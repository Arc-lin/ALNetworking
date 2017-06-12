//
//  ALNetworking.h
//  ALNetworkingDemo
//
//  Created by Arclin on 17/2/25.
//  Copyright © 2017年 dankal. All rights reserved.
//
//  封装: AFNetworking MJExtension YYCache ReactiveCocoa

#import <Foundation/Foundation.h>

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "ALNetworkingConfig.h"
#import "ALNetworkingConst.h"

#import "ALNetworkingRequest.h"
#import "ALNetworkingResponse.h"

@class ALNetworkingRequest;

@interface ALNetworking : NSObject

/** Singleton */
+ (instancetype)sharedInstance;

/** Observer the network status */
+ (void)networkStatus:(void(^)(ALNetworkReachabilityStatus networkStatus))statusBlock;

/** Request method */
- (ALNetworking * (^)(ALNetworkRequestMethod metohd))method;

/** Request an url with prefix */
- (ALNetworking * (^)(NSString *url))url;

/** Request an url without prefix */
- (ALNetworking * (^)(NSString *url))url_x;

/** Request Header  */
- (ALNetworking * (^)(NSDictionary *header))header;

/** Cache Strategy */
- (ALNetworking * (^)(ALCacheStrategy strategy))cacheStrategy;

/** Reqeust params */
- (ALNetworking * (^)(NSDictionary *params))params;

/** Request method */
- (ALNetworking * (^)(ALNetworkRequestParamsType requestType))paramsType;

/** Send Resquest */
- (RACSignal *(^)())executeSignal;

/** Empty the history */
- (void)clearHistories;

/** Configure Message */
@property (nonatomic, strong) ALNetworkingConfig *config;

/** When the server callback the error code and network exceptions, it will send value, you can subscribe it on viewController */
@property (nonatomic, strong, readonly) RACSubject *errors;

/** Request histories */
@property (nonatomic, strong, readonly) NSMutableArray *requestHistories;

@end
