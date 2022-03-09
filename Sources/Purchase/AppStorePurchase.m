//
//  AppStorePurchase.m
//  Created by Anton on 2/19/14.
//

#import "AppStorePurchase.h"
#import <StoreKit/StoreKit.h>

@implementation AppStorePurchase

- (id)init
{
    self = [super init];
    if (self) {
        self.isSandBox = NO;
    }
    return self;
}

- (void)dealloc
{
    self.product = nil;
    self.transactionIdentifier = nil;
    self.transactionReceipt = nil;
    self.purchasedDate = nil;
    
    [super dealloc];
}

+(AppStorePurchase*)purchaseWithProduct:(PurchaseProduct*)product transaction:(SKPaymentTransaction*)transaction
{
    AppStorePurchase* purchase = [[[AppStorePurchase alloc] init] autorelease];
    purchase.product = product;
    purchase.transactionIdentifier = transaction.transactionIdentifier;
    
    if (transaction.transactionState == SKPaymentTransactionStateRestored && transaction.originalTransaction.transactionDate != nil) {
        purchase.purchasedDate = transaction.originalTransaction.transactionDate;
    }else{
        purchase.purchasedDate = transaction.transactionDate;
    }
    
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    purchase.transactionReceipt = [NSData dataWithContentsOfURL:receiptUrl];

#ifdef DEBUG
    purchase.isSandBox = YES;
#endif
    
    return purchase;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [self init])) {
        self.product = [decoder decodeObjectOfClass:[PurchaseProduct class] forKey:@"product"];
        self.transactionIdentifier = [decoder decodeObjectOfClass:[NSString class] forKey:@"transactionIdentifier"];
        self.transactionReceipt = [decoder decodeObjectOfClass:[NSData class] forKey:@"transactionReceipt"];
        self.isSandBox = [decoder decodeBoolForKey:@"isSandBox"];
        self.purchasedDate = [decoder decodeObjectOfClass:[NSDate class] forKey:@"purchasedDate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_product forKey:@"product"];
    [encoder encodeObject:_transactionIdentifier forKey:@"transactionIdentifier"];
    [encoder encodeObject:_transactionReceipt forKey:@"transactionReceipt"];
    [encoder encodeBool:_isSandBox forKey:@"isSandBox"];
    [encoder encodeObject:_purchasedDate forKey:@"purchasedDate"];
}

@end
