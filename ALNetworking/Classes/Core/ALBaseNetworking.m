//
//  MMCBaseNeetworking.m
//  BaZiPaiPanSDK
//
//  Created by Arclin on 2018/4/21.
//

#import "ALBaseNetworking.h"

#import "ALNetworkRequest.h"
#import "ALNetworkResponse.h"

#import "ALNetworkCache.h"
#import "ALNetworkingConfig.h"
#import "ALNetworkResponseSerializer.h"

#import "ALAPIClient.h"

@implementation ALBaseNetworking

+ (NSURLSessionTask *)requestWithRequest:(ALNetworkRequest *)req mockData:(id)mockData success:(void (^)(ALNetworkResponse *, ALNetworkRequest *))success failure:(void (^)(ALNetworkRequest *, BOOL, id, NSError *))failure
{
    __block NSURLSessionDataTask *dataTask = nil;
    
    if (mockData) {
        [self mockWithRequest:req mockData:mockData success:success];
        return nil;
    }
    
    switch (req.cacheStrategy) {
        case ALCacheStrategyNetworkOnly:
            dataTask = [self networkWithRequest:req success:success failure:failure];
            break;
        case ALCacheStrategyCacheOnly:
            [self cacheWithRequest:req success:success failure:failure];
            break;
        case ALCacheStrategyCacheThenNetwork: {
            [self cacheWithRequest:req success:success failure:failure];
            dataTask = [self taskWithRequest:req cacheMemoryOnly:NO success:success failure:failure];
        }
            break;
        case ALCacheStrategyAutomatic: {
            __weak typeof(self) weakSelf = self;
            dataTask = [self taskWithRequest:req cacheMemoryOnly:NO success:success failure:^(ALNetworkRequest *request,BOOL isCache,id responseObject,NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf cacheWithRequest:req success:success failure:failure];
            }];
        }
            break;
        case ALCacheStrategyCacheAndNetwork: {
            __weak typeof(self) weakSelf = self;
            [self cacheWithRequest:req success:^(ALNetworkResponse *response, ALNetworkRequest *request) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf taskWithRequest:request cacheMemoryOnly:NO success:nil failure:nil];
                if (success) {
                    success(response,request);
                }
            } failure:^(ALNetworkRequest *request, BOOL isCache,id responseObject, NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                dataTask = [strongSelf taskWithRequest:request cacheMemoryOnly:NO success:success failure:failure];
            }];
        }
            break;
        case ALCacheStrategyMemoryCache: {
            __weak typeof(self) weakSelf = self;
            [self cacheWithRequest:req success:^(ALNetworkResponse *response, ALNetworkRequest *request) {
                if (success) {
                    success(response,request);
                }
            } failure:^(ALNetworkRequest *request, BOOL isCache, id responseObject, NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                dataTask = [strongSelf taskWithRequest:request cacheMemoryOnly:YES success:success failure:failure];
            }];
        }
            break;
    }
    
    req.task = dataTask;
    
    return dataTask;
}

+ (NSURLSessionDataTask *)taskWithRequest:(ALNetworkRequest *)req cacheMemoryOnly:(BOOL)cacheMemoryOnly success:(void (^)(ALNetworkResponse *, ALNetworkRequest *))success failure:(void (^)(ALNetworkRequest *,BOOL isCache,id responseObject, NSError *))failure
{
    return [self networkWithRequest:req success:^(ALNetworkResponse *response, ALNetworkRequest *request) {
        // 缓存
        [[ALNetworkCache defaultManager] setObject:response.rawData forRequestUrl:req.urlStr params:req.params memoryOnly:cacheMemoryOnly];
        if(success) {
            success(response,request);
        }
    } failure:^(ALNetworkRequest *request, BOOL isCache, id responseObject,NSError *error) {
        if(failure) {
            failure(request,isCache,responseObject,error);
        }
    }];
}

+ (void)mockWithRequest:(ALNetworkRequest *)req mockData:(id)data success:(void(^)(ALNetworkResponse *response,ALNetworkRequest *request))success
{
    ALNetworkResponse *response = [[ALNetworkResponse alloc] init];
    response.isCache = YES;
    response.rawData = data;
    if (success) {
        success(response,req);
    }
}

+ (NSURLSessionDataTask *)networkWithRequest:(ALNetworkRequest *)req success:(void(^)(ALNetworkResponse *response,ALNetworkRequest *request))success failure:(void(^)(ALNetworkRequest *request,BOOL isCache,id responseObject,NSError *error))failure {
    
    ALAPIClient *mgr = [ALAPIClient sharedInstance];
    
    [self configWithRequest:req manager:mgr setTimeOut:YES];
    
    NSArray *methods = @[@"GET",@"POST",@"PUT",@"PATCH",@"DELETE"];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [mgr.requestSerializer requestWithMethod:methods[req.method] URLString:req.urlStr parameters:req.params error:&serializationError];
    
    if (serializationError) {
        if (failure) {
            failure(req,NO,nil,serializationError);
        }
    }

    __block NSURLSessionDataTask *dataTask = nil;
//    NSLog(@"%@\n%@",request.URL.absoluteString,request.allHTTPHeaderFields);
    dataTask = [mgr dataTaskWithRequest:request
                             uploadProgress:nil
                           downloadProgress:nil
                          completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
//                              NSLog(@"%@",responseObject);
        if (!error) {
            if ([response isKindOfClass:NSHTTPURLResponse.class]) {
                error = [ALNetworkResponseSerializer verifyWithResponseType:req.responseType reponse:(NSHTTPURLResponse *)response reponseObject:responseObject];
            }
        }
        if (error) {
            if (failure) {
                failure(req,NO,responseObject,error);
                NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:4]);
//                                      LMLog(@"%@\n%@\n%@\n",req.urlStr,req.header.mj_JSONString,req.params.mj_JSONString);
            }
        } else {
            if (success) {
                ALNetworkResponse *resp = [[ALNetworkResponse alloc] init];
                resp.isCache = NO;
                resp.rawData = responseObject;
                success(resp,req);
//                                      LMLog(@"%@\n%@\n%@\n%@",req.urlStr,req.header.mj_JSONString,req.params.mj_JSONString,responseObject);
            }
        }
    }];
    [dataTask resume];
    
    return dataTask;
}

