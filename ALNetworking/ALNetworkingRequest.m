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
                return @"只从网络取数据(不缓存)";
                break;
            case ALCacheStrategy_CACHE_ONLY:
                return @"只从本地取数据";
                break;
            case ALCacheStrategy_NETWORK_AND_CACHE:
                return @"从网络取数据后缓存";
                break;
            case ALCacheStrategy_CACHE_ELSE_NETWORK:
                return @"先取缓存,如果没有数据的话,才从网络取数据";
                break;
            case ALCacheStrategy_CACHE_THEN_NETWORK:
                return @"先取缓存,再加载网络数据";
                break;
            case ALCacheStrategy_AUTOMATICALLY:
                return @"根据网络状况自动选择,有网选择网络数据,无网选择本地数据";
                break;
        }
    }
    return @"只从网络取数据(不缓存)";
}

@end
