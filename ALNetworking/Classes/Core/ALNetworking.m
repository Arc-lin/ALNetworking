//
//  ALNetworking.m
//  ALNetworking
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

/**
 请求体
 */
@property (nonatomic, strong) ALNetworkRequest *request;

@end

@implementation ALNetworking

- (void)cancelAllRequest {
    [self.requestDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, ALNetworkRequest * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj.req_requestTask cancel];
    }];
}

- (void)cancelRequestWithName:(NSString *)name {
    // 移除请求
    if ([self.requestDictionary.allKeys containsObject:name]) {
        ALNetworkRequest *request = [self.requestDictionary objectForKey:name];
        if (request.req_requestTask) {
            [request.req_requestTask cancel];
        }
        if (request.req_downloadTask) {
            [request.req_downloadTask cancel];
        }
        [self.requestDictionary removeObjectForKey:request.name];
    } else {
        NSLog(@"请求已经完成或者没有name = %@的请求",name);
    }
}

- (ALNetworkRequest *)getRequest {
    return self.request;
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
    
    @weakify(self);
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self);
        
        request.req_requestTask = [ALBaseNetworking requestWithRequest:request mockData:request.mockData success:^(ALNetworkResponse *response, ALNetworkRequest *req) {
        
            // 请求完成取消请求
            if (!response.isCache) {
                [self cancelRequestWithName:req.req_name];
            }
            
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
        
        request.req_downloadTask = [ALBaseNetworking downloadWithRequest:request progress:^(float progress) {
            if (request.req_progressBlock) {
                request.req_progressBlock(progress);
            }
        } success:^(ALNetworkResponse *response, ALNetworkRequest *request) {
           if (!response.isCache) {
                [self cancelRequestWithName:request.req_name];
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
    
    if (request.req_repeatRequestInterval > 0) { // 需要最短时间间隔
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
        NSString *keyName = [[ALNetworkCache defaultManager] keyForUrl:request.req_urlStr params:request.req_params];

        if (!request.isForce) { // 不是强制请求，判断是否大于最短时间间隔
            NSTimeInterval startTime = 0;
            if ([self.requestTimeDictionary.allKeys containsObject:keyName]) {
                startTime = [self.requestTimeDictionary[keyName] doubleValue];
                if (currentTimeInterval - startTime < request.req_repeatRequestInterval) {
                    return NO;
                }
            }
        }
        [self.requestTimeDictionary setObject:@(currentTimeInterval) forKey:keyName];
    }
    
    /// 防止改动了不必要的东西，所以复制一份
    ALNetworkRequest *requestCopy = [request copy];
    
    ALNetworkingConfig *config = [ALNetworkingConfig defaultConfig];
    
    // 先处理config的再处理self的
    if (self.commonParamsMethod == ALNetworkingCommonParamsMethodQS) {
        request.req_urlStr = [self stringWithURLString:request.req_urlStr params:[ALNetworkingConfig defaultConfig].defaultParams];
    }
    
    if (self.defaultParamsMethod == ALNetworkingCommonParamsMethodQS) {
        request.req_urlStr = [self stringWithURLString:request.req_urlStr params:self.defaultParams];
    }
    
    /// 记录请求起始时间
    request.req_startTimeInterval = [[NSDate date] timeIntervalSince1970];
    
    [self.requestDictionary setObject:request forKey:request.name];
        
    if (request.req_disableDynamicParams == ALNetworkingConfigTypeAll) {
        return YES;
    }
    
    /// 处理动态参数
    NSMutableDictionary *pramsDic = [NSMutableDictionary dictionary];
    
    /// 优先级最低
    if (request.req_disableDynamicParams != ALNetworkingConfigTypePublic && config.dynamicParamsConfig) {
        NSDictionary *configParams = config.dynamicParamsConfig(requestCopy);
        if (configParams) {
            [pramsDic addEntriesFromDictionary:configParams];
        }
    }
    
    /// 优先级第二
    if (request.req_disableDynamicParams != ALNetworkingConfigTypePrivate && self.dynamicParamsConfig) {
        NSDictionary *innerParams = self.dynamicParamsConfig(requestCopy);
        if (innerParams) {
            [pramsDic addEntriesFromDictionary:innerParams];
        }
    }
    
    /// 补充上去最终传入的参数，优先级最高
    if (request.req_inputParams) {
        [pramsDic addEntriesFromDictionary:request.req_inputParams];
    }
    
    request.req_params = pramsDic;
    
    /// 处理动态头部
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionary];
    
    /// 优先级最低
    if (request.req_disableDynamicHeader != ALNetworkingConfigTypePublic && config.dynamicHeaderConfig) {
        NSDictionary *configHeader = config.dynamicHeaderConfig(request);
        if (configHeader) {
            [headerDic addEntriesFromDictionary:configHeader];
        }
    }
    
    /// 优先级第二
    if (request.req_disableDynamicHeader != ALNetworkingConfigTypePrivate && self.dynamicHeaderConfig) {
        NSDictionary *innerHeader = self.dynamicHeaderConfig(request);
        if (innerHeader) {
            [headerDic addEntriesFromDictionary:innerHeader];
        }
    }
    
    /// 补充上去最终传入的参数，优先级最高
    if (request.req_inputHeader) {
        [headerDic addEntriesFromDictionary:request.req_inputHeader];
    }
    
    request.req_header = headerDic;
  
    return YES;
}

- (NSString *)stringWithURLString:(NSString *)urlString params:(NSDictionary *)dic {
    NSURLComponents *components= [NSURLComponents componentsWithString:urlString];
    NSMutableArray<NSURLQueryItem *> *queryItems = @[].mutableCopy;
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:obj]];
    }];
    components.queryItems = queryItems;
    return components.URL.absoluteString;
}

