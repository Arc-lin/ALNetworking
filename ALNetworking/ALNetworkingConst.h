//
//  ALNetworkingConst.h
//  ALNetworkingDemo
//
//  Created by Arclin on 2017/6/3.
//  Copyright © 2017年 arclin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALNetworkingConst : NSObject

/** Build parameters (NSDictionary) expediently */
#define paramsDic(...) params(NSDictionaryOfVariableBindings(__VA_ARGS__))

/** Build request expediently */

#define GET(urlStr)       url(urlStr).method(ALNetworkRequestMethodGET)
#define POST(urlStr)      url(urlStr).method(ALNetworkRequestMethodPOST)
#define PUT(urlStr)       url(urlStr).method(ALNetworkRequestMethodPUT)
#define DELETE(urlStr)    url(urlStr).method(ALNetworkRequestMethodDELETE)
#define PATCH(urlStr)     url(urlStr).method(ALNetworkRequestMethodPATCH)

#define get(urlStr,...)       url(urlStr).method(ALNetworkRequestMethodGET).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define post(urlStr,...)      url(urlStr).method(ALNetworkRequestMethodPOST).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define put(urlStr,...)       url(urlStr).method(ALNetworkRequestMethodPUT).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define delete(urlStr,...)    url(urlStr).method(ALNetworkRequestMethodDELETE).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define patch(urlStr,...)     url(urlStr).method(ALNetworkRequestMethodPATCH).params(NSDictionaryOfVariableBindings(__VA_ARGS__))

/**
 Requst metohd
 
 - ALNetworkRequestMethodGET:                 GET
 - ALNetworkRequestMethodPOST:                POST
 - ALNetworkRequestMethodPUT:                 PUT
 - ALNetworkRequestMethodPATCH:               PATCH
 - ALNetworkRequestMethodDELETE:              DELETE
 */
typedef NS_ENUM(NSInteger, ALNetworkRequestMethod) {
    ALNetworkRequestMethodGET                  = 0,
    ALNetworkRequestMethodPOST,
    ALNetworkRequestMethodPUT,
    ALNetworkRequestMethodPATCH,
    ALNetworkRequestMethodDELETE,
};


/**
 Network Status
 
 - ALNetworkReachabilityStatusUnknown:          Unknow
 - ALNetworkReachabilityStatusNotReachable:     Network cannot be used
 - ALNetworkReachabilityStatusReachableViaWWAN: WLAN
 - ALNetworkReachabilityStatusReachableViaWiFi: WIFI
 */
typedef NS_ENUM(NSInteger, ALNetworkReachabilityStatus) {
    ALNetworkReachabilityStatusUnknown          = -1,
    ALNetworkReachabilityStatusNotReachable,
    ALNetworkReachabilityStatusReachableViaWWAN,
    ALNetworkReachabilityStatusReachableViaWiFi,
};

/**
 Request Type
 
 - ALNetworkRequestParamsTypeDictionary:      Dictionary(Binary)
 - ALNetworkRequestParamsTypeJSON:            JSON
 */
typedef NS_ENUM(NSInteger, ALNetworkRequestParamsType) {
    ALNetworkRequestParamsTypeDictionary        = 0,
    ALNetworkRequestParamsTypeJSON
};

/**
 Network Cache Strategy

 - ALCacheStrategy_NETWORK_ONLY:             只从网络取数据(不缓存)   Only from network
 - ALCacheStrategy_CACHE_ONLY:               只从本地取数据          Only from disk cache
 - ALCacheStrategy_NETWORK_AND_CACHE:        从网络取数据后缓存       Get from network then cache
 - ALCacheStrategy_CACHE_ELSE_NETWORK:       先取缓存,如果没有数据的话,才从网络取数据  Get from cache, if not exist,get from network
 - ALCacheStrategy_CACHE_THEN_NETWORK:       先取缓存,再加载网络数据,网络数据加载完会更新缓存,这个选择会有两次回调 （或者收到两个信号值) Get from cache,then network,this option will send data twice.
 - ALCacheStrategy_AUTOMATICALLY:            根据网络状况自动选择,先请求一遍网络,如果网络异常就返回本地缓存的内容 Request from network ,if exception,get from disk cache
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
