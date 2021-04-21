//
//  MMCNetworking.h
//  BaZiPaiPanSDK
//
//  Created by Arclin on 2018/4/21.
//

#import <Foundation/Foundation.h>
#import "ALNetworkingConst.h"
#import "ALNetworkResponse.h"
#import "ALNetworkRequest.h"

#import <AFNetworking/AFNetworking.h>

@interface ALNetworking : NSObject

- (ALNetworking * (^)(ALNetworkRequestMethod metohd))method;

- (ALNetworking * (^)(ALNetworkResponseType type))responseType;

- (ALNetworking * (^)(NSString *url))url;

- (ALNetworking * (^)(NSDictionary *header))header;

- (ALNetworking * (^)(ALCacheStrategy strategy))cacheStrategy;

- (ALNetworking * (^)(NSDictionary *params))params;

/// 最短的重复请求时间间隔
- (ALNetworking * (^)(float timeInterval))minRepeatInterval;

/// 最短的重复请求时间 带上条件，如果true的时候，则忽略该时间间隔
- (ALNetworking * (^)(float timeInterval,BOOL forceRequest))minRepeatIntervalInCondition;

/// 添加假数据，当on为true的时候启用，不发送网络请求 上传接口无效
- (ALNetworking * (^)(id data,BOOL on))mockData;

- (ALNetworking * (^)(ALNetworkRequestParamsType paramsType))paramsType;

- (ALNetworking * (^)(NSData *data,NSString *fileName,NSString *mimeType))uploadData;

- (ALNetworking * (^)(NSString *))fileFieldName;

/** 上传文件时，请在适当的地方调用这个方法，清理掉一些旧数据 **/
- (ALNetworking *)prepareForUpload;

/** 文件上传/下载进度 */
- (ALNetworking * (^)(void(^handleProgress)(float progress)))progress;

/**
 请求的唯一标识符
 */
- (ALNetworking * (^)(NSString *name))name;

/**
 本次请求不启用动态参数，同时忽略的还有Config中的dynamicHandleRequest配置
 */
- (ALNetworking *)disableDynamicParams;

/**
 本次请求不启用动态请求头，同时忽略的还有Config中的dynamicHandleRequest配置
 */
- (ALNetworking *)disableDynamicHeader;

/// 是否需要在请求前清除缓存
- (ALNetworking *(^)(BOOL remove))removeCache;

/// 下载目的路径
- (ALNetworking *(^)(NSString *destPath))downloadDestPath;

#ifdef RAC
- (RACSignal<RACTuple *> *)executeSignal;

- (RACSignal *)executeDownloadSignal;
#endif

/**
 取消当前所有请求
 */
- (void)cancelAllRequest;

/**
 取消请求
 */
- (void)cancelRequestWithName:(NSString *)name;

/**
 处理AF请求体,普通情况下无需调用,有特殊需求时才需要拦截AF的请求体进行修改
 */
- (void)handleRequestSerialization:(AFHTTPRequestSerializer *(^)(AFHTTPRequestSerializer *serializer))requestSerializerBlock;

/**
 处理AF响应体,普通情况下无需调用,有特殊需求时才需要拦截AF的响应体进行修改
 */
- (void)handleResponseSerialization:(AFHTTPResponseSerializer *(^)(AFHTTPResponseSerializer *serializer))responseSerializerBlock;

#pragma mark - 请求配置

/**
 请求体 : 必要情况下可以修改里面的属性
 */
@property (nonatomic, strong) ALNetworkRequest *request;

/** 接口前缀 */
@property (nonatomic, copy) NSString *prefixUrl;

/** 通用请求头 */
@property (nonatomic, copy) NSDictionary *commonHeader;

/** 通用参数 */
@property (nonatomic, copy) NSDictionary *commonParams;

/** 忽略Config中配置的默认请求头 */
@property (nonatomic, assign) BOOL ignoreDefaultHeader;

/** 忽略Config中配置的默认请求参数 */
@property (nonatomic, assign) BOOL ignoreDefaultParams;

/** 请求前拦截请求体处理 如果需要取消请求则返回空值 */
@property (nonatomic, copy) ALNetworkRequest *(^handleRequest)(ALNetworkRequest *request);

/**
 根据需求处理回调信息判断是否是正确的回调
 */
@property (nonatomic, copy) NSError *(^handleResponse)(ALNetworkResponse *response,ALNetworkRequest *request);

/**
 处理错误
 */
@property (nonatomic, copy) void(^handleError)(ALNetworkRequest *request,ALNetworkResponse *response,NSError *error);

/**
 执行请求
 */
@property (nonatomic, copy) void(^executeRequest)(ALNetworkResponse *response,ALNetworkRequest *request,NSError *error);

/**
 执行上传文件请求
 */
@property (nonatomic, copy) void(^executeUploadRequest)(ALNetworkResponse *response,ALNetworkRequest *request, NSError *error);

/** Config类中公用参数的传递方式 */
@property (nonatomic, assign) ALNetworkingCommonParamsMethod commonParamsMethod;

/** networking属性中公用参数的传递方式 */
@property (nonatomic, assign) ALNetworkingCommonParamsMethod defaultParamsMethod;

/**
 动态参数的配置，每次执行请求都会加上这次的参数
 */
@property (nonatomic, copy) NSDictionary *(^dynamicParamsConfig)(ALNetworkRequest *request);

/**
 动态请求头的配置，每次执行请求都会加上这次的请求头
 */
@property (nonatomic, copy) NSDictionary *(^dynamicHeaderConfig)(ALNetworkRequest *request);

/**
 当前网络状态
 */
@property (nonatomic, assign, readonly) AFNetworkReachabilityStatus networkStatus;

@end
