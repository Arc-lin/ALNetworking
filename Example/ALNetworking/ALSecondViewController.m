//
//  ALSecondViewController.m
//  ALNetworking_Example
//
//  Created by Arclin on 2019/8/27.
//

#import "ALSecondViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <ALNetworking.h>

@interface ALSecondViewController ()

@property (nonatomic, strong) ALNetworking *networking;

@property (nonatomic, copy) NSString *page;
@property (nonatomic, copy) NSString *size;

@end

@implementation ALSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view.
    ALNetworking *networking = [[ALNetworking alloc] init];
    self.page = @"2";
    self.size = @"20";
    __weak typeof(self) weakSelf = self;
    networking.dynamicParamsConfig = ^NSDictionary *(ALNetworkRequest *request) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        return @{@"page":strongSelf.page,@"size":strongSelf.size};
    };
    networking.handleResponse = ^NSError *(ALNetworkResponse *response, ALNetworkRequest *request) {
//        NSLog(@"Handle!!!!!");
        return nil;
    };
    networking.url(@"http://myip.ipip.net").name(@"请求1").params(@{@"test":self.page}).executeRequest = ^void(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
        NSLog(@"%@",response.rawData);
    };
    
    networking.url(@"http://myip.ipip.net").name(@"请求2").params(@{@"test":self.page}).executeRequest = ^void(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
        NSLog(@"%@",response.rawData);
    };
    
    networking.url(@"http://myip.ipip.net").name(@"请求3").params(@{@"test":self.page}).executeRequest = ^void(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
        NSLog(@"%@",response.rawData);
    };
    
    networking.url(@"http://myip.ipip.net").name(@"请求4").params(@{@"test":self.page}).executeRequest = ^void(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
        NSLog(@"%@",response.rawData);
    };
    
    networking.url(@"http://myip.ipip.net").name(@"请求5").params(@{@"test":self.page}).executeRequest = ^void(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
        NSLog(@"%@",response.rawData);
    };
    
    networking.url(@"http://myip.ipip.net").name(@"请求6").params(@{@"test":self.page}).executeRequest = ^void(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
        NSLog(@"%@",response.rawData);
    };
    
    networking.url(@"http://myip.ipip.net").name(@"请求7").params(@{@"test":self.page}).executeRequest = ^void(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
        NSLog(@"%@",response.rawData);
    };
    
//    networking.url(@"http://myip.ipip.net").name(@"haha").params(@{@"test":self.page}).cacheStrategy(ALCacheStrategyNetworkOnly).responseType(ALNetworkResponseTypeHTTP).executeRequest = ^void(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
//        //        ALNetworkResponse *response = x.first;
//        //        ALNetworkRequest *request = x.second;
//        NSLog(@"%@ %zd %@",request.params,response.isCache,error);
//        NSString *string = [[NSString alloc] initWithData:response.rawData encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",string);
//    };
    
//    self.networking = networking;
}

- (void)dealloc
{
    NSLog(@"%@ DEALLOC",self);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
