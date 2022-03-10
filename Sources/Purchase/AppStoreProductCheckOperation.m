//
//  AppStoreProductCheckOperation.m

//  Created by Антон Красильников on 09/10/2018.
//

#import "AppStoreProductCheckOperation.h"

@interface AppStoreProductCheckOperation () <SKProductsRequestDelegate>

@property (nonatomic,copy) void (^completionHandler)(SKProductsResponse* responce);
@property (nonatomic,strong) SKProductsRequest* request;

@end

@implementation AppStoreProductCheckOperation

+(instancetype)scheduledOperationIds:(NSArray<NSString*>*)productdIds handler:(void (^)(SKProductsResponse* responce))handler
{
    AppStoreProductCheckOperation* operation = [AppStoreProductCheckOperation new];
    
    operation.completionHandler = handler;
    operation.request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productdIds]];
    operation.request.delegate = operation;
    [operation.request start];
    
    return operation;
}

- (void)dealloc
{
    _request.delegate = nil;
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (_completionHandler) {
            _completionHandler(response);
        }
    }];
}

@end
