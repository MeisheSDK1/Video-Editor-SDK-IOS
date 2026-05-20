//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2017. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jan 23. 2017
//   Author:        Meishe video team
//================================================================================
#pragma once

#import "NvsCommonDef.h"

#import <Foundation/Foundation.h>

@class NvsTimeline;
@class NvsExpressionParam;

/*! \if ENGLISH
*   \brief Asset package type
*   \else
*   \brief 资源包类型
*   \endif
*/
typedef enum
{
    NvsAssetPackageType_VideoFx = 0,                    //!< \if ENGLISH Video Fx Type \else 视频特效 \endif
    NvsAssetPackageType_VideoTransition,                //!< \if ENGLISH Video Transition Type \else 视频转场 \endif
    NvsAssetPackageType_CaptionStyle,                   //!< \if ENGLISH Caption Style Type\else 字幕样式 \endif
    NvsAssetPackageType_AnimatedSticker,                //!< \if ENGLISH Animated Sticker Type \else 动画贴纸 \endif
    NvsAssetPackageType_Theme,                          //!< \if ENGLISH Theme Type \else 主题 \endif
    NvsAssetPackageType_CaptureScene,                   //!< \if ENGLISH Capture Scene Type \else 拍摄场景 \endif
    NvsAssetPackageType_ARScene,                        //!< \if ENGLISH AR Scene Type\else AR场景 \endif
    NvsAssetPackageType_CompoundCaption,                //!< \if ENGLISH Compound caption type\else 复合字幕类型 \endif
    NvsAssetPackageType_CaptionContext,                 //!< \if ENGLISH Modular caption context type\else 模块字幕的环境包类型 \endif
    NvsAssetPackageType_CaptionRenderer,                //!< \if ENGLISH Modular caption renderer type\else 模块字幕的渲染包类型 \endif
    NvsAssetPackageType_CaptionAnimation,               //!< \if ENGLISH Modular caption animation type\else 模块字幕的循环动画类型 \endif
    NvsAssetPackageType_CaptionInAnimation,             //!< \if ENGLISH Modular caption in-animation type\else 模块字幕的入动画类型 \endif
    NvsAssetPackageType_CaptionOutAnimation,            //!< \if ENGLISH Modular caption out-animation type\else 模块字幕的出动画类型 \endif
    NvsAssetPackageType_Template,                       //!< \if ENGLISH Template type\else 模板类型 \endif
    NvsAssetPackageType_AvatarModel,                    //!< \if ENGLISH Custom avatar model type \else 捏脸模型包类型 \endif
    NvsAssetPackageType_AvatarMaterial,                 //!< \if ENGLISH Custom avatar materail type \else 捏脸素材包类型 \endif
    NvsAssetPackageType_AnimatedStickerAnimation,       //!< \if ENGLISH Sticker period animation type \else 贴纸周期动画类型 \endif
    NvsAssetPackageType_AnimatedStickerInAnimation,     //!< \if ENGLISH Sticker in animation type \else 贴纸入动画类型 \endif
    NvsAssetPackageType_AnimatedStickerOutAnimation,    //!< \if ENGLISH Sticker out animation type \else 贴纸出动画类型 \endif
    NvsAssetPackageType_Makeup,                         //!< \if ENGLISH Makeup type \else 美妆包类型 \endif
    NvsAssetPackageType_FaceMesh,                       //!< \if ENGLISH Face mesh type \else 新版美型包类型 \endif
    NvsAssetPackageType_Warp,                           //!< \if ENGLISH Warp type \else 旧版美型包类型 \endif
    NvsAssetPackageType_Project                         //!< \if ENGLISH Project \else 视频编辑项目包类型 \endif
} NvsAssetPackageType;

/*! \if ENGLISH
*   \brief Asset package status
*   \else
*   \brief 资源包状态
*   \endif
*/
typedef enum
{
    NvsAssetPackageStatus_NotInstalled = 0,  //!< \if ENGLISH Not installed \else 未安装 \endif
    NvsAssetPackageStatus_Installing,        //!< \if ENGLISH Installing \else 正在安装 \endif
    NvsAssetPackageStatus_Ready,             //!< \if ENGLISH Ready \else 准备 \endif
    NvsAssetPackageStatus_Upgrading          //!< \if ENGLISH Upgrading \else 正在升级 \endif
} NvsAssetPackageStatus;

/*! \if ENGLISH
*   \brief Resource Package Manager error type.
*
*   "NvsAssetPackageManagerError_NoError" or "NvsAssetPackageManagerError_AlreadyInstalled" indicates that the installation is successful, others it fails.
*   \else
*   \brief 资源包管理器错误类别。
*
*   NvsAssetPackageManagerError值为NvsAssetPackageManagerError_NoError或者NvsAssetPackageManagerError_AlreadyInstalled表示安装成功，其他则安装失败。
*   \endif
*/
typedef enum
{
    NvsAssetPackageManagerError_NoError = 0,          //!< \if ENGLISH Installed successfully\else 安装成功 \endif
    NvsAssetPackageManagerError_Name,                 //!< \if ENGLISH Wrong name\else 名称错误 \endif
    NvsAssetPackageManagerError_AlreadyInstalled,     //!< \if ENGLISH Already installed\else 已经安装 \endif
    NvsAssetPackageManagerError_WorkingInProgress,    //!< \if ENGLISH Installation or upgrade in progress \else 安装或升级正在进行中 \endif
    NvsAssetPackageManagerError_NotInstalled,         //!< \if ENGLISH Not installed \else 尚未安装 \endif
    NvsAssetPackageManagerError_ImproperStatus,       //!< \if ENGLISH Incorrect status \else 不正确状态 \endif
    NvsAssetPackageManagerError_Decompression,        //!< \if ENGLISH Decompression error \else 解压错误 \endif
    NvsAssetPackageManagerError_InvalidPackage,       //!< \if ENGLISH Invalid assets package \else 无效包 \endif
    NvsAssetPackageManagerError_AssetType,            //!< \if ENGLISH Resource type error \else 资源类型错误 \endif
    NvsAssetPackageManagerError_Permission,           //!< \if ENGLISH Permission error \else 许可错误 \endif
    NvsAssetPackageManagerError_MetaContent,          //!< \if ENGLISH Meta content error \else 元内容错误 \endif
    NvsAssetPackageManagerError_SdkVersion,           //!< \if ENGLISH Wrong SDK version \else Sdk版本错误 \endif
    NvsAssetPackageManagerError_UpgradeVersion,       //!< \if ENGLISH Upgrade version error \else 升级版本错误 \endif
    NvsAssetPackageManagerError_IO,                   //!< \if ENGLISH Input and output error \else 输入输出错误 \endif
    NvsAssetPackageManagerError_Resource              //!< \if ENGLISH Resource error \else 资源错误 \endif
} NvsAssetPackageManagerError;

