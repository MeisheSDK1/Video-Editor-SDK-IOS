//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Sep 6. 2018
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import "NvsAssetPackageManager.h"
#import "NvsVideoEffect.h"
#import "NvsVideoEffectTransition.h"
#import "NvsVideoEffectAnimatedSticker.h"
#import "NvsVideoEffectCompoundCaption.h"
#import "NvsVideoEffectCaption.h"
#import "NvsEffectRenderCore.h"
#import "NvsEffectCommonDef.h"

/*! \if ENGLISH
*   \brief Effect SDK context creation flag.
*   \else
*   \brief Effect SDK上下文创建标志
*   \endif
*/
typedef enum {
    NvsEffectSdkContextFlag_NoFlag = 0
} NvsEffectSdkContextFlag;

/*! \if ENGLISH
*   \brief Human detection feature
*   \else
*   \brief 人体检测特征标志
*   \endif
*/
typedef enum {
    NvsEffectSdkHumanDetectionFeature_FaceLandmark = 1,
    NvsEffectSdkHumanDetectionFeature_FaceAction = 2,
    NvsEffectSdkHumanDetectionFeature_AvatarExpression = 4,
    NvsEffectSdkHumanDetectionFeature_VideoMode = 8,
    NvsEffectSdkHumanDetectionFeature_ImageMode = 16,
    NvsEffectSdkHumanDetectionFeature_SemiImageMode = 32768,
    NvsEffectSdkHumanDetectionFeature_MultiThread = 32,
    NvsEffectSdkHumanDetectionFeature_SingleThread = 64,
    NvsEffectSdkHumanDetectionFeature_Extra = 128,
    NvsEffectSdkHumanDetectionFeature_Background = 256,
    NvsEffectSdkHumanDetectionFeature_HandLandmark = 512,
    NvsEffectSdkHumanDetectionFeature_HandAction = 1024,
    NvsEffectSdkHumanDetectionFeature_HandBone = 2048,
    NvsEffectSdkHumanDetectionFeature_EyeballLandmark = 4096,
    NvsEffectSdkHumanDetectionFeature_MultiDetect = 8192,
    NvsEffectSdkHumanDetectionFeature_SegmentationSky = 16384,
    NvsEffectSdkHumanDetectionFeature_HalfBody = 65536,
    NvsEffectSdkHumanDetectionFeature_FaceAttri = 131072,
    NvsEffectSdkHumanDetectionFeature_FaceAttriShape = 262144
} NvsEffectSdkHumanDetectionFeatureFlag;

/*! \anchor HUMAN_DETECTION_OPTIONS */
/*!
 *  \if ENGLISH
 *   @name Options of human detection
 *  \else
 *   @name 检测选项
 *  \endif
*/
//!@{
#define HUMAN_DETECTION_OPTIONS_FACE_DETECT_THREAD_NUM            @"Face Detect Thread Num"       //!< \if ENGLISH Face detect thread number \else 人脸检测线程数 \endif
#define HUMAN_DETECTION_OPTIONS_FACE_LANDMARK_THREAD_NUM          @"Face Landmark Thread Num"     //!< \if ENGLISH Face landmark thread number \else 人脸点位检测线程数 \endif
#define HUMAN_DETECTION_OPTIONS_FACE_TRACK_THREAD_NUM             @"Face Track Thread Num"        //!< \if ENGLISH Face track thread number \else 人脸跟踪线程数 \endif
#define HUMAN_DETECTION_OPTIONS_SKY_SEGMENTATION_THREAD_NUM       @"Sky Segmentation Thread Num"  //!< \if ENGLISH Face track thread number \else 天空分割线程数 \endif
//!@}

