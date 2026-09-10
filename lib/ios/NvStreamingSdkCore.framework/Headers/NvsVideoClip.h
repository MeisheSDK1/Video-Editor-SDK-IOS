//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Dec 29. 2016
//   Author:        Meishe video team
//================================================================================
/*! \file NvsVideoClip.h
 */
#pragma once

#import "NvsCommonDef.h"
#import "NvsClip.h"
#import "NvsCustomAudioFx.h"
#import "NvsCustomVideoFx.h"
#import "NvsClipCaption.h"
#import "NvsClipCompoundCaption.h"
#import "NvsClipAnimatedSticker.h"
#import <CoreGraphics/CGGeometry.h>

/*! \if ENGLISH
 *  \brief The type of the video clip
 *  \else
 *  \brief 视频片段类型
 *  \endif
*/
typedef enum NvsVideoClipType {
    NvsVideoClipType_AV = 0,   //!< \if ENGLISH Audio and video \else 音视频 \endif
    NvsVideoClipType_Image,    //!< \if ENGLISH Image \else 图片 \endif
} NvsVideoClipType;

/*! \if ENGLISH
 *  \brief The motion mode of the clip.
 *  \else
 *  \brief 图片片段运作模式
 *  \endif
 *  \since 1.1.0
*/
typedef enum {
    NvsStreamingEngineImageClipMotionMode_LetterBoxZoomIn = 0,  //!< \if ENGLISH Zoom in \else 放大 \endif
    NvsStreamingEngineImageClipMotionMode_LetterBoxZoomOut,     //!< \if ENGLISH Zoom out\else 缩小 \endif
    NvsStreamingEngineImageClipMotionMode_ROI,                  //!< \if ENGLISH The image clip's ROI(Region Of Interesting) \else 图片片段ROI(Region Of Interesting) \endif      //!< 图片片段ROI(Region Of Interesting)
    NvsStreamingEngineImageClipMotionMode_Crop                  //!< \if ENGLISH Image clip's crop \else 图片片段裁剪 \since 3.7.2 \endif
} NvsStreamingEngineImageClipMotionMode;

/*! \if ENGLISH
 *  \brief Background mode
 *  \else
 *  \brief 背景模式
 *  \endif
*/
typedef enum NvsSourceBackgroundMode {
    NvsSourceBackgroundModeColorSolid = 0,  //!< \if ENGLISH Solid color \else 纯色 \endif
    NvsSourceBackgroundModeBlur,            //!< \if ENGLISH Blur \else 模糊 \endif
} NvsSourceBackgroundMode;

/*!
 *  \if ENGLISH
 *   @name Variant image fill mode
 *  \else
 *   @name 填充模式
 *  \endif
 */
typedef enum NvsVariantImageFillMode {
    NvsVariantImageFillModeAspectFit = 0,  //!< \if ENGLISH Select one of the long sides of the length and width as the basis to fill in equal proportions \else 选取长宽里面较大的一个作为依据进行等比例填充 \since 3.7.0 \endif
    NvsVariantImageFillModeAspectFill,     //!< \if ENGLISH Select one of the short sides of the length and width as the basis to fill in equal proportions \else 选取长宽里面较小的一个作为依据进行等比例填充 \since 3.7.0 \endif
    NvsVariantImageFillModeFill,           //!< \if ENGLISH fill \else 填充 \since 3.7.0 \endif
} NvsVariantImageFillMode;

typedef enum NvsClipWrapMode {
    NvsClipWrapMode_Repeat_LastFrame = 0,
    NvsClipWrapMode_Repeat_FirstFrame = 1,
    NvsClipWrapMode_Repeat = 2
} NvsClipWrapMode;

typedef enum NvsExtraVideoRotation {
    NvsExtraVideoRotation_0 = 0,
    NvsExtraVideoRotation_90 = 1,
    NvsExtraVideoRotation_180 = 2,
    NvsExtraVideoRotation_270 = 3
} NvsExtraVideoRotation;

/*! \if ENGLISH
 *  \brief Track blending mode
 *  \else
 *  \brief 合成模式
 *  \endif
*/
typedef enum NvsClipBlendingMode {
    NvsClipBlendingMode_Normal = 0,        //!< \if ENGLISH Normal mode \else 一般默认 \endif
    NvsClipBlendingMode_Multiplay,         //!< \if ENGLISH multiplay mode \else 正片叠底模式 \endif
    NvsClipBlendingMode_Subtract,          //!< \if ENGLISH Subtract mode \else 减去模式 \endif
    NvsClipBlendingMode_Screen,            //!< \if ENGLISH Screen mode \else 滤色模式 \endif
    NvsClipBlendingMode_Add,               //!< \if ENGLISH Add mode \else 添加类型 \endif
    NvsClipBlendingMode_Exclusion,         //!< \if ENGLISH Exclusion mode \else 排除模式 \endif
    NvsClipBlendingMode_Darken,         //!< \if ENGLISH Darken mode \else 变暗模式 \endif
    NvsClipBlendingMode_Burn,         //!< \if ENGLISH Burn mode \else 颜色加深模式 \endif
    NvsClipBlendingMode_LinearBurn,         //!< \if ENGLISH Linear Burn mode \else 线性加深模式 \endif
    NvsClipBlendingMode_Lighten,         //!< \if ENGLISH Lighten mode \else 变亮模式 \endif
    NvsClipBlendingMode_Dodge,         //!< \if ENGLISH Dodge mode \else 颜色减淡模式 \endif
    NvsClipBlendingMode_Overlay,         //!< \if ENGLISH Overlay mode \else 叠加模式 \endif
    NvsClipBlendingMode_SoftLight,         //!< \if ENGLISH SoftLight mode \else 柔光模式 \endif
    NvsClipBlendingMode_HardLight,         //!< \if ENGLISH HardLight mode \else 强光模式 \endif
    NvsClipBlendingMode_VividLight,         //!< \if ENGLISH VividLight mode \else 亮光模式 \endif
    NvsClipBlendingMode_PinLight,         //!< \if ENGLISH PinLight mode \else 点光模式 \endif
    NvsClipBlendingMode_LinearLight,         //!< \if ENGLISH LinearLight mode \else 线性光模式 \endif
    NvsClipBlendingMode_HardMix,         //!< \if ENGLISH HardMix mode \else 实色混合模式 \endif
    NvsClipBlendingMode_Difference,         //!< \if ENGLISH Difference mode \else 差值模式 \endif
} NvsClipBlendingMode;

typedef NS_ENUM(NSInteger, NvsClipRawFilterProcessesMode) {
    NvsClipRawFilterProcessesModeNone = 0, //!< \if ENGLISH The Raw filter input and output sizes are the same as the resolution of the media file \else Raw滤镜输入输出尺寸都是和媒体文件的分辨率一致 \endif
    NvsClipRawFilterProcessesModeVarSize, //!< \if ENGLISH Raw filters are processed in varied-size mode and are finally adapted to the timeline size according to FillMode Fill mode \else Raw 滤镜都会按照变尺寸模式进行处理，最后会按照FillMode Fill的模式适配到时间线的尺寸上 \endif
    NvsClipRawFilterProcessesModeVarSizeWithFillModeUsed //!< \if ENGLISH fit the size of the timeline according to the set fill mode \else 最后会按照设置的填充模式适配到时间线的尺寸 \endif
};

@class NvsVideoFx;

/*! \if ENGLISH
 *  \brief The video clip is description of the video file.
 *
 *  The video clip source can be a video or an image. Each video clip can be modified for its in and out point value, the speed of playing, and the pan and scan.
 *  When editing a video, users can add or insert multiple video effects by the type of effect (built-in, package and beauty).
 *  When adding a resource package effect, users have to install it firstly. When installation is successful, users can get the package Id to use, and the built-in effect can be used only by obtaining the effect name.
 *  \warning In the NvsVideoClip class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 视频片段，对视频文件的描述
 *
 *  视频片段源可以是视频或者图片。每个视频片段可以修改其裁剪入点、裁剪出点以及播放速度，也可以设置摇摄和扫描。编辑视频时，可以按特效类型的不同（内建特效，包裹式特效，美颜特效）添加或者插入多个视频特效。
 *  添加资源包特效时，都得先安装，安装成功后获取packageId才能使用，而内建特效(builtin)只需获取特效名称即可使用。
 *  \warning NvsVideoClip类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsVideoClip : NvsClip


@property (readonly) NvsVideoClipType videoType;                              //!< \if ENGLISH Type of the video clip. \else 视频片段类型 \endif


@property (readonly) NvsRoleInTheme roleInTheme;                              //!< \if ENGLISH The clip's role in themes (General, title and trailer). \else 视频片段在主题中角色(通用、片头、片尾) \endif

@property (nonatomic) NvsStreamingEngineImageClipMotionMode imageMotionMode;  //!< \if ENGLISH The motion mode of the image clip. \else 图片片段运作模式 \endif \since 1.1.0

@property (nonatomic) BOOL imageMotionAnimationEnabled;                       //!< \if ENGLISH Whether it supports animation of images. \else 是否支持图片动画 \endif \since 1.1.0

@property (readonly) NvsRect startROI;                                        //!< \if ENGLISH Image clip's starting ROI (Region Of Interesting)\else 图片片段起始ROI \endif \since 1.1.0

@property (readonly) NvsRect endROI;                                          //!< \if ENGLISH Image clip's ending ROI (Region Of Interesting) \else 图片片段结束ROI \endif \since 1.1.0

@property (readonly) unsigned int audioFxCount;                               //!< \if ENGLISH The count of audio effects on the clip. \else 片段上的特效数量 \endif

@property (nonatomic, assign) NvsClipRawFilterProcessesMode rawFilterProcessesMode; //!< \if ENGLISH raw filter processes mode \else Raw滤镜的处理方式 \endif

/*! \if ENGLISH
 *  \brief Sets whether the clip is reversed.
 *
 *  Note: If users use the reversed clip to playback,please ensure that the current video file is a I frame video, otherwise the efficiency of the reversed playback is extremely low and completely intolerable! Users can use the Recording flag of
 *  Uses STREAMING_ENGINE_RECORDING_FLAG_VIDEO_INTRA_FRAME_ONLY for the Meishe SDK to generate a I frame video file.
 *  If the files which import from other places cannot be guaranteed to be a I frame video and users want to use the reversed function, users can use the Meishe transcoding SDK to directly transcode the original video into a reversed file and then use the reversed file.
 *  Note: Make sure the video files locate in the sandbox of the app that users need to reverse.
 *  \param playInReverse Whether the clip is reversed.
 *  \else
 *  \brief 设置片段是否倒放
 *
 *  注意：使用片段倒放请确保当前视频文件为全I帧视频，否则倒放播放效率极低完全无法忍受！可以利用美摄SDK录制标志
 *  STREAMING_ENGINE_RECORDING_FLAG_VIDEO_INTRA_FRAME_ONLY来产生出全I帧视频文件。如果从别的地方
 *  导入的文件无法保证为全I帧视频又想用倒放功能则可以使用美摄的转码SDK直接将原始视频转码为一个倒放的文件再使用。
 *  注意：请确保需要倒放的视频文件位于APP的沙盒中
 *  \param playInReverse 片段是否倒放
 *  \endif
 *  \since 1.5.1
 *  \sa getPlayInReverse
*/
- (void)setPlayInReverse:(BOOL)playInReverse;

/*! \if ENGLISH
 *  \brief Gets whether the clip is reversed.
 *  \return Returns the BOOL value whether the clip is reversed.
 *  \else
 *  \brief 获取片段是否倒放
 *  \return 返回片段是否倒放
 *  \endif
 *  \since 1.5.1
 *  \sa setPlayInReverse
*/
- (BOOL)getPlayInReverse;

