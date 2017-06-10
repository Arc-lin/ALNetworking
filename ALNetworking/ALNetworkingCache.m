//
//  ALNetworkingCache.m
//  ALNetworkingDemo
//
//  Created by Arclin on 17/2/28.
//  Copyright © 2017年 dankal. All rights reserved.
//

#import "ALNetworkingCache.h"
#import "ALNetworkingResponse.h"
#import <YYCache/YYCache.h>

#define KCACHENAME @"alnetworking"

@implementation ALNetworkingCache

static ALNetworkingCache *_manager;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

+ (instancetype)defaultManager
{
    if (_manager == nil) {
        _manager = [[ALNetworkingCache alloc] init];
    }
    return _manager;
}

- (void)setObject:(id<NSCoding>)object forRequestUrl:(NSString *)url params:(NSDictionary *)params
{
    // 生成Key
    NSString *key = [self base64:[NSString stringWithFormat:@"%@?%@",url,[self dic2Params:params]]];
    [self.cache setObject:object forKey:key];
}

- (ALNetworkingResponse *)responseForRequestUrl:(NSString *)url params:(NSDictionary *)params
{
    // 生成Key
    NSString *key = [self base64:[NSString stringWithFormat:@"%@?%@",url,[self dic2Params:params]]];
    return (ALNetworkingResponse *)[self.cache objectForKey:key];
}

- (void)removeAllObjects
{
    return [self.cache removeAllObjects];
}

// 编码base64
- (NSString *)base64:(NSString *)rawString
{
    NSData   *data          = [rawString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Endcode = [data base64EncodedStringWithOptions:0];
    return base64Endcode;
}

// 解码base64
- (NSString *)encodeBase64:(NSString *)base64Str
{
    // 解码base64
    NSData   *data            = [[NSData alloc] initWithBase64EncodedString:base64Str options:0];
    NSString *base64DecodeStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return base64DecodeStr;
}

// 字典转参数字符串
- (NSString *)dic2Params:(NSDictionary *)paramsDic
{
    if(!paramsDic) return @"";
    
    NSMutableString *paramsStr = [NSMutableString string];
    
    // 遍历字典
    NSArray *keys = paramsDic.allKeys;
    
    for (NSInteger i = 0 ; i < keys.count ; i++) {
        
        NSString *symbol = @"";
        if(i != 0) {
            symbol = @"&";
        }
        [paramsStr appendFormat:@"%@%@=%@",symbol,keys[i],paramsDic[keys[i]]];
    }
         
    return paramsStr;
}

- (YYCache *)cache
{
    if(!_cache) {
        _cache = [YYCache cacheWithName:KCACHENAME];
    }
    return _cache;
}

@end
