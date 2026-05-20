//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Sep 7. 2019
//   Author:        Meishe video team
//================================================================================

#pragma once

#import <Foundation/Foundation.h>
#import "NvsEffectCommonDef.h"

@class NvsArbitraryData;
@class NvsEffectDescription;
@class NvsParticleSystemContext;
@class NvsPaintingEffectContext;
@class NvsARSceneManipulate;
@class NvsMaskRegionInfo;
@class NvsControlPointPair;
@class NvsControlPointModePair;
@class NvsMeshWarpInfo;
@class NvsStoryboard3DSceneAnimData;
@class NvsStoryboard3DMorphingData;

/*! \if ENGLISH
*   \brief Special effects.
*
*   Special effects are the basic types of different types of effects such as Video effect. Special effects are a key part of the SDK framework.
*   It can be added by the createVideoEffect:aspectRatio: method of the NvsEffectSdkContext class.
*   \warning In the NvsEffect class, all public APIs are used in the UI thread! ! !
*   \else
*   \brief 特效
*
*   特效类是视频特效(Video effect)等不同类型特效的基类。在SDK框架中，特效是很关键的一部分，
*   可以通过NvsEffectSdkContext类的createVideoEffect:aspectRatio:方法来添加。
*   \warning NvsEffect类中，所有public API都在UI线程使用！！！
*   \endif
*/
NVS_EXPORT @interface NvsEffect : NSObject

@property (readonly) NvsEffectDescription *description; //!< \if ENGLISH \else 特效描述 \endif

/*! \if ENGLISH
*   \brief Sets effect parameter of integer type.
*   \param fxParam  Effect parameter integer type,please refer to[NVS_PARAM_TYPE_INT] (@ref EFFECT_PARAM_TYPE).
*   \param val Integer value
*   \else
*   \brief 设置特效参数整数值
*   \param fxParam 特效参数整数类型，请参见[NVS_PARAM_TYPE_INT] (@ref EFFECT_PARAM_TYPE)
*   \param val 整形值
*   \endif
*   \sa getIntVal:
*/
- (void)setIntVal:(NSString *)fxParam val:(int)val;

/*! \if ENGLISH
*   \brief Get effect parameter of integer type.
*   \param fxParam  Effect parameter integer type,please refer to[NVS_PARAM_TYPE_INT] (@ref EFFECT_PARAM_TYPE).
*   \return Returns integer value
*   \else
*   \brief 获得特效参数整数值
*   \param fxParam 特效参数整数类型，请参见[NVS_PARAM_TYPE_INT] (@ref EFFECT_PARAM_TYPE)
*   \return 返回整数值
*   \endif
*   \sa setIntVal:val:
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
*   \brief Sets effect parameter of float type.
*   \param fxParam  Effect parameter float type,please refer to[NVS_PARAM_TYPE_FLOAT] (@ref EFFECT_PARAM_TYPE)
*   \param val Float value
*   \else
*   \brief 设置特效参数浮点值
*   \param fxParam 特效参数浮点类型，请参见[NVS_PARAM_TYPE_FLOAT] (@ref EFFECT_PARAM_TYPE)
*   \param val 浮点值
*   \endif
*   \sa getFloatVal:
*/
- (void)setFloatVal:(NSString *)fxParam val:(double)val;

/*! \if ENGLISH
*   \brief Gets effect parameter of float type.
*   \param fxParam Effect parameter float type,please refer to[NVS_PARAM_TYPE_FLOAT] (@ref EFFECT_PARAM_TYPE)
*   \return Returns double value
*   \else
*   \brief 获得特效参数浮点值
*   \param fxParam 特效参数浮点数类型，请参见[NVS_PARAM_TYPE_FLOAT] (@ref EFFECT_PARAM_TYPE)
*   \return 返回double值
*   \endif
*   \sa setFloatVal:val:
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
*   \brief Sets effect parameter of BOOL type.
*   \param fxParam Effect parameter BOOL type,please refer to[NVS_PARAM_TYPE_BOOL] (@ref EFFECT_PARAM_TYPE)
*   \param val BOOL value
*   \else
*   \brief 设置特效参数布尔值
*   \param fxParam 特效参数布尔值类型，请参见[NVS_PARAM_TYPE_BOOL] (@ref EFFECT_PARAM_TYPE)
*   \param val 布尔值
*   \endif
*   \sa getBooleanVal:
*/
- (void)setBooleanVal:(NSString *)fxParam val:(BOOL)val;

