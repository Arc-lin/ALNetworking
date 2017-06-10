//
//  ALNetworking.m
//  ALNetworkingDemo
//
//  Created by Arclin on 17/2/25.
//  Copyright © 2017年 dankal. All rights reserved.
//

#import "ALNetworking.h"
#import "ALNetworkingCache.h"

#import "ALNetworkingBaseManager.h"
#import "ALNetworkingViewController.h"

#import <YYModel/YYModel.h>
#import <AFNetworkReachabilityManager.h>

#define KERROR(eCode,desc) [NSError errorWithDomain:@"alnetworking" code:eCode userInfo:@{NSLocalizedDescriptionKey:desc}]

@interface ALNetworking ()

/** 缓存 */
@property (nonatomic, strong) ALNetworkingCache   *cache;

/** 请求体 */
@property (nonatomic, strong) ALNetworkingRequest *request;

/** 响应错误的回调 */
@property (nonatomic, strong) RACSubject *errors;

/** 请求的历史 */
@property (nonatomic, strong) NSMutableArray *requestHistories;

@end

@implementation ALNetworking

#pragma mark - 单例

static ALNetworking *_networking;

+ (instancetype)sharedInstance
{
    if (_networking == nil) {
        _networking = [[ALNetworking alloc] init];
    }
    return _networking;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networking = [super allocWithZone:zone];
    });
    return _networking;
}

#pragma mark - 链式方法的实现

- (ALNetworking *(^)(ALNetworkRequestMethod))method
{
    return ^ALNetworking *(ALNetworkRequestMethod method){
        self.request.method = method;
        return self;
    };
}

- (ALNetworking *(^)(NSString *))url
{
    return ^ALNetworking *(NSString *url){
        self.request.urlStr = [NSString stringWithFormat:@"%@/%@",self.config.urlPerfix,url];
        return self;
    };
}

- (ALNetworking *(^)(NSString *))url_x
{
    return ^ALNetworking *(NSString *url){
        self.request.urlStr = url;
        return self;
    };
}

- (ALNetworking *(^)(NSDictionary *))params
{
    return ^ALNetworking *(NSDictionary *params){
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithDictionary:params];
        [paramDic setValuesForKeysWithDictionary:self.config.defaultParams];
        self.request.params = paramDic;
        return self;
    };
}

- (ALNetworking *(^)(NSDictionary *))header
{
    return ^ALNetworking *(NSDictionary *header){
        NSMutableDictionary *headerDic = [NSMutableDictionary dictionaryWithDictionary:header];
        [headerDic setValuesForKeysWithDictionary:self.config.defaultHeader];
        self.request.header = headerDic;
        return self;
    };
}

- (ALNetworking *(^)(ALCacheStrategy))cacheStrategy
{
    return ^ALNetworking *(ALCacheStrategy cacheStrategy){
        self.request.cacheStrategy = cacheStrategy;
        return self;
    };
}

- (ALNetworking *(^)(ALNetworkRequestParamsType))paramsType
{
    return ^ALNetworking *(ALNetworkRequestParamsType paramsType){
        self.request.paramsType = paramsType;
        return self;
    };
}

- (RACSignal *(^)())executeSignal
{
    return ^RACSignal *(){
        
        // 发送请求
        RACSignal *signal = [self handleRequest:self.request];
        
        // 置空成员属性
        self.request = nil;
        
        return signal;
    };
}


#pragma mark - 发送请求

