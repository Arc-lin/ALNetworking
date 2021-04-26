//
//  LMURLRecordDetailViewController.m
//  LMCommonModule
//
//  Created by Arclin on 2019/8/5.
//

#import "ALURLRecordDetailViewController.h"
#import "ALURLRecordDetailCell.h"
#import "ALURLRequestRecord.h"

@interface ALURLRecordDetailViewController ()

@property (nonatomic, strong) NSArray<NSDictionary *> *datas;

@end

@implementation ALURLRecordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.record.url.path;
    self.tableView.estimatedRowHeight = 20;
    [self.tableView registerClass:ALURLRecordDetailCell.class forCellReuseIdentifier:@"cell"];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.record.timeStamp.doubleValue];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.record.startTimeStamp.doubleValue];
    double duration = self.record.timeStamp.doubleValue - self.record.startTimeStamp.doubleValue;
    self.datas = @[
                   @{@"地址":self.record.url.absoluteString},
                   @{@"路径":self.record.url.path},
                   @{@"类型":self.record.isCache ? @"缓存" : @"网络"},
                   @{@"请求时间":[format stringFromDate:startDate]},
                   @{@"响应时间":[format stringFromDate:date]},
                   @{@"请求时长":@(duration).stringValue},
                   @{@"请求方式":self.record.requestMethod},
                   @{@"请求头":self.record.requestHeader?:@""},
                   @{@"参数":self.record.requestParams?:@""},
                   @{@"响应长度":self.record.responseLength?:@"0"},
                   @{@"响应":self.record.responseString?:@""}];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)share:(UIBarButtonItem *)item
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSMutableString *string = [NSMutableString string];
    [self.datas enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [string appendFormat:@"%@   %@\n",obj.allKeys.firstObject?:@"",obj.allValues.firstObject];
    }];
    NSString *cachesPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",[self.record.url.path stringByReplacingOccurrencesOfString:@"/" withString:@"_"]]];
    if ([manager fileExistsAtPath:cachesPath]) {
        [manager removeItemAtPath:cachesPath error:nil];
    }
    NSError *err;
    [string writeToFile:cachesPath atomically:YES encoding:NSUTF8StringEncoding error:&err];
    if (!err) {
    UIActivityViewController *docVc = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:cachesPath]] applicationActivities:nil];
        [self presentViewController:docVc animated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ALURLRecordDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.titleLabel.text = self.datas[indexPath.row].allKeys.firstObject;
    cell.resposneLabel.text = self.datas[indexPath.row].allValues.firstObject;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{
    if (action == @selector(copy:)) {
        NSDictionary *data = self.datas[indexPath.row];
        [UIPasteboard generalPasteboard].string = data.allValues.firstObject;
    }
}

@end
