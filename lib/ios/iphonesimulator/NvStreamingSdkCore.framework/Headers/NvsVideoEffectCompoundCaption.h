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
 *  \brief compound caption.
 *
 *  compound captions are compound caption that is superimposed on the video, each compound caption
 *  may composed of several sub-captions. When editing a video, users can add or remove timeline compound captions and adjust the captions position.
 *  User can also set its properties such as font family, text color, etc.
 *  \warning In the NvsTimelineCompoundCaption class, all public APIs should be used in the UI thread!!!
 *  \else
 *  \brief 复合字幕
 *
 *  复合字幕是视频上叠加的组合型文字，每个复合字幕包含若干个子字幕。编辑视频时，可以添加和移除时间线复合字幕，并对字幕位置进行调整处理，还可以对字体，颜色属性进行修改。
 *  \warning NvsTimelineCompoundCaption类中，所有public API都必须在UI线程使用!!!
 *  \endif
 *  \since 2.9.0
 */

/*! \anchor BOUNDING_TYPE */
/*!
 *  \if ENGLISH
 *   @name Bounding type
 *  \else
 *   @name 边框类型
 *  \endif
 */

typedef enum
{
    NvsEffectBoundingType_Text = 0,               //!< \if ENGLISH The actual text bounding \else 文字的实际边框 \endif
    NvsEffectBoundingType_Text_Frame = 1,         //!< \if ENGLISH Text frame bounding \else 文字框的边框 \endif
    NvsEffectBoundingType_Frame = 2,              //!< \if ENGLISH The whole bounding including decoration \else 包括装饰在内的整体边框 \endif
    NvsEffectBoundingType_Text_Origin_Frame = 3,  //!< \if ENGLISH Text frame bounding  that has not been transformed  \else 没有经过变换的文字框的边框 \endif
    NvsEffectBoundingType_Typographic_Text = 4,    //!< \if ENGLISH The typographic text bounding \else 文字的排版边框 \endif
} NvsEffectBoundingType;

NVS_EXPORT @interface NvsVideoEffectCompoundCaption : NvsEffect

/*! \if ENGLISH
 *  \brief Gets number of sub-cpations in this compound caption
 *  \return Returns number of sub-cpations
 *  \else
 *  \brief 获取该复合字幕中子字幕的数量
 *  \return 子字幕数量
 *  \endif
 */
@property (readonly) NSInteger captionCount;

@property (readonly) int64_t inPoint;                 //!< \if ENGLISH The in point of the caption on the timeline(in microseconds) \else 字幕显示的入点（单位微秒） \endif
@property (readonly) int64_t outPoint;                //!< \if ENGLISH The out point of the caption on the timeline (in microseconds) \else 字幕显示的出点（单位微秒） \endif
@property (readonly) NSString* captionStylePackageId; //!< \if ENGLISH The package ID of the caption style\else 字幕样式包裹ID \endif

/*! \if ENGLISH
 *  \brief Changes the in-point of the caption
 *  \param newInPoint The new in-point of the caption (in microseconds).
 *  \return Returns the in-point of the caption (in microseconds).
 *  \else
 *  \brief 改变字幕显示的入点
 *  \param newInPoint 字幕新的入点（单位微秒）
 *  \return 返回字幕显示的入点（单位微秒）
 *  \endif
 *  \sa changeOutPoint
 *  \sa getInPoint
 *  \sa movePosition
 */
- (int64_t)changeInPoint:(int64_t)newInPoint;

/*! \if ENGLISH
*  \brief Changes the out-point of the caption
*  \param newOutPoint The new out-point of the caption (in microseconds).
*  \return Returns the out-point of the caption  (in microseconds).
*  \else
*  \brief 改变字幕显示的出点
*  \param newOutPoint 字幕新的出点（单位微秒）
*  \return 返回字幕显示的出点（单位微秒）
*  \endif
*  \sa changeInPoint
*  \sa getOutPoint
*  \sa movePosition
*/
- (int64_t)changeOutPoint:(int64_t)newOutPoint;

