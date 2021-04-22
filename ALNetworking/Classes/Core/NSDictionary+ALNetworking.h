//
//  NSDictionary+ALNetworking.h
//  ALNetworking
//
//  Created by Arc Lin on 2021/1/31.
//

#import <Foundation/Foundation.h>

#define ALDictionaryOfVariableBindings(...) [NSDictionary _ALDictionaryOfVariableBindings:@"" # __VA_ARGS__, __VA_ARGS__]

@interface NSDictionary (ALNetworking)

/**
 模仿系统的对象生成字典的宏定义：NSDictionaryOfVariableBindings(...)
 if v1 = @"something"; v2 = nil; v3 = @"something"; v4 = @"";
 NSDictionaryOfVariableBindings(v1, v2, v3) is equivalent to [NSDictionary dictionaryWithObjectsAndKeys:v1, @"v1", v3, @"v3", nil];
 并且参数的值可为nil,@"", 会自动去除值为nil对象, @""对象或@"  "则保留
 */
+ (NSDictionary *)_ALDictionaryOfVariableBindings:(NSString *)firstArg, ...;

@end

