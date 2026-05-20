//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jan 15. 2021
//   Author:        Meishe video team
//================================================================================
#pragma once

#import "NvsEffect.h"
#import <CoreGraphics/CGGeometry.h>

/*! \if ENGLISH
 *  \brief Animated sticker class.
 *
 *  Animation sticker is a landscaping effect used in video editing to produce animated effects.
 * Users can add and remove animated stickers from the timeline, as well as adjust various properties of the stickers through various APIs, such as position, size, display time, and so on.
 *  <br>Note: The in-point and out-point units of the animated sticker on the timeline are both in microseconds.
 *  \warning In the NvsVideoEffectAnimatedSticker class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 动画贴纸类
 *
 *  动画贴纸是视频编辑时使用的一种美化特效，可以产生动画效果。
 *  用户可以在时间线上添加和移除动画贴纸，也可以通过各种API调整贴纸的各种属性，如位置、大小、显示时间等等。
 *  <br>注：动画贴纸在时间线上的入点和出点单位都为微秒
 *  \warning NvsVideoEffectAnimatedSticker，所有public API都在UI线程使用！！！
 *  \endif
 */
NVS_EXPORT @interface NvsVideoEffectAnimatedSticker : NvsEffect


@property (readonly) BOOL isPanoramic;          //!< \if ENGLISH Whether It's a panorama animated sticker,Default is no. \else 是否为全景图动画贴纸,默认为否 \endif \since 1.6.0
@property (readonly) int64_t inPoint;           //!< \if ENGLISH The in point of the animated sticker on the timeline (in microseconds). \else 动画贴纸在时间线上显示的入点（单位微秒） \endif
@property (readonly) int64_t outPoint;          //!< \if ENGLISH The out point of the animated sticker on the timeline (in microseconds). \else 动画贴纸在时间线上显示的出点（单位微秒） \endif
@property (readonly) int64_t defaultDuration;   //!< \if ENGLISH The default duration of the animated sticker on the timeline  (in microseconds). \else 动画贴纸在时间线上的默认长度（单位微秒） \endif \since 2.1.0


/*! \if ENGLISH
 *  \brief Get animated sticker's package ID.
 *  \return Return the animated sticker's package ID.
 *  \else
 *  \brief 获取动画贴纸包ID
 *  \return 返回动画贴纸包ID
 *  \endif
 *  \since 2.20.0
 */
- (NSString *)getAnimatedStickerPackageId;

/*! \if ENGLISH
 *  \brief Change the in-point of the animated sticker on the timeline.
 *  When the new in-point does not conform to the established rules, the final return in-point may be different from the new in-point value.
 *  Such as the new in-point is less than 0, the new in-point value is greater than the timeline duration, or the new in-point is greater than the out-point.
 *  \param newInPoint The new in-point of the animated sticker on the timeline (in microseconds).
 *  \return Return the in-point of the animated sticker on the timeline (in microseconds).
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change](\ref EngineChange.md).
 *  \else
 *  \brief 改变动画贴纸在时间线上显示的入点
 *  当设置的入点值不符合既定规则时最终返回入点值有可能与设置的入点值不同，比如新的入点值小于0，新的入点值大于时间线长度或者新的入点值大于出点值。
 *  \param newInPoint 动画贴纸在时间线上的新入点（单位微秒）
 *  \return 返回动画贴纸在时间线上显示的入点（单位微秒）
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
 *  \endif
 *  \sa changeOutPoint:
 *  \sa getInPoint
 *  \sa movePosition:
 */
- (int64_t)changeInPoint:(int64_t)newInPoint;

