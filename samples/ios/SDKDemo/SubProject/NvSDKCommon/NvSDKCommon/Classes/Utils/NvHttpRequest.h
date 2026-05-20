//
//  NvHttpRequest.h
//  NvCheez
//
//  Created by shizhouhu on 2018/6/5.
//  Copyright © 2018年 shizhouhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvAssetManager.h"
@class NvAsset;

#define NV_REQUEST_ASSET_RELEASE_VERSION YES          //注：正式环境下打开，测试环境下注释掉——Note: Open in formal environment, comment out in test environment

#ifdef NV_REQUEST_ASSET_RELEASE_VERSION
//正式 formal

//meishe域名
#define NV_HOST  @"https://mall.meishesdk.com/api/sdkdemo"
#define NV_API_HOST  @"https://mall.meishesdk.com/api/sdkdemo"
#define NV_APPSDKAPI_URL [NV_API_HOST stringByAppendingPathComponent:@"materialcenter/appSdkApi"]

#define NV_ASSET_REQUEST_URL @"https://mall.meishesdk.com/api/sdkdemo/materialcenter/appSdkApi/material/listAll"
#define NV_MAKEUP_SINGLE_URL [NV_APPSDKAPI_URL stringByAppendingPathComponent:@"listTypeAndCategory"]
#define NV_LISTMEDIAINFO_URL [NV_APPSDKAPI_URL stringByAppendingPathComponent:@"listMediaInfo"]
#define NV_TEST_MATERIAL @"0"
#endif

#define NV_API_FEEDBACK         @"/feedback/index.php?command=feedback"

@protocol NvHttpRequestDelegate <NSObject>
@optional

/**
 * 获取到在线素材列表后执行该回调。
 * Perform the callback after obtaining the online material list.
 */
- (void)onGetAssetListSuccess:(NSArray *)resultsArray
                    assetType:(AssetType)assetType
                      hasNext:(BOOL)hasNext;

/**
 * 获取到在线素材列表失败执行该回调。
 * Description Failed to obtain the online material list.
 */
- (void)onGetAssetListFailed:(NSError *)error
                   assetType:(AssetType) assetType;

/**
 * 根据关键字获取到在线素材列表后执行该回调。
 * The callback is performed after the online material list is obtained based on the keyword.
 */
- (void)onGetAssetListSuccess:(NSArray *)resultsArray
                    assetType:(AssetType)assetType
                      keyword:(NSString *)keyword
                      hasNext:(BOOL)hasNext;

/**
 * 根据关键字获取到在线素材列表失败执行该回调。
 * Description Failed to obtain the online material list based on the keyword.
 */
- (void)onGetAssetListFailed:(NSError *)error
                   assetType:(AssetType) assetType
                     keyword:(NSString *)keyword;

/**
 * 下载在线素材进度执行该回调。
 * Download online materials progress Perform this callback.
 */
- (void)onDonwloadAssetProgress:(int32_t)progress
                     downloadID:(NSString*)downloadID;

/**
 * 下载在线素材完成执行该回调。
 * Download online materials. Complete the callback.
 */
- (void)onDonwloadAssetSuccess:(BOOL) isSuccess
              downloadFilePath:(NSString*)downloadFilePath
                    downloadID:(NSString*)downloadID;

/**
 * 下载在线素材失败执行该回调。
 * Description Failed to download online materials.
 */
- (void)onDonwloadAssetFailed:(NSError *) error
             downloadFilePath:(NSString*)downloadFilePath
                   downloadID:(NSString*)downloadID;

/**
 * 检查网络状态后执行该回调。
 * Check the network status and perform the callback.
 */
- (void)onCheckNetworkState:(BOOL)isNetAvailable;

/**
 提交反馈回调
 Submit the feedback callback
 @param dic 数据 data
 */
- (void)feedBackWithDictionary:(NSDictionary *)dic;

@end

@interface NvHttpRequest : NSObject

+ (NvHttpRequest *)sharedInstance;

+ (BOOL)getTestMaterial;

/**
 * 获取到在线素材列表。
 * Get a list of online materials.
 */
- (void)getAssetList:(AssetType)assetType
          categoryId:(int)categoryId
               page:(int32_t)page
           pageSize:(int32_t)pageSize
                kind:(int)kind
             modular:(NvAssetModular)modular
               ratioFlag:(int)ratioFlag
                   ratio:(int)ratio
              sdkVerskon:(NSString *)sdkVerskon
       withDelegate:(id<NvHttpRequestDelegate>)delegate;

/**
 * 根据关键词获取在线素材列表。
 * Get a list of online materials based on keywords.
 */
- (void)getAssetList:(AssetType)assetType
          categoryId:(int)categoryId
             keyword:(NSString *)keyword
                page:(int32_t)page
            pageSize:(int32_t)pageSize
                kind:(int)kind
             modular:(NvAssetModular)modular
           ratioFlag:(int)ratioFlag
               ratio:(int)ratio
          sdkVerskon:(NSString *)sdkVerskon
        withDelegate:(id<NvHttpRequestDelegate>)delegate;