/*! \if ENGLISH
 *  \brief Sets the video's extra rotation angle.
 *  \param rotation Extra rotation angle
 *  \else
 *  \brief 设置视频额外旋转角度
 *  \param rotation 额外旋转角度
 *  \endif
 *  \sa getExtraVideoRotation
*/
- (void)setExtraVideoRotation:(NvsExtraVideoRotation)rotation;

/*! \if ENGLISH
 *  \brief Sets the video's extra rotation angle.
 *  \param rotation Extra rotation angle
 *  \else
 *  \brief 设置视频额外旋转角度
 *  \param rotation 额外旋转角度
 *  \param rotateROI 是否旋转ROI运动方向
 *  \endif
 *  \sa getExtraVideoRotation
*/
- (void)setExtraVideoRotation:(NvsExtraVideoRotation)rotation rotateROI:(bool)rotateROI;

/*! \if ENGLISH
 *  \brief Gets the video's extra rotation angle.
 *  \return Return the extra rotation angle which obtains.
 *  \else
 *  \brief 获取视频额外旋转角度
 *  \return 返回获取额外旋转角度
 *  \endif
 *  \sa setExtraVideoRotation:
*/
- (NvsExtraVideoRotation)getExtraVideoRotation;

/*! \if ENGLISH
 *  \brief Sets the pan and scan.
 *
 *  The pan and scan functions are used to adapt the position and size of the video's image on the display window. For details, please refer to the topic of [Pan and Scan] (\ref Pan_Scan.md).
 *  \param pan 摇摄
 *  \param scan 扫描
 *  \else
 *  \brief 设置摇摄和扫描
 *
 *  摇摄和扫描功能是用来适配图像在显示窗口上的位置与大小的。具体请参见[摇摄与扫描(Pan and Scan)] (\ref Pan_Scan.md)专题。
 *  \param pan 摇摄
 *  \param scan 扫描
 *  \endif
 *  \sa getPan:andScan:
*/
- (void)setPan:(float)pan andScan:(float)scan;

/*! \if ENGLISH
 *  \brief Gets the pan and scan.
 *  \param pan Output the panning value
 *  \param scan Output the scanning value
 *  \else
 *  \brief 获取摇摄和扫描
 *  \param pan 输出摇摄值
 *  \param scan 输出扫描值
 *  \endif
 *  \sa setPan:andScan:
*/
- (void)getPan:(float *)pan andScan:(float *)scan;

/*! \if ENGLISH
 *  \brief Sets whether to enable ROI mode on video clip. default pan and scan mode is used
 *  \param disable whether to enable or not.
 *  \else
 *  \brief 设置视频是否启用ROI的模式,默认使用的是摇摄和扫描模式
 *  \param enable 是否启用
 *  \endif
 *  \sa isVideoClipROIEnabled
 *  \sa setImageMotionROI
 */
- (void)enableVideoClipROI:(BOOL) enable;

/*! \if ENGLISH
 *  \brief Gets whether to enable ROI mode on video clip.
 *  \return Returns whether to enable ROI mode on video clip.
 *  \else
 *  \brief 获取视频是否启用ROI的模式
 *  \return 返回获取的视频是否启用ROI的模式
 *  \endif
 *  \sa enableVideoClipROI
 */
- (BOOL)isVideoClipROIEnabled;

/*! \if ENGLISH
 *  \brief Sets the background mode.
 *  \param sourceBackgroundMode the background mode (@ref ClIP_BACKGROUNDMODE)
 *  \else
 *  \brief 设置背景模式
 *  \param sourceBackgroundMode 背景模式 (@ref ClIP_BACKGROUNDMODE)
 *  \endif
 *  \sa getSourceBackgroundMode:
*/
- (void)setSourceBackgroundMode:(NvsSourceBackgroundMode) sourceBackgroundMode;

/*! \if ENGLISH
 *  \brief Gets the background mode.
 *  \return Background mode(@ref ClIP_BACKGROUNDMODE)
 *  \else
 *  \brief 获取背景模式
 *  \return 背景模式(@ref ClIP_BACKGROUNDMODE)
 *  \endif
 *  \sa setSourceBackgroundMode:sourceBackgroundMode:
*/
- (NvsSourceBackgroundMode)getSourceBackgroundMode;

/*! \if ENGLISH
 *  \brief Sets the background color.
 *  \param color the background color
 *  \else
 *  \brief 设置片段背景颜色
 *  \param color 背景颜色
 *  \endif
 *  \sa getSourceBackgroundColor:
 *  \since 2.11.1
 */
- (void)setSourceBackgroundColor:(NvsColor *)color;

/*! \if ENGLISH
 *  \brief Gets the background color.
 *  \return Background color
 *  \else
 *  \brief 获取背景颜色
 *  \return 背景颜色
 *  \endif
 *  \sa setSourceBackgroundColor:
 *  \since 2.11.1
 */
- (NvsColor)getSourceBackgroundColor;

/*! \if ENGLISH
 *  \brief Sets whether the video disables the approximate scale cropping of the screen, The default is false.
 *  \param disable whether disable or not.
 *  \else
 *  \brief 设置是否禁止画面的近似比例裁剪，默认为false。
 *  \param disable 是否禁止
 *  \endif
 *  \sa isAmbiguousCropDisabled:
*/
- (void)disableAmbiguousCrop:(BOOL) disable;

/*! \if ENGLISH
 *  \brief Gets whether the video disables the approximate scale cropping of the screen.
 *  \return Whether the video disables the approximate scale cropping of the screen.
 *  \else
 *  \brief 获取是否禁止画面的近似比例裁剪
 *  \return 是否禁止画面的近似比例裁剪
 *  \endif
 *  \sa disableAmbiguousCrop:disable:
*/
- (BOOL)isAmbiguousCropDisabled;

/*! \if ENGLISH
 *  \brief Sets the motion ROI(Region Of Interesting) for the Image clip.
 *
 *  For details, please refer to [The Topics of the Image Clip's ROI](\ref ImageROI.md)
 *  \param startROI Image clip's starting ROI
 *  \param endROI Image clip's terminating ROI
 *  \else
 *  \brief 设置图片片段动态移动ROI
 *
 *  具体情况请参见[图片片段ROI专题] (\ref ImageROI.md)
 *  \param startROI 图片片段起始ROI
 *  \param endROI 图片片段终止ROI
 *  \endif
 *  \since 1.1.0
 *  \sa setPan:andScan:
*/
- (void)setImageMotionROI:(NvsRect *)startROI endROI:(NvsRect *)endROI;

/*! \if ENGLISH
 *  \brief Sets the clip's loop mode.
 *  \param wrapMode Loop mode
 *  \else
 *  \brief 设置片段循环模式
 *  \param wrapMode 循环模式
 *  \endif
 *  \since 2.2.3
 *  \sa getClipWrapMode
*/
- (void)setClipWrapMode:(NvsClipWrapMode)wrapMode;

/*! \if ENGLISH
 *  \brief Gets the clip's loop mode.
 *  \return Returns the loop mode.
 *  \else
 *  \brief 获取视频循环模式
 *  \return 返回循环模式
 *  \endif
 *  \since 2.2.3
 *  \sa setClipWrapMode
*/
- (NvsClipWrapMode)getClipWrapMode;

/*! \if ENGLISH
 *  \brief Set Audio Fade-In Duration
 *  \param fadeInDuration Fade-In Duration
 *  \else
 *  \brief 设置音频淡入的时长
 *  \param fadeInDuration 淡入的时长
 *  \endif
 *  \since 2.8.2
 *  \sa getAudioFadeInDuration
 */
- (void)setAudioFadeInDuration:(int64_t)fadeInDuration;

/*! \if ENGLISH
 *  \brief Get Audio Fade-In Duration
 *  \return Returns Fade-In Duration
 *  \else
 *  \brief 获取音频的淡入时长
 *  \return 返回淡入时长
 *  \endif
 *  \since 2.8.2
 *  \sa setAudioFadeInDuration
 */
- (int64_t)getAudioFadeInDuration;

/*! \if ENGLISH
 *  \brief Set Audio Fade-Out Duration
 *  \param fadeOutDuration Fade-Out Duration
 *  \else
 *  \brief 设置音频淡出的时长
 *  \param fadeOutDuration 淡出的时长
 *  \endif
 *  \since 2.8.2
 *  \sa getAudioFadeOutDuration
 */
- (void)setAudioFadeOutDuration:(int64_t)fadeOutDuration;

/*! \if ENGLISH
 *  \brief Get Audio Fade-Out Duration
 *  \return Returns Fade-Out Duration
 *  \else
 *  \brief 获取音频的淡出时长
 *  \return 返回淡出时长
 *  \endif
 *  \since 2.8.2
 *  \sa setAudioFadeOutDuration
 */
- (int64_t)getAudioFadeOutDuration;

/*! \if ENGLISH
 *  \brief Changes the playback speed of the clip.
 *  \param startSpeed start playback speed.
 *  \param endSpeed end playback speed.
 *  \param keepAudioPitch Keep the tone unchanged.
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state, see [Engine Change Feature] (\ref EngineChange.md) for details.
 *  \sa getStartSpeed
 *  \since 2.11.0
 *  \else
 *  \brief 改变片段的播放速度
 *  \param startSpeed 开始播放速度
 *  \param endSpeed 结束播放速度
 *  \param keepAudioPitch 保持音调不变
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \sa getEndSpeed,
 *  \since 2.11.0
 *	\endif
 */
- (void)changeVariableSpeed:(double)startSpeed endSpeed:(double)endSpped keepAudioPitch:(BOOL)keepAudioPitch;

/*! \if ENGLISH
 *  \brief Get the playback speed of the clip.
 *
 *  \brief The default value is 1, which means that it plays at normal speed; the value less than 1 means slower playback; the value greater than 1 means faster playback.
 *  \return Returns the playback start speed of the current clip.
 *  \sa changeVariableSpeed:endSpeed:keepAudioPitch:
 *  \since 2.11.0
 *  \else
 *  \brief 默认值为1，表示按正常速度播放;小于1的值表示慢放;大于1的值表示快放
 *  \return 返回当前片段的起始播放速度
 *  \sa changeVariableSpeed:endSpeed:keepAudioPitch:
 *  \since 2.11.0
 *	\endif
*/
-(double)getStartSpeed;

/*! \if ENGLISH
*  \brief Get the playback speed of the clip.
*
*  \brief The default value is 1, which means that it plays at normal speed; the value less than 1 means slower playback; the value greater than 1 means faster playback.
*  \return Returns the playback end speed of the current clip.
*  \sa changeVariableSpeed:endSpeed:keepAudioPitch:
*  \since 2.11.0
*  \else
*  \brief 默认值为1，表示按正常速度播放;小于1的值表示慢放;大于1的值表示快放
*  \return 返回当前片段的结束播放速度
*  \sa changeVariableSpeed:endSpeed:keepAudioPitch:
*  \since 2.11.0
*	\endif
*/
- (double)getEndSpeed;

/*!
 *  \if ENGLISH
 *  \brief set blending mode to video clip.
 *  \param blendMode new blending mode.
 *  \sa getBlendingMode
 *  \else
 *  \brief 设置合成模式
 *  \param blendMode 合成模式
 *  \sa getBlendingMode
 *  \endif
*/
- (void)setBlendingMode:(NvsClipBlendingMode)blendMode;

/*!
 *  \if ENGLISH
 *  \brief get blending mode from video clip.
 *  \return current clip blending mode.
 *  \sa setBlendingMode
 *  \else
 *  \brief 获取合成模式
 *  \return 返回合成模式
 *  \sa setBlendingMode
 *  \endif
*/
- (NvsClipBlendingMode)getBlendingMode;

