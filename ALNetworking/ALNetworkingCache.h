//
//  ALNetworkingCache.h
//  ALNetworkingDemo
//
//  Created by Arclin on 17/2/28.
//  Copyright © 2017年 dankal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYCache,ALNetworkingResponse;

@interface ALNetworkingCache : NSObject

/** 单例方法 */
+ (instancetype)defaultManager;

/**
 存缓存

 @param object ALNetworkingResponse
 @param url url
 @param params 请求参数
 */
- (void)setObject:(id<NSCoding>)object forRequestUrl:(NSString *)url params:(NSDictionary *)params;


/**
 取缓存

 @param url 请求的API地址
 @param params 请求的参数
 @return 返回响应体
 */
- (ALNetworkingResponse *)responseForRequestUrl:(NSString *)url params:(NSDictionary *)params;


/**
 清空缓存
 */
- (void)removeAllObjects;


/** YYCache */
@property (nonatomic,strong) YYCache *cache;


@end
