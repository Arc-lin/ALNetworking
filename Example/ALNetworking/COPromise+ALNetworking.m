//
//  COPromise+ALNetworking.m
//  ALNetworking_Example
//
//  Created by Arclin on 2019/12/16.
//

#import "COPromise+ALNetworking.h"
#import <coobjc.h>
#import <ALNetworkRequest.h>
#import <ALNetworkResponse.h>
#import <MJExtension.h>

@implementation COPromise (ALNetworking)

- (COPromise *(^)(NSString *,Class))mapObjectWithSomething
{
    return ^COPromise *(NSString *someThing,Class clazz) {
        COPromise *p = [COPromise promise];
        ALNetworkRequest *request;
        ALNetworkResponse *response;
        NSError *error;
        co_unpack(&response,&request,&error) = await(self);
        id obj;
        if (!someThing || someThing.length == 0) {
            obj = [clazz mj_objectWithKeyValues:response.rawData];
        } else {
            if ([response.rawData isKindOfClass:NSDictionary.class]) {
                obj = [clazz mj_objectWithKeyValues:response.rawData[someThing]];
            }
        }
        if (obj) {
            [p fulfill:obj];
        } else {
            [p fulfill:nil];
        }
        return p;
    };
}

- (COPromise *(^)(NSString *,Class))mapArrayWithSomething
{
    return ^COPromise *(NSString *someThing,Class clazz) {
        COPromise *p = [COPromise promise];
        ALNetworkRequest *request;
        ALNetworkResponse *resp;
        NSError *error;
        co_unpack(&resp,&request,&error) = await(self);
        id obj;
        if (!someThing || someThing.length == 0) {
            obj = [clazz mj_objectArrayWithKeyValuesArray:resp.rawData];
        } else {
            if ([resp.rawData isKindOfClass:NSArray.class]) {
                obj = [clazz mj_objectArrayWithKeyValuesArray:resp.rawData];
            } else if ([resp.rawData isKindOfClass:NSDictionary.class]) {
                obj = [clazz mj_objectArrayWithKeyValuesArray:resp.rawData[someThing]];
            }
        }
        if (obj) {
            [p fulfill:obj];
        } else {
            [p fulfill:nil];
        }
        return p;
    };
}

@end
