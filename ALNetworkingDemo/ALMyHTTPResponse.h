//
//  ALMyHTTPResponse.h
//  ALNetworkingDemo
//
//  Created by Arclin on 2017/6/5.
//  Copyright © 2017年 arclin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ALNetworkingResponse.h"

@interface ALMyHTTPResponse : ALNetworkingResponse

@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSString *status;

@property (nonatomic, strong) id content;

@end
