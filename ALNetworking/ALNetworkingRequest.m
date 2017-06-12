//
//  ALNetworkingRequest.m
//  ALNetworkingDemo
//
//  Created by Arclin on 2017/6/3.
//  Copyright © 2017年 arclin. All rights reserved.
//

#import "ALNetworkingRequest.h"

@implementation ALNetworkingRequest

- (NSString *)urlStr
{
    if(!_urlStr || _urlStr.length == 0) {
        NSException *exception = [NSException exceptionWithName:@"Fatal" reason:@"URL string could not be nil or empty string" userInfo:nil];
        [exception raise];
    }
    return _urlStr;
}

- (NSString *)paramsTypeStr
{
    if (self.paramsType) {
        if (self.paramsType == ALNetworkRequestParamsTypeJSON) {
            return @"JSON";
        }
        return @"Dictionary";
    }
    return @"Dictionary";
}

- (NSString *)methodStr
{
    if (self.method) {
        switch (self.method) {
            case ALNetworkRequestMethodGET:
                return @"GET";
                break;
            case ALNetworkRequestMethodPOST:
                return @"POST";
                break;
            case ALNetworkRequestMethodPATCH:
                return @"PATCH";
                break;
            case ALNetworkRequestMethodDELETE:
                return @"DELETE";
                break;
            case ALNetworkRequestMethodPUT:
                return @"PUT";
                break;
            default:
                break;
        }
    }
    return @"GET";
}

- (NSString *)strategyStr
{
    if(self.cacheStrategy) {
        switch (self.cacheStrategy) {
            case ALCacheStrategy_NETWORK_ONLY:
                return @"ALCacheStrategy_NETWORK_ONLY";
                break;
            case ALCacheStrategy_CACHE_ONLY:
                return @"ALCacheStrategy_CACHE_ONLY";
                break;
            case ALCacheStrategy_NETWORK_AND_CACHE:
                return @"ALCacheStrategy_NETWORK_AND_CACHE";
                break;
            case ALCacheStrategy_CACHE_ELSE_NETWORK:
                return @"ALCacheStrategy_CACHE_ELSE_NETWORK";
                break;
            case ALCacheStrategy_CACHE_THEN_NETWORK:
                return @"ALCacheStrategy_CACHE_THEN_NETWORK";
                break;
            case ALCacheStrategy_AUTOMATICALLY:
                return @"ALCacheStrategy_AUTOMATICALLY";
                break;
        }
    }
    return @"ALCacheStrategy_NETWORK_ONLY";
}

@end
