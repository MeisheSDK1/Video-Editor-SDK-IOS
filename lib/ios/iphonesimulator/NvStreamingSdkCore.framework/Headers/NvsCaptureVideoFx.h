//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2017. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jan 18. 2017
//   Author:        Meishe video team
//================================================================================

#pragma once

#import "NvsFx.h"
#import <CoreGraphics/CGGeometry.h>


/*! \if ENGLISH
 *  \brief The type of the captured video effect
 *  \else
 *  \brief 采集视频特效类型
 *  \endif
*/
typedef enum {
    NvsCaptureVideoFxType_Builtin = 0,    //!< \if ENGLISH The type of built-in \else 内建采集类型 \endif
    NvsCaptureVideoFxType_Package,        //!< \if ENGLISH The type of package \else 包裹采集类型 \endif
    NvsCaptureVideoFxType_Custom          //!< \if ENGLISH The type of custom \else 自定义采集类型 \endif
} NvsCaptureVideoFxType;

/*! \if ENGLISH
 *  \brief The captured video effect
 *
 *  The captured video effect is an effect that it is applied when videos capture. After obtaining a Streaming Context, users can add or remove multiple captured video effects in built-in, package, and beauty modes.
 *  \warning In the NvsCaptureVideoFx class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 采集视频特效
 *
 *  采集视频特效是一种应用在视频采集时的特效。获取流媒体上下文(Streaming Context)实例后，可按内建方式，包裹方式，美颜方式来添加或移除多个采集视频特效。
 *  \warning NvsCaptureVideoFx类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsCaptureVideoFx : NvsFx

@property (readonly) NvsCaptureVideoFxType captureVideoFxType;  //!< \if ENGLISH The type of the captured video effect. \else 采集视频特效类型 \endif
@property (readonly) NSString *bultinCaptureVideoFxName;        //!< \if ENGLISH The name of the build-in captured video effect. If it is not a build-in capture video effect, return nil. \else 内嵌采集视频特效名字。如果不是内嵌采集视频特效返回nil \endif
@property (readonly) NSString *captureVideoFxPackageId;         //!< \if ENGLISH The ID of the package captured video effect. If it is not a package video effect, return nil. \else 采集视频特效资源包ID。如果不是资源包采集视频特效返回nil \endif
@property (readonly) unsigned int index;                        //!< \if ENGLISH The index of the video effect \else 视频特效索引 \endif

@property (readonly) int64_t offsetPoint;         //!< \if ENGLISH Get caption's offset time. \else 特效偏移时间（单位微秒） \endif \since 3.4.0
@property (readonly) int64_t duration;         //!< \if ENGLISH Get the duration of the caption (in microseconds). \else 特效的持续时间（单位微秒） \endif \since 3.4.0

/*! \if ENGLISH
 *  \brief Converts the captured screen coordinates to the particle system coordinates.
 *  \param imageWidth Image width
 *  \param imageHeight Image height
 *  \param ptImage the timeline coordinates
 *  \return Returns the transformed particle system coordinates(CGPoint).If ImageWidth or ImageHeight is less than 1, then ptImage is returned directly.
 *  \else
 *  \brief 将采集画面坐标转换为粒子系统坐标
 *  \param imageWidth 采集画面宽度
 *  \param imageHeight 采集画面高度
 *  \param ptImage 时间线坐标
 *  \return 返回转换后的粒子系统坐标CGPoint。如果imageWidth或者imageHeight小于1，则直接返回ptImage。
 *  \endif
 *  \since 2.3.1
*/
- (CGPoint)mapPointFromImageCoordToParticleSystemCoord:(int)imageWidth withHeight:(int)imageHeight withPtImage:(CGPoint)ptImage;

/*! \if ENGLISH
 *  \brief Changes the offset of the fx.
 *  The offset time is the fx time relative to the time when the caption was added.
 *  \param newInPoint The new offset of the fx (in microseconds).
 *  \return Returns the offset of the fx (in microseconds).
 *  \else
 *  \brief 改变特效的相对偏移时间
 *  \param newInPoint 新的相对偏移时间（单位微秒）
 *  \return 返回新的相对偏移时间（单位微秒）
 *  \endif
 *  \since 3.4.0
 */
- (int64_t)changeOffsetPoint:(int64_t)newOffset;

/*! \if ENGLISH
 *  \brief Changes the duration of the fx.
 *  \param newOutPoint The new expected duration of the fx on the timeline (in microseconds).
 *  \return Returns the out-point of the fx on the timeline (in microseconds).
 *  \else
 *  \brief 改变特效持续时间
 *  \param newOutPoint 特效新的期望持续时间（单位微秒）
 *  \return 返回特效新的持续时间（单位微秒）
 *  \endif
 *  \since 3.4.0
 */
- (int64_t)changeDuration:(int64_t)newOutPoint;

/*! \if ENGLISH
*  \brief Set start time of the fx.
*  \param startTime The start time(in microseconds).
*  \else
*  \brief 设置特效的起始时间
*  \param startTime 起始时间
*  \endif
*  \since 3.4.0
*/
- (void)setStartTime:(int64_t)startTime;

/*! \if ENGLISH
*  \brief Reset start time of the fx.
*  \else
*  \brief 重置特效的起始时间
*  \endif
*  \since 3.4.0
*/
- (void)resetStartTime;

@end
