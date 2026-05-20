//
//  NvAsset.m
//  SDKDemo
//
//  Created by dx on 2018/6/9.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvAsset.h"
#import <NvBaseCommon/NvBaseUtils.h>
@implementation TypeInfo

@end
@implementation CategoryInfo

@end

@implementation NvAsset

- (instancetype)init {
    self = [super init];
    self.downloadStatus = DownloadStatusNone;
    self.typeInfo = [[TypeInfo alloc] init];
    self.categoryInfo = [[CategoryInfo alloc] init];
    return self;
}

- (BOOL)isUsable {
    return ![NvBaseUtils isStringEmpty:self.localDirPath] || ![NvBaseUtils isStringEmpty:self.bundledLocalDirPath] || ![NvBaseUtils isStringEmpty:self.packagePath];
}

- (BOOL)hasRemoteAsset {
    return ![NvBaseUtils isStringEmpty:self.packageUrl];
}

- (NvsAssetPackageType)getPackageType {//liyong 素材类型
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
        return NvsAssetPackageType_CaptionInAnimation;
    }else if (self.assetType == ASSET_CAPTION_OUTANIMATION) {
        return NvsAssetPackageType_CaptionOutAnimation;
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
    }else if (self.assetType == ASSET_ANIMATION_IN || self.assetType == ASSET_ANIMATION_OUT || self.assetType == ASSET_ANIMATION_COMBINE) {
        return NvsAssetPackageType_VideoFx;
    }else if (self.assetType == ASSET_STICKER_ANIMATION) {
        return NvsAssetPackageType_AnimatedStickerAnimation;
    } else if (self.assetType == ASSET_STICKER_INANIMATION) {
        return NvsAssetPackageType_AnimatedStickerInAnimation;
    }else if (self.assetType == ASSET_STICKER_OUTANIMATION) {
        return NvsAssetPackageType_AnimatedStickerOutAnimation;
    }else if (self.assetType == ASSET_MAKEUP) {
        return NvsAssetPackageType_Makeup;
    }
    else {
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

- (void)copyAsset:(NvAsset *)asset {
    self.zipUrl = asset.zipUrl;
    self.packagePath = asset.packagePath;
    self.licensePath = asset.licensePath;
    self.uuid = asset.uuid;
    self.category = asset.category;
    self.version = asset.version;
    self.aspectRatio = asset.aspectRatio;
    self.typeInfo = asset.typeInfo;
    self.categoryInfo = asset.categoryInfo;
    self.displayName = asset.displayName;
    self.coverUrl = asset.coverUrl;
    self.coverUrl2 = asset.coverUrl2;
    self.desc = asset.desc;
    self.tags = asset.tags;
    self.minAppVersion = asset.minAppVersion;
    self.localDirPath = asset.localDirPath;
    self.bundledLocalDirPath = asset.bundledLocalDirPath;
    self.isReserved = asset.isReserved;
    self.packageUrl = asset.packageUrl;
    self.remoteVersion = asset.remoteVersion;
    self.downloadProgress = asset.downloadProgress;
    self.packageSize = asset.packageSize;
    self.downloadStatus = asset.downloadStatus;
    self.assetType = asset.assetType;
    self.downloadTask =  asset.downloadTask;
    self.idx = asset.idx;
    self.isAdjusted = asset.isAdjusted;
    self.infoJson = [asset.infoJson copy];
}
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"uuid":@"id"};
}

- (BOOL)isSupportCapture {
    if (self.suitablePlatform == 1 || self.suitablePlatform == 0) {
        return YES;
    }
    return NO;
}
@end
