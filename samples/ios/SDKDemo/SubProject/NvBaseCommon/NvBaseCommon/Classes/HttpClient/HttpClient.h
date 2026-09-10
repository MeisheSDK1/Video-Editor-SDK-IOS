//
//  HttpClient.h
//  meishe
//
//  Created by 刘东旭 on 2019/5/28.
//  Copyright © 2019 刘东旭. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    NvGet,
    NvPost,
} NvRequestMethod;
NS_ASSUME_NONNULL_BEGIN
@interface HttpClient : NSObject

+ (void)GET:(NSString *_Nonnull)stringUrl param:(nonnull NSDictionary *)param success:(nullable void (^)(NSArray<NSDictionary *> * _Nullable items))success failure:(nullable void (^)(NSError * _Nullable error))failure;

+ (void)GETNewAsset:(NSString *_Nonnull)stringUrl param:(nonnull NSDictionary *)param success:(nullable void (^)(NSArray<NSDictionary *> * _Nullable items))success failure:(nullable void (^)(NSError * _Nullable error))failure;

+ (void)request:(NvRequestMethod)method url:(NSString *_Nonnull)stringUrl param:(nonnull NSDictionary *)param completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler;

+ (void)downloadUrl:(NSString *_Nonnull)stringUrl param:(NSDictionary *_Nullable)param destinationDir:(NSString *)destinationDir completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable responseObject,  NSError * _Nullable error))completionHandler;

@end
NS_ASSUME_NONNULL_END
