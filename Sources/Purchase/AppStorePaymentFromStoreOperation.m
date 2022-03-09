//
//  AppStorePaymentFromStoreOperation.m

//  Created by Антон Красильников on 09/10/2018.
//

#import "AppStorePaymentFromStoreOperation.h"
#import "PaymentQueue.h"

@interface AppStorePaymentFromStoreOperation () <SKPaymentTransactionObserver>


@end

@implementation AppStorePaymentFromStoreOperation

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
    [super dealloc];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    
}

- (BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product
{
    if ([_delegate respondsToSelector:@selector(shouldAddStorePayment:forProduct:)]) {
        return [_delegate shouldAddStorePayment:payment forProduct:product];
    }
    return NO;
}

@end
