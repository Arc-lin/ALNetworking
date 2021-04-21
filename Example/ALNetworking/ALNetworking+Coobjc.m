//
//  ALNetworking+Coobjc.m
//  ALNetworking_Example
//
//  Created by Arclin on 2019/12/15.
//

#import "ALNetworking+Coobjc.h"

@implementation ALNetworking (Coobjc)

- (COPromise *)co_executeRequest CO_ASYNC
{
    SURE_ASYNC
    
    COPromise *promise = [COPromise promise];
    
    self.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
        if (error) {
            [promise reject:error];
        } else {
            [promise fulfill:co_tuple(response,request,error)];
        }
    };
    
    return promise;
}

@end
