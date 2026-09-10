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
#pragma once

#import "NvsFx.h"
#include <CoreGraphics/CGGeometry.h>

/*! \anchor VIDEOFX_TYPE */
/*!
 *  \if ENGLISH
 *   @name Video effects type
 *  \else
 *   @name 视频特效类型
 *  \endif
 */
//!@{
typedef enum {
    NvsVideoFxType_Builtin = 0,
    NvsVideoFxType_Package,
    NvsVideoFxType_Custom
} NvsVideoFxType;
//!@}

/*! \if ENGLISH
 *  \brief Video effect
 *
 *  The video effect is a special effect that display on the video clip, which can change the overall or partial color, brightness, transparency, etc. of the video image, so that the video can show a special effect.
 *  On the Video Clip, users can add, remove, and get multiple video effects.
 *  \warning In the NvsVideoFx class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 视频特效
 *
 *  视频特效是显示在视频片段上的特效，能够改变视频图像整体或者局部的颜色、亮度、透明度等，使视频显示出特殊的效果。在视频片段(Video Clip)上，可以添加、移除、获取多个视频特效。
 *  \warning NvsVideoFx类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsVideoFx : NvsFx

@property (readonly) NvsVideoFxType videoFxType;    //!< \if ENGLISH The type of the video effect. \else 视频特效类型 \endif
@property (readonly) NSString *bultinVideoFxName;   //!< \if ENGLISH The name of the built-in video effect. If it's not a built-in video effect, return nil.\else 内嵌视频特效名字。如果不是内嵌视频特效，返回nil \endif
@property (readonly) NSString *videoFxPackageId;    //!< \if ENGLISH The ID of the video effect resource package. If it's not a resource package video effect, return nil. \else 视频特效资源包ID。如果不是资源包视频特效，返回nil \endif
@property (readonly) unsigned int index;            //!< \if ENGLISH The index of the Video effect. \else 视频特效索引 \endif


/*! \if ENGLISH
 *  \brief Get the in-point of the fx on the Clip.
 *  \return The in-point of the fx on the Clip (in microseconds).
 *  \else
 *  \brief 视频特效在片段上显示的入点,相对于每个片段的时间段，以当前片段的起始时间为时间起始点。
 *  \return 视频特效在片段上显示的入点（单位微秒）
 *  \endif
 *  \sa getOutPoint
 *  \sa changeInPoint
 *  \since 3.0.1
 */

@property (readonly) int64_t inPoint;

/*! \if ENGLISH
 *  \brief The out-point of the fx on the Clip.
 *  \return The out-point of the fx on the Clip (in microseconds).
 *  \else
 *  \brief 视频特效在片段显示上的出点,相对于每个片段的时间段，以当前片段的起始时间为时间起始点。
 *  \return 视频特效在片段显示上的出点（单位微秒）
 *  \endif
 *  \sa getInPoint
 *  \sa changeOutPoint
 *  \since 3.0.1
 */
@property (readonly) int64_t outPoint;

 /*! \if ENGLISH
  *  \brief Changes the in-point of the fx on the Clip.
  *  \param newInPoint The new in-point of the fx on the timeline (in microseconds).
  *  \return Returns the in-point of the fx on the Clip (in microseconds).
  *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change](\ref EngineChange.md).
  *  \else
  *  \brief 改变视频特效在片段上显示的入点,相对于每个片段的时间段，以当前片段的起始时间为时间起始点。
  *  \param newInPoint 视频特效在片段上的新的入点（单位微秒）
  *  \return 返回视频特效在片段上的显示的入点（单位微秒）
  *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
  *  \endif
  *  \sa changeOutPoint
  *  \sa getInPoint
  *  \sa movePosition
  *  \since 3.0.1
  */
- (int64_t)changeInPoint:(int64_t)newInPoint;

/*! \if ENGLISH
*  \brief Changes the out-point of the fx on the Clip.
*  \param newOutPoint The new out-point of the fx on the Clip (in microseconds).
*  \return Returns the out-point of the fx on the Clip (in microseconds).
*  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change].(\ref EngineChange.md).
*  \else
*  \brief 改变视频特效在片段上显示的出点,相对于每个片段的时间段，以当前片段的起始时间为时间起始点。
*  \param newOutPoint 视频特效在时间线上的新的出点（单位微秒）
*  \return 返回视频特效在片段上显示的出点（单位微秒）
*  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
*  \endif
*  \sa changeInPoint
*  \sa getOutPoint
*  \sa movePosition
*  \since 3.0.1
*/
- (int64_t)changeOutPoint:(int64_t)newOutPoint;

 /*! \if ENGLISH
  *  \brief Changes the display position of the fx on the Clip (the in and out points are offset from the offset value at the same time).
  *  \param offset Offset value for in and out points changes (in microseconds).
  *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change] (\ref EngineChange.md).
  *  \else
  *  \brief 改变视频特效在片段上的显示位置(入点和出点同时偏移offset值),相对于每个片段的时间段，以当前片段的起始时间为时间起始点。
  *  \param offset 入点和出点改变的偏移值（单位微秒）
  *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
  *  \endif
  *  \sa changeInPoint
  *  \sa changeOutPoint
  *  \since 3.0.1
  */
- (void)movePosition:(int64_t)offset;

/*! \if ENGLISH
 *  \brief 将时间线坐标转换为粒子系统坐标
 *  \param ptCononical 时间线坐标
 *  \return 返回转换后的粒子系统坐标PointF对象
 *  \else
 *  \brief Converts timeline coordinates to particle system coordinates.
 *  \param ptCononical Timeline coordinates.
 *  \return Returns the transformed PointF object in particle system coordinates.
 *  \endif
 *  \since 1.16.0
 */
- (CGPoint)mapPointFromCanonicalToParticleSystem:(CGPoint)ptCononical;

/*! \if ENGLISH
 *  \brief Set the fx in and out point to absolute time
 *  \param enable switch checker
 *  \else
 *  \brief 设置特效入出点为绝对时间。
 *  \param enable 检测开关
 *  \endif
 *  \since 3.2.0
 */
- (void)setAbsoluteTimeUsed:(bool)enable;

/*! \if ENGLISH
 *  \brief Get whether the fx in and out point is absolute time
 *  \return Returns a boolean value. true for yes, false for no.
 *  \else
 *  \brief 获取特效入出点是否为绝对时间。
 *  \return 返回一个布尔值，true表示是，false表示否
 *  \endif
 *  \since 3.2.0
 */
- (bool)getAbsoluteTimeUsed;

@end