/*! \if ENGLISH
*   \brief Gets effect parameter of BOOL type.
*   \param fxParam Effect parameter BOOL type,please refer to[NVS_PARAM_TYPE_BOOL] (@ref EFFECT_PARAM_TYPE)
*   \return Returns BOOL value,YES means it successfully get the boolean value; NO means it fails.
*   \else
*   \brief 获得特效参数布尔值
*   \param fxParam 特效参数布尔值类型，请参见[NVS_PARAM_TYPE_BOOL] (@ref EFFECT_PARAM_TYPE)
*   \return 返回布尔值。YES 成功获取特效参数布尔值；NO 获取参数布尔值失败。
*   \endif
*   \sa setBooleanVal:val:
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
*   \brief Sets effect parameter of string type.
*   \param fxParam Effect parameter string type,please refer to[NVS_PARAM_TYPE_STRING] (@ref EFFECT_PARAM_TYPE)
*   \param val String value
*   \else
*   \brief 设置特效参数字符串值
*   \param fxParam 特效参数字符串类型，请参见[NVS_PARAM_TYPE_STRING] (@ref EFFECT_PARAM_TYPE)
*   \param val 字符串值
*   \endif
*   \sa getStringVal:
*/
- (void)setStringVal:(NSString *)fxParam val:(NSString *)val;

/*! \if ENGLISH
*   \brief Sets effect parameter of string type.
*   \param fxParam Effect parameter string type,please refer to[NVS_PARAM_TYPE_STRING] (@ref EFFECT_PARAM_TYPE)
*   \param val String value
*   \param time current time (In microseconds).
*   \else
*   \brief 设置特效参数字符串值
*   \param fxParam 特效参数字符串类型，请参见[NVS_PARAM_TYPE_STRING] (@ref EFFECT_PARAM_TYPE)
*   \param val 字符串值
*   \param time 时间点 (单位为微秒).
*   \endif
*   \sa getStringVal:
*/
- (void)setStringVal:(NSString *)fxParam val:(NSString *)val time:(int64_t)time;

/*! \if ENGLISH
*   \brief Gets effect parameter of string value.
*   \param fxParam Effect parameter string type,please refer to[NVS_PARAM_TYPE_STRING] (@ref EFFECT_PARAM_TYPE)
*   \return Returns string value.
*   \else
*   \brief 获得特效参数字符串值
*   \param fxParam 特效参数字符串类型，请参见[NVS_PARAM_TYPE_STRING] (@ref EFFECT_PARAM_TYPE)
*   \return 返回字符串指针
*   \endif
*   \sa setStringVal:val:
*/
- (NSString *)getStringVal:(NSString *)fxParam;

/*! \if ENGLISH
*   \brief Gets effect parameter of string value.
*   \param fxParam Effect parameter string type,please refer to[NVS_PARAM_TYPE_STRING] (@ref EFFECT_PARAM_TYPE)
*   \param time current time (In microseconds).
*   \return Returns string value.
*   \else
*   \brief 获得特效参数字符串值
*   \param fxParam 特效参数字符串类型，请参见[NVS_PARAM_TYPE_STRING] (@ref EFFECT_PARAM_TYPE)
*   \param time 时间点 (单位为微秒).
*   \return 返回字符串指针
*   \endif
*   \sa setStringVal:val:
*/
- (NSString *)getStringVal:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
*   \brief Sets effect parameter of color type.
*   \param fxParam Effect parameter color type,please refer to[NVS_PARAM_TYPE_COLOR] (@ref EFFECT_PARAM_TYPE)
*   \param val Color value
*   \else
*   \brief 设置特效参数颜色值
*   \param fxParam 特效参数颜色类型，请参见[NVS_PARAM_TYPE_COLOR] (@ref EFFECT_PARAM_TYPE)
*   \param val 颜色值
*   \endif
*   \sa getColorVal:
*/
- (void)setColorVal:(NSString *)fxParam val:(NvsEffectColor *)val;

/*! \if ENGLISH
*   \brief Gets effect parameter of color value.
*   \param fxParam Effect parameter color type,please refer to[NVS_PARAM_TYPE_COLOR] (@ref EFFECT_PARAM_TYPE)
*   \return Returns Color value.
*   \else
*   \brief 获得特效参数颜色值
*   \param fxParam 特效参数颜色类型，请参见[NVS_PARAM_TYPE_COLOR] (@ref EFFECT_PARAM_TYPE)
*   \return 返回自定义颜色对象
*   \endif
*   \sa setColorVal:val:
*/
- (NvsEffectColor)getColorVal:(NSString *)fxParam;

