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

/*! \file NvsFx.h
*/
#pragma once

#import "NvsObject.h"
#import "NvsCommonDef.h"

/*! \if ENGLISH
 *  \brief Key frame find mode
 *  \else
 *  \brief 关键帧查找方式
 *  \endif
*/
typedef enum {
    NvsKeyFrameFindModeFlag_Before = 1,            //!< \if ENGLISH find key frame before current time \else 查找当前时间点之前的关键帧\endif
    NvsKeyFrameFindModeFlag_After = 2,             //!< \if ENGLISH find key frame after current time \else 查找当前时间点之后的关键帧\endif
} NvsKeyFrameFindModeFlag;

/*! \if ENGLISH
 *  \brief Region Coordinate System Type
 *  \else
 *  \brief 局部特效坐标系类型
 *  \endif
*/
typedef enum {
    NvsRegionCoordinateSystemType_NDC = 0,              //!< \if ENGLISH NDC coordinate system \else NDC坐标系\endif
    NvsRegionCoordinateSystemType_Timeline = 1          //!< \if ENGLISH timeline coordinate system \else timeline坐标系 \endif
} NvsRegionCoordinateSystemType;

/*! \if ENGLISH
 *  @name Face Warp Effect Strategy
 *  \else
 *  @name 人脸变形特效策略
 *  \endif
 */
typedef enum {
    NvsFaceWarpEffectStrategy_Custom = 0x7FFFFFFF       //!< \if ENGLISH Face warp effect custom strategy \else 人脸变形特效自定义策略 \endif
} NvsFaceWarpEffectStrategy;

@class NvsArbitraryData;
@class NvsFxDescription;
@class NvsParticleSystemContext;
@class NvsARFaceContext;
@class NvsPaintingEffectContext;
@class NvsARSceneManipulate;
@class NvsMaskRegionInfo;
@class NvsControlPointPair;
@class NvsControlPointModePair;
@class NvsMeshWarpInfo;
@class NvsStoryboard3DSceneAnimData;
@class NvsStoryboard3DMorphingData;

/*! \if ENGLISH
 *  \brief effect class.
 *
 *  Effect class(NvsFx) is the basic class of different effect classes, include video effects(Video Fx), audio effects(Audio Fx), audio transition effects and video transition effects.
 *  In the SDK framework, effects are very important, as they are derived from the NvsFx class, with different kinds of effects. They can be added, removed or obtained from clips, timelines or tracks.
 *  Also, the effect class(NvsFx) provides different APIs to modify or obtain its parameters.
 *  \warning In the NvsFx class, all public APIs are used in UI thread!!!
 *  \else
 *  \brief 特效类
 *
 *  特效类是视频特效(Video Fx)，音频特效(Audio Fx)，音频转场(Audio Transition)，视频转场(Video Transition)等不同类型特效的基类。
 *  在SDK框架中，特效是很关键的一部分，派生自NvsFx的每种不同类型的特效，或通过片段实例，或时间线实例，或轨道实例来添加，移除和获取。
 *  同时，特效类中提供了不同的API接口来设置和获取特效参数类型。
 *  \warning NvsFx类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsFx : NvsObject

@property (readonly) NvsFxDescription *description; //!< \if ENGLISH Special effect description. \else 特效描述 \endif

/*! \if ENGLISH
 *  \brief Set the integer parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's integer parameter. Please refer to [NVS_PARAM_TYPE_INT] (@ref EFFECT_PARAM_TYPE).
 *  \param val integer value.
 *  \else
 *  \brief 设置特效的整数参数值
 *  \param fxParam 特效的整数参数的类型。请参见[NVS_PARAM_TYPE_INT] (@ref EFFECT_PARAM_TYPE)
 *  \param val 整数
 *  \endif
 *  \sa getIntVal:
*/
- (void)setIntVal:(NSString *)fxParam val:(int)val;

/*! \if ENGLISH
 *  \brief Get the integer parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's integer parameter. Please refer to [NVS_PARAM_TYPE_INT].
 *  \return Return the integer value.
 *  \else
 *  \brief 获得特效的整数参数值
 *  \param fxParam 特效的整数参数的类型。请参见[NVS_PARAM_TYPE_INT] (@ref EFFECT_PARAM_TYPE)
 *  \return 返回获得的整数值
 *  \endif
 *  \sa setIntVal:val
*/
- (int)getIntVal:(NSString *)fxParam;

/*! \if ENGLISH
 *  \brief Set the NvsFx's integer parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's integer parameter. Please refer to [NVS_PARAM_TYPE_INT] (@ref EFFECT_PARAM_TYPE).
 *  \param val integer value.
 *  \param time time point (In microseconds).
 *  \else
 *  \brief 设置指定时间点上特效的整数参数值
 *  \param fxParam 特效的整数参数的类型。请参见[NVS_PARAM_TYPE_INT] (@ref EFFECT_PARAM_TYPE)
 *  \param val 整数
 *  \param time 时间点 (单位为微秒).
 *  \endif
 *  \sa getIntValAtTime:val:time:
*/
- (void)setIntValAtTime:(NSString *)fxParam val:(int)val time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get the NvsFx's integer parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's integer parameter. Please refer to [NVS_PARAM_TYPE_INT].
 *  \param time time point (In microseconds).
 *  \return Return the integer value.
 *  \else
 *  \brief 获得指定时间点上特效的整数参数值
 *  \param fxParam 特效的整数参数的类型。请参见[NVS_PARAM_TYPE_INT] (@ref EFFECT_PARAM_TYPE)
 *  \param time 时间点 (单位为微秒).
 *  \return 返回获得的整数值
 *  \endif
 *  \sa setIntValAtTime:time:
