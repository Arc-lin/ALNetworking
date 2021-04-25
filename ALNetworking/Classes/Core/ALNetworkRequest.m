//
//  ALNetworkRequest.m
//  ALNetworking
//
//  Created by Arclin on 2018/4/21.
//

#import "ALNetworkRequest.h"
#import "ALBaseNetworking.h"
#import "ALNetworkResponse.h"

@interface ALNetworkRequest()

/** 请求地址前缀 */
@property (nonatomic, copy)   NSString                    *baseUrl;

/** 请求参数 */
@property (nonatomic, strong) NSDictionary                *req_inputParams;

/** 请求头 */
@property (nonatomic, strong) NSDictionary                *req_inputHeader;

/** 缓存策略 默认ALCacheStrategyNetworkOnly */
@property (nonatomic, assign) ALCacheStrategy              req_cacheStrategy;

/** 请求方式 */
@property (nonatomic, assign) ALNetworkRequestMethod       req_method;

/** 请求体类型 默认二进制形式 */
@property (nonatomic, assign) ALNetworkRequestParamsType   req_paramsType;

/** 响应体体类型 默认JSON形式 */
@property (nonatomic, assign) ALNetworkResponseType        req_responseType;

/** 禁止了动态参数 */
@property (nonatomic, assign) ALNetworkingConfigType       req_disableDynamicParams;

/** 禁止了动态请求头 */
@property (nonatomic, assign) ALNetworkingConfigType       req_disableDynamicHeader;

/** 唯一标识符 */
@property (nonatomic, copy) NSString                       *req_name;

/** 忽略最短请求间隔 强制发出请求 */
@property (nonatomic, assign, getter=isForce) BOOL         req_force;

/** 最短重复请求时间 */
@property (nonatomic, assign) float                        req_repeatRequestInterval;

/** 自定义属性 */
@property (nonatomic, strong) NSMutableDictionary<NSString *,id<NSCopying>> *req_customProperty;

/** 假数据 */
@property (nonatomic, strong) id<NSCopying>               req_mockData;

/** SSL证书 */
@property (nonatomic, copy) NSString                       *req_sslCerPath;

/** 文件名 */
@property (nonatomic, strong) NSMutableArray<NSString *>   *req_fileName;

/** 请求上传文件的字段名 */
@property (nonatomic, copy) NSString                       *req_fileFieldName;

/** 上传的数据 */
@property (nonatomic, strong) NSMutableArray<NSData *>     *req_data;

/** 文件类型 */
@property (nonatomic, strong) NSMutableArray<NSString *>   *req_mimeType;

/** 下载路径 */
@property (nonatomic, copy) NSString                      *req_destPath;

/** 上传/下载进度 */
@property (nonatomic, copy) void(^req_progressBlock)(float progress);

@end

@implementation ALNetworkRequest

- (instancetype)initWithBaseUrl:(NSString *)baseUrl defaultHeader:(NSDictionary *)defaultHeader defaultParams:(NSDictionary *)defaultParams defaultCacheStrategy:(ALCacheStrategy)strategy {
    if (self = [super init]) {
        self.baseUrl = [baseUrl copy];
        if (defaultHeader) {
            self.req_header = [defaultHeader mutableCopy];
        } else {
            self.req_header = [NSMutableDictionary dictionary];
        }
        if (defaultParams) {
            self.req_params = [defaultParams mutableCopy];
        } else {
            self.req_params = [NSMutableDictionary dictionary];
        }
        self.req_cacheStrategy = strategy;
        /// 给一个默认的唯一标识符
        self.req_name = [NSUUID UUID].UUIDString;
        self.req_disableDynamicParams = 0;
        self.req_disableDynamicHeader = 0;
    }
    return self;
}

#pragma mark - Chaining

- (ALNetworkRequest *(^)(NSString *))url {
    return ^ALNetworkRequest *(NSString *url) {
        NSString *urlStr;
        
        NSString *utf8Url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

        if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
            self.req_urlStr = utf8Url;
            return self;
        }
        
        // 优先自己的前缀
        NSString *prefix = self.baseUrl;
        if (!prefix || prefix.length == 0) {
            self.req_urlStr = utf8Url;
            return self;
        }
        
        // 处理重复斜杠的问题
        NSString *removeSlash;
        if(prefix.length > 0 && utf8Url.length > 0) {
            NSString *lastCharInPrefix = [prefix substringFromIndex:prefix.length - 1];
            NSString *firstCharInUrl = [utf8Url substringToIndex:1];
            if ([lastCharInPrefix isEqualToString:@"/"] &&
                [firstCharInUrl isEqualToString:@"/"]) {
                removeSlash = [prefix substringToIndex:prefix.length - 1];
            }
        }
        if (removeSlash) {
            prefix = removeSlash;
        }
        
        urlStr = [NSString stringWithFormat:@"%@%@",prefix,utf8Url];
        
        self.req_urlStr = urlStr;
        
        return self;
    };
}