/*! \if ENGLISH
 *  \brief Set the NvsFx's color parameter at a specified time point.
 *  \param fxParam The type of the NvsEffectFx's color parameter. Please refer to [NVS_PARAM_TYPE_COLOR].
 *  \param val [NvsEffectColor] (@ref NvsEffectColor) Customized color object.
 *  \param time point time (In microseconds).
 *  \else
 *  \brief 设置特效颜色值参数值
 *  \param fxParam 特效的颜色参数的类型。请参见[NVS_PARAM_TYPE_COLOR] (@ref EFFECT_PARAM_TYPE)
 *  \param val [NvsEffectColor] (@ref NvsEffectColor)自定义颜色对象
 *  \param time 时间点 (单位为微秒).
 *  \endif
 *  \sa getColorValAtTime:time:
 */
- (void)setColorValAtTime:(NSString *)fxParam val:(NvsEffectColor *)val time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get the NvsFx's color parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's color parameter. Please refer to [NVS_PARAM_TYPE_COLOR].
 *  \param time point time (In microseconds).
 *  \return Return the customized color object[NvsColor].
 *  \else
 *  \brief 获得特效颜色值参数值
 *  \param fxParam 特效的颜色参数的类型。请参见[NVS_PARAM_TYPE_COLOR] (@ref EFFECT_PARAM_TYPE)
 *  \param time 时间点 (单位为微秒).
 *  \return 返回获得的自定义颜色[NvsEffectColor] (@ref NvsEffectColor)对象
 *  \endif
 *  \sa setColorValAtTime:val:time:
 */
- (NvsEffectColor)getColorValAtTime:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
*   \brief Sets effect parameter of 2D coordinates type.
*   \param fxParam Effect parameter 2D coordinates type,please refer to[NVS_PARAM_TYPE_POSITION2D] (@ref EFFECT_PARAM_TYPE)
*   \param val 2D coordinates value
*   \else
*   \brief 设置特效参数二维坐标
*   \param fxParam 特效参数二维坐标类型，请参见[NVS_PARAM_TYPE_POSITION2D] (@ref EFFECT_PARAM_TYPE)
*   \param val 二维坐标
*   \endif
*   \sa getPosition2DVal:
*/
- (void)setPosition2DVal:(NSString *)fxParam val:(NvsEffectPosition2D *)val;

/*! \if ENGLISH
*   \brief Gets effect parameter of 2D coordinates value.
*   \param fxParam Effect parameter 2D coordinates type,please refer to[NVS_PARAM_TYPE_POSITION2D] (@ref EFFECT_PARAM_TYPE)
*   \return Returns 2D coordinates value.
*   \else
*   \brief 获得特效参数二维坐标
*   \param fxParam 特效参数二维坐标类型，请参见[NVS_PARAM_TYPE_POSITION2D] (@ref EFFECT_PARAM_TYPE)
*   \return 返回二维坐标
*   \endif
*   \sa setPosition2DVal:val:
*/
- (NvsEffectPosition2D)getPosition2DVal:(NSString *)fxParam;

/*! \if ENGLISH
 *  \brief Set the NvsFx's two dimentional coordinates parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's two dimentional coordinates parameter. Please refer to [NVS_PARAM_TYPE_POSITION2D].
 *  \param time point time (In microseconds).
 *  \param val Two dimentional coordinates object[NvsEffectPosition2D].
 *  \else
 *  \brief 设置特效二维坐标参数值
 *  \param fxParam 特效的二维坐标参数的类型。请参见[NVS_PARAM_TYPE_POSITION2D] (@ref EFFECT_PARAM_TYPE)
 *  \param val 二维坐标[NvsEffectPosition2D] (@ref NvsEffectPosition2D)对象
 *  \param time 时间点 (单位为微秒).
 *  \endif
 *  \sa getPosition2DValAtTime:time:
 *  \sa setPosition3DValAtTime:val:time:
 */