*/
- (int)getIntValAtTime:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set the float parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's float parameter. Please refer to [NVS_PARAM_TYPE_FLOAT].
 *  \param val float value.
 *  \else
 *  \brief 设置特效的浮点数参数值
 *  \param fxParam 特效的浮点数参数的类型。请参见[NVS_PARAM_TYPE_FLOAT] (@ref EFFECT_PARAM_TYPE)
 *  \param val 浮点值
 *  \endif
 *  \sa getFloatVal:
*/
- (void)setFloatVal:(NSString *)fxParam val:(double)val;

/*! \if ENGLISH
 *  \brief Get the float parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's float parameter. Please refer to [NVS_PARAM_TYPE_FLOAT].
 *  \return Return the double value.
 *  \else
 *  \brief 获得特效浮点数参数值
 *  \param fxParam 特效的浮点数参数的类型。请参见[NVS_PARAM_TYPE_FLOAT] (@ref EFFECT_PARAM_TYPE)
 *  \return 返回获得的double值
 *  \endif
 *  \sa setFloatVal:val:
 */
- (double)getFloatVal:(NSString *)fxParam;

/*! \if ENGLISH
 *  \brief Set the NvsFx's float parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's float parameter. Please refer to [NVS_PARAM_TYPE_FLOAT].
 *  \param val float value.
 *  \param time time point (In microseconds).
 *  \else
 *  \brief 设置指定时间点上特效的浮点数参数值
 *  \param fxParam 特效的浮点数参数的类型。请参见[NVS_PARAM_TYPE_FLOAT] (@ref EFFECT_PARAM_TYPE)
 *  \param val 浮点值
 *  \param time 时间点 (单位为微秒).
 *  \endif
 *  \sa getFloatValAtTime:time:
*/
- (void)setFloatValAtTime:(NSString *)fxParam val:(double)val time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get the NvsFx's float parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's float parameter. Please refer to [NVS_PARAM_TYPE_FLOAT].
 *  \param time time point (In microseconds).
 *  \return Return the double value.
 *  \else
 *  \brief 获得指定时间点上特效浮点数参数值
 *  \param fxParam 特效的浮点数参数的类型。请参见[NVS_PARAM_TYPE_FLOAT] (@ref EFFECT_PARAM_TYPE)
 *  \param time 时间点 (单位为微秒).
 *  \return 返回获得的double值
 *  \endif
 *  \sa setFloatValAtTime:val:time:
 */
- (double)getFloatValAtTime:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set the BOOL parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's float parameter. Please refer to [NVS_PARAM_TYPE_BOOL].
 *  \param val BOOL value.
 *  \else
 *  \brief 设置特效布尔值参数值
 *  \param fxParam 特效的布尔值参数的类型。请参见[NVS_PARAM_TYPE_BOOL] (@ref EFFECT_PARAM_TYPE)
 *  \param val 布尔值
 *  \endif
 *  \sa getBooleanVal:
 */
- (void)setBooleanVal:(NSString *)fxParam val:(BOOL)val;

/*! \if ENGLISH
 *  \brief Get the BOOL parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's BOOL parameter. Please refer to [NVS_PARAM_TYPE_BOOL].
 *  \return Return the BOOL value.
 *  \else
 *  \brief 获得特效的布尔值参数值
 *  \param fxParam 特效的布尔值参数的类型。请参见[NVS_PARAM_TYPE_BOOL] (@ref EFFECT_PARAM_TYPE)
 *  \return 返回获得的布尔值
 *  \endif
 *  \sa setBooleanVal:val:
 */
- (BOOL)getBooleanVal:(NSString *)fxParam;

/*! \if ENGLISH
 *  \brief Set the NvsFx’s BOOL parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's BOOL parameter. Please refer to [NVS_PARAM_TYPE_BOOL].
 *  \param val BOOL value.
 *  \param time time point (In microseconds).
 *  \else
 *  \brief 设置指点时间点上特效布尔值参数值
 *  \param fxParam 特效的布尔值参数的类型。请参见[NVS_PARAM_TYPE_BOOL] (@ref EFFECT_PARAM_TYPE)
 *  \param val 布尔值
 *  \param time 时间点 (单位为微秒).
 *  \endif
 *  \sa getBooleanValAtTime:time:
 */
- (void)setBooleanValAtTime:(NSString *)fxParam val:(BOOL)val time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get the NvsFx's BOOL parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's BOOL parameter. Please refer to [NVS_PARAM_TYPE_BOOL].
 *  \param time time point (In microseconds).
 *  \return Return the BOOL value.
 *  \else
 *  \brief 获得特效的布尔值参数值
 *  \param fxParam 特效的布尔值参数的类型。请参见[NVS_PARAM_TYPE_BOOL] (@ref EFFECT_PARAM_TYPE)
 *  \param time 时间点 (单位为微秒).
 *  \return 返回获得的布尔值
 *  \endif
 *  \sa setBooleanValAtTime:val:time:
 */
- (BOOL)getBooleanValAtTime:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set the string parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's string parameter. Please refer to [NVS_PARAM_TYPE_STRING].
 *  \param val string value.
 *  \else
 *  \brief 设置特效字符串参数值
 *  \param fxParam 特效的字符串参数的类型。请参见[NVS_PARAM_TYPE_STRING] (@ref EFFECT_PARAM_TYPE)
 *  \param val 字符串
 *  \endif
 *  \sa getStringVal:
 */
- (void)setStringVal:(NSString *)fxParam val:(NSString *)val;

/*! \if ENGLISH
 *  \brief Get the string parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's string parameter. Please refer to [NVS_PARAM_TYPE_STRING].
 *  \return Return the string value.
 *  \else
 *  \brief 获得特效字符串参数值
 *  \param fxParam 特效的字符串参数的类型。请参见[NVS_PARAM_TYPE_STRING] (@ref EFFECT_PARAM_TYPE)
 *  \return 返回获得的字符串
 *  \endif
 *  \sa setStringVal:val:
 */
- (NSString *)getStringVal:(NSString *)fxParam;

