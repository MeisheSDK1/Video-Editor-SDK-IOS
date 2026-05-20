//
//  NvAssetManager.h
//  SDKDemo
//
//  Created by dx on 2018/6/8.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvAsset.h"

@protocol NvAssetManagerDelegate <NSObject>
@optional

/**
 * 获取到在线素材列表后执行该回调。
 * Perform the callback after obtaining the online material list.
 */
- (void)onRemoteAssetsChanged:(BOOL)hasNext;

/**
 * 获取到在线素材列表失败执行该回调。
 * Description Failed to obtain the online material list.
 */
- (void)onGetRemoteAssetsFailed;

/**
 * 下载在线素材进度执行该回调。
 * Download online materials progress Perform this callback.
 */
- (void)onDownloadAssetProgress:(NSString *)uuid
                       progress:(int)progress;

/**
 * 下载在线素材失败执行该回调。
 * Description Failed to download online materials.
 */
- (void)onDonwloadAssetFailed:(NSString *)uuid;

/**
 * 下载在线素材完成执行该回调。
 * Download online materials. Complete the callback.
 */
- (void)onDonwloadAssetSuccess:(NSString *)uuid;


/// 素材下载完成的回调
/// Material download completed callback
/// @param uuid uuid
/// @param path 素材的包裹路径 The wrapping path of the material
- (void)onDonwloadAssetSuccess:(NSString *)uuid withPath:(NSString *)path;

/**
 * 如果素材为异步安装，安装完成后执行该回调。
 * If materials are installed asynchronously, perform this callback after installation.
 */
- (void)onFinishAssetPackageInstallation:(NSString *)uuid;

/**
 * 如果素材为异步安装，升级完成后执行该回调。
 * If materials are installed asynchronously, perform this callback after the upgrade is complete.
 */
- (void)onFinishAssetPackageUpgrading:(NSString *)uuid;

/**
 * 检查网络状态后执行该回调。
 * Check the network status and perform the callback.
 */
- (void)onCheckNetworkState:(BOOL)isNetAvailable;
@end

typedef NS_ENUM(NSUInteger, NvAssetModular) {
    NvAssetModularAll,
    NvAssetModularCapture,
    NvAssetModularEdit,
};

@interface NvUserAssetInfo: NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString * displayNamezhCN;
@property (nonatomic, strong) NSString *coverUrl;
@property (nonatomic, strong) NSString *coverUrl2;
@property (nonatomic, assign) int categoryId;
@property (nonatomic, assign) int kind;
@property (nonatomic, assign) AspectRatio aspectRatio;
@property (nonatomic, assign) int remotePackageSize;
@property (nonatomic, assign) int idx;
@property (nonatomic, assign) BOOL isAdjusted;
@property (nonatomic, strong) NSString *packagePath;
@property (nonatomic, strong) NSString *licensePath;
@end

@interface NvCustomStickerInfo: NSObject
///自定义贴纸uuid
///Custom sticker uuid
@property (nonatomic, strong) NSString *uuid;
///自定义贴纸模板uuid
///User-defined sticker template uuid
@property (nonatomic, strong) NSString *templateUuid;
///自定义贴纸图片路径
///Customize the sticker picture path
@property (nonatomic, strong) NSString *imagePath;
///选择的如果是gif图，需要转换成caf文件，但是页面需要一个的图片做封面，这个是gif图的地址也需要保存，用来显示封面
///If gif image is selected, it needs to be converted into caf file, but the page needs a picture for the cover, and the address of the gif image also needs to be saved to display the cover
@property (nonatomic, strong) NSString *tempImage;
///显示顺序
///Display sequence
@property (nonatomic, assign) int order;
@end

@interface NvAssetManager : NSObject

@property (nonatomic, strong) NSHashTable *hashTable;

+ (NvAssetManager *)sharedInstance;

- (void)downloadRemoteAssetsInfoForCapture:(AssetType)assetType categoryId:(int)categoryId page:(int)page pageSize:(int)pageSize kind:(int)kind
                       ratioFlag:(int)ratioFlag
                           ratio:(int)ratio
                                sdkVerskon:(NSString *)sdkVerskon;
/**
 * 下载在线素材信息
 * Download online material information
 */
- (void)downloadRemoteAssetsInfo:(AssetType)assetType categoryId:(int)categoryId page:(int)page pageSize:(int)pageSize kind:(int)kind modular:(NvAssetModular)modular ratioFlag:(int)ratioFlag ratio:(int)ratio sdkVerskon:(NSString *)sdkVerskon;

/**
 * 根据关键字下载在线素材信息
 * Download online material information by keyword
 */
- (void)downloadRemoteAssetsInfo:(AssetType)assetType categoryId:(int)categoryId keyword:(NSString *)keyword page:(int)page pageSize:(int)pageSize kind:(int)kind modular:(NvAssetModular)modular ratioFlag:(int)ratioFlag ratio:(int)ratio sdkVerskon:(NSString *)sdkVerskon;