/*! \if ENGLISH
*   \brief Human detection data packet type
*   \else
*   \brief 人体检测数据包类型
*   \endif
*/
typedef enum {
    NvsEffectSdkHumanDetectionDataType_FakeFace = 0,
    NvsEffectSdkHumanDetectionDataType_Makeup,
    NvsEffectSdkHumanDetectionDataType_SkinColor,
    NvsEffectSdkHumanDetectionDataType_PE106,
    NvsEffectSdkHumanDetectionDataType_PE240,
    NvsEffectSdkHumanDetectionDataType_CustomAvatar,
    NvsEffectSdkHumanDetectionDataType_Makeup2,     // deprecated, replaced by NvsHumanDetectionDataType_FaceCommon
    NvsEffectSdkHumanDetectionDataType_FaceCommon,
    NvsEffectSdkHumanDetectionDataType_AdvancedBeauty,
} NvsEffectSdkHumanDetectionDataTypeFlag;

@protocol NvsEffectSdkContextDebugLogDelegate <NSObject>
@optional

/*! \if ENGLISH
*  \brief log information.
*  \param level log level
*  \param log log string.
*  \else
*  \brief 日志信息
*  \param level 日志级别, 请参见[日志级别](@ref NvsDebugLevel)
*  \param log 日志
*  \endif
*  \since 3.13.0
*/
- (void)onDebugLogArrived:(int)level logStr:(NSString*)logStr;
@end

/*! \if ENGLISH
*   \brief Effect SDK context class
*   \else
*   \brief Effect SDK上下文类
*   \endif
*/
NVS_EXPORT @interface NvsEffectSdkContext : NSObject

@property (readonly) NvsAssetPackageManager *assetPackageManager; //!< \if ENGLISH Asset package manager\else 素材包管理器 \endif

/*! \if ENGLISH
 *  \brief Verifies the SDK license. Note: This interface must be called before the NvsStreamingContext is initialized.
 *  \param sdkLicenseFilePath SDK license file path
 *  \return Returns BOOL value. YES indicates that the license verification is successful, and NO indicates that the verification fails. If the verification fails, a subsequent watermark will appear in video preview and generated videos.
 *  \else
 *  \brief 验证SDK授权文件。注意：授权文件接口必须在NvsStreamingContext初始化之前调用。
 *  \param sdkLicenseFilePath SDK授权文件路径
 *  \return 返回BOOL值。YES表示授权验证成功，NO则验证失败。若验证失败，则后续的视频预览和生成视频会出现水印。
 *  \endif
*/
+ (BOOL)verifySdkLicenseFile:(NSString *)sdkLicenseFilePath;

+ (void)setDebugLogDelegate:(id<NvsEffectSdkContextDebugLogDelegate>)debugLogDelegate;
/*! \if ENGLISH
 *  \brief Gets the unique instance of the effect sdk context.
 *  \return Returns the instance of the effect sdk context.
 *  \else
 *  \brief 获取effect sdk上下文的唯一实例
 *  \return 返回effect sdk上下文的对象实例
 *  \endif
 *  \sa destroyInstance
*/
+ (NvsEffectSdkContext *)sharedInstance:(NvsEffectSdkContextFlag)flags;

/*! \if ENGLISH
*   \brief Destroys the effect sdk context instance.
*   \else
*   \brief 销毁effect sdk上下文实例。
*   \endif
*   \sa sharedInstance:
*/
+ (void)destroyInstance;

/*! \if ENGLISH
*   \brief Checks if the current SDK contains an AR module.
*   \return Returns value of 0 means that no AR module exists, and a value greater than 0 means that the AR module exists.
*   \else
*   \brief 检测当前SDK是否含有AR模块
*   \return 返回值0表示不含有AR模块，大于0表示含有AR模块
*   \endif
*   \since 2.5.0
*/
+ (int)hasARModule;

