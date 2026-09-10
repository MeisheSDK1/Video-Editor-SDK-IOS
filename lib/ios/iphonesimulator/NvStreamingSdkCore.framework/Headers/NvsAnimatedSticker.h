//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jan 29. 2021
//   Author:        Meishe video team
//================================================================================
#pragma once

#import "NvsFx.h"
#import <CoreGraphics/CGGeometry.h>

/*! \if ENGLISH
 *  \brief animated sticker class.
 *
 *  animation sticker is a landscaping effect used in video editing to produce animated effects.
 * Users can add and remove animated stickers from the timeline(or video track, or capture), as well as adjust various properties of the stickers through various APIs, such as position, size, display time, and so on.
 *  <br>Note: The in-point and out-point units of the animated sticker on the timeline are both in microseconds.
 *  \warning In the NvsAnimatedSticker class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 动画贴纸类
 *
 *  动画贴纸是视频编辑时使用的一种美化特效，可以产生动画效果。
 *  用户可以在时间线(或者轨道，或者采集)上添加和移除动画贴纸，也可以通过各种API调整贴纸的各种属性，如位置、大小、显示时间等等。
 *  <br>注：动画贴纸在时间线(或者轨道，或者采集)上的入点和出点单位都为微秒
 *  \warning NvsAnimatedSticker类中，所有public API都在UI线程使用！！！
 *  \endif
 */
NVS_EXPORT @interface NvsAnimatedSticker : NvsFx

@property (readonly) BOOL hasAudio;             //!< \if ENGLISH Whether it contains audio. \else 是否含有音频 \endif \since 2.0.3
@property (readonly) BOOL isPanoramic;          //!< \if ENGLISH Whether It's a panorama animated sticker,Default is no. \else 是否为全景图动画贴纸,默认为否 \endif \since 1.6.0
@property (readonly) int64_t defaultDuration;   //!< \if ENGLISH The default duration of the animated sticker on the timeline  (in microseconds). \else 动画贴纸在时间线上的默认长度（单位微秒） \endif \since 2.1.0
@property (readonly) NSString* animatedStickerPeriodAnimationPackageId;    //!< \if ENGLISH The package ID of the animated sticker loop-animation style \else 动画贴纸循环动画样式包裹ID \endif \since 2.21.0
@property (readonly) NSString* animatedStickerInAnimationPackageId;  //!< \if ENGLISH The package ID of the animated sticker in-animation style \else 动画贴纸入动画样式包裹ID \endif \since 2.21.0
@property (readonly) NSString* animatedStickerOutAnimationPackageId; //!< \if ENGLISH The package ID of the animated sticker out-animation style \else 动画贴纸出动画样式包裹ID \endif \since 2.21.0

/*! \if ENGLISH
 *  \brief Get animated sticker's package ID.
 *  \return Return the animated sticker's package ID.
 *  \else
 *  \brief 获取动画贴纸包ID
 *  \return 返回动画贴纸包ID
 *  \endif
 *  \since 1.7.0
 */
- (NSString *)getAnimatedStickerPackageId;

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
 *  \brief Set the horizontal scale value of the animated sticker. The scale value set by this function do not stack.
 *  \param scale horizontal Scaling value.
 *  \return
 *  \else
 *  \brief 设置动画贴纸的分离式水平缩放比例，该函数设置的缩放比例不叠加
 *  \param scaleX 分离式水平缩放比例
 *  \endif
 *  \since 3.7.3
*/
- (void)setSeperatedScaleX:(float)scaleX;

/*! \if ENGLISH
 *  \brief Set the vertical scale value of the animated sticker. The scale value set by this function do not stack.
 *  \param scale vertical Scaling value.
 *  \else
 *  \brief 设置动画贴纸的分离式垂直缩放比例，该函数设置的缩放比例不叠加
 *  \param scaleY 分离式垂直缩放比例
 *  \endif
 *  \since 3.7.3
*/
- (void)setSeperatedScaleY:(float)scaleY;

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
 *  \brief Get the seperated horizontal scale value of the animated sticker.
 *  \return Return the horizontal scale value.
 *  \else
 *  \brief 获取动画贴纸的分离式水平缩放比例。
 *  \return 分离式水平缩放比例。
 *  \endif
 *  \since 3.7.3
*/
- (float)getSeperatedScaleX;

/*! \if ENGLISH
 *  \brief Get the seperated vertical scale value of the animated sticker.
 *  \return Return the vertical scale value.
 *  \else
 *  \brief 获取动画贴纸的分离式垂直缩放比例。
 *  \return 分离式垂直缩放比例。
 *  \endif
 *  \since 3.7.3
*/
- (float)getSeperatedScaleY;

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
 *  \since 1.8.1
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
 *  \since 1.8.1
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
 *  \since 1.8.1
 */
- (void)rotateAnimatedSticker:(float)angle anchor:(CGPoint)anchor;