/*! \if ENGLISH
 *  \brief Changes the display position of the caption  (the in and out points are offset from the offset value at the same time).
 *  \param offset Offset value for in and out points changes (in microseconds).
 *  \else
 *  \brief 改变字幕显示位置(入点和出点同时偏移offset值)
 *  \param offset 入点和出点改变的偏移值（单位微秒）
 *  \endif
 *  \sa changeInPoint
 *  \sa changeOutPoint
 */
- (void)movePosition:(int64_t)offset;

/*! \if ENGLISH
 *  \brief Sets caption text.
 *  \param captionIndex caption index to set text
 *  \param text Caption text
 *  \else
 *  \brief 设置字幕文本
 *  \param captionIndex 想要设置文字的字幕索引号
 *  \param text 字幕文本
 *  \endif
 *  \sa getText
 */
- (void)setText:(NSInteger)captionIndex
           text:(NSString *)text;

/*! \if ENGLISH
 *  \brief Get caption text.
 *  \param captionIndex caption index to get text
 *  \return Returns caption text.
 *  \else
 *  \brief 获取字幕文本
 *  \param captionIndex 想要获取文字的字幕索引号
 *  \return 返回字幕文本
 *  \endif
 *  \sa setText
 */
- (NSString *)getText:(NSInteger)captionIndex;

/*! \if ENGLISH
 *  \brief Sets caption font family.
 *  \param captionIndex caption index to set font family
 *  \param family Caption font family name. It will be set to default font if family is an empty string
 *  \else
 *  \brief 设置字幕字体
 *  \param captionIndex 想要设置字体的字幕索引号
 *  \param family 字体名称，若设为空字符串，则设为默认字体
 *  \endif
 *  \sa getFontFamily
 */
- (void)setFontFamily:(NSInteger)captionIndex
               family:(NSString *)family;

/*! \if ENGLISH
 *  \brief Get the name of caption font.
 *  \param captionIndex caption index to get font family
 *  \return Returns the name of caption font.
 *  \else
 *  \brief 获取字幕字体的名字
 *  \param captionIndex 想要获取字体的字幕索引号
 *  \return 返回字幕字体的名字
 *  \endif
 *  \sa setFontFamily
 */
- (NSString *)getFontFamily:(NSInteger)captionIndex;

/*! \if ENGLISH
 *  \brief Sets caption text color.
 *  \param captionIndex caption index to set text color
 *  \param textColor Caption text color value.
 *  \else
 *  \brief 设置字幕文本颜色
 *  \param captionIndex 想要设置文本颜色的字幕索引号
 *  \param textColor 文本颜色值
 *  \endif
 *  \sa getTextColor
 */
- (void)setTextColor:(NSInteger)captionIndex
           textColor:(const NvsEffectColor *)textColor;

/*! \if ENGLISH
 *  \brief Gets the color value of the caption.
 *  \param captionIndex caption index to get text color
 *  \return Return NvsEffectColor object which is the text color
 *  \else
 *  \brief 获取字幕的颜色值
 *  \param captionIndex 想要获取文本颜色的字幕索引号
 *  \return 返回NvsEffectColor对象，表示文本的颜色值
 *  \endif
 *  \sa setTextColor
 */
- (NvsEffectColor)getTextColor:(NSInteger)captionIndex;

/*! \if ENGLISH
 *  \brief Sets caption weight.
 *  \param weight the value in opentype weight integer.
 *  \param captionIndex caption index
 *  \else
 *  \brief 设置字幕权重
 *  \param weight opentype中的权重值
 *  \param captionIndex 想要设置文字的字幕索引号
 *  \endif
 *  \sa getWeight:
 */