/*! \if ENGLISH
*   \brief Initializes the human body detection mechanism.
*   \param modelFilePath The file path of the face model
*   \param licenseFilePath The file path of license
*   \param features Human detection feature flag field. Please refer to [Human detection feature](@ref NvsEffectSdkHumanDetectionFeatureFlag)
*   \return The return value indicates whether it is successful
*   \else
*   \brief 初始化人体检测机制
*   \param modelFilePath 模型文件路径
*   \param licenseFilePath 授权文件路径
*   \param features 人体检测特征标志字段。请参见[人体检测特征标志](@ref NvsEffectSdkHumanDetectionFeatureFlag)
*   \return 返回值表示是否成功
*   \endif
*   \since 2.5.0
*/
+ (BOOL)initHumanDetection:(NSString *)modelFilePath
           licenseFilePath:(NSString *)licenseFilePath
                  features:(int)features;

/*! \if ENGLISH
 *  \brief Initializes the human body detection mechanism.Only once needed
 *  \param modelFilePath Path of the model file
 *  \param licenseFilePath Path of the license file
 *  \param features human detection flag field. Please refer to [Flag of human detection](@ref NvsEffectSdkHumanDetectionFeatureFlag).
 *  \param options detect options, please refer to [Human detection features](@ref HUMAN_DETECTION_OPTIONS).
 *  \else
 *  \brief 初始化人体检测机制, 只初始化一次
 *  \param modelFilePath 模型文件路径
 *  \param licenseFilePath 授权文件路径
 *  \param features 人体检测特征标志字段。请参见[人体检测特征标志](@ref NvsEffectSdkHumanDetectionFeatureFlag)
 *  \param options 检测选项，请参加[检测选项](@ref HUMAN_DETECTION_OPTIONS)
 *  \endif
 *  \since 3.14.0
 *  \sa closeHumanDetection
*/
+ (BOOL)initHumanDetection:(NSString *)modelFilePath
           licenseFilePath:(NSString *)licenseFilePath
                  features:(int)features
                   options:(NSMutableDictionary *)options;

/*! \if ENGLISH
 *  \brief Human detection initialization extension.
 *  \param modelFilePath Path of the model file
 *  \param licenseFilePath Path of the license file
 *  \param features human detection flag field. Please refer to [Flag of human detection](@ref NvsEffectSdkHumanDetectionFeatureFlag).
 *  \else
 *  \brief 初始化人体检测机制
 *  \param modelFilePath 模型文件路径
 *  \param licenseFilePath 授权文件路径
 *  \param features 人体检测特征标志字段。请参见[人体检测特征标志](@ref NvsEffectSdkHumanDetectionFeatureFlag)
 *  \endif
 *  \since 2.17.1
*/
+ (BOOL)initHumanDetectionExt:(NSString *)modelFilePath
              licenseFilePath:(NSString *)licenseFilePath
                     features:(int)features;

/*! \if ENGLISH
 *  \brief Human detection initialization extension. must called after initHumanDetection
 *  \param modelFilePath Path of the model file
 *  \param licenseFilePath Path of the license file
 *  \param features human detection flag field. Please refer to [Flag of human detection](@ref NvsEffectSdkHumanDetectionFeatureFlag).
 *  \param options detect options, please refer to [Human detection features](@ref HUMAN_DETECTION_OPTIONS).
 *  \else
 *  \brief 初始化人体检测扩展机制，必须先调用initHumanDetection
 *  \param modelFilePath 模型文件路径
 *  \param licenseFilePath 授权文件路径
 *  \param features 人体检测特征标志字段。请参见[人体检测特征标志](@ref NvsEffectSdkHumanDetectionFeatureFlag)
 *  \param options 检测选项，请参加[检测选项](@ref HUMAN_DETECTION_OPTIONS)
 *  \endif
 *  \since 3.14.0
*/
+ (BOOL)initHumanDetectionExt:(NSString *)modelFilePath
              licenseFilePath:(NSString *)licenseFilePath
                     features:(int)features
                      options:(NSMutableDictionary *)options;

