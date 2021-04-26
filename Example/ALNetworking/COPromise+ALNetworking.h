//
//  COPromise+ALNetworking.h
//  ALNetworking_Example
//
//  Created by Arclin on 2019/12/16.
//
#import "COPromise.h"

NS_ASSUME_NONNULL_BEGIN

#define object_with(string,clazz) mapObjectWithSomething(string,[clazz class])

#define array_with(string,clazz)  mapArrayWithSomething(string,[clazz class])

@interface COPromise (ALNetworking)

- (COPromise *(^)(NSString *,Class))mapObjectWithSomething;

- (COPromise *(^)(NSString *,Class))mapArrayWithSomething;

@end

NS_ASSUME_NONNULL_END
