//
//  AppStoreManager.m
//  Created by Антон Красильников on 09/10/2018.
//

#import "AppStoreManager.h"
#import <StoreKit/StoreKit.h>
#import "AppStorePaymentOperation.h"
#import "AppStoreRestoreOperation.h"
#import "AppStoreProductCheckOperation.h"
#import "AppStorePaymentFromStoreOperation.h"
#import "AppStoreRestoreAllPaymentsOperation.h"
#import "PurchaseProduct.h"

NSNotificationName const AppStoreManagerPromoteInAppBought = @"NotificationAppStoreManagerPromoteInAppBought";

static AppStoreManager* _store = nil;

@interface AppStoreManager () <PaymentFromStoreDelegate>

@property (nonatomic,strong) NSMutableArray<SKProduct*> *purchasableObjects;
@property (nonatomic,strong) NSMutableArray<AppStorePaymentOperation*>* activePaymentOperations;
@property (nonatomic,strong) NSMutableArray<AppStoreRestoreOperation*>* activeRestoreOperations;
@property (nonatomic,strong) NSMutableArray<AppStoreRestoreAllPaymentsOperation*>* activeRestoreAllPaymentsOperations;
@property (nonatomic,strong) NSMutableArray<AppStoreProductCheckOperation*>* activeCheckOperations;
@property (nonatomic,strong) SKPayment *promotedPayment;
@property (nonatomic,strong) AppStorePaymentFromStoreOperation* fromStoreOperation;

@end

@implementation AppStoreManager

+(instancetype)store
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _store = [[AppStoreManager alloc] initStore];
    });
    return _store;
}

+ (void)touch
{
    [self store];
}

+ (BOOL)isInBuying
{
    return _store.activePaymentOperations.count + _store.activeRestoreOperations.count > 0;
}

+ (void)checkProducts:(NSArray<PurchaseProduct*>*)products
          withHandler:(void (^)(BOOL checked)) verifyBlock
{
    [[self store] _checkProducts:products withHandler:verifyBlock];
}

+ (void)buyProduct:(PurchaseProduct*) product
        onComplete:(void (^)(AppStorePurchase* purchase)) completionBlock
       onFailed:(void (^)(NSError* error, BOOL canceled)) failedBlock
{
    [[self store] _buyProduct:product onComplete:completionBlock onFailed:failedBlock];
}

+ (NSArray<SKPaymentTransaction *>*)unfinishedTransactions
{
    return [[self store] _unfinishedTransactions];
}

+ (NSArray<AppStorePurchase*>*)unfinishedPurchases
{
    return [[self store] _unfinishedPurchases];
}

+ (void)finishTransaction:(NSString*)transactionId
{
    [[self store] _finishTransaction:transactionId];
}

+ (void)checkForBeenPayedNonConsumableProduct:(PurchaseProduct*)product
                               withOnComplete:(void (^)(BOOL wasAlreadyBuyed, AppStorePurchase* purchase))onRestoreCompleted
                                     onFailed:(void (^)(NSError* error))onRestoreFailed
{
    [[self store] _checkForBeenPayedNonConsumableProduct:product withOnComplete:onRestoreCompleted onFailed:onRestoreFailed];
}

+ (void)restoreNonConsumablePurchasesWithOnComplete:(void (^)(NSArray<AppStorePurchase*>* purchases))onRestoreCompleted
                                           onFailed:(void (^)(NSError* error))onRestoreFailed
{
    [[self store] _restoreNonConsumablePurchasesWithOnComplete:onRestoreCompleted onFailed:onRestoreFailed];
}

//

- (instancetype)initStore
{
    self = [super init];
    if (self) {
        self.purchasableObjects = [NSMutableArray array];
        self.activePaymentOperations = [NSMutableArray array];
        self.activeRestoreOperations = [NSMutableArray array];
        self.activeRestoreAllPaymentsOperations = [NSMutableArray array];
        self.activeCheckOperations = [NSMutableArray array];
        self.fromStoreOperation = [AppStorePaymentFromStoreOperation new];
        _fromStoreOperation.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    _fromStoreOperation.delegate = nil;
}

-(NSArray<SKPaymentTransaction *>*)_unfinishedTransactions
{
    NSMutableArray<SKPaymentTransaction *>* purchasedTransactions = [NSMutableArray array];
    
    NSArray<SKPaymentTransaction *>* transactions = [SKPaymentQueue defaultQueue].transactions;
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
            {
                [purchasedTransactions addObject:transaction];
            }
                break;
                
            default:
                
                break;
        }
    }
    return purchasedTransactions;
}

