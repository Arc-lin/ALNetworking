//
//  MMCNetworkingConfig.m
//  MMCNetworkingDemo
//
//  Created by Arclin on 2018/4/28.
//

#import "ALNetworkingConfig.h"
#import "ALNetworkCache.h"
#import <AFNetworking/AFNetworking.h>

@implementation ALNetworkingConfig

static ALNetworkingConfig *_instance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)defaultConfig {
    if (!_instance) {
        _instance = [[self alloc] init];
        _instance.distinguishError = YES;
    }
    return _instance;
}

- (void)setParams:(NSDictionary *)params responseObj:(id)responseObj forUrl:(NSString *)url {
    [[ALNetworkCache defaultManager] setObject:responseObj forRequestUrl:url params:params memoryOnly:NO];
}

@end