/*! \if ENGLISH
*   \brief Setup human detection data package.
*   \param dataType Human detection data package type.Please refer to[Human detection data packet type](@ref NvsEffectSdkHumanDetectionDataTypeFlag).
*   \param dataFilePath The file path of data
*   \return The return value indicates whether it is successful.
*   \else
*   \brief 安装人体检测相关数据包
*   \param dataType 人体检测数据包类型。请参见[人体检测数据包类型](@ref NvsEffectSdkHumanDetectionDataTypeFlag)
*   \param dataFilePath 数据文件路径
*   \return 返回值表示是否成功
*   \endif
*   \since 2.6.0
*/
+ (BOOL)setupHumanDetectionData:(int)dataType
           dataFilePath:(NSString *)dataFilePath;

/*! \if ENGLISH
*   \brief Turns off the human detection mechanism.
*   \else
*   \brief 关闭人体检测机制
*   \endif
*   \since 2.5.0
*/
+ (void)closeHumanDetection;

/*! \if ENGLISH
 *  \brief Gets the version information of Meishe SDK
 *  \param majorVersion Major version number
 *  \param minorVersion Minor version number
 *  \param revisionNumber Revision number
 *  \else
 *  \brief 获取美摄SDK的版本信息
 *  \param majorVersion 主版本号
 *  \param minorVersion 次版本号
 *  \param revisionNumber 修订版本号
 *  \endif
 *  \since 2.23.0
*/
+ (void)getSdkVersion:(int *)majorVersion minorVersion:(int *)minorVersion revisionNumber:(int *)revisionNumber;

/*! \if ENGLISH
 *  \brief Gets a list of all build-in video effects' names.
 *  \return Returns an array object containing all the build-in video effects' names.
 *  \else
 *  \brief 获取全部内嵌视频特效名称列表
 *  \return 返回包含所有内嵌的视频特效名称的数组对象
 *  \endif
*/
- (NSArray *)getAllBuiltinVideoFxNames;

/*! \if ENGLISH
 *  \brief Creates a special effect object.
 *  \param effectId Special effects ID. For build-in video effects, it is the name of the effect. If it is a resource package effect, it is the resource package ID.
 *  \param aspectRatio Aspect ratio
 *  \return Returns the created special effect object.
 *  \else
 *  \brief 创建特效对象
 *  \param effectId 特效id。对于内嵌视频特效，就是特效的名字，如果是资源包特效，就是资源包id
 *  \param aspectRatio 横纵比
 *  \return 返回创建的特效对象
 *  \endif
*/
- (NvsVideoEffect *)createVideoEffect:(NSString *)effectId aspectRatio:(NvsEffectRational)aspectRatio;

/*! \if ENGLISH
 *  \brief Creates a special effect object.
 *  \param effectId Special effects ID. For build-in video effects, it is the name of the effect. If it is a resource package effect, it is the resource package ID.
 *  \param aspectRatio Aspect ratio
 *  \param realTime realTime mode
 *  \return Returns the created special effect object.
 *  \else
 *  \brief 创建特效对象
 *  \param effectId 特效id。对于内嵌视频特效，就是特效的名字，如果是资源包特效，就是资源包id
 *  \param aspectRatio 横纵比
 *  \param realTime 实时模式
 *  \return 返回创建的特效对象
 *  \endif
*/
- (NvsVideoEffect *)createVideoEffect:(NSString *)effectId aspectRatio:(NvsEffectRational)aspectRatio realTime:(BOOL)realTime;

/*! \if ENGLISH
 *  \brief Creates a special transition object.
 *  \param effectId Special transitions ID. For build-in video transitions, it is the name of the effect. If it is a resource package transition, it is the resource package ID.
 *  \param aspectRatio Aspect ratio
 *  \param realTime realTime mode
 *  \return Returns the created special transition object.
 *  \else
 *  \brief 创建转场对象
 *  \param transitionId 转场id。对于内嵌视频转场特效，就是特效的名字，如果是资源包特效，就是资源包id
 *  \param aspectRatio 横纵比
 *  \return 返回创建的转场特效对象
 *  \endif
*/
- (NvsVideoEffectTransition *)createVideoTransition:(NSString *)transitionId aspectRatio:(NvsEffectRational)aspectRatio;

