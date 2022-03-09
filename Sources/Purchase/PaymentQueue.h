//
//  PaymentQueue.h

//  Created by Антон Красильников on 10/10/2018.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface PaymentQueue : NSObject

+(void)addObserver:(id<SKPaymentTransactionObserver>)observer;
+(void)removeObserver:(id<SKPaymentTransactionObserver>)observer;

@end