/*!
 *  \if ENGLISH
 *  \brief set opacity value to video clip.
 *  \param opacity new opacity value, Default value is 1, range (0,1).
 *  \sa getTrackOpacity
 *  \else
 *  \brief 设置透明度
 *  \param opacity  透明度，默认值为1，范围(0,1]
 *  \sa getOpacity
 *  \endif
*/
- (void)setOpacity:(float)opacity;

/*!
 *  \if ENGLISH
 *  \brief set opacity value from video clip.
 *  \return current opacity value.
 *  \sa setTrackOpacity
 *  \else
 *  \brief 获取透明度
 *  \return 返回透明度
 *  \sa setOpacity
 *  \endif
*/
- (float)getOpacity;

/*!
 *  \if ENGLISH
 *  \brief Turn on special effect rendering based on the original scale of the video clip.
 *  \param Enable Turn on or not.
 *  \sa IsOriginalRender
 *  \else
 *  \brief 开启按照视频片段的原始比例进行特效渲染
 *  \param enable  是否开启
 *  \sa IsOriginalRender
 *  \endif
*/
- (void)setEnableOriginalRender:(BOOL)enable;

/*!
 *  \if ENGLISH
 *  \brief Gets whether the original scale rendering mode is turned on.
 *  \return Turn on or not.
 *  \sa setEnableOriginalRender
 *  \else
 *  \brief 获取是否开启了原始比例渲染的模式
 *  \return 返回是否开启
 *  \sa setEnableOriginalRender
 *  \endif
*/
- (BOOL)isOriginalRender;

/*! \if ENGLISH
 *  \brief Sets the clip's hdr enable status.
 *  \param enable enable status.
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state, please refer to [Engine Change Feature] (\ref EngineChange.md) for details.
 *  \else
 *  \brief 设置片段静帧效果开启状态
 *  \param enable 是否开启
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \since 2.18
 *  \sa isClipFreenzeFrameEnabled
 */
- (void)enableClipFreezeFrame:(BOOL)enable;

/*! \if ENGLISH
 *  \brief Gets video freeze frame enabled.
 *  \else
 *  \brief 获取静帧效果是否开启
 *  \endif
 *  \since 2.18
 */
- (BOOL)isClipFreezeFrameEnabled;

/*! \if ENGLISH
 *  \brief Sets the clip's freeze trim position.
 *  \param trimPos freeze trim position(in microseconds).
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state, please refer to [Engine Change Feature] (\ref EngineChange.md) for details.
 *  \else
 *  \brief 设置片段静帧效果位置
 *  \param trimPos 静帧位置（单位微秒）
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \since 2.18
 *  \sa isClipFreenzeFrameEnabled
 */
- (void)setClipFreezeFrameTrimPosition:(long)trimPos;

/*! \if ENGLISH
 *  \brief Gets video freeze trim position(in microseconds).
 *  \else
 *  \brief 获取静帧位置（单位微秒）
 *  \endif
 *  \since 2.18
 */
- (long)getClipFreezeFrameTrimPosition;

/*! \if ENGLISH
 *  \brief Enable the original frame mode
 *         If enable this mode:
 *         SetPanAndScan, GetPanAndScan,
 *         DisableAmbiguousCrop, IsAmbiguousCropDisabled,
 *         SetImageMotionMode, ImageMotionMode
 *         SetImageMotionROI, GetImageMotionROI,
 *         SetImageMotionAnimationEnabled, IsImageMotionAnimationEnabled,
 *         SetImageMaskROI, GetImageMaskROI,are already invalid.
 *         If the property videoFx is enable, the corresponding parameters in the property videoFx have no effect
 *  \else
 *  \brief 开启原始画幅模式
 *         当这个模式开启后，
 *         SetPanAndScan, GetPanAndScan,
 *         DisableAmbiguousCrop, IsAmbiguousCropDisabled,
 *         SetImageMotionMode, ImageMotionMode
 *         SetImageMotionROI, GetImageMotionROI,
 *         SetImageMotionAnimationEnabled, IsImageMotionAnimationEnabled,
 *         SetImageMaskROI, GetImageMaskROI,都已经无效。
 *         如果开启了属性特技，在属性特技中的对应的参数是没有效果的
 *  \endif
 *  \sa isRawSourceModeEnabled
 *  \since 3.7.0
 */
- (void)enableRawSourceMode:(BOOL) enable;

/*! \if ENGLISH
 *  \brief The raw source mode is enabled
 *  \return Returns Whether to enable raw source mode
 *  \else
 *  \brief 获取原始画幅模式状态
 *  \return 返回是否开启了状态
 *  \endif
 *  \sa enableRawSourceMode
 *  \since 3.7.0
 */
- (BOOL)isRawSourceModeEnabled;

/*! \if ENGLISH
 *  \brief Appends audio effect at the end of the clip
 *  \param fxName The name of audio effect,please refer to [getAllBuiltinAudioFxNames()](@ref NvsStreamingContext::getAllBuiltinAudioFxNames) or [The List of Built-in Effect Name](\ref FxNameList.md).
 *  \return Returns the appended NvsAudioFx object.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine] (\ref EngineChange.md)。
 *  \else
 *  \brief 在片段尾部追加音频特效
 *  \param fxName 特效名称。获取特效名称，请参照[getAllBuiltinAudioFxNames()](@ref NvsStreamingContext::getAllBuiltinAudioFxNames)或[内建特效名称列表] (\ref FxNameList.md).
 *  \return 返回追加的音频特效对象
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa insertAudioFx:fxIndex:
 *  \sa removeAudioFx:
 *  \sa getAudioFxWithIndex:
 *  \since 2.24.0
*/
- (NvsAudioFx *)appendAudioFx:(NSString *)fxName;

/*! \if ENGLISH
 *  \brief Inserts a special effect at the index of the specified effect on the clip.
 *  \param fxName The name of special effect,please refer to [getAllBuiltinAudioFxNames()](@ref NvsStreamingContext::getAllBuiltinAudioFxNames) or [The List of Built-in Effect Name](\ref FxNameList.md).
 *  \param fxIndex The index of the specified effect. Range [0, [getFxCount()](@ref getFxCount) - 1 ). If index is outOfRange,It will be add in the end.
 *  \return Returns the inserted NvsAudioFx object.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine] (\ref EngineChange.md).
 *  \else
 *  \brief 在片段上指定特效索引处插入音频特效
 *  \param fxName 特效名称。获取特效名称，请参照[getAllBuiltinAudioFxNames()](@ref NvsStreamingContext::getAllBuiltinAudioFxNames)或[内建特效名称列表] (\ref FxNameList.md)。
 *  \param fxIndex 指定特效索引。范围[0, [getFxCount()](@ref getFxCount) - 1)。如果索引超出范围，会在最后面添加。
 *  \return 返回插入的音频特效对象
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa appendAudioFx:
 *  \sa removeAudioFx:
 *  \sa getAudioFxWithIndex:
 *  \since 2.24.0
*/
- (NvsAudioFx *)insertAudioFx:(NSString *)fxName fxIndex:(unsigned int)fxIndex;

/*! \if ENGLISH
*  \brief Appends custom audio effect to the clip.
*  \param NvsCustomAudioFx.Renderer User-implemented custom audio effect renderer interface.
*  \return Returns the appended audio effect object.
*  \warning This interface causes the streaming engine state to jump to the engine stop state. For more infomations please refer to [Engine Changes] (\ref EngineChange.md).
*  \else
*  \brief 在音频片段上追加自定义音频特效
*  \param NvsCustomAudioFx.Renderer 用户实现的自定义视频特效渲染器接口
*  \return 返回追加的音频特效对象
*  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
*  \endif
*  \since 2.24.0
*/
- (NvsAudioFx *)appendCustomAudioFx:(id<NvsCustomAudioFxRenderer>)customAudioFxRender;

/*! \if ENGLISH
*  \brief Inserts a custom audio effect at the specified effect index on the clip.
*  \param NvsCustomAudioFx.Renderer User-implemented custom audio effect renderer interface.
*  \param fxIndex audio effects' index to insert at.Range [0, [getFxCount()](@ref getFxCount) - 1 ). If index is outOfRange,It will be add in the end.
*  \return Returns the inserted audio effect object.
*  \warning This interface will cause the streaming engine state to jump to the engine stop state. For more information, please refer to [Engine Change] (\ref EngineChange.md).
*  \else
*  \brief 在片段上指定特效索引处插入自定义音频特效
*  \param NvsCustomAudioFx.Renderer 用户实现的自定义视频特效渲染器接口
*  \param fxIndex 插入音频特效索引。范围[0, [getFxCount()](@ref getFxCount) - 1)。如果索引超出范围，会在最后面添加。
*  \return 返回插入的音频特效对象
*  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
*  \endif
*  \since 2.24.0
*/
- (NvsAudioFx *)insertCustomAudioFx:(id<NvsCustomAudioFxRenderer>)customAudioFxRender fxIndex:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Removes the audio effect from the specified index，The subsequent audioFx index moves forward
 *  \param fxIndex The index of the special effect. Range [0, [getFxCount()] (@ref getFxCount))
 *  \return Returns BOOL value. If the value is YES, the removal is successful, and the NO means it fails.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine] (\ref EngineChange.md).
 *  \else
 *  \brief 移除指定索引的音频特效，后面的特效索引前移。
 *  \param fxIndex 特效索引。范围[0, [getFxCount()] (@ref getFxCount))
 *  \return 返回BOOL值。值为YES则移除成功，NO则移除失败。
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa appendAudioFx:
 *  \sa insertAudioFx:fxIndex:
 *  \sa getAudioFxWithIndex:
 *  \since 2.24.0
*/
- (BOOL)removeAudioFx:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Gets the audio effect by index
 *  \param fxIndex The index of the audio effect. Range [0, [getFxCount()] (@ref getFxCount))
 *  \return Returns the acquired NvsAudioFx object.
 *  \else
 *  \brief 通过索引获取音频特效
 *  \param fxIndex 特效索引。范围[0, [getFxCount()] (@ref getFxCount))
 *  \return 返回获取的音频特效对象
 *  \endif
 *  \sa appendAudioFx:
 *  \sa insertAudioFx:fxIndex:
 *  \sa removeAudioFx:
 *  \since 2.24.0
*/
- (NvsAudioFx *)getAudioFxWithIndex:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Appends the built-in effect on the clip.
 *  \param fxName The effect name,if users get the video effect name, please refer to [getAllBuiltinVideoFxNames()] (@ref NvsStreamingContext::getAllBuiltinVideoFxNames) or [The List of Built-in Effect Name] (\ref FxNameList.md)
 *  \return Returns the appended NvsVideoFx object.
 *  \else
 *  \brief 在片段上追加内嵌式特效
 *  \param fxName 特效名称。获取视频特效名称，请参见[getAllBuiltinVideoFxNames()] (@ref NvsStreamingContext::getAllBuiltinVideoFxNames)或[内建特效名称列表] (\ref FxNameList.md)
 *  \return 返回追加的视频特效对象
 *  \endif
 *  \sa insertBuiltinFx:fxIndex:
 *  \sa appendBeautyFx
 *  \sa appendPackagedFx:
*/
- (NvsVideoFx *)appendBuiltinFx:(NSString *)fxName;