/// 获取在线素材
/// Get online material
/// @param assetType 素材一级类别
/// Material primary class
/// @param categoryId 素材二级类别
/// Material secondary class
/// @param categorys 素材二级类别数组
/// Material secondary class array
/// @param keyword  关键字
/// Key word
/// @param page 页码
/// Page number
/// @param pageSize 每页数量
/// Quantity per page
/// @param kind 素材三级类别
/// Three class of material
/// @param ratioFlag
/// @param ratio
/// @param sdkVerskon sdk版本
/// sdk version
/// @param delegate 代理
/// delegate
- (void)newGetAssetList:(AssetType)assetType
             categoryId:(int)categoryId
           categoryList:(NSString *)categorys
                keyword:(NSString *)keyword
                   page:(int32_t)page
               pageSize:(int32_t)pageSize
                   kind:(int)kind
              ratioFlag:(int)ratioFlag
                  ratio:(int)ratio
             sdkVerskon:(NSString *)sdkVerskon
           withDelegate:(id<NvHttpRequestDelegate>)delegate;

/**
 * 下载在线素材。
 * Download online material.
 */
- (NSURLSessionDownloadTask *)downloadAsset:(NSString*)srcFileUrl
                                 destFileDir:(NSString*)destFileDir
                                withDelegate:(id<NvHttpRequestDelegate>)delegate
                                  downloadID:(NSString*)downloadID;

- (NSURLSessionDownloadTask *) downloadAsset:(NSString*)srcFileUrl
                                 destFileDir:(NSString*)destFileDir
                                  downloadID:(NSString*)downloadID
                               progressBlock:(void(^)(int32_t progress))progressBlock
                               completeBlock:(void(^)(NSString *downloadFilePath))completeBlock
                                failureBlock:(void(^)(NSError *error,NSString *downloadFilePath))failureBlock;

- (void)getAssetListForCaptureScene:(AssetType)assetType
                         categoryId:(int)categoryId
                              page:(int32_t)page
                          pageSize:(int32_t)pageSize
                               kind:(int)kind ratioFlag:(int)ratioFlag ratio:(int)ratio sdkVerskon:(NSString *)sdkVerskon withDelegate:(id<NvHttpRequestDelegate>)delegate;

/**
 * 检查是否存在网络。
 * Check whether the network exists.
 */
- (void)checkNetwork:(id<NvHttpRequestDelegate>)delegate;


/**
 反馈接口
 Feedback interface

 @param content 反馈内容
 Feedback content
 @param contact 联系方式
 Contact information
 @param sdkVersion sdk版本号
 sdk version number
 @param deviceModel 手机型号
 Mobile phone model
 */
- (void)feedBackWithContent:(NSString *)content withContact:(NSString *)contact withSdkVersion:(NSString *)sdkVersion withDeviceModel:(NSString *)deviceModel withDelegate:(id<NvHttpRequestDelegate>)delegate;

/// 获取当前语言参数
+ (NSString *)getCurrentLang;

/**
 获取照片影集list
 Get a list of photos

 @param page 请求当前页
 Request current page
 @param pageSize 请求每次个数
 Number per request
 */
+ (void)RequestPhotoAlbumMaterialListWithPage:(NSInteger)page
                                     pageSize:(NSInteger)pageSize
                              completionBlock:(void(^)(id respondData))completion
                                 failureBlock:(void(^)(NSError *error))failure;

+ (void)RequestListCategoryWithType:(NSInteger)type
                             category:(NSString *)category
                           sdkVersion:(NSString *)sdkVersion
                                 page:(NSInteger)page
                             pageSize:(NSInteger)pageSize
                      completionBlock:(void(^)(id respondData))completion
                         failureBlock:(void(^)(NSError *error))failure;

+ (void)RequestMakeupKindListWithType:(NSInteger)type
                             category:(NSInteger)category
                           sdkVersion:(NSString *)sdkVersion
                                 page:(NSInteger)page
                             pageSize:(NSInteger)pageSize
                      completionBlock:(void(^)(id respondData))completion
                         failureBlock:(void(^)(NSError *error))failure;

+ (void)RequestVariableMakeupListWithType:(NSInteger)type
                                 category:(NSInteger)category
                                     kind:(NSInteger)kind
                                ratioFlag:(NSInteger)ratioFlag
                                    ratio:(NSInteger)ratio
                               sdkVersion:(NSString *)sdkVersion
                                     page:(NSInteger)page
                                 pageSize:(NSInteger)pageSize
                          completionBlock:(void(^)(id respondData))completion
                             failureBlock:(void(^)(NSError *error))failure;

+ (void)RequestBeautyTemplateListWithType:(NSInteger)type
                                 category:(NSInteger)category
                                     kind:(NSInteger)kind
                                ratioFlag:(NSInteger)ratioFlag
                                    ratio:(NSInteger)ratio
                               sdkVersion:(NSString *)sdkVersion
                                     page:(NSInteger)page
                                 pageSize:(NSInteger)pageSize
                          completionBlock:(void(^)(id respondData))completion
                             failureBlock:(void(^)(NSError *error))failure;

+ (void)RequestListMediaInfoListWithType:(NSInteger)type
                                     page:(NSInteger)page
                                 pageSize:(NSInteger)pageSize
                          completionBlock:(void(^)(id respondData))completion
                             failureBlock:(void(^)(NSError *error))failure;

@end
