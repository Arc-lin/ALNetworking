//
//  LMURLRequestRecord.h
//  LMCommonModule
//
//  Created by Arclin on 2019/8/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALURLRequestRecord : NSObject<NSSecureCoding>

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, assign) NSInteger statusCode;

@property (nonatomic, copy) NSString *startTimeStamp;

@property (nonatomic, copy) NSString *timeStamp;

@property (nonatomic, copy) NSString *requestMethod;

@property (nonatomic, copy) NSString *requestParams;

@property (nonatomic, copy) NSString *requestHeader;

@property (nonatomic, copy) NSString *responseString;

@property (nonatomic, copy) NSString *responseLength;

@property (nonatomic, assign) BOOL isException;

@property (nonatomic, assign) BOOL isCache;

@end

NS_ASSUME_NONNULL_END
