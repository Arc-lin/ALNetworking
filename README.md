ALNetworking
==========

![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)
![Pod version](https://img.shields.io/cocoapods/v/ALNetworking.svg?style=flat)
[![Platform info](https://img.shields.io/cocoapods/p/ALNetworking.svg?style=flat)](http://cocoadocs.org/docsets/ALNetworking)
![Platform version](https://img.shields.io/badge/iOS_Version->8.0-red.svg)

## 这是什么

ALNetworking 是一个基于AFNetworking的网络层框架。通过它，我们可以使用链式调用的方式去构建一个网络请求。并且支持动态配置，支持插件化拓展，支持请求体和响应体的hook，支持缓存（基于`YYCache`），支持ReactiveCocoa方式的调用和普通方式调用等等，另外你也可以根据自己的需求，拓展出[`协程`](https://github.com/alibaba/coobjc)方式的调用，下文会阐述如何封装。

另外该框架也提供了json转模型和模型数组（基于`MJExtension`），你可以选择性使用，如果想改成`YYModel`或自己的方式进行转换的话，可以参照实现。

除此之外，该框架还提供了请求日志查看的功能（仅记录该框架发起的网络请求），你可以选择性使用。

## 环境要求

```
iOS 9.0 +
AFNetworking 4.0.0+
YYCache 1.0.4+
```

`RAC`拓展

```
ReactiveObjC 3.1.1+
```

`RAC_MJ`拓展

```
MJExtension 3.2.1+
```


## 安装

把下面这个东西写进你的`podfile`

```
pod 'ALNetworking/Core'
```

引入ReactiveCocoa

```
pod 'ALNetworking/RAC'
```

引入json和模型转换工具

```
pod 'ALNetworking/RAC_MJ'
```

引入网络请求日志工具

```
pod 'ALNetworking/Recorder'
```

## 文件结构

- Core或者RAC

|类名|说明|
|---|---|
|ALAPIClient|封装`AFHTTPSessionManager`的类，将`AFHTTPSessionManager`单例化，解决`AFNetworking`存在的内存泄露问题|
|ALBaseNetworking|底层封装AFNetworking的类|
|ALNetworkCache|封装YYCache的类|
|ALNetworking|入口类，网络请求要发起的时候需要实例化这个类|
|ALNetworkingConfig|基础配置类|
|ALNetworkingConst|枚举和一些方便的宏定义|
|ALNetworkingRequest|请求体|
|ALNetworkingResponse|响应体|
|ALNetworkResponseSerializer|用不同的类型解析响应体|
|NSDictionary+ALNetworking|封装字典，防止穿空指针构建字典的时候崩溃|

- RAC_MJ

|类名|说明|
|---|---|
|ALBlockTrampoline|数组转block回调|
|RACSignal+ALNetworking|通过MJExtension将响应体转为模型或模型数组|

- UI

|类名|说明|
|---|---|
|ALURLRecordManager|单例，用于记录网络请求日志|
|ALURLRecordsViewController|网络请求日志列表控制器|
|ALURLRecordDetailViewController|网络请求日志详情页|

## 基础用法

1. 使用配置类，配置全局的网络请求配置（可选择性赋值）

	```
	ALNetworkingConfig *config = [ALNetworkingConfig defaultConfig];
	/// 网络请求接口的前缀
   config.defaultPrefixUrl = @"https://example.com/api";
   /// 超时时间
   config.timeoutInterval = 10; 
   /// 默认的缓存机制，默认不缓存
   config.defaultCacheStrategy = ALCacheStrategyNetworkOnly;
   /// 是否要区分业务错误和网络错误，默认为true，具体内容看注释
   config.distinguishError = YES;
   /// 全局的默认请求头
   config.defaultHeader = @{};
   /// 全局的参数
   config.defaultParams = @{};
   /// 动态请求头，每次请求都会执行一次这个block，然后把返回值拼接到请求头中，一般用于请求加密添加Authorization参数
   config.dynamicHeaderConfig = ^NSDictionary *(ALNetworkRequest *request) {
        return @{};
   };
   /// 动态请求参数，每次请求都会执行一次这个block，然后把返回值拼接到请求参数中
   config.dynamicParamsConfig = ^NSDictionary *(ALNetworkRequest *request) {
        return @{};
   };
	```
	
2. 创建一个networking对象，建议每个界面创建一个对象单独管理（可选择性赋值）
	
	```
	ALNetworking *networking = [[ALNetworking alloc] init];
	   /// 配置接口请求链接的前缀，优先级比ALNetworkingConfig高
	   networking.prefixUrl = @"https://v1.alapi.cn/api";
	   /// 默认请求头，优先级比ALNetworkingConfig高
	   networking.defaultHeader = @{};
	   /// 默认请求参数，优先级比ALNetworkingConfig高
	   networking.defaultParams = @{};
	   /// 决定了ALNetworkingConfig内配置的公共参数，是否要以query string的方式拼接到接口链接上，默认为否
	   networking.configParamsMethod = ALNetworkingCommonParamsMethodFollowMethod;
	   /// 决定了networking对象配置的公共参数，是否要以query string的方式拼接到接口链接上，默认为否
	   networking.defaultParamsMethod = ALNetworkingCommonParamsMethodFollowMethod;
	   /// 动态请求头，每次请求都会执行一次这个block，然后把返回值拼接到请求头中
	   networking.dynamicHeaderConfig = ^NSDictionary *(ALNetworkRequest *request) {
		return @{};
	    };
	  /// 动态请求参数，每次请求都会执行一次这个block，然后把返回值拼接到请求参数中
	  networking.dynamicParamsConfig = ^NSDictionary *(ALNetworkRequest *request) {
		return @{};
	   };
	  /// 是否要忽略ALNetworkingConfig内配置的公共请求头
	  networking.ignoreDefaultHeader = NO;
	  /// 是否要忽略ALNetworkingConfig内配置的公共请求参数
	  networking.ignoreDefaultParams = NO; 
	  /// 处理响应，一般用来判断业务逻辑，这里假设业务接口返回的数据结构为{"code":200,"msg":"","data":{}} 
	  networking.handleResponse = ^NSError *(ALNetworkResponse *response, ALNetworkRequest *request) {
		   if ([response.rawData isKindOfClass:NSDictionary.class]) {
			/// 简单判断一下业务返回200的时候才是正确的情况
			NSInteger code = [response.rawData[@"code"] integerValue];
			if (code != 200) {
			    return [NSError errorWithDomain:@"domain" code:code userInfo:@{
				NSLocalizedDescriptionKey : [NSString stringWithFormat:@"%@",response.rawData[@"msg"]?:@""]
			    }];
			} else {
			    /// 只拿出有用的数据返回出去
			    response.rawData = response.rawData[@"data"];
			}
		    }
		    /// 返回nil表示正常，返回NSError认为是业务错误
		    return nil;
	   };
	   /// 在请求之前拦截一下请求体
	   networking.handleRequest = ^ALNetworkRequest *(ALNetworkRequest *request) {
	   	return request; // 如果返回nil的话，则不执行请求
	   };
	   /// 发生链路上的错误，比如404、403等，也有可能是500等服务器的错误
	   networking.handleError = ^(ALNetworkRequest *request, ALNetworkResponse *response, NSError *error) {
	   
	   };
	```
	
3. 创建一个GET请求（每次调用`request`方法都会创建一个新的请求对象）

	```
	networking.request.get(@"/new/wbtop").executeRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
	
	};
	```

4. ALNetworkResponse参数说明
	- isCache 表示本次响应结果是否来自缓存
	- rawData 表示本次请求的响应体，可以在`networking.handleResponse`内被修改
	
5. 由于创建请求我们采用了链式调用的方法，所以我们在步骤三那里还可以选择性地补充很多配置，如下

	- 带参数的请求
	
	```
	networking.request.get(@"/example").params(@{@"page":@1});
	/// 也可以这么写
	NSNumber *page = @1;
	networking.request.GET(@"/new/wbtop",page);
	```
	
	- 其他请求方式

	```
	networking.request.get(@"/example");
	networking.request.post(@"/example");
	networking.request.put(@"/example");
	networking.request.delete(@"/example");
	networking.request.patch(@"/example");
	```
	
	- 以此类推，提供了如下链式方法，具体参数和描述参考`ALNetworkRequest.h`

	|方法|描述|
	|---|---|
	|header()|请求头|
	|params()|请求参数|	
	|url()|接口|
	|prams()|参数|
	|method()|请求方式|
	|responseType()|指定响应体的类型，即rawData的数据类型|
	|cacheStrategy()|缓存方式|
	|minRepeatInterval()|两次调用该请求之间的最短时间间隔|
	|mockData()|模拟返回数据，不请求网络接口，直接返回传入的值|
	|paramsType()|参数的传递类型|
	|name()|给该请求一个唯一标识符，取消请求的时候可以传入这个标识符取消|
	|disableDynamicParams()|忽略动态参数的配置|
	|disableDynamicHeader()|忽略动态请求头的配置|
	|handleRequest|不要赋值|
	|handleResponse|不要赋值|
	
6. 文件上传

	```
	NSString *fileName = @"唯一id";
   NSData *data = UIImagePNGRepresentation([UIImage imageNamed:@"40icon_friends"]);
	networking
	.request
   .post(@"https://example.com/api/upload")
   .fileFieldName(@"smfile") // 后端的上传字段名
   .uploadData(data,fileName,@"image/png") // 参数1是数据，参数2是文件名，参数3是文件的MIME type
   .executeUploadRequest = ^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
        if (response) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response.rawData options:NSJSONReadingMutableContainers error:nil];
            result = dic[@"code"];
        }
    };
	```
	
7. 文件下载
	
	```
	NSString *filePath = [[NSString alloc] initWithString:NSHomeDirectory()];
   filePath = [filePath stringByAppendingPathComponent:@"Documents"]; /// 拼接出下载地址，示例而已，请不要学我这么写
   networking.request
   .downloadDestPath(filePath)
   .responseType(ALNetworkResponseTypeImage)
   .get(@"下载地址")
   .executeDownloadRequest = ^(NSString *destination, ALNetworkRequest *request, NSError *error) {
        NSLog(@"Path --- %@",destination);
   };
	```

8. 其他使用方法可以参考Demo中`Test.m`的测试用例

## 头部和参数优先级说明

优先级表示，当各个地方配置了相同的key值的内容的话，取哪个为准的问题

- 首先，我们有5个地方可以配置头部信息，以下排列优先级从低到高，分别是
	- `ALNetworkingConfig`单例的`defaultHeader`
	- `ALNetworking`实例对象的`defaultHeader`
	- `ALNetworkingConfig`单例的`dynamicHeaderConfig`
	- `ALNetworking`实例对象的`dynamicHeaderConfig`
	- `ALNetworkRequest`请求调用链中的`header()`

- 同理，配置公共参数也有5个地方，以下排列优先级从低到高，分别是
	- `ALNetworkingConfig`单例的`defaultParams`
	- `ALNetworking`实例对象的`defaultParams`
	- `ALNetworkingConfig`单例的`defaultParamsConfig`
	- `ALNetworking`实例对象的`defaultParamsConfig`
	- `ALNetworkRequest`请求调用链中的`params()`

- 另外，在`ALNetworking`实例对象中，`ignoreDefaultHeader`可以忽略Config中配置的默认请求头，`ignoreDefaultParams`参数可以忽略Config中配置的默认请求参数，`ALNetworkRequest `请求调用链`disableDynamicHeader`、`disableDynamicParams`分别可以忽略动态请求头和动态请求参数。

## ReactiveCocoa + MJExtension方式使用

## ReactiveCocoa + YYModel 方式使用

## 请求日志使用

## 证书

ALNetworking 使用的是MIT证书,详情见LICENSE文件.
