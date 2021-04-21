//
//  MMCNetworking.m
//  BaZiPaiPanSDK
//
//  Created by Arclin on 2018/4/21.
//

#import "ALNetworking.h"
#import "ALNetworkRequest.h"
#import "ALNetworkResponse.h"
#import "ALNetworkingConfig.h"
#import "ALBaseNetworking.h"
#import "ALNetworkCache.h"
#import <AFNetworking/AFNetworking.h>
#import "ALAPIClient.h"

@interface ALNetworking()

/**
 存储网络请求的字典
 */
@property (nonatomic, strong) NSMutableDictionary *requestDictionary;

/// 请求起始时间
@property (nonatomic, strong) NSMutableDictionary *requestTimeDictionary;

/** 保存一下手动传入的参数，保证他是最高优先级 */
@property (nonatomic, copy) NSDictionary *inputParams;

/** 保存一下手动传入的Header，保证他是最高优先级 */
@property (nonatomic, copy) NSDictionary *inputHeaders;

@end

@implementation ALNetworking

- (ALNetworking *(^)(ALNetworkRequestMethod))method {
    return ^ALNetworking *(ALNetworkRequestMethod method) {
        self.request.method = method;
        return self;
    };
}

- (ALNetworking *(^)(ALNetworkResponseType))responseType {
    return ^ALNetworking *(ALNetworkResponseType type) {
        self.request.responseType = type;
        return self;
    };
}

- (ALNetworking *(^)(NSString *))url {
    return ^ALNetworking *(NSString *url) {
        NSString *urlStr;
        
        NSString *utf8Url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

        if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
            self.request.urlStr = utf8Url;
            return self;
        }
                
        NSString *defaultPrefixUrl = [ALNetworkingConfig defaultConfig].defaultPrefixUrl;
        
        // 优先自己的前缀
        NSString *prefix = self.prefixUrl ?: defaultPrefixUrl;
        if (!prefix || prefix.length == 0) {
            self.request.urlStr = utf8Url;
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
        
        self.request.urlStr = urlStr;
        
        return self;
    };
}

- (ALNetworking *(^)(NSData *,  NSString *, NSString *))uploadData
{
    return ^ALNetworking *(NSData *data,NSString *fileName,NSString *mimeType) {
        NSAssert(data, @"data不能为空");
        NSAssert(fileName && fileName.length > 0, @"fileName不能为空");
        NSAssert(mimeType && mimeType.length > 0, @"mimeType不能为空");
        [self.request.data addObject:data];
        [self.request.fileName addObject:fileName];
        [self.request.mimeType addObject:mimeType];
        return self;
    };
}

- (ALNetworking *(^)(NSString *))fileFieldName
{
    return ^ALNetworking *(NSString *fileField) {
        self.request.fileFieldName = fileField;
        return self;
    };
}

- (ALNetworking *)prepareForUpload
{
    [self.request.data removeAllObjects];
    [self.request.fileName removeAllObjects];
    [self.request.mimeType removeAllObjects];
    return self;
}

- (ALNetworking * (^)(NSDictionary *header))header {
    return ^ALNetworking *(NSDictionary *header) {
        self.inputHeaders = header;
        [self.request.header setValuesForKeysWithDictionary:header];
        return self;
    };
}

- (ALNetworking * (^)(ALCacheStrategy strategy))cacheStrategy {
    return ^ALNetworking *(ALCacheStrategy strategy) {
        self.request.cacheStrategy = strategy;
        return self;
    };
}

- (ALNetworking * (^)(NSDictionary *params))params {
    return ^ALNetworking *(NSDictionary *params) {
        self.inputParams = params;
        NSMutableDictionary *reqParams = [NSMutableDictionary dictionaryWithDictionary:params];
        [self.request.params setValuesForKeysWithDictionary:reqParams];
        return self;
    };
}

- (ALNetworking * (^)(ALNetworkRequestParamsType paramsType))paramsType {
    return ^ALNetworking *(ALNetworkRequestParamsType paramsType) {
        self.request.paramsType = paramsType;
        return self;
    };
}

- (ALNetworking *(^)(void (^)(float)))progress
{
    return ^ALNetworking *(void(^progressBlock)(float progress)) {
        self.request.progressBlock = progressBlock;
        return self;
    };
}

- (ALNetworking *(^)(id, BOOL))mockData
{
    return ^ALNetworking *(id data,BOOL on) {
        if (on) {
            self.request.mockData = [data copy];
        }
        return self;
    };
}

