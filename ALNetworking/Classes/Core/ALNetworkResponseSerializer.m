//
//  ALNetworkResponseSerializer.m
//  ALNetworking
//
//  Created by Arclin on 2020/11/27.
//

#import "ALNetworkResponseSerializer.h"
#import <AFURLResponseSerialization.h>

@implementation ALNetworkResponseSerializer

+ (NSError *)verifyWithResponseType:(ALNetworkResponseType)type reponse:(NSHTTPURLResponse *)response reponseObject:(id)responseObject
{
    NSError *error;
    AFHTTPResponseSerializer *serializer;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:responseObject];
    switch (type) {
        case ALNetworkResponseTypeJSON:
            serializer = [AFJSONResponseSerializer serializer];
            [serializer validateResponse:response data:data error:&error];
            break;
        case ALNetworkResponseTypeHTTP:
            serializer = [AFHTTPResponseSerializer serializer];
            [serializer validateResponse:response data:data error:&error];
            break;
        case ALNetworkResponseTypeImage:
            serializer = [AFImageResponseSerializer serializer];
            [serializer validateResponse:response data:data error:&error];
            break;
        case ALNetworkResponseTypeXML:
            serializer = [AFXMLParserResponseSerializer serializer];
            [serializer validateResponse:response data:data error:&error];
            break;
        case ALNetworkResponseTypePlist:
            serializer = [AFPropertyListResponseSerializer serializer];
            [serializer validateResponse:response data:data error:&error];
            break;
        case ALNetworkResponseTypeAnyThing:
            return nil;
        default:
            break;
    }
    
    return error;
}

@end