/*! \if ENGLISH
 *  \brief Change the out-point of the animated sticker on the timeline.
 *  When the new out-point does not conform to the established rules, the final return out-point may be different from the new out-point value.
 *  Such as the new out-point is less than 0, the new out-point value is greater than the timeline duration, or the new out-point is less than the in-point.
 *  \param newOutPoint The out-point of the animated sticker on the timeline (in microseconds).
 *  \return Return the out-point of the animated sticker on the timeline (in microseconds).
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change] (\ref EngineChange.md).
 *  \else
 *  \brief 改变动画贴纸在时间线上显示的出点
 *  当设置的出点值不符合既定规则时最终返回出点值有可能与设置的出点值不同，比如新的出点值小于0，新的出点值大于时间线长度或者新的出点值小于入点值。
 *  \param newOutPoint 动画贴纸在时间线上的新的出点（单位微秒）
 *  \return 返回动画贴纸在时间线上的显示的出点（单位微秒）
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
 *  \endif
 *  \sa changeInPoint:
 *  \sa getOutPoint
 *  \sa movePosition:
 */
- (int64_t)changeOutPoint:(int64_t)newOutPoint;

/*! \if ENGLISH
 *  \brief Change the display position of the animated sticker on the timeline (the in and out points are offset from the offset value at the same time).
 *  \param offset Offset value for in and out points changes (in microseconds).
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change](\ref EngineChange.md).
 *  \else
 *  \brief 改变动画贴纸在时间线上的显示位置(入点和出点同时偏移offset值)
 *  \param offset 入点和出点改变的偏移值（单位微秒）
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
 *  \endif
 *  \sa changeInPoint:
 *  \sa changeOutPoint:
 */
- (void)movePosition:(int64_t)offset;

/*! \if ENGLISH
 *  \brief Set the scale value of the animated sticker. The scale value set by this function do not stack.
 *  \param scale Scaling value.
 *  \else
 *  \brief 设置动画贴纸的缩放比例，该函数设置的缩放比例不叠加
 *  \param scale 缩放比例
 *  \endif
 *  \sa getScale
 */
- (void)setScale:(float)scale;

/*! \if ENGLISH
 *  \brief Get the scale value of the animated sticker.
 *  \return Return the scale value.
 *  \else
 *  \brief 获取动画贴纸的缩放值
 *  \return 返回获取的缩放值
 *  \endif
 *  \sa setScale:
 */
- (float)getScale;

/*! \if ENGLISH
 *  \brief Set the horizontal flip of the animated sticker.
 *  \param flip Whether to flip horizontally. True means horizontal flip, and false means not.
 *  \else
 *  \brief 设置动画贴纸的水平翻转
 *  \param flip 是否水平翻转。true表示水平翻转，false则不翻转
 *  \endif
 *  \sa getHorizontalFlip
 */
- (void)setHorizontalFlip:(bool)flip;

/*! \if ENGLISH
 *  \brief Get the horizontal flip state of the animated sticker.
 *  \return Return a boolean value indicating a horizontal flip state. True means it flips, false means not.
 *  \else
 *  \brief 获取动画贴纸的水平翻转状态
 *  \return 返回boolean值，表示水平翻转状态。true表示已翻转，false则未翻转
 *  \endif
 *  \sa setHorizontalFlip:
 */
- (BOOL)getHorizontalFlip;

/*! \if ENGLISH
 *  \brief Set the vertical flip of the animated sticker.
 *  \param flip Whether to flip vertically. True means it flip vertically, false means not.
 *  \else
 *  \brief 设置动画贴纸的竖直翻转
 *  \param flip 是否竖直翻转。true表示竖直翻转，false则不翻转
 *  \endif
 *  \sa getVerticalFlip
 */
- (void)setVerticalFlip:(bool)flip;

/*! \if ENGLISH
 *  \brief Get the vertical flip state of the animated sticker.
 *  \return Return a boolean value indicating a vertical flip state. True means it flips, false means not.
 *  \else
 *  \brief 获取动画贴纸的竖直翻转状态
 *  \return 返回boolean值，表示竖直翻转状态。true表示已翻转，false则未翻转
 *  \endif
 *  \sa setVerticalFlip:
 */
- (BOOL)getVerticalFlip;

/*! \if ENGLISH
 *  \brief Set the angle at which the animation sticker rotates clockwise along the Z-axis, which is perpendicular to the screen.The rotation Angle set by this function does not stack.
 *  \param angle Rotation angle value.
 *  \else
 *  \brief 设置动画贴纸沿Z轴顺时针旋转的角度值，Z轴垂直于屏幕，该函数设置的旋转角度不叠加
 *  \param angle 旋转角度值
 *  \endif
 *  \sa getRotationZ
 */