/*! \if ENGLISH
*   \brief Asset package aspect ratio
*   \else
*   \brief 资源包支持的横纵比
*   \endif
*/
typedef enum {
    NvsAssetPackageAspectRatio_16v9 = 1,
    NvsAssetPackageAspectRatio_1v1 = 2,
    NvsAssetPackageAspectRatio_9v16 = 4,
    NvsAssetPackageAspectRatio_4v3 = 8,
    NvsAssetPackageAspectRatio_3v4 = 16,
    NvsAssetPackageAspectRatio_18v9 = 32,
    NvsAssetPackageAspectRatio_9v18 = 64
} NvsAssetPackageAspectRatio;

/*! \anchor TEIMPLATE_FOOTAGE_TYPE */
/*!
 *  \if ENGLISH
 *   @name Footage type of template asset
 *  \else
 *   @name 模板资源包的footage类型
 *  \endif
 */
typedef enum {
    NvsTemplateFootageTypeVideoImage = 0,
    NvsTemplateFootageTypeVideo = 1,
    NvsTemplateFootageTypeImage = 2,
    NvsTemplateFootageTypeAudio = 3,
    NvsTemplateFootageTypeFreezeFrame = 4
} NvsTemplateFootageType;

/*! \anchor ARSCENE_BEAUTY_PRESET */
/*!
 *  \if ENGLISH
 *   @name AR scene beauty preset
 *  \else
 *   @name AR 场景美颜预设
 *  \endif
 */
typedef struct {
    bool enabled;                       //!< \if ENGLISH Beauty is enabled \else 开启美颜 \endif
    float amplitude;                    //!< \if ENGLISH Skin smooth intensity \else 磨皮程度 \endif
    float whitening;                    //!< \if ENGLISH Whitening intensity \else 美白程度 \endif
    float reddening;                    //!< \if ENGLISH Reddening intensity \else 红润程度 \endif
    bool sharpenEnabled;                //!< \if ENGLISH sharpen is enabled \else 开启锐化 \endif
    bool defaultBeautyEnabled;          //!< \if ENGLISH Default beauty lut is enabled \else 开启默认美颜LUT \endif
    float defaultBeautyIntensity;       //!< \if ENGLISH Default beauty lut intensity \else 默认美颜LUT程度 \endif
} NvsARSceneBeautyPreset;

/*! \anchor ARSCENE_SHAPE_BEAUTIFICATION_PRESET */
/*!
 *  \if ENGLISH
 *   @name AR scene shape beautification preset
 *   \brief The value range of all float types is: [-1, 1]
 *  \else
 *   @name AR 场景美型预设
 *  \brief 所有float类型的值取值范围为：[-1, 1]
 *  \endif
 */
typedef struct {
    bool enabled;                       //!< \if ENGLISH Beauty is enabled \else 开启美型 \endif
    float eyeSizeWarp;                  //!< \if ENGLISH Eye size warp intensity \else 眼睛尺寸调节程度 \endif
    float eyeCornerStretch;             //!< \if ENGLISH Eye corner stretch intensity \else 眼角拉伸程度 \endif
    float faceWidthWarp;                //!< \if ENGLISH Face width warp intensity \else 人脸宽度调节程度 \endif
    float faceLengthWarp;               //!< \if ENGLISH Face length warp intensity \else 人脸长度调节程度 \endif
    float foreheadWarp;                 //!< \if ENGLISH Forehead warp intensity \else 前额调节程度 \endif
    float hairlineWarp;                 //!< \if ENGLISH Hairline warp intensity \else 发迹线调节程度 \endif
    float malarWarp;                    //!< \if ENGLISH Malar warp intensity \else 颧骨调节程度 \endif
    float jawWarp;                      //!< \if ENGLISH Jaw warp intensity \else 下颚调节程度 \endif
    float chinWarp;                     //!< \if ENGLISH Chin warp intensity \else 下巴调节程度 \endif
    float eyebrowWarp;                  //!< \if ENGLISH Eyebrow warp intensity \else 眉毛调节程度 \endif
    float eyeDistanceWarp;              //!< \if ENGLISH Eye distance warp intensity \else 眼间距调节程度 \endif
    float noseLengthWarp;               //!< \if ENGLISH Nose length warp intensity \else 鼻子长度调节程度 \endif
    float noseWidthWarp;                //!< \if ENGLISH Nose width warp intensity \else 鼻子宽度调节程度 \endif
    float mouthSizeWarp;                //!< \if ENGLISH Mouth size warp intensity \else 嘴尺寸调节程度 \endif
    float mouthWidthWarp;               //!< \if ENGLISH Mouth width warp intensity \else 嘴宽度调节程度 \endif
    float mouthCornerLift;              //!< \if ENGLISH Mouth corner lift intensity \else 嘴角上扬程度 \endif
    float faceSizeWarp;                 //!< \if ENGLISH Face size warp intensity \else 人脸尺寸调节程度 \endif
} NvsARSceneShapeBeautificationPreset;

/*!
 *  \if ENGLISH
 *  \brief ARScene resource package camera parameters resolved after the object.
 *
 *  \else
 *  \brief ARScene资源包中相机参数解析后的对象
 *  \endif
 */
typedef struct {
    float fovy;                         //!< @if ENGLISH @brief fovy of camera  @else @brief 相机FOV Y轴张角。 @endif
} NvsARSceneCameraPreset;

/*!
 *	\if ENGLISH
 *  \brief The clip information corresponding to footage of template asset
 *	\else
 *  \brief 模板资源包里footage对应的片段信息
 *	\endif
 */
NVS_EXPORT @interface NvsTemplateFootageCorrespondingClipInfo : NSObject

