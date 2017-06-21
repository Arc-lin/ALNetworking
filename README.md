ALNetworking
==========

![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)
![Pod version](https://img.shields.io/cocoapods/v/ALNetworking.svg?style=flat)
[![Platform info](https://img.shields.io/cocoapods/p/ALNetworking.svg?style=flat)](http://cocoadocs.org/docsets/ALNetworking)
![Platform version](https://img.shields.io/badge/iOS_Version->8.0-red.svg)

[English Version](#jump)

## 这是什么

ALNetworking 是一个基于AFNetworking的框架. __只能基于ReactiveCocoa(2.5版本)环境下使用__.


## 特性

1. 支持6种缓存方式,可以满足很多业务需求(基于 [YYCache](https://github.com/ibireme/YYCache))
2. 你可以按住屏幕两秒左右或者自定义手势,去展示你的历史请求,方便debug
3. 链式调用,为了代码比较好看
4. 如果服务器抛出了异常界面,那么框架会直接弹出界面展示异常信息(如果开了Debug模式的话),方便后端人员debug
5. 你可以使用自定义的响应体类,框架会自动帮你转换 (基于 [YYModel](https://github.com/ibireme/YYModel))
6. 成功的回调框架会返回`RACSignal`,里面包装这请求体和响应体,错误信息统一通过`RACSubject`回调,你可以统一处理,比如弹出HUD
7. 关于响应体,如果你有自定义响应体(建议继承自`ALNetworkingResponse`)的话,那么就会返回你的自定义响应体的对象,如果没有的话,那就是默认的`ALNetworkingResponse`
8. 看demo,里面有很多注释,能够帮助你使用框架


## 为什么只能在ReactiveCocoa环境下使用
 
MVVM架构现在这么火, 而ReactiveCocoa对于MVVM架构又这么好用,所以我就想写一个针对RAC的网络层框架.

之后我会写一个Demo详细介绍MVVM结合这套框架的使用

如果你会使用RAC的话,那么你可以使用 `merge:` `concat:` `zip:` 等方法进行接口的串联,并联等,这对于一个界面多个请求的需求很有用.


## 安装

把下面这个东西写进你的`podfile`

```
pod 'ALNetworking'
```

ALNetworking 是基于AFNetworking 3.x 的. 更多详情看[AFNetworking README](https://github.com/AFNetworking/AFNetworking).

## 文件结构

```
.
├── ALNetworking.h   ................... 主要的入口文件
├── ALNetworking.m
├── ALNetworkingBaseManager.h .......... 真正的请求方法在里面
├── ALNetworkingBaseManager.m
├── ALNetworkingCache.h  ............... 缓存类
├── ALNetworkingCache.m
├── ALNetworkingConfig.h ............... 一些全局的配置
├── ALNetworkingConfig.m
├── ALNetworkingConst.h ................ 一些枚举和常量
├── ALNetworkingConst.m 
├── ALNetworkingDetail.html ............ 历史记录的展示模板
├── ALNetworkingRequest.h .............. 封装请求体
├── ALNetworkingRequest.m 
├── ALNetworkingResponse.h ............. 封装响应体
├── ALNetworkingResponse.m
├── ALNetworkingViewController.h ....... 历史记录和webview的控制器
├── ALNetworkingViewController.m
├── NSDictionary+Log.m  ................ 把一些URL编码的字符转成中文
├── UIViewController+ALExtension.h ..... 拦截viewDidApper 目的是为了加上手势
└── UIViewController+ALExtension.m 
```

## 怎么用

__这里有一个[简单的MVVM+RAC使用示例](https://github.com/Arc-lin/ALMVVMDemo)__

### url() 

`url()`   : 请求的时候会在该内容前面加上一个自定义的前缀拼成Url,如果有`https://` 或者 `http://`前缀的话,就不会拼上自定义的前缀,如果这种处理方式不当的话请告知我

### params() & paramsDic()

`params()`    : 传入一个字典作为参数

`paramsDic()` : 这是一个宏,把对象名作为键,对象的值做为字典的值

### url(xxx).paramsDic(a,b).method(ALNetworkRequestMethodGET) ===> get(xxx,a,b)

同样道理

`url(xxx).paramsDic(a,b).method(ALNetworkRequestMethodPOST)` 也可以写成 `post(xxx,a,b)` 


等等

__一些配置信息写在了AppDelegate,请下载Demo查看__

### example1 

```
 // example1
 RACSignal *example1 = self.networking
                           .url_x(@"http://ip.taobao.com/service/getIpInfo.php")
                           .params(@{@"ip":@"192.168.0.103"})
                           .executeSignal();
    
 // example1_1 
 NSString *ip = @"192.168.0.103";
 RACSignal *example1_1 = self.networking
                             .url_x(@"http://ip.taobao.com/service/getIpInfo.php")
                             .paramsDic(ip)
                             .executeSignal();
    
 // example1_2 
 RACSignal *example1_2 = self.networking
                             .url_x(@"http://ip.taobao.com/service/getIpInfo.php")
                             .paramsDic(ip)
                             .paramsType(ALNetworkRequestParamsTypeJSON)
                             .method(ALNetworkRequestMethodGET)
                             .executeSignal();
    
 // example1_3
 RACSignal *example1_3 = self.networking
                             .get_x(@"http://ip.taobao.com/service/getIpInfo.php",ip)
                             .paramsType(ALNetworkRequestParamsTypeJSON)
                             .executeSignal();


[example1 subscribeNext:^(RACTuple *x) {
        ALNetworkingRequest *request = x.first;
        ALNetworkingResponse *response = x.second;
        NSLog(@"%@\n%zd\n%zd\n%@",request.urlStr,request.cacheStrategy,request.paramsType,response.rawData);
}];

```

### 示例2 (试试使用缓存策略)
```
NSString *Id = @"1";
NSString *name = @"22";
RACSignal *example2 = self.networking
                              .get(@"product/banner",Id,name)
                              .executeSignal();
    
// There are six cache stategies, you can find an API to try
RACSignal *example2_1 = self.networking
                            .get(@"product/banner",Id,name)
                            .cacheStrategy(ALCacheStrategy_AUTOMATICALLY)
                            .executeSignal();
    
[example2_1 subscribeNext:^(RACTuple *x) {
    ALNetworkingRequest *request = x.first;
    ALMyHTTPResponse *response = x.second;
    NSLog(@"%@\n%zd\n%zd\n%@",request.urlStr,request.cacheStrategy,request.paramsType,response.rawData);
 }];
```


## 证书

ALNetworking 使用的是MIT证书,详情见LICENSE文件.

---
---
---

<span id="jump"></span>

## What

ALNetworking is a networking framework base on AFNetworking. __Only use for ReactiveCocoa environment__. Develop by personal developer.

## Features

1. Support 6 cache stategies, can be satisified with various of business requires.(Base on [YYCache](https://github.com/ibireme/YYCache) framework)
2. Support check request histories, you can press screen for about 2 seconds to show a view of histories, or you can custom your own gestures.
3. Support chaining commands, this is good for readability.
4. Support cover response data to custom class automaticlly.(Base on [YYModel](https://github.com/ibireme/YYModel) framework)
5. If there is an error occurred by the server, and you just turn on the debug mode. It will show a view controller with UIWebView to show the error page. That is useful if your server is build up by ThinkPHP or Express.
6. Success callback comes from `RACSignal` ,error callback comes from `RACSubject`
7. Success callback --- RACSinal , what in it is a RACTuple object, it contains an ALNetworkingRequest and an ALNetworkingResponse , if you have already configured a custom response class, ALNetworkingResponse will be replace to your response class.

## Why ReactiveCocoa Only
 
MVVM is a popular architecture, and ReactiveCocoa is a good framework for FRP( Functional Reactive Programming). So I want to design a network layer's framework for RAC.

According to RAC, you can use `merge:` `concat:` `zip:` an so on to execute multiple requests. This is useful for a page with multiple requests. 

## Installation

To use ALNetworking add the following to your Podfile

```
pod 'ALNetworking'
```

ALNetworking is based on AFNetworking. You can find more detail about version compability at [AFNetworking README](https://github.com/AFNetworking/AFNetworking).

## Architecture

```
.
├── ALNetworking.h   ................... Main Entrance
├── ALNetworking.m
├── ALNetworkingBaseManager.h .......... True Request Class
├── ALNetworkingBaseManager.m
├── ALNetworkingCache.h  ............... Cache Class
├── ALNetworkingCache.m
├── ALNetworkingConfig.h ............... Some Global Config of Request and Response
├── ALNetworkingConfig.m
├── ALNetworkingConst.h ................ Enumerations and other const variables
├── ALNetworkingConst.m 
├── ALNetworkingDetail.html ............ Template for request histories
├── ALNetworkingRequest.h .............. Encapsulation request
├── ALNetworkingRequest.m 
├── ALNetworkingResponse.h ............. Encapsulation response
├── ALNetworkingResponse.m
├── ALNetworkingViewController.h ....... History viewController and WebViewController
├── ALNetworkingViewController.m
├── NSDictionary+Log.m  ................ Conver url encode to Chinese
├── UIViewController+ALExtension.h ..... AOP. Add gesture when viewDidAppear
└── UIViewController+ALExtension.m 
```

## How to use

__Here has a simple example for [MVVM+RAC](https://github.com/Arc-lin/ALMVVMDemo)__

### url()

`url()`   : Combine perfix with the content as url, if you have a prefix of `https://` or `http://`, you will not have custom prefix attached. If this is not handled properly, please let me know

### params() & paramsDic()

`params()`    : Input a Dictionary as parameters

`paramsDic()` : It is a macro. Use object name as key, object value as value

### url(xxx).paramsDic(a,b).method(ALNetworkRequestMethodGET) ===> get(xxx,a,b)

On the same

`url(xxx).paramsDic(a,b).method(ALNetworkRequestMethodPOST)` can be written as `post(xxx,a,b)` 


and so on. 

__Some configure message is write on AppDelegate,please download the Demo to check__

__There are more messages in the demo , please download the demo and read it__

### example1

```
 // example1
 RACSignal *example1 = self.networking
                           .url_x(@"http://ip.taobao.com/service/getIpInfo.php")
                           .params(@{@"ip":@"192.168.0.103"})
                           .executeSignal();
    
 // example1_1 
 NSString *ip = @"192.168.0.103";
 RACSignal *example1_1 = self.networking
                             .url_x(@"http://ip.taobao.com/service/getIpInfo.php")
                             .paramsDic(ip)
                             .executeSignal();
    
 // example1_2 
 RACSignal *example1_2 = self.networking
                             .url_x(@"http://ip.taobao.com/service/getIpInfo.php")
                             .paramsDic(ip)
                             .paramsType(ALNetworkRequestParamsTypeJSON)
                             .method(ALNetworkRequestMethodGET)
                             .executeSignal();
    
 // example1_3
 RACSignal *example1_3 = self.networking
                             .get_x(@"http://ip.taobao.com/service/getIpInfo.php",ip)
                             .paramsType(ALNetworkRequestParamsTypeJSON)
                             .executeSignal();


[example1 subscribeNext:^(RACTuple *x) {
        ALNetworkingRequest *request = x.first;
        ALNetworkingResponse *response = x.second;
        NSLog(@"%@\n%zd\n%zd\n%@",request.urlStr,request.cacheStrategy,request.paramsType,response.rawData);
}];

```

### example2 (Try to use cache stategy)
```
NSString *Id = @"1";
NSString *name = @"22";
RACSignal *example2 = self.networking
                              .get(@"product/banner",Id,name)
                              .executeSignal();
    
// There are six cache stategies, you can find an API to try
RACSignal *example2_1 = self.networking
                            .get(@"product/banner",Id,name)
                            .cacheStrategy(ALCacheStrategy_AUTOMATICALLY)
                            .executeSignal();
    
[example2_1 subscribeNext:^(RACTuple *x) {
    ALNetworkingRequest *request = x.first;
    ALMyHTTPResponse *response = x.second;
    NSLog(@"%@\n%zd\n%zd\n%@",request.urlStr,request.cacheStrategy,request.paramsType,response.rawData);
 }];
```


## License

ALNetworking is available under the MIT license. See the LICENSE file for more info.