/// 获取在线素材
/// Get online material
/// @param assetType 素材一级类别 Material primary class
/// @param categoryId 素材二级类别 Material secondary class
/// @param categorys 素材二级类别数组 Material secondary class array
/// @param keyword  关键字 Key word
/// @param page 页码 Page number
/// @param pageSize 每页数量 Quantity per page
/// @param kind 素材三级类别 Three class of material
/// @param ratioFlag
/// @param ratio
/// @param sdkVerskon sdk版本 sdk version
- (void)newDownloadRemoteAssetsInfo:(AssetType)assetType categoryId:(int)categoryId categoryList:(NSString *)categorys keyword:(NSString *)keyword page:(int)page pageSize:(int)pageSize kind:(int)kind
                       ratioFlag:(int)ratioFlag
                           ratio:(int)ratio
                      sdkVerskon:(NSString *)sdkVerskon;

/**
 * 下载素材
 * Download material
 */
- (BOOL)downloadAsset:(NSString *)uuid;

/**
 * 取消下载素材
 * Undownload material
 */
- (BOOL)cancelAssetDownload:(NSString *)uuid;

/**
 * 获取在线素材信息
 * Get online material information
 */
- (NSArray *)getRemoteAssets:(AssetType)assetType
                 aspectRatio:(AspectRatio)aspectRatio
                  categoryId:(int)categoryId
                      kindId:(int)kindId;
/**
 * 根据关键字获取在线素材信息
 * Obtain online material information by keyword
 */
- (NSArray *)getRemoteAssets:(AssetType)assetType
                 aspectRatio:(AspectRatio)aspectRatio
                  categoryId:(int)categoryId
                      kindId:(int)kindId
                     keyword:(NSString *)keyword;

/**
 * 获取可用素材id列表
 * Gets a list of available material ids
 */
- (NSArray *)getUsableAssets:(AssetType)assetType
                 aspectRatio:(AspectRatio)aspectRatio
                  categoryId:(int)categoryId
                      kindId:(int)kindId;

/**
 * 获取预装素材id列表
 * Obtain the list of preinstalled material ids
 */
- (NSArray *)getReservedAssets:(AssetType)assetType
                   aspectRatio:(AspectRatio)aspectRatio
                    categoryId:(int)categoryId
                        kindId:(int)kindId;

/**
 * 获取素材对象
 * Get material object
 */
- (NvAsset *)getAsset:(NSString *)uuid;

/**
 * 搜索本地素材，搜索结果存入素材字典
 * Obtain Material objects Search for local materials and store the search results in the material dictionary
 */
- (void)searchLocalAssets:(AssetType)assetType;

- (void)searchLocalAssets:(AssetType)assetType categoryId:(int)categoryId;

/**
 * 搜索预装素材，搜索结果存入素材字典
 * Search for preloaded material and store the search results in the material dictionary
 */
- (void)searchReservedAssets:(AssetType)assetType
                  bundlePath:(NSString *)bundlePath;

- (void)searchReservedAssets:(AssetType)assetType
                  bundlePath:(NSString *)bundlePath
                  categoryId:(int)categoryId;


/// 搜索本地沙盒素材，设计人员会在app中内置一些素材看效果，通过这个方法去获取对应的素材
/// Search the local sandbox material, the designer will build some material in the app to see the effect, through this method to obtain the corresponding material
/// @param assetType 素材类型 Material type
/// @param bundlePath 素材的本地路径 The local path of the material
- (NSArray *)searchLocalMaterialAssets:(AssetType)assetType
                            bundlePath:(NSString *)bundlePath;

/**
 * 保存素材信息到user defaults
 * Save material information to user defaults
 */
- (void)setAssetInfoToUserDefaults:(AssetType)assetType;

/**
 * 根据索引排序
 * Sort by index
 */
- (NSArray *)sortAssetByIdx:(NSMutableArray *)assets;

/**
 * 代理对象
 * Proxy object
 */
@property (nonatomic, weak) id<NvAssetManagerDelegate> delegate;

/**
 * 所有素材字典，包括本地素材和在线素材
 * Dictionary of all materials, including local materials and online materials
 */
@property (nonatomic, strong) NSMutableDictionary *assetDict;

/**
 * 同时下载限制个数
 * Limit the number of simultaneous downloads
 */
@property (nonatomic, assign) int maxConcurrentAssetDownloadNum;

/**
 * 等待下载队列
 * Waiting download queue
 */
@property (nonatomic, strong) NSMutableArray *pendingAssetsToDownload;

/**
 * 正在下载的个数
 * Number of downloads in progress
 */
@property (nonatomic, assign) int downloadingAssetsCounter;

/**
 * 在线素材的顺序表
 * A sequential list of online materials
 */
@property (nonatomic, strong) NSMutableDictionary *remoteAssetsOrderedList;

/**
 * 自定义贴纸素材。说明：自定义贴纸只有自定义图片的路径和自定义模板的包，没有单独的自定义贴纸包，所以需要单独存储。
 * 并且自定义贴纸的信息存储在User defaults里面。
 * Custom sticker material. Note: The custom sticker only has the path of the custom picture and the package of the custom template, there is no separate custom sticker package, so it needs to be stored separately.
 * And the information about custom stickers is stored in User defaults.
 */
@property (nonatomic, strong) NSMutableDictionary *customStickerDict;

/**
 * 是否同步安装素材，默认同步安装。
 * Whether to synchronize installation materials. By default, the installation is synchronized.
 */
@property (nonatomic, assign) BOOL isSyncInstallAsset;

/**
 * 关键字搜索的素材uuid素材。
 * Keyword search material uuid material.
 */
@property (nonatomic, strong) NSMutableArray *keywordAsset;

@end