/*! \if ENGLISH
 *  \brief Rotate the animation sticker with the center point of the animation sticker as the anchor point.The rotation angle set by this function is stackable.
 *  \param angle rotation angle
 *  \else
 *  \brief 以动画贴纸中心点为锚点旋转动画贴纸，该函数设置的旋转角度可叠加
 *  \param angle 旋转角度
 *  \endif
 *  \since 1.8.1
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
- (NvsRect)getOriginalBoundingRect;

/*! \if ENGLISH
 *  \brief Get the vertex positions of the animated sticker's original bounding in the timeline coordinate system.please refer to [TimeLine and View Coordinate] (\ref Coordinate.md).
 *  \return Return a List<PointF> object containing four vertex positions corresponding to the top left, bottom left, bottom right, and top right vertices of the original bounding.
 *  \else
 *  \brief 获取动画贴纸在时间线坐标系下原始包络框的顶点位置。请参见[时间线与视图坐标] (\ref Coordinate.md)
 *  \return 返回List<PointF>对象，包含四个顶点位置，分别对应原始包络框的左上，左下，右下，右上顶点
 *  \endif
 *  \since 1.4.0
 */
- (NSArray *)getBoundingRectangleVertices;

/*! \if ENGLISH
 *  \brief Set the polar angle of the center point on the animated sticker. Only valid for panorama animated stickers.
 *  \param centerPolarAngle The polar angle of the center point, in degrees.
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 对动画贴纸设置中心点的极角。只对全景图动画贴纸有效
 *  \param centerPolarAngle 中心点的极角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
 */
- (void)setCenterPolarAngle:(float)centerPolarAngle;

/*! \if ENGLISH
 *  \brief Get the polar angle of the center point of the animated sticker. It is only valid for panorama animated stickers.
 *  \return Return the polar angle of the center point of the animated sticker, in degrees.
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取动画贴纸中心点的极角。只对全景图动画贴纸有效
 *  \return 返回动画贴纸中心点的极角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
 */
- (float)getCenterPolarAngle;

/*! \if ENGLISH
 *  \brief Set the azimuth of the center point on the animated sticker. It is only valid for panorama animated stickers.
 *  \param centerAzimuthAngle The azimuth of the center point, in degrees.
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 对动画贴纸设置中心点的方位角。只对全景图动画贴纸有效
 *  \param centerAzimuthAngle 中心点的极角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
 */
- (void)setCenterAzimuthAngle:(float)centerAzimuthAngle;

/*! \if ENGLISH
 *  \brief Get the azimuth of the center point of the animated sticker. It is only valid for panorama animated stickers.
 *  \return Return the azimuth of the center point of the animated sticker, in degrees.
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取动画贴纸中心点的方位角。只对全景图动画贴纸有效
 *  \return 返回动画贴纸中心点的方位角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
 */
- (float)getCenterAzimuthAngle;

/*! \if ENGLISH
 *  \brief Set animated sticker's field angle, which is coplanar with the polar angle. It is only valid for panorama animated stickers.
 *  \param polarAngleRange The field angle coplanar with the polar angle, in degrees.
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 对动画贴纸设置极角的张角。只对全景图动画贴纸有效
 *  \param polarAngleRange 极角的张角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
 */
- (void)setPolarAngleRange:(float)polarAngleRange;

/*! \if ENGLISH
 *  \brief Get animated sticker's field angle, which is coplanar with the polar angle. It is only valid for panorama animated stickers.
 *  \return Return animated sticker's field angle coplanar with the polar corner, in degrees.
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取动画贴纸极角的张角。只对全景图动画贴纸有效
 *  \return 返回动画贴纸极角的张角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
 */
- (float)getPolarAngleRange;

/*! \if ENGLISH
 *  \brief Get the animated sticker’s field angle which is perpendicular to the polar angle. It is only valid for panorama animated stickers.
 *  \return Return the animated sticker’s field angle which is perpendicular to the polar angle, in degrees.
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取动画贴纸与极角垂直的张角。只对全景图动画贴纸有效
 *  \return 返回动画贴纸与极角垂直的张角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.7.0
 */
- (float)getOrthoAngleRange;

/*! \if ENGLISH
 *  \brief Set the sticker Z value.The higher the Z value, the higher the sticker is.
 *  \param value Z value
 *  \else
 *  \brief 设置贴纸Z值。Z值越大，贴纸越处于上层
 *  \param value Z值
 *  \endif
 *  \since 1.10.0
 */
- (void)setZValue:(float)value;

/*! \if ENGLISH
 *  \brief Get the sticker Z value.
 *  \return Return sticker Z value.
 *  \else
 *  \brief 获取贴纸Z值
 *  \return 返回贴纸Z值
 *  \endif
 *  \since 1.10.0
 */
- (float)getZValue;

