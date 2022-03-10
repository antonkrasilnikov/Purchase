//
//  AppStorePaymentOperation.h

//  Created by Антон Красильников on 09/10/2018.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface AppStorePaymentOperation : NSObject

-(SKProduct*)product;

+(instancetype)scheduledOperation:(SKProduct*)sk_product handler:(void (^)(AppStorePaymentOperation* operation, SKPaymentTransaction* transaction, NSError* error, BOOL userCancel))handler;

@end

