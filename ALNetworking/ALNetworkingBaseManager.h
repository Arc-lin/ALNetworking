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

/* 请求回调 */
typedef void (^ALHTTPCallBackBlock)(ALNetworkingRequest *request,ALNetworkingResponse *response);

@interface ALNetworkingBaseManager : NSObject

/**
 发送一个请求

 @param request 请求体
 @param block   回调
 @return        请求任务
 */
+ (NSURLSessionTask *)requestForRequest:(ALNetworkingRequest *)request reponseBlock:(ALHTTPCallBackBlock)block config:(ALNetworkingConfig *)config;

@end