- (BOOL)handleError:(ALNetworkRequest *)request response:(ALNetworkResponse *)response isCache:(BOOL)isCache error:(NSError *)error
{
    if (!isCache) {
        [self cancelRequestWithName:request.req_name];
    }
    if (error.code == kNoCacheErrorCode && request.req_cacheStrategy != ALCacheStrategyCacheOnly) { // 无缓存不回调
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
        
        /// 处理公共请求头
        NSMutableDictionary *defaultHeader = [NSMutableDictionary dictionary];
        if (!self.ignoreDefaultHeader) {
            [defaultHeader setValuesForKeysWithDictionary:[ALNetworkingConfig defaultConfig].defaultHeader];
        }
        if (self.defaultHeader) {
            [defaultHeader setValuesForKeysWithDictionary:self.defaultHeader];
        }
        
        /// 处理公共参数
        NSMutableDictionary *defaultParams = [NSMutableDictionary dictionary];
        if (!self.ignoreDefaultParams && self.commonParamsMethod == ALNetworkingCommonParamsMethodFollowMethod) {
            [defaultParams setValuesForKeysWithDictionary:[ALNetworkingConfig defaultConfig].defaultParams];
        }
        if (self.defaultParams) {
            [_request.req_params setValuesForKeysWithDictionary:self.defaultParams];
        }
        
        /// 处理baseURL
        NSString *baseUrl = self.prefixUrl ?: [ALNetworkingConfig defaultConfig].defaultPrefixUrl;
        
        _request = [[ALNetworkRequest alloc] initWithBaseUrl:baseUrl
                                               defaultHeader:defaultHeader
                                               defaultParams:defaultParams
                                               defaultCacheStrategy:[ALNetworkingConfig defaultConfig].defaultCacheStrategy];
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
    request.req_requestTask = [ALBaseNetworking requestWithRequest:request mockData:request.mockData success:^(ALNetworkResponse *response, ALNetworkRequest *req) {
        
        if (!response.isCache) {
            [self cancelRequestWithName:req.req_name];
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
    
    request.req_requestTask = [ALBaseNetworking uploadWithRequest:request progress:^(float progress) {
        if (request.req_progressBlock) {
            request.req_progressBlock(progress);
        }
    } success:^(ALNetworkResponse *response, ALNetworkRequest *request) {
        
        if (!response.isCache) {
            [self cancelRequestWithName:request.req_name];
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
