//
//  ALNetworking+Coobjc.h
//  ALNetworking_Example
//
//  Created by Arclin on 2019/12/15.
//
#import "ALNetworkRequest.h"

#import <coobjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALNetworkRequest (Coobjc)

- (COPromise *)co_executeRequest CO_ASYNC;

@end

NS_ASSUME_NONNULL_END
