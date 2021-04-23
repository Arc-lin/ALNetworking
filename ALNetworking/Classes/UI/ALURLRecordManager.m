//
//  LMURLRecordManager.m
//  LMCommonModule
//
//  Created by Arclin on 2019/8/5.
//

#import "ALURLRecordManager.h"
#import "ALURLRequestRecord.h"
#import "ALURLRecordsViewController.h"
#import <ALNetworking.h>

@interface ALURLRecordManager()

@property (strong) NSMutableArray<ALURLRequestRecord *> *records;

@end

@implementation ALURLRecordManager

static ALURLRecordManager *_instance;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    
    return _instance;
}

+ (instancetype)sharedInstance
{
    if (_instance == nil) {
        _instance = [[ALURLRecordManager alloc] init];
        _instance.records = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:_instance selector:@selector(showViewController:) name:kALURLRecordManagerShowRecord object:nil];
    }
    return _instance;
}

- (void)showViewController:(NSNotification *)nofi
{
    ALURLRecordsViewController *vc = [[ALURLRecordsViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [[self lm_topViewController] presentViewController:nav animated:YES completion:nil];
}

- (id)lm_topViewController {
    UIViewController *resultVC;
    resultVC = [self findTopViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self findTopViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)findTopViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self findTopViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self findTopViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

- (void)saveTask:(ALNetworkRequest *)request response:(ALNetworkResponse *)response isException:(BOOL)isException
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            ALURLRequestRecord *record = [[ALURLRequestRecord alloc] init];
            record.url = [NSURL URLWithString:request.urlString];
//            record.statusCode = response.;
            record.timeStamp = [NSString stringWithFormat:@"%.3f",[[NSDate date] timeIntervalSince1970]];
            record.startTimeStamp = [NSString stringWithFormat:@"%.3f",request.requestStartTime];
            record.requestMethod = request.methodStr;
            record.isException = isException;
            NSDictionary *headers = request.headerDic;
            NSError *error = nil;
            NSData *headersData = [NSJSONSerialization dataWithJSONObject:headers options:NSJSONWritingPrettyPrinted error:&error];
            if (!error) {
                NSString *headersString = [[NSString alloc] initWithData:headersData encoding:NSUTF8StringEncoding];
                record.requestHeader = headersString;
            }
            NSMutableString *params = [NSMutableString string];
            [request.params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [params appendFormat:@"%@ = %@ \n",key,obj];
            }];
            record.requestParams = params;
            record.isCache = response.isCache;
            if (response.rawData && [response.rawData isKindOfClass:NSDictionary.class]) {
                NSError *err;
                NSData *data = [NSJSONSerialization dataWithJSONObject:response.rawData options:NSJSONWritingPrettyPrinted error:&err];
                NSString *string;
                if (!err) {
                    string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
                record.responseString = string;
                record.responseLength = [NSString stringWithFormat:@"%ld",record.responseString.length];
            } else {
                record.responseString = [NSString stringWithFormat:@"%@",response.rawData];
            }
        
            [self.records addObject:record];
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
    });
}

- (void)removeAllDatas
{
    [self.records removeAllObjects];
}

- (void)removeItemAtIndex:(NSInteger)index
{
    if (index < self.records.count && index >= 0) {
        [self.records removeObjectAtIndex:index];
    }
}

@end