/*! \if ENGLISH
 *  \brief Inserts a built-in effect at the specified effect index on the clip.
 *  \param fxName The effect name,if users get the video effect name, please refer to [getAllBuiltinVideoFxNames()] (@ref NvsStreamingContext::getAllBuiltinVideoFxNames) or [The List of Built-in Effect Name] (\ref FxNameList.md)
 *  \param fxIndex The specified effect index
 *  \return Returns the inserted NvsVideoFx object.
 *  \else
 *  \brief 在片段上指定特效索引处插入内嵌式特效
 *  \param fxName 特效名称。获取视频特效名称，请参见[getAllBuiltinVideoFxNames()] (@ref NvsStreamingContext::getAllBuiltinVideoFxNames)或[内建特效名称列表] (\ref FxNameList.md)
 *  \param fxIndex 指定特效索引
 *  \return 返回插入的视频特效对象
 *  \endif
 *  \sa appendBuiltinFx:
 *  \sa insertPackagedFx:fxIndex:
 *  \sa insertBeautyFx:
*/
- (NvsVideoFx *)insertBuiltinFx:(NSString *)fxName fxIndex:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Appends the resource package effect on the clip.
 *  \param fxPackageId The resource package ID of effect
 *  \return Returns the appended NvsVideoFx object.
 *  \else
 *  \brief 在片段上追加资源包特效
 *  \param fxPackageId 特效资源包ID
 *  \return 返回追加的视频特效对象
 *  \endif
 *  \sa appendBeautyFx
 *  \sa appendBuiltinFx:
 *  \sa insertPackagedFx:fxIndex:
*/
- (NvsVideoFx *)appendPackagedFx:(NSString *)fxPackageId;

/*! \if ENGLISH
 *  \brief Inserts the resource package effect at the specified effect index on the clip.
 *  \param fxPackageId The resource package ID of effect.
 *  \param fxIndex The specified effect index
 *  \return Returns the inserted NvsVideoFx object.
 *  \else
 *  \brief 在片段上指定特效索引处插入包裹特效
 *  \param fxPackageId 包裹特效Id
 *  \param fxIndex 插入特效索引
 *  \return 返回插入的视频特效对象
 *  \endif
 *  \sa insertBeautyFx:
 *  \sa appendPackagedFx:
 *  \sa insertBuiltinFx:fxIndex:
*/
- (NvsVideoFx *)insertPackagedFx:(NSString *)fxPackageId fxIndex:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Appends the custom video effect on the clip.
 *  \param customVideoFxRender The renderer interface of the custom video effect which users implement
 *  \return Returns the appended NvsVideoFx object.
 *  \else
 *  \brief 在片段上追加自定义视频特效
 *  \param customVideoFxRender 用户实现的自定义视频特效渲染器接口
 *  \return 返回追加的视频特效对象
 *  \endif
 *  \since 1.7.0
*/
- (NvsVideoFx *)appendCustomFx:(id<NvsCustomVideoFxRenderer>)customVideoFxRender;

/*! \if ENGLISH
 *  \brief Inserts the custom video effect at the specified effect index on the clip.
 *  \param customVideoFxRender The renderer interface of the custom video effect which users implement
 *  \param fxIndex The specified effect index
 *  \return Returns the inserted NvsVideoFx object.
 *  \else
 *  \brief 在片段上指定特效索引处插入自定义视频特效
 *  \param customVideoFxRender 用户实现的自定义视频特效渲染器接口
 *  \param fxIndex 插入特效索引
 *  \return 返回插入的视频特效对象
 *  \endif
 *  \since 1.7.0
*/
- (NvsVideoFx *)insertCustomFx:(id<NvsCustomVideoFxRenderer>)customVideoFxRender fxIndex:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief  Appends built-in effect on the raw input to clips.
 *  \param fxName The effect name. To get the video effect name, please refer to [getAllBuiltinVideoFxNames()] (@ref com.meicam.sdk.NvsStreamingContext.getAllBuiltinVideoFxNames) or [built-in effect name list] (\ref FxNameList.md).
 *  \return Returns the added video effect object.
 *  \else
 *  \brief 在片段上追加作用在原始输入上的内嵌式特效
 *  \param fxName 特效名称。获取视频特效名称，请参见[getAllBuiltinVideoFxNames()] (@ref com.meicam.sdk.NvsStreamingContext.getAllBuiltinVideoFxNames)或[内建特效名称列表] (\ref FxNameList.md)
 *  \return 返回追加的视频特效对象
 *  \endif
 *  \since 2.20.0
 */
- (NvsVideoFx *)appendRawBuiltinFx:(NSString *)fxName;

/*! \if ENGLISH
*  \brief Inserts a built-in effect at the specified effect index on the raw input on the clip.
*  \param fxName The effect name. To get the video effect name, please refer to [getAllBuiltinVideoFxNames()] (@ref com.meicam.sdk.NvsStreamingContext.getAllBuiltinVideoFxNames) or [Built-in Effect Name List] (\ref FxNameList.md).
*  \param fxIndex Effect index to insert at.
*  \return Returns the inserted video effect object.
*  \else
*  \brief 在片段上指定特效索引处插入作用在原始输入上的内嵌式特效
*  \param fxName 特效名称。获取视频特效名称，请参见[getAllBuiltinVideoFxNames()] (@ref com.meicam.sdk.NvsStreamingContext.getAllBuiltinVideoFxNames)或[内建特效名称列表]
*  \param fxIndex 插入特效索引
*  \return 返回插入的视频特效对象
*  \endif
*  \since 2.20.0
*/
- (NvsVideoFx *)insertRawBuiltinFx:(NSString *)fxName fxIndex:(unsigned int)fxIndex;

/*! \if ENGLISH
*  \brief Appends package effect on the raw input to the clip.
*  \param fxPackageId Effect resource package ID.
*  \return Returns the added video effect object.
*  \else
*  \brief 在片段上追加作用在原始输入上的资源包特效
*  \param fxPackageId 特效资源包ID
*  \return 返回追加的视频特效对象
*  \endif
*  \since 2.20.0
*/
- (NvsVideoFx *)appendRawPackagedFx:(NSString *)fxPackageId;

/*! \if ENGLISH
*  \brief Inserts package effect at the specified effect index on the raw input on the clip.
*  \param fxPackageId Effect resource package ID.
*  \param fxIndex Effect index to insert at, please refer to [getRawFxCount()].
*  \return Returns the inserted video effect object.
*  \else
*  \brief 在片段上指定特效索引处插入作用在原始输入上的资源包特效
*  \param fxPackageId 特效资源包ID
*  \param fxIndex 插入特效索引，参见[getRawFxCount()]
*  \return 返回插入的视频特效对象
*  \endif
*  \since 2.20.0
*/
- (NvsVideoFx *)insertRawPackagedFx:(NSString *)fxPackageId fxIndex:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Appends custom video effect on the raw input to the clip.
 *  \param customVideoFxRender User-implemented custom video effect renderer interface.
 *  \return Returns the added video effect object.
 *  \else
 *  \brief 在片段上追加作用在原始输入上的自定义视频特效
 *  \param customVideoFxRender 用户实现的自定义视频特效渲染器接口
 *  \return 返回追加的视频特效对象
 *  \endif
 *  \since 2.20.0
 */
- (NvsVideoFx *)appendRawCustomFx:(id<NvsCustomVideoFxRenderer>)customVideoFxRender;

/*! \if ENGLISH
*  \brief Inserts a custom video effect at the specified effect index on the raw input on the clip.
*  \param customVideoFxRender User-implemented custom video effects renderer interface.
*  \param fxIndex Effect index to insert at.
*  \return Returns the inserted video special effect object.
*  \else
*  \brief 在片段上指定特效索引处插入作用在原始输入上的自定义视频特效
*  \param customVideoFxRender 用户实现的自定义视频特效渲染器接口
*  \param fxIndex 插入特效索引
*  \return 返回插入的视频特效对象
*  \endif
*  \since 2.20.0
*/
- (NvsVideoFx *)insertRawCustomFx:(id<NvsCustomVideoFxRenderer>)customVideoFxRender fxIndex:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Appends the beauty effect on the clip.
 *  \return Returns the appended NvsVideoFx object.
 *  \else
 *  \brief 在片段上追加美颜特效
 *  \return 返回追加的视频特效对象
 *  \endif
 *  \sa insertBeautyFx:
 *  \sa appendPackagedFx:
 *  \sa appendBuiltinFx:
*/
- (NvsVideoFx *)appendBeautyFx;

/*! \if ENGLISH
 *  \brief Inserts the beauty effect at the specified effect index on the clip.
 *  \param fxIndex The specified effect index
 *  \return Returns the inserted NvsVideoFx object.
 *  \else
 *  \brief 在片段上指定特效索引处插入美颜特效
 *  \param fxIndex 指定特效索引
 *  \return 返回插入的视频特效对象
 *  \endif
 *  \sa appendBeautyFx
 *  \sa insertPackagedFx:fxIndex:
 *  \sa insertBuiltinFx:fxIndex:
*/
- (NvsVideoFx *)insertBeautyFx:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Appends the built-in effect on the clip.
 *  \param fxName The effect name,if users get the video effect name, please refer to [getAllBuiltinVideoFxNames()] (@ref NvsStreamingContext::getAllBuiltinVideoFxNames) or [The List of Built-in Effect Name] (\ref FxNameList.md)
 *  \return Returns the appended NvsVideoFx object.
 *  \else
 *  \brief 在片段上追加内嵌式特效
 *  \param fxName 特效名称。获取视频特效名称，请参见[getAllBuiltinVideoFxNames()] (@ref NvsStreamingContext::getAllBuiltinVideoFxNames)或[内建特效名称列表] (\ref FxNameList.md)
 *  \param inPoint 特效的相对于片段的起始时间
 *  \param duration 特效在片段上的持续时间，数值为-1表示特效显示整个片段
 *  \return 返回追加的视频特效对象
 *  \endif
 *  \sa insertBuiltinFx:fxIndex:
 *  \sa appendBeautyFx
 *  \sa appendPackagedFx:
 *  \since 3.0.1
*/
- (NvsVideoFx *)appendBuiltinFx:(NSString *)fxName inPoint:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
 *  \brief Inserts a built-in effect at the specified effect index on the clip.
 *  \param fxName The effect name,if users get the video effect name, please refer to [getAllBuiltinVideoFxNames()] (@ref NvsStreamingContext::getAllBuiltinVideoFxNames) or [The List of Built-in Effect Name] (\ref FxNameList.md)
 *  \param fxIndex The specified effect index
 *  \return Returns the inserted NvsVideoFx object.
 *  \else
 *  \brief 在片段上指定特效索引处插入内嵌式特效
 *  \param fxName 特效名称。获取视频特效名称，请参见[getAllBuiltinVideoFxNames()] (@ref NvsStreamingContext::getAllBuiltinVideoFxNames)或[内建特效名称列表] (\ref FxNameList.md)
 *  \param fxIndex 指定特效索引
 *  \param inPoint 特效的相对于片段的起始时间
 *  \param duration 特效在片段上的持续时间，数值为-1表示特效显示整个片段
 *  \return 返回插入的视频特效对象
 *  \endif
 *  \sa appendBuiltinFx:
 *  \sa insertPackagedFx:fxIndex:
 *  \sa insertBeautyFx:
 *  \since 3.0.1
*/
- (NvsVideoFx *)insertBuiltinFx:(NSString *)fxName fxIndex:(unsigned int)fxIndex inPoint:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
 *  \brief Appends the resource package effect on the clip.
 *  \param fxPackageId The resource package ID of effect
 *  \return Returns the appended NvsVideoFx object.
 *  \else
 *  \brief 在片段上追加资源包特效
 *  \param fxPackageId 特效资源包ID
 *  \param inPoint 特效的相对于片段的起始时间
 *  \param duration 特效在片段上的持续时间，数值为-1表示特效显示整个片段
 *  \return 返回追加的视频特效对象
 *  \endif
 *  \sa appendBeautyFx
 *  \sa appendBuiltinFx:
 *  \sa insertPackagedFx:fxIndex:
*/
- (NvsVideoFx *)appendPackagedFx:(NSString *)fxPackageId inPoint:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
 *  \brief Inserts the resource package effect at the specified effect index on the clip.
 *  \param fxPackageId The resource package ID of effect.
 *  \param fxIndex The specified effect index
 *  \return Returns the inserted NvsVideoFx object.
 *  \else
 *  \brief 在片段上指定特效索引处插入包裹特效
 *  \param fxPackageId 包裹特效Id
 *  \param fxIndex 插入特效索引
 *  \param inPoint 特效的相对于片段的起始时间
 *  \param duration 特效在片段上的持续时间，数值为-1表示特效显示整个片段
 *  \return 返回插入的视频特效对象
 *  \endif
 *  \sa insertBeautyFx:
 *  \sa appendPackagedFx:
 *  \sa insertBuiltinFx:fxIndex:
*/
- (NvsVideoFx *)insertPackagedFx:(NSString *)fxPackageId fxIndex:(unsigned int)fxIndex inPoint:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
 *  \brief Appends the custom video effect on the clip.
 *  \param customVideoFxRender The renderer interface of the custom video effect which users implement
 *  \return Returns the appended NvsVideoFx object.
 *  \else
 *  \brief 在片段上追加自定义视频特效
 *  \param customVideoFxRender 用户实现的自定义视频特效渲染器接口
 *  \param inPoint 特效的相对于片段的起始时间
 *  \param duration 特效在片段上的持续时间，数值为-1表示特效显示整个片段
 *  \return 返回追加的视频特效对象
 *  \endif
 *  \since 3.0.1
*/
- (NvsVideoFx *)appendCustomFx:(id<NvsCustomVideoFxRenderer>)customVideoFxRender inPoint:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
 *  \brief Inserts the custom video effect at the specified effect index on the clip.
 *  \param customVideoFxRender The renderer interface of the custom video effect which users implement
 *  \param fxIndex The specified effect index
 *  \return Returns the inserted NvsVideoFx object.
 *  \else
 *  \brief 在片段上指定特效索引处插入自定义视频特效
 *  \param customVideoFxRender 用户实现的自定义视频特效渲染器接口
 *  \param fxIndex 插入特效索引
 *  \param inPoint 特效的相对于片段的起始时间
 *  \param duration 特效在片段上的持续时间，数值为-1表示特效显示整个片段
 *  \return 返回插入的视频特效对象
 *  \endif
 *  \since 3.0.1
*/
- (NvsVideoFx *)insertCustomFx:(id<NvsCustomVideoFxRenderer>)customVideoFxRender fxIndex:(unsigned int)fxIndex inPoint:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
 *  \brief  Appends built-in effect on the raw input to clips.
 *  \param fxName The effect name. To get the video effect name, please refer to [getAllBuiltinVideoFxNames()] (@ref com.meicam.sdk.NvsStreamingContext.getAllBuiltinVideoFxNames) or [built-in effect name list] (\ref FxNameList.md).
 *  \return Returns the added video effect object.
 *  \else
 *  \brief 在片段上追加作用在原始输入上的内嵌式特效
 *  \param fxName 特效名称。获取视频特效名称，请参见[getAllBuiltinVideoFxNames()] (@ref com.meicam.sdk.NvsStreamingContext.getAllBuiltinVideoFxNames)或[内建特效名称列表] (\ref FxNameList.md)
 *  \param inPoint 特效的相对于片段的起始时间
 *  \param duration 特效在片段上的持续时间，数值为-1表示特效显示整个片段
 *  \return 返回追加的视频特效对象
 *  \endif
 *  \since 3.0.1
 */
- (NvsVideoFx *)appendRawBuiltinFx:(NSString *)fxName inPoint:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
*  \brief Inserts a built-in effect at the specified effect index on the raw input on the clip.
*  \param fxName The effect name. To get the video effect name, please refer to [getAllBuiltinVideoFxNames()] (@ref com.meicam.sdk.NvsStreamingContext.getAllBuiltinVideoFxNames) or [Built-in Effect Name List] (\ref FxNameList.md).
*  \param fxIndex Effect index to insert at.
*  \return Returns the inserted video effect object.
*  \else
*  \brief 在片段上指定特效索引处插入作用在原始输入上的内嵌式特效
*  \param fxName 特效名称。获取视频特效名称，请参见[getAllBuiltinVideoFxNames()] (@ref com.meicam.sdk.NvsStreamingContext.getAllBuiltinVideoFxNames)或[内建特效名称列表]
*  \param fxIndex 插入特效索引
*  \param inPoint 特效的相对于片段的起始时间
*  \param duration 特效在片段上的持续时间，数值为-1表示特效显示整个片段
*  \return 返回插入的视频特效对象
*  \endif
*  \since 3.0.1
*/
- (NvsVideoFx *)insertRawBuiltinFx:(NSString *)fxName fxIndex:(unsigned int)fxIndex inPoint:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
*  \brief Appends package effect on the raw input to the clip.
*  \param fxPackageId Effect resource package ID.
*  \return Returns the added video effect object.
*  \else
*  \brief 在片段上追加作用在原始输入上的资源包特效
*  \param fxPackageId 特效资源包ID
*  \param inPoint 特效的相对于片段的起始时间
*  \param duration 特效在片段上的持续时间，数值为-1表示特效显示整个片段
*  \return 返回追加的视频特效对象
*  \endif
*  \since 3.0.1
*/
- (NvsVideoFx *)appendRawPackagedFx:(NSString *)fxPackageId inPoint:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
*  \brief Inserts package effect at the specified effect index on the raw input on the clip.
*  \param fxPackageId Effect resource package ID.
*  \param fxIndex Effect index to insert at, please refer to [getRawFxCount()].
*  \return Returns the inserted video effect object.
*  \else
*  \brief 在片段上指定特效索引处插入作用在原始输入上的资源包特效
*  \param fxPackageId 特效资源包ID
*  \param fxIndex 插入特效索引，参见[getRawFxCount()]
*  \param inPoint 特效的相对于片段的起始时间
*  \param duration 特效在片段上的持续时间，数值为-1表示特效显示整个片段
*  \return 返回插入的视频特效对象
*  \endif
*  \since 3.0.1
*/
- (NvsVideoFx *)insertRawPackagedFx:(NSString *)fxPackageId fxIndex:(unsigned int)fxIndex inPoint:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
 *  \brief Appends custom video effect on the raw input to the clip.
 *  \param customVideoFxRender User-implemented custom video effect renderer interface.
 *  \return Returns the added video effect object.
 *  \else
 *  \brief 在片段上追加作用在原始输入上的自定义视频特效
 *  \param customVideoFxRender 用户实现的自定义视频特效渲染器接口
 *  \param inPoint 特效的相对于片段的起始时间
 *  \param duration 特效在片段上的持续时间,数值为-1表示特效显示整个片段
 *  \return 返回追加的视频特效对象
 *  \endif
 *  \since 3.0.1
 */
- (NvsVideoFx *)appendRawCustomFx:(id<NvsCustomVideoFxRenderer>)customVideoFxRender inPoint:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
*  \brief Inserts a custom video effect at the specified effect index on the raw input on the clip.
*  \param customVideoFxRender User-implemented custom video effects renderer interface.
*  \param fxIndex Effect index to insert at.
*  \return Returns the inserted video special effect object.
*  \else
*  \brief 在片段上指定特效索引处插入作用在原始输入上的自定义视频特效
*  \param customVideoFxRender 用户实现的自定义视频特效渲染器接口
*  \param fxIndex 插入特效索引
*  \param inPoint 特效的相对于片段的起始时间
*  \param duration 特效在片段上的持续时间，数值为-1表示特效显示整个片段
*  \return 返回插入的视频特效对象
*  \endif
*  \since 3.0.1
*/
- (NvsVideoFx *)insertRawCustomFx:(id<NvsCustomVideoFxRenderer>)customVideoFxRender fxIndex:(unsigned int)fxIndex inPoint:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
 *  \brief Appends the beauty effect on the clip.
 *  \return Returns the appended NvsVideoFx object.
 *  \else
 *  \brief 在片段上追加美颜特效
 *  \param inPoint 特效的相对于片段的起始时间
 *  \param duration 特效在片段上的持续时间，数值为-1表示特效显示整个片段
 *  \return 返回追加的视频特效对象
 *  \endif
 *  \sa insertBeautyFx:
 *  \sa appendPackagedFx:
 *  \sa appendBuiltinFx:
 *  \since 3.0.1
*/
- (NvsVideoFx *)appendBeautyFx:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
 *  \brief Inserts the beauty effect at the specified effect index on the clip.
 *  \param fxIndex The specified effect index
 *  \return Returns the inserted NvsVideoFx object.
 *  \else
 *  \brief 在片段上指定特效索引处插入美颜特效
 *  \param fxIndex 指定特效索引
 *  \param inPoint 特效的相对于片段的起始时间
 *  \param duration 特效在片段上的持续时间，数值为-1表示特效显示整个片段
 *  \return 返回插入的视频特效对象
 *  \endif
 *  \sa appendBeautyFx
 *  \sa insertPackagedFx:fxIndex:
 *  \sa insertBuiltinFx:fxIndex:
 *  \since 3.0.1
*/
- (NvsVideoFx *)insertBeautyFx:(unsigned int)fxIndex inPoint:(int64_t)inPoint duration:(int64_t)duration;


/*! \if ENGLISH
 *  \brief Removes the special effect.
 *  \param fxIndex The effect index
 *  \return Determines whether the removal is successful. YES means that it's successful; NO means it fails.
 *  \else
 *  \brief 移除特效
 *  \param fxIndex 特效索引
 *  \return 判断是否移除成功。返回YES则移除成功，NO则失败。
 *  \endif
 *  \sa removeAllFx
*/
- (BOOL)removeFx:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Remove effect by index on the raw input.
 *  \param fxIndex Special effect index, please refer to[getFxCount()] (@ref com.meicam.sdk.NvsClip.getFxCount).
 *  \return Determines whether the removal is successful. If it returns true, the removal is successful and if it returns false, it fails to remove.
 *  \else
 *  \brief 移除作用在原始输入上的特效
 *  \param fxIndex 特效索引，参见[getRawFxCount()]
 *  \return 判断是否移除成功。返回true则移除成功，false则移除失败
 *  \endif
 *  \since 2.20.0
 */
- (BOOL)removeRawFx:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Remove all the audio effects.
 *  \return Determines whether the removal is successful. YES means that it's successful; NO means it fails.
 *  \else
 *  \brief 移除所有音频特效
 *  \return 判断是否移除成功。返回YES则移除成功，NO则失败。
 *  \endif
 *  \sa removeFx:
*/
- (BOOL)removeAllAudioFx;

/*! \if ENGLISH
 *  \brief Remove all the video effects.
 *  \return Determines whether the removal is successful. YES means that it's successful; NO means it fails.
 *  \else
 *  \brief 移除所有视频特效
 *  \return 判断是否移除成功。返回YES则移除成功，NO则失败。
 *  \endif
 *  \sa removeFx:
*/
- (BOOL)removeAllVideoFx;

/*! \if ENGLISH
 *  \brief Remove all the effects.
 *  \return Determines whether the removal is successful. YES means that it's successful; NO means it fails.
 *  \else
 *  \brief 移除所有特效
 *  \return 判断是否移除成功。返回YES则移除成功，NO则失败。
 *  \endif
 *  \sa removeFx:
*/
- (BOOL)removeAllFx;

