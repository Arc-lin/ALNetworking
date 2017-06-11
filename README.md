ALNetworking
==========

![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)
![Pod version](https://img.shields.io/cocoapods/v/ALNetworking.svg?style=flat)
[![Platform info](https://img.shields.io/cocoapods/p/ALNetworking.svg?style=flat)](http://cocoadocs.org/docsets/ALNetworking)
![Platform version](https://img.shields.io/badge/iOS_Version->8.0-red.svg)

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
pod 'YTKNetwork'
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

### url() & url_x()

`url()`   : Combine perfix with the content as url

`url_x()` : Only use conent as url

### params() & paramsDic()

`params()`    : Input a Dictionary as parameters

`paramsDic()` : It is a macro. Use object name as key, object value as value

### url(xxx).paramsDic(a,b).method(ALNetworkRequestMethodGET) ===> get(xxx,a,b)

On the same

`url(xxx).paramsDic(a,b).method(ALNetworkRequestMethodPOST)` can be written as `post(xxx,a,b)` 

`url_x(xxx).paramsDic(a,b).method(ALNetworkRequestMethodPOST)` can be written as `post_x(xxx,a,b)` 

and so on. 

### example1 (Without url prefix)

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

### example2 (With url prefix, try to use cache stategy)
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
