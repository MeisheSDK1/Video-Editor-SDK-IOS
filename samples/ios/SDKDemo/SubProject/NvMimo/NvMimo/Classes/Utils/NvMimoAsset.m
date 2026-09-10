//
//  NvAsset.m
//  SDKDemo
//
//  Created by dx on 2018/6/9.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMimoAsset.h"
#import "NvMimoUtils.h"

@implementation NvMimoAsset

- (instancetype)init {
    self = [super init];
    self.downloadStatus = DownloadStatusNone;
    return self;
}

- (NvsAssetPackageType)getPackageType {
    if (self.assetType == ASSET_THEME) {
        return NvsAssetPackageType_Theme;
    } else if (self.assetType == ASSET_FILTER) {
        return NvsAssetPackageType_VideoFx;
    } else if (self.assetType == ASSET_CAPTION_STYLE) {
        return NvsAssetPackageType_CaptionStyle;
    } else if (self.assetType == ASSET_CAPTION_RENDERER) {
        return NvsAssetPackageType_CaptionRenderer;
    } else if (self.assetType == ASSET_CAPTION_CONTEXT) {
        return NvsAssetPackageType_CaptionContext;
    } else if (self.assetType == ASSET_CAPTION_ANIMATION) {
        return NvsAssetPackageType_CaptionAnimation;
    } else if (self.assetType == ASSET_CAPTION_INANIMATION) {
        return NvsAssetPackageType_CaptionOutAnimation;
    }else if (self.assetType == ASSET_CAPTION_OUTANIMATION) {
        return NvsAssetPackageType_CaptionInAnimation;
    } else if (self.assetType == ASSET_ANIMATED_STICKER) {
        return NvsAssetPackageType_AnimatedSticker;
    } else if (self.assetType == ASSET_VIDEO_TRANSITION) {
        return NvsAssetPackageType_VideoTransition;
    } else if (self.assetType == ASSET_CAPTURE_SCENE) {
        return NvsAssetPackageType_CaptureScene;
    } else if (self.assetType == ASSET_PARTICLE) {
        return NvsAssetPackageType_VideoFx;
    } else if (self.assetType == ASSET_FACE_STICKER) {
        return NvsAssetPackageType_CaptureScene;
    } else if (self.assetType == ASSET_CUSTOM_ANIMATED_STICKER) {
        return NvsAssetPackageType_AnimatedSticker;
    } else if (self.assetType == ASSET_ARSCENE) {
        return NvsAssetPackageType_ARScene;
    } else if (self.assetType == ASSET_COMPOUND_CAPTION) {
        return NvsAssetPackageType_CompoundCaption;
    } else {
        return NvsAssetPackageType_Theme;
    }
}

- (BOOL)hasUpdate {
    if (![self isUsable] || ![self hasRemoteAsset])
        return NO;
    
    return _remoteVersion > _version;
}

- (BOOL)isReserved {
    return _isReserved;
}

- (BOOL)isInstalling {
    return self.downloadStatus == DownloadStatusDecompressing;
}

- (BOOL)isInstallingFailed {
    return self.downloadStatus == DownloadStatusFailed;
}

- (BOOL)isInstallingFinished {
    return self.downloadStatus == DownloadStatusFinished;
}

- (void)copyAsset:(NvMimoAsset *)asset {
    self.uuid = asset.uuid;
    self.categoryId = asset.categoryId;
    self.version = asset.version;
    self.aspectRatio = asset.aspectRatio;
    self.name = asset.name;
    self.coverUrl = asset.coverUrl;
    self.coverUrl2 = asset.coverUrl2;
    self.desc = asset.desc;
    self.tags = asset.tags;
    self.minAppVersion = asset.minAppVersion;
    self.localDirPath = asset.localDirPath;
    self.bundledLocalDirPath = asset.bundledLocalDirPath;
    self.isReserved = asset.isReserved;
    self.remotePackageUrl = asset.remotePackageUrl;
    self.remoteVersion = asset.remoteVersion;
    self.downloadProgress = asset.downloadProgress;
    self.remotePackageSize = asset.remotePackageSize;
    self.downloadStatus = asset.downloadStatus;
    self.assetType = asset.assetType;
    self.downloadTask =  asset.downloadTask;
    self.idx = asset.idx;
}
@end
