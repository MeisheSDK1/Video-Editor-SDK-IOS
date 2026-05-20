//
//  NvMimoSDKUtils.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsStreamingContext.h"
#import "NvMimoAsset.h"

NS_ASSUME_NONNULL_BEGIN

#define NV_EFFECT_UUID_DOUDONG          @"A8A4344D-45DA-460F-A18F-C0E2355FE864"
#define NV_EFFECT_UUID_HUANJUE          @"Video Echo"
#define NV_EFFECT_UUID_LINHUNCHUQIAO    @"C6273A8F-C899-4765-8BFC-E683EE37AA84"
#define NV_EFFECT_UUID_JINGXIANG        @"6B7BE12C-9FA1-4ED0-8E81-E107632FFBC8"
#define NV_EFFECT_UUID_BOLANG           @"1CEE3777-A813-4378-AD52-7B264BD0CC4D"
#define NV_EFFECT_UUID_HEIMOFA          @"C02204D0-F3C3-495E-B65C-9F2C79E68573"
#define NV_EFFECT_COLOR_DOUDONG         @"FCB600"
#define NV_EFFECT_COLOR_HUANJUE         @"FF4D97"
#define NV_EFFECT_COLOR_LINHUNCHUQIAO   @"00ABFC"
#define NV_EFFECT_COLOR_JINGXIANG       @"00FCE0"
#define NV_EFFECT_COLOR_BOLANG          @"F8FC00"
#define NV_EFFECT_COLOR_HEIMOFA         @"5C00FC"
#define NV_EFFECT_COLOR_SLIDER_KNOB     @"52D3FF"

@interface NvMimoSDKUtils : NSObject

+ (NvsStreamingContext *_Nullable)getSDKContext;

+ (NSString *)getMoreTitleName:(AssetType)type;

+ (NSString *)getAssetAspectRatioString:(int)aspectRatio;

+ (NSString *)getAssetPackageSizeString:(int)packageSize;

+ (NSString *)getAssetDownloadPath:(AssetType)assetType;

/**
 * 判断是否为SDK内建滤镜
 * Determine if the filter is built into the SDK
 */
+ (BOOL)isBuiltinFilter:(nullable NSString *)filterName;

/**
 * 判断是否为SDK内建视频转场
 * Determine if the video transition is built into the SDK
 */
+ (BOOL)isBuiltinVideoTransition:(NSString *)videoTransition;

/**
 * 根据素材的本地地址素材版本号。例如脸贴的下载路径：/App/....../uuid.2.zip ,那么返回2
 * Build version number based on the local address of the build. For example, the download path of the face post is: /App/...... /uuid.2.zip, then returns 2
 */
+ (int)getAssetVersionWithPath:(NSString *_Nullable)path;

/**
 * 获取特效颜色
 * Getting the effect color
 */

+ (NSString *)getColorWithIndex:(NSInteger)index;

/**
 * 获取视频的时长
 * Get the duration of the video
 */
+ (int64_t)getVideoDuration:(NSString *_Nonnull)path;

/**
 * 获取转场特效封面名称
 * Gets the cover name of the transition effect
 */
+ (NSString *)getTransitionsCoverName:(NSString *)fxUUID;

+ (NvsLiveWindowHDRDisplayMode)liveWindowModelSetting;
+ (NvsVideoResolutionBitDepth)resolutionModelSetting;
+ (NSString *)exportModelSetting;
+ (NSString *)hevcModelSetting;

@end

NS_ASSUME_NONNULL_END