- (ALNetworkRequest * (^)(NSDictionary *header))header {
    return ^ALNetworkRequest *(NSDictionary *header) {
        self.req_inputHeader = header;
        [self.req_header setValuesForKeysWithDictionary:header];
        return self;
    };
}

- (ALNetworkRequest * (^)(NSDictionary *params))params {
    return ^ALNetworkRequest *(NSDictionary *params) {
        self.req_inputParams = params;
        NSMutableDictionary *reqParams = [NSMutableDictionary dictionaryWithDictionary:params];
        [self.req_params setValuesForKeysWithDictionary:reqParams];
        return self;
    };
}

- (ALNetworkRequest *(^)(ALNetworkRequestMethod))method {
    return ^ALNetworkRequest *(ALNetworkRequestMethod method) {
        self.req_method = method;
        return self;
    };
}

- (ALNetworkRequest *(^)(ALNetworkResponseType))responseType {
    return ^ALNetworkRequest *(ALNetworkResponseType type) {
        self.req_responseType = type;
        return self;
    };
}

- (ALNetworkRequest * (^)(ALCacheStrategy strategy))cacheStrategy {
    return ^ALNetworkRequest *(ALCacheStrategy strategy) {
        self.req_cacheStrategy = strategy;
        return self;
    };
}

- (ALNetworkRequest * (^)(ALNetworkRequestParamsType paramsType))paramsType {
    return ^ALNetworkRequest *(ALNetworkRequestParamsType paramsType) {
        self.req_paramsType = paramsType;
        return self;
    };
}

- (ALNetworkRequest *(^)(NSString *))name {
    return ^ALNetworkRequest *(NSString *name) {
        self.req_name = name;
        return self;
    };
}

#pragma mark - 调试、伪数据

- (ALNetworkRequest *(^)(id, BOOL))mockData
{
    return ^ALNetworkRequest *(id data,BOOL on) {
        if (on) {
            self.req_mockData = [data copy];
        }
        return self;
    };
}

#pragma mark - 下载

- (ALNetworkRequest *(^)(NSString *))downloadDestPath
{
    return ^ALNetworkRequest *(NSString *destPath) {
        self.req_destPath = destPath;
        return self;
    };
}

#pragma mark - 上传

- (ALNetworkRequest *(^)(NSData *,  NSString *, NSString *))uploadData
{
    return ^ALNetworkRequest *(NSData *data,NSString *fileName,NSString *mimeType) {
        NSAssert(data, @"data不能为空");
        NSAssert(fileName && fileName.length > 0, @"fileName不能为空");
        NSAssert(mimeType && mimeType.length > 0, @"mimeType不能为空");
        [self.req_data addObject:data];
        [self.req_fileName addObject:fileName];
        [self.req_mimeType addObject:mimeType];
        return self;
    };
}

- (ALNetworkRequest *(^)(NSString *))fileFieldName
{
    return ^ALNetworkRequest *(NSString *fileField) {
        self.req_fileFieldName = fileField;
        return self;
    };
}

- (ALNetworkRequest *(^)(void (^)(float)))progress
{
    return ^ALNetworkRequest *(void(^progressBlock)(float progress)) {
        self.req_progressBlock = progressBlock;
        return self;
    };
}

- (ALNetworkRequest *(^)(ALNetworkingConfigType configType))disableDynamicParams
{
    return ^ALNetworkRequest *(ALNetworkingConfigType configType) {
        self.req_disableDynamicParams = configType;
        return self;
    };
}

- (ALNetworkRequest *(^)(ALNetworkingConfigType configType))disableDynamicHeader
{
    return ^ALNetworkRequest *(ALNetworkingConfigType configType) {
        self.req_disableDynamicHeader = configType;
        return self;
    };
}

- (ALNetworkRequest *(^)(float))minRepeatInterval
{
    return ^ALNetworkRequest *(float repeatInterval) {
        self.req_repeatRequestInterval = repeatInterval;
        return self;
    };
}

- (ALNetworkRequest *(^)(float, BOOL))minRepeatIntervalInCondition
{
    return ^ALNetworkRequest *(float repeatInterval,BOOL forceRequest) {
        self.req_repeatRequestInterval = repeatInterval;
        self.req_force = forceRequest;
        return self;
    };
}

#pragma mark - 执行请求

#ifdef RAC