@property (nonatomic, assign) int trackIndex;//!< \if ENGLISH Footage corresponds to the track index of the clip\else footage对应的该clip所在的轨道index \endif
@property (nonatomic, assign) int clipIndex;//!< \if ENGLISH Footage corresponds to the index of the clip on the track\else footage对应的该clip在轨道上的index \endif
@property (nonatomic, assign) int64_t inPoint;//!< \if ENGLISH Footage corresponds to the inPoint of the clip on the timeline\else footage对应的该clip在时间线上的入点 \endif
@property (nonatomic, assign) int64_t outPoint;//!< \if ENGLISH Footage corresponds to the outPoint of the clip on the timeline\else footage对应的该clip在时间线上的出点 \endif
@property (nonatomic, assign) int64_t trimIn; //!< \if ENGLISH Footage corresponds to the trimin of the clip \else footage对应的该clip的裁剪入点 \endif
@property (nonatomic, assign) int64_t trimOut;//!< \if ENGLISH Footage corresponds to the trimout of the clip\else footage对应的该clip的裁剪出点 \endif
@property (nonatomic, assign) BOOL needReverse;//!< \if ENGLISH This footage needs to be reversed\else footage是否需要倒放 \endif
@property (nonatomic, assign) BOOL canReplace;//!< \if ENGLISH Footage is replaceable\else footage是否可替换 \endif

@end

/*!
 *	\if ENGLISH
 *  \brief The footage information of template asset
 *	\else
 *  \brief 模板资源包里footage信息
 *	\endif
 */
NVS_EXPORT @interface NvsTemplateFootageDesc : NSObject

@property (nonatomic, strong) NSString *footageId;//!< \if ENGLISH The ID of footage, one footage can correspond to more than one clip \else footage的id，一个footage可以对应多个clip \endif
@property (nonatomic, assign) NvsTemplateFootageType type;//!< \if ENGLISH The type of footage can be video, audio, image\else footage的类型，可以是视频，音频，图片 \endif
@property (nonatomic, assign) BOOL canReplace;//!< \if ENGLISH Footage is replaceable\else footage是否可替换 \endif
@property (nonatomic, strong) NSString *innerAssetFilePath;//!< \if ENGLISH Builtin resource file paths\else 内置资源文件路径 \endif
@property (nonatomic, strong) NSArray <NSString *>*tags;//!< \if ENGLISH Footage of some tag information, such as scenery, cats\else footage的一些标签信息，比如风景、猫 \endif
@property (nonatomic, strong) NSArray <NvsTemplateFootageCorrespondingClipInfo *>*correspondingClipInfos;//!< \if ENGLISH Footage corresponds to clip information\else footage对应的clip的信息 \endif
@property (nonatomic, strong) NSArray<NvsTemplateFootageDesc *>*timelineClipFootages;   //!< \if ENGLISH Footage information in sub timeline\else 序列嵌套的footage信息 \endif

@end
/*!
    *	\if ENGLISH
    *  \brief The caption information corresponding to footage of template asset
    *	\else
    *  \brief 模板资源包里footage对应的字幕信息。如果trackIndex和clipIndex都是-1，表示该字幕是timeline字幕。如果仅clipIndex为-1，表示该字幕是轨道字幕。如果两者都不为-1，表示该字幕是片段字幕
    *	\endif
    */
NVS_EXPORT @interface NvsTemplateCaptionDesc : NSObject

@property (nonatomic, strong) NSString *replaceId;//!< \if ENGLISH The id of caption，The ID value is equal to[getTemplateAttachment()] (@ref com.meicam.sdk.NvsObject.getTemplateAttachment),The KEY used is [TEMPLATE_KEY_REPLACE_ID] (@ref com.meicam.sdk.NvsObject.TEMPLATE_KEY_REPLACE_ID)\else 字幕的id。ID值等同于[getTemplateAttachment()] (@ref com.meicam.sdk.NvsObject.getTemplateAttachment)，用到的KEY为[TEMPLATE_KEY_REPLACE_ID] (@ref com.meicam.sdk.NvsObject.TEMPLATE_KEY_REPLACE_ID) \endif
@property (nonatomic, strong) NSString *text;//!< \if ENGLISH The text of caption\else 字幕的文字内容 \endif
@property (nonatomic, assign) int trackIndex;      //!< \if ENGLISH The track index of caption\else 轨道字幕的轨道索引，非负表示有效 \endif
@property (nonatomic, assign) int clipIndex;       //!< \if ENGLISH The clip index of caption\else 片段字幕的片段索引，非负表示有效 \endif
@property (nonatomic, strong) NSArray<NvsTemplateCaptionDesc*>* subCaptions;   //!< \if ENGLISH Captions in sub timeline \else 序列嵌套的字幕 \endif

@end
/*!
     *	\if ENGLISH
     *  \brief The compound caption information corresponding to footage of template asset
     *	\else
     *  \brief 模板资源包里footage对应的组合字幕信息
     *	\endif
     */
NVS_EXPORT @interface NvsTemplateCompoundCaptionItemDesc : NSObject

@property (nonatomic, assign) int index;        //!< \if ENGLISH The index of text in CompoundCaption\else 组合字幕中文字的index \endif
@property (nonatomic, strong) NSString *text;   //!< \if ENGLISH The text of CompoundCaption\else 组合字幕中对应index的文字内容 \endif

@end

/*!
     *	\if ENGLISH
     *  \brief The All compound caption informations corresponding to footage of template asset
     *	\else
     *  \brief 模板资源包里footage对应的组合字幕信息。如果trackIndex和clipIndex都是-1，表示该字幕是timeline字幕。如果仅clipIndex为-1，表示该字幕是轨道字幕。如果两者都不为-1，表示该字幕是片段字幕
     *	\endif
     */
NVS_EXPORT @interface NvsTemplateCompoundCaptionDesc : NSObject

@property (nonatomic, strong) NSString *replaceId;  //!< \if ENGLISH The id of caption，The ID value is equal to[getTemplateAttachment()] (@ref com.meicam.sdk.NvsObject.getTemplateAttachment),The KEY used is [TEMPLATE_KEY_REPLACE_ID] (@ref com.meicam.sdk.NvsObject.TEMPLATE_KEY_REPLACE_ID)\else 字幕的id。ID值等同于[getTemplateAttachment()] (@ref com.meicam.sdk.NvsObject.getTemplateAttachment)，用到的KEY为[TEMPLATE_KEY_REPLACE_ID] (@ref com.meicam.sdk.NvsObject.TEMPLATE_KEY_REPLACE_ID) \endif
@property (nonatomic, strong) NSArray <NvsTemplateCompoundCaptionItemDesc *>*itemList;       //!< \if ENGLISH An array of all Compound Caption\else 所有包含的组合字幕的数组 \endif
@property (nonatomic, assign)  int trackIndex;      //!< \if ENGLISH The track index of caption\else 轨道字幕的轨道索引，非负表示有效 \endif
@property (nonatomic, assign)  int clipIndex;       //!< \if ENGLISH The clip index of caption\else 片段字幕的片段索引，非负表示有效 \endif
@property (nonatomic, strong) NSArray<NvsTemplateCompoundCaptionDesc*> *subCaptions;   //!< \if ENGLISH Compound captions in sub timeline \else 序列嵌套的复合字幕 \endif