/*! \if ENGLISH
 *  \brief Gets the special effect by index.
 *  \param fxIndex The index of the special effect
 *  \return Returns the obtained NvsVideoFx object.
 *  \else
 *  \brief 通过索引获取特效
 *  \param fxIndex 特效索引
 *  \return 返回获取的视频特效对象
 *  \endif
*/
- (NvsVideoFx *)getFxWithIndex:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Gets the number of effects on the raw input on the clip. Note: The effect index on the clip starts from 0.
 *  \return Returns the number of special effects on the clip.
 *  \else
 *  \brief 获取片段上作用在原始输入上的特效数量。注：片段上的特效索引是从0开始
 *  \return 返回片段上的特效数
 *	\endif
 *  \since 2.20.0
 */
- (unsigned int)getRawFxCount;

/*! \if ENGLISH
 *  \brief Gets special effect by index on the raw input.
 *  \param fxIndex Special effect index, please refer to [getRawFxCount()].
 *  \return Returns the obtained video effect object.
 *  \else
 *  \brief 通过索引获取作用在原始输入上的特效
 *  \param fxIndex 特效索引，参见[getRawFxCount()]
 *  \return 返回获取的视频特效对象
 *  \endif
 *  \since 2.20.0
 */
- (NvsVideoFx *)getRawFxByIndex:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Gets ref image fill mode
 *  \return Returns the obtained fill mode object, Fill Mode
 *  \else
 *  \brief 获取有参考尺寸下的填充模式
 *  \return 返回获取的背景模式
 *  \endif
 *  \sa setRefImageFillMode
 *  \since 3.7.0
 */
- (NvsVariantImageFillMode)getRefImageFillMode;

/*! \if ENGLISH
 *  \brief Sets ref image background mode, Fill Mode
 *  \param  mode Fill mode.
 *  \else
 *  \brief 设置有参考尺寸下的填充模式
 *  \param mode 填充模式
 *  \endif
 *  \sa getRefImageFillMode
 *  \since 3.7.0
 */
- (void)setRefImageFillMode:(NvsVariantImageFillMode)variantImageBackgroundMode;

/*! \if ENGLISH
 *  \brief Gets ref image size
 *  \return ref image size
 *  \else
 *  \brief 获取小图模式下参考尺寸
 *  \return 返回小图模式下参考尺寸
 *  \endif
 *  \sa setRefImageSize
 *  \since 3.7.2
 */
- (NvsSize)getRefImageSize;

/*! \if ENGLISH
 *  \brief set ref image size
 *  \param refImageSize Reference size
 *  \else
 *  \brief 设置小图模式下参考尺寸
 *  \param refImageSize 参考尺寸
 *  \endif
 *  \sa getRefImageSize
 *  \since 3.7.2
 */
- (void)setRefImageSize:(NvsSize)refImageSize;

/*! \if ENGLISH
 *  \brief Gets ref image background mode
 *  \return Returns the obtained background mode object, Background Mode (@ref VARIANT_IMAGE_BACKGROUNDMODE)
 *  \else
 *  \brief 获取小图模式下背景填充模式
 *  \return 返回获取的背景模式 (@ref VARIANT_IMAGE_BACKGROUNDMODE)
 *  \endif
 *  \sa setRefImageBackgroundMode
 *  \since 3.4.1
 */
- (NvsSourceBackgroundMode)getRefImageBackgroundMode;

/*! \if ENGLISH
 *  \brief Sets ref image background mode, Background Mode (@ref VARIANT_IMAGE_BACKGROUNDMODE)
 *  \param  mode Background mode.
 *  \else
 *  \brief 设置小图模式下背景模式 (@ref VARIANT_IMAGE_BACKGROUNDMODE)
 *  \param mode 背景模式
 *  \endif
 *  \sa getRefImageBackgroundMode
 *  \since 3.4.1
 */
- (void)setRefImageBackgroundMode:(NvsSourceBackgroundMode)variantImageBackgroundMode;

/*! \if ENGLISH
 *  \brief Gets the ref image background color.
 *  \return Background color
 *  \else
 *  \brief 获取小图模式下背景颜色
 *  \return 背景颜色
 *  \endif
 *  \sa setRefImageBackgroundColor
 *  \since 3.4.1
 */
- (NvsColor)getRefImageBackgroundColor;

/*! \if ENGLISH
 *  \brief Sets the ref image background color.
 *  \param color the ref image background color
 *  \else
 *  \brief 设置小图模式下片段背景颜色
 *  \param color 背景颜色
 *  \endif
 *  \sa getRefImageBackgroundColor
 *  \since 3.4.1
 */
- (void)setRefImageBackgroundColor:(NvsColor *)color;

/*! \if ENGLISH
 *  \brief Gets ref image background blur radius.
 *  \return Returns the obtained background blur radius.
 *  \else
 *  \brief 获取小图模式下背景填充模糊程度
 *  \return 返回获取的背景模式程度
 *  \endif
 *  \sa setRefImageBackgroundBlurRadius
 *  \since 3.4.1
 */
- (float)getRefImageBackgroundBlurRadius;

/*! \if ENGLISH
 *  \brief Sets ref image background blur radius.
 *  \param  Background blur radius.
 *  \else
 *  \brief 设置小图模式下背景模糊程度
 *  \param mode 背景模糊程度
 *  \endif
 *  \sa getRefImageBackgroundBlurRadius
 *  \since 3.4.1
 */
- (void)setRefImageBackgroundBlurRadius:(float)radius;


/*! \if ENGLISH
 *  \brief Gets ref image background blur new mode enable.
 *  \return Returns the obtained background blur new mode enable.
 *  \else
 *  \brief 获取小图模式下背景填充模糊新模式状态
 *  \return 返回获取的背景新模式状态
 *  \endif
 *  \sa getRefImageBackgroundBlurNewModeEnable
 *  \since 3.7.0
 */
- (BOOL)getRefImageBackgroundBlurNewModeEnable;

/*! \if ENGLISH
 *  \brief Sets ref image background blur new mode enable.
 *  \param  Background blur new mode enable.
 *  \else
 *  \brief 设置小图模式下背景模糊新模式
 *  \param mode 背景模糊新模式
 *  \endif
 *  \sa setRefImageBackgroundBlurNewModeEnable
 *  \since 3.7.0
 */
- (void)setRefImageBackgroundBlurNewModeEnable:(BOOL)newModeEnable;


/*! \if ENGLISH
 *  \brief Disable Clip Color Primary Conversion.
 *  \param  Is Clip color primary conversion disabled.
 *  \else
 *  \brief 设置禁用clip色彩基色转换
 *  \param disable clip色彩基色转换是否被禁止
 *  \endif
 *  \sa isClipColorPrimariesConvertDisabled
 *  \since 3.15.4
 */
- (void)disableClipColorPrimariesConvert:(BOOL)disable;

/*! \if ENGLISH
 *  \brief Get the clip's primary color conversion status..
 *  \return Is Clip color primary conversion disabled
 *  \else
 *  \brief 获取clip色彩基色转换状态
 *  \return 返回clip色彩基色转换状态是否被禁止
 *  \endif
 *  \sa isClipColorPrimariesConvertDisabled
 *  \since 3.15.4
 */
- (BOOL)isClipColorPrimariesConvertDisabled;


/*! \if ENGLISH
 *  \brief Update the audio information in the current clip effect.
 *  \return
 *  \else
 *  \brief 更新当前片段特效中携带的音频信息。
 *  \return 无返回值。
 *  \endif
 *  \since 3.8.0
*/
- (void)updateAudioForClipVideoFx;

/*! \if ENGLISH
 *  \brief Gets the property effect of the video clip
 *  \return Returns the obtained NvsVideoFx object.
 *  \else
 *  \brief 获取当前视频片段属性特效
 *  \return 返回获取的视频特效对象
 *  \endif
*/
- (NvsVideoFx *)getPropertyVideoFx;

/*! \if ENGLISH
 *  \brief set the custom property effect of the video clip
 *  \param customVideoFxRender User-implemented custom video effect renderer interface.
 *  \return Returns the obtained NvsVideoFx object.
 *  \else
 *  \brief 设置当前视频片段自定义属性特效
 *  \param customVideoFxRender 用户实现的自定义视频特效渲染器接口
 *  \return 返回获取的视频特效对象
 *  \endif
*/
- (NvsVideoFx *)setCustomPropertyVideoFx:(id<NvsCustomVideoFxRenderer>)customVideoFxRender;

/*!
 *  \if ENGLISH
 *  \brief Turn on special effect rendering based on the original scale of the video clip.
 *  \warning
 *  \param Enable Turn on or not.
 *  \sa IsOriginalRender
 *  \else
 *  \brief 设置属性特效是否有效
 *  \warning 此接口会使setPan:andScan:，setSourceBackgroundMode 和setSourceBackgroundColor接口无效。
 *   如果启用属性特效，可以通过特效中的参数来设置对应效果
 *  \param enable  是否开启
 *  \sa IsOriginalRender
 *  \endif
*/
- (void)enablePropertyVideoFx:(BOOL)enable;

/*! \if ENGLISH
 *  \brief Get the first caption on the clip.
 *  \return Returns the NvsClipCaption object.
 *  \else
 *  \brief 获取片段上的第一个字幕,相对于每个片段上的字幕
 *  \return 返回获取的片段字幕对象
 *  \endif
 *  \sa getLastCaption
 *  \sa addCaption
 *  \since 3.0.1
*/
- (NvsClipCaption *)getFirstCaption;

/*! \if ENGLISH
 *  \brief Get the last caption on the clip.
 *  \return Returns the NvsClipCaption object.
 *  \else
 *  \brief 获取片段上的最后一个字幕,相对于每个片段上的字幕
 *  \return 返回获取的片段字幕对象
 *  \endif
 *  \sa getFirstCaption
 *  \sa addCaption
 *  \since 3.0.1
*/
- (NvsClipCaption *)getLastCaption;

/*! \if ENGLISH
 *  \brief Get the previous caption of the current caption on the Clip
 *  \param caption The current caption on the Clip
 *  \return Returns the NvsClipCaption object.
 *  \else
 *  \brief 获取片段上的当前字幕的前一个字幕，相对于每个片段上的字幕
 *  \param caption 片段上当前字幕对象
 *  \return 返回获取的片段字幕对象
 *  \endif
 *  \sa getNextCaption
 *  \since 3.0.1
*/
- (NvsClipCaption *)getPrevCaption:(NvsClipCaption *)caption;

/*! \if ENGLISH
 *  \brief Get the next caption of the current caption on the Clip
 *  \param caption The current caption on the Clip
 *  \return Returns the NvsClipCaption object.
 *  \else
 *  \brief 获取片段上的当前字幕的前一个字幕，相对于每个片段上的字幕
 *  \param caption 片段上当前字幕对象
 *  \return 返回获取的片段字幕对象
 *  \endif
 *  \sa getPrevCaption
 *  \since 3.0.1
*/
- (NvsClipCaption *)getNextCaption:(NvsClipCaption *)caption;

/*! \if ENGLISH
 *  \brief Get a list of captions based on the position on the Clip.
 *  \param ClipPos The position on the Clip(in micro-second)
 *  \return Returns a list of arrays of captions at the current position。
 *  <br>The sorting rules for the obtained captions list are as follows:
 *  <br>1.When adding, the in points are different, and captions are arranged in the order of the in points;
 *  <br>2.When adding, the in points are the same, and captions are arranged in the order of adding captions.
 *  \else
 *  \brief 根据片段上的位置获得字幕列表，相对于单一的片段
 *  \param ClipPos 片段上的位置（单位微秒）
 *  \return 返回当前位置字幕的List集合
 *  <br>获取的字幕列表排序规则如下：
 *  <br>1.添加时字幕入点不同，按入点的先后顺序排列；
 *  <br>2.添加时字幕入点相同，按添加字幕的先后顺序排列。
 *  \endif
 *  \sa addCaption
 *  \since 3.0.1
*/
- (NSArray *)getCaptionsByClipTimePosition:(int64_t)cliptimePos;