/*! \if ENGLISH
 *  \brief Creates animated sticker object.
 *  \param inPoint In point of sticker
 *  \param duration Duration of sticker
 *  \param isPanoramic Whether panoramic sticker
 *  \param animatedStickerId  Animated sticker package id.
 *  \param aspectRatio  The aspect ratio of animated sticker.
 *  \return Returns the created animated sticker object.
 *  \else
 *  \brief 创建贴纸对象
 *  \param inPoint 贴纸的时间起点
 *  \param duration 贴纸的时长
 *  \param isPanoramic 是否是全景贴纸
 *  \param animatedStickerId 贴纸资源包id
 *  \param aspectRatio 贴纸的画幅比。
 *  \return 返回创建的贴纸对象
 *  \endif
 */
- (NvsVideoEffectAnimatedSticker *)createAnimatedSticker:(int64_t)inPoint duration:(int64_t)duration isPanoramic:(bool)isPanoramic packageId:(NSString *)packageId aspectRatio:(NvsEffectRational)aspectRatio;

/*! \if ENGLISH
 *  \brief Creates custom animated sticker object.
 *  \param inPoint In point of sticker
 *  \param duration Duration of sticker
 *  \param isPanoramic Whether panoramic sticker
 *  \param animatedStickerId  Animated sticker package id.
 *  \param customImageFilePath  Custom sticker image file path.
 *  \param aspectRatio  The aspect ratio of animated sticker.
 *  \return Returns the created animated sticker object.
 *  \else
 *  \brief 创建自定义贴纸对象
 *  \param inPoint 贴纸的时间起点
 *  \param duration 贴纸的时长
 *  \param isPanoramic 是否是全景贴纸
 *  \param animatedStickerId 贴纸资源包id
 *  \param customImageFilePath 自定义贴纸图片路径
 *  \param aspectRatio 贴纸的画幅比。
 *  \return 返回创建的贴纸对象
 *  \endif
 */
- (NvsVideoEffectAnimatedSticker *)createCustomAnimatedSticker:(int64_t)inPoint duration:(int64_t)duration isPanoramic:(bool)isPanoramic packageId:(NSString *)packageId customImageFilePath:(NSString *)customImageFilePath aspectRatio:(NvsEffectRational)aspectRatio;

/*! \if ENGLISH
 *  \brief Creates compound caption object.
 *  \param inPoint In point of caption
 *  \param duration Duration of caption
 *  \param packageId  caption package id.
 *  \param aspectRatio  The aspect ratio of caption
 *  \return Returns the created compound caption object.
 *  \else
 *  \brief 创建复合字幕对象
 *  \param inPoint 字幕的时间起点
 *  \param duration 字幕的时长
 *  \param packageId 字幕资源包id
 *  \param aspectRatio 字幕的画幅比。
 *  \return 返回创建的复合字幕对象
 *  \endif
 */
- (NvsVideoEffectCompoundCaption *)createCompoundCaption:(int64_t)inPoint duration:(int64_t)duration packageId:(NSString *)packageId aspectRatio:(NvsEffectRational)aspectRatio;

/*! \if ENGLISH
 *  \brief Creates compound caption object.
 *  \param inPoint In point of caption
 *  \param duration Duration of caption
 *  \param packageId  caption package id.
 *  \param aspectRatio  The aspect ratio of caption
 *  \return Returns the created compound caption object.
 *  \else
 *  \brief 创建全景图复合字幕对象
 *  \param inPoint 字幕的时间起点
 *  \param duration 字幕的时长
 *  \param packageId 字幕资源包id
 *  \param aspectRatio 字幕的画幅比。
 *  \return 返回创建的复合字幕对象
 *  \endif
 */
