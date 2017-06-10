//
//  RACSignal+ALNetworking.m
//  DragonStar
//
//  Created by Arclin on 2017/4/21.
//  Copyright © 2017年 dankal. All rights reserved.
//

#import "RACSignal+ALNetworking.h"
#import "ALNetworking.h"

#import <YYModel/YYModel.h>

@implementation RACSignal (ALNetworking)

//- (RACSignal *(^)(Class))mapWithArrayOfClass
//{
//    return ^RACSignal *(Class clazz){
//        return [self map:^id(RACTuple *value) {
//            ALNetworkingResponse *response = value.second;
//            NSArray *arr = [clazz mj_objectArrayWithKeyValuesArray:response.result];
//            return arr;
//        }];
//    };
//}
//
//- (RACSignal *(^)())mapWithBoolNumber
//{
//    return ^RACSignal *{
//        return [self map:^id(RACTuple *value) {
//            ALNetworkingResponse *response = value.second;
//            return @([response.state isEqualToString:successCode]);
//        }];
//    };
//}
//
//- (RACSignal *(^)(Class))mapWithObject
//{
//    return ^RACSignal *(Class clazz){
//        return [self map:^id(RACTuple *value) {
//            ALNetworkingResponse *response = value.second;
//            if(!response.result[@"data"]) {
//                id obj = [clazz mj_objectWithKeyValues:response.result];
//                return obj;
//            }else {
//                id obj = [clazz mj_objectWithKeyValues:response.result[@"data"]];
//                return obj;
//            }
//        }];
//    };
//}
//
//- (RACSignal *)mapWithObject:(Class)clazz otherThings:(void(^)(id obj))other
//{
//    return [self map:^id(RACTuple *value) {
//        ALNetworkingResponse *response = value.second;
//        id obj = [clazz mj_objectWithKeyValues:response.result];
//        if(other) {
//            other(obj);
//        }
//        return obj;
//    }];
//}

@end
