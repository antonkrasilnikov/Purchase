//
//  PurchaseProduct.m
//  Created by Anton on 11/13/12.
//

#import "PurchaseProduct.h"

@implementation PurchaseProduct

-(id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)dealloc
{
    self.name = nil;
    self.identifier = nil;
    self.cashName = nil;
    [super dealloc];
}

-(BOOL)isEqual:(PurchaseProduct*)object
{
    return [object isKindOfClass:[PurchaseProduct class]] && _identifier.length > 0 && object.identifier.length > 0 && [_identifier isEqualToString:object.identifier];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [self init])) {
        self.name = [decoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        self.identifier = [decoder decodeObjectOfClass:[NSString class] forKey:@"identifier"];
        self.cashName = [decoder decodeObjectOfClass:[NSString class] forKey:@"cashName"];
        self.price = [decoder decodeFloatForKey:@"price"];
        self.enabled = [decoder decodeBoolForKey:@"enabled"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_identifier forKey:@"identifier"];
    [encoder encodeObject:_cashName forKey:@"cashName"];
    [encoder encodeFloat:_price forKey:@"price"];
    [encoder encodeBool:_enabled forKey:@"enabled"];
}

@end
