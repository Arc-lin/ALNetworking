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
    
    // 自定义响应类 配置了这个的话,返回值就是RACTuple(ALNetworkingRequest *,自定义类映射出的对象)
    networking.config.customRespClazz = [ALMyHTTPResponse class];
    
    // 超时时间
    networking.config.timeoutInterval = 10.0f;
    
    // 请求的URL前缀 调用url()的时候会自动加上前缀,不想加的话就用url_x() 这里示例用,就搭建了个本地服务器
    networking.config.urlPerfix       = @"http://dankal.cn:3000";
    
    // 默认全局参数
    networking.config.defaultParams   = @{@"xxx":@"dddd"};
    
    // 默认全局请求头
    // 注意如果你想在这里配置token, 这里因为是在AppDelegate配置的,所以如果用户切换账号的话,这里的token是不会更新的,需要在切换登录的地方重新写一遍配置全局请求头
    networking.config.defaultHeader   = @{@"token":@"xxxxxx"};
    
    // 自定义手势 这个手势是用来唤出历史记录界面的
    //    networking.config.gesture         = [self gesture];
    
    // 处理请求错误信息
    // 1. 当你想要直接使用error.localizedDescription去给用户提示网络异常的原因的时候,系统的错误是用英文提示的,所以这里得改成中文
    // 2. 当你有维护一个错误码表的时候,你就可以在这里拦截到所有的错误返回,然后进行错误码表的对应
    networking.config.handleError     = ^NSError *(NSError *error) {
        if(error.code == -1001) {
            error = [NSError errorWithDomain:error.domain code:error.code userInfo:@{NSLocalizedDescriptionKey:@"网络连接超时"}];
        } else if (error.code == -1009) {
            error = [NSError errorWithDomain:error.domain code:error.code userInfo:@{NSLocalizedDescriptionKey:@"网络连接失败"}];
        }
        
        return error;
    };
    
    // 统一提前处理响应体
    // 1. 进行错误码的校验, 如果不是正确码,则抛出错误
    // 2. 举个例子,当用户的token失效的时候,需要弹出登录界面,就可以校验服务器返回的特殊错误码,在rootViewController弹出登录窗口
    networking.config.handleResponse = ^RACSignal *(RACTuple *value) {
        
        ALNetworkingRequest *request = value.first;
        if (!request.ignoreCustomResponseClass) { // 如果有配置自定义响应类
            ALMyHTTPResponse *response = value.second;
            
            if (![response.status isEqualToString:@"10000"]) { // 如果不是正确返回码
                NSError *error = [[NSError alloc] initWithDomain:@"myDomain" code:response.status.integerValue userInfo:@{NSLocaleCountryCode:response.message?:@"未知错误"}];
                [RACSignal error:error]; // 必须使用这种方式抛出错误
            }
            
        } else {
            ALNetworkingResponse *response = value.second;
            
            // 可以做点错误码判断之类的
        }
        return [RACSignal return:value];
    };
    
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
