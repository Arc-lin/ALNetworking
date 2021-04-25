//
//  ALNetworkResponseSerializer.h
//  ALNetworking
//
//  Created by Arclin on 2020/11/27.
//

#import "AFURLResponseSerialization.h"
#import "ALNetworkingConst.h"

@interface ALNetworkResponseSerializer : NSObject

+ (NSError *)verifyWithResponseType:(ALNetworkResponseType)type reponse:(NSHTTPURLResponse *)response reponseObject:(id)responseObject;

@end
