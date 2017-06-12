//
//  ALNetworkingBaseManager.m
//  ALNetworkingDemo
//
//  Created by Arclin on 17/3/1.
//  Copyright © 2017年 dankal. All rights reserved.
//

#import "ALNetworkingBaseManager.h"
#import <AFNetworking/AFNetworking.h>

#import "ALNetworkingConst.h"
#import "ALNetworkingResponse.h"
#import "ALNetworkingRequest.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#define ALCALLAPI(REQUEST_METHOD,REQUEST_TASK) \
{\
    task = [mgr REQUEST_METHOD:request.urlStr parameters:request.params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {\
                ALNetworkingResponse *response = [[ALNetworkingResponse alloc] init];\
                response.rawData               = responseObject;\
                request.task                   = task;\
                if (block) block(request,response);\
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {\
                ALNetworkingResponse *response = [[ALNetworkingResponse alloc] init];\
                response.error                 = error;\
                request.task                   = task;\
                if (block) block(request,response);\
            }];\
}

@implementation ALNetworkingBaseManager

+ (NSURLSessionTask *)requestForRequest:(ALNetworkingRequest *)request reponseBlock:(ALHTTPCallBackBlock)block config:(ALNetworkingConfig *)config
{
    ALNetworkRequestMethod  method = request.method;
    
    AFHTTPSessionManager   *mgr    = [AFHTTPSessionManager manager];
    
    // Setting accetable content types
    [mgr.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",@"text/html",@"text/json", @"text/javascript",@"text/plain",nil]];
    
    // Setting sequrity policy
    if (config.sslCerPath) {
        AFSecurityPolicy *securityPolicy        = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        securityPolicy.pinnedCertificates       = [NSSet setWithObject:[NSData dataWithContentsOfFile:config.sslCerPath]];
        securityPolicy.allowInvalidCertificates = NO;
        securityPolicy.validatesDomainName      = YES;
        mgr.securityPolicy                      = securityPolicy;
    }

    AFHTTPRequestSerializer *requestSerializer = mgr.requestSerializer;
    
    // Request by json type
    if(request.paramsType == ALNetworkRequestParamsTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    // Set request header
    if (request.header && request.header.allKeys.count > 0) {
        [request.header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id obj, BOOL * _Nonnull stop) {
            [requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    // Set timeout interval
    requestSerializer.timeoutInterval = config.timeoutInterval;
    
    mgr.requestSerializer = requestSerializer;
    
    NSURLSessionDataTask *task;
    
    switch (method) {
        case ALNetworkRequestMethodGET:
            ALCALLAPI(GET, task)
            break;
        case ALNetworkRequestMethodPOST:
            ALCALLAPI(POST, task)
            break;
        case ALNetworkRequestMethodPUT:
            ALCALLAPI(PUT, task)
            break;
        case ALNetworkRequestMethodPATCH:
            ALCALLAPI(PATCH, task)
            break;
        case ALNetworkRequestMethodDELETE:
            ALCALLAPI(DELETE, task)
            break;
        default:
            break;
    }
    
    return task;
}

@end

#pragma clang diagnostic pop