- (void)setRotationZ:(float)angle;

/*! \if ENGLISH
 *  \brief Get the angle at which the animation sticker rotates clockwise along the Z-axis, which is perpendicular to the screen.
 *  \return Return the rotation angle value.
 *  \else
 *  \brief 获取动画贴纸沿Z轴顺时针旋转的角度值，Z轴垂直于屏幕
 *  \return 返回旋转角度值
 *  \endif
 *  \sa setRotationZ:
 *  \sa rotateAnimatedSticker:
 */
- (float)getRotationZ;

/*! \if ENGLISH
 *  \brief Sets the translation position of the animated sticker in the timeline coordinate system.The translation coordinate set by this function do not stack.please refer to [TimeLine and View Coordinate] (\ref Coordinate.md).
 *  \param translation Translation position
 *  \else
 *  \brief 设置动画贴纸在时间线坐标系下的平移坐标，该函数设置的平移坐标不叠加。请参见[时间线与视图坐标] (\ref Coordinate.md)
 *  \param translation 平移坐标
 *  \endif
 *  \sa getTransltion
 *  \sa translateAnimatedSticker:
 */
- (void)setTranslation:(CGPoint)translation;

/*! \if ENGLISH
 *  \brief Get the translation position of the animated sticker in the timeline coordinate system.
 *  \return Return a PointF object representing the translation position.
 *  \else
 *  \brief 获取动画贴纸在时间线坐标系下的平移坐标
 *  \return 返回PointF对象，表示获取的平移坐标
 *  \endif
 *  \sa setTranslation:
 */
- (CGPoint)getTransltion;

/*! \if ENGLISH
 *  \brief Tanslate animated sticker in the timeline coordinate system.The translation coordinates set by this function are stackable.
 *  \param translationOffset Animated sticker translation offset values.
 *  \else
 *  \brief 在时间线坐标系下平移动画贴纸，该函数设置的平移坐标可叠加
 *  \param translationOffset 动画贴纸平移的偏移值
 *  \endif
 *  \since 2.20.0
 *  \sa setTranslation:
 *  \sa getTranslation
 */
- (void)translateAnimatedSticker:(CGPoint)translationOffset;

/*! \if ENGLISH
 *  \brief Scale animation sticker with the anchor point as the center. The scaling value set by this function is stackable.
 *  \param scaleFactor Animated sticker scaling factor.
 *  \param anchor Animated sticker scale anchor.
 *  \else
 *  \brief 以锚点为中心缩放动画贴纸，该函数设置的缩放值可叠加
 *  \param scaleFactor 动画贴纸缩放系数
 *  \param anchor 动画贴纸缩放的锚点
 *  \endif
 *  \since 2.20.0
 */
- (void)scaleAnimatedSticker:(float)scaleFactor anchor:(CGPoint)anchor;

/*! \if ENGLISH
 *  \brief Rotate the animation sticker around the anchor point. The rotation angle set by this function is stackable.
 *  \param angle rotation angle.
 *  \param anchor rotation anchor.
 *  \else
 *  \brief 以锚点为中心旋转动画贴纸，该函数设置的旋转角度可叠加
 *  \param angle 旋转角度
 *  \param anchor 锚点
 *  \endif
 *  \since 2.20.0
 */
- (void)rotateAnimatedSticker:(float)angle anchor:(CGPoint)anchor;

/*! \if ENGLISH
 *  \brief Rotate the animation sticker with the center point of the animation sticker as the anchor point.The rotation angle set by this function is stackable.
 *  \param angle rotation angle
 *  \else
 *  \brief 以动画贴纸中心点为锚点旋转动画贴纸，该函数设置的旋转角度可叠加
 *  \param angle 旋转角度
 *  \endif
 *  \since 2.20.0
 */
- (void)rotateAnimatedSticker:(float)angle;