- (RACSignal<RACTuple *> *)executeSignal {
    
    ALNetworkRequest *request = self;
    
    if (self.handleRequest) {
        request = self.handleRequest(self);
        if (!request) {
            request = nil;
            return [RACSignal empty];
        }
    }

    @weakify(self);
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self);

        /// 记录请求起始时间，以订阅的时候开始算起
        request.req_startTimeInterval = [[NSDate date] timeIntervalSince1970];

        request.req_requestTask = [ALBaseNetworking requestWithRequest:request mockData:request.req_mockData success:^(ALNetworkResponse *response, ALNetworkRequest *req) {
            
            if (self.handleResponse) {
                NSError *error = self.handleResponse(response,req);
                if (!error) {
                    [subscriber sendNext:RACTuplePack(response,req)];
                }
                if (req.req_cacheStrategy == ALCacheStrategyCacheThenNetwork) {
                    if (!response.isCache) { // 如果是缓存模式，则不发送sendError和sendComplete
                        if (error) {
                            [subscriber sendError:error];
                        } else {
                            [subscriber sendCompleted];
                        }
                    }
                } else {
                    if (!error) {
                        [subscriber sendCompleted];
                    } else {
                        [subscriber sendError:error];
                    }
                }
            } else {
                [subscriber sendNext:RACTuplePack(response,req)];
                if (req.req_cacheStrategy == ALCacheStrategyCacheThenNetwork) {
                    if (!response.isCache) {
                        [subscriber sendCompleted];
                    }
                } else {
                    [subscriber sendCompleted];
                }
            }
        } failure:^(ALNetworkRequest *request, BOOL isCache,id responseObject,NSError *error) {
            @strongify(self);
            ALNetworkResponse *response = [[ALNetworkResponse alloc] init];
            if ([self handleError:request response:response isCache:isCache error:error]) {
                // 处理一下错误
                response.rawData = responseObject;
                NSError *error;
                if (self.handleError) {
                   error = self.handleError(request, response, error);
                }
                [subscriber sendError:error];
            }
            
        }];
        return nil;
    }];
    
    request = nil;
    
    return signal;
}


- (RACSignal *)executeDownloadSignal
{
    ALNetworkRequest *request = self;
    
    if (self.handleRequest) {
        request = self.handleRequest(self);
        if (!request) {
            return [RACSignal empty];
        }
    }
    
    @weakify(self);
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        @strongify(self);
        
        /// 记录请求起始时间，以订阅的时候开始算起
        request.req_startTimeInterval = [[NSDate date] timeIntervalSince1970];

        request.req_downloadTask = [ALBaseNetworking downloadWithRequest:request progress:^(float progress) {
            if (request.req_progressBlock) {
                request.req_progressBlock(progress);
            }
        } success:^(ALNetworkResponse *response, ALNetworkRequest *request) {
            if (self.handleResponse) {
                NSError *error = self.handleResponse(response,request);
                if(!error) {
                    [subscriber sendNext:response.rawData[@"path"]?:@""];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:error];
                }
            } else {
                [subscriber sendNext:response.rawData[@"path"]?:@""];
                [subscriber sendCompleted];
            }
        } failure:^(ALNetworkRequest *request, BOOL isCache, NSError *error) {
            if([self handleError:request response:nil isCache:isCache error:error]) {
                if (self.handleError) {
                   error = self.handleError(request, nil, error);
                }
                [subscriber sendError:error];
            }
        }];
        
        return nil;
    }];
    
    return signal;
}

#endif

#pragma mark - private method

/// 判断当前事件是不是要认为是一个错误
- (BOOL)handleError:(ALNetworkRequest *)request response:(ALNetworkResponse *)response isCache:(BOOL)isCache error:(NSError *)error
{
    if (error.code == kNoCacheErrorCode && request.req_cacheStrategy != ALCacheStrategyCacheOnly) { // 无缓存不回调，除非是纯缓存模式
        return NO;
    }
    if (error.code == NSURLErrorCancelled) {
        return NO;
    }
    
    return YES;
}

- (void)setExecuteRequest:(void (^)(ALNetworkResponse *, ALNetworkRequest *, NSError *))executeRequest {
    _executeRequest = executeRequest;
    
    if (!executeRequest) {
        return;
    }
    
    ALNetworkRequest *request = self;
    
    if (self.handleRequest) {
        request = self.handleRequest(self);
        if (!request) {
            return;
        }
    }
    
    // AF内部解开self的循环引用，所以不用弱引用
    request.req_requestTask = [ALBaseNetworking requestWithRequest:request mockData:request.req_mockData success:^(ALNetworkResponse *response, ALNetworkRequest *req) {
        
        if (self.handleResponse) {
            NSError *error = self.handleResponse(response,req);
            if(!error) {
                executeRequest(response,req,nil);
            } else {
                executeRequest(nil,req,error);
            }
        } else {
            executeRequest(response,req,nil);
        }
    } failure:^(ALNetworkRequest *req, BOOL isCache,id responseObject, NSError *error) {
        ALNetworkResponse *resp = [[ALNetworkResponse alloc] init];
        if ([self handleError:req response:resp isCache:isCache error:error]) {
            resp.rawData = responseObject;
            NSError *error;
            // 处理一下错误
            if (self.handleError) {
                error = self.handleError(req,resp,error);
            }
            executeRequest(resp,req,error);
        }
    }];
}

