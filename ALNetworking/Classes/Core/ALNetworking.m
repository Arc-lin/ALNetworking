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

#define ALLOCK(block) {\
[self.lock lock];\
block\
[self.lock unlock];\
}

@interface ALNetworking()

/**
 存储网络请求的字典
 */
@property (nonatomic, strong) NSMutableDictionary *requestDictionary;

/// 请求起始时间
@property (nonatomic, strong) NSMutableDictionary *requestTimeDictionary;

/// 递归锁
@property (nonatomic, strong) NSRecursiveLock *lock;

@end

@implementation ALNetworking

#pragma mark - setter & getter

///  创建一个网络请求
- (ALNetworkRequest *)request {
    
    /// 处理baseURL
    NSString *baseUrl = self.prefixUrl ?: [ALNetworkingConfig defaultConfig].defaultPrefixUrl;
    
    if (baseUrl.length > 0 && ![baseUrl hasPrefix:@"http://"] && ![baseUrl hasPrefix:@"https://"]) {
        NSLog(@"❌URL前缀不合法");
        return nil;
    }
    /// 处理公共请求头
    NSMutableDictionary *defaultHeader = [NSMutableDictionary dictionary];
    if (!self.ignoreDefaultHeader && [ALNetworkingConfig defaultConfig].defaultHeader) {
        [defaultHeader addEntriesFromDictionary:[ALNetworkingConfig defaultConfig].defaultHeader];
    }
    
    /// 处理私有请求头
    if (self.defaultHeader) {
        [defaultHeader addEntriesFromDictionary:self.defaultHeader];
    }
    
    /// 处理公共参数
    NSMutableDictionary *defaultParams = [NSMutableDictionary dictionary];
    if (!self.ignoreDefaultParams && self.configParamsMethod == ALNetworkingCommonParamsMethodFollowMethod && [ALNetworkingConfig defaultConfig].defaultParams) {
        [defaultParams addEntriesFromDictionary:[ALNetworkingConfig defaultConfig].defaultParams];
    }
    
    /// 处理私有参数
    if (self.defaultParams && self.defaultParamsMethod == ALNetworkingCommonParamsMethodFollowMethod) {
        [defaultParams addEntriesFromDictionary:self.defaultParams];
    }
    
    ALNetworkRequest *request = [[ALNetworkRequest alloc] initWithBaseUrl:baseUrl
                                                            defaultHeader:defaultHeader
                                                            defaultParams:defaultParams
                                                     defaultCacheStrategy:[ALNetworkingConfig defaultConfig].defaultCacheStrategy];
    
    /// 处理URL
    /// 处理URL,config配置优先
    if (self.defaultParamsMethod == ALNetworkingCommonParamsMethodQS && self.configParamsMethod == ALNetworkingCommonParamsMethodQS) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        if (!self.ignoreDefaultParams) { /// 不忽略的情况下才加进去
            [params addEntriesFromDictionary:[ALNetworkingConfig defaultConfig].defaultParams];
        }
        /// 覆盖掉config的
        [params addEntriesFromDictionary:self.defaultParams];
        request.req_urlStr = [self stringWithURLString:baseUrl params:params];
    } else if (self.configParamsMethod == ALNetworkingCommonParamsMethodQS && !self.ignoreDefaultParams) {
        request.req_urlStr = [self stringWithURLString:baseUrl params:[ALNetworkingConfig defaultConfig].defaultParams];
    } else if (self.defaultParamsMethod == ALNetworkingCommonParamsMethodQS) {
        request.req_urlStr = [self stringWithURLString:baseUrl params:self.defaultParams];
    }
    
    __weak typeof(self) weakSelf = self;
    
    request.handleResponse = ^NSError *(ALNetworkResponse *response, ALNetworkRequest *request) {
        __strong typeof(self) self = weakSelf;
        // 网络请求完成取消请求
        if (!response.isCache) {
            [self cancelRequestWithName:request.req_name];
        }
        if (self.handleResponse) {
            return self.handleResponse(response,request);
        } else {
            return nil;
        }
    };
    
    request.handleError = ^(ALNetworkRequest *request, ALNetworkResponse *response, NSError *error) {
        __strong typeof(self) self = weakSelf;
        if (!response.isCache) {
            [self cancelRequestWithName:request.req_name];
        }
        if ([ALNetworkingConfig defaultConfig].distinguishError == NO &&
            self.handleResponse && response) {
            error = self.handleResponse(response,request);
        }
        if (self.handleError) {
            self.handleError(request, response, error);
        }
        return error;
    };
    
    request.handleRequest = ^ALNetworkRequest *(ALNetworkRequest *request) {
        __strong typeof(self) self = weakSelf;
        
        /// 需要最短时间间隔
        if (request.req_repeatRequestInterval > 0) {
            NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
            NSString *keyName = request.req_name;
    
            if (!request.isForce) { // 不是强制请求，判断是否大于最短时间间隔
                NSTimeInterval startTime = 0;
                ALLOCK(
                    if ([self.requestTimeDictionary.allKeys containsObject:keyName]) {
                        startTime = [self.requestTimeDictionary[keyName] doubleValue];
                    }
                )
                if (startTime > 0) {
                    if (currentTimeInterval - startTime < request.req_repeatRequestInterval) {
                        return nil;
                    }
                }
            }
            ALLOCK(
                [self.requestTimeDictionary setObject:@(currentTimeInterval) forKey:keyName];
            )
        }
        
        /// 防止改动了不必要的东西，所以复制一份
        ALNetworkRequest *requestCopy = [request copy];
        
        ALNetworkingConfig *config = [ALNetworkingConfig defaultConfig];
        
        if (request.req_disableDynamicParams == ALNetworkingConfigTypeAll &&
            request.req_disableDynamicHeader == ALNetworkingConfigTypeAll) {
            return request;
        }
        
        /// 处理动态参数
        NSMutableDictionary *pramsDic = [NSMutableDictionary dictionary];
        
        /// 公有参数优先级最低
        if (request.req_disableDynamicParams != ALNetworkingConfigTypePublic &&
            request.req_disableDynamicParams != ALNetworkingConfigTypeAll    && config.dynamicParamsConfig) {
            NSDictionary *configParams = config.dynamicParamsConfig(requestCopy);
            if (configParams) {
                [pramsDic addEntriesFromDictionary:configParams];
            }
        }
        
        /// 私有参数优先级第二
        if (request.req_disableDynamicParams != ALNetworkingConfigTypePrivate && request.req_disableDynamicParams != ALNetworkingConfigTypeAll     &&
            self.dynamicParamsConfig) {
            NSDictionary *innerParams = self.dynamicParamsConfig(requestCopy);
            if (innerParams) {
                [pramsDic addEntriesFromDictionary:innerParams];
            }
        }
        
        /// 补充上去最终传入的参数，优先级最高
        if (request.req_inputParams) {
            [pramsDic addEntriesFromDictionary:request.req_inputParams];
        }
        
        [request.req_params addEntriesFromDictionary:pramsDic];
        
        /// 处理动态头部
        NSMutableDictionary *headerDic = [NSMutableDictionary dictionary];
        
        /// 公有头部优先级最低
        if (request.req_disableDynamicHeader != ALNetworkingConfigTypePublic &&
            request.req_disableDynamicHeader != ALNetworkingConfigTypeAll    &&
            config.dynamicHeaderConfig) {
            NSDictionary *configHeader = config.dynamicHeaderConfig(requestCopy);
            if (configHeader) {
                [headerDic addEntriesFromDictionary:configHeader];
            }
        }
        
        /// 私有头部优先级第二
        if (request.req_disableDynamicHeader != ALNetworkingConfigTypePrivate && request.req_disableDynamicHeader != ALNetworkingConfigTypeAll     &&
            self.dynamicHeaderConfig) {
            NSDictionary *innerHeader = self.dynamicHeaderConfig(requestCopy);
            if (innerHeader) {
                [headerDic addEntriesFromDictionary:innerHeader];
            }
        }
        
        /// 补充上去最终传入的头部，优先级最高
        if (request.req_inputHeader) {
            [headerDic addEntriesFromDictionary:request.req_inputHeader];
        }
        
        [request.req_header addEntriesFromDictionary:headerDic];
        
        /// 最后的最后就交给外面去处理了
        if (self.handleRequest) {
            request = self.handleRequest(request);
        }
        
        ALLOCK(
            [self.requestDictionary setObject:request forKey:request.req_name];
        )
       
        return request;
    };
    
    return request;
}

