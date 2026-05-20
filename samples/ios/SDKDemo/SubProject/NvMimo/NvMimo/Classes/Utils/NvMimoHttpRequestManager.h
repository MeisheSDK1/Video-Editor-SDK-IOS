//
//  NvMimoHttpRequestManager.h
//  NvMimoDemo
//
//  Created by MS on 2020/7/28.
//  Copyright © 2020 MS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol NvMimoHttpRequestDelegate <NSObject>
@optional

/**
 * 下载在线素材进度执行该回调。
 * Download the online asset progress to execute the callback.
 */
- (void)onDonwloadAssetProgress:(int32_t)progress
                     downloadID:(NSString*)downloadID;

/**
 * 下载在线素材完成执行该回调。
 * Download the online assets to complete the execution of the callback.
 */
- (void)onDonwloadAssetSuccess:(BOOL) isSuccess
              downloadFilePath:(NSString*)downloadFilePath
                    downloadID:(NSString*)downloadID;

/**
 * 下载在线素材失败执行该回调。
 * Failed to download online assets to execute the callback.
 */
- (void)onDonwloadAssetFailed:(NSError *) error
             downloadFilePath:(NSString*)downloadFilePath
                   downloadID:(NSString*)downloadID;

/**
 * 检查网络状态后执行该回调。
 */
- (void)onCheckNetworkState:(BOOL)isNetAvailable;

/**
 提交反馈回调
 Submit the feedback callback
 
 @param dic 数据
 */
- (void)feedBackWithDictionary:(NSDictionary *)dic;

@end
@interface NvMimoHttpRequestManager : NSObject

+ (NvMimoHttpRequestManager *)sharedInstance;

/**
 * 下载在线素材。
 * Download online assets.
 */
- (NSURLSessionDownloadTask *)downloadAsset:(NSString*)srcFileUrl
                                destFileDir:(NSString*)destFileDir
                               withDelegate:(id<NvMimoHttpRequestDelegate>)delegate
                                 downloadID:(NSString*)downloadID;

/**
* 下载在线视频。
 Download online videos.
*/
- (NSURLSessionDownloadTask *) downloadVideo:(NSString*)srcFileUrl
                                 destFileDir:(NSString*)destFileDir
                                withDelegate:(id<NvMimoHttpRequestDelegate>)delegate
                                  downloadID:(NSString*)downloadID;

/**
 获取照片影集list
 Get a list of photo albums
 @param page 请求当前页
 @param pageSize 请求每次个数
 */
+ (void)RequestMimoMaterialListWithPage:(NSInteger)page
                               pageSize:(NSInteger)pageSize
                        completionBlock:(void(^)(id respondData))completion
                           failureBlock:(void(^)(NSError *error))failure;


- (void)checkNetwork:(id<NvMimoHttpRequestDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
