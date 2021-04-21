//
//  MMCBlockTrampoline.h
//  MMCNetworking
//
//  Created by Arc Lin on 2021/4/4.
//

#import <Foundation/Foundation.h>
#import "RACTuple.h"

static inline id ALInvokeBlock(id block, NSArray *args) {
  NSCParameterAssert(block != NULL && args.count > 0);

  switch (args.count) {
    case 0:
      return nil;
    case 1:
      return ((id(^)(id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil);
    case 2:
      return ((id(^)(id, id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil, ![args[1] isKindOfClass:NSNull.class]?args[1]:nil);
    case 3:
      return ((id(^)(id, id, id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil, ![args[1] isKindOfClass:NSNull.class]?args[1]:nil, ![args[2] isKindOfClass:NSNull.class]?args[2]:nil);
    case 4:
      return ((id(^)(id, id, id, id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil, ![args[1] isKindOfClass:NSNull.class]?args[1]:nil, ![args[2] isKindOfClass:NSNull.class]?args[2]:nil, ![args[3] isKindOfClass:NSNull.class]?args[3]:nil);
    case 5:
      return ((id(^)(id, id, id, id, id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil, ![args[1] isKindOfClass:NSNull.class]?args[1]:nil, ![args[2] isKindOfClass:NSNull.class]?args[2]:nil, ![args[3] isKindOfClass:NSNull.class]?args[3]:nil, ![args[4] isKindOfClass:NSNull.class]?args[4]:nil);
    case 6:
      return ((id(^)(id, id, id, id, id, id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil, ![args[1] isKindOfClass:NSNull.class]?args[1]:nil, ![args[2] isKindOfClass:NSNull.class]?args[2]:nil, ![args[3] isKindOfClass:NSNull.class]?args[3]:nil, ![args[4] isKindOfClass:NSNull.class]?args[4]:nil, ![args[5] isKindOfClass:NSNull.class]?args[5]:nil);
    case 7:
      return ((id(^)(id, id, id, id, id, id, id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil, ![args[1] isKindOfClass:NSNull.class]?args[1]:nil, ![args[2] isKindOfClass:NSNull.class]?args[2]:nil, ![args[3] isKindOfClass:NSNull.class]?args[3]:nil, ![args[4] isKindOfClass:NSNull.class]?args[4]:nil, ![args[5] isKindOfClass:NSNull.class]?args[5]:nil, ![args[6] isKindOfClass:NSNull.class]?args[6]:nil);
    case 8:
      return ((id(^)(id, id, id, id, id, id, id, id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil, ![args[1] isKindOfClass:NSNull.class]?args[1]:nil, ![args[2] isKindOfClass:NSNull.class]?args[2]:nil, ![args[3] isKindOfClass:NSNull.class]?args[3]:nil, ![args[4] isKindOfClass:NSNull.class]?args[4]:nil, ![args[5] isKindOfClass:NSNull.class]?args[5]:nil, ![args[6] isKindOfClass:NSNull.class]?args[6]:nil, ![args[7] isKindOfClass:NSNull.class]?args[7]:nil);
    case 9:
      return ((id(^)(id, id, id, id, id, id, id, id, id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil, ![args[1] isKindOfClass:NSNull.class]?args[1]:nil, ![args[2] isKindOfClass:NSNull.class]?args[2]:nil, ![args[3] isKindOfClass:NSNull.class]?args[3]:nil, ![args[4] isKindOfClass:NSNull.class]?args[4]:nil, ![args[5] isKindOfClass:NSNull.class]?args[5]:nil, ![args[6] isKindOfClass:NSNull.class]?args[6]:nil, ![args[7] isKindOfClass:NSNull.class]?args[7]:nil, ![args[8] isKindOfClass:NSNull.class]?args[8]:nil);
    case 10:
      return ((id(^)(id, id, id, id, id, id, id, id, id, id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil, ![args[1] isKindOfClass:NSNull.class]?args[1]:nil, ![args[2] isKindOfClass:NSNull.class]?args[2]:nil, ![args[3] isKindOfClass:NSNull.class]?args[3]:nil, ![args[4] isKindOfClass:NSNull.class]?args[4]:nil, ![args[5] isKindOfClass:NSNull.class]?args[5]:nil, ![args[6] isKindOfClass:NSNull.class]?args[6]:nil, ![args[7] isKindOfClass:NSNull.class]?args[7]:nil, ![args[8] isKindOfClass:NSNull.class]?args[8]:nil, ![args[9] isKindOfClass:NSNull.class]?args[9]:nil);
    case 11:
      return ((id(^)(id, id, id, id, id, id, id, id, id, id, id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil, ![args[1] isKindOfClass:NSNull.class]?args[1]:nil, ![args[2] isKindOfClass:NSNull.class]?args[2]:nil, ![args[3] isKindOfClass:NSNull.class]?args[3]:nil, ![args[4] isKindOfClass:NSNull.class]?args[4]:nil, ![args[5] isKindOfClass:NSNull.class]?args[5]:nil, ![args[6] isKindOfClass:NSNull.class]?args[6]:nil, ![args[7] isKindOfClass:NSNull.class]?args[7]:nil, ![args[8] isKindOfClass:NSNull.class]?args[8]:nil, ![args[9] isKindOfClass:NSNull.class]?args[9]:nil, ![args[10] isKindOfClass:NSNull.class]?args[10]:nil);
    case 12:
      return ((id(^)(id, id, id, id, id, id, id, id, id, id, id, id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil, ![args[1] isKindOfClass:NSNull.class]?args[1]:nil, ![args[2] isKindOfClass:NSNull.class]?args[2]:nil, ![args[3] isKindOfClass:NSNull.class]?args[3]:nil, ![args[4] isKindOfClass:NSNull.class]?args[4]:nil, ![args[5] isKindOfClass:NSNull.class]?args[5]:nil, ![args[6] isKindOfClass:NSNull.class]?args[6]:nil, ![args[7] isKindOfClass:NSNull.class]?args[7]:nil, ![args[8] isKindOfClass:NSNull.class]?args[8]:nil, ![args[9] isKindOfClass:NSNull.class]?args[9]:nil, ![args[10] isKindOfClass:NSNull.class]?args[10]:nil, ![args[11] isKindOfClass:NSNull.class]?args[11]:nil);
    case 13:
      return ((id(^)(id, id, id, id, id, id, id, id, id, id, id, id, id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil, ![args[1] isKindOfClass:NSNull.class]?args[1]:nil, ![args[2] isKindOfClass:NSNull.class]?args[2]:nil, ![args[3] isKindOfClass:NSNull.class]?args[3]:nil, ![args[4] isKindOfClass:NSNull.class]?args[4]:nil, ![args[5] isKindOfClass:NSNull.class]?args[5]:nil, ![args[6] isKindOfClass:NSNull.class]?args[6]:nil, ![args[7] isKindOfClass:NSNull.class]?args[7]:nil, ![args[8] isKindOfClass:NSNull.class]?args[8]:nil, ![args[9] isKindOfClass:NSNull.class]?args[9]:nil, ![args[10] isKindOfClass:NSNull.class]?args[10]:nil, ![args[11] isKindOfClass:NSNull.class]?args[11]:nil, ![args[12] isKindOfClass:NSNull.class]?args[12]:nil);
    case 14:
      return ((id(^)(id, id, id, id, id, id, id, id, id, id, id, id, id, id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil, ![args[1] isKindOfClass:NSNull.class]?args[1]:nil, ![args[2] isKindOfClass:NSNull.class]?args[2]:nil, ![args[3] isKindOfClass:NSNull.class]?args[3]:nil, ![args[4] isKindOfClass:NSNull.class]?args[4]:nil, ![args[5] isKindOfClass:NSNull.class]?args[5]:nil, ![args[6] isKindOfClass:NSNull.class]?args[6]:nil, ![args[7] isKindOfClass:NSNull.class]?args[7]:nil, ![args[8] isKindOfClass:NSNull.class]?args[8]:nil, ![args[9] isKindOfClass:NSNull.class]?args[9]:nil, ![args[10] isKindOfClass:NSNull.class]?args[10]:nil, ![args[11] isKindOfClass:NSNull.class]?args[11]:nil, ![args[12] isKindOfClass:NSNull.class]?args[12]:nil, ![args[13] isKindOfClass:NSNull.class]?args[13]:nil);
    case 15:
      return ((id(^)(id, id, id, id, id, id, id, id, id, id, id, id, id, id, id))block)(![args[0] isKindOfClass:NSNull.class]?args[0]:nil, ![args[1] isKindOfClass:NSNull.class]?args[1]:nil, ![args[2] isKindOfClass:NSNull.class]?args[2]:nil, ![args[3] isKindOfClass:NSNull.class]?args[3]:nil, ![args[4] isKindOfClass:NSNull.class]?args[4]:nil, ![args[5] isKindOfClass:NSNull.class]?args[5]:nil, ![args[6] isKindOfClass:NSNull.class]?args[6]:nil, ![args[7] isKindOfClass:NSNull.class]?args[7]:nil, ![args[8] isKindOfClass:NSNull.class]?args[8]:nil, ![args[9] isKindOfClass:NSNull.class]?args[9]:nil, ![args[10] isKindOfClass:NSNull.class]?args[10]:nil, ![args[11] isKindOfClass:NSNull.class]?args[11]:nil, ![args[12] isKindOfClass:NSNull.class]?args[12]:nil, ![args[13] isKindOfClass:NSNull.class]?args[13]:nil, ![args[14] isKindOfClass:NSNull.class]?args[14]:nil);
  }

  NSCAssert(NO, @"The argument count is too damn high! Only blocks of up to 15 arguments are currently supported.");
  return nil;
}
