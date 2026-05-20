//
//  NvAsset.h
//  SDKDemo
//
//  Created by dx on 2018/6/9.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsAssetPackageParticleDescParser.h"
#import "NvsStreamingContext.h"
#define NV_CATEGORY_ID_ALL              0
#define NV_CATEGORY_ID_CUSTOM           20000
/// The following Chinese explanatory variable names do not need to be translated
typedef enum{
    ASSET_THEME = 0,    //主题
    ASSET_FILTER,       //滤镜
    ASSET_CAPTION_STYLE,    //字幕
    ASSET_CAPTION_RENDERER, //花字
    ASSET_CAPTION_CONTEXT,  //气泡
    ASSET_CAPTION_INANIMATION, //入动画
    ASSET_CAPTION_OUTANIMATION, //出动画
    ASSET_CAPTION_ANIMATION, //组合动画
    ASSET_ANIMATED_STICKER, //贴纸
    ASSET_VIDEO_TRANSITION, //转场
    ASSET_CAPTURE_SCENE,    //拍摄背景
    ASSET_FONT,             //字体
    ASSET_PARTICLE,         //粒子
    ASSET_FACE_STICKER,     //脸贴
    ASSET_CUSTOM_ANIMATED_STICKER,  //自定义贴纸
    ASSET_FACE1_STICKER,         //脸贴1
    ASSET_SUPERZOOM,         //推镜
    ASSET_ARSCENE,         //美摄人脸道具
    ASSET_COMPOUND_CAPTION,  //组合（复合）字幕
    ASSET_ANIMATION_IN,  //动画入
    ASSET_ANIMATION_OUT,  //动画出
    ASSET_ANIMATION_COMBINE,  //动画组合
}AssetType;

typedef enum {
    AspectRatio_16v9 = 1,
    AspectRatio_1v1 = 2,
    AspectRatio_9v16 = 4,
    AspectRatio_4v3 = 8,
    AspectRatio_3v4 = 16,
    AspectRatio_18v9 = 32,
    AspectRatio_9v18 = 64,
    AspectRatio_All = AspectRatio_16v9 | AspectRatio_1v1 | AspectRatio_9v16 | AspectRatio_3v4 | AspectRatio_4v3 | AspectRatio_18v9 | AspectRatio_9v18,
}AspectRatio;

typedef enum {
    DownloadStatusNone,
    DownloadStatusPending,
    DownloadStatusInProgress,
    DownloadStatusDecompressing,
    DownloadStatusFinished,
    DownloadStatusFailed,
    DownloadStatusDecompressingFailed
}DownloadStatus;

typedef enum {
    ANIMATED_STICKER_SILENT = 1,
    ANIMATED_STICKER_SOUND
}NvAnimatedStickerCategory;

@interface NvMimoAsset : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) int categoryId;
@property (nonatomic, strong) NvsAssetPackageParticleDescParser *parser;
@property (nonatomic, assign) int version;
@property (nonatomic, assign) int aspectRatio;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *coverUrl;
@property (nonatomic, strong) NSURL *coverUrl2;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *minAppVersion;
@property (nonatomic, strong) NSString *localDirPath;
@property (nonatomic, strong) NSString *bundledLocalDirPath;
@property (nonatomic, assign) BOOL isReserved;
@property (nonatomic, strong) NSURL *remotePackageUrl;
@property (nonatomic, assign) int remoteVersion;
@property (nonatomic, assign) float downloadProgress;
@property (nonatomic, assign) int remotePackageSize;
@property (nonatomic, assign) DownloadStatus downloadStatus;
@property (nonatomic, assign) AssetType assetType;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, assign) int idx;

/**
 * 判断素材是否是预装素材。
 * Determine if the material is preloaded.
 */
- (BOOL)isReserved;

/**
 * 判断素材是否可用。说明：可用仅表示素材在本地或安装包里存在，并不表示它已安装。
 * Determine if the material is available. Note: Available only means that the asset is present locally or in the installed package, does not mean that it is installed.
 */
- (BOOL)isUsable;

/**
 * 判断素材是否有在线素材。
 * Determine if the material has online material.
 */
- (BOOL)hasRemoteAsset;

/**
 * 判断素材是否有更新。
 * Determine if the material has been updated.
 */
- (BOOL)hasUpdate;

/**
 * 判断素材是否正在安装。
 * Determine if assets are being installed.
 */
- (BOOL)isInstalling;

/**
 * 判断素材是否安装失败。
 * Determine if the asset failed to install.
 */
- (BOOL)isInstallingFailed;

/**
 * 判断素材是否安装完成。
 * Determine if assets have been installed.
 */
- (BOOL)isInstallingFinished;

/**
 * 获取SDK中的素材类型表示方式
 * Gets the representation of the asset type in the SDK
 */
- (NvsAssetPackageType)getPackageType;

/**
 * 对象的值拷贝。说用：更新素材的时候，用新的对象复制给旧的。
 * Object value copy. Use: When updating assets, copy the new object to the old one.
 */
- (void)copyAsset:(NvMimoAsset *)asset;
@end
