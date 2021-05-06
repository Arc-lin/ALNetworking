//
//  ALNetworkingTests.m
//  ALNetworkingTests
//
//  Created by Arclin on 11/21/2018.

//

@import XCTest;

#import <Kiwi.h>
#import <ALNetworking.h>
#import <ALNetworkCache.h>
#import <ALNetworkingConfig.h>
#import <ALAPIClient.h>
#import <ALNetworkCache.h>

SPEC_BEGIN(Tests)
describe(@"ALNetworking", ^{
    
    __block ALNetworking *networking;
    __block ALNetworkRequest *globalReqeust;
    
    __block NSInteger headerVisitTimes_config = 0;
    __block NSInteger paramsVisitTimes_config = 0;
    __block NSInteger headerVisitTimes_private = 0;
    __block NSInteger paramsVisitTimes_private = 0;
    
    beforeAll(^{
        // 初始化配置
        // 通用、全局配置
        ALNetworkingConfig *config = [ALNetworkingConfig defaultConfig];
        config.defaultPrefixUrl = @"https://v2.alapi.cn";
        config.timeoutInterval = 10;
        config.defaultCacheStrategy = ALCacheStrategyNetworkOnly;
        config.distinguishError = YES;
        config.defaultHeader = @{
            @"test_config_header" : @"config_header",
            @"priority_header" : @"configHeader"
        };
        config.defaultParams = @{
            @"test_config_params" : @"config_params",
            @"priority_params" : @"configParams",
        };
        config.dynamicHeaderConfig = ^NSDictionary *(ALNetworkRequest *request) {
            return @{
                @"config_header_times" : @(++headerVisitTimes_config).stringValue,
                @"priority_header": @"configDynamicHeader",
            };
        };
        config.dynamicParamsConfig = ^NSDictionary *(ALNetworkRequest *request) {
            return @{
                @"config_params_times" : @(++paramsVisitTimes_config).stringValue,
                @"priority_params": @"configDynamicParams",
            };
        };
        
        networking = [[ALNetworking alloc] init];
        networking.prefixUrl = @"https://v1.alapi.cn/api";
        networking.configParamsMethod = ALNetworkingCommonParamsMethodFollowMethod;
        networking.defaultParamsMethod = ALNetworkingCommonParamsMethodFollowMethod;
        networking.defaultHeader = @{
            @"test_private_header" : @"private_header",
            @"priority_header" : @"privateHeader"
        };
        networking.defaultParams = @{
            @"test_private_params" : @"private_params",
            @"priority_params" : @"privateParams"
        };
        
        networking.dynamicHeaderConfig = ^NSDictionary *(ALNetworkRequest *request) {
            return @{
                @"private_header_times" : @(++headerVisitTimes_private).stringValue,
                @"priority_header": @"privateDynamicHeader",
            };
        };
        networking.dynamicParamsConfig = ^NSDictionary *(ALNetworkRequest *request) {
            return @{
                @"private_params_times" : @(++paramsVisitTimes_private).stringValue,
                @"priority_params" : @"privateDynamicParams"
            };
        };
        networking.ignoreDefaultHeader = NO;
        networking.ignoreDefaultParams = NO;
        
    });
    
    afterAll(^{
        networking = nil;
        [[ALNetworkCache defaultManager] removeAllObjects];
    });
    
    context(@"Header And Params", ^{
        it(@"The Networking", ^{
            [[networking should] beNonNil];
        });
        
        it(@"Generate Request And Check Request", ^{
            globalReqeust = networking.request;
            [[globalReqeust should] beNonNil];
            [[globalReqeust.req_header should] equal:@{
                @"test_config_header" : @"config_header",
                @"test_private_header" : @"private_header",
                @"priority_header": @"privateHeader",
            }];
            [[globalReqeust.req_params should] equal:@{
                @"test_config_params" : @"config_params",
                @"test_private_params" : @"private_params",
                @"priority_params" : @"privateParams"
            }];
        });
        
        it(@"Without Default Header", ^{
            networking.ignoreDefaultHeader = YES;
            globalReqeust = networking.request;
            [[globalReqeust.req_header should] equal:@{
                @"test_private_header" : @"private_header",
                @"priority_header": @"privateHeader",
            }];
        });
        
        it(@"Without Default Params", ^{
            networking.ignoreDefaultParams = YES;
            globalReqeust = networking.request;
            [[globalReqeust.req_params should] equal:@{
                @"test_private_params" : @"private_params",
                @"priority_params" : @"privateParams"
            }];
            //            [[theValue(networking.requestDictionary.allKeys.count) should] equal:theValue(0)];
        });
        
        it(@"With Dynamic Header And Dynamic Parameters", ^{
            networking.ignoreDefaultHeader = NO;
            /// Config的公共参数不忽略
            networking.ignoreDefaultParams = YES;
            globalReqeust = networking.request;
            globalReqeust
            .get(@"/new/wbtop")
            .header(@{@"priority_header" : @"innerHeader"})
            .params(@{@"priority_params" : @"innerParams"})
            .executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                
            };
            [[globalReqeust.req_header should] equal:@{
                @"test_config_header" : @"config_header",
                @"config_header_times" : @"1",
                @"test_private_header" : @"private_header",
                @"private_header_times" : @"1",
                @"priority_header" : @"innerHeader"
            }];
            [[globalReqeust.req_params should] equal:@{
                @"config_params_times" : @"1",
                @"test_private_params" : @"private_params",
                @"private_params_times" : @"1",
                @"priority_params" : @"innerParams"
            }];
        });
        
        xit(@"Ignore dynamic header or dynamic params in chain", ^{
            networking.ignoreDefaultHeader = NO;
            networking.ignoreDefaultParams = NO;
            globalReqeust = networking.request;
            globalReqeust
            .get(@"/new/wbtop")
            .header(@{@"priority_header" : @"innerHeader"})
            .params(@{@"priority_params" : @"innerParams"})
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypePrivate)
            .executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                
            };
            [[globalReqeust.req_header should] equal:@{
                @"test_config_header" : @"config_header",
                @"test_private_header" : @"private_header",
                @"priority_header" : @"innerHeader"
            }];
            [[globalReqeust.req_params should] equal:@{
                @"config_params_times" : @"2",
                @"test_config_params" : @"config_params",
                @"test_private_params" : @"private_params",
                @"priority_params" : @"innerParams"
            }];
        });
    });
    
    context(@"Data", ^{
        
        it(@"Mock Data", ^{
            globalReqeust = networking.request;
            __block ALNetworkResponse *myResp = nil;
            globalReqeust
            .mockData(@{@"msg":@"I'm Mock Data",@"code":@200},YES)
            .get(@"/new/wbtop")
            .executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                myResp = response;
            };
            [[expectFutureValue(myResp.rawData) shouldEventually] equal:@{
                @"msg":@"I'm Mock Data",
                @"code":@200
            }];
            [[expectFutureValue(theValue(myResp.isCache)) shouldEventually] beYes];
        });
        
    });
    
    context(@"URL", ^{
        beforeEach(^{
            ALNetworkingConfig *config = [ALNetworkingConfig defaultConfig];
            config.defaultPrefixUrl = @"https://v2.alapi.cn";
        });
        
        it(@"Invalid URL", ^{
            networking.prefixUrl = @"xxxx";
            globalReqeust = networking.request;
            [[globalReqeust should] beNil];
        });
        
        it(@"Perfix Url", ^{
            networking.prefixUrl = @"https://v1.alapi.cn";
            globalReqeust = networking.request;
            
            globalReqeust.get(@"/new/wbtop");
            [[globalReqeust.req_urlStr should] equal:@"https://v1.alapi.cn/new/wbtop"];
            
            globalReqeust.get(@"https://v3.alapi.cn/new/wbtop");
            [[globalReqeust.req_urlStr should] equal:@"https://v3.alapi.cn/new/wbtop"];
            
        });
        
        it(@"Method Type Change URL", ^{
            networking.prefixUrl = nil;
            networking.ignoreDefaultParams = NO;
            networking.configParamsMethod = ALNetworkingCommonParamsMethodQS;
            networking.defaultParamsMethod = ALNetworkingCommonParamsMethodQS;
            
            globalReqeust = networking.request;
            globalReqeust.post(@"/new/wbtop").params(@{@"innerParams":@"testInnerParams"});
            NSURL *url = [NSURL URLWithString:globalReqeust.req_urlStr];
            [[url.path should] equal:@"/new/wbtop"];
            [[url.host should] equal:@"v2.alapi.cn"];
            
            NSMutableDictionary *parm = [[NSMutableDictionary alloc]init];
            NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
            [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [parm setObject:obj.value forKey:obj.name];
            }];
            [[parm should] equal:@{
                @"test_config_params":@"config_params",
                @"test_private_params":@"private_params",
                @"priority_params" : @"privateParams",
            }];
            
            [[globalReqeust.req_params should] equal:@{
                @"innerParams":@"testInnerParams"
            }];
        });
    });
    
    context(@"Cache", ^{
        beforeEach(^{
            ALNetworkingConfig *config = [ALNetworkingConfig defaultConfig];
            config.defaultPrefixUrl = @"https://v1.alapi.cn/api";
            networking.ignoreDefaultHeader = YES;
            networking.ignoreDefaultParams = YES;
            networking.defaultHeader = nil;
            networking.defaultParams = nil;
            networking.defaultParamsMethod = ALNetworkingCommonParamsMethodFollowMethod;
            networking.configParamsMethod = ALNetworkingCommonParamsMethodFollowMethod;
            
            
            networking.handleResponse = ^NSError *(ALNetworkResponse *response, ALNetworkRequest *request) {
                if ([response.rawData isKindOfClass:NSDictionary.class]) {
                    NSInteger code = [response.rawData[@"code"] integerValue];
                    if (code != 200) {
                        return [NSError errorWithDomain:@"domain" code:code userInfo:@{
                            NSLocalizedDescriptionKey : [NSString stringWithFormat:@"%@",response.rawData[@"msg"]?:@""]
                        }];
                    } else {
                        /// 只拿出有用的数据返回出去
                        response.rawData = response.rawData[@"data"];
                    }
                }
                return nil;
            };
        });
        
        xit(@"Network Only", ^{
            __block ALNetworkResponse *resp = nil;
            __block id result = nil;
            
            globalReqeust = networking.request;
            globalReqeust.get(@"/new/wbtop").params(@{@"num" : @"3"})
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypeAll)
            .executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                if (!error) {
                    resp = response;
                    result = response.rawData;
                }
            };
            // 等待10秒等请求回来
            [[expectFutureValue(result) shouldEventuallyBeforeTimingOutAfter(10)] beNonNil];
            [[expectFutureValue(result) shouldEventuallyBeforeTimingOutAfter(10)] beKindOfClass:NSArray.class];
            [[expectFutureValue(theValue([result count])) shouldEventually] beLessThanOrEqualTo:theValue(3)];
            [[expectFutureValue(theValue(resp.isCache)) shouldEventuallyBeforeTimingOutAfter(10)] beNo];
            /// 讲道理应该没缓存
            [[expectFutureValue([[ALNetworkCache defaultManager] responseForRequestUrl:globalReqeust.req_urlStr params:globalReqeust.req_params]) shouldEventuallyBeforeTimingOutAfter(10)] beNil];
        });
        
        xit(@"Cache Only At First Time", ^{
            __block ALNetworkResponse *resp = nil;
            __block id result = nil;
            
            globalReqeust = networking.request;
            
            globalReqeust
            .get(@"/new/wbtop")
            .params(@{@"num" : @"10"})
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypeAll)
            .cacheStrategy(ALCacheStrategyCacheOnly);
            //            __weak typeof(globalReqeust) weakGlobalReqeust = globalReqeust;
            globalReqeust.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                if(!error) {
                    resp = response;
                    result = response.rawData;
                    
                    //                    weakGlobalReqeust.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                    //                        if(!error) {
                    //                            resp = response;
                    //                            result = response.rawData;
                    //                        }
                    //                    };
                    //
                    //                    // 等待10秒等请求回来
                    //                    [[expectFutureValue(theValue(resp.isCache)) shouldEventuallyBeforeTimingOutAfter(10)] beYes];
                }
            };
            // 等待10秒等请求回来
            [[expectFutureValue(theValue(resp.isCache)) shouldEventuallyBeforeTimingOutAfter(10)] beNo];
            /// 讲道理10秒后应该有缓存
            [[expectFutureValue([[ALNetworkCache defaultManager] responseForRequestUrl:globalReqeust.req_urlStr params:globalReqeust.req_params]) shouldEventuallyBeforeTimingOutAfter(10)] beNonNil];
        });
        
        xit(@"Cache Then Network", ^{
            __block ALNetworkResponse *resp = nil;
            __block id result = nil;
            /// 回调访问次数
            __block NSInteger times = 0;
            
            globalReqeust = networking.request;
            
            globalReqeust
            .get(@"/new/wbtop")
            .params(@{@"num" : @"6"})
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypeAll)
            .cacheStrategy(ALCacheStrategyCacheThenNetwork);
            globalReqeust.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                resp = response;
                result = response.rawData;
                times++;
            };
            [[theValue(resp.isCache) should] beYes];
            [[resp.rawData should] beNil];
            [[expectFutureValue(theValue(resp.isCache)) shouldEventuallyBeforeTimingOutAfter(10)] beNo];
            [[expectFutureValue(resp.rawData) shouldEventuallyBeforeTimingOutAfter(10)] beNonNil];
            [[expectFutureValue(theValue(times)) shouldEventuallyBeforeTimingOutAfter(10)] equal:theValue(2)];
            /// 讲道理应该有缓存
            [[expectFutureValue([[ALNetworkCache defaultManager] responseForRequestUrl:globalReqeust.req_urlStr params:globalReqeust.req_params]) shouldEventuallyBeforeTimingOutAfter(10)] beNonNil];
        });
        
        xit(@"Cache Automatic", ^{
            
            __block ALNetworkResponse *resp = nil;
            /// 回调访问次数
            
            globalReqeust = networking.request;
            
            globalReqeust
            .get(@"/new/wbtop")
            .params(@{@"num" : @"7"})
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypeAll)
            .cacheStrategy(ALCacheStrategyAutomatic);
            
            globalReqeust.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                resp = response;
            };
            
            [[expectFutureValue(theValue([ALAPIClient sharedInstance].networkStatus)) shouldEventually] equal:theValue(AFNetworkReachabilityStatusReachableViaWiFi)];
            
