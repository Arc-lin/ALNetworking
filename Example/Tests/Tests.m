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
    __block ALNetworkRequest *globalRequest;
    
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
        /// 默认的缓存机制，默认不缓存
        config.defaultCacheStrategy = ALCacheStrategyNetworkOnly;
        /// 是否要区分业务错误和网络错误，默认为true，具体内容看注释
        config.distinguishError = YES;
        /// 全局的默认请求头
        config.defaultHeader = @{
            @"test_config_header" : @"config_header",
            @"priority_header" : @"configHeader"
        };
        /// 全局的参数
        config.defaultParams = @{
            @"test_config_params" : @"config_params",
            @"priority_params" : @"configParams",
        };
        /// 动态请求头，每次请求都会执行一次这个block，然后把返回值拼接到请求头中，一般用于请求加密添加Authorization参数
        config.dynamicHeaderConfig = ^NSDictionary *(ALNetworkRequest *request) {
            return @{
                @"config_header_times" : @(++headerVisitTimes_config).stringValue,
                @"priority_header": @"configDynamicHeader",
            };
        };
        /// 动态请求参数，每次请求都会执行一次这个block，然后把返回值拼接到请求参数中
        config.dynamicParamsConfig = ^NSDictionary *(ALNetworkRequest *request) {
            return @{
                @"config_params_times" : @(++paramsVisitTimes_config).stringValue,
                @"priority_params": @"configDynamicParams",
            };
        };
        
        networking = [[ALNetworking alloc] init];
        /// 配置接口请求链接的前缀，优先级比ALNetworkingConfig高
        networking.prefixUrl = @"https://v1.alapi.cn/api";
        /// 默认请求头，优先级比ALNetworkingConfig高
        networking.defaultHeader = @{
            @"test_private_header" : @"private_header",
            @"priority_header" : @"privateHeader"
        };
        /// 默认请求参数，优先级比ALNetworkingConfig高
        networking.defaultParams = @{
            @"test_private_params" : @"private_params",
            @"priority_params" : @"privateParams"
        };
        /// 决定了ALNetworkingConfig内配置的公共参数，是否要以query string的方式拼接到接口链接上，默认为否
        networking.configParamsMethod = ALNetworkingCommonParamsMethodFollowMethod;
        /// 决定了networking对象配置的公共参数，是否要以query string的方式拼接到接口链接上，默认为否
        networking.defaultParamsMethod = ALNetworkingCommonParamsMethodFollowMethod;
        /// 动态请求头，每次请求都会执行一次这个block，然后把返回值拼接到请求头中
        networking.dynamicHeaderConfig = ^NSDictionary *(ALNetworkRequest *request) {
            return @{
                @"private_header_times" : @(++headerVisitTimes_private).stringValue,
                @"priority_header": @"privateDynamicHeader",
            };
        };
        /// 动态请求参数，每次请求都会执行一次这个block，然后把返回值拼接到请求参数中
        networking.dynamicParamsConfig = ^NSDictionary *(ALNetworkRequest *request) {
            return @{
                @"private_params_times" : @(++paramsVisitTimes_private).stringValue,
                @"priority_params" : @"privateDynamicParams"
            };
        };
        /// 是否要忽略ALNetworkingConfig内配置的公共请求头
        networking.ignoreDefaultHeader = NO;
        /// 是否要忽略ALNetworkingConfig内配置的公共请求参数
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
            globalRequest = networking.request;
            [[globalRequest should] beNonNil];
            [[globalRequest.req_header should] equal:@{
                @"test_config_header" : @"config_header",
                @"test_private_header" : @"private_header",
                @"priority_header": @"privateHeader",
            }];
            [[globalRequest.req_params should] equal:@{
                @"test_config_params" : @"config_params",
                @"test_private_params" : @"private_params",
                @"priority_params" : @"privateParams"
            }];
        });
        
        it(@"Without Default Header", ^{
            networking.ignoreDefaultHeader = YES;
            globalRequest = networking.request;
            [[globalRequest.req_header should] equal:@{
                @"test_private_header" : @"private_header",
                @"priority_header": @"privateHeader",
            }];
        });
        
        it(@"Without Default Params", ^{
            networking.ignoreDefaultParams = YES;
            globalRequest = networking.request;
            [[globalRequest.req_params should] equal:@{
                @"test_private_params" : @"private_params",
                @"priority_params" : @"privateParams"
            }];
            //            [[theValue(networking.requestDictionary.allKeys.count) should] equal:theValue(0)];
        });
        
        it(@"With Dynamic Header And Dynamic Parameters", ^{
            networking.ignoreDefaultHeader = NO;
            /// Config的公共参数不忽略
            networking.ignoreDefaultParams = YES;
            globalRequest = networking.request;
            globalRequest
            .get(@"/new/wbtop")
            .header(@{@"priority_header" : @"innerHeader"})
            .params(@{@"priority_params" : @"innerParams"})
            .executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                
            };
            [[globalRequest.req_header should] equal:@{
                @"test_config_header" : @"config_header",
                @"config_header_times" : @"1",
                @"test_private_header" : @"private_header",
                @"private_header_times" : @"1",
                @"priority_header" : @"innerHeader"
            }];
            [[globalRequest.req_params should] equal:@{
                @"config_params_times" : @"1",
                @"test_private_params" : @"private_params",
                @"private_params_times" : @"1",
                @"priority_params" : @"innerParams"
            }];
        });
        
        xit(@"Ignore dynamic header or dynamic params in chain", ^{
            networking.ignoreDefaultHeader = NO;
            networking.ignoreDefaultParams = NO;
            globalRequest = networking.request;
            globalRequest
            .get(@"/new/wbtop")
            .header(@{@"priority_header" : @"innerHeader"})
            .params(@{@"priority_params" : @"innerParams"})
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypePrivate)
            .executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                
            };
            [[globalRequest.req_header should] equal:@{
                @"test_config_header" : @"config_header",
                @"test_private_header" : @"private_header",
                @"priority_header" : @"innerHeader"
            }];
            [[globalRequest.req_params should] equal:@{
                @"config_params_times" : @"2",
                @"test_config_params" : @"config_params",
                @"test_private_params" : @"private_params",
                @"priority_params" : @"innerParams"
            }];
        });
    });
    
    context(@"Data", ^{
        
        it(@"Mock Data", ^{
            globalRequest = networking.request;
            __block ALNetworkResponse *myResp = nil;
            globalRequest
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
            globalRequest = networking.request;
            [[globalRequest should] beNil];
        });
        
        it(@"Perfix Url", ^{
            networking.prefixUrl = @"https://v1.alapi.cn";
            globalRequest = networking.request;
            
            globalRequest.get(@"/new/wbtop");
            [[globalRequest.req_urlStr should] equal:@"https://v1.alapi.cn/new/wbtop"];
            
            globalRequest.get(@"https://v3.alapi.cn/new/wbtop");
            [[globalRequest.req_urlStr should] equal:@"https://v3.alapi.cn/new/wbtop"];
            
        });
        
        it(@"Method Type Change URL", ^{
            networking.prefixUrl = nil;
            networking.ignoreDefaultParams = NO;
            networking.configParamsMethod = ALNetworkingCommonParamsMethodQS;
            networking.defaultParamsMethod = ALNetworkingCommonParamsMethodQS;
            
            globalRequest = networking.request;
            globalRequest.post(@"/new/wbtop").params(@{@"innerParams":@"testInnerParams"});
            NSURL *url = [NSURL URLWithString:globalRequest.req_urlStr];
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
            
            [[globalRequest.req_params should] equal:@{
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
            networking.handleRequest = ^ALNetworkRequest *(ALNetworkRequest *request) {
                return request;
            };
            networking.handleError = ^(ALNetworkRequest *request, ALNetworkResponse *response, NSError *error) {
                
            };
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
            
            globalRequest = networking.request;
            globalRequest.get(@"/new/wbtop").params(@{@"num" : @"3"})
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
            [[expectFutureValue([[ALNetworkCache defaultManager] responseForRequestUrl:globalRequest.req_urlStr params:globalRequest.req_params]) shouldEventuallyBeforeTimingOutAfter(10)] beNil];
        });
        
        xit(@"Cache Only At First Time", ^{
            __block ALNetworkResponse *resp = nil;
            __block id result = nil;
            
            globalRequest = networking.request;
            
            globalRequest
            .get(@"/new/wbtop")
            .params(@{@"num" : @"10"})
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypeAll)
            .cacheStrategy(ALCacheStrategyCacheOnly);
            //            __weak typeof(globalRequest) weakglobalRequest = globalRequest;
            globalRequest.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                if(!error) {
                    resp = response;
                    result = response.rawData;
                    
                    //                    weakglobalRequest.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
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
            [[expectFutureValue([[ALNetworkCache defaultManager] responseForRequestUrl:globalRequest.req_urlStr params:globalRequest.req_params]) shouldEventuallyBeforeTimingOutAfter(10)] beNonNil];
        });
        
        xit(@"Cache Then Network", ^{
            __block ALNetworkResponse *resp = nil;
            __block id result = nil;
            /// 回调访问次数
            __block NSInteger times = 0;
            
            globalRequest = networking.request;
            
            globalRequest
            .get(@"/new/wbtop")
            .params(@{@"num" : @"6"})
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypeAll)
            .cacheStrategy(ALCacheStrategyCacheThenNetwork);
            globalRequest.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
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
            [[expectFutureValue([[ALNetworkCache defaultManager] responseForRequestUrl:globalRequest.req_urlStr params:globalRequest.req_params]) shouldEventuallyBeforeTimingOutAfter(10)] beNonNil];
        });
        
        xit(@"Cache Automatic", ^{
            
            __block ALNetworkResponse *resp = nil;
            /// 回调访问次数
            
            globalRequest = networking.request;
            
            globalRequest
            .get(@"/new/wbtop")
            .params(@{@"num" : @"7"})
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypeAll)
            .cacheStrategy(ALCacheStrategyAutomatic);
            
            globalRequest.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                resp = response;
            };
            
            [[expectFutureValue(theValue([ALAPIClient sharedInstance].networkStatus)) shouldEventually] equal:theValue(AFNetworkReachabilityStatusReachableViaWiFi)];
            
//            [[expectFutureValue(theValue(resp.isCache)) shouldEventuallyBeforeTimingOutAfter(10)] beYes];
            
            [[expectFutureValue(theValue(resp.isCache)) shouldEventuallyBeforeTimingOutAfter(10)] beNo];
            /// 讲道理应该有缓存
            [[expectFutureValue([[ALNetworkCache defaultManager] responseForRequestUrl:globalRequest.req_urlStr params:globalRequest.req_params]) shouldEventuallyBeforeTimingOutAfter(10)] beNonNil];
        });
        
        xit(@"Cache And Network", ^{
            __block ALNetworkResponse *resp = nil;
            /// 回调访问次数
            __block NSInteger times = 0;
            
            globalRequest = networking.request;
            
            globalRequest
            .get(@"/new/wbtop")
            .params(@{@"num" : @"8"})
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypeAll)
            .cacheStrategy(ALCacheStrategyCacheAndNetwork);
            globalRequest.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                resp = response;
                times++;
            };
            [[expectFutureValue(theValue(times)) shouldEventuallyBeforeTimingOutAfter(10)] equal:theValue(1)];
            /// 讲道理应该有缓存
            [[expectFutureValue([[ALNetworkCache defaultManager] responseForRequestUrl:globalRequest.req_urlStr params:globalRequest.req_params]) shouldEventuallyBeforeTimingOutAfter(10)] beNonNil];
        });
        
        xit(@"Memory Cache", ^{
            __block ALNetworkResponse *resp = nil;
            
            globalRequest = networking.request;
            
            globalRequest
            .get(@"/new/wbtop")
            .params(@{@"num" : @"9"})
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypeAll)
            .cacheStrategy(ALCacheStrategyMemoryCache);
            globalRequest.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                resp = response;
            };
            [[expectFutureValue([[ALNetworkCache defaultManager] responseForRequestUrl:globalRequest.req_urlStr params:globalRequest.req_params]) shouldEventuallyBeforeTimingOutAfter(10)] beNonNil];
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
        
        xit(@"Respoonse Type HTML", ^{
            
            __block NSString *result = nil;
            
            globalRequest = networking.request;
            
            globalRequest
            .get(@"/s")
            .disableDynamicHeader(ALNetworkingConfigTypeAll)
            .disableDynamicParams(ALNetworkingConfigTypeAll)
            .responseType(ALNetworkResponseTypeHTTP);
            globalRequest.executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                result = [[NSString alloc] initWithData:response.rawData encoding:4];
                NSLog(@"result = \n%@",result);
            };
            [[expectFutureValue(result) shouldEventuallyBeforeTimingOutAfter(10)] beKindOfClass:NSString.class];
            [[expectFutureValue(result) shouldEventuallyBeforeTimingOutAfter(10)] containString:@"<html>"];
            [[expectFutureValue(theValue(result.length)) shouldEventuallyBeforeTimingOutAfter(10)] beGreaterThan:theValue(0)];
        });
        
        xit(@"Response Type Image", ^{
            __block id result = nil;
            
            globalRequest = networking.request;
            
            globalRequest
            .get(@"https://www.baidu.com/img/PCtm_d9c8750bed0b3c7d089fa7d55720d6cf.png")
            .responseType(ALNetworkResponseTypeImage)
            .executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                result = response.rawData;
            };
            [[expectFutureValue(result) shouldEventuallyBeforeTimingOutAfter(10)] beKindOfClass:UIImage.class];
        });
    });
    
    context(@"Upload", ^{
        xit(@"Upload Image", ^{
            __block id result = nil;
            __block id imageUrl = nil;
            NSString *fileName = [NSUUID UUID].UUIDString;
            NSData *data = UIImagePNGRepresentation([UIImage imageNamed:@"40icon_friends"]);
            globalRequest = networking.request;
            globalRequest
            .post(@"https://sm.ms/api/v2/upload")
            .header(@{@"Authorization" : @"申请个key"})
            .params(@{@"format":@"json"})
            .fileFieldName(@"smfile")
            .uploadData(data,fileName,@"image/png")
            .executeUploadRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response.rawData options:NSJSONReadingMutableContainers error:nil];
                result = dic[@"code"];
                imageUrl = dic[@"url"];
                NSLog(@"%@",imageUrl);
            };
            [[expectFutureValue(result) shouldEventuallyBeforeTimingOutAfter(10)] equal:@"image_repeated"];
            [[expectFutureValue(imageUrl) shouldEventuallyBeforeTimingOutAfter(10)] beNonNil];
        });
        
        xit(@"Cancel Upload", ^{
            __block id result = nil;
            NSString *fileName = [NSUUID UUID].UUIDString;
            NSData *data = UIImagePNGRepresentation([UIImage imageNamed:@"40icon_friends"]);
            globalRequest = networking.request;
            globalRequest
            .post(@"https://sm.ms/api/v2/upload")
            .header(@{@"Authorization" : @"申请个key"})
            .params(@{@"format":@"json"})
            .fileFieldName(@"smfile")
            .uploadData(data,fileName,@"image/png")
            .executeUploadRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
                if (response) {
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response.rawData options:NSJSONReadingMutableContainers error:nil];
                    result = dic[@"code"];
                }
            };
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [networking cancelAllRequest];
            });
            [[expectFutureValue(result) shouldEventuallyBeforeTimingOutAfter(10)] beNil];
        });
        
    });
    
    context(@"Download", ^{
        
        xit(@"Download", ^{
            __block id result = nil;
            NSString *filePath = [[NSString alloc] initWithString:NSHomeDirectory()];
            filePath = [filePath stringByAppendingPathComponent:@"Documents"];
            globalRequest = networking.request;
            globalRequest
            .downloadDestPath(filePath)
            .responseType(ALNetworkResponseTypeImage)
            .get(@"https://images.pexels.com/photos/2179064/pexels-photo-2179064.jpeg?cs=srgb&dl=pexels-darwis-alwan-2179064.jpg&fm=jpg")
            .executeDownloadRequest = ^(NSString *destination, ALNetworkRequest *request, NSError *error) {
                result = destination;
                NSLog(@"Path --- %@",result);
            };
            [[expectFutureValue(theValue([[NSFileManager defaultManager] fileExistsAtPath:result])) shouldEventuallyBeforeTimingOutAfter(10)] beYes];
        });
        
        xit(@"Cancel Download", ^{
            __block id result = nil;
            NSString *filePath = [[NSString alloc] initWithString:NSHomeDirectory()];
            filePath = [filePath stringByAppendingPathComponent:@"Documents"];
            globalRequest = networking.request;
            globalRequest
            .downloadDestPath(filePath)
            .responseType(ALNetworkResponseTypeImage)
            .get(@"https://images.pexels.com/photos/2179064/pexels-photo-2179064.jpeg?cs=srgb&dl=pexels-darwis-alwan-2179064.jpg&fm=jpg")
            .executeDownloadRequest = ^(NSString *destination, ALNetworkRequest *request, NSError *error) {
                result = destination;
                NSLog(@"Path --- %@",result);
            };
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [networking cancelAllRequest];
            });
            [[expectFutureValue(theValue([[NSFileManager defaultManager] fileExistsAtPath:result])) shouldEventuallyBeforeTimingOutAfter(10)] beNo];
        });
        
    });
    
    
    
});
SPEC_END