- (void)_checkProducts:(NSArray<PurchaseProduct*>*)products
          withHandler:(void (^)(BOOL checked)) verifyBlock
{
    NSMutableArray* productsToCheck = [NSMutableArray arrayWithArray:products ? products : @[]];
    
    for (PurchaseProduct* product in products) {
        for (SKProduct* _obj in _purchasableObjects) {
            if ([product.identifier isEqualToString:_obj.productIdentifier]) {
                [self fillProduct:product fromPurchasableObj:_obj];
                [productsToCheck removeObject:product];
                break;
            }
        }
    }
    if (productsToCheck.count == 0) {
        if (verifyBlock) {
            verifyBlock(YES);
        }
    }else
    {
        __weak typeof(self) _self = self;
        NSArray* ids = [productsToCheck valueForKey:@"identifier"];
        __block AppStoreProductCheckOperation* operation = [AppStoreProductCheckOperation scheduledOperationIds:ids handler:^(SKProductsResponse *responce) {
            
            for(SKProduct *sk_product in responce.products)
            {
                NSLog(@"AppStore: %@, Cost: %f, ID: %@",[sk_product localizedTitle],
                      [[sk_product price] doubleValue], [sk_product productIdentifier]);
                
                PurchaseProduct* relateProduct = nil;
                
                for (PurchaseProduct* product in productsToCheck) {
                    if ([product.identifier isEqualToString:[sk_product productIdentifier]]) {
                        [_self fillProduct:product fromPurchasableObj:sk_product];
                        relateProduct = product;
                        break;
                    }
                }
                if (![_purchasableObjects containsObject:sk_product]) {
                    [_purchasableObjects addObject:sk_product];
                }
                if (_promotedPayment && [sk_product.productIdentifier isEqualToString:_promotedPayment.productIdentifier]) {
                    [_self _buyPromotedProduct:sk_product];
                }
            }
            
            for(NSString *invalidProduct in responce.invalidProductIdentifiers)
                NSLog(@"AppStore: Problem in iTunes connect configuration for product: %@", invalidProduct);
            
            if (verifyBlock) {
                verifyBlock(YES);
            }
            
            [self.activeCheckOperations removeObject:operation];
        }];
        
        [_activeCheckOperations addObject:operation];
    }
}

-(SKProduct*)purchasableObjForProduct:(PurchaseProduct*)product
{
    NSArray *allIds = [self.purchasableObjects valueForKey:@"productIdentifier"];
    NSUInteger index = [allIds indexOfObject:product.identifier];
    
    if (index == NSNotFound)
    {
        return nil;
    }
    
    return [self.purchasableObjects objectAtIndex:index];
}