/*! \if ENGLISH
 *  \brief Get the original bounding of the animated sticker in the timeline coordinate system.please refer to [TimeLine and View Coordinate] (\ref Coordinate.md).
 *  \return Return a RectF object representing the original bounding.
 *  \else
 *  \brief 获取动画贴纸在时间线坐标系下的原始包络框。请参见[时间线与视图坐标] (\ref Coordinate.md)
 *  \return 返回NvsRect对象，表示原始包络框
 *  \endif
 */
- (NvsEffectRect)getOriginalBoundingRect;

/*! \if ENGLISH
 *  \brief Get the vertex positions of the animated sticker's original bounding in the timeline coordinate system.please refer to [TimeLine and View Coordinate] (\ref Coordinate.md).
 *  \return Return a List<PointF> object containing four vertex positions corresponding to the top left, bottom left, bottom right, and top right vertices of the original bounding.
 *  \else
 *  \brief 获取动画贴纸在时间线坐标系下原始包络框的顶点位置。请参见[时间线与视图坐标] (\ref Coordinate.md)
 *  \return 返回List<PointF>对象，包含四个顶点位置，分别对应原始包络框的左上，左下，右下，右上顶点
 *  \endif
 *  \since 2.20.0
 */
- (NSArray *)getBoundingRectangleVertices;

/*! \if ENGLISH
 *  \brief Set the polar angle of the center point on the animated sticker. Only valid for panorama animated stickers.
 *  \param centerPolarAngle The polar angle of the center point, in degrees.
 *  \else
 *  \brief 对动画贴纸设置中心点的极角。只对全景图动画贴纸有效
 *  \param centerPolarAngle 中心点的极角，单位为角度
 *  \endif
 *  \since 2.20.0
 */
- (void)setCenterPolarAngle:(float)centerPolarAngle;

/*! \if ENGLISH
 *  \brief Get the polar angle of the center point of the animated sticker. It is only valid for panorama animated stickers.
 *  \return Return the polar angle of the center point of the animated sticker, in degrees.
 *  \else
 *  \brief 获取动画贴纸中心点的极角。只对全景图动画贴纸有效
 *  \return 返回动画贴纸中心点的极角，单位为角度
 *  \endif
 *  \since 2.20.0
 */
- (float)getCenterPolarAngle;

/*! \if ENGLISH
 *  \brief Set the azimuth of the center point on the animated sticker. It is only valid for panorama animated stickers.
 *  \param centerAzimuthAngle The azimuth of the center point, in degrees.
 *  \else
 *  \brief 对动画贴纸设置中心点的方位角。只对全景图动画贴纸有效
 *  \param centerAzimuthAngle 中心点的极角，单位为角度
 *  \endif
 *  \since 2.20.0
 */
- (void)setCenterAzimuthAngle:(float)centerAzimuthAngle;

/*! \if ENGLISH
 *  \brief Get the azimuth of the center point of the animated sticker. It is only valid for panorama animated stickers.
 *  \return Return the azimuth of the center point of the animated sticker, in degrees.
 *  \else
 *  \brief 获取动画贴纸中心点的方位角。只对全景图动画贴纸有效
 *  \return 返回动画贴纸中心点的方位角，单位为角度
 *  \endif
 *  \since 2.20.0
 */
- (float)getCenterAzimuthAngle;

/*! \if ENGLISH
 *  \brief Set animated sticker's field angle, which is coplanar with the polar angle. It is only valid for panorama animated stickers.
 *  \param polarAngleRange The field angle coplanar with the polar angle, in degrees.
 *  \else
 *  \brief 对动画贴纸设置极角的张角。只对全景图动画贴纸有效
 *  \param polarAngleRange 极角的张角，单位为角度
 *  \endif
 *  \since 2.20.0
 */
- (void)setPolarAngleRange:(float)polarAngleRange;

/*! \if ENGLISH
 *  \brief Get animated sticker's field angle, which is coplanar with the polar angle. It is only valid for panorama animated stickers.
 *  \return Return animated sticker's field angle coplanar with the polar corner, in degrees.
 *  \else
 *  \brief 获取动画贴纸极角的张角。只对全景图动画贴纸有效
 *  \return 返回动画贴纸极角的张角，单位为角度
 *  \endif
 *  \since 2.20.0
 */