/*! \if ENGLISH
 *  \brief Set the NvsFx's string parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's string parameter. Please refer to [NVS_PARAM_TYPE_STRING].
 *  \param val string value.
 *  \param time time point (In microseconds).
 *  \else
 *  \brief 设置指定时间点上特效字符串参数值
 *  \param fxParam 特效的字符串参数的类型。请参见[NVS_PARAM_TYPE_STRING] (@ref EFFECT_PARAM_TYPE)
 *  \param val 字符串
 *  \param time 时间点 (单位为微秒).
 *  \endif
 *  \sa getStringValAtTime:time:
 */
- (void)setStringValAtTime:(NSString *)fxParam val:(NSString *)val time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get the NvsFx's string parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's string parameter. Please refer to [NVS_PARAM_TYPE_STRING].
 *  \param time time point (In microseconds).
 *  \return Return the string value.
 *  \else
 *  \brief 获得指定时间点上特效字符串参数值
 *  \param fxParam 特效的字符串参数的类型。请参见[NVS_PARAM_TYPE_STRING] (@ref EFFECT_PARAM_TYPE)
 *  \param time 时间点 (单位为微秒).
 *  \return 返回获得的字符串
 *  \endif
 *  \sa setStringValAtTime:val:time:
 */
- (NSString *)getStringValAtTime:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set the color parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's color parameter. Please refer to [NVS_PARAM_TYPE_COLOR].
 *  \param val [NvsColor] (@ref NvsColor) Customized color object.
 *  \else
 *  \brief 设置特效颜色值参数值
 *  \param fxParam 特效的颜色参数的类型。请参见[NVS_PARAM_TYPE_COLOR] (@ref EFFECT_PARAM_TYPE)
 *  \param val [NvsColor] (@ref NvsColor)自定义颜色对象
 *  \endif
 *  \sa getColorVal:
 */
- (void)setColorVal:(NSString *)fxParam val:(NvsColor *)val;

/*! \if ENGLISH
 *  \brief Get the color parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's color parameter. Please refer to [NVS_PARAM_TYPE_COLOR].
 *  \return Return the customized color object[NvsColor].
 *  \else
 *  \brief 获得特效颜色值参数值
 *  \param fxParam 特效的颜色参数的类型。请参见[NVS_PARAM_TYPE_COLOR] (@ref EFFECT_PARAM_TYPE)
 *  \return 返回获得的自定义颜色[NvsColor] (@ref NvsColor)对象
 *  \endif
 *  \sa setColorVal:val:
 */
- (NvsColor)getColorVal:(NSString *)fxParam;

/*! \if ENGLISH
 *  \brief Set the NvsFx's color parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's color parameter. Please refer to [NVS_PARAM_TYPE_COLOR].
 *  \param val [NvsColor] (@ref NvsColor) Customized color object.
 *  \param time point time (In microseconds).
 *  \else
 *  \brief 设置特效颜色值参数值
 *  \param fxParam 特效的颜色参数的类型。请参见[NVS_PARAM_TYPE_COLOR] (@ref EFFECT_PARAM_TYPE)
 *  \param val [NvsColor] (@ref NvsColor)自定义颜色对象
 *  \param time 时间点 (单位为微秒).
 *  \endif
 *  \sa getColorValAtTime:time:
 */
- (void)setColorValAtTime:(NSString *)fxParam val:(NvsColor *)val time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get the NvsFx's color parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's color parameter. Please refer to [NVS_PARAM_TYPE_COLOR].
 *  \param time point time (In microseconds).
 *  \return Return the customized color object[NvsColor].
 *  \else
 *  \brief 获得特效颜色值参数值
 *  \param fxParam 特效的颜色参数的类型。请参见[NVS_PARAM_TYPE_COLOR] (@ref EFFECT_PARAM_TYPE)
 *  \param time 时间点 (单位为微秒).
 *  \return 返回获得的自定义颜色[NvsColor] (@ref NvsColor)对象
 *  \endif
 *  \sa setColorValAtTime:val:time:
 */
- (NvsColor)getColorValAtTime:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set the two dimentional coordinates parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's two dimentional coordinates parameter. Please refer to [NVS_PARAM_TYPE_POSITION2D].
 *  \param val Two dimentional coordinates object[NvsPosition2D].
 *  \else
 *  \brief 设置特效二维坐标参数值
 *  \param fxParam 特效的二维坐标参数的类型。请参见[NVS_PARAM_TYPE_POSITION2D] (@ref EFFECT_PARAM_TYPE)
 *  \param val 二维坐标[NvsPosition2D] (@ref NvsPosition2D)对象
 *  \endif
 *  \sa getPosition2DVal:
 *  \sa setPosition3DVal:
 */
- (void)setPosition2DVal:(NSString *)fxParam val:(NvsPosition2D *)val;

/*! \if ENGLISH
 *  \brief Get the two dimentional coordinates parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's two dimentional coordinates parameter. Please refer to [NVS_PARAM_TYPE_POSITION2D].
 *  \return Return the two dimentional coordinates object[NvPosition2D].
 *  \else
 *  \brief 获得特效二维坐标参数值
 *  \param fxParam 特效的二维坐标参数的类型。请参见[NVS_PARAM_TYPE_POSITION2D] (@ref EFFECT_PARAM_TYPE)
 *  \return 返回获得的二维坐标[NvPosition2D] (@ref NvsPosition2D)对象
 *  \endif
 *  \sa setPosition2DVal:val:
 *  \sa getPosition3DVal:val:
 */
- (NvsPosition2D)getPosition2DVal:(NSString *)fxParam;

