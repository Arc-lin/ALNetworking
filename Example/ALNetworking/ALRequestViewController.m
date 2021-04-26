//
//  ALRequestViewController.m
//  ALNetworking_Example
//
//  Created by apple on 2021/4/25.
//

#import "ALRequestViewController.h"
#import <ALNetworking.h>

@interface ALRequestViewController ()

@property(nonatomic,strong) ALNetworking *networking;

@property(nonatomic,strong, readonly) ALNetworkRequest *networkRequest;

@end

@implementation ALRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.networkRequest
    .get(@"/new/wbtop")
//    .header(@{@"priority_header" : @"innerHeader"})
//    .params(@{@"priority_params" : @"innerParams"})
    .executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
        NSLog(@"URL:%@\nHEADER:%@\nPARAMS:%@\nResult:\n%@ \n Error : %@",request.req_urlStr,request.req_header,request.req_params,response.rawData,error);
    };
    
}

- (ALNetworkRequest *)networkRequest {
    return self.networking.request;
}

- (ALNetworking *)networking {
    if (!_networking) {
        _networking = [[ALNetworking alloc] init];
        _networking.prefixUrl = @"https://v2.alapi.cn/api";
        _networking.defaultHeader = @{
            @"test_private_header" : @"private_header",
//            @"priority_header" : @"privateHeader"
        };
        _networking.defaultParams = @{
            @"test_private_params" : @"private_params",
//            @"priority_params" : @"privateParams"
        };
        _networking.handleRequest = ^ALNetworkRequest *(ALNetworkRequest *request) {
            if ([request.req_customProperty.allKeys containsObject:@"customKey"]) {
                NSString *object = (NSString *)[request.req_customProperty objectForKey:@"customKey"];
                BOOL blockRequest = [object boolValue];
                if (blockRequest) {
                    return nil;
                }
            }
            return request;
        };
        _networking.handleError = ^(ALNetworkRequest *request, ALNetworkResponse *response, NSError *error) {
            NSLog(@"handleError : %@",error);
        };
        _networking.handleResponse = ^NSError *(ALNetworkResponse *response, ALNetworkRequest *request) {
            NSDictionary *rawData = response.rawData;
            if ([rawData.allKeys containsObject:@"code"]) {
                NSInteger code = [rawData[@"code"] integerValue];
                if (code == 200) {
                    NSLog(@"Code 200 ： %@",response);
                } else {
                    NSLog(@"Code Error : %@",response.rawData);
                    return [NSError errorWithDomain:@"mydomain" code:-999 userInfo:@{NSLocalizedDescriptionKey:response.rawData[@"msg"]?:@""}];
                }
            }
            return nil;
        };
        __block NSInteger headerVisitTimes = 0;
        __block NSInteger paramsVisitTimes = 0;
        _networking.dynamicHeaderConfig = ^NSDictionary *(ALNetworkRequest *request) {
            return @{
                @"private_header_times" : @(headerVisitTimes++).stringValue,
                @"priority_header": @"privateDynamicHeader",
            };
        };
        _networking.dynamicParamsConfig = ^NSDictionary *(ALNetworkRequest *request) {
            return @{
                @"private_params_times" : @(paramsVisitTimes++).stringValue,
                @"priority_params" : @"privateDynamicParams"
            };
        };
        _networking.ignoreDefaultHeader = YES;
        _networking.ignoreDefaultParams = YES;
        _networking.configParamsMethod = ALNetworkingCommonParamsMethodFollowMethod;
        _networking.defaultParamsMethod = ALNetworkingCommonParamsMethodFollowMethod;
        
    }
    return _networking;
}

@end
