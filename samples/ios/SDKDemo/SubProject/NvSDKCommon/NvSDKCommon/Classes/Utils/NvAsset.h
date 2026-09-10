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
#define NV_KIND_ID_ALL              0
#define NV_CATEGORY_ID_CUSTOM           20000
#define NV_KIND_ID_CAPTION_RENDER       1
#define NV_KIND_ID_CAPTION_CONTEXT      2
#define NV_KIND_ID_CAPTION_INANIMATION  3
#define NV_KIND_ID_CAPTION_OUTANIMATION 4
#define NV_KIND_ID_CAPTION_ANIMATION    5
#define NV_CATEGORY_ID_FILTER_IN_ANIMATION  8

/*
 枚举值就是英文翻译
 The enumerated value is the English translation
 */
typedef enum{
    ASSET_THEME = 0,    //主题
    ASSET_FILTER,       //滤镜
    ASSET_CAPTION_STYLE,    //字幕
    ASSET_CAPTION_RENDERER,    //花字
    ASSET_CAPTION_CONTEXT,    //气泡
    ASSET_CAPTION_ANIMATION,    //组合动画
    ASSET_CAPTION_INANIMATION,  //入场动画
    ASSET_CAPTION_OUTANIMATION,    //出场动画
    ASSET_STICKER_ANIMATION,    //组合动画
    ASSET_STICKER_INANIMATION,  //入场动画
    ASSET_STICKER_OUTANIMATION,    //出场动画
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
    ASSET_MAKEUP,             //美妆
    ASSET_BEAUTY_TEMPLATE,    //美颜模版
}AssetType;

typedef enum {
    AspectRatio_16v9 = 1,
    AspectRatio_1v1 = 2,
    AspectRatio_9v16 = 4,
    AspectRatio_4v3 = 8,
    AspectRatio_3v4 = 16,
    AspectRatio_18v9 = 32,
    AspectRatio_9v18 = 64,
    AspectRatio_2d39v1 = 128,
    AspectRatio_2d55v1 = 256,
    AspectRatio_21v9 = 512,
    AspectRatio_9v21 = 1024,
    AspectRatio_6v7 = 2048,
    AspectRatio_7v6 = 4096,
    AspectRatio_All = AspectRatio_16v9 | AspectRatio_1v1 | AspectRatio_9v16 | AspectRatio_3v4 | AspectRatio_4v3 | AspectRatio_18v9 | AspectRatio_9v18 | AspectRatio_2d39v1 | AspectRatio_2d55v1 | AspectRatio_21v9 | AspectRatio_9v21 | AspectRatio_7v6 | AspectRatio_6v7,
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

@interface CategoryInfo : NSObject
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *displayNameZhCn;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) int ID;
@end

@interface TypeInfo : NSObject
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *displayNameZhCn;
@property (nonatomic, assign) int displayState;
@property (nonatomic, assign) int ID;
@end

@interface NvAsset : NSObject

@property (nonatomic, strong) NvsAssetPackageParticleDescParser *parser;
@property (nonatomic, assign) int aspectRatio;
@property (nonatomic, assign) int remoteAspectRatio;
@property (nonatomic, strong) NSURL *coverUrl2;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *localDirPath;
@property (nonatomic, strong) NSString *bundledLocalDirPath;
@property (nonatomic, assign) BOOL isReserved;
@property (nonatomic, assign) int remoteVersion;
@property (nonatomic, assign) float downloadProgress;
@property (nonatomic, assign) DownloadStatus downloadStatus;
@property (nonatomic, assign) AssetType assetType;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, assign) int idx;
@property (nonatomic, strong) NSString *zipUrl;
@property (nonatomic, strong) NSString *packagePath;
@property (nonatomic, strong) NSString *licensePath;
//
@property (nonatomic, assign) int category;
@property (nonatomic, strong) CategoryInfo *categoryInfo;
@property (nonatomic, assign) int costQuota;
@property(nonatomic, copy) NSString *coverUrl;
@property(nonatomic, copy) NSString *customDisplayName;
@property(nonatomic, copy) NSString *desc;
@property (nonatomic, assign) int kind;
@property(nonatomic, copy) NSString *displayName;
@property(nonatomic, copy) NSString *displayNameZhCn;
@property(nonatomic, copy) NSString *displayNamezhCN;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *infoUrl;
@property (nonatomic, copy) NSString *minAppVersion;
@property (nonatomic, assign) int packageSize;
@property (nonatomic, copy) NSString *packageUrl;
@property (nonatomic, copy) NSString *previewVideoUrl;
@property (nonatomic, assign) int rate;
@property (nonatomic, assign) int ratioFlag;
@property (nonatomic, assign) int sizeLevel;
@property (nonatomic, assign) int supportedAspectRatio;
@property (nonatomic, assign) int type;
@property (nonatomic, strong) TypeInfo *typeInfo;
@property (nonatomic, assign) int version;
@property (nonatomic, strong) NSDictionary *infoJson;
@property (nonatomic, assign) BOOL isPostPackage;
@property (nonatomic, assign) BOOL isAdjusted;
@property (nonatomic, assign) int suitablePlatform;
/**
 * 判断素材是否是预装素材。
 * Determine whether the material is preloaded
 */
- (BOOL)isReserved;

/**
 * 判断素材是否可用。说明：可用仅表示素材在本地或安装包里存在，并不表示它已安装。
 * Determine whether the material is available. Note: Available only means that the material exists locally or in the installation package, does not mean that it has been installed.
 */
- (BOOL)isUsable;

/**
 * 判断素材是否有在线素材。
 * Determine whether the material has online material.
 */
- (BOOL)hasRemoteAsset;

/**
 * 判断素材是否有更新。
 * Determine if the material has been updated.
 */
- (BOOL)hasUpdate;

/**
 * 判断素材是否正在安装。
 * Determine whether the material is being installed.
 */
- (BOOL)isInstalling;

/**
 * 判断素材是否安装失败。
 * Check whether materials fail to be installed.
 */
- (BOOL)isInstallingFailed;

/**
 * 判断素材是否安装完成。
 * Check whether the material is installed.
 */
- (BOOL)isInstallingFinished;

/**
 * 获取SDK中的素材类型表示方式
 * Gets the representation of the material type in the SDK
 */
- (NvsAssetPackageType)getPackageType;

/**
 * 对象的值拷贝。说用：更新素材的时候，用新的对象复制给旧的。
 * Copy of the value of the object. Use: When updating material, copy the new object to the old one.
 */
- (void)copyAsset:(NvAsset *)asset;

/**
 * 素材是否支持拍摄场景使用
 * Does the asset support the use of capture scenes
 */
- (BOOL)isSupportCapture;
@end
