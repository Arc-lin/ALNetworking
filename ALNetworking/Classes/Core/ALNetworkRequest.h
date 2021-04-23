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

- (instancetype)initWithBaseUrl:(NSString *)baseUrl defaultHeader:(NSDictionary *)defaultHeader defaultParams:(NSDictionary *)defaultParams defaultCacheStrategy:(ALCacheStrategy)strategy;

#pragma mark - 链式调用方法

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
- (ALNetworkRequest * (^)(ALNetworkingConfigType configType))disableDynamicParams;

/**
 本次请求不启用动态请求头，同时忽略的还有Config中的dynamicHandleRequest配置
 */
- (ALNetworkRequest * (^)(ALNetworkingConfigType configType))disableDynamicHeader;

/// 下载目的路径
- (ALNetworkRequest *(^)(NSString *destPath))downloadDestPath;

#pragma mark - 外部获取数据

/** 获取当前的请求方式(字符串) ***/
@property (nonatomic, copy, readonly) NSString *methodStr;

/** 请求地址 */
@property (nonatomic, copy)   NSString                    *req_urlStr;

/** 请求参数 */
@property (nonatomic, strong, readonly) NSMutableDictionary         *req_params;
@property (nonatomic, strong, readonly) NSDictionary                *req_inputParams;

/** 请求头 */
@property (nonatomic, strong, readonly) NSMutableDictionary         *req_header;
@property (nonatomic, strong, readonly) NSDictionary                *req_inputHeader;

/** 请求Task 当启用假数据返回的时候为空 */
@property (nonatomic, strong, readonly) NSURLSessionDataTask        *req_requestTask;

/** 下载Task */
@property (nonatomic, strong, readonly) NSURLSessionDownloadTask    *req_downloadTask;

/** 缓存策略 默认ALCacheStrategyNetworkOnly */
@property (nonatomic, assign, readonly) ALCacheStrategy              req_cacheStrategy;

/** 请求体类型 默认二进制形式 */
@property (nonatomic, assign, readonly) ALNetworkRequestParamsType   req_paramsType;

/** 响应体体类型 默认JSON形式 */
@property (nonatomic, assign, readonly) ALNetworkResponseType        req_responseType;

/** 禁止了动态参数 */
@property (nonatomic, assign, readonly) ALNetworkingConfigType       req_disableDynamicParams;

/** 禁止了动态请求头 */
@property (nonatomic, assign, readonly) ALNetworkingConfigType       req_disableDynamicHeader;

/** 唯一标识符 */
@property (nonatomic, copy, readonly) NSString                       *req_name;

/** 起始时间 */
@property (nonatomic, assign) NSTimeInterval                         req_startTimeInterval;

/** 忽略最短请求间隔 强制发出请求 */
@property (nonatomic, assign, getter=isForce, readonly) BOOL         req_force;

/** 最短重复请求时间 */
@property (nonatomic, assign, readonly) float                        req_repeatRequestInterval;

/** 自定义属性 */
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *,id<NSCopying>> *req_customProperty;

/** 假数据 */
@property (nonatomic, strong, readonly) id<NSCopying>                req_mockData;

/** SSL证书 */
@property (nonatomic, copy, readonly) NSString                       *req_sslCerPath;

/** 文件名 */
@property (nonatomic, strong, readonly) NSMutableArray<NSString *>   *req_fileName;

/** 请求上传文件的字段名 */
@property (nonatomic, copy, readonly) NSString                       *req_fileFieldName;

/** 上传的数据 */
@property (nonatomic, strong, readonly) NSMutableArray<NSData *>     *req_data;

/** 文件类型 */
@property (nonatomic, strong, readonly) NSMutableArray<NSString *>   *req_mimeType;

/** 下载路径 */
@property (nonatomic, copy, readonly) NSString                      *req_destPath;

/** 上传/下载进度 */
@property (nonatomic, copy, readonly) void(^req_progressBlock)(float progress);


@end