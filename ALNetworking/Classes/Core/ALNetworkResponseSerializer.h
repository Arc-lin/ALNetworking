//
//  ALNetworkResponseSerializer.h
//  MMCNetworking
//
//  Created by Arclin on 2020/11/27.
//

#import "AFURLResponseSerialization.h"
#import "ALNetworkingConst.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALNetworkResponseSerializer : NSObject

+ (NSError *)verifyWithResponseType:(ALNetworkResponseType)type reponse:(NSHTTPURLResponse *)response reponseObject:(id)responseObject;

@end

NS_ASSUME_NONNULL_END
