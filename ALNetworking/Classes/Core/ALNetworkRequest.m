//
//  ALNetworkRequest.m
//  BaZiPaiPanSDK
//
//  Created by Arclin on 2018/4/21.
//

#import "ALNetworkRequest.h"

@implementation ALNetworkRequest

- (id)copyWithZone:(NSZone *)zone {
    ALNetworkRequest *request = [[ALNetworkRequest alloc] init];
    request.urlStr = self.urlStr;
    request.params = self.params;
    request.header = self.header;
    request.task = self.task;
    request.cacheStrategy = self.cacheStrategy;
    request.method = self.method;
    request.paramsType = self.paramsType;
    request.name = self.name;
    request.sslCerPath = self.sslCerPath;
    request.requestSerializerBlock = self.requestSerializerBlock;
    request.responseSerializerBlock = self.responseSerializerBlock;
    request.responseType = self.responseType;
    request.fileName = self.fileName;
    request.fileFieldName = self.fileFieldName;
    request.mimeType = self.mimeType;
    request.progressBlock = self.progressBlock;
    request.data = self.data;
    request.disableDynamicParams = self.disableDynamicParams;
    request.disableDynamicHeader = self.disableDynamicHeader;
    request.clearCache = self.clearCache;
    request.repeatRequestInterval = self.repeatRequestInterval;
    request.customProperty = self.customProperty;
    request.force = self.force;
    request.mockData = self.mockData;
    request.destPath = self.destPath;
    request.downloadTask = self.downloadTask;
    request.startTimeInterval = self.startTimeInterval;
    return request;
}

#pragma mark - setter & getter

- (NSMutableDictionary *)params {
    if (!_params) {
        _params = [NSMutableDictionary dictionary];
    }
    return _params;
}

- (NSMutableDictionary *)header {
    if (!_header) {
        _header = [NSMutableDictionary dictionary];
    }
    return _header;
}

- (NSString *)methodStr {
    switch (self.method) {
        case ALNetworkRequestMethodGET:
            return @"GET";
        case ALNetworkRequestMethodPOST:
            return @"POST";
        case ALNetworkRequestMethodDELETE:
            return @"DELETE";
        case ALNetworkRequestMethodPUT:
            return @"PUT";
        case ALNetworkRequestMethodPATCH:
            return @"PATCH";
        default:
            return @"GET";
            break;
    }
}

- (NSMutableArray<NSString *> *)fileName
{
    if (!_fileName) {
        _fileName = [NSMutableArray array];
    }
    return _fileName;
}

- (NSMutableArray<NSData *> *)data
{
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}

- (NSMutableArray<NSString *> *)mimeType
{
    if (!_mimeType) {
        _mimeType = [NSMutableArray array];
    }
    return _mimeType;
}

- (NSMutableDictionary<NSString *,id<NSCopying>> *)customProperty
{
    if (!_customProperty) {
        _customProperty = [NSMutableDictionary dictionary];
    }
    return _customProperty;
}

@end