- (ALNetworking *)disableDynamicParams
{
    self.request.disableDynamicParams = YES;
    return self;
}

- (ALNetworking *)disableDynamicHeader
{
    self.request.disableDynamicHeader = YES;
    return self;
}

- (ALNetworking *(^)(NSString *))name {
    return ^ALNetworking *(NSString *name) {
        self.request.name = name;
        return self;
    };
}

- (ALNetworking *(^)(BOOL))removeCache
{
    return ^ALNetworking *(BOOL removeCache) {
        self.request.clearCache = removeCache;
        return self;
    };
}

- (ALNetworking *(^)(float))minRepeatInterval
{
    return ^ALNetworking *(float repeatInterval) {
        self.request.repeatRequestInterval = repeatInterval;
        return self;
    };
}

- (ALNetworking *(^)(float, BOOL))minRepeatIntervalInCondition
{
    return ^ALNetworking *(float repeatInterval,BOOL forceRequest) {
        self.request.repeatRequestInterval = repeatInterval;
        self.request.force = forceRequest;
        return self;
    };
}

- (ALNetworking *(^)(NSString *))downloadDestPath
{
    return ^ALNetworking *(NSString *destPath) {
        self.request.destPath = destPath;
        return self;
    };
}

- (void)cancelAllRequest {
    [self.requestDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, ALNetworkRequest * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj.task cancel];
    }];
}

- (void)cancelRequestWithName:(NSString *)name {
    // 移除请求
    if ([self.requestDictionary.allKeys containsObject:name]) {
        ALNetworkRequest *request = [self.requestDictionary objectForKey:name];
        if (request.task) {
            [request.task cancel];
        } else if (request.downloadTask) {
            [request.downloadTask cancel];
        }
        [self.requestDictionary removeObjectForKey:request.name];
    } else {
        NSLog(@"请求已经完成或者没有name = %@的请求",name);
    }
}

- (ALNetworkRequest *)getRequest {
    return self.request;
}

- (void)handleRequestSerialization:(AFHTTPRequestSerializer *(^)(AFHTTPRequestSerializer *serializer))requestSerializerBlock {
    if (requestSerializerBlock) {
        self.request.requestSerializerBlock = requestSerializerBlock;
    }
}

- (void)handleResponseSerialization:(AFHTTPResponseSerializer *(^)(AFHTTPResponseSerializer *))responseSerializerBlock
{
    if (responseSerializerBlock) {
        self.request.responseSerializerBlock = responseSerializerBlock;
    }
}

#ifdef RAC

- (RACSignal<RACTuple *> *)executeSignal {
    
    ALNetworkRequest *request = [self.request copy];
    
    BOOL canContinue = [self handleConfigWithRequest:request];
    if (!canContinue) {
        self.request = nil;
        return [RACSignal empty];
    }
    
    if (self.handleRequest) {
        request = self.handleRequest(request);
        if (!request) {
            self.request = nil;
            return [RACSignal empty];
        }
    }
    
    if (request.clearCache) {
        [[ALNetworkCache defaultManager] removeCacheWithUrl:request.urlStr params:request.params];
    }
    
    @weakify(self);
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self);
        
        [ALBaseNetworking requestWithRequest:request mockData:request.mockData success:^(ALNetworkResponse *response, ALNetworkRequest *req) {
        
            // 请求完成取消请求
            if (!response.isCache) {
                [self cancelRequestWithName:req.name];
            }
            
            if (self.handleResponse) {
                NSError *error = self.handleResponse(response,req);
                if (!error) {
                    [subscriber sendNext:RACTuplePack(response,req)];
                }
                if (req.cacheStrategy == ALCacheStrategyCacheThenNetwork) {
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
                if (req.cacheStrategy == ALCacheStrategyCacheThenNetwork) {
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
                if ([ALNetworkingConfig defaultConfig].distinguishError == NO &&
                    self.handleResponse && responseObject) {
                    response.rawData = responseObject;
                    NSError *error = self.handleResponse(response,request);
                    if (error) {
                        [subscriber sendError:error];
                    }
                } else {
                    [subscriber sendError:error];
                }
            }
            
        }];
        return nil;
    }];
    
    self.request = nil;
    
    return signal;
}

