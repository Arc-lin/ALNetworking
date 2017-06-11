//
//  RACSignal+ALNetworking.m
//  DragonStar
//
//  Created by Arclin on 2017/4/21.
//  Copyright © 2017年 dankal. All rights reserved.
//

#import "RACSignal+ALNetworking.h"
#import "ALNetworking.h"
#import "ALMyHTTPResponse.h"

#import <YYModel/YYModel.h>

@implementation RACSignal (ALNetworking)

static NSString *successCode = @"1000";

- (RACSignal *(^)(Class))mapWithArrayOfClass
{
    return ^RACSignal *(Class clazz){
        return [self map:^id(RACTuple *value) {
            ALMyHTTPResponse *response = value.second;
            NSArray *arr = [clazz yy_modelWithDictionary:response.content];
            return arr;
        }];
    };
}

- (RACSignal *(^)())mapWithBoolNumber
{
    return ^RACSignal *{
        return [self map:^id(RACTuple *value) {
            ALMyHTTPResponse *response = value.second;
            return @([response.message isEqualToString:successCode]);
        }];
    };
}

- (RACSignal *(^)(Class))mapWithObject
{
    return ^RACSignal *(Class clazz){
        return [self map:^id(RACTuple *value) {
            ALMyHTTPResponse *response = value.second;
            if(!response.content[@"data"]) {
                id obj = [clazz yy_modelWithDictionary:response.content];
                return obj;
            }else {
                id obj = [clazz yy_modelWithDictionary:response.content[@"data"]];
                return obj;
            }
        }];
    };
}

- (RACSignal *)mapWithObject:(Class)clazz otherThings:(void(^)(id obj))other
{
    return [self map:^id(RACTuple *value) {
        ALMyHTTPResponse *response = value.second;
        id obj = [clazz yy_modelWithDictionary:response.content];
        if(other) {
            other(obj);
        }
        return obj;
    }];
}

@end
