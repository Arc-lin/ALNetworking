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

SPEC_BEGIN(Tests)
describe(@"ALNetworking Test", ^{
    context(@"This Test is for cache strategy", ^{
    __block ALNetworking *networking;
    __block NSString *page = @"2";
    __block NSString *size = @"20";
        beforeEach(^{
            // 初始化配置
            // 通用、全局配置
            ALNetworkingConfig *config = [ALNetworkingConfig defaultConfig];
            config.defaultPrefixUrl = @"https://v2.alapi.cn";
            config.timeoutInterval = 10;
            config.defaultCacheStrategy = ALCacheStrategyAutomatic;
            config.distinguishError = YES;
            config.defaultHeader = @{
                @"test_config_header" : @"config_header",
                @"priority_header" : @"configHeader"
            };
            config.defaultParams = @{
                @"test_config_params" : @"config_params",
                @"priority_params" : @"configParams",
            };
            __block NSInteger headerVisitTimes = 0;
            __block NSInteger paramsVisitTimes = 0;
            config.dynamicHeaderConfig = ^NSDictionary *(ALNetworkRequest *request) {
                return @{
                    @"config_header_times" : @(headerVisitTimes++).stringValue,
                    @"priority_header": @"configDynamicHeader",
                };
            };
            config.dynamicParamsConfig = ^NSDictionary *(ALNetworkRequest *request) {
                return @{
                    @"config_params_times" : @(paramsVisitTimes++).stringValue,
                    @"priority_params": @"configDynamicParams",
                };
            };
            [[ALNetworkCache defaultManager] removeAllObjects];
            
            networking = [[ALNetworking alloc] init];
        });
        afterEach(^{
            networking = nil;
        });
        it(@"The Networking", ^{
            [[networking should] beNonNil];
        });
        it(@"Test default Cache", ^{
            __block id rawData = nil;
            __block long paramsCount;
            networking.get(@"https://tcc.taobao.com/cc/json/mobile_tel_segment.htm").name(@"请求1").params(@{@"tel":@"15919758637"}).responseType(ALNetworkResponseTypeHTTP).executeRequest = ^void(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                rawData = response.rawData;
                paramsCount = request.params.allKeys.count;
            };
            [[expectFutureValue(rawData) shouldEventually] beNonNil]; // 结果不为空
            [[theValue(paramsCount) shouldEventually] equal:theValue(3)]; // 请求参数3个
        });
        it(@"Test ALCacheStrategyCacheAndNetwork", ^{
            __block id rawData = nil;
            __block BOOL isCache;
            networking.get(@"http://ip.taobao.com/service/getIpInfo.php?ip=63.223.108.42").name(@"先缓存后网络并且网络不回调1").cacheStrategy(ALCacheStrategyCacheAndNetwork).executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                rawData = response.rawData;
                isCache = response.isCache;
            };
            [[expectFutureValue(rawData) shouldEventually] beNil];
            [[theValue(isCache) shouldEventually] beNo];
        });
        it(@"Test ALCacheStrategyMemonryCache", ^{
            __block id rawData = nil;
            __block BOOL isCache;
            networking.get(@"http://ip.taobao.com/service/getIpInfo.php?ip=101.20.165.229").name(@"内存缓存").cacheStrategy(ALCacheStrategyMemoryCache).executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                rawData = response.rawData;
                isCache = response.isCache;
                __block id rawDataAfter = nil;
                __block BOOL isCacheAfter;
                networking.get(@"http://ip.taobao.com/service/getIpInfo.php?ip=101.20.165.229").name(@"内存缓存2").cacheStrategy(ALCacheStrategyMemoryCache).executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                    rawDataAfter = response.rawData;
                    isCacheAfter = response.isCache;
                };
                [[expectFutureValue(rawDataAfter) shouldEventually] beNil];
                [[theValue(isCacheAfter) shouldEventually] beYes];
            };
            [[expectFutureValue(rawData) shouldEventually] beNil];
            [[theValue(isCache) shouldEventually] beNo];
        });
    
        it(@"Test Prefix", ^{
            __block id url = nil;
            networking.prefixUrl = @"https://www.v2ex.com/";
            networking.get(@"/api/topics/hot.json").executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                url = request.urlStr;
            };
            [[expectFutureValue(url) shouldEventually] equal:@"https://www.v2ex.com/api/topics/hot.json"];
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