- (RACSignal *)executeDownloadSignal
{
    ALNetworkRequest *request = [self.request copy];
    
    BOOL canContinue = [self handleConfigWithRequest:request];
    if (!canContinue) {
        self.request = nil;
        return [RACSignal empty];
    }
    
    if (self.handleRequest) {
        request = self.handleRequest(request);
        if (!request) {
            self.request = nil;
            return [RACSignal empty];
        }
    }
    
    @weakify(self);
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        @strongify(self);
        
        [ALBaseNetworking downloadWithRequest:request progress:^(float progress) {
            if (request.progressBlock) {
                request.progressBlock(progress);
            }
        } success:^(ALNetworkResponse *response, ALNetworkRequest *request) {
           if (!response.isCache) {
                [self cancelRequestWithName:request.name];
            }
                
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
                [subscriber sendError:error];
            }
        }];
        
        return nil;
    }];
    self.request = nil;
    
    return signal;
}

#endif

#pragma mark - private method

- (BOOL)handleConfigWithRequest:(ALNetworkRequest *)request {
    
    if (request.repeatRequestInterval > 0) { // 需要最短时间间隔
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
        NSString *keyName = [[ALNetworkCache defaultManager] keyForUrl:request.urlStr params:request.params];

        if (!request.isForce) { // 不是强制请求，判断是否大于最短时间间隔
            NSTimeInterval startTime = 0;
            if ([self.requestTimeDictionary.allKeys containsObject:keyName]) {
                startTime = [self.requestTimeDictionary[keyName] doubleValue];
                if (currentTimeInterval - startTime < request.repeatRequestInterval) {
                    return NO;
                }
            }
        }
        [self.requestTimeDictionary setObject:@(currentTimeInterval) forKey:keyName];
    }
    
    if (!request.name || request.name.length == 0) {
        request.name = [NSUUID UUID].UUIDString;
    }
    
    ALNetworkRequest *requestCopy = [request copy];
    
    // 先处理config的再处理self的
    ALNetworkingConfig *config = [ALNetworkingConfig defaultConfig];
    
    if (!request.disableDynamicParams && (self.dynamicParamsConfig || config.dynamicParamsConfig)) { // 动态参数 , 为了保持手动传入参数的优先级最高，这里剔除掉重复的动态参数的键值对，下面的Header同理
        NSDictionary *(^dynamicParamsConfig)(ALNetworkRequest *request) = self.dynamicParamsConfig ?: config.dynamicParamsConfig;
        NSDictionary *dynamicParams = dynamicParamsConfig(requestCopy);
        [dynamicParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (![self.inputParams.allKeys containsObject:key]) {
                [request.params setObject:obj forKey:key];
            }
        }];
    }
    
    if (!request.disableDynamicHeader && (self.dynamicHeaderConfig || config.dynamicHeaderConfig)) {
        NSDictionary *(^dynamicHeaderConfig)(ALNetworkRequest *request) = self.dynamicHeaderConfig ?: config.dynamicHeaderConfig;
        NSDictionary *dynamicHeader = dynamicHeaderConfig(requestCopy);
        [dynamicHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (![self.inputHeaders.allKeys containsObject:key]) {
                [request.header setObject:obj forKey:key];
            }
        }];
    }
    
    if (self.commonParamsMethod == ALNetworkingCommonParamsMethodQS) {
        NSString *queryString = [self stringWithDictionary:[ALNetworkingConfig defaultConfig].defaultParams];
        request.urlStr = [request.urlStr stringByAppendingString:queryString];
    }
       
    if (self.defaultParamsMethod == ALNetworkingCommonParamsMethodQS) {
        NSString *queryString = [self stringWithDictionary:self.commonParams];
        request.urlStr = [request.urlStr stringByAppendingString:queryString];
    }
    
    request.startTimeInterval = [[NSDate date] timeIntervalSince1970];
    
    [self.requestDictionary setObject:request forKey:request.name];
    
    return YES;
}

- (NSString *)stringWithDictionary:(NSDictionary *)dic {
    NSMutableString *ms = [NSMutableString stringWithString:@"?"];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [ms appendFormat:@"%@=%@&",key,obj];
    }];
    NSString *s = [ms substringToIndex:ms.length - 1];
    return s;
}

