//
//  AppStoreRestoreOperation.h

//  Created by Антон Красильников on 09/10/2018.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface AppStoreRestoreOperation : NSObject

+(instancetype)scheduledOperation:(SKProduct*)sk_product handler:(void (^)(AppStoreRestoreOperation* operation, SKPaymentTransaction* transaction, NSError* error, BOOL userCancel))handler;

@end

