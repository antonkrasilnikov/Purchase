//
//  PaymentQueue.m

//  Created by Антон Красильников on 10/10/2018.
//

#import "PaymentQueue.h"

static PaymentQueue* _queue = nil;

@implementation NSMutableArray (WeakReferences)
+ (id)mutableArrayUsingWeakReferences {
    return [self mutableArrayUsingWeakReferencesWithCapacity:0];
}

+ (id)mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity {
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    return (id)CFBridgingRelease(CFArrayCreateMutable(0, capacity, &callbacks));
}
@end

@interface PaymentQueue () <SKPaymentTransactionObserver>

@property (nonatomic,strong) NSMutableArray<id<SKPaymentTransactionObserver>>* observers;

@end

@implementation PaymentQueue

+(PaymentQueue*)queue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _queue = [self new];
    });
    return _queue;
}

+(void)addObserver:(id<SKPaymentTransactionObserver>)observer
{
    [[self queue] _addObserver:observer];
}

+(void)removeObserver:(id<SKPaymentTransactionObserver>)observer
{
    [[self queue] _removeObserver:observer];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.observers = [NSMutableArray mutableArrayUsingWeakReferences];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(NSArray<id<SKPaymentTransactionObserver>>*)getStrongRefObservers
{
    NSMutableArray<id<SKPaymentTransactionObserver>>* observers = [NSMutableArray array];
    
    for (id<SKPaymentTransactionObserver> observer in _observers) {
        [observers addObject:observer];
    }
    return observers;
}

-(void)_addObserver:(id<SKPaymentTransactionObserver>)observer
{
    if (observer && ![_observers containsObject:observer]) {
        [_observers addObject:observer];
    }
}

-(void)_removeObserver:(id<SKPaymentTransactionObserver>)observer
{
    if (observer && [_observers containsObject:observer]) {
        [_observers removeObject:observer];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    NSArray* observers = [self getStrongRefObservers];
    
    for (id<SKPaymentTransactionObserver> observer in observers) {
        if ([observer respondsToSelector:@selector(paymentQueue:updatedTransactions:)]) {
            [observer paymentQueue:queue updatedTransactions:transactions];
        }
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    NSArray* observers = [self getStrongRefObservers];
    for (id<SKPaymentTransactionObserver> observer in observers) {
        if ([observer respondsToSelector:@selector(paymentQueue:removedTransactions:)]) {
            [observer paymentQueue:queue removedTransactions:transactions];
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSArray* observers = [self getStrongRefObservers];
    for (id<SKPaymentTransactionObserver> observer in observers) {
        if ([observer respondsToSelector:@selector(paymentQueue:restoreCompletedTransactionsFailedWithError:)]) {
            [observer paymentQueue:queue restoreCompletedTransactionsFailedWithError:error];
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSArray* observers = [self getStrongRefObservers];
    for (id<SKPaymentTransactionObserver> observer in observers) {
        if ([observer respondsToSelector:@selector(paymentQueueRestoreCompletedTransactionsFinished:)]) {
            [observer paymentQueueRestoreCompletedTransactionsFinished:queue];
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads
{
    NSArray* observers = [self getStrongRefObservers];
    for (id<SKPaymentTransactionObserver> observer in observers) {
        if ([observer respondsToSelector:@selector(paymentQueue:updatedDownloads:)]) {
            [observer paymentQueue:queue updatedDownloads:downloads];
        }
    }
}

- (BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product NS_AVAILABLE_IOS(11_0)
{
    NSArray* observers = [self getStrongRefObservers];
    BOOL returnValue = NO;
    for (id<SKPaymentTransactionObserver> observer in observers) {
        if ([observer respondsToSelector:@selector(paymentQueue:shouldAddStorePayment:forProduct:)]) {
            returnValue |= [observer paymentQueue:queue shouldAddStorePayment:payment forProduct:product];
        }
    }
    return returnValue;
}

@end