- (void)_buyProduct:(PurchaseProduct*) product
        onComplete:(void (^)(AppStorePurchase* purchase)) completionBlock
       onFailed:(void (^)(NSError* error, BOOL canceled)) failedBlock
{
    if ([SKPaymentQueue canMakePayments] && product != nil)
    {
        SKProduct *sk_product = [self purchasableObjForProduct:product];
        
        if (sk_product == nil)
        {
            __weak typeof(self) _self = self;
            
            [self _checkProducts:@[product] withHandler:^(BOOL checked) {
                SKProduct *sk_product = [_self purchasableObjForProduct:product];
                if (sk_product != nil) {
                    [_self _buyProduct:product onComplete:completionBlock onFailed:failedBlock];
                }else
                {
                    if (failedBlock) {
                        NSError* error = [NSError errorWithDomain:@"AppStoreManager" code:1 userInfo:@{NSLocalizedDescriptionKey : @"Product is unavailable"}];
                        failedBlock(error,NO);
                    }
                }
            }];
            
            return;
        }
        
        for (AppStorePaymentOperation* queued_operation in _activePaymentOperations) {
            if ([queued_operation.product isEqual:sk_product]) {
                if (failedBlock) {
                    failedBlock(nil,YES);
                }
                NSLog(@"AppStore: product has been already queued");
                return;
            }
        }
        
        AppStorePaymentOperation* operation = [AppStorePaymentOperation scheduledOperation:sk_product handler:^(AppStorePaymentOperation* _operation, SKPaymentTransaction *transaction, NSError *error, BOOL userCancel) {
            
            if (transaction != nil) {
                AppStorePurchase* purchase = [AppStorePurchase purchaseWithProduct:product transaction:transaction isRestore:NO];
                if (completionBlock) {
                    completionBlock(purchase);
                }
            }else
            {
                if (failedBlock) {
                    failedBlock(error,userCancel);
                }
            }
            [_activePaymentOperations removeObject:_operation];
        }];
        [_activePaymentOperations addObject:operation];
    }
    else
    {
        if (failedBlock) {
            NSError* error = [NSError errorWithDomain:@"AppStoreManager" code:0 userInfo:@{NSLocalizedDescriptionKey : @"AppStore is unavailable"}];
            failedBlock(error,NO);
        }
    }
}

