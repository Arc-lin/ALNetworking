//
//  ALNetworkingConst.h
//
//  Created by Arclin on 2018/4/21.
//

#import "NSDictionary+ALNetworking.h"

#ifndef ALNetworkingConst_h
#define ALNetworkingConst_h

#define get(urlStr) url(urlStr).method(ALNetworkRequestMethodGET)
#define post(urlStr) url(urlStr).method(ALNetworkRequestMethodPOST)
#define put(urlStr) url(urlStr).method(ALNetworkRequestMethodPUT)
#define patch(urlStr) url(urlStr).method(ALNetworkRequestMethodPATCH)
#define delete(urlStr) url(urlStr).method(ALNetworkRequestMethodDELETE)

#define GET(urlStr,...)       url(urlStr).method(ALNetworkRequestMethodGET).params(ALDictionaryOfVariableBindings(__VA_ARGS__))
#define POST(urlStr,...)      url(urlStr).method(ALNetworkRequestMethodPOST).params(ALDictionaryOfVariableBindings(__VA_ARGS__))
#define PUT(urlStr,...)       url(urlStr).method(ALNetworkRequestMethodPUT).params(ALDictionaryOfVariableBindings(__VA_ARGS__))
#define DELETE(urlStr,...)    url(urlStr).method(ALNetworkRequestMethodDELETE).params(ALDictionaryOfVariableBindings(__VA_ARGS__))
#define PATCH(urlStr,...)     url(urlStr).method(ALNetworkRequestMethodPATCH).params(ALDictionaryOfVariableBindings(__VA_ARGS__))

#define kNoCacheErrorCode -10992

#define KERROR(errCode,description) [NSError errorWithDomain:@"linghit.com" code:errCode userInfo:@{NSLocalizedDescriptionKey:description}]

/// 监听网络状态的通知
static NSString *kALNetworking_NetworkStatus = @"kALNetworking_NetworkStatus";

typedef NS_ENUM(NSInteger, ALCacheStrategy) {
    ALCacheStrategyNetworkOnly, // 只网络
    ALCacheStrategyCacheOnly, // 只取缓存，无缓存的时候会请求网络（比如第一次请求时）
    ALCacheStrategyCacheThenNetwork, // 先缓存后网络，回调执行两次
    ALCacheStrategyAutomatic, // 自动判断网络状况，有则网络，无则缓存
    ALCacheStrategyCacheAndNetwork, // 先缓存后网络，回调执行一次，网络请求后不回调。因为第一次请求时无缓存，所以使用会回调的网络数据
    ALCacheStrategyMemoryCache, // 使用内存缓存，重启App后会清空，第一次由于第一次没数据所以会走网络
};

typedef NS_ENUM(NSInteger, ALNetworkRequestMethod) {
    ALNetworkRequestMethodGET                  = 0,
    ALNetworkRequestMethodPOST,
    ALNetworkRequestMethodPUT,
    ALNetworkRequestMethodPATCH,
    ALNetworkRequestMethodDELETE,
};

/**
 网络状态

 - ALNetworkReachabilityStatusUnknown: 位置
 - ALNetworkReachabilityStatusNotReachable: 网络不可用
 - ALNetworkReachabilityStatusReachableViaWWAN: 数据网络
 - ALNetworkReachabilityStatusReachableViaWiFi: Wifi
 */
typedef NS_ENUM(NSInteger, ALNetworkReachabilityStatus) {
    ALNetworkReachabilityStatusUnknown          = -1,
    ALNetworkReachabilityStatusNotReachable     = 0,
    ALNetworkReachabilityStatusReachableViaWWAN = 1,
    ALNetworkReachabilityStatusReachableViaWiFi = 2,
};

/**
 参数传输类型

 - ALNetworkRequestParamsTypeDictionary: 二进制
 - ALNetworkRequestParamsTypeJSON: JSON
 */
typedef NS_ENUM(NSInteger, ALNetworkRequestParamsType) {
    ALNetworkRequestParamsTypeDictionary        = 0,
    ALNetworkRequestParamsTypeJSON
};

typedef NS_ENUM(NSInteger, ALNetworkResponseType) {
    ALNetworkResponseTypeJSON = 0,
    ALNetworkResponseTypeHTTP,
    ALNetworkResponseTypeXML,
    ALNetworkResponseTypeImage,
    ALNetworkResponseTypePlist,
    ALNetworkResponseTypeAnyThing,
};

/**
 公用参数请求方式

 - ALNetworkingCommonParamsMethodFollowMethod: 随接口请求方法
 - ALNetworkingCommonParamsMethodQS: 用query string方式拼接在URL后面
 */
typedef NS_ENUM(NSInteger, ALNetworkingCommonParamsMethod) {
    ALNetworkingCommonParamsMethodFollowMethod,
    ALNetworkingCommonParamsMethodQS,
};

/// 请求配置的位置
typedef NS_ENUM(NSInteger, ALNetworkingConfigType) {
    /// 全局配置和私有配置
    ALNetworkingConfigTypeAll = 1,
    /// 全局配置
    ALNetworkingConfigTypePublic,
    /// 私有配置
    ALNetworkingConfigTypePrivate,
};

#endif /* ALNetworkingConst_h */
