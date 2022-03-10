//
//  PurchaseProduct.m
//  Created by Anton on 11/13/12.
//

#import "PurchaseProduct.h"

static NSString* const kName        = @"name";
static NSString* const kIdentifier  = @"identifier";
static NSString* const kCurrency    = @"currency";
static NSString* const kPrice       = @"price";
static NSString* const kChecked     = @"checked";

@implementation PurchaseProduct

-(instancetype _Nonnull)initWithIdentifier:(NSString* _Nonnull)identifier
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
    }
    return self;
}

-(BOOL)isEqual:(PurchaseProduct*)object
{
    return [object isKindOfClass:[PurchaseProduct class]] &&
    _identifier.length > 0 && object.identifier.length > 0
    && [_identifier isEqualToString:object.identifier];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [self init])) {
        self.name = [decoder decodeObjectOfClass:[NSString class] forKey:kName];
        self.identifier = [decoder decodeObjectOfClass:[NSString class] forKey:kIdentifier];
        self.currency = [decoder decodeObjectOfClass:[NSString class] forKey:kCurrency];
        self.price = [decoder decodeFloatForKey:kPrice];
        self.checked = [decoder decodeBoolForKey:kChecked];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_name forKey:kName];
    [encoder encodeObject:_identifier forKey:kIdentifier];
    [encoder encodeObject:_currency forKey:kCurrency];
    [encoder encodeFloat:_price forKey:kPrice];
    [encoder encodeBool:_checked forKey:kChecked];
}

@end
