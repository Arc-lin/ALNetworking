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
@property (nonatomic, strong) id rawData;

/** 网络异常错误 */
@property (nonatomic, strong) NSError *error;

@end
