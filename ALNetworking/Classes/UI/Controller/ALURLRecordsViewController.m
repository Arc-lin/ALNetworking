//
//  LMURLRecordsViewController.m
//  LMCommonModule
//
//  Created by Arclin on 2019/8/5.
//

#import "ALURLRecordsViewController.h"
#import "ALURLRecordManager.h"
#import "ALURLRequestRecord.h"
#import "ALURLRecordDetailViewController.h"

@interface ALURLRecordsViewController ()<UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) NSArray *searchResult;

@end

@implementation ALURLRecordsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"请求日志";
    NSMutableDictionary *barTitleDic = [NSMutableDictionary dictionary];
    barTitleDic[NSForegroundColorAttributeName] = [UIColor blackColor];
    [self.navigationController.navigationBar setTitleTextAttributes:barTitleDic];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeViewController)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearDatas)];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)closeViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clearDatas
{
    [[ALURLRecordManager sharedInstance] removeAllDatas];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active) {
        return self.searchResult.count;
    }
    return [ALURLRecordManager sharedInstance].records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    ALURLRequestRecord *record;
    if (self.searchController.active) {
        record = self.searchResult[indexPath.row];
    } else {
        record = [ALURLRecordManager sharedInstance].records[indexPath.row];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",record.url.path];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"HH:mm:ss"];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:record.timeStamp.longLongValue];
    cell.detailTextLabel.text = [format stringFromDate:date];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (record.isException) {
        cell.detailTextLabel.textColor = UIColor.redColor;
        cell.textLabel.textColor = UIColor.redColor;
    } else {
        cell.detailTextLabel.textColor = UIColor.blackColor;
        cell.textLabel.textColor = UIColor.blackColor;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALURLRecordDetailViewController *vc = [[ALURLRecordDetailViewController alloc] init];
    if (self.searchController.active) {
        vc.record = self.searchResult[indexPath.row];
    } else {
        vc.record = [ALURLRecordManager sharedInstance].records[indexPath.row];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchController.active) {
        ALURLRequestRecord *record = self.searchResult[indexPath.row];
        NSInteger index = [[ALURLRecordManager sharedInstance].records indexOfObject:record];
        if (index != NSNotFound) {
            [[ALURLRecordManager sharedInstance] removeItemAtIndex:index];
        }
    } else {
        [[ALURLRecordManager sharedInstance] removeItemAtIndex:indexPath.row];
    }
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *inputStr = searchController.searchBar.text;
    NSArray *total = [ALURLRecordManager sharedInstance].records;
    NSMutableArray *arr = [NSMutableArray array];
    for (ALURLRequestRecord *record in total) {
        if ([[record.url.absoluteString lowercaseString] containsString:[inputStr lowercaseString]]) {
            [arr addObject:record];
        }
    }
    self.searchResult = arr;
    
    [self.tableView reloadData];
}

- (UISearchController *)searchController
{
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.dimsBackgroundDuringPresentation = NO;
        _searchController.hidesNavigationBarDuringPresentation = YES;
    }
    return _searchController;
}

@end
