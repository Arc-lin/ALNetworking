//
//  ALNetworkingBaseManager.h
//  ALNetworkingDemo
//
//  Created by Arclin on 17/3/1.
//  Copyright © 2017年 dankal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALNetworkingConfig.h"

@class ALNetworkingRequest,ALNetworkingResponse;

/* Callback block */
typedef void (^ALHTTPCallBackBlock)(ALNetworkingRequest *request,ALNetworkingResponse *response);

@interface ALNetworkingBaseManager : NSObject

/**
 Send a request

 @param request Request body
 @param block   Callback
 @return        Reqeust Task
 */
+ (NSURLSessionTask *)requestForRequest:(ALNetworkingRequest *)request reponseBlock:(ALHTTPCallBackBlock)block config:(ALNetworkingConfig *)config;

@end
