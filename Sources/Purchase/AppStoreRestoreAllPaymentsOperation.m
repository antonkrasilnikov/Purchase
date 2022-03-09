//
//  AppStoreRestoreAllPaymentsOperation.m

//  Created by Антон Красильников on 25/02/2019.
//

#import "AppStoreRestoreAllPaymentsOperation.h"
#import "PaymentQueue.h"

@interface AppStoreRestoreAllPaymentsOperation () <SKPaymentTransactionObserver>

@property (nonatomic,copy) void (^handler)(AppStoreRestoreAllPaymentsOperation* operation, NSArray<SKPaymentTransaction*>* transactions, NSError* error, BOOL userCancel);
@property (nonatomic,retain) NSMutableArray<SKPaymentTransaction*>* restoredTransactions;

@end

@implementation AppStoreRestoreAllPaymentsOperation

+(instancetype)scheduledOperationWithHandler:(void (^)(AppStoreRestoreAllPaymentsOperation* operation, NSArray<SKPaymentTransaction*>* transactions, NSError* error, BOOL userCancel))handler
{
    AppStoreRestoreAllPaymentsOperation* operation = [[AppStoreRestoreAllPaymentsOperation new] autorelease];
    operation.handler = handler;
    [operation run];
    return operation;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [PaymentQueue addObserver:self];
        self.restoredTransactions = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    [PaymentQueue removeObserver:self];
    self.handler = nil;
    self.restoredTransactions = nil;
    [super dealloc];
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
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                [_restoredTransactions addObject:transaction];
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
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    if(self.handler)
    {
        self.handler(self, _restoredTransactions, nil, NO);
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if(self.handler)
    {
        self.handler(self, nil, error, NO);
    }
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"AppStore: failedTransaction");
}

@end