- (void)setWeight:(int)weight captionIndex:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Gets the caption weight.
 *  \param captionIndex caption index
 *  \return Returns the caption weight.
 *  \else
 *  \brief 获取字幕权重值
 *  \param captionIndex 想要设置文字的字幕索引号
 *  \return 字幕权重值
 *  \endif
 *  \sa setWeight: captionIndex:
 */
- (int)getWeight:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Sets the amount of caption translation.
 *  \param translation The horizontal and vertical translation of the caption.
 *  \else
 *  \brief 设置字幕平移量
 *  \param translation 字幕平移的水平和垂直的平移值
 *  \endif
 *  \sa getCaptionTranslation
 */
- (void)setCaptionTranslation:(CGPoint)translation;

/*! \if ENGLISH
 *  \brief Gets the amount of caption translation.
 *  \return Returns CGPoint object indicating the amount of caption translation obtained.
 *  \else
 *  \brief 获取字幕的平移量
 *  \return 返回CGPoint对象，表示获得的字幕平移量
 *  \endif
 *  \sa setCaptionTranslation
 */
- (CGPoint)getCaptionTranslation;

/*! \if ENGLISH
 *  \brief Translate caption
 *  \param translationOffset Horizontal and vertical offset values for caption.
 *  \else
 *  \brief 平移字幕
 *  \param translationOffset 字幕平移的水平和垂直的偏移值
 *  \endif
 *  \sa setCaptionTranslation
 *  \sa getCaptionTranslation
 */
- (void)translateCaption:(CGPoint)translationOffset;

/*! \if ENGLISH
 *  \brief Sets caption anchor.
 *  \param anchor Anchor.
 *  \else
 *  \brief 设置字幕锚点
 *  \param anchor 锚点
 *  \endif
 *  \sa getAnchorPoint
 */
- (void)setAnchorPoint:(CGPoint)anchor;

/*! \if ENGLISH
 *  \brief Gets caption anchor.
 *  \return Returns caption anchor.
 *  \else
 *  \brief 获取字幕锚点
 *  \return 返回字幕锚点
 *  \endif
 *  \sa setAnchorPoint
 */
- (CGPoint)getAnchorPoint;

/*! \if ENGLISH
 *  \brief Sets horizontal scaling factor for caption.
 *  \param scale Horizontal scaling factor.
 *  \else
 *  \brief 对字幕设置水平缩放系数
 *  \param scale 水平缩放系数
 *  \endif
 *  \sa getScaleX
 *  \sa setScaleY
 */
- (void)setScaleX:(float)scale;

/*! \if ENGLISH
 *  \brief Gets caption horizontal scaling factor.
 *  \return Returns caption horizontal scaling factor.
 *  \else
 *  \brief 获取字幕水平缩放系数
 *  \return 返回字幕水平缩放系数
 *  \endif
 *  \sa setScaleX
 *  \sa getScaleY
 */
- (float)getScaleX;

/*! \if ENGLISH
 *  \brief Sets vertical scaling factor for captions.
 *  \param scale Vertical scaling factor.
 *  \else
 *  \brief 对字幕设置垂直缩放系数
 *  \param scale 垂直缩放系数
 *  \endif
 *  \sa getScaleY
 *  \sa setScaleX
 */
- (void)setScaleY:(float)scale;

/*! \if ENGLISH
 *  \brief Gets caption vertical scaling factor.
 *  \return Returns caption vertical scaling factor.
 *  \else
 *  \brief 获取字幕垂直缩放系数
 *  \return 返回字幕垂直缩放系数
 *  \endif
 *  \sa setScaleY
 *  \sa getScaleX
 */
- (float)getScaleY;

/*! \if ENGLISH
 *  \brief Zooms caption.
 *  \param scaleFactor Caption scaling factor.
 *  \param anchor Caption zoom anchor.
 *  \else
 *  \brief 缩放字幕
 *  \param scaleFactor 字幕缩放的因子
 *  \param anchor 字幕缩放的锚点
 *  \endif
 */
