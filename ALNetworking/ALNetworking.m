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
#import <AFNetworking/AFNetworking.h>

#define KERROR(eCode,desc) [NSError errorWithDomain:@"alnetworking" code:eCode userInfo:@{NSLocalizedDescriptionKey:desc}]

@interface ALNetworking ()

/** Cache */
@property (nonatomic, strong) ALNetworkingCache   *cache;

/** Request Body */
@property (nonatomic, strong) ALNetworkingRequest *request;

/** Error Subject */
@property (nonatomic, strong) RACSubject *errors;

/** Histories */
@property (nonatomic, strong) NSMutableArray *requestHistories;

@end

@implementation ALNetworking

#pragma mark - Singleton

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

#pragma mark - Chain

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
        // 剪掉最前面的 "/"
        if ([[url substringToIndex:1] isEqualToString:@"/"]) {
            url = [url substringFromIndex:1];
        }
        // 通过判断有没有http:// 或者 https:// 前缀去决定是否要使用url前缀 , 如果这种做法处理不当的话请告知我
        if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
            self.request.urlStr = url;
            self.request.ignoreCustomResponseClass = YES;
        } else {
            self.request.urlStr = [NSString stringWithFormat:@"%@/%@",self.config.urlPerfix,url];
            self.request.ignoreCustomResponseClass = NO;
        }
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


#pragma mark - Send Request

- (RACSignal *)handleRequest:(ALNetworkingRequest *)request
{
    NSAssert(self.config.handleResponse, @"handleRACResponse could not be nil");
    NSAssert(self.config.customLog, @"customLog could not be nil");
    
    RACSignal *requestSignal;
    @weakify(self);
    switch (request.cacheStrategy) {
        case ALCacheStrategy_CACHE_ONLY: // Only Request Cache
            requestSignal = [self cacheWithRequest:request];
            break;
        case ALCacheStrategy_NETWORK_ONLY: // Only Request network
            requestSignal = [self networkWithRequest:request cache:NO];
            break;
        case ALCacheStrategy_NETWORK_AND_CACHE: // Request network and cache
        {
            requestSignal = [self networkWithRequest:request cache:YES];
        }
            break;
        case ALCacheStrategy_CACHE_ELSE_NETWORK: // Fetch cache, if not exist, fetch network data
        {
            requestSignal = [[self cacheWithRequest:request] catch:^RACSignal *(NSError *error) {
                @strongify(self);
                return [self networkWithRequest:request cache:YES];
            }];
        }
            break;
        case ALCacheStrategy_CACHE_THEN_NETWORK: // Get cache and fetch network data
        {
            requestSignal = [[[self cacheWithRequest:request] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }] concat:[self networkWithRequest:request cache:YES]];
        }
            break;
        case ALCacheStrategy_AUTOMATICALLY: // If network exception, then fetch cache
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
        // 如果有设置并且不忽略自定义响应体类
        // if there has custom response class and not ignore it
        if (self.config.customRespClazz) {
            ALNetworkingRequest  *req  = value.first;
            ALNetworkingResponse *resp = value.second;
            if(req.ignoreCustomResponseClass) return RACTuplePack(req,resp);
            
            id customResponse = [self.config.customRespClazz yy_modelWithDictionary:resp.rawData];
            if ([customResponse isKindOfClass:[ALNetworkingResponse class]]) {
                ((ALNetworkingResponse *)customResponse).error = resp.error;
                ((ALNetworkingResponse *)customResponse).rawData = resp.rawData;
                ((ALNetworkingResponse *)customResponse).isCache = resp.isCache;
            }
            return RACTuplePack(req,customResponse);
        }
        return value;
    }] flattenMap:self.config.handleResponse] catch:^RACSignal *(NSError *error) {
        @strongify(self);
        
        // 检查服务器是否有返回错误页面代码
        // Check whether server has return the error page code
        if(self.config.debugMode && [error.userInfo.allKeys containsObject:@"NSUnderlyingError"]) {
            NSError *underlyingError = error.userInfo[@"NSUnderlyingError"];
            if ([underlyingError.userInfo.allKeys containsObject:@"com.alamofire.serialization.response.error.data"]) {
                NSString *htmlStr = [[NSString alloc] initWithData:underlyingError.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
                ALNetworkingViewController *vc = [[ALNetworkingViewController alloc] initWithWebViewControllerWithHtmlStr:htmlStr];
                // 弹出窗口
                // pop the window
                [[self topViewController] presentViewController:vc animated:YES completion:nil];
            }
        }
        
        self.config.customLog([NSString stringWithFormat:@"Request Error : %@",error]);
        // 发送信号告知错误
        // Send error to call front-end error
        [self.errors sendNext:self.config.handleError(error)];
        return [RACSignal empty];
    }];
}

// 通过请求体取出缓存中的响应体
// Get cache through request
- (RACSignal *)cacheWithRequest:(ALNetworkingRequest *)request
{
    RACSignal *cacheSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[RACScheduler scheduler] schedule:^{
            ALNetworkingResponse *response = [self.cache responseForRequestUrl:request.urlStr params:request.params];
            if(!response) {
                [subscriber sendError:KERROR(-99, @"NO CACHE")];
            } else {
                
                // Confirm is get from cache(for Display)
                response.isCache = YES;
                
                // Add to history
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
// Get data from server through request
- (RACSignal *)networkWithRequest:(ALNetworkingRequest *)request cache:(BOOL)cache
{
    @weakify(self);
    RACSignal *requestSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [ALNetworkingBaseManager requestForRequest:request reponseBlock:^(ALNetworkingRequest *request, ALNetworkingResponse *response) {
            
            @strongify(self);
            if(cache && !response.error) {
                [[RACScheduler scheduler] schedule:^{
                    
                    // Confirm isn't get from cache(for Display)
                    response.isCache = NO;
                    
                    // Save request result into disk cache
                    [self.cache setObject:response forRequestUrl:request.urlStr params:request.params];
                }];
            }

            // Add to history
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

#pragma mark - Network Status

+ (void)networkStatus:(void (^)(ALNetworkReachabilityStatus))statusBlock
{
    NSAssert(statusBlock != nil, @"Block Cannot Be Nil");
    
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
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
    // Start Monitoring
    [mgr startMonitoring];
}

#pragma mark - Get Top ViewControllers
- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

#pragma mark - Clear the histories

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
        _request.header = self.config.defaultHeader;
        _request.params = self.config.defaultParams;
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
