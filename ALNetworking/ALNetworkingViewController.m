//
//  ALNetworkingViewController.m
//  ALNetworkingDemo
//
//  Created by Arclin on 2017/6/6.
//  Copyright © 2017年 arclin. All rights reserved.
//

#import "ALNetworkingViewController.h"
#import "ALNetworking.h"

#import <WebKit/WebKit.h>

#pragma mark - 导航控制器

@interface ALNetworkingViewController ()

@end

@implementation ALNetworkingViewController

- (instancetype)initWithHistoryViewController
{
    ALNetworkingHistoryTableViewController *vc = [[ALNetworkingHistoryTableViewController alloc] init];
    vc.title = @"Request History";
    // 取消按钮
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:vc action:@selector(dismiss)];
    // 清空按钮
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:vc action:@selector(trash)];
    
    self = [super initWithRootViewController:vc];
    return self;
}

- (instancetype)initWithWebViewControllerWithHtmlStr:(NSString *)htmlStr
{
    ALNetworkingWebViewController *vc = [[ALNetworkingWebViewController alloc] init];
    vc.html = htmlStr;
    vc.title = @"Response Error";
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:vc action:@selector(dismiss)];
    self = [super initWithRootViewController:vc];
    return self;
}

@end

#pragma mark - 历史记录列表

@interface ALNetworkingHistoryTableViewController()

/** 数据源 */
@property (nonatomic, strong) NSArray *histories;

@end

@implementation ALNetworkingHistoryTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.histories = [ALNetworking sharedInstance].requestHistories;
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 清空历史记录
- (void)trash
{
    [[ALNetworking sharedInstance] clearHistories];
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.histories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"al_cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"al_cell"];
    }
    RACTuple *tuple              = self.histories[indexPath.row];
    RACTupleUnpack(NSDate *date,ALNetworkingRequest *request) = tuple;
    cell.textLabel.text          = [NSString stringWithFormat:@"%@ : %@",[self dateStr:date],[self lastTwoCompoment:request.urlStr]];
    cell.accessoryType           = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RACTuple *tuple              = self.histories[indexPath.row];
    
    // 取出数据
    RACTupleUnpack(NSDate *date,ALNetworkingRequest *request,ALNetworkingResponse *response) = tuple;
    
    ALNetworkingWebViewController *vc = [[ALNetworkingWebViewController alloc] init];
    
    // 数据插入HTML
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ALNetworkingDetail" ofType:@"html"];
    __block NSString *htmlStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    // 处理响应体
    NSString *respData = response.rawData ? [((NSDictionary *)response.rawData) descriptionWithLocale:nil] : response.error.description;
    respData = [respData stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    respData = [respData stringByReplacingOccurrencesOfString:@"\t" withString:@"&nbsp;&nbsp;&nbsp;"];
    
    NSDictionary *dic = @{@"{time}":[self dateStr:date],
                          @"{url}":request.urlStr,
                          @"{header}":request.header?[request.header descriptionWithLocale:nil]:@"",
                          @"{params}":request.params?[request.params descriptionWithLocale:nil]:@"",
                          @"{paramsType}":request.paramsTypeStr,
                          @"{stategy}":request.strategyStr,
                          @"{method}":request.methodStr,
                          @"{isCache}":@"",
                          @"{response}":respData};
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:key withString:obj];
    }];
    vc.html = htmlStr;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - private method

// 日期转字符串
- (NSString *)dateStr:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM-dd HH:mm:ss";
    return [formatter stringFromDate:date];
}

- (NSString *)lastTwoCompoment:(NSString *)urlStr
{
    NSString *compoment = [NSString stringWithFormat:@"%@/%@",urlStr.stringByDeletingLastPathComponent.lastPathComponent,urlStr.lastPathComponent];
    return compoment;
}

@end

#pragma mark - 网页控制器

@interface ALNetworkingWebViewController ()

@end

@implementation ALNetworkingWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 屏幕适应
    NSString *jScript                      = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    
    WKUserScript *wkUScript                = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *wkWebConfig    = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController      = wkUController;
    
    WKWebView *webView                     = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:wkWebConfig];
    
    [webView loadHTMLString:self.html baseURL:nil];
    [self.view addSubview:webView];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