@end



@protocol NvsAssetPackageManagerGenerateTemplateDelegate <NSObject>
@optional

/*!
 *  \if ENGLISH
 *  \brief Notifies the completion of template pack generate process
 *  \param assetPackageFilePath File path of resource package
 *  \param error Returns error value of generate. "NvsAssetPackageManagerError_NoError" indicates a successful generation, while the other values suggest a failure. Please refer to [Resource Package Management Error Type](@ref ASSET_PACKAGE_MANAGER_ERROR)
 *  \else
 *  \brief 通知模板资源包的生成过程结束
 *  \param assetPackageFilePath 资源包的文件路径
 *  \param error 生成过程的错误返回值，为NvsAssetPackageManagerError_NoError表示生成成功，否则表示生成失败。请参见[资源包管理错误类型](@ref NvsAssetPackageManagerError)
 *  \endif
 */
- (void)onGenerateTemplatePackageFinished:(NSString *)assetPackageFilePath error:(NvsAssetPackageManagerError)error;

@end

@protocol NvsAssetPackageManagerDelegate <NSObject>
@optional

/*! \if ENGLISH
 *  \brief Notifies the accomplishment of asset package installation
 *  \param assetPackageId Asset package ID
 *  \param assetPackageFilePath Asset package file path
 *  \param assetPackageType Asset package type
 *  \param error Returns error value of installation. "NvsAssetPackageManagerError_NoError" indicates that the installation succeeds, otherwise it fails.
 *  \brief Common causes of errors: 1. Package file path error.2. Package type error.
 *  \else
 *  \brief 通知资源包的安装过程结束
 *  \param assetPackageId 安装资源包ID
 *  \param assetPackageFilePath 安装资源包的文件路径
 *  \param assetPackageType 安装资源包的类型
 *  \param error 返回安装过程的错误值。值为NvsAssetPackageManagerError_NoError表示安装成功，否则表示安装失败
 *  \brief 常见的错误原因：1、资源包路径错误。2、资源包类型错误。
 *  \endif
 *  \sa didFinishAssetPackageUpgrading:filePath:type:error:
 */
- (void)didFinishAssetPackageInstallation:(NSString *)assetPackageId filePath:(NSString *)assetPackageFilePath type:(NvsAssetPackageType)assetPackageType error:(NvsAssetPackageManagerError)error;

/*! \if ENGLISH
 *  \brief Notifies the completion of asset package upgrade.
 *  \param assetPackageId Asset package ID.
 *  \param assetPackageFilePath Asset package file path
 *  \param assetPackageType Asset package type
 *  \param error Returns error value of upgrading. "NvsAssetPackageManagerError_NoError" indicates that the installation succeeds, otherwise it fails.
 *  \else
 *  \brief 通知资源包的升级过程结束
 *  \param assetPackageId 升级资源包ID
 *  \param assetPackageFilePath 升级资源包的文件路径
 *  \param assetPackageType 升级资源包的类型
 *  \param error 返回升级过程的错误值。值为NvsAssetPackageManagerError_NoError表示安装成功，否则表示安装失败。
 *  \endif
 *  \sa didFinishAssetPackageInstallation:filePath:type:error:
*/
- (void)didFinishAssetPackageUpgrading:(NSString *)assetPackageId filePath:(NSString *)assetPackageFilePath type:(NvsAssetPackageType)assetPackageType error:(NvsAssetPackageManagerError)error;

@end

/*! \if ENGLISH
 *  \brief Asset package manager for managing assets in video.
 *
 *   In the development of the SDK, the asset package manager unifies the various special asset packages including subtitles, themes, animation stickers, etc. for installation, upgrading, and uninstallation. When it is installing, upgrading, and uninstalling, there will be a corresponding error type for errors to be quickly located and resolved.
 *  \warning NvsAssetPackageManager类中，所有public API都在UI线程使用！！！
 *  \else
 *  \brief 资源包管理器，管理视频场景中的资源包
 *
 *   在SDK开发过中，资源包管理器统一对需要的各种特技资源包包括字幕，主题，动画贴纸等进行相应的安装，升级，卸载等操作。在安装，升级，卸载时，出现差错都会有相应的错误提示类型，以便快速定位和解决错误。
 *  \warning NvsAssetPackageManager类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsAssetPackageManager : NSObject

@property (nonatomic, weak) id<NvsAssetPackageManagerDelegate> delegate;
@property (nonatomic, weak) id<NvsAssetPackageManagerGenerateTemplateDelegate> generateTemplateDelegate;


/*! \if ENGLISH
 *  \brief Gets asset package ID from asset package path.
 *  \param assetPackageFilePath Asset package file path
 *  \return Returns a string representing the assets package ID.
 *  \warning By the character in the path, so do not change the file name!
 *  \else
 *  \brief 从资源包的文件路径获得资源包ID
 *  \param assetPackageFilePath 资源包的文件路径
 *  \return 返回表示资源包ID的字符串
 *  \warning 通过路径中字符判断，所以不建议修改已有的文件名！
 *  \endif
*/
- (NSString *)getAssetPackageIdFromAssetPackageFilePath:(NSString *)assetPackageFilePath;

/*! \if ENGLISH
 *  \brief Gets the package version number from package file path.
 *  \param assetPackageFilePath Asset package file path
 *  \return Returns the version of package. If the asset package does not have a version number, return 1.
 *  \warning By the character in the path, so do not change the file name!
 *  \else
 *  \brief 从资源包的文件路径获得资源包版本号
 *  \param assetPackageFilePath 资源包的文件路径
 *  \return 返回表示资源包版本号。如果该资源包不包含版本号则返回1.
 *  \warning 通过路径中字符判断，所以不建议修改已有的文件名！
 *  \endif
*/
- (int)getAssetPackageVersionFromAssetPackageFilePath:(NSString *)assetPackageFilePath;

