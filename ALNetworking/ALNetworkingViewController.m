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
    NSString *path = [self filesPathFromCustomBundle:@"ALNetworkingDetail"];
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
                          @"{isCache}":response.isCache ? @"True" : @"False",
                          @"{response}":respData};
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:key withString:obj];
    }];
    vc.html = htmlStr;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - private method

- (NSString *)filesPathFromCustomBundle:(NSString *)fileName
{
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"ALNetworking.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *file_path = [bundle pathForResource:fileName ofType:@"html"];
    return file_path;
}


// 日期转字符串
- (NSString *)dateStr:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM-dd HH:mm:ss";
    return [formatter stringFromDate:date];
}

- (NSString *)lastTwoCompoment:(NSString *)urlStr
{
    NSString *component = [NSString stringWithFormat:@"%@/%@",urlStr.stringByDeletingLastPathComponent.lastPathComponent,urlStr.lastPathComponent];
    return component;
}

@end

#pragma mark - 网页控制器

@interface ALNetworkingWebViewController ()

/** webView */
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation ALNetworkingWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [webView loadHTMLString:self.html baseURL:nil];
    [self.view addSubview:webView];
    self.webView = webView;
    
    // 保存网页内容到相册图片
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(webContentImage)];
}

- (UIImage *)webContentImage
{
    CGSize boundsSize = self.webView.bounds.size;
    CGFloat boundsWidth = self.webView.bounds.size.width;
    CGFloat boundsHeight = self.webView.bounds.size.height;
    CGPoint offset = self.webView.scrollView.contentOffset;
    [self.webView.scrollView setContentOffset:CGPointMake(0, 0)];
    CGFloat contentHeight = self.webView.scrollView.contentSize.height;
    NSMutableArray *images = [NSMutableArray array];
    while (contentHeight > 0) {
        UIGraphicsBeginImageContext(boundsSize);
        [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [images addObject:image];
        CGFloat offsetY = self.webView.scrollView.contentOffset.y;
        [self.webView.scrollView setContentOffset:CGPointMake(0, offsetY + boundsHeight)];
        contentHeight -= boundsHeight;
    }
    [self.webView.scrollView setContentOffset:offset];
    UIGraphicsBeginImageContext(self.webView.scrollView.contentSize);
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
        [image drawInRect:CGRectMake(0, boundsHeight * idx, boundsWidth, boundsHeight)];
    }];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(fullImage, self,@selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:),nil);
    
    return fullImage;
}

- (void)imageSavedToPhotosAlbum:(UIImage*)image didFinishSavingWithError:  (NSError*)error contextInfo:(id)contextInfo
{
    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"保存成功" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil] show];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
