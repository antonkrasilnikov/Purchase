//
//  AppStorePaymentFromStoreOperation.h

//  Created by Антон Красильников on 09/10/2018.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


@protocol PaymentFromStoreDelegate <NSObject>

- (BOOL)shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product;

@end

@interface AppStorePaymentFromStoreOperation : NSObject

@property (nonatomic,assign) id<PaymentFromStoreDelegate> delegate;

@end

