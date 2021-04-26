//
//  ALTableViewController.m
//  ALNetworking_Example
//
//  Created by apple on 2021/4/25.
//

#import "ALTableViewController.h"
#import "ALRequestViewController.h"
#import <ALNetworkingConfig.h>

@interface ALTableViewController ()

@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;

@end

@implementation ALTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化配置
    // 通用、全局配置
    ALNetworkingConfig *config = [ALNetworkingConfig defaultConfig];
    config.defaultPrefixUrl = @"https://v2.alapi.cn";
    config.timeoutInterval = 10;
    config.defaultCacheStrategy = ALCacheStrategyNetworkOnly;
    config.distinguishError = YES;
    config.defaultHeader = @{
        @"test_config_header" : @"config_header",
        @"priority_header" : @"configHeader"
    };
    config.defaultParams = @{
        @"test_config_params" : @"config_params",
        @"priority_params" : @"configParams",
    };
    __block NSInteger headerVisitTimes = 0;
    __block NSInteger paramsVisitTimes = 0;
    config.dynamicHeaderConfig = ^NSDictionary *(ALNetworkRequest *request) {
        return @{
            @"config_header_times" : @(headerVisitTimes++).stringValue,
            @"priority_header": @"configDynamicHeader",
        };
    };
    config.dynamicParamsConfig = ^NSDictionary *(ALNetworkRequest *request) {
        return @{
            @"config_params_times" : @(paramsVisitTimes++).stringValue,
            @"priority_params": @"configDynamicParams",
        };
    };
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
        cell.textLabel.text = @"点击发起请求";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ALRequestViewController *vc = [[ALRequestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