- (void)scaleCaption:(float)scaleFactor
              anchor:(CGPoint)anchor;

/*! \if ENGLISH
 *  \brief Sets the rotation angle for the caption.
 *  \param angle Rotation angle.
 *  \else
 *  \brief 对字幕设置旋转角度
 *  \param angle 旋转角度
 *  \endif
 *  \sa getRotationZ
 */
- (void)setRotationZ:(float)angle;

/*! \if ENGLISH
 *  \brief Gets caption rotation angle.
 *  \return Returns caption rotation angle.
 *  \else
 *  \brief 获取字幕旋转角度
 *  \return 返回字幕旋转角度
 *  \endif
 *  \sa setRotationZ
 */
- (float)getRotationZ;

/*! \if ENGLISH
 *  \brief Rotates captions.
 *  \param angle Angle of caption rotation.
 *  \param anchor Anchor of caption rotation.
 *  \else
 *  \brief 旋转字幕
 *  \param angle 字幕旋转的角度
 *  \param anchor 字幕旋转的锚点
 *  \endif
 */
- (void)rotateCaption:(float)angle
               anchor:(CGPoint)anchor;

/*! \if ENGLISH
 *  \brief Rotates caption around center of the bounding
 *  \param angle Angle of rotation, in degree
 *  \param boundingType Bounding type to calculate center point. Please refer to [Bounding Type] (@ref NvsEffectBoundingType)
 *  \else
 *  \brief 绕字幕边框中心旋转
 *  \param angle 字幕旋转的角度
 *  \param boundingType 用于计算中心点的边框类型。请参见[边框类型] (@ref NvsEffectBoundingType)
 *  \endif
 */
- (void)rotateCaptionAroundCenter:(float)angle
                     boundingType:(NvsEffectBoundingType)boundingType;

/*! \if ENGLISH
 *  \brief Gets the transformed vertices position of the original caption bounding
 *  \param captionIndex Caption index to get vertices positions
 *  \param boundingType Bounding type. Please refer to [Bounding Type] (@ref NvsEffectBoundingType)
 *  \return Returns the NSArray object, the object type is NSValue, and the actual data type is CGPoint, which correspond to the top left, bottom left, bottom right, and top right vertices of the original bounding.
 *  \else
 *  \brief 获取字幕原始边框变换后的顶点位置
 *  \param captionIndex 要获取顶点位置的字幕索引号
 *  \param boundingType 边框类型。请参见[边框类型] (@ref NvsEffectBoundingType)
 *  \return 返回NSArray对象，里面的对象类型为NSValue，而实际包含的数据类型为CGPoint，包含四个顶点位置，依次分别对应原始边框的左上，左下，右下，右上顶点
 *  \endif
 */
- (NSArray *)getCaptionBoundingVertices:(NSInteger)captionIndex
                           boundingType:(NvsEffectBoundingType)boundingType;

/*! \if ENGLISH
 *  \brief Gets the transformed vertices position of the original compound caption bounding
 *  \param boundingType Bounding type. Please refer to [Bounding Type] (@ref NvsEffectBoundingType)
 *  \return Returns the NSArray object, the object type is NSValue, and the actual data type is CGPoint, which correspond to the top left, bottom left, bottom right, and top right vertices of the original bounding.
 *  \else
 *  \brief 获取复合字幕原始边框变换后的顶点位置
 *  \param boundingType 边框类型。请参见[边框类型] (@ref NvsEffectBoundingType)
 *  \return 返回NSArray对象，里面的对象类型为NSValue，而实际包含的数据类型为CGPoint，包含四个顶点位置，依次分别对应原始边框的左上，左下，右下，右上顶点
 *  \endif
 */
- (NSArray *)getCompoundBoundingVertices:(NvsEffectBoundingType)boundingType;

/*! \if ENGLISH
 *  \brief Sets caption Z value.
 *  \param value Z value
 *  \else
 *  \brief 设置字幕Z值
 *  \param value z值
 *  \endif
 */