/*! \if ENGLISH
 *  \brief Add a caption on the Clip
 *  \param captionText Text of caption
 *  \param inPoint The in point of the caption on the Clip (in microseconds)
 *  \param duration Caption display duration (in microseconds), -1 indicates that the whole clip is covered.
 *  \param captionStylePackageId Caption style package Id.If it does not exist, you can pass an empty string or null.
 *  \return Returns the NvsClipCaption object.
 *  <br>It will return null in the following situations:
 *  <br>1. No caption function authorization;
 *  <br>2. If inPoint is less than 0 or greater than or equal to the current Clip duration, or duration is not greater than 0.
 *  \else
 *  \brief 在片段上添加字幕,相对于单一的片段
 *  \param captionText 字幕的文字
 *  \param inPoint 字幕在片段上的起点（单位微秒）
 *  \param duration 字幕显示时长（单位微秒）, -1表示铺满整个片段
 *  \param captionStylePackageId 字幕样式包Id，不存在的话，可以传空字符串或者null
 *  \return 返回片段字幕对象
 *  <br>以下情况会返回null：
 *  <br>1.没有字幕功能授权；
 *  <br>2.如果inPoint小于0，或者duration小于等于0并且不为-1。
 *  \endif
 *  \sa removeCaption
 *  \since 3.0.1
*/
- (NvsClipCaption *)addCaption:(NSString *)captionText inPoint:(int64_t)inPoint duration:(int64_t)duration captionStylePackageId:(NSString *)captionStylePackageId;

/*! \if ENGLISH
 *  \brief Add a panorama caption on the Clip
 *  \param captionText Text of caption
 *  \param inPoint The in point of the caption on the Clip (in microseconds)
 *  \param duration Caption display duration (in microseconds), -1 indicates that the whole clip is covered.
 *  \param captionStylePackageId Caption style package Id.If it does not exist, you can pass an empty string or null.
 *  \return Returns the NvsClipCaption object.
 *  <br>It will return null in the following situations:
 *  <br>1. No caption function authorization;
 *  <br>2. If inPoint is less than 0 or greater than or equal to the current Clip duration, or duration is not greater than 0.
 *  \else
 *  \brief 在片段上添加全景图字幕
 *  \param captionText 字幕的文字
 *  \param inPoint 字幕在片段上的入点（单位微秒）
 *  \param duration 字幕的显示时长（单位微秒）, -1表示铺满整个片段
 *  \param captionStylePackageId 字幕样式包Id，不存在的话，可以传空字符串或者null
 *  \return 返回片段字幕对象
 *  <br>以下情况会返回null：
 *  <br>1.没有字幕功能授权；
 *  <br>2.如果inPoint小于0，或者duration小于等于0并且不为-1。
 *  \endif
 *  \since 1.6.0
 *  \sa removeCaption
*/
- (NvsClipCaption *)addPanoramicCaption:(NSString *)captionText inPoint:(int64_t)inPoint duration:(int64_t)duration captionStylePackageId:(NSString *)captionStylePackageId;

   /*! \if ENGLISH
    *  \brief Add a modular caption on the Clip
    *  \param captionText Text of caption
    *  \param inPoint The in point of the caption on the Clip (in microseconds)
    *  \param duration Caption display duration (in microseconds), -1 indicates that the whole clip is covered.
    *  \return Returns the NvsClipCaption object.
    *  <br>It will return null in the following situations:
    *  <br>1. No caption function authorization;
    *  <br>2. If inPoint is less than 0 or greater than or equal to the current Clip duration, or duration is not greater than 0.
    *  \else
    *  \brief 在片段上添加模块字幕
    *  \param captionText 字幕的文字
    *  \param inPoint 字幕在片段上的起点（单位微秒）
    *  \param duration 字幕显示时长（单位微秒）, -1表示铺满整个片段
    *  \return 返回片段字幕对象
    *  <br>以下情况会返回null：
    *  <br>1.没有字幕功能授权；
    *  <br>2.如果inPoint小于0，或者duration小于等于0并且不为-1。
    *  \endif
    *  \sa removeCaption
    */
- (NvsClipCaption *)addModularCaption:(NSString *)captionText inPoint:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
 *  \brief Remove the caption on the Clip.
 *  \param caption Clip caption object which removed
 *  \return Returns the next NvsClipCaption object.
 *  \else
 *  \brief 移除片段上的字幕
 *  \param caption 要移除的片段字幕对象
 *  \return 返回下一个片段字幕对象
 *  \endif
 *  \sa addCaption
 *  \since 3.0.1
*/
- (NvsClipCaption *)removeCaption:(NvsClipCaption *)caption;

/*! \if ENGLISH
 *  \brief Get the first compound caption on the Clip.
 *  \return Returns the compound caption object.
 *  \else
 *  \brief 获取片段上的第一个复合字幕
 *  \return 返回获取的片段复合字幕对象
 *  \endif
 *  \since 3.0.1
 *  \sa getLastCompoundCaption
 *  \sa addCompoundCaption
 */
- (NvsClipCompoundCaption *)getFirstCompoundCaption;

/*! \if ENGLISH
 *  \brief Get the last compound caption on the Clip.
 *  \return Returns the compound caption object.
 *  \else
 *  \brief 获取片段上的最后一个复合字幕，相对于单个的片段上的字幕
 *  \return 返回获取的片段复合字幕对象
 *  \endif
 *  \since 3.0.1
 *   \sa getFirstCompoundCaption
 *  \sa addCompoundCaption
 */
- (NvsClipCompoundCaption *)getLastCompoundCaption;

/*! \if ENGLISH
 *  \brief Get the previous compound caption of the current compound caption on the Clip
 *  \param caption The current compound caption on the Clip
 *  \return Returns the compound caption object.
 *  \else
 *  \brief 获取片段上的当前复合字幕的前一个复合字幕，相对于单个片段上的字幕
 *  \param caption 片段上当前复合字幕对象
 *  \return 返回获取的片段复合字幕对象
 *  \endif
 *  \since 3.0.1
 *  \sa getNextCompoundCaption
 */
- (NvsClipCompoundCaption *)getPrevCompoundCaption:(NvsClipCompoundCaption *)caption;

/*! \if ENGLISH
 *  \brief Get the next compound caption of the current compound caption on the Clip
 *  \param caption The current compound caption on the Clip
 *  \return Returns the compound caption object.
 *  \else
 *  \brief 获取片段上的当前复合字幕的前一个复合字幕，相对于单个片段上的字幕
 *  \param caption 片段上当前复合字幕对象
 *  \return 返回获取的片段复合字幕对象
 *  \endif
 *  \since 3.0.1
 *  \sa getPrevCompoundCaption
*/
- (NvsClipCompoundCaption *)getNextCompoundCaption:(NvsClipCompoundCaption *)caption;

/*! \if ENGLISH
 *  \brief Get a list of compound captions based on the position on the Clip.
 *  \param ClipPos The position on the Clip(in micro-second)
 *  \return Returns a list of compound captions at the current position。
 *  <br>The sorting rules for the obtained captions list are as follows:
 *  <br>1. If the in points are different, captions are sorted in the order of the in points;
 *  <br>2. If the in points are the same, and captions are sorted in the order of compound caption added.
 *  \else
 *  \brief 根据片段上的位置获得复合字幕列表，相对于单个片段上的字幕
 *  \param ClipPos 片段上的复合位置（单位微秒）
 *  \return 返回当前位置复合字幕的列表
 *  <br>获取的字幕列表排序规则如下：
 *  <br>1.如果字幕入点不同，按入点时间排列
 *  <br>2.如果字幕入点相同，按添加字幕的先后顺序排列。
 *  \endif
 *  \since 3.0.1
 *  \sa addCompoundCaption
*/
- (NSArray<NvsClipCompoundCaption*> *)getCompoundCaptionsByClipTimePosition:(int64_t)cliptimePos;

/*! \if ENGLISH
 *  \brief Add a caption on the Clip
 *  \param captionText Text of caption
 *  \param inPoint The in point of the caption on the Clip (in microseconds)
 *  \param duration Caption display duration (in microseconds), -1 indicates that the whole clip is covered.
 *  \param captionStylePackageId Caption style package Id.If it does not exist, you can pass an empty string or null.
 *  \return Returns the NvsClipCaption object.
 *  <br>It will return null in the following situations:
 *  <br>1. No compound caption function authorization;
 *  <br>2. If inPoint is less than 0 or greater than or equal to the current Clip duration, or duration is not greater than 0.
 *  \else
 *  \brief 在片段上添加字幕
 *  \param inPoint 字幕在片段上的起点（单位微秒）
 *  \param duration 字幕显示时长（单位微秒）, -1表示铺满整个片段
 *  \param captionStylePackageId 字幕样式包Id，不存在的话，可以传空字符串或者null
 *  \return 返回片段字幕对象
 *  <br>以下情况会返回null：
 *  <br>1.没有复合字幕功能授权；
 *  <br>2.如果inPoint小于0，或者duration小于等于0并且不为-1。
 *  \endif
 *  \since 3.0.1
 *  \sa removeCompoundCaption
*/
- (NvsClipCompoundCaption *)addCompoundCaption:(int64_t)inPoint
                                          duration:(int64_t)duration
                          compoundCaptionPackageId:(NSString *)compoundCaptionPackageId;

/*! \if ENGLISH
 *  \brief Remove compound caption from the Clip.
 *  \param caption Clip compound caption object which to be removed
 *  \return Returns the next compound caption object.
 *  \else
 *  \brief 移除片段上的复合字幕，相对于单个片段
 *  \param caption 要移除的片段复合字幕对象
 *  \return 返回下一个片段复合字幕对象
 *  \endif
 *  \since 3.0.1
 *  \sa addCompoundCaption
 */
- (NvsClipCompoundCaption *)removeCompoundCaption:(NvsClipCompoundCaption *)caption;

/*! \if ENGLISH
 *  \brief Get the first animated sticker on the Clip.
 *  \return Return the acquired NvsClipAnimatedSticker object.
 *  \else
 *  \brief 获取片段上第一个动画贴纸，相对于单个片段上的动画
 *  \return 返回获取的片段动画贴纸对象
 *  \endif
 *  \sa getLastAnimatedSticker
 *  \sa addAnimatedSticker
 *  \since 3.0.1
*/
- (NvsClipAnimatedSticker *)getFirstAnimatedSticker;

/*! \if ENGLISH
 *  \brief Get the last animated sticker on the Clip.
 *  \return Return the acquired NvsClipAnimatedSticker object.
 *  \else
 *  \brief 获取片段上最后一个动画贴纸，相对于单个片段上的动画贴纸
 *  \return 返回获取的片段动画贴纸对象
 *  \endif
 *  \sa getFirstAnimatedSticker
 *  \since 3.0.1
*/
- (NvsClipAnimatedSticker *)getLastAnimatedSticker;

/*! \if ENGLISH
 *  \brief Get the previous animated sticker of the current animated sticker of the Clip.
 *  \param animatedSticker the current NvsClipAnimatedSticker obejct
 *  \return Return the acquired NvsClipAnimatedSticker object.
 *  \else
 *  \brief 获取片段当前动画贴纸的前一个动画贴纸，相对于单个片段上的动画贴纸
 *  \param animatedSticker 片段动画贴纸对象
 *  \return 返回获取的片段动画贴纸对象
 *  \endif
 *  \sa getNextAnimatedSticker
 *  \since 3.0.1
*/
- (NvsClipAnimatedSticker *)getPrevAnimatedSticker:(NvsClipAnimatedSticker *)animatedSticker;

