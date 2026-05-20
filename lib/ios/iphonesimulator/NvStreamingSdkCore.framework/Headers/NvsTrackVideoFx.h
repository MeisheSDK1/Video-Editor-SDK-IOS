//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2017. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jun 17. 2017
//   Author:        Meishe video team
//================================================================================
#pragma once

#import "NvsFx.h"
#include <CoreGraphics/CGGeometry.h>

/*! \if ENGLISH
 *  \brief The type of track video effect.
 *  \else
 *  \brief 轨道视频特效类型
 *  \endif
*/
typedef enum {
    NvsTrackVideoFxType_Builtin = 0,
    NvsTrackVideoFxType_Package,
    NvsTrackVideoFxType_Custom
} NvsTrackVideoFxType;


/*! \if ENGLISH
 *  \brief Track video effect
 *  \warning In the NvsTrackVideoFx class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 轨道视频特效
 *  \warning NvsTrackVideoFx类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsTrackVideoFx : NvsFx

@property (readonly) NvsTrackVideoFxType trackVideoFxType;  //!< \if ENGLISH The type of track video effect. \else 时间线视频特效类型 \endif
@property (readonly) NSString *bultinTrackVideoFxName;         //!< \if ENGLISH The name of the built-in video effect on the track. If it's not a built-in video effect on the track, it returns nil. \else 内嵌时间线视频特效名字。如果不是内嵌时间线视频特效返回nil \endif
@property (readonly) NSString *trackVideoFxPackageId;          //!< \if ENGLISH The resource package ID of the video effect on the track. If it's not a resource package video effect on the track, it returns nil. \else 时间线视频特效资源包ID。如果不是资源包时间线视频特效返回nil \endif
@property (readonly) int64_t inPoint;                             //!< \if ENGLISH The in point of the track video effect on the track (in microseconds). \else 时间线视频特效在时间线上的入点（单位微秒） \endif
@property (readonly) int64_t outPoint;                            //!< \if ENGLISH The out point of the track video effect on the track (in microseconds). \else 时间线视频特效在时间线上的出点（单位微秒） \endif

/*! \if ENGLISH
 *  \brief Changes the in point of the track video effect on the track.
 *  \param newInPoint The new in point of the track video effect on the track (in microseconds)
 *  \return Returns the final in point value of the track video effect on the track (in microseconds).
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 改变轨道视频特效在时间线上的入点
 *  \param newInPoint 轨道特效在时间线上的新的入点（单位微秒）
 *  \return 返回轨道视频特效在时间线上最终的入点值（单位微秒）
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa changeOutPoint:
 *  \sa movePosition:
 *  \since 2.15.0
*/
- (int64_t)changeInPoint:(int64_t)newInPoint;

/*! \if ENGLISH
 *  \brief Changes the out point of the track video effects on the track.
 *  \param newOutPoint The new out point of the track video effect on the track (in microseconds)
 *  \return Returns the final out point value of the track video effect on the track (in microseconds).
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 改变轨道视频特效在轨道上的出点
 *  \param newOutPoint 轨道视频特效在轨道上的新的出点（单位微秒）
 *  \return 返回轨道视频特效在时间线最终的出点值（单位微秒）
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa changeInPoint:
 *  \sa movePosition:
 *  \since 2.15.0
*/
- (int64_t)changeOutPoint:(int64_t)newOutPoint;

/*! \if ENGLISH
 *  \brief Changes the position of the track video effect on the track (the in and out points move the value of "offset" at the same time).
 *  \param offset The offset value (in microseconds)
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 改变轨道视频特效在轨道上的位置(入点和出点同时偏移offset值)
 *  \param offset 偏移值（单位微秒）
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa changeInPoint:
 *  \sa changeOutPoint:
 *  \since 2.15.0
*/
- (void)movePosition:(int64_t)offset;

/*! \if ENGLISH
 *  \brief Converts the track coordinates to the particle system coordinates.
 *  \param ptCononical track coordinates
 *  \return Returns the CGPoint object of the particle system coordinate after transforming.
 *  \else
 *  \brief 将轨道坐标转换为粒子系统坐标
 *  \param ptCononical 时间线坐标
 *  \return 返回转换后的粒子系统坐标CGPoint
 *  \endif
 *  \since 2.15.0
*/
- (CGPoint)mapPointFromCanonicalToParticleSystem:(CGPoint)ptCononical;


/*! \if ENGLISH
 *  \brief Set the sticker Z value.The higher the Z value, the higher the sticker is.
 *  \param value Z value
 *  \else
 *  \brief 设置轨道特效Z值。Z值越大，轨道特效越处于上层
 *  \param value Z值
 *  \endif
 *  \since 1.10.0
 */
- (void)setZValue:(float)value;

/*! \if ENGLISH
 *  \brief Get the sticker Z value.
 *  \return Return sticker Z value.
 *  \else
 *  \brief 获取轨道特效Z值
 *  \return 返回轨道特效Z值
 *  \endif
 *  \since 1.10.0
 */
- (float)getZValue;

@end