//            [[expectFutureValue(theValue(resp.isCache)) shouldEventuallyBeforeTimingOutAfter(10)] beYes];
            
            [[expectFutureValue(theValue(resp.isCache)) shouldEventuallyBeforeTimingOutAfter(10)] beNo];
            /// 讲道理应该有缓存
            [[expectFutureValue([[ALNetworkCache defaultManager] responseForRequestUrl:globalReqeust.req_urlStr params:globalReqeust.req_params]) shouldEventuallyBeforeTimingOutAfter(10)] beNonNil];
        });
        
        xit(@"Cache And Network", ^{
            __block ALNetworkResponse *resp = nil;
            /// 回调访问次数
            __block NSInteger times = 0;
            
            globalReqeust = networking.request;
            
            globalReqeust
            .get(@"/new/wbtop")
            .params(@{@"num" : @"8"})
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypeAll)
            .cacheStrategy(ALCacheStrategyCacheAndNetwork);
            globalReqeust.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                resp = response;
                times++;
            };
            [[expectFutureValue(theValue(times)) shouldEventuallyBeforeTimingOutAfter(10)] equal:theValue(1)];
            /// 讲道理应该有缓存
            [[expectFutureValue([[ALNetworkCache defaultManager] responseForRequestUrl:globalReqeust.req_urlStr params:globalReqeust.req_params]) shouldEventuallyBeforeTimingOutAfter(10)] beNonNil];
        });
        
        it(@"Memory Cache", ^{
            __block ALNetworkResponse *resp = nil;
            
            globalReqeust = networking.request;
            
            globalReqeust
            .get(@"/new/wbtop")
            .params(@{@"num" : @"9"})
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypeAll)
            .cacheStrategy(ALCacheStrategyMemoryCache);
            globalReqeust.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                resp = response;
            };
            [[expectFutureValue([[ALNetworkCache defaultManager] responseForRequestUrl:globalReqeust.req_urlStr params:globalReqeust.req_params]) shouldEventuallyBeforeTimingOutAfter(10)] beNonNil];
        });
    });
    
    context(@"Response Type", ^{
        
        beforeEach(^{
            ALNetworkingConfig *config = [ALNetworkingConfig defaultConfig];
            config.defaultPrefixUrl = @"https://www.baidu.com";
            networking.ignoreDefaultHeader = YES;
            networking.ignoreDefaultParams = YES;
            networking.defaultHeader = nil;
            networking.defaultParams = nil;
            networking.defaultParamsMethod = ALNetworkingCommonParamsMethodFollowMethod;
            networking.configParamsMethod = ALNetworkingCommonParamsMethodFollowMethod;
        });
        
        it(@"Respoonse Type HTML", ^{
            
            __block NSString *result = nil;
            
            globalReqeust = networking.request;
            
            globalReqeust
            .get(@"/s")
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypeAll)
            .responseType(ALNetworkResponseTypeHTTP);
            globalReqeust.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                result = [[NSString alloc] initWithData:response.rawData encoding:4];
                NSLog(@"result = \n%@",result);
            };
            [[expectFutureValue(result) shouldEventuallyBeforeTimingOutAfter(10)] containString:@"<html>"];
            [[expectFutureValue(theValue(result.length)) shouldEventuallyBeforeTimingOutAfter(10)] beGreaterThan:theValue(0)];
        });
    });
});
SPEC_END