- (NSString *)stringWithURLString:(NSString *)urlString params:(NSDictionary *)dic {
    NSURLComponents *components= [NSURLComponents componentsWithString:urlString];
    NSMutableArray<NSURLQueryItem *> *queryItems = @[].mutableCopy;
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:obj]];
    }];
    components.queryItems = queryItems;
    if (components.URL) {
        return components.URL.absoluteString;
    } else {
        return nil;
    }
}

- (void)cancelAllRequest {
    ALLOCK(
        [self.requestDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, ALNetworkRequest * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj.req_requestTask cancel];
        }];
    )
}

- (void)cancelRequestWithName:(NSString *)name {
    // 移除请求
    ALLOCK(
        if ([self.requestDictionary.allKeys containsObject:name]) {
            ALNetworkRequest *request = [self.requestDictionary objectForKey:name];
            if (request.req_requestTask) {
                [request.req_requestTask cancel];
            }
            if (request.req_downloadTask) {
                [request.req_downloadTask cancel];
            }
            [self.requestDictionary removeObjectForKey:request.req_name];
        }
        
        if ([self.requestTimeDictionary.allKeys containsObject:name]) {
            [self.requestTimeDictionary removeObjectForKey:name];
        }
    )
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

- (NSRecursiveLock *)lock {
    if (!_lock) {
        _lock = [[NSRecursiveLock alloc] init];
    }
    return _lock;
}

- (void)dealloc
{
    [self.requestTimeDictionary removeAllObjects];
}

@end
