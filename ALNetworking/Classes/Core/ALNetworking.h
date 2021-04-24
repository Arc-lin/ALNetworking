//
//  ALNetworking.h
//  ALNetworking
//
//  Created by Arclin on 2018/4/21.
//

#import <Foundation/Foundation.h>
#import "ALNetworkingConst.h"
#import "ALNetworkResponse.h"
#import "ALNetworkRequest.h"

#import <AFNetworking/AFNetworking.h>

@interface ALNetworking : NSObject

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

#pragma mark - 请求配置

/**
 请求体
 */
@property (nonatomic, strong, readonly) ALNetworkRequest *request;

/** 接口前缀 */
@property (nonatomic, copy) NSString *prefixUrl;

/** 通用请求头 */
@property (nonatomic, copy) NSDictionary *defaultHeader;

/** 通用参数 */
@property (nonatomic, copy) NSDictionary *defaultParams;

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
