//
//  RACSignal+DKNetworking.h
//  DragonStar
//
//  Created by Arclin on 2017/4/21.
//  Copyright © 2017年 dankal. All rights reserved.
//

#import <ReactiveObjC/ReactiveObjC.h>

#define object_combine(string,clazz) combineObjectWithKey(string, [clazz class])

#define array_combine(string,clazz) combineArrayWithKey(string, [clazz class])

#define object_with(string,clazz) mapObjectWithSomething(string,[clazz class])

#define array_with(string,clazz)  mapArrayWithSomething(string,[clazz class])

typedef void(^ALNetworkReduceBlock)();

@interface RACSignal (ALNetworking)

/**
 映射成为一个模型数组
 */
- (RACSignal *(^)(Class))mapWithArrayOfClass;

/**
 把RawData映射出来

 @return 信号
 */
- (RACSignal *)mapWithRawData;

/**
 映射出RawData中的某个键中的值
 */
- (RACSignal *(^)(NSString *))mapWithSomething;

/** 
 映射出RawData中的某个键中的值并转成模型
 */
- (RACSignal *(^)(NSString *,Class))mapObjectWithSomething;

/**
 映射出RawData中的某个键中的值并转成数组
 */
- (RACSignal *(^)(NSString *,Class))mapArrayWithSomething;

/**
 合并出RawData中的某个键中的值并转成模型
 */
- (RACSignal<RACTuple *> *(^)(NSString *,Class))combineObjectWithKey;

/**
 合并出RawData中的某个键中的值并转成数组
 */
- (RACSignal<RACTuple *> *(^)(NSString *,Class))combineArrayWithKey;

/// 归纳
/// @param reduceBlock reduceBlock 
- (RACSignal *)reduceResult:(ALNetworkReduceBlock)reduceBlock;

@end