/*! \if ENGLISH
 *  \brief Set the NvsFx's two dimentional coordinates parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's two dimentional coordinates parameter. Please refer to [NVS_PARAM_TYPE_POSITION2D].
 *  \param time point time (In microseconds).
 *  \param val Two dimentional coordinates object[NvsPosition2D].
 *  \else
 *  \brief 设置特效二维坐标参数值
 *  \param fxParam 特效的二维坐标参数的类型。请参见[NVS_PARAM_TYPE_POSITION2D] (@ref EFFECT_PARAM_TYPE)
 *  \param val 二维坐标[NvsPosition2D] (@ref NvsPosition2D)对象
 *  \param time 时间点 (单位为微秒).
 *  \endif
 *  \sa getPosition2DValAtTime:time:
 *  \sa setPosition3DValAtTime:val:time:
 */
- (void)setPosition2DValAtTime:(NSString *)fxParam val:(NvsPosition2D *)val time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get the NvsFx's two dimentional coordinates parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's two dimentional coordinates parameter. Please refer to [NVS_PARAM_TYPE_POSITION2D].
 *  \param time time point (In microseconds).
 *  \return Return the two dimentional coordinates object[NvPosition2D].
 *  \else
 *  \brief 获得特效二维坐标参数值
 *  \param fxParam 特效的二维坐标参数的类型。请参见[NVS_PARAM_TYPE_POSITION2D] (@ref EFFECT_PARAM_TYPE)
 *  \param time 时间点 (单位为微秒).
 *  \return 返回获得的二维坐标[NvPosition2D] (@ref NvsPosition2D)对象
 *  \endif
 *  \sa setPosition2DValAtTime:val:time:
 *  \sa getPosition3DValAtTime:time:
 */
- (NvsPosition2D)getPosition2DValAtTime:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set the three dimentional coordinates parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's three dimentional coordinates parameter. Please refer to [NVS_PARAM_TYPE_POSITION3D].
 *  \param val Three dimentional coordinates object[NvsPosition3D].
 *  \else
 *  \brief 设置特效三维坐标参数值
 *  \param fxParam 特效的三维坐标参数的类型。请参见[NVS_PARAM_TYPE_POSITION3D] (@ref EFFECT_PARAM_TYPE)
 *  \param val 三维坐标[NvsPosition3D] (@ref NvsPosition3D)对象
 *  \endif
 *  \sa getPosition3DVal:
 *  \sa setPosition2DVal:val:
 */
- (void)setPosition3DVal:(NSString *)fxParam val:(NvsPosition3D *)val;

/*! \if ENGLISH
 *  \brief Get the three dimentional coordinates parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's three dimentional coordinates parameter. Please refer to [NVS_PARAM_TYPE_POSITION3D].
 *  \return Return the three dimentional coordinates object[NvPosition3D].
 *  \else
 *  \brief 获得特效三维坐标参数值
 *  \param fxParam 特效的三维坐标参数的类型。请参见[NVS_PARAM_TYPE_POSITION3D] (@ref EFFECT_PARAM_TYPE)
 *  \return 返回获得的三维坐标[NvsPosition3D] (@ref NvsPosition3D)对象
 *  \endif
 *  \sa setPosition3DVal:val:
 *  \sa getPosition2DVal:
 */
- (NvsPosition3D)getPosition3DVal:(NSString *)fxParam;

/*! \if ENGLISH
 *  \brief Set the NvsFx's three dimentional coordinates parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's three dimentional coordinates parameter. Please refer to [NVS_PARAM_TYPE_POSITION3D].
 *  \param val Three dimentional coordinates object[NvsPosition3D].
 *  \param time time point (In microseconds).
 *  \else
 *  \brief 设置特效三维坐标参数值
 *  \param fxParam 特效的三维坐标参数的类型。请参见[NVS_PARAM_TYPE_POSITION3D] (@ref EFFECT_PARAM_TYPE)
 *  \param val 三维坐标[NvsPosition3D] (@ref NvsPosition3D)对象
 *  \param time 时间点 (单位为微秒).
 *  \endif
 *  \sa getPosition3DValAtTime:time:
 *  \sa setPosition2DValAtTime:val:time:
 */
- (void)setPosition3DValAtTime:(NSString *)fxParam val:(NvsPosition3D *)val time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get the NvsFx's three dimentional coordinates parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's three dimentional coordinates parameter. Please refer to [NVS_PARAM_TYPE_POSITION3D].
 *  \param time current time (In microseconds).
 *  \return Return the three dimentional coordinates object[NvPosition3D].
 *  \else
 *  \brief 获得特效三维坐标参数值
 *  \param fxParam 特效的三维坐标参数的类型。请参见[NVS_PARAM_TYPE_POSITION3D] (@ref EFFECT_PARAM_TYPE)
 *  \param time 时间点 (单位为微秒).
 *  \return 返回获得的三维坐标[NvsPosition3D] (@ref NvsPosition3D)对象
 *  \endif
 *  \sa setPosition3DValAtTime:val:time:
 *  \sa getPosition2DValAtTime:time:
 */
- (NvsPosition3D)getPosition3DValAtTime:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set the menu parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's menu parameter. Please refer to [NVS_PARAM_TYPE_MENU].
 *  \param val A string value.
 *  \else
 *  \brief 设置特效菜单参数值
 *  \param fxParam 特效的菜单参数的类型。请参见[NVS_PARAM_TYPE_MENU] (@ref EFFECT_PARAM_TYPE)
 *  \param val 字符串
 *  \endif
 *  \sa getMenuVal:
 */
- (void)setMenuVal:(NSString *)fxParam val:(NSString *)val;

/*! \if ENGLISH
 *  \brief Get the menu parameter of NvsFx.
 *  \param fxParam The type of the NvsFx's menu parameter. Please refer to [NVS_PARAM_TYPE_MENU].
 *  \return Return the menu value of NvsFx.
 *  \else
 *  \brief 获得特效菜单参数值
 *  \param fxParam 特效的菜单参数的类型。请参见[NVS_PARAM_TYPE_MENU] (@ref EFFECT_PARAM_TYPE)
 *  \return 返回获得的菜单
 *  \endif
 *  \sa setMenuVal:val:
 */
