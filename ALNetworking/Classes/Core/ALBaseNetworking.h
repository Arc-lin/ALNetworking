//
//  MMCBaseNeetworking.h
//  ALNetworking
//
//  Created by Arclin on 2018/4/21.
//

#import <Foundation/Foundation.h>
#import "ALNetworkingConst.h"

#import <AFNetworking/AFNetworking.h>

@class ALNetworkRequest,ALNetworkResponse;

@interface ALBaseNetworking : NSObject

+ (NSURLSessionDataTask *)requestWithRequest:(ALNetworkRequest *)req mockData:(id)mockData success:(void(^)(ALNetworkResponse *response,ALNetworkRequest *request))success failure:(void(^)(ALNetworkRequest *request,BOOL isCache,id responseObject,NSError *error))failure;

+ (NSURLSessionDataTask *)uploadWithRequest:(ALNetworkRequest *)req progress:(void(^)(float progress))progressBlock success:(void(^)(ALNetworkResponse *response,ALNetworkRequest *request))success failure:(void(^)(ALNetworkRequest *request,BOOL isCache,NSError *error))failure;

+ (NSURLSessionDownloadTask *)downloadWithRequest:(ALNetworkRequest *)req progress:(void(^)(float progress))progressBlock success:(void(^)(ALNetworkResponse *response,ALNetworkRequest *request))success failure:(void(^)(ALNetworkRequest *request,BOOL isCache,NSError *error))failure;

@end
