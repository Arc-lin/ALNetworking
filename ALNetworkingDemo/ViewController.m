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
    
    // 示例1 : EXAMPLE 1
    @weakify(self);
    [[self.btn1 rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self example1];
    }];
   
    // 示例2 : EXAMPLE 2
    [[self.btn2 rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self example2];
    }];
    
    
    // 拦截错误 HANDLE THE ERROR
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
        那么你就可以配置一个带有message,status,content属性的请求体,这样子就可以方便地取出想要的内容
     2. 开发过程中可能需要用到其他服务器的数据(判断依据是你使用了url_x()去设置url),那么这时候框架会忽略你设置好的自定义的响应体类,返回的就是ALNetworkingResponse的对象
     3. 自定义响应体类建议继承自ALNetworkingResponse
     */
    
    /** 
     Why you need a custom response class ?
     1. If your server interface return json is base on some format like
        {"message":"Success","status":"1000","content":"Register Success"}.
        Then you can create a class which has the properties message, status,content, then you can get the value you want expediently.
     2. When you use `url_x()` to set up an url (Normally is an url from third party),the framework will ignore your custom response class, reutrn ALNetworkingResponse obj
     3. Custom response class should be inherit from ALNetworkingResponse
     */
    
    // 写法1
    RACSignal *example1 = self.networking
                              .url(@"http://ip.taobao.com/service/getIpInfo.php")
                              .params(@{@"ip":@"192.168.0.103"})
                              .executeSignal();
    
    // 写法2 使用 NSDictionaryOfVariableBindings() 将对象名作为键,对象的值作为值,组成字典
    // Use NSDictionaryOfVariableBindings() object key as key, object value as value ,generate a dictionary
    NSString *ip = @"192.168.0.103";
    RACSignal *example1_1 = self.networking
                                .url(@"http://ip.taobao.com/service/getIpInfo.php")
                                .paramsDic(ip)
                                .executeSignal();
    
    // 写法3 针对不同类型的请求,可以设定请求方式和请求体类型
    // Setting different request method and different type of parameters
    RACSignal *example1_2 = self.networking
                                .url(@"http://ip.taobao.com/service/getIpInfo.php")
                                .paramsDic(ip)
                                .paramsType(ALNetworkRequestParamsTypeJSON)
                                .method(ALNetworkRequestMethodGET)
                                .executeSignal();
    
    // 写法4 使用封装好的宏替代掉method()的约束  参数1是URL,参数2到参数x是请求参数
    
    // Use marco to save your code!  url(xxx).paramsDic(a,b).method(ALNetworkRequestMethodGET) ===> get(xxx,a,b)
    
    RACSignal *example1_3 = self.networking
                                .get(@"http://ip.taobao.com/service/getIpInfo.php",ip)
                                .paramsType(ALNetworkRequestParamsTypeJSON)
                                .executeSignal();
    
    // Subscribe Signal
    [example1 subscribeNext:^(RACTuple *x) {
        ALNetworkingRequest *request = x.first;
        ALNetworkingResponse *response = x.second;
        NSLog(@"%@\n%zd\n%zd\n%@",request.urlStr,request.cacheStrategy,request.paramsType,response.rawData);
    }];
}

- (void)example2
{
    // 大概用例像上面差不多,把get_x()改为了get()就可以使用url前缀
    
    // USE URL Perfix  Change get_x() to get()   url_x() to url()
    NSString *Id = @"1";
    NSString *name = @"22";
    RACSignal *example2 = self.networking
                              .get(@"product/banner",Id,name)
                              .executeSignal();
    
    // 使用缓存策略 有六种,可以自己找个API试一下
    // There are six cache stategies, find a API and have a try
    RACSignal *example2_1 = self.networking
                                .get(@"product/banner",Id,name)
                                .cacheStrategy(ALCacheStrategy_AUTOMATICALLY)
                                .executeSignal();
    
    [example2_1 subscribeNext:^(RACTuple *x) {
        ALNetworkingRequest *request = x.first;
        // If you haven't configure a custom response class , it will be an ALNetworkingResponse object
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