- (void)setZValue:(float)value;

/*! \if ENGLISH
 *  \brief Gets caption Z value.
 *  \return Returns caption Z value.
 *  \else
 *  \brief 获取字幕Z值
 *  \return 返回字幕Z值
 *  \endif
 */
- (float)getZValue;

/*! \if ENGLISH
 *  \brief Set the caption opacity.
 *  \param opacity The opacity of caption
 *  \else
 *  \brief 设置字幕透明度
 *  \param value 字幕透明度
 *  \endif
 *  \sa getOpacity
*/
- (void)setOpacity:(float)opacity;

/*! \if ENGLISH
 *  \brief Get the caption opacity.
 *  \return Return the opacity.
 *  \else
 *  \brief 获取字幕透明度
 *  \return 返回字幕透明度
 *  \endif
 *  \sa setOpacity:
*/
- (float)getOpacity;

/*! \if ENGLISH
*  \brief Set the Compound Caption's video resolution
*  \param resolution The Compound Caption's video resolution
*  \else
*  \brief 设置复合字幕渲染的画幅解析度
*  \param resolution 画幅解析度
*  \endif
*  \since 2.20.0
*/
- (void)setVideoResolution:(NvsEffectVideoResolution*)resolution;

/*! \if ENGLISH
 *  \brief Sets caption stroke.
 *  \param drawOutline Whether to stroke the captions. True means it strokes the caption. False means it does not stroke the edges.
 *  \param captionIndex caption index to set text
 *  \else
 *  \brief 设置字幕描边
 *  \param drawOutline 是否对字幕描边。true表示对字幕进行描边，false则不描边
 *  \param captionIndex 想要设置文字的字幕索引号
 *  \endif
 *  \since 3.7.3
 *  \sa getDrawOutline
 */
- (void)setDrawOutline:(BOOL)drawOutline captionIndex:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Gets the caption stroke status.
 *  \param captionIndex caption index
 *  \return Returns boolean value, true means it is stroked, and false means it is not stroked.
 *  \else
 *  \brief 获取字幕描边状态
 *  \param captionIndex 想要设置文字的字幕索引号
 *  \return 返回boolean值，true表示已描边，false则未描边
 *  \endif
 *  \since 3.7.3
 *  \sa setDrawOutline
 */
- (BOOL)getDrawOutline:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Sets the color of the caption stroke.
 *  \param outlineColor Caption stroke color value.
 *  \param captionIndex caption index
 *  \else
 *  \brief 设置字幕描边的颜色
 *  \param captionIndex 想要设置文字的字幕索引号
 *  \param outlineColor 字幕描边颜色值
 *  \endif
 *  \since 3.7.3
 *  \sa getOutlineColor
 */
- (void)setOutlineColor:(NvsEffectColor)outlineColor captionIndex:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Gets the color value of the current caption stroke.
 *  \param captionIndex caption index
 *  \return Returns the NvsEffectColor object representing the color of the resulting caption stroke.
 *  \else
 *  \brief 获取当前字幕描边的颜色值
 *  \param captionIndex 想要设置文字的字幕索引号
 *  \return 返回NvsEffectColor对象，表示获得的字幕描边的颜色
 *  \endif
 *  \since 3.7.3
 *  \sa setOutlineColor
 */
-(NvsEffectColor)getOutlineColor:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Sets the width of the caption stroke.
 *  \param outlineWidth The width of the caption stroke.
 *  \param captionIndex caption index
 *  \else
 *  \brief 设置字幕描边的宽度
 *  \param captionIndex 想要设置文字的字幕索引号
 *  \param outlineWidth 字幕描边的宽度
 *  \endif
 *  \since 3.7.3
 *  \sa getOutlineWidth
 */
