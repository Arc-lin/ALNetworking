//
//  ALNetworkingResponse.m
//  ALA
//
//  Created by Arclin on 2017/3/24.
//  Copyright © 2017年 dankal. All rights reserved.
//

#import "ALNetworkingResponse.h"

@implementation ALNetworkingResponse

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(!self) {
        return nil;
    }
    self.rawData = [aDecoder decodeObjectForKey:@"rawData"];
    self.error = [aDecoder decodeObjectForKey:@"error"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.rawData forKey:@"rawData"];
    [aCoder encodeObject:self.error forKey:@"error"];
}

@end
