//
//  AppStoreManager.h
//  Created by Антон Красильников on 09/10/2018.
//

#import <Foundation/Foundation.h>
#import "AppStorePurchase.h"

extern _Nonnull NSNotificationName const AppStoreManagerPromoteInAppBought;

@interface AppStoreManager : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;

+ (void)touch;

+ (BOOL)isInBuying;

+ (void)checkProducts:(NSArray<PurchaseProduct*>* _Nonnull)products
          withHandler:(void (^ _Nonnull)(BOOL checked)) verifyBlock;

+ (void)buyProduct:(PurchaseProduct* _Nonnull) product
        onComplete:(void (^ _Nonnull)(AppStorePurchase* _Nonnull purchase)) completionBlock
       onFailed:(void (^ _Nullable)(NSError* _Nullable error, BOOL canceled)) failedBlock;

+ (NSArray<AppStorePurchase*>* _Nonnull)unfinishedPurchases;
+ (void)finishTransaction:(NSString* _Nonnull)transactionId;

+ (void)checkForBeenPayedNonConsumableProduct:(PurchaseProduct* _Nonnull)product
                               withOnComplete:(void (^ _Nonnull)(BOOL wasAlreadyBuyed, AppStorePurchase* _Nullable purchase))onRestoreCompleted
                                     onFailed:(void (^ _Nullable)(NSError* _Nullable error))onRestoreFailed;
+ (void)restoreNonConsumablePurchasesWithOnComplete:(void (^ _Nonnull)(NSArray<AppStorePurchase*>* _Nullable purchases))onRestoreCompleted
                                     onFailed:(void (^ _Nullable)(NSError* _Nullable error))onRestoreFailed;

@end