- (NSString *)getMenuVal:(NSString *)fxParam;

/*! \if ENGLISH
 *  \brief Set the NvsFx's menu parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's menu parameter. Please refer to [NVS_PARAM_TYPE_MENU].
 *  \param val string value.
 *  \param time time point (In microseconds).
 *  \else
 *  \brief 设置特效菜单参数值
 *  \param fxParam 特效的菜单参数的类型。请参见[NVS_PARAM_TYPE_MENU] (@ref EFFECT_PARAM_TYPE)
 *  \param val 字符串
 *  \param time 时间点 (单位为微秒).
 *  \endif
 *  \sa getMenuValAtTime:time:
 */
- (void)setMenuValAtTime:(NSString *)fxParam val:(NSString *)val time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get the NvsFx menu parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's menu parameter. Please refer to [NVS_PARAM_TYPE_MENU].
 *  \param time time point (In microseconds).
 *  \return Return the menu value of NvsFx.
 *  \else
 *  \brief 获得特效菜单参数值
 *  \param fxParam 特效的菜单参数的类型。请参见[NVS_PARAM_TYPE_MENU] (@ref EFFECT_PARAM_TYPE)
 *  \param time 时间点 (单位为微秒).
 *  \return 返回获得的菜单
 *  \endif
 *  \sa setMenuValAtTime:val:time:
 */
- (NSString *)getMenuValAtTime:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set custom data parameter value.
 *  \param fxParam The type of custom data parameter for the effect.
 *  \param val custom arbitrary data.
 *  \else
 *  \brief 设置自定义数据参数值
 *  \param fxParam 特效的自定义数据参数的类型
 *  \param val 字符串
 *  \endif
 *  \sa getArbDataVal:
 */
- (void)setArbDataVal:(NSString *)fxParam val:(NvsArbitraryData *)val;

/*! \if ENGLISH
 *  \brief Get custom data parameter value.
 *  \param fxParam The type of custom data parameter for the effect.
 *  \return return custom arbitrary data.[NvsArbitraryData] (@ref NvsArbitraryData)对象
 *  \else
 *  \brief 返回自定义数据参数值
 *  \param fxParam 特效的自定义数据参数的类型
 *  \return 返回获得的自定义数据
 *  \endif
 *  \sa setArbDataVal:val:
 */
- (NvsArbitraryData *)getArbDataVal:(NSString *)fxParam;

/*! \if ENGLISH
 *  \brief Sets custom data parameter value.
 *  \param fxParam The type of custom data parameter for the effect.
 *  \param time current time (In microseconds).
 *  \param val String.
 *  \else
 *  \brief 设置自定义数据参数值
 *  \param fxParam 特效的自定义数据参数的类型
 *  \param val 字符串
 *  \param time 时间点 (单位为微秒).
 *  \endif
 *  \sa getArbDataValAtTime:time:
 */
- (void)setArbDataValAtTime:(NSString *)fxParam val:(NvsArbitraryData *)val time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get custom data parameter value at a specified time point.
 *  \param fxParam The type of custom data parameter for the effect.
 *  \param time time point
 *  \return return custom arbitrary data.[NvsArbitraryData] (@ref NvsArbitraryData)对象
 *  \else
 *  \brief 返回自定义数据参数值
 *  \param fxParam 特效的自定义数据参数的类型
 *  \param time 时间点
 *  \return 返回获得的自定义数据
 *  \endif
 *  \sa setArbDataValAtTime:val:time:
 */
- (NvsArbitraryData *)getArbDataValAtTime:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Remove key frame at a specified time point from key frame list.
 *  \param fxParam The type of custom data parameter for the effect.
 *  \param time time point (In microseconds).
 *  \return Return success or not
 *  \else
 *  \brief 删除参数指定时间点的关键帧
 *  \param fxParam 特效的数据参数
 *  \param time 时间点 (单位为微秒).
 *  \return 返回是否执行成功
 *  \endif
 */
- (bool)removeKeyframeAtTime:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Remove all key frames from key frame list.
 *  \param fxParam The type of custom data parameter for the effect.
 *  \return Return success or not
 *  \else
 *  \brief 删除参数的所有关键帧
 *  \param fxParam 特效的数据参数
 *  \return 返回是否执行成功
 *  \endif
 */
- (bool)removeAllKeyframe:(NSString *)fxParam;

/*! \if ENGLISH
 *  \brief Check whether the parameter has key frame list or not.
 *  \param fxParam The type of custom data parameter for the effect.
 *  \return Return exist or not.
 *  \else
 *  \brief 当前参数是否有关键帧列表
 *  \param fxParam 特效的数据参数
 *  \return 返回是否有关键帧列表
 *  \endif
 */
- (bool)hasKeyframeList:(NSString *)fxParam;

/*! \if ENGLISH
 *  \brief Get key frame at a specified time point.
 *  \param fxParam The type of custom data parameter for the effect.
 *  \param time time point (In microseconds).
 *  \param flags flag of finding mode, Please refer to [KEY_FRAME_FIND_MODE].
 *  \return Return key frame time point near the specified time point,  If there is no key frame near this time point, return - 1
 *  \else
 *  \brief 获取指定时间点附近的关键帧
 *  \param fxParam 特效的数据参数
 *  \param time 时间点 (单位为微秒).
 *  \param flags 查找标志位，请参见[KEY_FRAME_FIND_MODE] (@ref KEY_FRAME_FIND_MODE).
 *  \return 返回离指定时间点最近的关键帧的时间位置，如果没有找到返回-1
 *  \endif
 */
- (int64_t)findKeyframeTime:(NSString *)fxParam time:(int64_t)time flags:(int)flags;

