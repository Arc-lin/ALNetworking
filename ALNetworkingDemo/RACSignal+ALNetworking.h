//
//  RACSignal+ALNetworking.h
//  DragonStar
//
//  Created by Arclin on 2017/4/21.
//  Copyright © 2017年 dankal. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RACSignal (ALNetworking)

/**
 映射成为一个模型数组
 */
- (RACSignal *(^)(Class))mapWithArrayOfClass;

/**
 映射成为一个1或0的NSNumber对象
 */
- (RACSignal *(^)())mapWithBoolNumber;

/**
 映射成为一个对象
 */
- (RACSignal *(^)(Class))mapWithObject;

/**
 映射成为一个对象,另外你可以拿到对象后做其他事情

 @param clazz 类
 @param other 其他事情
 @return 信号
 */
- (RACSignal *)mapWithObject:(Class)clazz otherThings:(void(^)(id obj))other;

@end