- (void)setPosition2DValAtTime:(NSString *)fxParam val:(NvsEffectPosition2D *)val time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get the NvsFx's two dimentional coordinates parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's two dimentional coordinates parameter. Please refer to [NVS_PARAM_TYPE_POSITION2D].
 *  \param time time point (In microseconds).
 *  \return Return the two dimentional coordinates object[NvPosition2D].
 *  \else
 *  \brief 获得特效二维坐标参数值
 *  \param fxParam 特效的二维坐标参数的类型。请参见[NVS_PARAM_TYPE_POSITION2D] (@ref EFFECT_PARAM_TYPE)
 *  \param time 时间点 (单位为微秒).
 *  \return 返回获得的二维坐标[NvsEffectPosition2D] (@ref NvsEffectPosition2D)对象
 *  \endif
 *  \sa setPosition2DValAtTime:val:time:
 *  \sa getPosition3DValAtTime:time:
 */
- (NvsEffectPosition2D)getPosition2DValAtTime:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
*   \brief Sets effect parameter of 3D coordinates type.
*   \param fxParam Effect parameter 3D coordinates type,please refer to[NVS_PARAM_TYPE_POSITION3D] (@ref EFFECT_PARAM_TYPE)
*   \param val 3D coordinates value
*   \else
*   \brief 设置特效参数三维坐标
*   \param fxParam 特效参数三维坐标类型，请参见[NVS_PARAM_TYPE_POSITION3D] (@ref EFFECT_PARAM_TYPE)
*   \param val 三维坐标
*   \endif
*   \sa getPosition3DVal:
*/
- (void)setPosition3DVal:(NSString *)fxParam val:(NvsEffectPosition3D *)val;

/*! \if ENGLISH
*   \brief Gets effect parameter of 3D coordinates value.
*   \param fxParam Effect parameter 3D coordinates type,please refer to[NVS_PARAM_TYPE_POSITION3D] (@ref EFFECT_PARAM_TYPE)
*   \return Returns 3D coordinates value.
*   \else
*   \brief 获得特效参数三维坐标
*   \param fxParam 特效参数三维坐标类型，请参见[NVS_PARAM_TYPE_POSITION3D] (@ref EFFECT_PARAM_TYPE)
*   \return 返回三维坐标
*   \endif
*   \sa setPosition2DVal:val:
*/
- (NvsEffectPosition3D)getPosition3DVal:(NSString *)fxParam;

/*! \if ENGLISH
 *  \brief Set the NvsFx's three dimentional coordinates parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's three dimentional coordinates parameter. Please refer to [NVS_PARAM_TYPE_POSITION3D].
 *  \param val Three dimentional coordinates object[NvsEffectPosition3D].
 *  \param time time point (In microseconds).
 *  \else
 *  \brief 设置特效三维坐标参数值
 *  \param fxParam 特效的三维坐标参数的类型。请参见[NVS_PARAM_TYPE_POSITION3D] (@ref EFFECT_PARAM_TYPE)
 *  \param val 三维坐标[NvsEffectPosition3D] (@ref NvsEffectPosition3D)对象
 *  \param time 时间点 (单位为微秒).
 *  \endif
 *  \sa getPosition3DValAtTime:time:
 *  \sa setPosition2DValAtTime:val:time:
 */
- (void)setPosition3DValAtTime:(NSString *)fxParam val:(NvsEffectPosition3D *)val time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get the NvsFx's three dimentional coordinates parameter at a specified time point.
 *  \param fxParam The type of the NvsFx's three dimentional coordinates parameter. Please refer to [NVS_PARAM_TYPE_POSITION3D].
 *  \param time current time (In microseconds).
 *  \return Return the three dimentional coordinates object[NvPosition3D].
 *  \else
 *  \brief 获得特效三维坐标参数值
 *  \param fxParam 特效的三维坐标参数的类型。请参见[NVS_PARAM_TYPE_POSITION3D] (@ref EFFECT_PARAM_TYPE)
 *  \param time 时间点 (单位为微秒).
 *  \return 返回获得的三维坐标[NvsEffectPosition3D] (@ref NvsEffectPosition3D)对象
 *  \endif
 *  \sa setPosition3DValAtTime:val:time:
 *  \sa getPosition2DValAtTime:time:
 */
- (NvsEffectPosition3D)getPosition3DValAtTime:(NSString *)fxParam time:(int64_t)time;

