//
//  AppStorePurchase.h
//  Created by Anton on 2/19/14.
//

#import <Foundation/Foundation.h>
#import "PurchaseProduct.h"

@class SKPaymentTransaction;

@interface AppStorePurchase : NSObject <NSCoding>

@property (nonatomic,retain) PurchaseProduct* product;
@property (nonatomic,retain) NSString* transactionIdentifier;
@property (nonatomic,retain) NSData*   transactionReceipt;
@property (nonatomic,retain) NSDate*   purchasedDate;
@property (nonatomic,assign) BOOL      isSandBox;

+(AppStorePurchase*)purchaseWithProduct:(PurchaseProduct*)product transaction:(SKPaymentTransaction*)transaction;

@end
