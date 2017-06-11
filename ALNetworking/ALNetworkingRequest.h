//
//  ALNetworkingRequest.h
//  ALNetworkingDemo
//
//  Created by Arclin on 2017/6/3.
//  Copyright © 2017年 arclin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ALNetworkingConst.h"

@interface ALNetworkingRequest : NSObject

/** 请求地址 */
@property (nonatomic, copy)   NSString                    *urlStr;

/** 请求参数 */
@property (nonatomic, strong) NSDictionary                *params;

/** 请求头 */
@property (nonatomic, strong) NSDictionary                *header;

/** 请求Task */
@property (nonatomic, strong) NSURLSessionDataTask        *task;

/** 缓存策略 默认ALCacheStrategy_NETWORK_ONLY */
@property (nonatomic, assign) ALCacheStrategy              cacheStrategy;

/** 请求方式 */
@property (nonatomic, assign) ALNetworkRequestMethod       method;

/** 请求体类型 默认二进制形式 */
@property (nonatomic, assign) ALNetworkRequestParamsType   paramsType;

/** 忽视自定义响应类 */
@property (nonatomic, assign) BOOL                          ignoreCustomResponseClass;



#pragma mark - 方便输出直观的请求状况的成员属性

/** 请求方式(String) */
@property (nonatomic, copy) NSString                       *methodStr;

/** 缓存策略(String) */
@property (nonatomic, copy) NSString                       *strategyStr;

/** 请求体类型(String) */
@property (nonatomic, copy) NSString                       *paramsTypeStr;

@end
