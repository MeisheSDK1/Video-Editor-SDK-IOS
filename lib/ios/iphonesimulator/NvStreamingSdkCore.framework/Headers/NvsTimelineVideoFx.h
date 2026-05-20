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

/*! \anchor TIMELINE_VIDEOFX_TYPE */
/*!
 *  \if ENGLISH
 *   @name Timeline video effect type.
 *  \else
 *   @name 时间线视频特效类型
 *  \endif
 */
typedef enum {
    NvsTimelineVideoFxType_Builtin = 0,  //!< \if built-in video effect type \else 内建视频特效类型 \endif
    NvsTimelineVideoFxType_Package,      //!< \if package video effect type \else 包裹视频特效类型 \endif
    NvsTimelineVideoFxType_Custom        //!< \if custom video effect type \else 自定义视频特效类型 \endif
} NvsTimelineVideoFxType;

/*! \if ENGLISH
 *  \brief Timeline video effect
 *  Timeline Video Effect is a video effect applied to a Timeline instance.
 *  Timeline video effects are divided into three types: built-in effects, packaged effects and custom effects.
 *  Built-in effects are integrated into the SDK and can be used without authorization. Packaged effects are the integration of effect resources into effect packages. Each effect package has its own license file and must be installed before it can be used. For details, please refer to [Installation of effect package] (\ref  assetsPackageInstall.md).
 *  Custom effects are effects that the user writes code to implement.
 *  Timeline video effect contains in-point and out-point, by which we can specify the position and duration of the effect on the timeline. The in-point must be smaller than the out-point, and they are both in microseconds.
 *  \warning In the NvsTimelineVideoFx class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 时间线视频特效
 *  时间线视频特效是作用于时间线实例上的视频特效。
 *  时间线视频特效分为內建特效、包裹特效和自定义特效三种类型。
 *  內建特效是集成在sdk内部的，不需要授权即可直接使用。包裹特效是将特效资源整合成了特效包，每个特效包都有其一一对应的授权文件，并且要先安装再使用，具体情况请参见[素材包安装] (\ref EngineChange.md)
 *  自定义特效是用户通过编写代码实现的特效
 *  时间线视频特效包含特效入点和出点，通过入点和出点我们可以指定特效作用于时间线的位置和长度，入点要小于出点，单位为微秒。
 *  时间线视频特效允许叠加，渲染顺序通过预设Z值控制。
 *  \warning NvsTimelineVideoFx类中，所有public API都在UI线程使用！！！
 *  \endif
 */

NVS_EXPORT @interface NvsTimelineVideoFx : NvsFx

@property (readonly) NvsTimelineVideoFxType timelineVideoFxType;  //!< \if ENGLISH The type of timeline video effect. \else 时间线视频特效类型 \endif
@property (readonly) NSString *bultinTimelineVideoFxName;         //!< \if ENGLISH The name of the built-in video effect on the timeline. If it's not a built-in video effect on the timeline, it returns nil. \else 内嵌时间线视频特效名字。如果不是内嵌时间线视频特效返回nil \endif
@property (readonly) NSString *timelineVideoFxPackageId;          //!< \if ENGLISH The resource package ID of the video effect on the timeline. If it's not a resource package video effect on the timeline, it returns nil. \else 时间线视频特效资源包ID。如果不是资源包时间线视频特效返回nil \endif
@property (readonly) int64_t inPoint;                             //!< \if ENGLISH The in point of the timeline video effect on the timeline (in microseconds). \else 时间线视频特效在时间线上的入点（单位微秒） \endif
@property (readonly) int64_t outPoint;                            //!< \if ENGLISH The out point of the timeline video effect on the timeline (in microseconds). \else 时间线视频特效在时间线上的出点（单位微秒） \endif

