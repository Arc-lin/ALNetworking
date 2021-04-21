//
//  ALNetworkResponse.m
//  BaZiPaiPanSDK
//
//  Created by Arclin on 2018/4/21.
//

#import "ALNetworkResponse.h"

#define MMCRawDataKey @"rawData"
//#define MMCErrorKey @"error"
#define MMCIsCacheKey @"isCache"

@implementation ALNetworkResponse

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_rawData forKey:MMCRawDataKey];
    [aCoder encodeObject:@(_isCache) forKey:MMCIsCacheKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _rawData = [aDecoder decodeObjectForKey:MMCRawDataKey];
        _isCache = [[aDecoder decodeObjectForKey:MMCIsCacheKey] boolValue];
    }
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    ALNetworkResponse *resp = [[ALNetworkResponse alloc] init];
    resp.rawData = [self.rawData mutableCopy];
    resp.isCache = self.isCache;
    return resp;
}

@end
