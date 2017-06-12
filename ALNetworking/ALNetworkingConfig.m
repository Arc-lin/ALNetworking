//
//  ALNetworkingConfig.m
//  ALNetworkingDemo
//
//  Created by Arclin on 2017/3/16.
//  Copyright © 2017年 dankal. All rights reserved.
//

#import "ALNetworkingConfig.h"
#import "ReactiveCocoa.h"
#import "ALNetworking.h"
#import "ALNetworkingResponse.h"

@implementation ALNetworkingConfig

static ALNetworkingConfig *_configure;

- (instancetype)init
{
    if (self = [super init]) {
        // Set Default Value
        self.timeoutInterval   = 30;
        self.defaultHeader     = @{};
        self.defaultParams     = @{};
        self.handleError       = ^(NSError *error) {
            return error;
        };
        self.handleResponse    = ^RACSignal *(RACTuple *value) {
            return [RACSignal return:value];
        };
        self.customLog         = ^(NSString *logText) {
            NSLog(@"%@",logText);
        };
    }
    
    return self;
}

#pragma mark - setter & getter

- (void)setSslCerPath:(NSString *)sslCerPath
{
    NSAssert(sslCerPath != nil, @"SSL PATH Could not be nil");
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if([manager fileExistsAtPath:sslCerPath]) {
        _sslCerPath = sslCerPath;
    }else {
        
        if(self.customLog) self.customLog(@"SSL PATH NOT EXIST");
        
        _sslCerPath = nil;
    }
}

- (NSString *)urlPerfix
{
    // 没有值的时候返回空字符串而不是nil
    if (!_urlPerfix) {
        return @"";
    }
    return _urlPerfix;
}

@end
