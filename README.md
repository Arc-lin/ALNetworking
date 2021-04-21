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

引入json和模型转换工具

```
pod 'ALNetworking/RAC_MJ'
```

引入网络请求日志工具

```
pod 'ALNetworking/Recorder'
```

## 文件结构

- Core/RAC

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

## 证书

ALNetworking 使用的是MIT证书,详情见LICENSE文件.
