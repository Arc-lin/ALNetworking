//
//  ViewController.m
//  ALNeetworkingDemo
//
//  Created by Arclin on 2017/5/30.
//  Copyright © 2017年 arclin. All rights reserved.
//

#import "ViewController.h"
#import "ALNetworking.h"
#import "ALMyHTTPResponse.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ALNetworking *networking = [ALNetworking sharedInstance];
    [networking.errors subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    NSString *page = @"1";
    
    RACSignal *signal = networking.header(@{@"token":@"a33c85e2b45ec60f7f96727f3f2ad886"}).url_x(@"http://www.idragonstarapp.com/api/video/choice").paramsDic(page).paramsType(ALNetworkRequestParamsTypeDictionary).executeSignal();
    
    [signal subscribeNext:^(RACTuple *x) {
        ALNetworkingRequest *request = x.first;
        ALMyHTTPResponse *response = x.second;
        NSLog(@"%@\n%zd\n%zd\n%@",request.urlStr,request.cacheStrategy,request.paramsType,response.content);
    }];
    
}

- (void)dealloc
{
    NSLog(@"dealloc");
}


@end
