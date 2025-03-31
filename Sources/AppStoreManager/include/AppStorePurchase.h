//
//  AppStorePurchase.h
//  Created by Anton on 2/19/14.
//

#import <Foundation/Foundation.h>
#import "PurchaseProduct.h"

@class SKPaymentTransaction;

@interface AppStorePurchase : NSObject <NSCoding>

@property (nonatomic,strong,nonnull,readonly) PurchaseProduct* product;
@property (nonatomic,strong,nonnull,readonly) NSString* transactionIdentifier;
@property (nonatomic,strong,nonnull,readonly) NSData*   transactionReceipt;
@property (nonatomic,strong,nonnull,readonly) NSDate*   purchasedDate;
@property (nonatomic,assign,readonly)         BOOL      isSandBox;
@property (nonatomic,assign,readonly)         BOOL      isRestore;

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;

+(AppStorePurchase* _Nonnull)purchaseWithProduct:(PurchaseProduct* _Nonnull)product
                                     transaction:(SKPaymentTransaction* _Nonnull)transaction
                                       isRestore:(BOOL)isRestore;

@end
