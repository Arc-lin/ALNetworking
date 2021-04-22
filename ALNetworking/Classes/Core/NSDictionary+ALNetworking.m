//
//  NSDictionary+ALNetworking.m
//  ALNetworking
//
//  Created by Arc Lin on 2021/1/31.
//

#import "NSDictionary+ALNetworking.h"

@implementation NSDictionary (ALNetworking)

+ (NSDictionary *)_ALDictionaryOfVariableBindings:(id)firstArg, ... {
    NSArray *keys = [firstArg componentsSeparatedByString:@","];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:keys.count];
    va_list list;
    if (firstArg) {
        va_start(list, firstArg);
        id arg;
        for (NSString *key in keys) {
            arg = va_arg(list, id);
            if (!arg || [arg isKindOfClass:[NSNull class]]) {
                continue;
            }
            [dic setObject:arg forKey:key];
        }
        va_end(list);
    }
    return dic;
}

@end
