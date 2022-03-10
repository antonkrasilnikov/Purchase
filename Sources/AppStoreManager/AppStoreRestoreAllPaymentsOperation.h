//
//  AppStoreRestoreAllPaymentsOperation.h

//  Created by Антон Красильников on 25/02/2019.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface AppStoreRestoreAllPaymentsOperation : NSObject

+(instancetype)scheduledOperationWithHandler:(void (^)(AppStoreRestoreAllPaymentsOperation* operation, NSArray<SKPaymentTransaction*>* transactions, NSError* error, BOOL userCancel))handler;

@end
