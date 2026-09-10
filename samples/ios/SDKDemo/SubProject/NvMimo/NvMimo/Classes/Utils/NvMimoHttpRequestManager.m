//
//  NvMimoHttpRequestManager.m
//  NvMimoDemo
//
//  Created by MS on 2020/7/28.
//  Copyright © 2020 MS. All rights reserved.
//

#import "NvMimoHttpRequestManager.h"
#import "AFNetworking.h"
#import <NvSDKCommon/NvHttpRequest.h>

#define NV_MIMO_API_HOST             @"https://vsapi.meishesdk.com/"

@implementation NvMimoHttpRequestManager
static NvMimoHttpRequestManager *sharedInstance = nil;
static AFHTTPSessionManager *httpSessionManager;
static AFNetworkReachabilityManager *networkManager;

+ (NvMimoHttpRequestManager *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[NvMimoHttpRequestManager alloc] init];
        networkManager = [AFNetworkReachabilityManager sharedManager];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    return self;
}

+ (AFHTTPSessionManager *)sharedManager {
    if (httpSessionManager)
        return httpSessionManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpSessionManager = [AFHTTPSessionManager manager];
        httpSessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        httpSessionManager.requestSerializer.timeoutInterval = 15.0;
        [httpSessionManager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        httpSessionManager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        httpSessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        httpSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
    });
    return httpSessionManager;
}

- (NSURLSessionDownloadTask *) downloadAsset:(NSString*)srcFileUrl
                                 destFileDir:(NSString*)destFileDir
                                withDelegate:(id<NvMimoHttpRequestDelegate>)delegate
                                  downloadID:(NSString*)downloadID
{
    AFURLSessionManager *httpSessionManager = [NvMimoHttpRequestManager sharedManager];
    NSURL *url = [NSURL URLWithString:srcFileUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *currentTask = [httpSessionManager downloadTaskWithRequest:request
                                                                               progress:^(NSProgress * _Nonnull downloadProgress) {
        int32_t progress = (int32_t)(downloadProgress.completedUnitCount * 100 / downloadProgress.totalUnitCount);
        if(delegate && [delegate respondsToSelector:@selector(onDonwloadAssetProgress:downloadID:)])
            [delegate onDonwloadAssetProgress:progress downloadID:downloadID];
    }
                                                                            destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *filePath = [destFileDir stringByAppendingPathComponent:url.lastPathComponent];
        return [NSURL fileURLWithPath:filePath];
        
    }
                                                                      completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if(delegate){
            if(error){
                if([delegate respondsToSelector:@selector(onDonwloadAssetFailed:downloadFilePath:downloadID:)])
                    [delegate onDonwloadAssetFailed:error downloadFilePath:[filePath absoluteString] downloadID:downloadID];
            } else{
                if([delegate respondsToSelector:@selector(onDonwloadAssetSuccess: downloadFilePath: downloadID:)])
                    [delegate onDonwloadAssetSuccess:TRUE downloadFilePath:[filePath absoluteString] downloadID:downloadID];
            }
        }
    }];

    [currentTask resume];
    return currentTask;
}

- (NSURLSessionDownloadTask *) downloadVideo:(NSString*)srcFileUrl
                                 destFileDir:(NSString*)destFileDir
                                withDelegate:(id<NvMimoHttpRequestDelegate>)delegate
                                  downloadID:(NSString*)downloadID
{
    AFURLSessionManager *httpSessionManager = [NvMimoHttpRequestManager sharedManager];
    NSURL *url = [NSURL URLWithString:srcFileUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *currentTask = [httpSessionManager downloadTaskWithRequest:request
                                                                               progress:^(NSProgress * _Nonnull downloadProgress) {
        int32_t progress = (int32_t)(downloadProgress.completedUnitCount * 100 / downloadProgress.totalUnitCount);
        NSLog(@"%d",progress);
    }
                                                                            destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *filePath = [destFileDir stringByAppendingPathComponent:url.lastPathComponent];
        return [NSURL fileURLWithPath:filePath];
        
    }
                                                                      completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if(delegate){
            if(error){
                if([delegate respondsToSelector:@selector(onDonwloadAssetFailed:downloadFilePath:downloadID:)])
                    [delegate onDonwloadAssetFailed:error downloadFilePath:[filePath absoluteString] downloadID:downloadID];
            } else{
                if([delegate respondsToSelector:@selector(onDonwloadAssetSuccess: downloadFilePath: downloadID:)])
                    [delegate onDonwloadAssetSuccess:TRUE downloadFilePath:[filePath absoluteString] downloadID:downloadID];
            }
        }
    }];

    [currentTask resume];
    return currentTask;
}

- (void)checkNetwork:(id<NvMimoHttpRequestDelegate>)delegate
{
    if (delegate == nil) {
        [networkManager stopMonitoring];
        [networkManager setReachabilityStatusChangeBlock:nil];
        return;
    }
    [networkManager startMonitoring];
    [networkManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        BOOL isNetAvailable = YES;
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: {
                isNetAvailable = NO;
                break;
            }
            case AFNetworkReachabilityStatusNotReachable:{
                isNetAvailable = NO;
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                isNetAvailable = YES;
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                isNetAvailable = YES;
            }
        }
        
        if(delegate && [delegate respondsToSelector:@selector(onCheckNetworkState:)]){
            [delegate onCheckNetworkState:isNetAvailable];
        }
    }];
}

- (void)feedBackWithContent:(NSString *)content withContact:(NSString *)contact withSdkVersion:(NSString *)sdkVersion withDeviceModel:(NSString *)deviceModel withDelegate:(id<NvMimoHttpRequestDelegate>)delegate{
    NSDictionary *body = @{@"content":content,@"contact":contact,@"sdkVersion":sdkVersion,@"deviceModel":deviceModel};
    AFHTTPSessionManager *httpSessionManager = [NvMimoHttpRequestManager sharedManager];
    httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [httpSessionManager POST:[NV_MIMO_API_HOST stringByAppendingString:NV_MIMO_API_HOST] parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        [delegate feedBackWithDictionary:dict];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

+ (void)RequestMimoMaterialListWithPage:(NSInteger)page
                               pageSize:(NSInteger)pageSize
                        completionBlock:(void(^)(id respondData))completion
                           failureBlock:(void(^)(NSError *error))failure {
    AFHTTPSessionManager *httpSessionManager = [NvMimoHttpRequestManager sharedManager];
    httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *urlStr = NV_ASSET_REQUEST_URL;
    NSDictionary *body = @{
        @"type":@17,
        @"pageNum":[NSNumber numberWithInteger:page],
        @"pageSize":[NSNumber numberWithInteger:pageSize],
        @"lang":[NvHttpRequest getCurrentLang]
    };
    [httpSessionManager GET:urlStr parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        int code = [dict[@"code"] intValue];
        if (code == 1) {
            completion(dict);
        }else{
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"%@",error);
    }];
}


@end
