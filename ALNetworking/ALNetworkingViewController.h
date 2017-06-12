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

/** Dismiss controller */
- (void)dismiss;

/** Clear all the histories */
- (void)trash;

@end

@interface ALNetworkingWebViewController : UIViewController

/** html String */
@property (nonatomic, copy) NSString *html;

/** Dismiss controller */
- (void)dismiss;

@end
