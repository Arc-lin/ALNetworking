//
//  LMURLRecordManager.h
//  LMCommonModule
//
//  Created by Arclin on 2019/8/5.
//

#import <Foundation/Foundation.h>

static NSNotificationName _Nonnull kALURLRecordManagerShowRecord = @"kALURLRecordManagerShowRecord";

@class ALURLRequestRecord,ALNetworkRequest,ALNetworkResponse;

NS_ASSUME_NONNULL_BEGIN

@interface ALURLRecordManager : NSObject

+ (instancetype)sharedInstance;

- (void)saveTask:(ALNetworkRequest *)request response:(ALNetworkResponse *)response isException:(BOOL)isException;

- (void)removeItemAtIndex:(NSInteger)index;

- (void)removeAllDatas;

@property (strong, readonly) NSMutableArray<ALURLRequestRecord *> *records;

@end

NS_ASSUME_NONNULL_END