/*! \if ENGLISH
 *  \brief Set key frame control point pair.
 *  \param fxParam The type of custom data parameter for the effect.
 *  \param time time point (In microseconds).
 *  \param controlPointPair control point pair.
 *  \else
 *  \brief 设置关键帧控制点对
 *  \param fxParam 特效的自定义数据参数的类型
 *  \param time 时间点 (单位为微秒)
 *  \param controlPointPair 控制点对
 *  \endif
 *  \sa getKeyFrameControlPoint:time:
 *  \since 2.21.0
 */
- (bool)setKeyFrameControlPoint:(NSString *)fxParam time:(int64_t)time controlPointPair:(NvsControlPointPair *)controlPointPair;

/*! \if ENGLISH
 *  \brief Get key frame control point pair.
 *  \param fxParam The type of custom data parameter for the effect.
 *  \param time time point (In microseconds).
 *  \return return key frame control point data.[NvsControlPointPair] (@ref NvsControlPointPair)对象
 *  \else
 *  \brief 返回关键帧控制点对
 *  \param fxParam 特效的自定义数据参数的类型
 *  \param time 时间点 (单位为微秒)
 *  \return 返回获得的控制点信息
 *  \endif
 *  \sa setKeyFrameControlPoint:time:controlPointPair:
 *  \since 2.21.0
 */
- (NvsControlPointPair*)getKeyFrameControlPoint:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set key frame control point mode pair.
 *  \param fxParam The type of custom data parameter for the effect.
 *  \param time time point (In microseconds).
 *  \param controlPointModePair control point mode pair.
 *  \else
 *  \brief 设置关键帧控制点对
 *  \param fxParam 特效的自定义数据参数的类型
 *  \param time 时间点 (单位为微秒)
 *  \param controlPointModePair 控制点模式对
 *  \endif
 *  \sa getKeyFrameControlPointMode:time:
 *  \since 3.6.0
 */
- (bool)setKeyFrameControlPointMode:(NSString *)fxParam time:(int64_t)time controlPointModePair:(NvsControlPointModePair *)controlPointModePair;

/*! \if ENGLISH
 *  \brief Get key frame control point mode pair.
 *  \param fxParam The type of custom data parameter for the effect.
 *  \param time time point (In microseconds).
 *  \return return key frame control point mode data.[NvsControlPointModePair] (@ref NvsControlPointModePair)对象
 *  \else
 *  \brief 返回关键帧控制点模式对
 *  \param fxParam 特效的自定义数据参数的类型
 *  \param time 时间点 (单位为微秒)
 *  \return 返回获得的控制点模式信息
 *  \endif
 *  \sa setKeyFrameControlPointMode:time:controlPointModePair:
 *  \since 3.6.0
 */
- (NvsControlPointModePair*)getKeyFrameControlPointMode:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set the intensity of the filter.
 *  \param intensity The degree of intensity of the filter, ranging from 0 to 1, with 0 means no effects and 1 means the default effects.
 *  \else
 *  \brief 设置滤镜的强度
 *  \param intensity 滤镜强度值，取值范围一般为[0,1]，为0则滤镜无效果，为1则为默认效果
 *  \endif
 *  \sa getFilterIntensity
 *  \since 2.0.2
 */
-(void)setFilterIntensity:(float)intensity;

/*! \if ENGLISH
 *  \brief Get the intensity of the filter.
 *  \return Return the degree of intensity of the filter.
 *  \else
 *  \brief 获得滤镜的强度
 *  \return 返回滤镜的强度值
 *  \endif
 *  \sa setFilterIntensity:
 *  \since 2.0.2
 */
-(float)getFilterIntensity;

/*! \if ENGLISH
 *  \brief Set the mask of the filter.
 *  \param useMask Whether use mask to limit the filter's region.
 *  \else
 *  \brief 设置滤镜遮罩
 *  \param useMask 是否使用遮罩。如果使用遮罩，仅在有遮罩的区域添加滤镜效果。
 *  \endif
 *  \sa getFilterMask
 *  \since 2.14.1
 */
-(void)setFilterMask:(bool)useMask;

/*! \if ENGLISH
 *  \brief Get the usage of the filter's mask.
 *  \return Return used or not.
 *  \else
 *  \brief 获得是否使用滤镜遮罩
 *  \return 返回是否使用了滤镜遮罩
 *  \endif
 *  \sa setFilterMask:
 *  \since 2.14.1
 */
-(bool)getFilterMask;

/*! \if ENGLISH
 *  \brief Set whether the filter is regional.
 *  \param isRegional Whether the filter is regional. True means regional, false means the opposite.
 *  \else
 *  \brief 设置滤镜是否为局部滤镜
 *  \param regional 是否为局部滤镜，true为局部滤镜，false不是
 *  \endif
 *  \sa getRegional
 *  \since 2.10.1
 */
-(void)setRegional:(BOOL)isRegional;

/*! \if ENGLISH
 *  \brief Get whether the filter is regional.
 *  \return Return whether the filter is regional or not.
 *  \else
 *  \brief 获得滤镜是否为局部滤镜
 *  \return 返回滤镜是否为局部滤镜
 *  \endif
 *  \sa setRegional:
 *  \since 2.10.1
 */
-(BOOL)getRegional;

/*! \if ENGLISH
*  \brief Set whether the regional filter ignores background.
*  \param isIgnoreBackground Whether the regional filter ignores background. True means ignored, false means the opposite.
*  \else
*  \brief 设置局部滤镜是否消除背景
*  \param IgnoreBackground 是否为局部滤镜消除背景，true为消除，false不是
*  \endif
*  \sa getIgnoreBackground
*  \since 2.15.1
*/
-(void)setIgnoreBackground:(BOOL)isIgnoreBackground;

