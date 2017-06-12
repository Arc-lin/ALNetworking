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

/** Singleton */
+ (instancetype)defaultManager;

/**
 Save to disk cache

 @param object ALNetworkingResponse
 @param url url
 @param params Parameters
 */
- (void)setObject:(id<NSCoding>)object forRequestUrl:(NSString *)url params:(NSDictionary *)params;


/**
 Get from disk cache

 @param url API address
 @param params Parameters
 @return Response body
 */
- (ALNetworkingResponse *)responseForRequestUrl:(NSString *)url params:(NSDictionary *)params;


/**
 Clear the caches
 */
- (void)removeAllObjects;


/** YYCache */
@property (nonatomic,strong) YYCache *cache;


@end