+ (NSURLSessionDataTask *)uploadWithRequest:(ALNetworkRequest *)req progress:(void(^)(float progress))progressBlock success:(void(^)(ALNetworkResponse *response,ALNetworkRequest *request))success failure:(void(^)(ALNetworkRequest *request,BOOL isCache,NSError *error))failure
{
    ALAPIClient *mgr = [ALAPIClient sharedInstance];
    
    [self configWithRequest:req manager:mgr setTimeOut:NO];
    
    NSURLSessionDataTask *task = [mgr POST:req.urlStr parameters:req.params headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (req.data && req.data.count > 0) {
            NSInteger index = 0;
            for (NSData *data in req.data) {
                [formData appendPartWithFileData:data name:req.fileFieldName fileName:req.fileName[index] mimeType:req.mimeType[index]];
                index++;
            }
        }
    }
    progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) {
            progressBlock((float)uploadProgress.completedUnitCount / (float)uploadProgress.totalUnitCount);
        }
    }
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            ALNetworkResponse *response = [[ALNetworkResponse alloc] init];
            response.isCache = NO;
            response.rawData = responseObject;
            success(response,req);
        }
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(req,NO,error);

        }
    }];
    
    req.task = task;

    return task;
}

+ (NSURLSessionDownloadTask *)downloadWithRequest:(ALNetworkRequest *)req progress:(void(^)(float progress))progressBlock success:(void(^)(ALNetworkResponse *response,ALNetworkRequest *request))success failure:(void(^)(ALNetworkRequest *request,BOOL isCache,NSError *error))failure
{
    ALAPIClient *mgr = [ALAPIClient sharedInstance];
    
    [self configWithRequest:req manager:mgr setTimeOut:NO];

    NSURL *downloadURL = [NSURL URLWithString:req.urlStr];

    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:downloadURL];
    
    NSURLSessionDownloadTask *task = [mgr downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock((float)downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *downloadPath = req.destPath;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *filePath = [downloadPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (success && !error) {
            ALNetworkResponse *response = [[ALNetworkResponse alloc] init];
            response.isCache = NO;
            response.rawData = @{@"path": filePath.relativePath ?: @"", @"code":@200};
            success(response,req);
        }
        if (failure && error) {
            failure(req,NO,error);
        }
    }];
    
    req.downloadTask = task;
    
    [task resume];
    
    return task;
}

+ (void)configWithRequest:(ALNetworkRequest *)req manager:(ALAPIClient *)mgr setTimeOut:(BOOL)setTimeOut
{
    // Setting sequrity policy
    if (req.sslCerPath) {
        AFSecurityPolicy *securityPolicy        = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        securityPolicy.pinnedCertificates       = [NSSet setWithObject:[NSData dataWithContentsOfFile:req.sslCerPath]];
        securityPolicy.allowInvalidCertificates = NO;
        securityPolicy.validatesDomainName      = YES;
        mgr.securityPolicy                      = securityPolicy;
    } else {
        mgr.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    }
    
    AFHTTPRequestSerializer *requestSerializer;
    
    // Request by json type
    if(req.paramsType == ALNetworkRequestParamsTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    } else {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    // Set request header
    if (req.header && req.header.allKeys.count > 0) {
        [req.header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id obj, BOOL * _Nonnull stop) {
            [requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    // Set timeout interval
    if (setTimeOut) {
        double timeoutInterval = [ALNetworkingConfig defaultConfig].timeoutInterval;
        if (timeoutInterval != 0) {
            requestSerializer.timeoutInterval = timeoutInterval;
        }
    } else {
        requestSerializer.timeoutInterval = 60.0f;
    }
    
    if (req.requestSerializerBlock) {
        mgr.requestSerializer = req.requestSerializerBlock(requestSerializer);
    } else {
        mgr.requestSerializer = requestSerializer;
    }
    
    // 直接支持多种格式的返回
    mgr.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[
        [AFJSONResponseSerializer serializer],
        [AFImageResponseSerializer serializer],
        [AFHTTPResponseSerializer serializer],
        [AFPropertyListResponseSerializer serializer],
        [AFXMLParserResponseSerializer serializer]
    ]];
}

+ (void)cacheWithRequest:(ALNetworkRequest *)req success:(void(^)(ALNetworkResponse *response,ALNetworkRequest *request))success failure:(void(^)(ALNetworkRequest *request,BOOL isCache,id responseObject, NSError *error))failure {
    ALNetworkCache *cache = [ALNetworkCache defaultManager];
    ALNetworkResponse *response = [cache responseForRequestUrl:req.urlStr params:req.params];
    if (response) {
        success(response,req);
    } else {
        failure(req,YES,nil,KERROR(kNoCacheErrorCode,@"无缓存"));
    }
}

@end