- (BOOL)handleError:(ALNetworkRequest *)request response:(ALNetworkResponse *)response isCache:(BOOL)isCache error:(NSError *)error
{
    if (!isCache) {
        [self cancelRequestWithName:request.name];
    }
    if (error.code == kNoCacheErrorCode && request.cacheStrategy != ALCacheStrategyCacheOnly) { // 无缓存不回调
        return NO;
    }
    if (error.code == NSURLErrorCancelled) {
        return NO;
    }
    // 处理一下错误
    if (self.handleError) {
        self.handleError(request, response, error);
    }
    
    return YES;
}

#pragma mark - setter & getter

- (ALNetworkRequest *)request {
    if (!_request) {
        _request = [[ALNetworkRequest alloc] init];
        _request.cacheStrategy = [ALNetworkingConfig defaultConfig].defaultCacheStrategy;
        if (!self.ignoreDefaultHeader) {
            [_request.header setValuesForKeysWithDictionary:[ALNetworkingConfig defaultConfig].defaultHeader];
        }
        if (self.commonHeader) {
            [_request.header setValuesForKeysWithDictionary:self.commonHeader];
        }
        
        if (!self.ignoreDefaultParams && self.commonParamsMethod == ALNetworkingCommonParamsMethodFollowMethod) {
            [_request.params setValuesForKeysWithDictionary:[ALNetworkingConfig defaultConfig].defaultParams];
        }
        if (self.commonParams) {
            [_request.params setValuesForKeysWithDictionary:self.commonParams];
        }
    }
    return _request;
}

- (void)setExecuteRequest:(void (^)(ALNetworkResponse *, ALNetworkRequest *, NSError *))executeRequest {
    _executeRequest = executeRequest;
    
    if (!executeRequest) {
        return;
    }
    
    ALNetworkRequest *request = [self.request copy];
    
    BOOL canContinue = [self handleConfigWithRequest:request];
    if (!canContinue) {
        return;
    }
    
    if (self.handleRequest) {
        request = self.handleRequest(request);
        if (!request) {
            return;
        }
    }
           
    // AF内部解开self的循环引用，所以不用弱引用
    request.task = [ALBaseNetworking requestWithRequest:request mockData:request.mockData success:^(ALNetworkResponse *response, ALNetworkRequest *req) {
        
        if (!response.isCache) {
            [self cancelRequestWithName:req.name];
        }
        
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
            if ([ALNetworkingConfig defaultConfig].distinguishError == NO && self.handleResponse && responseObject) {
                resp.rawData = responseObject;
                NSError *error = self.handleResponse(resp,req);
                executeRequest(resp,req,error);
            } else {
                executeRequest(resp,req,error);
            }
        }
    }];
    
    self.request = nil;
}

- (void)setExecuteUploadRequest:(void (^)(ALNetworkResponse *, ALNetworkRequest *, NSError *))executeUploadRequest
{
    _executeUploadRequest = executeUploadRequest;
    
    if (!executeUploadRequest) {
        return;
    }
    
    ALNetworkRequest *request = [self.request copy];
    
    BOOL canContinue = [self handleConfigWithRequest:request];
    if (!canContinue) {
        return;
    }
    
    if (self.handleRequest) {
        request = self.handleRequest(request);
        if (!request) {
            return;
        }
    }
    
    if (request.clearCache) {
        [[ALNetworkCache defaultManager] removeCacheWithUrl:request.urlStr params:request.params];
    }
    
    request.task = [ALBaseNetworking uploadWithRequest:request progress:^(float progress) {
        if (request.progressBlock) {
            request.progressBlock(progress);
        }
    } success:^(ALNetworkResponse *response, ALNetworkRequest *request) {
        
        if (!response.isCache) {
            [self cancelRequestWithName:request.name];
        }
        
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
        
        if([self handleError:request response:nil isCache:isCache error:error]) {
            executeUploadRequest(nil,request,error);
        }
    }];
    self.request = nil;
}

- (NSMutableDictionary *)requestDictionary {
    if (!_requestDictionary) {
        _requestDictionary = [NSMutableDictionary dictionary];
    }
    return _requestDictionary;
}

- (NSMutableDictionary *)requestTimeDictionary
{
    if (!_requestTimeDictionary) {
        _requestTimeDictionary = [NSMutableDictionary dictionary];
    }
    return _requestTimeDictionary;
}

- (AFNetworkReachabilityStatus)networkStatus
{
    return [ALAPIClient sharedInstance].networkStatus;
}

- (void)dealloc
{
    [self.requestTimeDictionary removeAllObjects];
}

@end
