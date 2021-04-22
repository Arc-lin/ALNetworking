//
//  ALNetworkRequest.h
//  ALNetworking
//
//  Created by Arclin on 2018/4/21.
//

#import <Foundation/Foundation.h>
#import "ALNetworkingConst.h"

@class AFHTTPRequestSerializer,AFHTTPResponseSerializer;

@interface ALNetworkRequest : NSObject<NSCopying>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithBaseUrl:(NSString *)baseUrl defaultHeader:(NSDictionary *)defaultHeader defaultParams:(NSDictionary *)defaultParams cacheStrategy:(ALCacheStrategy)strategy;

/// 请求路径
- (ALNetworkRequest *(^)(NSString *))url;

/// 请求头部
- (ALNetworkRequest * (^)(NSDictionary *header))header;

/// 请求参数
- (ALNetworkRequest * (^)(NSDictionary *params))params;

/// 请求方式
- (ALNetworkRequest *(^)(ALNetworkRequestMethod))method;

/// 响应体类型
- (ALNetworkRequest *(^)(ALNetworkResponseType))responseType;

/// 缓存策略
- (ALNetworkRequest * (^)(ALCacheStrategy strategy))cacheStrategy;

/// 最短的重复请求时间间隔
- (ALNetworkRequest * (^)(float timeInterval))minRepeatInterval;

/// 最短的重复请求时间 带上条件，如果true的时候，则忽略该时间间隔
- (ALNetworkRequest * (^)(float timeInterval,BOOL forceRequest))minRepeatIntervalInCondition;

/// 添加假数据，当on为true的时候启用，不发送网络请求 上传接口无效
- (ALNetworkRequest * (^)(id data,BOOL on))mockData;

/// 参数类型
- (ALNetworkRequest * (^)(ALNetworkRequestParamsType paramsType))paramsType;

/// 上传数据
- (ALNetworkRequest * (^)(NSData *data,NSString *fileName,NSString *mimeType))uploadData;

/// 上传文件承载的字段名
- (ALNetworkRequest * (^)(NSString *))fileFieldName;

/** 上传文件时，请在适当的地方调用这个方法，清理掉一些旧数据 **/
- (ALNetworkRequest *)prepareForUpload;

/** 文件上传/下载进度 */
- (ALNetworkRequest * (^)(void(^handleProgress)(float progress)))progress;

/**
 请求的唯一标识符
 */
- (ALNetworkRequest * (^)(NSString *name))name;

/**
 本次请求不启用动态参数，同时忽略的还有Config中的dynamicHandleRequest配置
 */
- (ALNetworkRequest *)disableDynamicParams;

/**
 本次请求不启用动态请求头，同时忽略的还有Config中的dynamicHandleRequest配置
 */
- (ALNetworkRequest *)disableDynamicHeader;

/// 下载目的路径
- (ALNetworkRequest *(^)(NSString *destPath))downloadDestPath;

/** 获取当前的请求方式(字符串) ***/
@property (nonatomic, copy, readonly)NSString *methodStr;

@end
