//
//  AppStoreProductCheckOperation.h

//  Created by Антон Красильников on 09/10/2018.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface AppStoreProductCheckOperation : NSObject

+(instancetype)scheduledOperationIds:(NSArray<NSString*>*)productdIds handler:(void (^)(SKProductsResponse* responce))handler;

@end