/*! \if ENGLISH
*   \brief Sets effect parameter of menu type.
*   \param fxParam Effect parameter menu type,please refer to[NVS_PARAM_TYPE_MENU] (@ref EFFECT_PARAM_TYPE)
*   \param val Menu value
*   \else
*   \brief 设置特效参数菜单值
*   \param fxParam 特效参数菜单类型，请参见[NVS_PARAM_TYPE_MENU] (@ref EFFECT_PARAM_TYPE)
*   \param val 字符串
*   \endif
*   \sa getMenuVal:
*/
- (void)setMenuVal:(NSString *)fxParam val:(NSString *)val;

/*! \if ENGLISH
*   \brief Gets effect parameter of menu value.
*   \param fxParam Effect parameter menu type,please refer to[NVS_PARAM_TYPE_MENU] (@ref EFFECT_PARAM_TYPE)
*   \return Returns menu value.
*   \else
*   \brief 获得特效参数菜单值
*   \param fxParam 特效参数菜单类型，请参见[NVS_PARAM_TYPE_MENU] (@ref EFFECT_PARAM_TYPE)
*   \return 返回菜单值
*   \endif
*   \sa setMenuVal:val:
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
*   \brief Sets the effect parameter of custom type.
*   \param fxParam The type of custom data parameter for the effect
*   \param val NvsArbitraryData data value
*   \else
*   \brief 设置自定义数据参数值
*   \param fxParam 特效自定义数据参数的类型
*   \param val NvsArbitraryData数据值
*   \endif
*/
- (void)setArbDataVal:(NSString *)fxParam val:(NvsArbitraryData *)val;

/*! \if ENGLISH
*   \brief Gets the effect parameter of custom type.
*   \param fxParam The type of custom data parameter for the effect
*   \return Returns the custom data of NvsFx.
*   \else
*   \brief 设置自定义数据参数值
*   \param fxParam 特效自定义数据参数的类型
*   \param val NvsArbitraryData数据值
*   \return 返回获得的自定义数据参数值.
*   \endif
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
*   \brief Set the filter intensity.
*   \param intensity The filter intensity value. The value range is generally [0,1]. 0 means the filter has no effect, the default value is 1.
*   \else
*   \brief 设置滤镜的强度
*   \param intensity 滤镜强度值，取值范围一般为[0,1]，为0则滤镜无效果，为1则为默认效果
*   \endif
*   \sa getFilterIntensity
*   \since 2.0.2
*/
-(void)setFilterIntensity:(float)intensity;

/*! \if ENGLISH
*   \brief Gets the filter intensity.
*   \return Returns the filter intensity.
*   \else
*   \brief 获得滤镜的强度
*   \return 返回滤镜的强度值
*   \endif
*   \sa setFilterIntensity:
*   \since 2.0.2
*/
-(float)getFilterIntensity;

/*! \if ENGLISH
 *  \brief Sets the mask of the filter.
 *  \param useMask Wether use mask to limit the filter's region
 *  \else
 *  \brief 设置滤镜遮罩
 *  \param useMask 使用滤镜遮罩，仅在有图像的区域添加滤镜效果
 *  \endif
 *  \sa getFilterMask
 *  \since 2.14.1
 */
-(void)setFilterMask:(bool)useMask;

/*! \if ENGLISH
 *  \brief Gets the usage of the filter's mask.
 *  \return Returns the usage of the filter's mask.
 *  \else
 *  \brief 获得是否使用滤镜遮罩
 *  \return 返回是否使用了滤镜遮罩
 *  \endif
 *  \sa setFilterMask
 *  \since 2.14.1
 */
-(bool)getFilterMask;

/*! \if ENGLISH
 *  \brief Sets whether the filter is regional.
 *  \param regional whether the filter is regional. true means regional, while false means the opposite.
 *  \else
 *  \brief 设置滤镜是否为局部滤镜
 *  \param regional 是否为局部滤镜，true为局部滤镜，false不是
 *  \endif
 *  \sa getRegional
 *  \since 2.10.1
 */
-(void)setRegional:(BOOL)isRegional;

/*! \if ENGLISH
 *  \brief Gets whether the filter is regional.
 *  \return Returns whether the filter is regional.
 *  \else
 *  \brief 获得滤镜是否为局部滤镜
 *  \return 返回滤镜是否为局部滤镜
 *  \endif
 *  \sa setRegional
 *  \since 2.10.1
 */
-(BOOL)getRegional;

/*! \if ENGLISH
 *  \brief Sets whether the regional filter ignore Background.
 *  \param regional whether the regional filter ignores Background. true means ignored, while false means the opposite.
 *  \else
 *  \brief 设置局部滤镜是否消除背景
 *  \param regional 是否为局部滤镜消除背景，true为消除，false不是
 *  \endif
 *  \sa getIgnoreBackground
 *  \since 2.15.1
 */
