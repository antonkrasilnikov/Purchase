//
//  AppStorePurchase.m
//  Created by Anton on 2/19/14.
//

#import "AppStorePurchase.h"
#import <StoreKit/StoreKit.h>

static NSString* const kProduct                 = @"product";
static NSString* const kTransactionIdentifier   = @"transactionIdentifier";
static NSString* const kTransactionReceipt      = @"transactionReceipt";
static NSString* const kPurchasedDate           = @"purchasedDate";
static NSString* const kIsSandBox               = @"isSandBox";
static NSString* const kIsRestore               = @"isRestore";

@interface AppStorePurchase ()

@property (nonatomic,strong) PurchaseProduct* product;
@property (nonatomic,strong) NSString* transactionIdentifier;
@property (nonatomic,strong) NSData*   transactionReceipt;
@property (nonatomic,strong) NSDate*   purchasedDate;
@property (nonatomic,assign) BOOL      isSandBox;
@property (nonatomic,assign) BOOL      isRestore;

@end

@implementation AppStorePurchase

- (id)initWith:(PurchaseProduct*) product
              :(NSString*) transactionIdentifier
              :(NSData*)   transactionReceipt
              :(NSDate*)   purchasedDate
              :(BOOL)      isSandBox
              :(BOOL)      isRestore
{
    self = [super init];
    if (self) {
        self.product = product;
        self.transactionIdentifier = transactionIdentifier;
        self.transactionReceipt = transactionReceipt;
        self.purchasedDate = purchasedDate;
        self.isSandBox = isSandBox;
        self.isRestore = isRestore;
    }
    return self;
}

+(AppStorePurchase*)purchaseWithProduct:(PurchaseProduct*)product transaction:(SKPaymentTransaction*)transaction isRestore:(BOOL)isRestore
{
    NSDate* purchasedDate = nil;
    
    if (transaction.transactionState == SKPaymentTransactionStateRestored && transaction.originalTransaction.transactionDate != nil) {
        purchasedDate = transaction.originalTransaction.transactionDate;
    }else{
        purchasedDate = transaction.transactionDate;
    }
    
    BOOL isSandBox = NO;
#ifdef DEBUG
    isSandBox = YES;
#endif
    
    return [[AppStorePurchase alloc] initWith:product
                                             :transaction.transactionIdentifier
                                             :[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]]
                                             :purchasedDate
                                             :isSandBox
                                             :isRestore];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    return [self initWith:[decoder decodeObjectOfClass:[PurchaseProduct class] forKey:kProduct]
                         :[decoder decodeObjectOfClass:[NSString class] forKey:kTransactionIdentifier]
                         :[decoder decodeObjectOfClass:[NSData class] forKey:kTransactionReceipt]
                         :[decoder decodeObjectOfClass:[NSDate class] forKey:kPurchasedDate]
                         :[decoder decodeBoolForKey:kIsSandBox]
                         :[decoder decodeBoolForKey:kIsRestore]];

}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_product forKey:kProduct];
    [encoder encodeObject:_transactionIdentifier forKey:kTransactionIdentifier];
    [encoder encodeObject:_transactionReceipt forKey:kTransactionReceipt];
    [encoder encodeBool:_isSandBox forKey:kIsSandBox];
    [encoder encodeBool:_isRestore forKey:kIsRestore];
    [encoder encodeObject:_purchasedDate forKey:kPurchasedDate];
}

@end
