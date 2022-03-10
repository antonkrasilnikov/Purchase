//
//  PurchaseProduct.h
//  Created by Anton on 11/13/12.
//

#import <Foundation/Foundation.h>

@interface PurchaseProduct : NSObject <NSCoding>

@property (nonatomic,strong,nonnull)  NSString* identifier;
@property (nonatomic,strong,nullable) NSString* name;
@property (nonatomic,strong,nullable) NSString* currency;
@property (nonatomic,assign)          float     price;
@property (nonatomic,assign)          BOOL      checked NS_SWIFT_NAME(isChecked);

-(instancetype _Nonnull)initWithIdentifier:(NSString* _Nonnull)identifier;

@end