- (float)getPolarAngleRange;

/*! \if ENGLISH
 *  \brief Get the animated sticker’s field angle which is perpendicular to the polar angle. It is only valid for panorama animated stickers.
 *  \return Return the animated sticker’s field angle which is perpendicular to the polar angle, in degrees.
 *  \else
 *  \brief 获取动画贴纸与极角垂直的张角。只对全景图动画贴纸有效
 *  \return 返回动画贴纸与极角垂直的张角，单位为角度
 *  \endif
 *  \since 2.20.0
 */
- (float)getOrthoAngleRange;

/*! \if ENGLISH
 *  \brief Set the sticker Z value.The higher the Z value, the higher the sticker is.
 *  \param value Z value
 *  \else
 *  \brief 设置贴纸Z值。Z值越大，贴纸越处于上层
 *  \param value Z值
 *  \endif
 *  \since 2.20.0
 */
- (void)setZValue:(float)value;

/*! \if ENGLISH
 *  \brief Get the sticker Z value.
 *  \return Return sticker Z value.
 *  \else
 *  \brief 获取贴纸Z值
 *  \return 返回贴纸Z值
 *  \endif
 *  \since 2.20.0
 */
- (float)getZValue;

/*! \if ENGLISH
 *  \brief Set the sticker opacity,value range [0, 1].
 *  \param opacity sticker opacity.
 *  \else
 *  \brief 设置贴纸透明度
 *  \param opacity 贴纸透明度，取值范围[0,1]
 *  \endif
 *  \sa getOpacity
 *  \since 2.20.0
 */
- (void)setOpacity:(float)opacity;

/*! \if ENGLISH
 *  \brief Get the sticker opacity.
 *  \return Return the sticker opacity.
 *  \else
 *  \brief 获取透明度
 *  \return 返回获取的贴纸透明度
 *  \endif
 *  \sa setOpacity:
 *  \since 2.20.0
 */
- (float)getOpacity;

/*! \if ENGLISH
 *  \brief Set the sticker's Key frame time.
 *  \param time time point
 *  \else
 *  \brief 设置贴纸的关键帧时间
 *  \param time 时间点
 *  \endif
 *  \sa setCurrentKeyFrameTime
 *  \since 2.20.0
*/
- (void)setCurrentKeyFrameTime:(int64_t)time;

/*! \if ENGLISH
*  \brief Set the sticker's video resolution
*  \param resolution The sticker's video resolution
*  \else
*  \brief 设置贴纸渲染的画幅解析度
*  \param resolution 画幅解析度
*  \endif
*  \since 2.20.0
*/
- (void)setVideoResolution:(NvsEffectVideoResolution*)resolution;

/*! \if ENGLISH
 *  \brief Applys animated sticker loop-animation style.
 *  \param animatedStickerPeriodAnimationPackageId animated sticker loop-animation style resource package ID.
 *  \return Returns boolean value. True means a successful application, false means a failure.
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change](\ref EngineChange.md).
 *  \else
 *  \brief 运用动画贴纸循环动画样式包
 *  \param animatedStickerPeriodAnimationPackageId 动画贴纸循环动画样式资源包ID
 *  \return 返回boolean值。true表示成功运用，false则运用失败
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
 *  \endif
 *  \sa getAnimatedStickerAnimationPackageId
 *  \since 2.21.0
 */
- (bool)applyAnimatedStickerPeriodAnimation:(NSString*) animatedStickerPeriodAnimationPackageId;

/*! \if ENGLISH
 *  \brief Applys animated sticker in-animation style. Notes：please set loop-Animation to null before you set in-animation, otherwise it will NOT works
 *  \param animatedStickerInAnimationPackageId Animated sticker in-animation style resource package ID.
 *  \return Returns boolean value. True means a successful application, false means a failure.
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change](\ref EngineChange.md).
 *  \else
 *  \brief 运用动画贴纸入动画样式包。注意：如果已经应用了循环动画样式包，需要先把循环动画设置为null，否则不生效
 *  \param animatedStickerInAnimationPackageId 动画贴纸入动画样式资源包ID
 *  \return 返回boolean值。true表示成功运用，false则运用失败
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
 *  \endif
 *  \sa getAnimatedStickerInAnimationPackageId
 *  \since 2.21.0
 */