- (RACSignal *)handleRequest:(ALNetworkingRequest *)request
{
    NSAssert(self.config.handleResponse, @"handleRACResponse could not be nil");
    NSAssert(self.config.customLog, @"customLog could not be nil");
    
    RACSignal *requestSignal;
    @weakify(self);
    switch (request.cacheStrategy) {
        case ALCacheStrategy_CACHE_ONLY: // 只请求缓存
            requestSignal = [self cacheWithRequest:request];
            break;
        case ALCacheStrategy_NETWORK_ONLY: // 只请求网络
            requestSignal = [self networkWithRequest:request cache:NO];
            break;
        case ALCacheStrategy_NETWORK_AND_CACHE: // 请求网络后缓存
        {
            requestSignal = [self networkWithRequest:request cache:YES];
        }
            break;
        case ALCacheStrategy_CACHE_ELSE_NETWORK: // 取缓存无则请求网络
        {
            requestSignal = [[self cacheWithRequest:request] catch:^RACSignal *(NSError *error) {
                @strongify(self);
                return [self networkWithRequest:request cache:YES];
            }];
        }
            break;
        case ALCacheStrategy_CACHE_THEN_NETWORK: // 取缓存并请求网络
        {
            requestSignal = [[[self cacheWithRequest:request] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }] concat:[self networkWithRequest:request cache:YES]];
        }
            break;
        case ALCacheStrategy_AUTOMATICALLY: // 网络异常则取缓存
        {
            requestSignal = [[self networkWithRequest:request cache:YES] catch:^RACSignal *(NSError *error) {
                @strongify(self);
                return [self cacheWithRequest:request];
            }];
        }
            break;
        default:
            break;
    }
    
    return [[[requestSignal map:^id(RACTuple *value) {
        @strongify(self);
        // 如果有设置自定义响应体类的话
        if (self.config.customRespClazz) {
            ALNetworkingResponse *resp = value.second;
            id customResponse = [self.config.customRespClazz yy_modelWithDictionary:resp.rawData];
            return RACTuplePack(value.first,customResponse);
        }
        return value;
    }] flattenMap:self.config.handleResponse] catch:^RACSignal *(NSError *error) {
        @strongify(self);
        
        // 检查服务器是否有返回错误页面代码
        if(self.config.debugMode && [error.userInfo.allKeys containsObject:@"NSUnderlyingError"]) {
            NSError *underlyingError = error.userInfo[@"NSUnderlyingError"];
            if ([underlyingError.userInfo.allKeys containsObject:@"com.alamofire.serialization.response.error.data"]) {
                NSString *htmlStr = [[NSString alloc] initWithData:underlyingError.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
                ALNetworkingViewController *vc = [[ALNetworkingViewController alloc] initWithWebViewControllerWithHtmlStr:htmlStr];
                // 弹出窗口
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
            }
        }
        
        self.config.customLog([NSString stringWithFormat:@"Request Error : %@",error]);
        // 发送信号告知错误
        [self.errors sendNext:self.config.handleError(error)];
        return [RACSignal empty];
    }];
}

// 通过请求体取出缓存中的响应体
- (RACSignal *)cacheWithRequest:(ALNetworkingRequest *)request
{
    RACSignal *cacheSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[RACScheduler scheduler] schedule:^{
            ALNetworkingResponse *response = [self.cache responseForRequestUrl:request.urlStr params:request.params];
            if(!response) {
                [subscriber sendError:KERROR(-99, @"NO CACHE")];
            } else {
                
                // 添加进入历史记录中
                [self.requestHistories addObject:RACTuplePack([NSDate date],request,response)];
                
                [subscriber sendNext:RACTuplePack(request,response)];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
    return cacheSignal;
}

// 网络请求
- (RACSignal *)networkWithRequest:(ALNetworkingRequest *)request cache:(BOOL)cache
{
    @weakify(self);
    RACSignal *requestSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [ALNetworkingBaseManager requestForRequest:request reponseBlock:^(ALNetworkingRequest *request, ALNetworkingResponse *response) {
            
            @strongify(self);
            if(cache) {
                [[RACScheduler scheduler] schedule:^{
                    // 把请求结果写入缓存
                    [self.cache setObject:response forRequestUrl:request.urlStr params:request.params];
                }];
            }

            // 添加进入历史记录中
            [self.requestHistories addObject:RACTuplePack([NSDate date],request,response)];
            
            if (response.error) {
                [subscriber sendError:response.error];
            } else {
                [subscriber sendNext:RACTuplePack(request,response)];
                [subscriber sendCompleted];
            }
        } config:self.config];
        
        return nil;
    }];
    return requestSignal;
}

#pragma mark - 网络状态

+ (void)networkStatus:(void (^)(ALNetworkReachabilityStatus))statusBlock
{
    NSAssert(statusBlock != nil, @"Block Cannot Be Nil");
    
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态发生改变的时候调用这个block
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                statusBlock(ALNetworkReachabilityStatusReachableViaWiFi);
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                statusBlock(ALNetworkReachabilityStatusReachableViaWWAN);
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                statusBlock(ALNetworkReachabilityStatusNotReachable);
                break;
                
            case AFNetworkReachabilityStatusUnknown:
                statusBlock(ALNetworkReachabilityStatusUnknown);
                break;
            default:
                break;
        }
    }];
    // 开始监控
    [mgr startMonitoring];
}

#pragma mark - 清空历史

- (void)clearHistories
{
    [self.requestHistories removeAllObjects];
}

#pragma mark - setter & getter

- (ALNetworkingCache *)cache
{
    if (!_cache) {
        _cache = [ALNetworkingCache defaultManager];
    }
    return _cache;
}

- (ALNetworkingRequest *)request
{
    if (!_request) {
        _request = [[ALNetworkingRequest alloc] init];
    }
    return _request;
}

- (RACSubject *)errors
{
    if(!_errors) {
        _errors = [RACSubject subject];
    }
    return _errors;
}

- (ALNetworkingConfig *)config
{
    if (!_config) {
        _config = [[ALNetworkingConfig alloc] init];
    }
    return _config;
}

- (NSMutableArray *)requestHistories
{
    if (!_requestHistories) {
        _requestHistories = [NSMutableArray array];
    }
    return _requestHistories;
}

@end
