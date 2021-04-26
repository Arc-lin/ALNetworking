//
//  MMCNetworkCache.h
//  ALNetworking
//
//  Created by Arclin on 2018/4/21.
//

#import <Foundation/Foundation.h>

@class YYCache,ALNetworkResponse;

@interface ALNetworkCache : NSObject

/** Singleton */
+ (instancetype)defaultManager;

/**
 Save to disk cache
 
 @param object id<NSCoding,NSCopying>
 @param url url
 @param params Parameters
 */
- (void)setObject:(id<NSCoding>)object forRequestUrl:(NSString *)url params:(NSDictionary *)params memoryOnly:(BOOL)memoryOnly;


/**
 生成数据库的key

 @param url URL地址
 @param params 参数
 @return Key
 */
- (NSString *)keyForUrl:(NSString *)url params:(NSDictionary *)params;

/**
 Get from disk cache
 
 @param url API address
 @param params Parameters
 @return Response body
 */
- (ALNetworkResponse *)responseForRequestUrl:(NSString *)url params:(NSDictionary *)params;


/**
 Clear the caches
 */
- (void)removeAllObjects;

/// 清除指定内存和磁盘的缓存
/// @param url URL
/// @param params 参数
- (void)removeCacheWithUrl:(NSString *)url params:(NSDictionary *)params;

@end