- (NvsVideoEffectCompoundCaption *)createPanoramicCompoundCaption:(int64_t)inPoint duration:(int64_t)duration packageId:(NSString *)packageId aspectRatio:(NvsEffectRational)aspectRatio;

/*! \if ENGLISH
 *  \brief Create caption
 *  \param captionText Text of caption
 *  \param inPoint The in point of the caption (in microseconds)
 *  \param duration Caption display duration (in microseconds)
 *  \param captionStylePackageId Caption style package Id.If it does not exist, you can pass an empty string or null.
 *  \param aspectRatio  The aspect ratio of caption
 *  \return Returns the NvsTimelineCaption object.
 *  <br>It will return null in the following situations:
 *  <br>1. No caption function authorization;
 *  <br>2. If inPoint is less than 0 or greater than or equal to the current timeline duration, or duration is not greater than 0.
 *  \else
 *  \brief 创建字幕
 *  \param captionText 字幕的文字
 *  \param inPoint 字幕在时间线上的起点（单位微秒）
 *  \param duration 字幕显示时长（单位微秒）
 *  \param captionStylePackageId 字幕样式包Id，不存在的话，可以传空字符串或者null
 *  \param aspectRatio 字幕的画幅比。
 *  \return 返回时间线字幕对象
 *  <br>以下情况会返回null：
 *  <br>1.没有字幕功能授权；
 *  <br>2.如果inPoint小于0，或者duration不大于0。
 *  \endif
 *  \since 2.20.0
*/
- (NvsVideoEffectCaption *)createCaption:(NSString *)captionText inPoint:(int64_t)inPoint duration:(int64_t)duration captionStylePackageId:(NSString *)captionStylePackageId aspectRatio:(NvsEffectRational)aspectRatio;

/*! \if ENGLISH
 *  \brief Add a panorama caption on the timeline
 *  \param captionText Text of caption
 *  \param inPoint The in point of the caption on the timeline (in microseconds)
 *  \param duration Caption display duration (in microseconds)
 *  \param captionStylePackageId Caption style package Id.If it does not exist, you can pass an empty string or null.
 *  \param aspectRatio  The aspect ratio of caption
 *  \return Returns the NvsTimelineCaption object.
 *  <br>It will return null in the following situations:
 *  <br>1. No caption function authorization;
 *  <br>2. If inPoint is less than 0 or greater than or equal to the current timeline duration, or duration is not greater than 0.
 *  \else
 *  \brief 在时间线上添加全景图字幕
 *  \param captionText 字幕的文字
 *  \param inPoint 字幕在时间线上的入点（单位微秒）
 *  \param duration 字幕的显示时长（单位微秒）
 *  \param captionStylePackageId 字幕样式包Id，不存在的话，可以传空字符串或者null
 *  \param aspectRatio 字幕的画幅比。
 *  \return 返回时间线字幕对象
 *  <br>以下情况会返回null：
 *  <br>1.没有字幕功能授权；
 *  <br>2.如果inPoint小于0，或者duration不大于0。
 *  \endif
 *  \since 2.20.0
*/
- (NvsVideoEffectCaption *)createPanoramicCaption:(NSString *)captionText inPoint:(int64_t)inPoint duration:(int64_t)duration captionStylePackageId:(NSString *)captionStylePackageId aspectRatio:(NvsEffectRational)aspectRatio;