- (void)setOutlineWidth:(float)outlineWidth captionIndex:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Gets the width of the current caption stroke.
 *  \param captionIndex caption index
 *  \return Returns the width value of the obtained caption stroke.
 *  \else
 *  \brief 获取当前字幕描边的宽度
 *  \param captionIndex 想要设置文字的字幕索引号
 *  \return 返回获得的字幕描边的宽度值
 *  \endif
 *  \since 3.7.3
 *  \sa setOutlineWidth
 */
- (float)getOutlineWidth:(int)captionIndex;

/*! \if ENGLISH
*  \brief Set text background color
*  \param backgroundColor Background color value.
*  \param captionIndex caption index
*  \else
*  \brief 设置字幕文本的背景颜色
*  \param backgroundColor 文本背景颜色值
*  \param captionIndex 想要设置文字的字幕索引号
*  \endif
*  \sa getBackgroundColor
*  \since 3.7.3
*/
- (void)setBackgroundColor:(NvsEffectColor)backgroundColor captionIndex:(int)captionIndex;

/*! \if ENGLISH
*  \brief Get the current text background color value.
*  \param captionIndex caption index
*  \return Returns the NvsEffectColor object representing the current background color.
*  \else
*  \brief 获取字幕文本的当前背景颜色值
*  \param captionIndex 想要设置文字的字幕索引号
*  \return 返回NvsEffectColor对象，表示当前的文本背景颜色值
*  \endif
*  \sa setBackgroundColor
*  \since 3.7.3
*/
- (NvsEffectColor)getBackgroundColor:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Sets whether the caption font is bold.
 *  \param captionIndex caption index
 *  \param bold Indicates whether the caption font is bold.YES means it is bold, NO means it is not.
 *  \else
 *  \brief 设置字幕字体是否加粗
 *  \param bold 表示字幕字体是否加粗，YES表示加粗，NO则不加粗。
 *  \param captionIndex 想要设置文字的字幕索引号
 *  \endif
 *  \sa getBold:
 *  \since 3.7.3
*/
- (void)setBold:(BOOL)bold captionIndex:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Gets the state whether the caption font is bold.
 *  \param captionIndex caption index
 *  \return Returns the state whether the caption font is bold. YES means it is bold, NO means it is not.
 *  \else
 *  \brief 获取字幕字体加粗状态
 *  \param captionIndex 想要设置文字的字幕索引号
 *  \return 返回字幕字体加粗状态，YES表示字体已加粗，NO则字体未加粗。
 *  \endif
 *  \sa setBold: captionIndex:
 *  \since 3.7.3
*/
- (BOOL)getBold:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Sets caption italic.
 *  \param italic the value to set italic.
 *  \param captionIndex caption index
 *  \else
 *  \brief 设置字幕斜体
 *  \param italic用于设置字幕是否应用斜体
 *  \param captionIndex 想要设置的字幕索引号
 *  \endif
 */
- (void)setItalic:(BOOL)italic captionIndex:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Gets the caption italic.
 *  \param captionIndex caption index
 *  \return Returns the caption italic.
 *  \else
 *  \brief 获取字幕斜体状态
 *  \param captionIndex 字幕索引号
 *  \return 字幕斜体状态
 *  \endif
 *  \since 3.7.3
 */
- (BOOL)getItalic:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Set the compound caption KeyFrameTime.
 *  \else
 *  \brief 设置复合字幕的关键帧时间
 *  \endif
 *  \sa setCurrentKeyFrameTime
 *  \since 3.7.3
*/
- (void)setCurrentKeyFrameTime:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set the caption's control point pair.
 *  \param fxParam The type of data parameter for the caption.
 *  \param controlPointPair control point pair.
 *  \else
 *  \brief 设置字幕的关键帧控制点对
 *  \param fxParam 字幕参数的类型
 *  \param controlPointPair 控制点对
 *  \endif
 *  \sa getControlPoint
 *  \since 3.7.3
 */