/*! \if ENGLISH
*  \brief Get whether the regional filter ignores background.
*  \return Return whether the regional filter ignores background or not.
*  \else
*  \brief 获得局部滤镜是否消除背景
*  \return 返回局部滤镜是否消除背景
*  \endif
*  \sa setIgnoreBackground:
*  \since 2.15.1
*/
-(BOOL)getIgnoreBackground;


/*! \if ENGLISH
*  \brief Set whether the regional filter inverses region.
*  \param isInverseRegion Whether the regional filter inverses region. True means inversed, false means the opposite.
*  \else
*  \brief 设置局部滤镜是否反选区域
*  \param isInverseRegion 是否为局部滤镜反选区域，true为反选，false不是
*  \endif
*  \sa getInverseRegion
*  \since 2.15.1
*/
-(void)setInverseRegion:(BOOL)isInverseRegion;

/*! \if ENGLISH
*  \brief Get whether the regional filter inverses region.
*  \return Return whether the regional filter inverses region or not.
*  \else
*  \brief 获得局部滤镜是否反选区域
*  \return 返回局部滤镜是否反选区域
*  \endif
*  \sa setInverseRegion:
*  \since 2.15.1
*/
-(BOOL)getInverseRegion;

/*! \if ENGLISH
 *  \brief Get the region of this regional filter.
 *  \return Return the region of this regional filter. It is composed with a series of points, which are in NDC coordinate system.
 *  \else
 *  \brief 获取局部滤镜的控制范围
 *  \return 返回局部滤镜的控制范围，点的坐标在NDC坐标系中
 *  \endif
 *  \sa setRegion:
 *  \since 2.14.0
 */
-(NSArray *)getRegion;

/*! \if ENGLISH
 *  \brief Set the region of this regional filter.
 *  \param region The effective region of this filter. It is composed with a series of points, which are in NDC coordinate system.
 *  \else
 *  \brief 设置局部滤镜的控制范围
 *  \param region 局部滤镜的控制范围, 由一系列连续的点构成，点的坐标在NDC坐标系中
 *  \sa getRegion
 *  \endif
 *  \since 2.10.1
 */
-(void)setRegion:(NSArray *)region;

/*! \if ENGLISH
 *  \brief Get the mask region informations of the regional filter.
 *  \return Return the mask region informations of the filter. It could be series of points, cubic bezier curve or ellipse, which are in NDC coordinate system.
 *  \else
 *  \brief 获取局部滤镜的蒙版区域信息
 *  \return 返回局部滤镜的蒙版区域信息
 *  \endif
 *  \sa setRegionInfo:
 *  \since 2.16.0
 */
-(NvsMaskRegionInfo *)getRegionInfo;

/*! \if ENGLISH
 *  \brief Set the mask region informations of the regional filter.
 *  \param info the mask region informations of the filter. It could be series of points, cubic bezier curve or ellipse, which are in NDC coordinate system.
 *  \else
 *  \brief 设置局部滤镜的蒙版区域信息
 *  \param info 局部滤镜的蒙版区域信息, 构成控制区域的可以是点，贝塞尔曲线或者椭圆，对应的坐标系为NDC坐标系
 *  \endif
 *  \sa getRegionInfo
 *  \since 2.16.0
 */
-(void)setRegionInfo:(NvsMaskRegionInfo *)info;

/*! \if ENGLISH
 *  \brief Set the regional filter's mask region informations at a specified time point.
 *  \param info mask region informations. It could be series of points, cubic bezier curve or ellipse, which are in NDC coordinate system.
 *  \param time time point.
 *  \else
 *  \brief 设置指定时间点局部滤镜的蒙版区域信息
 *  \param region 蒙版区域信息, 构成控制区域的可以是点，贝塞尔曲线或者椭圆，对应的坐标系为NDC坐标系
 *  \param time 时间点
 *  \endif
 *  \sa getRegionInfoAtTime:
 *  \since 2.16.0
 */
-(void)setRegionInfoAtTime:(NvsMaskRegionInfo *)info time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get the the regional filter's mask region informations at a specified time.
 *  \return Return the filter's mask region informations. It could be series of points, cubic bezier curve or ellipse, which are in NDC coordinate system.
 *  \else
 *  \brief 获取指定时间点局部滤镜的模板区域信息
 *  \return 返回指定时间点滤镜的模板区域信息
 *  \endif
 *  \sa setRegionInfoAtTime:time:
 *  \since 2.16.0
 */
-(NvsMaskRegionInfo *)getRegionInfoAtTime:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set the feather width of the regional filter.
 *  \param featherWidth feather width of the regional filter
 *  \else
 *  \brief 设置局部滤镜的羽化宽度
 *  \param featherWidth 局部滤镜的羽化宽度
 *  \endif
 *  \sa getRegionalFeatherWidth
 *  \since 2.10.1
 */
-(void)setRegionalFeatherWidth:(float)featherWidth;

/*! \if ENGLISH
 *  \brief Get the feather width of the regional filter.
 *  \return Return the feather width of the regional filter.
 *  \else
 *  \brief 获得局部滤镜的羽化宽度
 *  \return 返回局部滤镜的羽化宽度
 *  \endif
 *  \sa setRegionalFeatherWidth:
 *  \since 2.10.1
 */
-(float)getRegionalFeatherWidth;

/*! \if ENGLISH
 *  \brief Set the regional filter's feather width at a specified time point.
 *  \param featherWidth feather width of regional filter
 *  \param time time point
 *  \else
 *  \brief 设置指定时间点局部滤镜的羽化宽度
 *  \param featherWidth 局部滤镜的羽化宽度
 *  \param time 时间点
 *  \endif
 *  \sa getRegionalFeatherWidthAtTime:time:
 *  \since 2.16.1
 */
- (void)setRegionalFeatherWidthAtTime:(float)featherWidth time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get the regional filter's feather width at a specified time point.
 *  \param time time point
 *  \return Return the feather width of the regional filter.
 *  \else
 *  \brief 获得指定时间点局部滤镜的羽化宽度
 *  \param time 时间点
 *  \return 返回指定时间点局部滤镜的羽化宽度
 *  \endif
 *  \sa setRegionalFeatherWidth:
 *  \since 2.16.1
 */
