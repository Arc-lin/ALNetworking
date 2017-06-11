//
//  ALNetworkingConst.h
//  ALNetworkingDemo
//
//  Created by Arclin on 2017/6/3.
//  Copyright © 2017年 arclin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALNetworkingConst : NSObject

/** 便利构造请求参数(字典) */
#define paramsDic(...) params(NSDictionaryOfVariableBindings(__VA_ARGS__))

/** 构造简单的请求 */
/** 带自定义url前缀 */
#define get(urlStr,...)       url(urlStr).method(ALNetworkRequestMethodGET).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define post(urlStr,...)      url(urlStr).method(ALNetworkRequestMethodGET).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define put(urlStr,...)       url(urlStr).method(ALNetworkRequestMethodPUT).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define delete(urlStr,...)    url(urlStr).method(ALNetworkRequestMethodDELETE).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define patch(urlStr,...)     url(urlStr).method(ALNetworkRequestMethodPATCH).params(NSDictionaryOfVariableBindings(__VA_ARGS__))

/** 不带自定义url前缀 */
#define get_x(urlStr,...)     url_x(urlStr).method(ALNetworkRequestMethodGET).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define post_x(urlStr,...)    url_x(urlStr).method(ALNetworkRequestMethodGET).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define put_x(urlStr,...)     url_x(urlStr).method(ALNetworkRequestMethodPUT).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define delete_x(urlStr,...)  url_x(urlStr).method(ALNetworkRequestMethodDELETE).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define patch_x(urlStr,...)   url_x(urlStr).method(ALNetworkRequestMethodPATCH).params(NSDictionaryOfVariableBindings(__VA_ARGS__))

/**
 请求的方式
 
 - ALNetworkRequestMethodGET:                 GET请求
 - ALNetworkRequestMethodPOST:                POST请求
 - ALNetworkRequestMethodPUT:                 PUT请求
 - ALNetworkRequestMethodPATCH:               PATCH请求
 - ALNetworkRequestMethodDELETE:              DELETE请求
 */
typedef NS_ENUM(NSInteger, ALNetworkRequestMethod) {
    ALNetworkRequestMethodGET                  = 0,
    ALNetworkRequestMethodPOST,
    ALNetworkRequestMethodPUT,
    ALNetworkRequestMethodPATCH,
    ALNetworkRequestMethodDELETE,
};


/**
 网络状态
 
 - ALNetworkReachabilityStatusUnknown:          未知状态
 - ALNetworkReachabilityStatusNotReachable:     网络不可用
 - ALNetworkReachabilityStatusReachableViaWWAN: WLAN 网络
 - ALNetworkReachabilityStatusReachableViaWiFi: WIFI 网络
 */
typedef NS_ENUM(NSInteger, ALNetworkReachabilityStatus) {
    ALNetworkReachabilityStatusUnknown          = -1,
    ALNetworkReachabilityStatusNotReachable,
    ALNetworkReachabilityStatusReachableViaWWAN,
    ALNetworkReachabilityStatusReachableViaWiFi,
};

/**
 请求参数的类型
 
 - ALNetworkRequestParamsTypeDictionary:      以字典(二进制)方式请求 (默认)
 - ALNetworkRequestParamsTypeJSON:            以JSON方式请求
 */
typedef NS_ENUM(NSInteger, ALNetworkRequestParamsType) {
    ALNetworkRequestParamsTypeDictionary        = 0,
    ALNetworkRequestParamsTypeJSON
};

/**
 网络缓存策略

 - ALCacheStrategy_NETWORK_ONLY: 只从网络取数据(不缓存)
 - ALCacheStrategy_CACHE_ONLY: 只从本地取数据
 - ALCacheStrategy_NETWORK_AND_CACHE: 从网络取数据后缓存
 - ALCacheStrategy_CACHE_ELSE_NETWORK: 先取缓存,如果没有数据的话,才从网络取数据
 - ALCacheStrategy_CACHE_THEN_NETWORK: 先取缓存,再加载网络数据,网络数据加载完会更新缓存,这个选择会有两次回调 （或者收到两个信号值)
 - ALCacheStrategy_AUTOMATICALLY: 根据网络状况自动选择,先请求一遍网络,如果网络异常就返回本地缓存的内容
 */
typedef NS_ENUM(NSInteger,ALCacheStrategy) {
    ALCacheStrategy_NETWORK_ONLY            = 0,
    ALCacheStrategy_CACHE_ONLY,
    ALCacheStrategy_NETWORK_AND_CACHE,
    ALCacheStrategy_CACHE_ELSE_NETWORK,
    ALCacheStrategy_CACHE_THEN_NETWORK,
    ALCacheStrategy_AUTOMATICALLY
};

@end
