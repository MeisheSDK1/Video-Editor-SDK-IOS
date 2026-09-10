//
//  NvSDKUtils.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsStreamingContext.h"
#import "NvStreamingSdkCore.h"
#import "NvAsset.h"
#import <NvBaseCommon/NVDefineConfig.h>

NS_ASSUME_NONNULL_BEGIN

///特效相关
///Special effect correlation
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

@interface NvSDKUtils : NSObject

/// 初始化sdk
/// Initialize SDK
+ (NvsStreamingContext *)getSDKContext ;

/// 获取sdk版本号
/// get the sdk version
+ (NSString *)getSDKVersion;

/// 获取素材更多页面的标题
/// Get the title of the more pages of the material
/// @param type 素材类型   type
+ (NSString *)getMoreTitleName:(AssetType)type;

/// 获取素材比例
/// Get the material ratio
/// @param editMode 素材创建的比例
/// The ratio of material creation
+ (AspectRatio)convertRatio:(NvEditMode)editMode;

/// 把素材比例转成字符串
/// Convert the material ratio into a string
/// @param aspectRatio 素材比例
/// aspect Ratio
+ (NSString *)getAssetAspectRatioString:(int)aspectRatio;

/// 把素材大小转换成字符串
/// Convert asset size to string
/// @param packageSize 大小
/// size
+ (NSString *)getAssetPackageSizeString:(int)packageSize;

/// 获取素材下载路径文件夹
/// Obtain material download path folder
/// @param assetType 素材类型
/// asset Type
+ (NSString *)getAssetDownloadPath:(AssetType)assetType;

/// 判断是否为SDK内建滤镜
/// Determine whether it is a built-in filter in the SDK
/// @param filterName   滤镜名称
/// Filter name
+ (BOOL)isBuiltinFilter:(nullable NSString *)filterName;

/// 根据素材的本地地址素材版本号。例如脸贴的下载路径：/App/....../uuid.2.zip ,那么返回2
/// Source version number based on the local address of the source. For example, download path of face post: /App/...... /uuid.2.zip, then return 2
/// @param path 素材路径  Material path
/// Material path
+ (int)getAssetVersionWithPath:(NSString *_Nullable)path;

/// 获取特效颜色
/// Get special effect color
/// @param index 下标
/// index
+ (NSString *)getColorWithIndex:(NSInteger)index;

/// 获取视频的时长
/// Get the duration of the video
/// @param path 视频路径
/// Video path
+ (int64_t)getVideoDuration:(NSString *_Nonnull)path;

/// 获取转场特效封面名称
/// Get the name of the transition effect cover
/// @param fxUUID 素材的uuid
/// The uuid of the material
+ (NSString *)getTransitionsCoverName:(NSString *)fxUUID;

/// 创建timeline
/// Create timeline
/// @param editMode 比例
/// proportion
+ (NvsTimeline *)createTimeline:(NvEditMode)editMode;

/// 获取设置的预览模式
/// Get the set preview mode
+ (NvsLiveWindowHDRDisplayMode)liveWindowModelSetting;

/// 获取设置的位深度
/// Get the set bit depth
+ (NvsVideoResolutionBitDepth)resolutionModelSetting;

/// 获取导出hevc配置
/// Obtain and export hevc configuration
+ (NSString *)exportModelSetting;

/// 获取hevc设置字段
/// Get hevc setting field
+ (NSString *)hevcModelSetting;


+(NSString *)getSdkVersion;

/// 重新安装
/// reinstall
+ (NSMutableString *)reInstallAssetPackage:(NSString *)path license:(NSString * __nullable)licensePath assetType:(NvsAssetPackageType)assetType;
/// 安装美妆素材
/// Install makeup material
+ (NSMutableString *)installAssetPackage:(NSString *)path license:(NSString * __nullable)licensePath assetType:(NvsAssetPackageType)assetType;

/// 创建一个clip特效
/// Create a clip effect
/// @param string 特效名称或者特效包裹
/// Special effects name or special effects package
/// @param clip 片段
+ (NvsVideoFx *)createClipVideoFx:(NSString *)string withClip:(NvsVideoClip *)clip;

/// 获取片段上的某个特效
/// Gets a special effect on the clip
/// @param string 特效名称或者特效包裹
/// Special effects name or special effects package
/// @param clip 片段
+ (NvsVideoFx *)getClipVideoFx:(NSString *)string withClip:(NvsVideoClip *)clip;

@end

NS_ASSUME_NONNULL_END