/*! \if ENGLISH
 *  \brief Installs asset package
 *  \param assetPackageFilePath Asset package file path
 *  \param licenseFilePath License file path
 *  \param type Asset package type
 *  \param synchronous Whether to install synchronously: A value of YES will cause the installation process to block the current thread until the installation succeeds or fails. NO means results in the installation process being asynchronously notified by the delegate (but also notified by the current thread).
 *  \param Notice: if type is template, this param will be ignored and will install asynchronously
 *  \param assetPackageId output value. Output asset package ID
 *  \return Returns error value of installation. "NvsAssetPackageManagerError_NoError" or "NvsAssetPackageManagerError_AlreadyInstalled" indicates that the installation succeeds (It can only be returned in synchronous installation), otherwise it fails.
 *  \else
 *  \brief 安装资源包
 *  \param assetPackageFilePath 待安装资源包的文件路径
 *  \param licenseFilePath 待安装资源包的授权文件路径
 *  \param type 待安装资源包的类型
 *  \param synchronous 是否同步安装。值为YES则安装过程会阻塞当前线程直到安装成功或者失败，NO则安装过程的结果通过delegate异步通知（但也在当前线程通知）。
 *  \param 注意：如果type是模板类型，那么只能使用异步安装。
 *  \param assetPackageId 返回值，返回该资源包ID。
 *  \return 返回错误类型值。NvsAssetPackageManagerError_NoError: 表示安装成功（只有同步安装才可能返回这个)，任何其它返回值都表示安装错误。
 *  \endif
 *  \sa upgradeAssetPackage:license:type:sync:assetPackageId:
 *  \sa uninstallAssetPackage:type:
*/
// 安装asset package
// @assetPackageFilePath: 待安装asset package的文件路径
// @licenseFilePath: 待安装asset package的授权文件
// @type: 待安装asset package的类型
// @synchronous: 是否同步安装
//               YES: 安装过程会阻塞当前线程直到安装成功或者失败
//               NO: 安装过程的结果通过delegate异步通知（但也在当前线程通知）
// @assetPackageId: 返回该asset package的标识符
//
// 返回值为一个错误号
// NvsAssetPackageManagerError_NoError: 表示安装成功（只有同步安装才可能返回这个值）
// NvsAssetPackageManagerError_AlreadyInstalled: 表示当前asset package已经安装
// NvsAssetPackageManagerError_WorkingInProgress: 表示安装正在进行中（只有异步安装才可能返回这个值）
// 任何其它返回值都表示安装错误
//
- (NvsAssetPackageManagerError)installAssetPackage:(NSString *)assetPackageFilePath license:(NSString *)licenseFilePath type:(NvsAssetPackageType)type sync:(BOOL)synchronous assetPackageId:(NSMutableString *)assetPackageId;

/*! \if ENGLISH
 *  \brief Upgrades asset package
 *  \param assetPackageFilePath File path of the asset package to be upgraded
 *  \param licenseFilePath License file path of the asset package to be upgraded
 *  \param type Type of the asset package to be upgraded
 *  \param synchronous Whether to upgrade synchronously. Value of YES will cause the upgrade process to block the current thread until the upgrade succeeds or fails. NO results in the upgrade process being asynchronously notified by the delegate (it can also be notified by the current thread).
 *  \param Notice: if type is template, this param will be ignored and will install asynchronously
 *  \param assetPackageId Output value, output the assets package ID
 *  \return Returns error value of upgrading. "NvsAssetPackageManagerError_NoError" indicates that the upgrade succeeds (It can only be returned in synchronous installation), otherwise it fails.
 *  \else
 *  \brief 升级资源包
 *  \param assetPackageFilePath 待升级资源包的文件路径
 *  \param licenseFilePath 待升级资源包的授权文件路径
 *  \param type 待升级资源包的类型
 *  \param synchronous 是否同步升级。值为YES则升级过程会阻塞当前线程直到升级成功或者失败，NO则升级过程的结果通过delegate异步通知（但也在当前线程通知）。
 *  \param 注意：如果type是模板类型，那么只能使用异步安装。
 *  \param assetPackageId 返回值，返回该资源包ID
 *  \return 返回错误类型。值为NvsAssetPackageManagerError_NoError表示升级成功（只有同步升级才可能返回这个)，任何其它返回值都表示升级错误。
 *  \endif
 *  \sa installAssetPackage:license:type:sync:assetPackageId:
 *  \sa uninstallAssetPackage:type:
*/
// 升级asset package
// @assetPackageFilePath: 待升级asset package的文件路径
// @licenseFilePath: 待升级asset package的授权文件
// @type: 待升级asset package的类型
// @synchronous: 是否同步升级
//               YES: 升级过程会阻塞当前线程直到升级成功或者失败
//               NO: 升级过程的结果通过delegate异步通知（但也在当前线程通知）
// @assetPackageId: 返回该asset package的标识符
//
// 返回值为一个错误号
// NvsAssetPackageManagerError_NoError: 表示升级成功（只有同步升级才可能返回这个值）
// NvsAssetPackageManagerError_NotInstalled: 表示当前asset package尚未安装
// NvsAssetPackageManagerError_WorkingInProgress: 表示升级正在进行中（只有异步升级才可能返回这个值）
// 任何其它返回值都表示升级错误
//
- (NvsAssetPackageManagerError)upgradeAssetPackage:(NSString *)assetPackageFilePath license:(NSString *)licenseFilePath type:(NvsAssetPackageType)type sync:(BOOL)synchronous assetPackageId:(NSMutableString *)assetPackageId;

/*! \if ENGLISH
 *  \brief Uninstalls asset package
 *  \param assetPackageId ID of the asset package to be uninstalled
 *  \param type Type of the asset package to be uninstalled
 *  \return Returns error value of uninstallation. "NvsAssetPackageManagerError_NoError" indicates that the uninstallation is successful, otherwise it fails.
 *  \else
 *  \brief 卸载资源包
 *  \param assetPackageId 待卸载资源包ID
 *  \param type 待卸载资源包的类型
 *  \return 返回错误类型。返回NvsAssetPackageManagerError_NoError表示卸载成功，其它则卸载失败
 *  \endif
 *  \sa installAssetPackage:license:type:sync:assetPackageId:
 *  \sa upgradeAssetPackage:license:type:sync:assetPackageId:
*/
- (NvsAssetPackageManagerError)uninstallAssetPackage:(NSString *)assetPackageId type:(NvsAssetPackageType)type;

