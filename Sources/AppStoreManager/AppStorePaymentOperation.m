//
//  AppStorePaymentOperation.m

//  Created by Антон Красильников on 09/10/2018.
//

#import "AppStorePaymentOperation.h"
#import "PaymentQueue.h"

@interface AppStorePaymentOperation () <SKPaymentTransactionObserver>

@property (nonatomic,strong) SKProduct* sk_product;
@property (nonatomic,strong) SKPayment *payment;
@property (nonatomic,strong) SKPaymentTransaction *transaction;
@property (nonatomic,copy) void (^handler)(AppStorePaymentOperation* operation, SKPaymentTransaction* transaction, NSError* error, BOOL userCancel);

@end

@implementation AppStorePaymentOperation

+(instancetype)scheduledOperation:(SKProduct*)sk_product handler:(void (^)(AppStorePaymentOperation* operation, SKPaymentTransaction* transaction, NSError* error, BOOL userCancel))handler
{
    AppStorePaymentOperation* operation = [AppStorePaymentOperation new];
    operation.sk_product = sk_product;
    operation.handler = handler;
    [operation run];
    return operation;
}

-(SKProduct*)product
{
    return _sk_product;
}

-(void)run
{
    if (_sk_product) {
        self.payment = [SKPayment paymentWithProduct:_sk_product];
        [[SKPaymentQueue defaultQueue] addPayment:_payment];
    }else
    {
        NSError* error = [NSError errorWithDomain:@"AppStoreManager" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Product is empty"}];
        if (_handler) {
            _handler(self,nil,error,NO);
        }
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [PaymentQueue addObserver:self];
    }
    return self;
}

- (void)dealloc
{
    [PaymentQueue removeObserver:self];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        if ([transaction.payment.productIdentifier isEqualToString:_sk_product.productIdentifier]) {
            switch (transaction.transactionState)
            {
                case SKPaymentTransactionStatePurchased:
                {
                    [self completeTransaction:transaction];
                }
                    break;
                    
                case SKPaymentTransactionStateFailed:
                {
                    [self failedTransaction:transaction];
                }
                    break;
                default:
                    
                    break;
            }
            break;
        }
    }
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    BOOL canceled = [transaction.error.domain isEqualToString:SKErrorDomain] && transaction.error.code == SKErrorPaymentCancelled;
    
    if (canceled) {
        NSLog(@"AppStore: user cancelled transaction: %@", [transaction description]);
    }else
    {
        NSLog(@"AppStore: error: %@", transaction.error);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    if(_handler)
    {
        _handler(self, nil,transaction.error,canceled);
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    self.transaction = transaction;
    
    if (_handler) {
        _handler(self,transaction,nil,NO);
    }    
}

@end