- (void)_finishTransaction:(NSString*)transactionId
{
    NSArray<SKPaymentTransaction*>* transactions = [self _unfinishedTransactions];
    for (SKPaymentTransaction* transaction in transactions) {
        if ([transaction.transactionIdentifier isEqualToString:transactionId]) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}

- (NSArray<AppStorePurchase*>*)_unfinishedPurchases
{
    NSArray<SKPaymentTransaction *>* transactions = [self _unfinishedTransactions];
    
    NSMutableArray<AppStorePurchase*>* purchases = [NSMutableArray array];
    
    for (SKPaymentTransaction* transaction in transactions) {
        PurchaseProduct* product = [PurchaseProduct new];
        product.identifier = transaction.payment.productIdentifier;
        
        for (SKProduct* _obj in _purchasableObjects) {
            if ([product.identifier isEqualToString:_obj.productIdentifier]) {
                [self fillProduct:product fromPurchasableObj:_obj];
                break;
            }
        }
        
        AppStorePurchase* purchase = [AppStorePurchase purchaseWithProduct:product transaction:transaction isRestore:NO];
        [purchases addObject:purchase];
    }
    
    return purchases;
}

- (void)_checkForBeenPayedNonConsumableProduct:(PurchaseProduct*)product
                               withOnComplete:(void (^)(BOOL wasAlreadyBuyed, AppStorePurchase* purchase))onRestoreCompleted
                                     onFailed:(void (^)(NSError* error))onRestoreFailed
{
    if ([SKPaymentQueue canMakePayments] && product != nil) {
        
        SKProduct *sk_product = [self purchasableObjForProduct:product];
        
        if (sk_product == nil)
        {
            __weak typeof(self) _self = self;
            
            [self _checkProducts:@[product] withHandler:^(BOOL checked) {
                SKProduct *sk_product = [_self purchasableObjForProduct:product];
                if (sk_product != nil) {
                    [_self _checkForBeenPayedNonConsumableProduct:product withOnComplete:onRestoreCompleted onFailed:onRestoreFailed];
                }else
                {
                    if (onRestoreFailed) {
                        NSError* error = [NSError errorWithDomain:@"AppStoreManager" code:1 userInfo:@{NSLocalizedDescriptionKey : @"Product is unavailable"}];
                        onRestoreFailed(error);
                    }
                }
            }];
            
            return;
        }
        
        AppStoreRestoreOperation* operation = [AppStoreRestoreOperation scheduledOperation:sk_product handler:^(AppStoreRestoreOperation *_operation, SKPaymentTransaction *transaction, NSError *error, BOOL userCancel) {
            
            if (transaction != nil) {
                AppStorePurchase* purchase = [AppStorePurchase purchaseWithProduct:product transaction:transaction isRestore:YES];
                if (onRestoreCompleted) {
                    onRestoreCompleted(YES,purchase);
                }
            }else if (error != nil)
            {
                if (onRestoreFailed) {
                    onRestoreFailed(error);
                }
            }else
            {
                if (onRestoreCompleted) {
                    onRestoreCompleted(NO,nil);
                }
            }
            
            [_activeRestoreOperations removeObject:_operation];
        }];
        [_activeRestoreOperations addObject:operation];
    }else
    {
        if (onRestoreFailed) {
            NSError* error = [NSError errorWithDomain:@"AppStoreManager" code:0 userInfo:@{NSLocalizedDescriptionKey : @"AppStore is unavailable"}];
            onRestoreFailed(error);
        }
    }
}

- (void)_restoreNonConsumablePurchasesWithOnComplete:(void (^)(NSArray<AppStorePurchase*>* purchases))onRestoreCompleted
                                            onFailed:(void (^)(NSError* error))onRestoreFailed
{
    if ([SKPaymentQueue canMakePayments])
    {
        AppStoreRestoreAllPaymentsOperation* operation = [AppStoreRestoreAllPaymentsOperation scheduledOperationWithHandler:^(AppStoreRestoreAllPaymentsOperation *_operation, NSArray<SKPaymentTransaction *> *transactions, NSError *error, BOOL userCancel) {
            
            if (transactions != nil) {
                
                NSMutableArray<AppStorePurchase*>* purchases = [NSMutableArray array];
                
                transactions = [transactions sortedArrayUsingComparator:^NSComparisonResult(SKPaymentTransaction*  _Nonnull transaction1, SKPaymentTransaction*  _Nonnull transaction2) {
                    return [transaction1.transactionDate compare:transaction2.transactionDate];
                }];
                
                for (SKPaymentTransaction* transaction in transactions) {
                    PurchaseProduct* product = [PurchaseProduct new];
                    product.identifier = transaction.payment.productIdentifier;
                    AppStorePurchase* purchase = [AppStorePurchase purchaseWithProduct:product transaction:transaction isRestore:YES];
                    
                    for (AppStorePurchase* _purchase in purchases) {
                        if ([_purchase.product isEqual:purchase.product]) {
                            [purchases removeObject:_purchase];
                            break;
                        }
                    }
                    [purchases addObject:purchase];
                }
                
                if (onRestoreCompleted) {
                    onRestoreCompleted(purchases);
                }
            }else if (error != nil)
            {
                if (onRestoreFailed) {
                    onRestoreFailed(error);
                }
            }else
            {
                if (onRestoreCompleted) {
                    onRestoreCompleted(nil);
                }
            }
            
            [_activeRestoreAllPaymentsOperations removeObject:_operation];
        }];
        [_activeRestoreAllPaymentsOperations addObject:operation];
    }else
    {
        if (onRestoreFailed) {
            NSError* error = [NSError errorWithDomain:@"AppStoreManager" code:0 userInfo:@{NSLocalizedDescriptionKey : @"AppStore is unavailable"}];
            onRestoreFailed(error);
        }
    }
}

-(void)fillProduct:(PurchaseProduct*)product fromPurchasableObj:(SKProduct*)sk_product
{
    product.checked = YES;
    product.price = [[sk_product price] doubleValue];
    product.name = [sk_product localizedTitle];
    product.currency = [sk_product.priceLocale objectForKey:@"currency"];
}

// from store delegate

-(void)_buyPromotedProduct:(SKProduct*)sk_product
{
    if (_promotedPayment && [sk_product.productIdentifier isEqualToString:_promotedPayment.productIdentifier]) {
        self.promotedPayment = nil;
        PurchaseProduct* product = [PurchaseProduct new];
        product.identifier = sk_product.productIdentifier;
        [self _buyProduct:product onComplete:^(AppStorePurchase *purchase) {
            [[NSNotificationCenter defaultCenter] postNotificationName:AppStoreManagerPromoteInAppBought object:purchase];
        } onFailed:^(NSError *error, BOOL canceled) {
            
        }];
    }
}

- (BOOL)shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product
{
    self.promotedPayment = payment;
    
    for (SKProduct *checkedProduct in self.purchasableObjects) {
        if ([checkedProduct.productIdentifier isEqualToString:product.productIdentifier]) {
            [self _buyPromotedProduct:product];
            break;
        }
    }
    
    return NO;
}

@end
