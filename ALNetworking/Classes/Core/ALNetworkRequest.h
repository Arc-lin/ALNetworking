//
//  ALNetworkRequest.h
//  BaZiPaiPanSDK
//
//  Created by Arclin on 2018/4/21.
//

#import <Foundation/Foundation.h>
#import "ALNetworkingConst.h"

@class AFHTTPRequestSerializer,AFHTTPResponseSerializer;

@interface ALNetworkRequest : NSObject<NSCopying>

/** 请求地址 */
@property (nonatomic, copy)   NSString                    *urlStr;

/** 请求参数 */
@property (nonatomic, strong) NSMutableDictionary         *params;

/** 请求头 */
@property (nonatomic, strong) NSMutableDictionary         *header;

/** 请求Task 当启用假数据返回的时候为空 */
@property (nonatomic, strong) NSURLSessionDataTask        *task;

/** 下载Task */
@property (nonatomic, strong) NSURLSessionDownloadTask    *downloadTask;

/** 缓存策略 默认ALCacheStrategyNetworkOnly */
@property (nonatomic, assign) ALCacheStrategy             cacheStrategy;

/** 请求方式 */
@property (nonatomic, assign) ALNetworkRequestMethod       method;

/** 获取当前的请求方式(字符串) ***/
@property (nonatomic, copy, readonly)      NSString       *methodStr;

/** 请求体类型 默认二进制形式 */
@property (nonatomic, assign) ALNetworkRequestParamsType   paramsType;

/** 响应体体类型 默认JSON形式 */
@property (nonatomic, assign) ALNetworkResponseType        responseType;

/** 禁止了动态参数 */
@property (nonatomic, assign) BOOL disableDynamicParams;

/** 禁止了动态请求头 */
@property (nonatomic, assign) BOOL disableDynamicHeader;

/** 处理AF请求体: 特殊情况下需要修改时使用 一般可以不用 */
@property (nonatomic, copy) AFHTTPRequestSerializer *(^requestSerializerBlock)(AFHTTPRequestSerializer *);

/** 处理AF响应体: 特殊情况下需要修改时使用 一般可以不用 */
@property (nonatomic, copy) AFHTTPResponseSerializer *(^responseSerializerBlock)(AFHTTPResponseSerializer *);

/** 唯一标识符 */
@property (nonatomic, copy) NSString *name;

/** SSL证书 */
@property (nonatomic, copy) NSString *sslCerPath;

/** 文件名 */
@property (nonatomic, strong) NSMutableArray<NSString *> *fileName;

/** 请求上传文件的字段名 */
@property (nonatomic, copy) NSString *fileFieldName;

/** 上传的数据 */
@property (nonatomic, strong) NSMutableArray<NSData *> *data;

/** 文件类型 */
@property (nonatomic, strong) NSMutableArray<NSString *> *mimeType;

/** 上传/下载进度 */
@property (nonatomic, copy) void(^progressBlock)(float progress);

/** 是否需要清理缓存 */
@property (nonatomic, assign) BOOL clearCache;

/** 忽略最短请求间隔 强制发出请求 */
@property (nonatomic, assign, getter=isForce) BOOL force;

/** 最短重复请求时间 */
@property (nonatomic, assign) float repeatRequestInterval;

/** 自定义属性 */
@property (nonatomic, strong) NSMutableDictionary<NSString *,id<NSCopying>> *customProperty;

/** 假数据 */
@property (nonatomic, strong) id<NSCopying> mockData;

/** 下载路径 */
@property (nonatomic, copy) NSString *destPath;

/** 起始时间 */
@property (nonatomic, assign) NSTimeInterval startTimeInterval;

@end