/*! \if ENGLISH
 *  \brief Add a modular caption on the timeline
 *  \param captionText Text of caption
 *  \param inPoint The in point of the caption on the timeline (in microseconds)
 *  \param duration Caption display duration (in microseconds)
 *  \param aspectRatio  The aspect ratio of caption
 *  \return Returns the NvsTimelineCaption object.
 *  <br>It will return null in the following situations:
 *  <br>1. No caption function authorization;
 *  <br>2. If inPoint is less than 0 or greater than or equal to the current timeline duration, or duration is not greater than 0.
 *  \else
 *  \brief 在时间线上添加模块字幕
 *  \param captionText 字幕的文字
 *  \param inPoint 字幕在时间线上的起点（单位微秒）
 *  \param duration 字幕显示时长（单位微秒）
 *  \param aspectRatio 字幕的画幅比。
 *  \return 返回时间线字幕对象
 *  <br>以下情况会返回null：
 *  <br>1.没有字幕功能授权；
 *  <br>2.如果inPoint小于0，或者duration不大于0。
 *  \endif
 *  \since 2.20.0
 */
- (NvsVideoEffectCaption *)createModularCaption:(NSString *)captionText inPoint:(int64_t)inPoint duration:(int64_t)duration aspectRatio:(NvsEffectRational)aspectRatio;

/*! \if ENGLISH
 *  \brief Add a modular caption on the timeline
 *  \param captionText Text of caption
 *  \param inPoint The in point of the caption on the timeline (in microseconds)
 *  \param duration Caption display duration (in microseconds)
 *  \param aspectRatio  The aspect ratio of caption
 *  \return Returns the NvsTimelineCaption object.
 *  <br>It will return null in the following situations:
 *  <br>1. No caption function authorization;
 *  <br>2. If inPoint is less than 0 or greater than or equal to the current timeline duration, or duration is not greater than 0.
 *  \else
 *  \brief 在时间线上添加全景图模块字幕
 *  \param captionText 字幕的文字
 *  \param inPoint 字幕在时间线上的起点（单位微秒）
 *  \param duration 字幕显示时长（单位微秒）
 *  \param aspectRatio 字幕的画幅比。
 *  \return 返回时间线字幕对象
 *  <br>以下情况会返回null：
 *  <br>1.没有字幕功能授权；
 *  <br>2.如果inPoint小于0，或者duration不大于0。
 *  \endif
 *  \since 2.20.0
 */
- (NvsVideoEffectCaption *)createPanoramicModularCaption:(NSString *)captionText inPoint:(int64_t)inPoint duration:(int64_t)duration aspectRatio:(NvsEffectRational)aspectRatio;

/*! \if ENGLISH
 *  \brief Creates a special effect rendering object.
 *  \return Returns the created effect rendering object.
 *  \else
 *  \brief 创建特效渲染对象
 *  \return 返回创建的特效渲染对象
 *  \endif
*/
- (NvsEffectRenderCore *)createEffectRenderCore;

/*! \if ENGLISH
 *  \brief Register fonts according to file path.
 *  \return Returns the fontfamily of the font. If the file path is empty or the registration fails, it returns an empty string. If the context does not exist, it returns nil.
 *  \else
 *  \brief 根据文件路径注册字体
 *  \return 返回字体的fontFamily，如果文件路径为空，或者注册失败返回空字符串，如果context不存在返回nil.
 *  \endif
 *  \since 2.23.0
*/
- (NSString *)registerFontByFilePath:(NSString *)filePath;

/*! \if ENGLISH
 *  \brief Unregister fonts according to file path.
 *  \else
 *  \brief 根据文件路径注销字体
 *  \endif
 *  \since 2.23.0
*/
- (void)UnregisterFontByFilePath:(NSString *)filePath;

/*! \cond */

/*! \if ENGLISH
 *  \brief Verifies whether a feature is available.
 *  \param sdkFunctionName The name of the sdk function
 *  \return Returns BOOL value. YES indicates that the authorization verification is successful, and NO indicates that the verification fails.
 *  \else
 *  \brief 验证某项功能是否可用。
 *  \param sdkFunctionName sdk功能的名字
 *  \return 返回BOOL值。YES表示授权验证成功，NO则验证失败。
 *  \endif
*/
+ (BOOL)functionalityAuthorised:(NSString *)sdkFunctionName;
/*! \endcond */

@end
