//
//  PurchaseProduct.h
//  Created by Anton on 11/13/12.
//

#import <Foundation/Foundation.h>

@interface PurchaseProduct : NSObject <NSCoding>

@property (nonatomic,retain) NSString*    identifier;
@property (nonatomic,retain) NSString*    name;
@property (nonatomic,retain) NSString*    cashName;
@property (nonatomic,assign) float        price;
@property (nonatomic,assign) BOOL         enabled;

@end