- (bool)applyAnimatedStickerInAnimation:(NSString*) animatedStickerInAnimationPackageId;

/*! \if ENGLISH
 *  \brief Applys animated sticker out-animation style.Notes：please set loop-Animation to null before you set out-animation, otherwise it will NOT works
 *  \param AnimatedStickerOutAnimationPackageId Animated sticker out-animation style resource package ID.
 *  \return Returns boolean value. True means a successful application, false means a failure.
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change](\ref EngineChange.md).
 *  \else
 *  \brief 运用动画贴纸出动画样式包. 注意：如果已经应用了循环动画样式包，需要先把循环动画设置为null，否则不生效
 *  \param animatedStickerOutAnimationPackageId 动画贴纸出动画样式资源包ID
 *  \return 返回boolean值。true表示成功运用，false则运用失败
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
 *  \endif
 *  \sa getAnimatedStickerOutAnimationPackageId
 *  \since 2.21.0
 */
- (bool)applyAnimatedStickerOutAnimation:(NSString*) animatedStickerOutAnimationPackageId;

/*! \if ENGLISH
 *  \brief Set animated sticker Animation Period
 *  \param periodInMS Animation period in million second
 *  \else
 *  \brief 设置动画贴纸循环动画的周期
 *  \param periodInMS 周期的时间，注意：单位是毫秒
 *  \endif
 *  \sa getAnimatedStickerAnimationPeriod
 *  \since 2.21.0
 */
- (void)setAnimatedStickerAnimationPeriod:(int)periodInMS;

/*! \if ENGLISH
 *  \brief Get animated sticker Animation Period
 *  \return Return animation period in million second
 *  \else
 *  \brief 获取动画贴纸循环动画的周期
 *  \return 返回动画贴纸的动画周期，注意：单位是毫秒
 *  \endif
 *  \sa setAnimatedStickerAnimationPeriod
 *  \since 2.21.0
 */
- (int)getAnimatedStickerAnimationPeriod;

/*! \if ENGLISH
 *  \brief Set animated sticker in-animation duration
 *  \param inAnimationDurationInMS in-animation duration in million second
 *  \else
 *  \brief 设置动画贴纸入动画的时长
 *  \param inAnimationDurationInMS 入动画的时长，注意：单位是毫秒
 *  \endif
 *  \sa getAnimatedStickerInAnimationDuration
 *  \since 2.21.0
 */
- (void)setAnimatedStickerInAnimationDuration:(int)inAnimationDurationInMS;

/*! \if ENGLISH
 *  \brief Get animated sticker in-animation duration
 *  \return Return in-animation duration in million second
 *  \else
 *  \brief 获取动画贴纸入动画的时长
 *  \return 返回动画贴纸入动画的时长，注意：单位是毫秒
 *  \endif
 *  \sa setAnimatedStickerInAnimationDuration
 *  \since 2.21.0
 */
- (int)getAnimatedStickerInAnimationDuration;

/*! \if ENGLISH
 *  \brief Set animated sticker out-animation duration
 *  \param outAnimationDurationInMS out-animation duration in million second
 *  \else
 *  \brief 设置动画贴纸出动画的时长
 *  \param outAnimationDurationInMS 出动画的时长，注意：单位是毫秒
 *  \endif
 *  \sa getAnimatedStickerOutAnimationDuration
 *  \since 2.21.0
 */
- (void)setAnimatedStickerOutAnimationDuration:(int)outAnimationDurationInMS;

/*! \if ENGLISH
 *  \brief Get animated sticker out-animation duration
 *  \return Return out-animation duration in million second
 *  \else
 *  \brief 获取动画贴纸出动画的时长
 *  \return 返回动画贴纸出动画的时长，注意：单位是毫秒
 *  \endif
 *  \sa setAnimatedStickerOutAnimationDuration
 *  \since 2.21.0
 */
- (int)getAnimatedStickerOutAnimationDuration;

@end