/*! \if ENGLISH
 *  \brief Get the state of asset package.
 *  \param assetPackageId ID of the asset package to be checked
 *  \param type Asset package type
 *  \return Returns the current state value of asset package.
 *  \else
 *  \brief 获取资源包的当前状态。
 *  \param assetPackageId 待查询状态资源包ID
 *  \param type 待查询状态资源包的类型
 *  \return 返回资源包的当前状态值.
 *  \endif
*/
- (NvsAssetPackageStatus)getAssetPackageStatus:(NSString *)assetPackageId type:(NvsAssetPackageType)type;

/*! \if ENGLISH
 *  \brief Gets the version number of the installed asset package.
 *  \param assetPackageId ID of the asset package to be checked
 *  \param type Type of the asset package to be checked
 *  \return Returns the version number of the asset package. Returns 1 if asset package is not installed.
 *  \brief Need install this package before use this method.Please check this package status by [getAssetPackageStatus()] (@ref getAssetPackageStatus)
 *  \else
 *  \brief 获取已安装资源包的版本号
 *  \param assetPackageId 待查询状态资源包ID
 *  \param type 待查询状态资源包的类型
 *  \return 返回资源包的版本号。如果该资源包未安装，则返回1。
 *  \brief 只有安装过的资源包，才可以通过该方法获取。请在使用前注意检查是否安装。请参见[getAssetPackageStatus()] (@ref getAssetPackageStatus)
 *  \endif
*/
- (int)getAssetPackageVersion:(NSString *)assetPackageId type:(NvsAssetPackageType)type;

/*! \if ENGLISH
 *  \brief Gets the lowest SDK version required by the installed asset package.
 *  \param assetPackageId ID of the asset package to be checked
 *  \param type Type of the asset package to be checked
 *  \return Returns the version number of the SDK. Returns nil if asset package is not installed.
 *  \brief Need install this package before use this method.Please check this package status by [getAssetPackageStatus()] (@ref getAssetPackageStatus)
 *  \else
 *  \brief 获取已安装资源包需要的SDK最低版本号
 *  \param assetPackageId 待查询状态资源包ID
 *  \param type 待查询状态资源包的类型
 *  \return 返回SDK版本号。如果该资源包未安装，则返回nil。
 *  \brief 只有安装过的资源包，才可以通过该方法获取。请在使用前注意检查是否安装。请参见[getAssetPackageStatus()] (@ref getAssetPackageStatus)
 *  \endif
*/
- (NSString*)getAssetPackageMinSdkVersion:(NSString *)assetPackageId type:(NvsAssetPackageType)type;

/*! @if ENGLISH
 *  @brief Gets the contentType required by the installed asset package.
 *  @param assetPackageId ID of the asset package to be checked
 *  @param type Type of the asset package to be checked
 *  @return Returns the contentType of the asset package.Returns nil if asset package is not installed.
 *  \brief Need install this package before use this method.Please check this package status by [getAssetPackageStatus()] (@ref getAssetPackageStatus)
 *  @else
 *  @brief 获取资源包的内容类型。
 *  @param assetPackageId 资源包的ID。
 *  @param type 资源类型。
 *  @return 返回内容类型。如果该资源包未安装，则返回nil。
 *  \brief 只有安装过的资源包，才可以通过该方法获取。请在使用前注意检查是否安装。请参见[getAssetPackageStatus()] (@ref getAssetPackageStatus)
 *  @endif
*/
- (NSString*)getAssetPackageContentType:(NSString *)assetPackageId type:(NvsAssetPackageType)type;

/*! @if ENGLISH
 *  @brief Gets the expValue list required by the installed asset package.
 *  @param assetPackageId ID of the asset package to be checked
 *  @param type Type of the asset package to be checked
 *  @return Returns the expValue list of the asset package.Returns nil if asset package is not installed.
 *  \brief Need install this package before use this method.Please check this package status by [getAssetPackageStatus()] (@ref getAssetPackageStatus)
 *  @else
 *  @brief 获取资源包的表达式参数的列表。
 *  @param assetPackageId 资源包的ID。
 *  @param type 资源类型。
 *  @return 返回资源包的表达式参数的列表。如果该资源包未安装，则返回nil。
 *  \brief 只有安装过的资源包，才可以通过该方法获取。请在使用前注意检查是否安装。请参见[getAssetPackageStatus()] (@ref getAssetPackageStatus)
 *  @endif
*/
- (NSArray <NvsExpressionParam *>*)getExpValueList:(NSString *)assetPackageId type:(NvsAssetPackageType)type;

/*! @if ENGLISH
 *  @brief Translate the text required by the installed asset package.
 *  @param assetPackageId ID of the asset package to be checked
 *  @param type Type of the asset package to be checked
 *  @return Returns the translation of the asset package.Returns nil if asset package is not installed.
 *  \brief Need install this package before use this method.Please check this package status by [getAssetPackageStatus()] (@ref getAssetPackageStatus)
 *  @else
 *  @brief 翻译资源包中的字段。
 *  @param assetPackageId 资源包的ID。
 *  @param type 资源类型。
 *  @return 返回翻译后的字符串。。如果该资源包未安装，则返回nil。
 *  \brief 只有安装过的资源包，才可以通过该方法翻译。请在使用前注意检查是否安装。请参见[getAssetPackageStatus()] (@ref getAssetPackageStatus)
 *  @endif
*/
- (NSDictionary<NSString*, NSString*>*)getTranslationMap:(NSString *)assetPackageId type:(NvsAssetPackageType)type;

/*! \if ENGLISH
 *  \brief Gets the supported aspect ratio of the asset package.
 *  \param assetPackageId ID of the asset package to be checked.
 *  \param type Type of the asset package to be checked.
 *  \return Returns the supported aspect ratio of the asset package, which is the result of a bitwise OR operation of several aspect ratios (NvsAssetPackageAspectRatio_XXX).
 *  \else
 *  \brief 获取资源包的所支持的横纵比
 *  \param assetPackageId 待查询状态资源包ID
 *  \param type 待查询状态资源包的类型
 *  \return 返回资源包的所支持的横纵比，这个值是若干横纵比(NvsAssetPackageAspectRatio_XXX)的按位或的结果。
 *  \endif
*/
- (int)getAssetPackageSupportedAspectRatio:(NSString *)assetPackageId type:(NvsAssetPackageType)type;