- (void)setExecuteUploadRequest:(void (^)(ALNetworkResponse *, ALNetworkRequest *, NSError *))executeUploadRequest
{
    _executeUploadRequest = executeUploadRequest;
    
    if (!executeUploadRequest) {
        return;
    }
    
    ALNetworkRequest *request = self;
    
    if (self.handleRequest) {
        request = self.handleRequest(request);
        if (!request) {
            return;
        }
    }
    
    request.req_requestTask = [ALBaseNetworking uploadWithRequest:request progress:^(float progress) {
        if (request.req_progressBlock) {
            request.req_progressBlock(progress);
        }
    } success:^(ALNetworkResponse *response, ALNetworkRequest *request) {
        
        if (self.handleResponse) {
            NSError *error = self.handleResponse(response,request);
            if(!error) {
                executeUploadRequest(response,request,nil);
            } else {
                executeUploadRequest(nil,request,error);
            }
        } else {
            executeUploadRequest(response,request,nil);
        }
    } failure:^(ALNetworkRequest *request, BOOL isCache, NSError *error) {
        
        if ([self handleError:request response:nil isCache:isCache error:error]) {
            NSError *error;
            // 处理一下错误
            if (self.handleError) {
                error = self.handleError(request,nil,error);
            }
            executeUploadRequest(nil,request,error);
        }
    }];
}

- (id)copyWithZone:(NSZone *)zone {
    ALNetworkRequest *request = [[ALNetworkRequest alloc] init];
    request.req_urlStr = self.req_urlStr;
    request.req_params = self.req_params;
    request.req_header = self.req_header;
    request.req_requestTask = self.req_requestTask;
    request.req_cacheStrategy = self.req_cacheStrategy;
    request.req_method = self.req_method;
    request.req_paramsType = self.req_paramsType;
    request.req_name = self.req_name;
    request.req_sslCerPath = self.req_sslCerPath;
    request.req_responseType = self.req_responseType;
    request.req_fileName = self.req_fileName;
    request.req_fileFieldName = self.req_fileFieldName;
    request.req_mimeType = self.req_mimeType;
    request.req_progressBlock = self.req_progressBlock;
    request.req_data = self.req_data;
    request.req_disableDynamicParams = self.req_disableDynamicParams;
    request.req_disableDynamicHeader = self.req_disableDynamicHeader;
    request.req_repeatRequestInterval = self.req_repeatRequestInterval;
    request.req_customProperty = self.req_customProperty;
    request.req_force = self.req_force;
    request.req_mockData = self.req_mockData;
    request.req_destPath = self.req_destPath;
    request.req_downloadTask = self.req_downloadTask;
    request.req_startTimeInterval = self.req_startTimeInterval;
    return request;
}

#pragma mark - setter & getter

- (NSString *)methodStr {
    switch (self.req_method) {
        case ALNetworkRequestMethodGET:
            return @"GET";
        case ALNetworkRequestMethodPOST:
            return @"POST";
        case ALNetworkRequestMethodDELETE:
            return @"DELETE";
        case ALNetworkRequestMethodPUT:
            return @"PUT";
        case ALNetworkRequestMethodPATCH:
            return @"PATCH";
        default:
            return @"GET";
            break;
    }
}

- (NSMutableArray<NSString *> *)req_fileName
{
    if (!_req_fileName) {
        _req_fileName = [NSMutableArray array];
    }
    return _req_fileName;
}

- (NSMutableArray<NSData *> *)req_data
{
    if (!_req_data) {
        _req_data = [NSMutableArray array];
    }
    return _req_data;
}

- (NSMutableArray<NSString *> *)req_mimeType
{
    if (!_req_mimeType) {
        _req_mimeType = [NSMutableArray array];
    }
    return _req_mimeType;
}

- (NSMutableDictionary<NSString *,id<NSCopying>> *)req_customProperty
{
    if (!_req_customProperty) {
        _req_customProperty = [NSMutableDictionary dictionary];
    }
    return _req_customProperty;
}

@end