/*! \if ENGLISH
 *  \brief Set the sticker volume.
 *  \param leftVolumeGain Left channel volume gain,value range [0, 1].
 *  \param rightVolumeGain Right channel volume gain,value range [0, 1].
 *  \else
 *  \brief 设置贴纸音量
 *  \param leftVolumeGain 左声道音量增益,取值范围[0,1]
 *  \param rightVolumeGain 右声道音量增益,取值范围[0,1]
 *  \endif
 *  \sa getVolumeGain:rightVolumeGain:
 *  \since 2.0.3
 */
- (void)setVolumeGain:(float)leftVolumeGain rightVolumeGain:(float)rightVolumeGain;

/*! \if ENGLISH
 *  \brief Get volume information.
 *  \param leftVolumeGain Outputs the volume value of the left channel
 *  \param rightVolumeGain Outputs the volume value of the right channel
 *  \else
 *  \brief 获取音量
 *  \return 返回获取的音量对象
 *  \param leftVolumeGain 输出左声道音量值
 *  \param rightVolumeGain 输出右声道音量值
 *  \endif
 *  \sa setVolumeGain:rightVolumeGain:
 *  \since 2.0.3
 */
- (void)getVolumeGain:(float *)leftVolumeGain rightVolumeGain:(float *)rightVolumeGain;

/*! \if ENGLISH
 *  \brief Set the sticker opacity,value range [0, 1].
 *  \param opacity sticker opacity.
 *  \else
 *  \brief 设置贴纸透明度
 *  \param opacity 贴纸透明度，取值范围[0,1]
 *  \endif
 *  \sa getOpacity
 *  \since 2.14.0
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
 *  \since 2.14.0
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
 *  \since 2.15.0
*/
- (void)setCurrentKeyFrameTime:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set the sticker's control point pair.
 *  \param fxParam The type of data parameter for the sticker.
 *  \param controlPointPair control point pair.Set the control point to {0, 0}, that is, the current control point is linear interpolation, otherwise it is curve interpolation.
 *  \else
 *  \brief 设置贴纸的关键帧控制点对
 *  \param fxParam 贴纸参数的类型
 *  \param controlPointPair 控制点对，设置控制点为{0, 0}，即当前控制点为线性插值方式，否则为曲线插值方式
 *  \endif
 *  \sa getControlPoint
 *  \since 2.22.0
 */
- (bool)setControlPoint:(NSString *)fxParam controlPointPair:(NvsControlPointPair *)controlPointPair;

/*! \if ENGLISH
 *  \brief Get the sticker's key frame control point pair.
 *  \param fxParam The type of data parameter for the sticker.
 *  \return return control point data.If the control point is {0, 0},the current control point interpolation method is linear interpolation.[NvsControlPointPair] (@ref NvsControlPointPair)对象
 *  \else
 *  \brief 返回关键帧控制点对
 *  \param fxParam 贴纸参数的类型
 *  \return 返回获得的控制点信息, 如果控制点为{0, 0}说明当前控制点插值方式为线性插值
 *  \endif
 *  \sa setControlPoint: controlPointPair
 *  \since 2.22.0
 */
- (NvsControlPointPair*)getControlPoint:(NSString*)fxParam;

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
-(bool) applyAnimatedStickerPeriodAnimation:(NSString*) animatedStickerPeriodAnimationPackageId;

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
-(bool) applyAnimatedStickerInAnimation:(NSString*) animatedStickerInAnimationPackageId;

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
-(bool) applyAnimatedStickerOutAnimation:(NSString*) animatedStickerOutAnimationPackageId;

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
-(void) setAnimatedStickerAnimationPeriod:(int)periodInMS;

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
-(int) getAnimatedStickerAnimationPeriod;

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
-(void) setAnimatedStickerInAnimationDuration:(int)inAnimationDurationInMS;

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
-(int) getAnimatedStickerInAnimationDuration;

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
-(void) setAnimatedStickerOutAnimationDuration:(int)outAnimationDurationInMS;

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
-(int) getAnimatedStickerOutAnimationDuration;

/*! \if ENGLISH
 *  \brief Set enable the separate effect settings from progress mode.
 *  \param enable whether enable or not.
 *  \else
 *  @brief 设置开启将特效参数与进程分离模式。
 *  @param enable 是否开启
 *  \endif
 *  \sa isSeparateProgressModeEnabled
 *  \since 3.8.1
 */
-(void) enableSeparateProgressMode:(bool)enable;

/*! \if ENGLISH
 *  \brief Get whether enable the separate effect settings from progress mode.
 *  @return Return whether enable the separate effect settings from progress mode.
 *  \else
 *  @brief 获取是否开启将特效参数与进程分离模式。
 *  @return 是否开启
 *  \endif
 *  \sa enableSeparateProgressMode
 *  \since 3.8.1
 */
-(bool) isSeparateProgressModeEnabled;

@end

