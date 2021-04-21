//
//  MMCAPIClient.m
//  MMCNetworking
//
//  Created by Arclin on 2019/8/29.
//

#import "ALAPIClient.h"
#import "ALNetworkingConst.h"

@implementation ALAPIClient

+ (instancetype)sharedInstance
{
    static ALAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ALAPIClient alloc] initWithBaseURL:nil];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            _sharedClient.networkStatus = status;
            [[NSNotificationCenter defaultCenter] postNotificationName:kALNetworking_NetworkStatus object:nil userInfo:@{@"status":@(status)}];
        }];
    });
    
    return _sharedClient;
}

@end