/*! \if ENGLISH
 *  \brief Get the next animated sticker of the current animated sticker of the Clip.
 *  \param animatedSticker the current NvsClipAnimatedSticker obejct
 *  \return Return the acquired NvsClipAnimatedSticker object.
 *  \else
 *  \brief 获取片段当前动画贴纸的后一个动画贴纸。相对于单个片段上的动画贴纸
 *  \param animatedSticker 片段动画贴纸对象
 *  \return 返回获取的片段动画贴纸对象
 *  \endif
 *  \sa getPrevAnimatedSticker
 *  \since 3.0.1
*/
- (NvsClipAnimatedSticker *)getNextAnimatedSticker:(NvsClipAnimatedSticker *)animatedSticker;

/*! \if ENGLISH
 *  \brief Get an animated sticker list based on the position on the Clip.
 *  \param ClipPos Position on the Clip (in microseconds)
 *  \return Returns a list which holding the current position animated sticker object
 *  <br>The sorting rules for the obtained animated sticker list are as follows:
 *  <br>1.When adding, the in points are different,animated stickers are arranged in the order of the in points;
 *  <br>2.When adding, the in points are the same, they are arranged in the order in which the animation stickers are added.
 *  \else
 *  \brief 根据片段上的位置获得动画贴纸列表，相对于单个片段
 *  \param ClipPos 片段上的位置（单位微秒）
 *  \return 返回保存当前位置动画贴纸对象的数组
 *  <br>获取的动画贴纸列表排序规则如下：
 *  <br>1.添加时入点不同，按入点的先后顺序排列；
 *  <br>2.添加时入点相同，按添加动画贴纸的先后顺序排列。
 *  \endif
 *  \sa addAnimatedSticker
 *  \since 3.0.1
*/
- (NSArray *)getAnimatedStickersByClipTimePosition:(int64_t)cliptimePos;

/*! \if ENGLISH
 *  \brief Add a animated sticker on the Clip.
 *  \param inPoint The in point of the animated sticker on the Clip (in microseconds)
 *  \param duration The duration of the animation sticker which displayed (in microseconds), -1 indicates that the whole clip is covered.
 *  \param animatedStickerPackageId Animated sticker package Id
 *  \return Return the NvsClipAnimatedSticker object.
 *  <br>It will return null in the following situations:
 *  <br>1. No animated sticker function authorization;
 *  <br>2. The animatedStickerPackageId is empty or null;
 *  <br>3. The animatedSticker has not install successed;
 *  <br>4. If inPoint is less than 0 or greater than or equal to the current Clip duration, or duration is not greater than 0.
 *  \else
 *  \brief 在片段上添加动画贴纸
 *  \param inPoint 动画贴纸在片段上的入点（单位微秒）
 *  \param duration 动画贴纸的显示时长（单位微秒）, -1表示铺满整个片段
 *  \param animatedStickerPackageId 动画贴纸包Id
 *  \return 返回片段动画贴纸对象
 *  <br>以下情况会返回null：
 *  <br>1.没有动画贴纸功能授权；
 *  <br>2.animatedStickerPackageId参数为空字符串或者null；
 *  <br>3.该动画贴纸包没有安装成功；
 *  <br>4.如果inPoint小于0，或者duration小于等于0并且不为-1。
 *  \endif
 *  \sa removeAnimatedSticker
 *  \since 3.0.1
*/
- (NvsClipAnimatedSticker *)addAnimatedSticker:(int64_t)inPoint duration:(int64_t)duration animatedStickerPackageId:(NSString*)animatedStickerPackageId;

/*! \if ENGLISH
 *  \brief Add a panorama animation sticker on the Clip.
 *  \param inPoint The in point of the animated sticker on the Clip (in microseconds)
 *  \param duration The duration of the animation sticker which displayed (in microseconds), -1 indicates that the whole clip is covered.
 *  \param animatedStickerPackageId Animated sticker package Id
 *  \return Return the NvsClipAnimatedSticker object.
 *  <br>It will return null in the following situations:
 *  <br>1. No animated sticker function authorization or no panoramic function authorization;
 *  <br>2. The animatedStickerPackageId is empty or null;
 *  <br>3. The animatedSticker has not install successed;
 *  <br>4. If inPoint is less than 0 or greater than or equal to the current Clip duration, or duration is not greater than 0.
 *  \else
 *  \brief 在片段上添加全景图动画贴纸
 *  \param inPoint 动画贴纸在片段上的起点（单位微秒）
 *  \param duration 动画贴纸的显示时长（单位微秒）, -1表示铺满整个片段
 *  \param animatedStickerPackageId 动画贴纸资源包ID
 *  \return 返回片段动画贴纸对象
 *  <br>以下情况会返回null：
 *  <br>1.没有动画贴纸功能授权或者没有全景编辑功能授权；
 *  <br>2.animatedStickerPackageId参数为空字符串或者null；
 *  <br>3.该动画贴纸包没有安装成功；
 *  <br>4.如果inPoint小于0，或者duration小于等于0并且不为-1。
 *  \endif
 *  \since 3.0.1
 *  \sa removeAnimatedSticker
*/
- (NvsClipAnimatedSticker *)addPanoramicAnimatedSticker:(int64_t)inPoint duration:(int64_t)duration animatedStickerPackageId:(NSString*)animatedStickerPackageId;

/*! \if ENGLISH
 *  \brief Add a custom animated sticker on the Clip.
 *  \param inPoint The in point of custom animated sticker on the Clip (in microseconds)
 *  \param duration The duration of custom animation sticker which displayed (in microseconds), -1 indicates that the whole clip is covered.
 *  \param animatedStickerPackageId Animated sticker package Id
 *  \param customImagePath Path of custom animated sticker image(It can be a jpg, png image, or a dynamic caf format image supported by Meishe sdk)
 *  \return Return the NvsClipAnimatedSticker object.
 *  <br>It will return null in the following situations:
 *  <br>1. No animated sticker function authorization;
 *  <br>2. The animatedStickerPackageId is empty or null;
 *  <br>3. The animatedSticker has not install successed;
 *  <br>4. If inPoint is less than 0 or greater than or equal to the current Clip duration, or duration is not greater than 0.
 *  <br>Note: If the return value is not null, you still cannot see the sticker effect, you need to check whether the customImagePath actually exists.
 *  \else
 *  \brief 在片段上添加自定义动画贴纸
 *  \param inPoint 自定义动画贴纸在片段上的入点（单位微秒）
 *  \param duration 自定义动画贴纸的显示时长（单位微秒）, -1表示铺满整个片段
 *  \param animatedStickerPackageId 自定义动画贴纸包Id
 *  \param customImagePath 自定义动画贴纸图像路径（可以是jpg、png图像，或者美摄sdk内部支持的动态caf格式图像）
 *  \return 返回片段自定义动画贴纸对象
 *  <br>以下情况会返回null：
 *  <br>1.没有动画贴纸功能授权；
 *  <br>2.animatedStickerPackageId参数为空字符串或者null；
 *  <br>3.该动画贴纸包没有安装成功；
 *  <br>4.如果inPoint小于0，或者duration小于等于0并且不为-1。
 *  <br>注意：如果返回值非空，依旧看不到贴纸效果，需要检查customImagePath是否真实存在
 *  \endif
 *  \sa removeAnimatedSticker
 *  \since 3.0.1
*/
- (NvsClipAnimatedSticker *)addCustomAnimatedSticker:(int64_t)inPoint duration:(int64_t)duration animatedStickerPackageId:(NSString*)animatedStickerPackageId customImagePath:(NSString*)customImagePath;

/*! \if ENGLISH
 *  \brief Add a a custom panorama animated sticker on the Clip.
 *  \param inPoint The in point of custom animated sticker on the Clip (in microseconds)
 *  \param duration The duration of custom animation sticker which displayed (in microseconds), -1 indicates that the whole clip is covered.
 *  \param animatedStickerPackageId Animated sticker package Id
 *  \param customImagePath Path of custom animated sticker image
 *  \return Return the NvsClipAnimatedSticker object.
 *  <br>It will return null in the following situations:
 *  <br>1. No animated sticker function authorization or no panoramic function authorization;
 *  <br>2. The animatedStickerPackageId is empty or null;
 *  <br>3. The animatedSticker has not install successed;
 *  <br>4. If inPoint is less than 0 or greater than or equal to the current Clip duration, or duration is not greater than 0.
 *  <br>Note: If the return value is not null, you still cannot see the sticker effect, you need to check whether the customImagePath actually exists.
 *  \else
 *  \brief 在片段上添加自定义全景图动画贴纸
 *  \param inPoint 动画贴纸在片段上的起点（单位微秒）
 *  \param duration 动画贴纸的显示时长（单位微秒）, -1表示铺满整个片段
 *  \param animatedStickerPackageId 动画贴纸资源包ID
 *  \param customImagePath 自定义动画贴纸图像路径（可以是jpg、png图像，或者美摄sdk内部支持的动态caf格式图像）
 *  \return 返回片段动画贴纸对象
 *  <br>以下情况会返回null：
 *  <br>1.没有动画贴纸功能授权或者没有全景编辑功能授权；
 *  <br>2.animatedStickerPackageId参数为空字符串或者null；
 *  <br>3.该动画贴纸包没有安装成功；
 *  <br>4.如果inPoint小于0，或者duration小于等于0并且不为-1。
 *  <br>注意：如果返回值非空，依旧看不到贴纸效果，需要检查customImagePath是否真实存在
 *  \endif
 *  \since 3.0.1
 *  \sa removeAnimatedSticker
*/
- (NvsClipAnimatedSticker *)addCustomPanoramicAnimatedSticker:(int64_t)inPoint duration:(int64_t)duration animatedStickerPackageId:(NSString*)animatedStickerPackageId customImagePath:(NSString*)customImagePath;

/*! \if ENGLISH
 *  \brief Remove an animated sticker on the Clip.
 *  \param animatedSticker The NvsClipAnimatedSticker object which will be removed
 *  \return Return the next NvsClipAnimatedSticker object.
 *  \else
 *  \brief 移除片段上的动画贴纸
 *  \param animatedSticker 要移除的动画贴纸对象
 *  \return 返回下一个片段动画贴纸对象
 *  \endif
 *  \since 3.0.1
 *  \sa addAnimatedSticker
*/
- (NvsClipAnimatedSticker *)removeAnimatedSticker:(NvsClipAnimatedSticker *)animatedSticker;

/*!
 *  \if ENGLISH
 *  \brief Gets whether the original scale rendering mode is turned on.
 *  \return Turn on or not.
 *  \sa setEnableOriginalRender
 *  \else
 *  \brief 获取是否开启了原始比例渲染的模式
 *  \return 返回是否开启
 *  \sa enablePropertyEffect
 *  \endif
*/
- (BOOL)isPropertyVideoFxEnabled;

/*!
 *  \if ENGLISH
 *  \brief Sets whether the video is decoded using software.
 *  \sa isSoftWareDeocedUsed
 *  \else
 *  \brief 设置视频是否使用软件解码
 *  \sa isSoftWareDeocedUsed
 *  \endif
*/
- (void)setSoftWareDecoding:(BOOL)softwareUsed;

/*!
 *  \if ENGLISH
 *  \brief Sets whether the video is decoded using software.
 *  \sa setSoftWareDecoding:
 *  \return Returns whether the acquired video is decoded using software.
 *  \else
 *  \brief 获取视频是否使用软件解码
 *  \return 返回获取的视频是否使用软件解码
 *  \sa setSoftWareDecoding:
 *  \endif
*/
- (BOOL)isSoftWareDeocedUsed;


@end
