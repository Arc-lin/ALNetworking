//
//  UIViewController+ALExtension.m
//  ALNetworkingDemo
//
//  Created by Arclin on 2017/6/8.
//  Copyright © 2017年 arclin. All rights reserved.
//

#import "UIViewController+ALExtension.h"
#import "ALNetworking.h"
#import "ALNetworkingViewController.h"
#import <objc/runtime.h>

@implementation UIViewController (ALExtension)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector1 = @selector(viewDidAppear:);
        SEL swizzledSelector1 = @selector(logger_viewDidAppear:);
        Method originalMethod1 = class_getInstanceMethod(class, originalSelector1);
        Method swizzledMethod1 = class_getInstanceMethod(class, swizzledSelector1);
        BOOL didAddMethod1 = class_addMethod(class,originalSelector1,method_getImplementation(swizzledMethod1),method_getTypeEncoding(swizzledMethod1));
        if (didAddMethod1) {
            class_replaceMethod(class,swizzledSelector1,method_getImplementation(originalMethod1),method_getTypeEncoding(originalMethod1));
        } else {
            method_exchangeImplementations(originalMethod1, swizzledMethod1);
        }
    });
}

- (void)logger_viewDidAppear:(BOOL)animated
{
    [self logger_viewDidAppear:animated];
    
    UIGestureRecognizer *customGesture = [ALNetworking sharedInstance].config.gesture;
    
    NSArray *controllerNames = @[@"ALNetworkingViewController",@"ALNetworkingWebViewController",@"ALNetworkingHistoryTableViewController"];
    if ([controllerNames containsObject:NSStringFromClass([self class])]) {
        return;
    }
    if(![[ALNetworking sharedInstance].config.noHistoryControllerNames containsObject:NSStringFromClass([self class])]) {
        if(customGesture) { // 如果有自定义手势就直接添加在View上面
                @weakify(self);
                [customGesture.rac_gestureSignal subscribeNext:^(id x) {
                    @strongify(self);
                    [self showLoggerViewController];
                }];
                [self.view addGestureRecognizer:customGesture];
        } else {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showLoggerViewController)];
            longPress.minimumPressDuration = 2.0f;
            [self.view addGestureRecognizer:longPress];
        }
    }
}

- (void)showLoggerViewController
{
    NSString *className = NSStringFromClass(self.class);
    if([ALNetworking sharedInstance].config.debugMode &&
       ![className isEqualToString:@"ALNetworkingHistoryTableViewController"] &&
       ![className isEqualToString:@"ALNetworkingWebViewController"]) { // 如果是调试模式的话才可以弹出  Pop if Debug mode is YES
        ALNetworkingViewController *vc = [[ALNetworkingViewController alloc] initWithHistoryViewController];
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

@end