-(void)setIgnoreBackground:(BOOL)isIgnoreBackground;

/*! \if ENGLISH
 *  \brief Gets whether the regional filter ignores Background.
 *  \return Returns whether the regional filter ignores Background.
 *  \else
 *  \brief 获得局部滤镜是否消除背景
 *  \return 返回局部滤镜是否消除背景
 *  \endif
 *  \sa setIgnoreBackground
 *  \since 2.15.1
 */
-(BOOL)getIgnoreBackground;

/*! \if ENGLISH
 *  \brief Sets whether the regional filter inverse region.
 *  \param regional whether the regional filter inverse region. true means inversed, while false means the opposite.
 *  \else
 *  \brief 设置局部滤镜是否反选区域
 *  \param regional 是否为局部滤镜反选区域，true为反选，false不是
 *  \endif
 *  \sa getInverseRegion
 *  \since 2.15.1
 */
-(void)setInverseRegion:(BOOL)isInverseRegion;

/*! \if ENGLISH
 *  \brief Gets whether the regional filter inverse region.
 *  \return Returns whether the regional filter inverses region.
 *  \else
 *  \brief 获得局部滤镜是否反选区域
 *  \return 返回局部滤镜是否反选区域
 *  \endif
 *  \sa setInverseRegion
 *  \since 2.15.1
 */
-(BOOL)getInverseRegion;

/*! \if ENGLISH
 *  \brief Sets the region of this regional filter.
 *  \param region the effective region of this filter. It is composed with a series of points, which are in NDC coordinate system.
 *  \else
 *  \brief 设置局部滤镜的控制范围
 *  \param region 局部滤镜的控制范围, 由一系列连续的点构成，点的坐标在NDC坐标系中
 *  \endif
 *  \since 2.10.1
 */
-(void)setRegion:(NSArray *)region;

/*! \if ENGLISH
 *  \brief Get the region of this regional filter.
 *  \return Returns the region of this regional filter. It is composed with a series of points, which are in NDC coordinate system.
 *  \else
 *  \brief 获取局部滤镜的控制范围
 *  \return 返回局部滤镜的控制范围，点的坐标在NDC坐标系中
 *  \endif
 *  \sa setRegion:
 *  \since 2.14.0
 */
-(NSArray *)getRegion;

/*! \if ENGLISH
 *  \brief Get the region of this regional filter.
 *  \return region the effective region of this filter. It could be series of points, cubic bezier curve or ellipse, which are in NDC coordinate system.
 *  \else
 *  \brief 获取局部滤镜的控制范围
 *  \return region 局部滤镜的控制范围, 构成控制区域的可以是点，贝塞尔曲线或者椭圆，对应的坐标系为NDC坐标系
 *  \endif
 *  \since 2.16.1
*/
-(NvsMaskRegionInfo *)getRegionInfo;

/*! \if ENGLISH
 *  \brief Sets the region of this regional filter.
 *  \param region the effective region of this filter. It could be series of points, cubic bezier curve or ellipse, which are in NDC coordinate system.
 *  \else
 *  \brief 设置局部滤镜的控制范围
 *  \param region 局部滤镜的控制范围, 构成控制区域的可以是点，贝塞尔曲线或者椭圆，对应的坐标系为NDC坐标系
 *  \endif
 *  \since 2.16.0
 */
-(void)setRegionInfo:(NvsMaskRegionInfo *)info;

/*! \if ENGLISH
 *  \brief Sets the region of this regional filter at certain time.
 *  \param region the effective region of this filter. It could be series of points, cubic bezier curve or ellipse, which are in NDC coordinate system.
 *  \else
 *  \brief 设置某时刻局部滤镜的控制范围
 *  \param region 局部滤镜的控制范围, 构成控制区域的可以是点，贝塞尔曲线或者椭圆，对应的坐标系为NDC坐标系
 *  \endif
 *  \since 2.16.0
 */
-(void)setRegionInfoAtTime:(NvsMaskRegionInfo *)info time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Sets the feather width of this regional filter.
 *  \param featherWidth feather width of regional filter
 *  \else
 *  \brief 设置局部滤镜的羽化宽度
 *  \param featherWidth 局部滤镜的羽化宽度
 *  \endif
 *  \sa getRegionalFeatherWidth
 *  \since 2.10.1
 */
