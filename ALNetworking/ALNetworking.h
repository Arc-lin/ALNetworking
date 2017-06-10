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

/** 单例 */
+ (instancetype)sharedInstance;

/** 监听网络状态 */
+ (void)networkStatus:(void(^)(ALNetworkReachabilityStatus networkStatus))statusBlock;

/** 请求方法 */
- (ALNetworking * (^)(ALNetworkRequestMethod metohd))method;

/** 带URL前缀（如果有的话）的url */
- (ALNetworking * (^)(NSString *url))url;

/** 不带前缀的url */
- (ALNetworking * (^)(NSString *url))url_x;

/** 请求头 */
- (ALNetworking * (^)(NSDictionary *header))header;

/** 请求策略 */
- (ALNetworking * (^)(ALCacheStrategy strategy))cacheStrategy;

/** 请求参数 */
- (ALNetworking * (^)(NSDictionary *params))params;

/** 请求方式 */
- (ALNetworking * (^)(ALNetworkRequestParamsType requestType))paramsType;

/** 发送请求 */
- (RACSignal *(^)())executeSignal;

/** 清空历史 */
- (void)clearHistories;

/** 配置信息 */
@property (nonatomic, strong) ALNetworkingConfig *config;

/** 异常状况(服务端返回非正确码和网络异常时回调) */
@property (nonatomic, strong, readonly) RACSubject *errors;

/** 请求历史 */
@property (nonatomic, strong, readonly) NSMutableArray *requestHistories;

@end
