//
//  ALNetworkResponse.h
//  BaZiPaiPanSDK
//
//  Created by Arclin on 2018/4/21.
//

#import <Foundation/Foundation.h>

@interface ALNetworkResponse : NSObject<NSCoding,NSMutableCopying>

/** 原始数据 */
@property (nonatomic, strong) id rawData;

/** 是否是取缓存的响应 */
@property (nonatomic, assign) BOOL isCache;

@end
