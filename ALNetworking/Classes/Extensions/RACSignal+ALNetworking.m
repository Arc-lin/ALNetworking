//
//  RACSignal+DKNetworking.m
//  DragonStar
//
//  Created by Arclin on 2017/4/21.
//  Copyright © 2017年 dankal. All rights reserved.
//

#import "RACSignal+ALNetworking.h"
#import "ALNetworkResponse.h"
#import "ALNetworking.h"
#import <MJExtension/MJExtension.h>
#import "ALBlockTrampoline.h"

@implementation RACSignal (ALNetworking)

- (RACSignal *(^)(Class))mapWithArrayOfClass
{
    return ^RACSignal *(Class clazz){
        return [self map:^id(NSArray *value) {
            NSArray *arr = [clazz mj_objectArrayWithKeyValuesArray:value];
            return arr;
        }];
    };
}

- (RACSignal *)mapWithRawData
{
    return [self map:^id(RACTuple *tuple) {
        ALNetworkResponse *resp = tuple.first;
        if([resp.rawData isKindOfClass:[NSNull class]]) {
            return nil;
        } else if ([resp.rawData isKindOfClass:NSDictionary.class]){
            NSMutableDictionary *tempDic = [resp.rawData mutableCopy];
            [resp.rawData enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSNull class]]) {
                    [tempDic removeObjectForKey:key];
                }
            }];
            resp.rawData = tempDic;
            return resp.rawData;
        } else {
            return resp.rawData;
        }
    }];
}

- (RACSignal *(^)(NSString *,Class))mapObjectWithSomething
{
    return ^RACSignal *(NSString *someThing,Class clazz) {
        return [self map:^id(RACTuple *tuple) {
            ALNetworkResponse *resp = tuple.first;
            id obj;
            if (!someThing || someThing.length == 0) {
                obj = [clazz mj_objectWithKeyValues:resp.rawData];
            } else {
                if ([resp.rawData isKindOfClass:NSDictionary.class]) {
                    obj = [clazz mj_objectWithKeyValues:resp.rawData[someThing]];
                }
            }
            if (obj) {
                return obj;
            }
            return nil;
       }];
    };
}

- (RACSignal *(^)(NSString *,Class))mapArrayWithSomething
{
    return ^RACSignal *(NSString *someThing,Class clazz) {
        return [self map:^id(RACTuple *tuple) {
            ALNetworkResponse *resp = tuple.first;
            id obj;
            if ([resp.rawData isKindOfClass:NSNull.class]) return nil;
            if (!someThing || someThing.length == 0) {
                obj = [clazz mj_objectArrayWithKeyValuesArray:resp.rawData];
            } else {
                if ([resp.rawData isKindOfClass:NSArray.class]) {
                    obj = [clazz mj_objectArrayWithKeyValuesArray:resp.rawData];
                } else if ([resp.rawData isKindOfClass:NSDictionary.class]) {
                    if ([resp.rawData[someThing] isKindOfClass:NSNull.class]) return nil;
                    obj = [clazz mj_objectArrayWithKeyValuesArray:resp.rawData[someThing]];
                }
            }
            if (obj) {
                return obj;
            }
            return nil;
        }];
    };
}

- (RACSignal<RACTuple *> *(^)(NSString *, __unsafe_unretained Class))combineObjectWithKey {
    return ^RACSignal *(NSString *someThing,Class clazz) {
        return [self map:^id _Nullable(RACTuple * _Nullable tuple) {
            if (tuple == nil) {
                return nil;
            }
            ALNetworkResponse *resp = tuple.first;
            id obj;
            if ([resp.rawData isKindOfClass:NSNull.class]) return nil;
            if (!someThing || someThing.length == 0) {
                obj = [clazz mj_objectWithKeyValues:resp.rawData];
            } else {
                if ([resp.rawData isKindOfClass:NSDictionary.class]) {
                    obj = [clazz mj_objectWithKeyValues:resp.rawData[someThing]];
                }
            }
            RACTuple *newTuple;
            if (obj) {
                newTuple = [tuple tupleByAddingObject:obj];
            } else {
                newTuple = [tuple tupleByAddingObject:[NSNull null]];
            }
            return newTuple;
        }];
    };
}

- (RACSignal<RACTuple *> *(^)(NSString *, __unsafe_unretained Class))combineArrayWithKey {
    return ^RACSignal *(NSString *someThing,Class clazz) {
        return [self map:^id _Nullable(RACTuple * _Nullable tuple) {
            if (tuple == nil) {
                return nil;
            }
            ALNetworkResponse *resp = tuple.first;
            id obj;
            if ([resp.rawData isKindOfClass:NSNull.class]) return nil;
            if (!someThing || someThing.length == 0) {
                obj = [clazz mj_objectArrayWithKeyValuesArray:resp.rawData];
            } else {
                if ([resp.rawData isKindOfClass:NSArray.class]) {
                    obj = [clazz mj_objectArrayWithKeyValuesArray:resp.rawData];
                } else if ([resp.rawData isKindOfClass:NSDictionary.class]) {
                    if ([resp.rawData[someThing] isKindOfClass:NSNull.class]) return nil;
                    obj = [clazz mj_objectArrayWithKeyValuesArray:resp.rawData[someThing]];
                }
            }
            RACTuple *newTuple;
            if (obj) {
                newTuple = [tuple tupleByAddingObject:obj];
            } else {
                newTuple = [tuple tupleByAddingObject:[NSNull null]];
            }
            return newTuple;
        }];
    };
}

- (RACSignal *)reduceResult:(ALNetworkReduceBlock)reduceBlock {
    return [self map:^id(RACTuple * _Nullable tuple) {
        if (!tuple) {
            return nil;
        }
        if (![tuple isKindOfClass:[RACTuple class]]) {
            return [RACSignal error:[NSError errorWithDomain:@"com.alnetworking.objmapping" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"类型错误"}]];
        }
        NSArray *objs = [[tuple.rac_sequence skip:2] map:^id _Nullable(id  _Nullable value) {
            return value;
        }].array;
        ALInvokeBlock(reduceBlock,objs);
        return tuple;
    }];
}

- (RACSignal *(^)(NSString *))mapWithSomething {
    return ^RACSignal *(NSString *someThing) {
        return [self map:^id(RACTuple *tuple) {
            ALNetworkResponse *resp = tuple.first;
            id data = resp.rawData[someThing];
            if ([data isKindOfClass:NSNull.class]) {
                return nil;
            } else {
                return data;
            }
        }];
    };
}

@end
