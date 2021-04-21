//
//  LMURLRequestRecord.m
//  LMCommonModule
//
//  Created by Arclin on 2019/8/5.
//

#import "ALURLRequestRecord.h"

@implementation ALURLRequestRecord

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        if (aDecoder) {
            _url = [aDecoder decodeObjectOfClass:[NSURL class] forKey:@"url"];
            _statusCode = [aDecoder decodeIntegerForKey:@"statusCode"];
            _isException = [aDecoder decodeBoolForKey:@"isException"];
            _isCache = [aDecoder decodeBoolForKey:@"isCache"];
            _timeStamp = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"timeStamp"];
            _requestMethod = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"requestMethod"];
            _requestParams = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"requestParams"];
            _requestHeader = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"requestHeader"];
            _responseString = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"responseString"];
            _responseLength = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"responseLength"];
            _startTimeStamp = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"startTimeStamp"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeInteger:_statusCode forKey:@"statusCode"];
    [aCoder encodeObject:_timeStamp forKey:@"timeStamp"];
    [aCoder encodeObject:_requestMethod forKey:@"requestMethod"];
    [aCoder encodeObject:_requestParams forKey:@"requestParams"];
    [aCoder encodeObject:_requestHeader forKey:@"requestHeader"];
    [aCoder encodeObject:_responseString forKey:@"responseString"];
    [aCoder encodeObject:_responseLength forKey:@"responseLength"];
    [aCoder encodeBool:_isException forKey:@"isException"];
    [aCoder encodeBool:_isCache forKey:@"isCache"];
    [aCoder encodeBool:_startTimeStamp forKey:@"startTimeStamp"];
}

@end
