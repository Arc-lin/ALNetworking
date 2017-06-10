//
//  ALNetworkingHistoryViewController.h
//  ALNetworkingDemo
//
//  Created by Arclin on 2017/6/6.
//  Copyright © 2017年 arclin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALNetworkingViewController : UINavigationController

- (instancetype)initWithHistoryViewController;

- (instancetype)initWithWebViewControllerWithHtmlStr:(NSString *)htmlStr;

@end

@interface ALNetworkingHistoryTableViewController : UITableViewController

/** 隐藏控制器 */
- (void)dismiss;

/** 清空历史记录 */
- (void)trash;

@end

@interface ALNetworkingWebViewController : UIViewController

/** html字符串 */
@property (nonatomic, copy) NSString *html;

/** 隐藏控制器 */
- (void)dismiss;

@end
