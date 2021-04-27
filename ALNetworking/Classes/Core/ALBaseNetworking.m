//
//  MMCBaseNeetworking.m
//  ALNetworking
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
    
    switch (req.req_cacheStrategy) {
        case ALCacheStrategyNetworkOnly:
            dataTask = [self networkWithRequest:req success:success failure:failure];
            break;
        case ALCacheStrategyCacheOnly: {
            __weak typeof(self) weakSelf = self;
            [self cacheWithRequest:req success:success failure:^(ALNetworkRequest *request, BOOL isCache, id responseObject, NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                dataTask = [strongSelf taskWithRequest:request cacheMemoryOnly:NO success:success failure:failure];
            }];
        }
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
    
    return dataTask;
}

+ (NSURLSessionDataTask *)taskWithRequest:(ALNetworkRequest *)req cacheMemoryOnly:(BOOL)cacheMemoryOnly success:(void (^)(ALNetworkResponse *, ALNetworkRequest *))success failure:(void (^)(ALNetworkRequest *,BOOL isCache,id responseObject, NSError *))failure
{
    return [self networkWithRequest:req success:^(ALNetworkResponse *response, ALNetworkRequest *request) {
        // 缓存
        [[ALNetworkCache defaultManager] setObject:response.rawData forRequestUrl:req.req_urlStr params:req.req_params memoryOnly:cacheMemoryOnly];
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
    NSMutableURLRequest *request = [mgr.requestSerializer requestWithMethod:methods[req.req_method] URLString:req.req_urlStr parameters:req.req_params error:&serializationError];
    
    if (serializationError) {
        if (failure) {
            failure(req,NO,nil,serializationError);
        }
    }

    __block NSURLSessionDataTask *dataTask = nil;

    dataTask = [mgr dataTaskWithRequest:request
                             uploadProgress:nil
                           downloadProgress:nil
                          completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {

        if (!error) {
            if ([response isKindOfClass:NSHTTPURLResponse.class]) {
                error = [ALNetworkResponseSerializer verifyWithResponseType:req.req_responseType reponse:(NSHTTPURLResponse *)response reponseObject:responseObject];
            }
        }
        if (error) {
            if (failure) {
                failure(req,NO,responseObject,error);
                NSLog(@"%@",[[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:4]);
            }
        } else {
            if (success) {
                ALNetworkResponse *resp = [[ALNetworkResponse alloc] init];
                resp.isCache = NO;
                resp.rawData = responseObject;
                success(resp,req);
            }
        }
//        [mgr invalidateSessionCancelingTasks:YES resetSession:YES];
    }];
    [dataTask resume];
    
    return dataTask;
}

+ (NSURLSessionDataTask *)uploadWithRequest:(ALNetworkRequest *)req progress:(void(^)(float progress))progressBlock success:(void(^)(ALNetworkResponse *response,ALNetworkRequest *request))success failure:(void(^)(ALNetworkRequest *request,BOOL isCache,NSError *error))failure
{
    ALAPIClient *mgr = [ALAPIClient sharedInstance];
    
    [self configWithRequest:req manager:mgr setTimeOut:NO];
    
    NSURLSessionDataTask *task = [mgr POST:req.req_urlStr parameters:req.req_params headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (req.req_data && req.req_data.count > 0) {
            NSInteger index = 0;
            for (NSData *data in req.req_data) {
                [formData appendPartWithFileData:data name:req.req_fileFieldName fileName:req.req_fileName[index] mimeType:req.req_mimeType[index]];
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

    return task;
}

+ (NSURLSessionDownloadTask *)downloadWithRequest:(ALNetworkRequest *)req progress:(void(^)(float progress))progressBlock success:(void(^)(ALNetworkResponse *response,ALNetworkRequest *request))success failure:(void(^)(ALNetworkRequest *request,BOOL isCache,NSError *error))failure
{
    ALAPIClient *mgr = [ALAPIClient sharedInstance];
    
    [self configWithRequest:req manager:mgr setTimeOut:NO];

    NSURL *downloadURL = [NSURL URLWithString:req.req_urlStr];

    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:downloadURL];
    
    NSURLSessionDownloadTask *task = [mgr downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock((float)downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *downloadPath = req.req_destPath;
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
    
    [task resume];
    
    return task;
}

+ (void)configWithRequest:(ALNetworkRequest *)req manager:(ALAPIClient *)mgr setTimeOut:(BOOL)setTimeOut
{
    // Setting sequrity policy
    if (req.req_sslCerPath) {
        AFSecurityPolicy *securityPolicy        = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        securityPolicy.pinnedCertificates       = [NSSet setWithObject:[NSData dataWithContentsOfFile:req.req_sslCerPath]];
        securityPolicy.allowInvalidCertificates = NO;
        securityPolicy.validatesDomainName      = YES;
        mgr.securityPolicy                      = securityPolicy;
    } else {
        mgr.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    }
    
    AFHTTPRequestSerializer *requestSerializer;
    
    // Request by json type
    if(req.req_paramsType == ALNetworkRequestParamsTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    } else {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    // Set request header
    if (req.req_header && req.req_header.allKeys.count > 0) {
        [req.req_header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id obj, BOOL * _Nonnull stop) {
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
    
    mgr.requestSerializer = requestSerializer;

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
    ALNetworkResponse *response = [cache responseForRequestUrl:req.req_urlStr params:req.req_params];
    if (response) {
        success(response,req);
    } else {
        failure(req,YES,nil,KERROR(kNoCacheErrorCode,@"无缓存"));
    }
}

@end
