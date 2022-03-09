//
//  AppStoreProductCheckOperation.m

//  Created by Антон Красильников on 09/10/2018.
//

#import "AppStoreProductCheckOperation.h"

@interface AppStoreProductCheckOperation () <SKProductsRequestDelegate>

@property (nonatomic,copy) void (^completionHandler)(SKProductsResponse* responce);
@property (nonatomic,retain) SKProductsRequest* request;

@end

@implementation AppStoreProductCheckOperation

+(void)checkIds:(NSArray<NSString*>*)productdIds handler:(void (^)(SKProductsResponse* responce))handler
{
    AppStoreProductCheckOperation* operation = [AppStoreProductCheckOperation new];
    
    operation.completionHandler = handler;
    operation.request = [[[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productdIds]] autorelease];
    operation.request.delegate = operation;
    [operation.request start];
    
}

- (void)dealloc
{
    _request.delegate = nil;
    self.request = nil;
    self.completionHandler = nil;
    [super dealloc];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (_completionHandler) {
            _completionHandler(response);
        }
        [self release];
    }];
}

@end