- (bool)setControlPoint:(NSString *)fxParam controlPointPair:(NvsControlPointPair *)controlPointPair;

/*! \if ENGLISH
 *  \brief Get the caption's key frame control point pair.
 *  \param fxParam The type of data parameter for the caption.
 *  \return return control point data.[NvsControlPointPair] (@ref NvsControlPointPair)对象
 *  \else
 *  \brief 返回关键帧控制点对
 *  \param fxParam 字幕参数的类型
 *  \return 返回获得的控制点信息
 *  \endif
 *  \sa setControlPoint: controlPointPair
 *  \since 3.7.3
 */
- (NvsControlPointPair*)getControlPoint:(NSString*)fxParam;

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
 *  \since 3.7.3
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
 *  \since 3.7.3
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
 *  \since 3.7.3
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
 *  \since 3.7.3
 */
- (int64_t)findKeyframeTime:(NSString *)fxParam time:(int64_t)time flags:(int)flags;

/*! \cond */
//
// Panoramic caption specific methods
//
@property (readonly) BOOL isPanoramic;          //!< \if ENGLISH Whether It's a panorama compound caption,Default is no. \else 是否为全景图复合字幕,默认为否 \endif \since 3.7.0

/*! \if ENGLISH
 *  \brief Set the polar angle of the center point on the compound caption. Only valid for panorama compound captions.
 *  \param centerPolarAngle The polar angle of the center point, in degrees.
 *  \else
 *  \brief 对复合字幕设置中心点的极角。只对全景图复合字幕有效
 *  \param centerPolarAngle 中心点的极角，单位为角度
 *  \endif
 *  \since 3.7.3
 */
-(void)setCenterPolarAngle:(float)centerPolarAngle;

/*! \if ENGLISH
 *  \brief Get the polar angle of the center point of the compound caption. It is only valid for panorama compound captions.
 *  \param captionIndex caption index. -1 indicates the whole compound caption
 *  \return Return the polar angle of the center point of the compound caption, in degrees.
 *  \else
 *  \brief 获取复合字幕中心点的极角。只对全景图复合字幕有效
 *  \param captionIndex 字幕索引号.-1 代表整个复合字幕
 *  \return 返回复合字幕中心点的极角，单位为角度
 *  \endif
 *  \since 3.7.3
 */
-(float)getCenterPolarAngle:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Set compound caption's field angle, which is coplanar with the polar angle. It is only valid for panorama compound captions.
 *  \param polarAngleRange The field angle coplanar with the polar angle, in degrees.
 *  \else
 *  \brief 对复合字幕设置极角的张角。只对全景图复合字幕有效
 *  \param polarAngleRange 极角的张角，单位为角度
 *  \endif
 *  \since 3.7.3
 */
-(void)setPolarAngleRange:(float)polarAngleRange;

/*! \if ENGLISH
 *  \brief Get compound caption's field angle, which is coplanar with the polar angle. It is only valid for panorama compound captions.
 *  \param captionIndex caption index. -1 indicates the whole compound caption
 *  \return Return compound caption's field angle coplanar with the polar corner, in degrees.
 *  \else
 *  \brief 获取复合字幕极角的张角。只对全景图复合字幕有效
 *  \param captionIndex 字幕索引号.-1 代表整个复合字幕
 *  \return 返回复合字幕极角的张角，单位为角度
 *  \endif
 *  \since 3.7.3
 */
-(float)getPolarAngleRange:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Set the azimuth of the center point on the compound caption. It is only valid for panorama compound captions.
 *  \param centerAzimuthAngle The azimuth of the center point, in degrees.
 *  \else
 *  \brief 对复合字幕设置中心点的方位角。只对全景图复合字幕有效
 *  \param centerAzimuthAngle 中心点的极角，单位为角度
 *  \endif
 *  \since 3.7.3
 */
-(void)setCenterAzimuthAngle:(float)centerAzimuthAngle;

