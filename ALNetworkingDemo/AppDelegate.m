//
//  AppDelegate.m
//  ALNeetworkingDemo
//
//  Created by Arclin on 2017/5/30.
//  Copyright © 2017年 arclin. All rights reserved.
//

#import "AppDelegate.h"
#import "ALNetworking.h"
#import "ALMyHTTPResponse.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    ALNetworking *networking          = [ALNetworking sharedInstance];
    
    // 判断是否开启调试模式
#if DEBUG
    networking.config.debugMode       = YES;
#else
    networking.config.debugMode       = NO;
#endif
    
    // 自定义响应类
    networking.config.customRespClazz = [ALMyHTTPResponse class];
    // 请求的URL前缀
    networking.config.urlPerfix       = @"http://47.90.51.89:9091";
    // 处理请求错误信息
    networking.config.handleError     = ^NSError *(NSError *error) {
        return error;
    };
    // 处理响应体
    networking.config.handleResponse = ^RACSignal *(RACTuple *value) {
        ALMyHTTPResponse *response = value.second;
        if (![response.status isEqualToString:@"10000"]) { // 如果不是正确返回码
            NSError *error = [[NSError alloc] initWithDomain:@"myDomain" code:response.status.integerValue userInfo:@{NSLocaleCountryCode:response.message?:@"未知错误"}];
            [RACSignal error:error]; // 必须抛出错误
        }
        return [RACSignal return:value];
    };
    
//    networking.config.gesture         = [self gesture];
    
    return YES;
}

- (UITapGestureRecognizer *)gesture
{
    // 自定义手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
    tap.numberOfTapsRequired = 2;
    tap.numberOfTouchesRequired = 2;
    return tap;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
