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
#import "SVProgressHUD.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;

@property (nonatomic, strong) ALNetworking *networking;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setMaximumDismissTimeInterval:1.0f];
    
    // 示例1 : 淘宝接口:不使用配置好的前缀.有请求参数
    @weakify(self);
    [[self.btn1 rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self example1];
    }];
   
    // 示例2 : 使用配置好的前缀
    [[self.btn2 rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self example2];
    }];
    
    
    // 拦截错误
    [self.networking.errors subscribeNext:^(NSError *x) {
        [SVProgressHUD showErrorWithStatus:x.localizedDescription];
    }];

}

- (void)example1
{
    /**
     自定义响应体类的作用 :
     1. 如果你的服务器返回的json是带有一定格式的如 
        {"message":"注册成功","status":"1000","content":"Register Success"}
        那么你就可以配置一个带有message,status,conten属性的请求体,这样子就可以方便地取出想要的内容
     2. 开发过程中可能需要用到其他服务器的数据,那么这时候不能使用自定义的响应体类,返回的就是ALNetworkingResponse的对象
     3. 自定义响应体类建议继承自ALNetworkingResponse
     */
    
    // 写法1
    RACSignal *example1 = self.networking
                              .url_x(@"http://ip.taobao.com/service/getIpInfo.php")
                              .params(@{@"ip":@"192.168.0.103"})
                              .executeSignal();
    
    // 写法2 使用 NSDictionaryOfVariableBindings() 将对象名作为键,对象的值作为值,组成字典
    NSString *ip = @"192.168.0.103";
    RACSignal *example1_1 = self.networking
                                .url_x(@"http://ip.taobao.com/service/getIpInfo.php")
                                .paramsDic(ip)
                                .executeSignal();
    
    // 写法3 针对不同类型的请求,可以设定请求方式和请求体类型
    RACSignal *example1_2 = self.networking
                                .url_x(@"http://ip.taobao.com/service/getIpInfo.php")
                                .paramsDic(ip)
                                .paramsType(ALNetworkRequestParamsTypeJSON)
                                .method(ALNetworkRequestMethodGET)
                                .executeSignal();
    
    // 写法4 使用封装好的宏替代掉method()的约束  参数1是URL,参数2到参数x是请求参数
    RACSignal *example1_3 = self.networking
                                .get_x(@"http://ip.taobao.com/service/getIpInfo.php",ip)
                                .paramsType(ALNetworkRequestParamsTypeJSON)
                                .executeSignal();
    
    [example1 subscribeNext:^(RACTuple *x) {
        ALNetworkingRequest *request = x.first;
        ALNetworkingResponse *response = x.second;
        NSLog(@"%@\n%zd\n%zd\n%@",request.urlStr,request.cacheStrategy,request.paramsType,response.rawData);
    }];
}

- (void)example2
{
    // 大概用例像上面差不多,把get_x()改为了get()就可以使用url前缀
    NSString *Id = @"1";
    NSString *name = @"22";
    RACSignal *example2 = self.networking
                              .get(@"product/banner",Id,name)
                              .executeSignal();
    
    // 使用缓存策略 有六种,可以自己找个API试一下
    RACSignal *example2_1 = self.networking
                                .get(@"product/banner",Id,name)
                                .cacheStrategy(ALCacheStrategy_AUTOMATICALLY)
                                .executeSignal();
    
    [example2_1 subscribeNext:^(RACTuple *x) {
        ALNetworkingRequest *request = x.first;
        ALMyHTTPResponse *response = x.second; // 如果没有配置自定义响应体类的话,就会返回ALNetworkingResponse的对象
        NSLog(@"%@\n%zd\n%zd\n%@",request.urlStr,request.cacheStrategy,request.paramsType,response.rawData);
    }];
}

- (ALNetworking *)networking
{
    if (!_networking) {
        _networking = [ALNetworking sharedInstance];
    }
    return _networking;
}

- (void)dealloc
{
    NSLog(@"dealloc");
}


@end
