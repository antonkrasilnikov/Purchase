//
//  AppStoreRestoreOperation.m

//  Created by Антон Красильников on 09/10/2018.
//

#import "AppStoreRestoreOperation.h"
#import "PaymentQueue.h"

@interface AppStoreRestoreOperation () <SKPaymentTransactionObserver>

@property (nonatomic,strong) SKProduct* sk_product;
@property (nonatomic,copy) void (^handler)(AppStoreRestoreOperation* operation, SKPaymentTransaction* transaction, NSError* error, BOOL userCancel);
@property (nonatomic,strong) SKPaymentTransaction* restoredTransaction;
@end

@implementation AppStoreRestoreOperation

+(instancetype)scheduledOperation:(SKProduct*)sk_product handler:(void (^)(AppStoreRestoreOperation* operation, SKPaymentTransaction* transaction, NSError* error, BOOL userCancel))handler
{
    AppStoreRestoreOperation* operation = [AppStoreRestoreOperation new];
    operation.sk_product = sk_product;
    operation.handler = handler;
    [operation run];
    return operation;
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

-(void)run
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStateRestored:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                if ([transaction.payment.productIdentifier isEqualToString:_sk_product.productIdentifier]) {
                    self.restoredTransaction = transaction;
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    if(self.handler)
    {
        self.handler(self, self.restoredTransaction, nil, NO);
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if(self.handler)
    {
        self.handler(self, nil, error, NO);
    }
}

@end