- (float)getRegionalFeatherWidthAtTime:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set the coordinate system of the region.
 *  \param type coordinate system type of the region, NDC as the default.
 *  \else
 *  \brief 设置局部滤镜所在坐标系类型，默认为NDC坐标系
 *  \param coordinateSystem 局部滤镜所在坐标系，默认是NDC坐标系
 *  \endif
 *  \sa getRegionCoordinateSystemType
 *  \since 2.16.1
 */
-(void)setRegionCoordinateSystemType:(int)type;

/*! \if ENGLISH
 *  \brief Get the coordinate system of the region.
 *  \return Return the coordinate system of the region.
 *  \else
 *  \brief 获得局部滤镜所在坐标系类型
 *  \return 返回局部滤镜所在坐标系类型
 *  \endif
 *  \sa setRegionCoordinateSystemType:
 *  \since 2.16.1
 */
-(int)getRegionCoordinateSystemType;

/*! \if ENGLISH
*   \brief Get the particle effect context pointer.Please refer to [NvsParticleSystemContext] (@ref NvsParticleSystemContext)
*   \return Return the particle effect context pointer.
*   \else
*   \brief 获得粒子特效上下文指针。请参见[NvsParticleSystemContext] (@ref NvsParticleSystemContext)
*   \return 返回指向粒子特效上下文的指针
*   \endif
*/
- (NvsParticleSystemContext *)getParticleSystemContext;

/*! \if ENGLISH
 *  \brief Get face effect context pointer.Please refer to [NvsARFaceContext] (@ref NvsARFaceContext)
 *  \return Return face effect context pointer.
 *  \else
 *  \brief 获得人脸特效上下文指针。请参见[NvsARFaceContext] (@ref NvsARFaceContext)
 *  \return 返回指向人脸特效上下文指针
 *  \endif
*/
- (NvsARFaceContext *)getARFaceContext;

/*! \if ENGLISH
 *  \brief Get the particle effect context pointer.Please refer to [NvsPaintingEffectContext] (@ref NvsPaintingEffectContext)
 *  \return Return the particle effect context pointer.
 *  \else
 *  \brief 获得手绘特效上下文指针。请参见[NvsPaintingEffectContext] (@ref NvsPaintingEffectContext)
 *  \return 返回指向手绘特效上下文指针
 *  \endif
 *   \since 2.2.0
 */
- (NvsPaintingEffectContext *)getPaintingEffectContext;

/*! \if ENGLISH
 *  \brief Get the AR scene operation pointer.Please refer to [NvsARSceneManipulate] (@ref NvsARSceneManipulate)
 *  \return Return the AR scene operation pointer.
 *  \else
 *  \brief 获得AR场景操作指针。请参见[NvsARSceneManipulate] (@ref NvsARSceneManipulate)
 *  \return 返回指向AR场景操作指针
 *  \endif
*/
- (NvsARSceneManipulate *)getARSceneManipulate;

/*! \if ENGLISH
 *  \brief Set the value of the defined parameter in the expression.
 *  \param varName The parameters defined in the expression
 *  \param varValue The value of a parameter in the expression
 *  \else
 *  \brief 设置表达式中定义参数的值
 *  \param varName 表达式中定义的参数
 *  \param varValue 表达式中参数对应的值
 *  \endif
 *  \sa getExprVar:
 *  \since 2.16.1
 */
- (void)setExprVar:(NSString *)varName varValue:(double)varValue;

/*! \if ENGLISH
 *  \brief Get the value of the defined parameter in the expression.
 *  \param varName The parameters defined in the expression
 *  \return Returns the value of the parameter defined in the expression
 *  \else
 *  \brief 获得表达式中定义参数的值
 *  \param varName 表达式中定义的参数
 *  \return 返回表达式中定义参数的值
 *  \endif
 *  \sa setExprVar:varValue:
 *  \since 2.16.1
 */
- (double)getExprVar:(NSString *)varName;

/*! \if ENGLISH
 *  \brief Set the color value of the defined parameter in the expression.
 *  \param varName The parameters defined in the expression
 *  \param color The color value of a parameter in the expression
 *  \else
 *  \brief 设置颜色类型表达式中定义参数的值
 *  \param varName 表达式中定义的参数
 *  \param color 表达式中参数对应的值
 *  \endif
 *  \sa getColorExprVar:
 *  \since 3.5.2
 */
- (void)setColorExprVar:(NSString *)varName varValue:(NvsColor *)color;

/*! \if ENGLISH
 *  \brief Get the color value of the defined parameter in the expression.
 *  \param varName The parameters defined in the expression
 *  \return Returns the value of the parameter defined in the expression
 *  \else
 *  \brief 获得颜色表达式中定义参数的值
 *  \param varName 表达式中定义的参数
 *  \return 返回表达式中定义参数的值
 *  \endif
 *  \sa setExprVar:varValue:
 *  \since 3.5.2
 */
- (NvsColor)getColorExprVar:(NSString *)varName;

/*! \if ENGLISH
 *  \brief Clear the value of the defined parameter in the expression and set it to the default value of 0.
 *  \param varName The parameter defined in the expression
 *  \else
 *  \brief 清空表达式中定义参数的值，并设置为默认值0
 *  \param varName 表达式中定义的参数
 *  \endif
 *  \since 2.16.1
 */
- (void)clearExprVar:(NSString *)varName;

/*! \if ENGLISH
 *  \brief Clear all parameter values defined in the expression and set them to the default value of 0.
 *  \else
 *  \brief 清空表达式中定义的全部参数的值，并设置为默认值0
 *  \endif
 *  \since 2.16.1
 */
- (void)clearExprVarCtx;
@end
