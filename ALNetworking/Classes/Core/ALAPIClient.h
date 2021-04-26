//
//  MMCAPIClient.h
//  ALNetworking
//
//  Created by Arclin on 2019/8/29.
//

#import "AFHTTPSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALAPIClient : AFHTTPSessionManager

+ (instancetype)sharedInstance;

@property (nonatomic, assign) AFNetworkReachabilityStatus networkStatus;

@end

NS_ASSUME_NONNULL_END
