//
//  MMCNetworkCache.m
//  ALNetworking
//
//  Created by Arclin on 2018/4/21.
//

#import "ALNetworkCache.h"
#import "ALNetworkResponse.h"

#import <YYCache/YYCache.h>

#define KCACHENAME @"alnetworking"

@interface ALNetworkCache()

@property (nonatomic,strong) YYCache *cache;

@end

@implementation ALNetworkCache

static ALNetworkCache *_manager;

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
        _manager = [[self alloc] init];
    }
    return _manager;
}

- (void)setObject:(id<NSCoding>)object forRequestUrl:(NSString *)url params:(NSDictionary *)params memoryOnly:(BOOL)memoryOnly
{
    // Generate Key
    NSString *key = [self keyForUrl:url params:params];
    [self.cache.memoryCache setObject:object forKey:key];
    if (!memoryOnly) {
        [self.cache.diskCache setObject:object forKey:key];
    }
}

- (NSString *)keyForUrl:(NSString *)url params:(NSDictionary *)params {
    return [self base64:[NSString stringWithFormat:@"%@?%@",url,[self dic2Params:params]]];
}

- (ALNetworkResponse *)responseForRequestUrl:(NSString *)url params:(NSDictionary *)params
{
    // Generate Key
    NSString *key = [self base64:[NSString stringWithFormat:@"%@?%@",url,[self dic2Params:params]]];
    if ([self.cache.memoryCache containsObjectForKey:key]) {
        id response = [self.cache.memoryCache objectForKey:key];
        ALNetworkResponse *resp;
        // 只处理字典、数组和字符串类型
        if ([response isKindOfClass:ALNetworkResponse.class]){
            resp = response;
        } else if ([response isKindOfClass:NSDictionary.class] || [response isKindOfClass:NSArray.class] || [response isKindOfClass:NSString.class]) {
            resp = [[ALNetworkResponse alloc] init];
            resp.rawData = response;
        }
        resp.isCache = YES;
        return resp;
    } else if ([self.cache.diskCache containsObjectForKey:key]) {
        ALNetworkResponse *response = [[ALNetworkResponse alloc] init];
        id object = [self.cache.diskCache objectForKey:key];
        if ([object isKindOfClass:ALNetworkResponse.class]) {
            response = object;
        } else {
            response.rawData = object;
        }
        response.isCache = YES;
        // 保存到内存中方便下次使用
        [self.cache.memoryCache setObject:object forKey:key];
        return response;
    } else {
        return nil;
    }
}

- (void)removeCacheWithUrl:(NSString *)url params:(NSDictionary *)params {
    // Generate Key
    NSString *key = [self base64:[NSString stringWithFormat:@"%@?%@",url,[self dic2Params:params]]];
    if ([self.cache.memoryCache containsObjectForKey:key]) {
        [self.cache.memoryCache removeObjectForKey:key];
    }
    if ([self.cache.diskCache containsObjectForKey:key]) {
        [self.cache.diskCache removeObjectForKey:key];
    }
}

- (void)removeAllObjects
{
    [self.cache.memoryCache removeAllObjects];
    [self.cache.diskCache removeAllObjects];
//    [self.cache.memoryCache setAgeLimit:1];
}

// base64 encode
- (NSString *)base64:(NSString *)rawString
{
    NSData   *data          = [rawString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Endcode = [data base64EncodedStringWithOptions:0];
    return base64Endcode;
}

// base64 decode
- (NSString *)encodeBase64:(NSString *)base64Str
{
    NSData   *data            = [[NSData alloc] initWithBase64EncodedString:base64Str options:0];
    NSString *base64DecodeStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return base64DecodeStr;
}

// Dictionary to parameters
- (NSString *)dic2Params:(NSDictionary *)paramsDic
{
    if(!paramsDic) return @"";
    
    NSMutableString *paramsStr = [NSMutableString string];
    
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
