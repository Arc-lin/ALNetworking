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
        [[ALNetworkCache defaultManager] removeAllObjects];
        
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
        
        it(@"Ignore dynamic header or dynamic params in chain", ^{
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
            globalReqeust = networking.request;
            
            networking.configParamsMethod = ALNetworkingCommonParamsMethodQS;
            networking.defaultParamsMethod = ALNetworkingCommonParamsMethodQS;
            globalReqeust.get(@"/new/wbtop");
            [[globalReqeust.req_urlStr should] equal:@"https://v2.alapi.cn/new/wbtop?test_config_params=config_params&test_private_params=private_params"];
        });
    });
    
    context(@"Cache", ^{
        beforeEach(^{
            ALNetworkingConfig *config = [ALNetworkingConfig defaultConfig];
            config.defaultPrefixUrl = @"https://v2.alapi.cn";
        });
        
        it(@"Perfix Url", ^{
            networking.prefixUrl = @"https://v1.alapi.cn";
            globalReqeust = networking.request;
            
            globalReqeust.get(@"/new/wbtop");
            [[globalReqeust.req_urlStr should] equal:@"https://v1.alapi.cn/new/wbtop"];
            
            globalReqeust.get(@"https://v3.alapi.cn/new/wbtop");
            [[globalReqeust.req_urlStr should] equal:@"https://v3.alapi.cn/new/wbtop"];
            
        });
    });
});
SPEC_END

//
//    networking.url(@"http://myip.ipip.net").name(@"请求2").params(@{@"test":self.page}).cacheStrategy(ALCacheStrategyCacheThenNetwork).responseType(ALNetworkResponseTypeHTTP).executeRequest = ^void(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
//        XCTAssertNotNil(response.rawData,@"结果不为空");
//    };
//
//    networking.get(@"http://ip.taobao.com/service/getIpInfo.php?ip=63.223.108.42").name(@"先缓存后网络并且网络不回调1").cacheStrategy(ALCacheStrategyCacheAndNetwork).executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
//        XCTAssert(response.isCache == YES, @"回调是缓存类型");
//        XCTAssertNil(response.rawData,@"第一次结果为空");
//    };
//
////    sleep(2);
//
//    networking.get(@"http://ip.taobao.com/service/getIpInfo.php?ip=63.223.108.42").name(@"先缓存后网络并且网络不回调2").cacheStrategy(ALCacheStrategyCacheAndNetwork).executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
//        XCTAssert(response.isCache == YES, @"缓存");
//        XCTAssertNotNil(response.rawData,@"第二次结果不为空");
//    };
//
//    networking.url(@"http://myip.ipip.net").name(@"请求3").params(@{@"test":self.page}).cacheStrategy(ALCacheStrategyCacheOnly).responseType(ALNetworkResponseTypeHTTP).executeRequest = ^void(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
//        XCTAssert(response.isCache == YES, @"回调是缓存类型");
//        XCTAssertNotNil(response.rawData,@"结果不为空");
//    };
//
//    networking.get(@"https://tcc.taobao.com/cc/json/mobile_tel_segment.htm").name(@"请求4").params(@{@"tel":@"15919758637"}).cacheStrategy(ALCacheStrategyCacheOnly).responseType(ALNetworkResponseTypeHTTP).executeRequest = ^void(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
//        XCTAssertNil(response.rawData,@"结果为空");
//    };