/*! \if ENGLISH
 *  \brief Gets a list of asset packages of certain type.
 *  \param type Asset package type
 *  \return Return an NSArray array object. It represents a list of asset packages of a certain type. Each NSString element in the list is an asset package ID.
 *  \else
 *  \brief 获取某个类型的资源包列表
 *  \param type 资源包类型
 *  \return 返回NSArray数组对象，表示某个类型下资源包的的列表。列表里每个NSString元素都是一个资源包ID。
 *  \endif
*/
// 获取某个类型的asset package的列表
// @type: asset package的类型
// 返回值为一个NSString类型的NSArray，每一个NSString都是一个资源包的标识符
- (NSArray *)getAssetPackageListOfType:(NvsAssetPackageType)type;

/*! \if ENGLISH
 *  \brief Defines if it is a customized sticker
 *  \param uuidString Sticker uuid
 *  \return Returns BOOL value,which indicates whether it is customized sticker.
 *  \else
 *  \brief 判断是否为自定义贴纸
 *  \param uuidString 贴纸uuid
 *  \return 返回BOOL值，表示是否为自定义贴纸
 *  \endif
 *  \since 1.11.0
*/
- (BOOL)isCustomAnimatedSticker:(NSString *)uuidString;

/*! \if ENGLISH
 *  \brief Defines if it is particle Fx
 *  \param uuidString Fx Asset uuid
 *  \return Returns BOOL value,which indicates whether it is particle Fx
 *  \else
 *  \brief 判断是否为粒子特效
 *  \param uuidString 特效资源uuid
 *  \return 返回BOOL值，表示是否为粒子特效。
 *  \endif
 *  \since 1.14.0
*/
- (BOOL)isParticleFx:(NSString *)uuidString;

/*!
 *	\if ENGLISH
 *  \brief Check whether a theme package contain music
 *  \param uuidString theme package uuid
 *  \return Returns BOOL value indicating whether it contain music
 *	\else
 *  \brief 检查主题包是否含有音乐
 *  \param uuidString 主题包uuid
 *  \return 返回BOOL值，表示否含有音乐
 *	\endif
 *  \since 2.6.0
 */
- (BOOL)isThemeContainMusic:(NSString *)uuidString;

/*! \if ENGLISH
 *  \brief Gets the Fx description of an asset of type VideoFx
 *  \param uuidString Fx asset uuid
 *  \return Returns a String object,the Fx description of the Fx asset
 *  \else
 *  \brief 获取某个类型为VideoFx的资源的特效描述信息
 *  \param uuidString 特效资源uuid
 *  \return 返回String对象，特效资源的特效描述信息
 *  \endif
 *  \since 1.14.0
*/
- (NSString *)GetVideoFxAssetPackageDescription:(NSString *)uuidString;

/*!
 *	\if ENGLISH
 *  \brief Gets the footage description list of the Template asset.
 *  \param uuidString special effect uuid
 *  \return Returns a ArrayList object, which is a footage description list.
 *  \since 1.18.0
 *	\else
 *  \brief 获取Template资源里的footage信息列表
 *  \param uuidString 特效uuid
 *  \return 返回ArrayList，footage信息列表
 *  \since 2.18.1
 *	\endif
 */
- (NSArray <NvsTemplateFootageDesc *>*)getTemplateFootages:(NSString *)uuidString;

/*!
 *	\if ENGLISH
 *  \brief Gets the caption description list of the Template asset.
 *  \param uuidString special effect uuid
 *  \return Returns a ArrayList object, which is a caption description list.
 *  \since 2.18.1
 *	\else
 *  \brief 获取Template资源里的字幕信息列表
 *  \param uuidString 特效uuid
 *  \return 返回ArrayList，字幕信息列表
 *  \since 2.18.1
 *	\endif
 */
- (NSArray <NvsTemplateCaptionDesc *>*)getTemplateCaptions:(NSString *)uuidString;

/*!
 *	\if ENGLISH
 *  \brief Gets the aspect ratio which is template using
 *  \param uuidString special effect uuid
 *  \return Returns aspect ratio which is template using
 *  \since 2.18.1
 *	\else
 *  \brief 获取Template当前使用的画幅比例
 *  \param uuidString 特效uuid
 *  \return 返回画幅比例(@ref NvsAssetPackageAspectRatio)
 *  \since 2.18.1
 *	\endif
 */
- (int)getTemplateCurrentAspectRatio:(NSString *)uuidString;

/*!
 *	\if ENGLISH
 *  \brief Gets the compound caption description list of the Template asset.
 *  \param uuidString special effect uuid
 *  \return Returns a ArrayList object, which is a compound caption description list.
 *  \since 2.18.1
 *	\else
 *  \brief 获取Template资源里的复合字幕信息列表
 *  \param uuidString 特效uuid
 *  \return 返回ArrayList，复合字幕信息列表
 *  \since 2.18.1
 *	\endif
 */
- (NSArray <NvsTemplateCompoundCaptionDesc *>*)getTemplateCampoundCaptions:(NSString *)uuidString;

/*!
 *	\if ENGLISH
 *  \brief Change aspect ratio of template
 *  \param uuidString special effect uuid
 *  \return Returns suc or not
 *  \since 2.18.1
 *	\else
 *  \brief 更改模板的画幅比例
 *  \param uuidString 特效uuid
 *  \return 返回是否成功
 *  \since 2.18.1
 *	\endif
 */
- (BOOL)changeTemplateAspectRatio:(NSString *)uuidString aspectRatio:(int)aspectRatio;

/*!
 *	\if ENGLISH
 *  \brief Get the prompt message of the ARScene asset package
 *  \param uuidString asset package uuid
 *  \return Returns a String object which represent the prompt message.
 *	\else
 *  \brief 获取ARScene资源包的提示信息
 *  \param uuidString 资源包uuid
 *  \return 返回提示信息的String对象
 *	\endif
 *  \since 2.9.0
 */
- (NSString *)getARSceneAssetPackagePrompt:(NSString *)uuidString;