/*! \if ENGLISH
 *  \brief Change the in-point of the timeline video effect on the timeline.
 *  When the new in-point does not conform to the established rules, the final return in-point may be different from the new in-point value.
 *  Such as the new in-point is less than 0, the new in-point value is greater than the timeline duration, or the new in-point is greater than the out-point.
 *  \param newInPoint The new in-point of the video effect on the timeline (in microseconds).
 *  \return Returns the final in-point value of the timeline video effect on the timeline (in microseconds).
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change] (\ref EngineChange.md).
 *  \else
 *  \brief 改变时间线视频特效在时间线上的入点
 *  当设置的入点值不符合既定规则时最终返回入点值有可能与设置的入点值不同，比如新的入点值小于0，新的入点值大于时间线长度或者新的入点值大于出点值。
 *  \param newInPoint 时间线特效在时间线上的新的入点（单位微秒）
 *  \return 返回时间线视频特效在时间线上最终的入点值（单位微秒
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
 *  \endif
 *  \sa changeOutPoint
 *  \sa movePosition
 */
- (int64_t)changeInPoint:(int64_t)newInPoint;

/*! \if ENGLISH
 *  \brief Change the out-point of the timeline video effect on the timeline.
 *  When the new out-point does not conform to the established rules, the final return out-point may be different from the new out-point value.
 *  Such as the new out-point is less than 0, the new out-point value is greater than the timeline duration, or the new out-point is less than the in-point.
 *  \param newOutPoint The new out-point of the animated sticker on the timeline (in microseconds).
 *  \return Returns the final out-point value of the timeline video effect on the timeline (in microseconds).
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change]  (\ref EngineChange.md).
 *  \else
 *  \brief 改变时间线视频特效在时间线上的出点
 *  当设置的出点值不符合既定规则时最终返回出点值有可能与设置的出点值不同，比如新的出点值小于0，新的出点值大于时间线长度或者新的出点值小于入点值。
 *  \param newOutPoint 时间线视频特效在时间线上的新的出点（单位微秒）
 *  \return 返回时间线视频特效在时间线最终的出点值（单位微秒）
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
 *  \endif
 *  \sa changeInPoint
 *  \sa movePosition
 */
- (int64_t)changeOutPoint:(int64_t)newOutPoint;

/*! \if ENGLISH
 *  \brief Changes the position of the timeline video effect on the timeline (the in and out points translate the offset value at the same time).
 *  \param offset Offset value for in and out points (in microseconds).
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change]   (\ref EngineChange.md).
 *  \else
 *  \brief 改变时间线视频特效在时间线上的位置(入点和出点同时偏移offset值)
 *  \param offset 入点和出点改变的偏移值（单位微秒）
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
 *  \endif
 *  \sa changeInPoint
 *  \sa changeOutPoint
 */
- (void)movePosition:(int64_t)offset;

/*! \if ENGLISH
 *  \brief Sets video effect Z value.
 *  The Z value determines the rendering order of the effects. The higher the Z value, the higher the effect is.
 *  \param value Z value
 *  \else
 *  \brief 设置时间线视频特效Z值
 *  Z值决定了特效的渲染顺序，Z值越大，特效越处于上层
 *  \param value z值
 *  \endif
 *  \since 2.17.0
 */
- (void)setZValue:(float)value;

/*! \if ENGLISH
 *  \brief Gets video effect Z value.
 *  \return Returns video effect Z value.
 *  \else
 *  \brief 获取时间线视频特效Z值
 *  \return 返回时间线视频特效Z值
 *  \endif
 *  \since 2.17.0
 */
- (float)getZValue;

/*! \if ENGLISH
 *  \brief Converts the timeline coordinates to the particle system coordinates.
 *  \param ptCononical Timeline coordinates
 *  \return Returns the CGPoint object of the particle system coordinate after transforming.
 *  \else
 *  \brief 将时间线坐标转换为粒子系统坐标
 *  \param ptCononical 时间线坐标
 *  \return 返回转换后的粒子系统坐标CGPoint
 *  \endif
 *  \since 1.16.0
*/
- (CGPoint)mapPointFromCanonicalToParticleSystem:(CGPoint)ptCononical;

@end