/*! \if ENGLISH
 *  \brief Get the azimuth of the center point of the compound caption. It is only valid for panorama compound captions.
 *  \param captionIndex caption index. -1 indicates the whole compound caption
 *  \return Return the azimuth of the center point of the compound caption, in degrees.
 *  \else
 *  \brief 获取复合字幕中心点的方位角。只对全景图复合字幕有效
 *  \param captionIndex 字幕索引号.-1 代表整个复合字幕
 *  \return 返回复合字幕中心点的方位角，单位为角度
 *  \endif
 *  \since 3.7.3
 */
-(float)getCenterAzimuthAngle:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Get the compound caption’s field angle which is perpendicular to the polar angle. It is only valid for panorama compound captions.
 *  \param captionIndex caption index. -1 indicates the whole compound caption
 *  \return Return the compound caption’s field angle which is perpendicular to the polar angle, in degrees.
 *  \else
 *  \brief 获取复合字幕与极角垂直的张角。只对全景图复合字幕有效
 *  \param captionIndex 字幕索引号.-1 代表整个复合字幕
 *  \return 返回复合字幕与极角垂直的张角，单位为角度
 *  \endif
 *  \since 3.7.3
 */
-(float)getOrthoAngleRange:(int)captionIndex;

/*! \if ENGLISH
 *  \brief Sets the horizontal scaling factor for the compound caption. It's only valid for the panorama compound captions.
 *  \param scaleX The horizontal scaling factor
 *  \else
 *  \brief 对复合字幕设置水平缩放系数。只对全景图复合字幕有效
 *  \param scaleX 水平缩放系数
 *  \endif
 *  \since 3.7.3
*/
-(void)setPanoramicScaleX:(float)scaleX;

/*! \if ENGLISH
 *  \brief Gets the horizontal scaling factor for the compound caption. It's only valid for the panorama compound captions.
 *  \return Returns the horizontal scaling factor.
 *  \else
 *  \brief 获取复合字幕水平缩放系数。只对全景图复合字幕有效
 *  \return 返回复合字幕水平缩放系数
 *  \endif
 *  \since 3.7.3
*/
-(float)getPanoramicScaleX;

/*! \if ENGLISH
 *  \brief Sets the vertical scaling factor for the compound caption. It's only valid for the panorama compound captions.
 *  \param scaleY The vertical scaling factor
 *  \else
 *  \brief 对复合字幕设置垂直缩放系数。只对全景图复合字幕有效
 *  \param scaleY 垂直缩放系数
 *  \endif
 *  \since 3.7.3
*/
-(void)setPanoramicScaleY:(float)scaleY;

/*! \if ENGLISH
 *  \brief Gets the vertical scaling factor for the compound caption. It's only valid for the panorama compound captions.
 *  \return Returns the vertical scaling factor.
 *  \else
 *  \brief 获取复合字幕垂直缩放系数。只对全景图复合字幕有效
 *  \return 返回复合字幕垂直缩放系数
 *  \endif
 *  \since 3.7.3
*/
-(float)getPanoramicScaleY;

/*! \if ENGLISH
 *  \brief Sets the rotation angle for the compound caption. It's only valid for the panorama compound captions.
 *  \param rotationAngle The rotation angle
 *  \else
 *  \brief 对复合字幕设置旋转角度。只对全景图复合字幕有效
 *  \param rotationAngle 旋转角度
 *  \endif
 *  \since 3.7.3
*/
-(void)setPanoramicRotation:(float)rotationAngle;

/*! \if ENGLISH
 *  \brief Gets the rotation angle for the compound caption. It's only valid for the panorama compound captions.
 *  \return Returns the rotation angle of the caption.
 *  \else
 *  \brief 获取复合字幕旋转角度。只对全景图复合字幕有效
 *  \return 返回复合字幕旋转角度
 *  \endif
 *  \since 3.7.3
*/
-(float)getPanoramicRotation;
/*! \endcond */
@end