-(void)setRegionalFeatherWidth:(float)featherWidth;

/*! \if ENGLISH
 *  \brief Gets the feather width of this regional filter.
 *  \return Returns the feather width of this regional filter.
 *  \else
 *  \brief 获得局部滤镜的羽化宽度
 *  \return 返回局部滤镜的羽化宽度
 *  \endif
 *  \sa setRegionalFeatherWidth
 *  \since 2.10.1
 */
-(float)getRegionalFeatherWidth;

/*! \if ENGLISH
 *  \brief Sets the coordinate system of the region.
 *  \param type coordinate system type of the region, NDC as the default.
 *  \else
 *  \brief 设置局部滤镜所在坐标系类型，默认为NDC坐标系
 *  \param coordinateSystem 局部滤镜所在坐标系
 *  \endif
 *  \sa getRegionCoordinateSystemType
 *  \since 2.16.1
 */
-(void)setRegionCoordinateSystemType:(int)type;

/*! \if ENGLISH
 *  \brief Gets the coordinate system of the region.
 *  \return Returns the coordinate system of the region.
 *  \else
 *  \brief 获得局部滤镜所在坐标系类型
 *  \return 返回局部滤镜所在坐标系类型
 *  \endif
 *  \sa setRegionCoordinateSystemType
 *  \since 2.16.1
 */
-(int)getRegionCoordinateSystemType;

/*! \if ENGLISH
*   \brief Gets the particle effect context.
*   \return Returns a pointer to a particle effect context.
*   \else
*   \brief 获得粒子特效上下文
*   \return 返回指向粒子特效上下文的指针
*   \endif
*/
- (NvsParticleSystemContext *)getParticleSystemContext;

/*! \if ENGLISH
*   \brief Gets the particle effect context.
*   \return Returns a pointer to a hand-drawn effect context.
*   \else
*   \brief 获得手绘特效上下文
*   \return 返回指向手绘特效上下文指针
*   \endif
*/
- (NvsPaintingEffectContext *)getPaintingEffectContext;

/*! \if ENGLISH
 *  \brief Get the AR scene operation pointer.
 *  \return Return the AR scene operation pointer.
 *  \else
 *  \brief 获得AR场景操作指针
 *  \return 返回指向AR场景操作指针
 *  \endif
*/
- (NvsARSceneManipulate *)getARSceneManipulate;

/*! \if ENGLISH
 *  \brief Sets the value of the defined parameter in the expression.
 *  \param varName The parameters defined in the expression
 *  \param varValue The value of a parameter in an expression
 *  \else
 *  \brief 设置表达式中定义参数的值
 *  \param varName 表达式中定义的参数
 *  \param varValue 表达式中参数对应的值
 *  \endif
 *  \since 2.16.1
 */
- (void)setExprVar:(NSString *)varName varValue:(double)varValue;

/*! \if ENGLISH
 *  \brief Gets the value of the defined parameter in the expression.
 *  \param varName The parameters defined in the expression
 *  \return Returns the value of the parameter defined in the expression
 *  \else
 *  \brief 获得表达式中定义参数的值
 *  \param varName 表达式中定义的参数
 *  \return 返回表达式中定义参数的值
 *  \endif
 *  \since 2.16.1
 */
- (double)getExprVar:(NSString *)varName;

/*! \if ENGLISH
 *  \brief Clears the value of the defined parameter in the expression and sets it to the default value of 0.
 *  \param varName The parameters defined in the expression
 *  \else
 *  \brief 清空表达式中定义参数的值，并设置为默认值0
 *  \param varName 表达式中定义的参数
 *  \endif
 *  \since 2.16.1
 */
- (void)clearExprVar:(NSString *)varName;

/*! \if ENGLISH
 *  \brief Clears the value of all parameters defined in the expression and sets it to the default value of 0.
 *  \param varName The parameters defined in the expression
 *  \else
 *  \brief 清空表达式中定义的全部参数的值，并设置为默认值0
 *  \param varName 表达式中定义的参数
 *  \endif
 *  \since 2.16.1
 */
- (void)clearExprVarCtx;

/*! \if ENGLISH
 *  \brief Reset the internal data of effectcontext
 *  \else
 *  \brief 重置effectcontext内部数据
 *  \endif
 *  \since 3.15.0
 */
- (void)resetEffectContext;

@end
