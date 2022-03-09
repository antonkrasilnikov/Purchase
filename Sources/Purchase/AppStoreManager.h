//
//  AppStoreManager.h
//  Created by Антон Красильников on 09/10/2018.
//

#import <Foundation/Foundation.h>
#import "AppStorePurchase.h"

extern NSString* const kNotificationAppStoreManagerPromoteInAppBought;

@interface AppStoreManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (void)touch;

+ (BOOL)isInBuying;

+ (void)checkProducts:(NSArray<PurchaseProduct*>*)products
          withHandler:(void (^)(BOOL checked)) verifyBlock;

+ (void)buyProduct:(PurchaseProduct*) product
        onComplete:(void (^)(AppStorePurchase* purchase)) completionBlock
       onFailed:(void (^)(NSError* error, BOOL canceled)) failedBlock;

+ (NSArray<AppStorePurchase*>*)unfinishedPurchases;
+ (void)finishTransaction:(NSString*)transactionId;

+ (void)checkForBeenPayedNonConsumableProduct:(PurchaseProduct*)product
                               withOnComplete:(void (^)(BOOL wasAlreadyBuyed, AppStorePurchase* purchase))onRestoreCompleted
                                     onFailed:(void (^)(NSError* error))onRestoreFailed;
+ (void)restoreNonConsumablePurchasesWithOnComplete:(void (^)(NSArray<AppStorePurchase*>* purchases))onRestoreCompleted
                                     onFailed:(void (^)(NSError* error))onRestoreFailed;

@end
