//
//  ALNetworkResponse.h
//  ALA
//
//  Created by Arclin on 2017/3/24.
//  Copyright © 2017年 dankal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALNetworkingResponse : NSObject<NSCoding>

/** 原始数据 */
/** Raw Data, comes from AFNetworking directly */
@property (nonatomic, strong) id rawData;

/** 网络异常错误 */
/** Network error */
@property (nonatomic, strong) NSError *error;

/** 是否是取缓存的响应 */
/** If comes from cahce */
@property (nonatomic, assign) BOOL isCache;

@end