/*!
 *	\if ENGLISH
 *  \brief Is arScene assetPackage conflit with makeup
 *  \param uuidString asset package uuid
 *  \return Returns is conflit
 *	\else
 *  \brief 是否含有美妆
 *  \param uuidString 资源包uuid
 *  \return 返回是否含有美妆
 *	\endif
 *  \since 3.1.1
 */
-(BOOL)isARSceneAssetPackageContainMakeup:(NSString *)uuidString;

/*!
 *  \if ENGLISH
 *  \brief Is arScene assetPackage conflit with face mesh
 *  \param uuidString asset package uuid
 *  \return Returns is conflit
 *  \else
 *  \brief 是否包含新版美型
 *  \param uuidString 资源包uuid
 *  \return 返回是否包含新版美型
 *  \endif
 *  \since 3.4.0
 */
-(BOOL)isARSceneAssetPackageContainFaceMesh:(NSString *)uuidString;

/*!
 *  \if ENGLISH
 *  \brief Is arScene assetPackage conflit with warp
 *  \param uuidString asset package uuid
 *  \return Returns is conflit
 *  \else
 *  \brief 是否包含旧版美型
 *  \param uuidString 资源包uuid
 *  \return 返回包含旧版美型
 *  \endif
 *  \since 3.4.0
 */
-(BOOL)isARSceneAssetPackageContainWarp:(NSString *)uuidString;

/*!
 *	\if ENGLISH
 *  \brief Get Beauty effect preset in a ARScene asset package
 *  \param uuidString asset package uuid
 *  \param beautyPreset a pointer of NvsARSceneBeautyPreset, preset data will be returned in this structure
 *  \return Returns YES on success, NO on failure or if there is no preset,
 *          data in preset will be undefined if this method returns NO!
 *	\else
 *  \brief 获取ARScene资源包美颜的预设参数
 *  \param uuidString 资源包uuid
 *  \param beautyPreset 一个NvsARSceneBeautyPreset结构的指针，预设数据将会被返回在这个结构里。
 *  \return 成功时返回YES，失败或者没有预设返回NO。当返回NO时，preset里面的数据时未定义的！
 *	\endif
 *  \since 2.9.0
 */
- (BOOL)getARSceneAssetPackage:(NSString *)uuidString
                  beautyPreset:(NvsARSceneBeautyPreset *)beautyPreset;

/*!
 *	\if ENGLISH
 *  \brief Get shape beautification effect preset in a ARScene asset package
 *  \param uuidString asset package uuid
 *  \param shapeBeautificationPreset a pointer of NvsARSceneShapeBeautificationPreset, preset data will be returned in this structure
 *  \return Returns YES on success, NO on failure or if there is no preset,
 *          data in preset will be undefined if this method returns NO!
 *	\else
 *  \brief 获取ARScene资源包美型的预设参数
 *  \param uuidString 资源包uuid
 *  \param shapeBeautificationPreset 一个NvsARSceneShapeBeautificationPreset结构的指针，预设数据将会被返回在这个结构里。
 *  \return 成功时返回YES，失败或者没有预设返回NO。当返回NO时，preset里面的数据时未定义的！
 *	\endif
 *  \since 2.9.0
 */
- (BOOL)getARSceneAssetPackage:(NSString *)uuidString
     shapeBeautificationPreset:(NvsARSceneShapeBeautificationPreset *)shapeBeautificationPreset;



/*!
 * \if ENGLISH
 *  \brief Get camera preset in a ARScene asset package
 *  \param uuidString asset package uuid
 *  \param cameraPreset a pointer of NvsARSceneCameraPreset preset data will be returned in this structure
 *  \return Returns a NvsARSceneCameraPreset object which contain preset,
 *          returns null if preset is not available
 *  \else
 *  \brief 获取ARScene资源包相机的预设参数
 *  \param uuidString 资源包uuid
 *  \param cameraPreset 一个NvsARSceneCameraPreset结构的指针，预设数据将会被返回在这个结构里。
 *  \return 返回含有预设参数的ARSceneCameraPreset对象，如果没有预设则返回null
 * \endif
 *  \since 3.7.2
 */
- (BOOL)getARSceneAssetPackage:(NSString *)uuidString
     cameraPreset:(NvsARSceneCameraPreset *)cameraPreset;

/*! \if ENGLISH
 *  \brief Defines if there is audio in asset package
 *  \param uuidString Sticker uuid
 *  \param assetPackageType Asset package type
 *  \return Returns BOOL value,which indicates whether there is audio.
 *  \else
 *  \brief 判断是否含有音频在包裹内
 *  \param uuidString 贴纸uuid
 *  \param assetPackageType Asset package type
 *  \return 返回BOOL值，表示是否含有音频
 *  \endif
 *  \since 3.8.0
*/
- (BOOL)hasAudioInAssetPackage:(NSString *)uuidString type:(NvsAssetPackageType)assetPackageType;

/*! \if ENGLISH
 *  \brief Whether the ARScene package has detection requirements
 *  \param uuidString ARScene package uuid
 *  \param assetPackageType Asset package type
 *  \return Returns BOOL value, Whether it contains detection requirements
 *  \else
 *  \brief ARScene资源包是否有检测需求
 *  \param uuidString ARScene资源包uuid
 *  \param assetPackageType Asset package type
 *  \return 返回BOOL值，是否含有检测需求
 *  \endif
 *  \since 3.10.0
*/
- (BOOL)hasDetectionInAssetPackage:(NSString *)uuidString type:(NvsAssetPackageType)assetPackageType;


/*! \if ENGLISH
 *  \brief Get detection type string in asset package
 *  \param uuidString  asset package ID
 *  \param assetPackageType asset package type
 *  \return Detection type string seprated by |.
 *  \else
 *  \brief 获取资源包中检测类型
 *  \param uuidString 资源包id。
 *  \param assetPackageType 资源包类型
 *  \return 资源包中的检测类型字符串，以|分开。
 *  \endif
 *  \since 3.14.3
*/

- (NSString *)getDetectionTypeStringInAssetPackage:(NSString *)uuidString type:(NvsAssetPackageType)assetPackageType;

/*! \cond */
- (NSString *)decodeFile:(NSString *)fileFile
                 licPath:(NSString *)licPath
                  isJson:(BOOL)isJson;
/*! \endcond */

/*! \cond */
- (void)createZipFileAtPath:(NSString *)path withContentsOfDirectory:(NSString *)directoryPath;
/*! \endcond */
@end

