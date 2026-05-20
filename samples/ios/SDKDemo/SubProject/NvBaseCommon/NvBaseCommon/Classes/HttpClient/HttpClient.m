//
//  HttpClient.m
//  meishe
//
//  Created by 刘东旭 on 2019/5/28.
//  Copyright © 2019 刘东旭. All rights reserved.
//

#import "HttpClient.h"
#import "AFNetWorking.h"

@implementation HttpClient

+ (void)GET:(NSString *_Nonnull)stringUrl param:(nonnull NSDictionary *)param success:(nullable void (^)(NSArray<NSDictionary *> * _Nullable items))success failure:(nullable void (^)(NSError * _Nullable error))failure {
    
    [HttpClient request:NvGet url:stringUrl param:param completionHandler:^(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            failure(error);
        } else {
            int rval = [[responseObject objectForKey:@"errNo"] intValue];
            if (rval != 0) {
                NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:[responseObject objectForKey:@"resMsg"]}];
                failure(error);
            } else {
                NSArray *array = [responseObject objectForKey:@"list"];
                success(array);
            }
        }
    }];
}

+ (void)GETNewAsset:(NSString *_Nonnull)stringUrl param:(nonnull NSDictionary *)param success:(nullable void (^)(NSArray<NSDictionary *> * _Nullable items))success failure:(nullable void (^)(NSError * _Nullable error))failure {
    
    [HttpClient request:NvGet url:stringUrl param:param completionHandler:^(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            failure(error);
        } else {
            int rval = [[responseObject objectForKey:@"code"] intValue];
            if (rval != 1) {
                NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:[responseObject objectForKey:@"resMsg"]}];
                failure(error);
            } else {
                NSArray *array = [[responseObject objectForKey:@"data"] objectForKey:@"elements"];
                success(array);
            }
        }
    }];
}

+ (void)request:(NvRequestMethod)method url:(NSString *_Nonnull)stringUrl param:(nonnull NSDictionary *)param completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSession *managerSession = manager.session;
    NSString *methodName;
    if (method == NvGet) {
        methodName = @"GET";
    } else {
        methodName = @"POST";
    }
    NSError *error;
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:methodName URLString:stringUrl parameters:param error:&error];

    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        completionHandler(response, responseObject, error);
        [managerSession finishTasksAndInvalidate];
    }];
    [task resume];
}

+ (void)downloadUrl:(NSString *_Nonnull)stringUrl param:(NSDictionary *_Nullable)param destinationDir:(NSString *)destinationDir completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable responseObject,  NSError * _Nullable error))completionHandler {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSession *managerSession = manager.session;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:stringUrl]];
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *fullPath = [destinationDir stringByAppendingPathComponent:[stringUrl lastPathComponent]];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:fullPath]) {
            [fm removeItemAtPath:fullPath error:nil];
        }
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        completionHandler(response, filePath, error);
        [managerSession finishTasksAndInvalidate];
    }];
    [task resume];
}

@end
