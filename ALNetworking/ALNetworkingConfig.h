//
//  ALNetworkingConfig.h
//  ALNetworkingDemo
//
//  Created by Arclin on 2017/3/16.
//  Copyright © 2017年 dankal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACSignal,RACTuple,ALNetworkingResponse;

typedef RACSignal *(^ALHandleResponse)(RACTuple *value);

typedef void(^ALCustomLog)(NSString *logText);

typedef NSError *(^ALHandleLinkError)(NSError *error);

@interface ALNetworkingConfig : NSObject

/** 统一请求头 */
/** Common Header */
@property (nonatomic, strong) NSDictionary         *defaultHeader;

/** 统一参数 */
/** Common Parameters */
@property (nonatomic, strong) NSDictionary         *defaultParams;

/** 配置SSL证书路径 */
/** Setup SSL Certificates path */
@property (nonatomic, copy)   NSString             *sslCerPath;

/** URL前缀,需要调用url()才会使用这个前缀 */
/** URL Prefix , need to use url() */
@property (nonatomic, copy)   NSString             *urlPerfix;

/** 自定义Log输出,默认NSLog */
/** Custom Log, default is NSLog **/
@property (nonatomic, copy)   ALCustomLog           customLog;

/** 处理回调的请求 */
/** Handle the response */
@property (nonatomic, copy)   ALHandleResponse      handleResponse;

/** 处理服务器返回的错误和本地连接的错误 */
/** Handle the error comes from server and network exception */
@property (nonatomic, copy)   ALHandleLinkError     handleError;

/** 自定义的响应体映射类 */
/** Custom the response class */
@property (nonatomic)         Class customRespClazz;

/** 弹出历史记录的手势 */
/** The getsure to pop the history record */
@property (nonatomic, strong) UIGestureRecognizer *gesture;

/** 不弹出历史记录的控制器名 */
/** Don't pop history controllers */
@property (nonatomic, strong) NSArray<NSString *> *noHistoryControllerNames;

/** 调试模式,默认NO 
 *  1. 记录请求
 *  2. 如果服务器端发生异常,返回异常的HTML代码,则弹出webView进行显示
 *  3. 输出Log
 */
/** If YES , you can show the history , pop webview to show server's error , print the log */
@property (nonatomic, assign) BOOL               debugMode;

/** 超时时间,默认30s */
/** Timeout interval */
@property (nonatomic, assign) float              timeoutInterval;

@end
