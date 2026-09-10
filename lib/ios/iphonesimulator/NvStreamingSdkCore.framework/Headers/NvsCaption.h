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
#import "NvsTimelineCompoundCaption.h"
#import "NvsCaptionSpan.h"
#import "NvsCaptionTextLayout.h"

/*! \if ENGLISH
 *  \brief captions.
 *
 *  captions are custom text that is superimposed on the video. When editing a video, users can add and remove timeline captions and adjust the captions position. After adding captions, user can also set the style, including font size, color, shadow, stroke, etc.
 *  \warning In the NvsCaption class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 时间线字幕
 *
 *  字幕是视频上叠加的自定义文字。编辑视频时，可以添加和移除字幕，并对字幕位置进行调整处理。添加完字幕，还可以进行样式设置，包括字体大小，颜色，阴影，描边等。
 *  \warning
 *  \endif
 */
NVS_EXPORT @interface NvsCaption : NvsFx

@property (readonly) BOOL isPanoramic;                //!< \if ENGLISH Whether it is a panorama caption \else 是否为全景图字幕 \endif \since 1.6.0
@property (readonly) BOOL isModular;                  //!< \if ENGLISH whether the current caption is a modular caption \else 当前字幕是否为模块字幕 \endif \since 2.15.2
@property (readonly) NvsRoleInTheme roleInTheme;      //!< \if ENGLISH The role of captions in the theme (general, title, and trailer.) \else 字幕在主题中的角色(通用、片头、片尾) \endif
@property (readonly) NvsCategory category;            //!< \if ENGLISH Clip type \else 片段类型 \endif
@property (readonly) NSString* captionStylePackageId; //!< \if ENGLISH The package ID of the caption style\else 字幕样式包裹ID \endif \since 2.17.1
@property (readonly) NSString* modularCaptionContextPackageId;      //!< \if ENGLISH The package ID of the modular caption context style \else 模块字幕环境样式包裹ID \endif \since 2.15.2
@property (readonly) NSString* modularCaptionRendererPackageId;     //!< \if ENGLISH The package ID of the modular caption render style \else 模块字幕渲染样式包裹ID \endif \since 2.15.2
@property (readonly) NSString* modularCaptionAnimationPackageId;    //!< \if ENGLISH The package ID of the modular caption animation style \else 模块字幕循环动画样式包裹ID \endif \since 2.15.2
@property (readonly) NSString* modularCaptionInAnimationPackageId;  //!< \if ENGLISH The package ID of the modular caption in-animation style \else 模块字幕入动画样式包裹ID \endif \since 2.15.2
@property (readonly) NSString* modularCaptionOutAnimationPackageId; //!< \if ENGLISH The package ID of the modular caption out-animation style \else 模块字幕出动画样式包裹ID \endif \since 2.15.2

/*! \if ENGLISH
 *  \brief Apply the caption style.
 *  \param captionStylePackageId The resource package ID of the caption style
 *  \return Returns bool value. True means it use caption style successfully, and false means it fails.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 运用字幕样式
 *  \param captionStylePackageId 字幕样式资源包ID
 *  \return 返回bool值。true表示成功运用字幕样式，false则运用失败
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
*/
-(bool) applyCaptionStyle:(NSString*) captionStylePackageId;

/*! \if ENGLISH
 *  \brief Applys modular caption context style.
 *  \param captionContextPackageId Modular caption context style resource package ID.
 *  \return Returns boolean value. True means a successful application, false means a failure.
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change](\ref EngineChange.md).
 *  \else
 *  \brief 运用模块字幕环境样式包
 *  \param captionContextPackageId 字幕环境样式资源包ID
 *  \return 返回boolean值。true表示成功运用，false则运用失败
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
 *  \endif
 *  \sa getModularCaptionContextPackageId
 *  \since 2.15.2
 */
-(bool) applyModularCaptionContext:(NSString*) captionContextPackageId;

/*! \if ENGLISH
 *  \brief Applys modular caption render style.
 *  \param captionRendererPackageId Modular caption render style resource package ID.
 *  \return Returns boolean value. True means a successful application, false means a failure.
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change](\ref EngineChange.md).
 *  \else
 *  \brief 运用模块字幕渲染样式包
 *  \param captionRendererPackageId 字幕渲染样式资源包ID
 *  \return 返回boolean值。true表示成功运用，false则运用失败
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
 *  \endif
 *  \sa getModularCaptionRenderPackageId
 *  \since 2.15.2
 */
-(bool) applyModularCaptionRenderer:(NSString*) captionRendererPackageId;

/*! \if ENGLISH
 *  \brief Applys modular caption loop-animation style.
 *  \param captionAnimationPackageId Modular caption loop-animation style resource package ID.
 *  \return Returns boolean value. True means a successful application, false means a failure.
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change](\ref EngineChange.md).
 *  \else
 *  \brief 运用模块字幕循环动画样式包
 *  \param captionAnimationPackageId 字幕循环动画样式资源包ID
 *  \return 返回boolean值。true表示成功运用，false则运用失败
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
 *  \endif
 *  \sa getModularCaptionAnimationPackageId
 *  \since 2.15.2
 */
-(bool) applyModularCaptionAnimation:(NSString*) captionAnimationPackageId;

/*! \if ENGLISH
 *  \brief Applys modular caption in-animation style. Notes：please set loop-Animation to null before you set in-animation, otherwise it will NOT works
 *  \param captionInAnimationPackageId Modular caption in-animation style resource package ID.
 *  \return Returns boolean value. True means a successful application, false means a failure.
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change](\ref EngineChange.md).
 *  \else
 *  \brief 运用模块字幕入动画样式包。注意：如果已经应用了循环动画样式包，需要先把循环动画设置为null，否则不生效
 *  \param captionInAnimationPackageId 字幕入动画样式资源包ID
 *  \return 返回boolean值。true表示成功运用，false则运用失败
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
 *  \endif
 *  \sa getModularCaptionInAnimationPackageId
 *  \since 2.15.2
 */
-(bool) applyModularCaptionInAnimation:(NSString*) captionInAnimationPackageId;

/*! \if ENGLISH
 *  \brief Applys modular caption out-animation style.Notes：please set loop-Animation to null before you set out-animation, otherwise it will NOT works
 *  \param captionOutAnimationPackageId Modular caption out-animation style resource package ID.
 *  \return Returns boolean value. True means a successful application, false means a failure.
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change](\ref EngineChange.md).
 *  \else
 *  \brief 运用模块字幕出动画样式包. 注意：如果已经应用了循环动画样式包，需要先把循环动画设置为null，否则不生效
 *  \param captionOutAnimationPackageId 字幕出动画样式资源包ID
 *  \return 返回boolean值。true表示成功运用，false则运用失败
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
 *  \endif
 *  \sa getModularCaptionOutAnimationPackageId
 *  \since 2.15.2
 */
-(bool) applyModularCaptionOutAnimation:(NSString*) captionOutAnimationPackageId;

/*! \if ENGLISH
 *  \brief Set modular caption Animation Peroid
 *  \param periodInMS Animation peroid in million second
 *  \else
 *  \brief 设置模块字幕循环动画的周期
 *  \param periodInMS 周期的时间，注意：单位是毫秒
 *  \endif
 *  \sa getModularCaptionAnimationPeroid
 *  \since 2.15.2
 */
-(void) setModularCaptionAnimationPeroid:(int)periodInMS;

/*! \if ENGLISH
 *  \brief Get modular caption Animation Peroid
 *  \return Return animation peroid in million second
 *  \else
 *  \brief 获取模块字幕循环动画的周期
 *  \return 返回模块字幕的动画周期，注意：单位是毫秒
 *  \endif
 *  \sa setModularCaptionAnimationPeroid
 *  \since 2.15.2
 */
-(int) getModularCaptionAnimationPeroid;

/*! \if ENGLISH
 *  \brief Set modular caption in-animation duration
 *  \param inAnimationDurationInMS in-animation duration in million second
 *  \else
 *  \brief 设置模块字幕入动画的时长
 *  \param inAnimationDurationInMS 入动画的时长，注意：单位是毫秒
 *  \endif
 *  \sa getModularCaptionInAnimationDuration
 *  \since 2.15.2
 */
-(void) setModularCaptionInAnimationDuration:(int)inAnimationDurationInMS;

/*! \if ENGLISH
 *  \brief Get modular caption in-animation duration
 *  \return Return in-animation duration in million second
 *  \else
 *  \brief 获取模块字幕入动画的时长
 *  \return 返回模块字幕入动画的时长，注意：单位是毫秒
 *  \endif
 *  \sa setModularCaptionInAnimationDuration
 *  \since 2.15.2
 */
-(int) getModularCaptionInAnimationDuration;

/*! \if ENGLISH
 *  \brief Set modular caption out-animation duration
 *  \param outAnimationDurationInMS out-animation duration in million second
 *  \else
 *  \brief 设置模块字幕出动画的时长
 *  \param outAnimationDurationInMS 出动画的时长，注意：单位是毫秒
 *  \endif
 *  \sa getModularCaptionOutAnimationDuration
 *  \since 2.15.2
 */
-(void) setModularCaptionOutAnimationDuration:(int)outAnimationDurationInMS;

/*! \if ENGLISH
 *  \brief Get modular caption out-animation duration
 *  \return Return out-animation duration in million second
 *  \else
 *  \brief 获取模块字幕出动画的时长
 *  \return 返回模块字幕出动画的时长，注意：单位是毫秒
 *  \endif
 *  \sa setModularCaptionOutAnimationDuration
 *  \since 2.15.2
 */
-(int) getModularCaptionOutAnimationDuration;

/*! \if ENGLISH
 *  \brief apply the caption style.
 *  \param captionStylePackageId The resource package ID of the caption style
 *  \param isUseDefaultAssetParam Whether to use the default material parameters.
 *  \return Returns bool value. True means it use caption style successfully, and false means it fails.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 运用字幕样式
 *  \param captionStylePackageId 字幕样式资源包ID
 *  \param isUseDefaultAssetParam 是否使用默认素材参数
 *  \return 返回bool值。true表示成功运用字幕样式，false则运用失败
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
*/
-(bool) applyCaptionStyleWithAssetDefaultParam:(NSString*) captionStylePackageId isUseDefaultAssetParam:(NvsAssetDefaultParam)isUseDefaultAssetParam;

/*! \if ENGLISH
 *  \brief Set the caption text.
 *  \param text The caption text
 *  \else
 *  \brief 设置字幕文本
 *  \param text 字幕文本
 *  \endif
 *  \sa getText
*/
- (void)setText:(NSString *)text;

/*! \if ENGLISH
 *  \brief Gets the caption text.
 *  \return Returns the obtained caption text.
 *  \else
 *  \brief 获取字幕文本
 *  \return 返回获取的字幕文本
 *  \endif
 *  \sa setText:
*/
- (NSString *)getText;

/*! \if ENGLISH
 *  \brief Sets whether the caption is vertical layout.
 *  \param verticalLayout Indicates whether the caption is vertical layout.YES means it is vertical layout, NO means it is not.
 *  \else
 *  \brief 设置字幕是否为竖版布局
 *  \param verticalLayout 表示字幕是否为竖版布局，YES表示是竖版布局，NO则为水平布局。
 *  \endif
 *  \sa getVerticalLayout
*/
- (void)setVerticalLayout:(BOOL)verticalLayout;

/*! \if ENGLISH
 *  \brief Gets the state whether the caption is vertical layout.
 *  \return Returns the state whether the caption vertical layout. YES means it is vertical layout, NO means it is not.
 *  \else
 *  \brief 获取字幕布局状态
 *  \return 返回字幕布局状态，YES表示字幕为竖版布局，NO则水平布局。
 *  \endif
 *  \sa setVerticalLayout:
*/
- (BOOL)getVerticalLayout;

/*! \if ENGLISH
 *  \brief Sets the caption horizontal alignment method.
 *  \param textAlign the caption horizontal alignment method
 *  \else
 *  \brief 设置字幕水平对齐方式
 *  \param textAlign 字幕水平对齐方式
 *  \endif
 *  \sa getTextAlignment
 *  \sa setTextVerticalAlignment
*/
- (void)setTextAlignment:(NvsTextAlignment)textAlign;

/*! \if ENGLISH
 *  \brief Gets the caption horizontal alignment method.
 *  \return Returns the caption horizontal alignment method.
 *  \else
 *  \brief 获取字幕水平对齐方式
 *  \return 返回字幕水平对齐方式
 *  \endif
 *  \sa setTextAlignment:
*/
- (NvsTextAlignment)getTextAlignment;

/*! \if ENGLISH
 *  \brief Sets the caption vertical alignment method, valid for frame-caption only.
 *  \param textAlign the caption vertical alignment method
 *  \else
 *  \brief 设置字幕垂直对齐方式，仅边框型字幕有效
 *  \param textVerticalAlign 字幕垂直对齐方式
 *  \endif
 *  \sa getTextVerticalAlignment
 *  \sa setTextAlignment
 *  \since 2.19.1
*/
- (void)setTextVerticalAlignment:(NvsTextAlignment)textVerticalAlign;

/*! \if ENGLISH
 *  \brief Gets the caption vertical alignment method, valid for frame-caption only.
 *  \return Returns the caption vertical alignment method.
 *  \else
 *  \brief 获取字幕垂直对齐方式，仅边框型字幕有效
 *  \return 返回字幕垂直对齐方式
 *  \endif
 *  \sa setTextVerticalAlignment:
 *  \since 2.19.1
*/
- (NvsTextAlignment)getTextVerticalAlignment;

/*! \if ENGLISH
 *  \brief Sets whether the caption font is bold.
 *  \param bold Indicates whether the caption font is bold.YES means it is bold, NO means it is not.
 *  \else
 *  \brief 设置字幕字体是否加粗
 *  \param bold 表示字幕字体是否加粗，YES表示加粗，NO则不加粗。
 *  \endif
 *  \sa getBold
*/
- (void)setBold:(BOOL)bold;

/*! \if ENGLISH
 *  \brief Gets the state whether the caption font is bold.
 *  \return Returns the state whether the caption font is bold. YES means it is bold, NO means it is not.
 *  \else
 *  \brief 获取字幕字体加粗状态
 *  \return 返回字幕字体加粗状态，YES表示字体已加粗，NO则字体未加粗。
 *  \endif
 *  \sa setBold:
*/
- (BOOL)getBold;

/*! \if ENGLISH
 *  \brief Sets caption weight.
 *  \param weight the value in opentype weight integer.
 *  \else
 *  \brief 设置字幕权重
 *  \param weight opentype中的权重值
 *  \endif
 *  \sa getWeight
 */
- (void)setWeight:(int)weight;

/*! \if ENGLISH
 *  \brief Gets the caption weight.
 *  \return Returns the caption weight.
 *  \else
 *  \brief 获取字幕权重值
 *  \return 字幕权重值
 *  \endif
 *  \sa setWeight
 */
- (int)getWeight;

/*! \if ENGLISH
 *  \brief Sets whether the caption font is italic.
 *  \param italic Whether it is italic. YES means the caption font is italic, and NO means it is not.
 *  \else
 *  \brief 设置字幕字体是否是斜体
 *  \param italic 是否是斜体。YES表示设置字幕字体为斜体，NO则不设为斜体
 *  \endif
 *  \sa getItalic
*/
- (void)setItalic:(BOOL)italic;

/*! \if ENGLISH
 *  \brief Gets the state whether the caption font is italic.
 *  \return Returns boolean value. YES means the caption font is italic. NO means it is not.
 *  \else
 *  \brief 获取字幕斜体状态
 *  \return 返回BOOL值，YES表示是斜体字体，NO则不是斜体
 *  \endif
 *  \sa setItalic:
*/
- (BOOL)getItalic;

/*! \if ENGLISH
 *  \brief Sets caption under line.
 *  \param underline Whether it is set to under line.
 *  \else
 *  \brief 设置字幕下划线
 *  \param underline 是否设置下划线
 *  \endif
 *  \sa getUnderline
 */
- (void)setUnderline:(BOOL)underline;

/*! \if ENGLISH
 *  \brief Gets the caption under line.
 *  \return Returns boolean value. True means it is under line, false means it is not.
 *  \else
 *  \brief 获取字幕下划线状态
 *  \return 返回boolean值，true表示是下划线，false则不是下划线
 *  \endif
 *  \sa setUnderline
 */
- (BOOL)getUnderline;

/*! \if ENGLISH
 *  \brief Sets caption strike out.
 *  \param strikeOut Whether it is set to strike out.
 *  \else
 *  \brief 设置字幕删除线
 *  \param strikeOut 是否设置删除线
 *  \endif
 *  \sa getStrikeOut
 */
- (void)setStrikeOut:(BOOL)strikeOut;

/*! \if ENGLISH
 *  \brief Gets the caption strike out.
 *  \return Returns boolean value. True means it is strike out, false means it is not.
 *  \else
 *  \brief 获取字幕删除线状态
 *  \return 返回boolean值，true表示是删除线，false则不是删除线
 *  \endif
 *  \sa setStrikeOut
 */
- (BOOL)getStrikeOut;

/*! \if ENGLISH
 *  \brief Gets caption word spacing.
 *  \return Returns the float value, the percentage value by default.(@ref LETTER_SPACING_TYPE)
 *  \else
 *  \brief 获取字幕字间距
 *  \return 返回float值，类型默认百分比值。(@ref LETTER_SPACING_TYPE)
 *  \endif
 *  \sa setLetterSpacing
 *  \sa setLetterSpacingType
 *  \since 1.16.0
 */
- (float)getLetterSpacing;

/*! \if ENGLISH
 *  \brief Sets caption word spacing.
 *  \param letterSpacing Word spacing is expressed in percentage value by default. (@ref LETTER_SPACING_TYPE)
 *  \else
 *  \brief 设置字幕字间距
 *  \param letterSpacing 字间距，类型默认百分比。(@ref LETTER_SPACING_TYPE)
 *  \endif
 *  \sa getLetterSpacing
 *  \sa setLetterSpacingType
 *  \since 1.16.0
 */
- (void)setLetterSpacing:(float)letterSpacing;

/*! \if ENGLISH
 *  \brief Gets caption word spacing type.
 *  \return return letterSpacingType.(@ref LETTER_SPACING_TYPE)
 *  \else
 *  \brief 获取字幕字间距类型
 *  \return 返回字间距类型 (@ref LETTER_SPACING_TYPE)
 *  \endif
 *  \sa setLetterSpacingType
 *  \since 2.15.1
 */
- (NvsLetterSpacingType)getLetterSpacingType;

/*! \if ENGLISH
 *  \brief Sets caption word spacing type.
 *  \param letterSpacingType Word spacing type.(@ref LETTER_SPACING_TYPE)
 *  \else
 *  \brief 设置字幕字间距类型
 *  \param letterSpacingType 字间距类型. (@ref LETTER_SPACING_TYPE)
 *  \endif
 *  \sa getLetterSpacingType
 *  \since 2.15.1
 */
- (void)setLetterSpacingType:(NvsLetterSpacingType)letterSpacingType;

/*! \if ENGLISH
 *  \brief Gets caption line spacing.
 *  \return return float value, line spacing is expressed in absolute value.
 *  \else
 *  \brief 获取字幕行间距
 *  \return 返回float值， 行间距，绝对值
 *  \endif
 *  \sa setLineSpacing
 *  \since 2.15.1
 */
- (float)getLineSpacing;

/*! \if ENGLISH
 *  \brief Sets caption line spacing.
 *  \param lineSpacing line spacing is expressed in absolute value.
 *  \else
 *  \brief 设置字幕行间距
 *  \param lineSpacing 行间距，绝对值
 *  \endif
 *  \sa getLineSpacing
 *  \since 2.15.1
 */
- (void)setLineSpacing:(float)lineSpacing;


/*! \if ENGLISH
 *  \brief Sets the color of the caption text.
 *  \param textColor the color of the caption text
 *  \else
 *  \brief 设置字幕文本颜色
 *  \param textColor 字幕文本颜色值
 *  \endif
 *  \sa getTextColor
*/
- (void)setTextColor:(const NvsColor *)textColor;

/*! \if ENGLISH
 *  \brief Resets the color state of the caption text.
 *  \else
 *  \brief 重置字幕颜色状态
 *  \endif
 *  \sa getTextColor
*/
- (void)resetTextColorState;

/*! \if ENGLISH
 *  \brief Gets the current color value of the caption font.
 *  \return Returns the NvsColor object representing the obtained color value.
 *  \else
 *  \brief 获取字幕字体的当前颜色值
 *  \return 返回NvsColor对象，表示获得的颜色值
 *  \endif
 *  \sa setTextColor:
*/
- (NvsColor)getTextColor;

/*! \if ENGLISH
 *  \brief Sets whether the caption draws the outline.
 *  \param drawOutline whether the caption draws the outline。YES means it draws the outline. NO means it does not.
 *  \else
 *  \brief 设置字幕是否描边
 *  \param drawOutline 是否对字幕描边。YES表示对字幕进行描边，NO则不描边
 *  \endif
 *  \sa getDrawOutline
*/
- (void)setDrawOutline:(BOOL)drawOutline;

/*! \if ENGLISH
 *  \brief Gets the status whether the caption draws the outline.
 *  \return  Returns boolean value. YES means it has drawed the outline. NO means it has not.
 *  \else
 *  \brief 获取字幕描边状态
 *  \return 返回BOOL值，YES表示已描边，NO则未描边
 *  \endif
 *  \sa setDrawOutline:
*/
- (BOOL)getDrawOutline;

/*! \if ENGLISH
 *  \brief Sets the color of the outline for the caption.
 *  \param outlineColor the color of the outline
 *  \else
 *  \brief 设置字幕描边的颜色
 *  \param outlineColor 描边颜色值
 *  \endif
 *  \sa getOutlineColor
*/
- (void)setOutlineColor:(const NvsColor *)outlineColor;

/*! \if ENGLISH
 *  \brief Gets the color of the outline for the caption.
 *  \return  Returns the NvsColor object representing the color of the outline for the caption.
 *  \else
 *  \brief 获取当前字幕描边的颜色值
 *  \return 返回NvsColor对象，表示获得的字幕描边的颜色
 *  \endif
 *  \sa setOutlineColor:
*/
- (NvsColor)getOutlineColor;

/*! \if ENGLISH
 *  \brief Resets the outlinecolor state of the caption text.
 *  \else
 *  \brief 重置字幕描边颜色状态
 *  \endif
 *  \sa getOutlineColor
*/
- (void)resetOutlineColorState;

/*! \if ENGLISH
 *  \brief Sets the width of the outline for the caption.
 *  \param outlineWidth the width of the outline
 *  \else
 *  \brief 设置字幕描边的宽度
 *  \param outlineWidth 描边宽度
 *  \endif
 *  \sa getOutlineWidth
*/
- (void)setOutlineWidth:(float)outlineWidth;

/*! \if ENGLISH
 *  \brief Gets the width of the outline for the caption.
 *  \return Returns the width of the outline for the caption.
 *  \else
 *  \brief 获取当前字幕描边的宽度
 *  \return 返回获得的字幕描边的宽度值
 *  \endif
 *  \sa setOutlineWidth:
*/
- (float)getOutlineWidth;

/*! \if ENGLISH
 *  \brief Sets the caption shadows.
 *  \param drawShadow Whether to set the caption shadow. YES means to set the caption shadow. NO means not.
 *  \else
 *  \brief 设置字幕阴影
 *  \param drawShadow 是否设置字幕阴影。YES表示设置字幕阴影，NO则不设置
 *  \endif
 *  \sa getDrawShadow
*/
- (void)setDrawShadow:(BOOL)drawShadow;

/*! \if ENGLISH
 *  \brief Gets the state of the current caption shadow.
 *  \return Returns BOOL value. YES means the caption has shadow. NO means it is not.
 *  \else
 *  \brief 获取当前字幕阴影状态
 *  \return 返回BOOL值，YES表示有字幕阴影，NO则没有字幕阴影
 *  \endif
 *  \sa setDrawShadow:
*/
- (BOOL)getDrawShadow;

/*! \if ENGLISH
 *  \brief Sets the color of the caption shadow.
 *  \param shadowColor The color of the caption shadow
 *  \else
 *  \brief 设置字幕阴影的颜色
 *  \param shadowColor 字幕阴影颜色值
 *  \endif
 *  \sa getShadowColor
*/
- (void)setShadowColor:(const NvsColor *)shadowColor;

/*! \if ENGLISH
 *  \brief Gets the color of the caption shadow.
 *  \return Returns the NvsColor object representing the caption shadow color which obtained.
 *  \else
 *  \brief 获取当前字幕阴影的颜色
 *  \return 返回NvsColor对象，表示获得的字幕阴影颜色值
 *  \endif
 *  \sa setShadowColor:
*/
- (NvsColor)getShadowColor;

/*! \if ENGLISH
 *  \brief Sets the offset of the caption shadow.
 *  \param shadowOffset The offset of the caption shadow.
 *  \else
 *  \brief 设置字幕阴影的偏移量
 *  \param shadowOffset 字幕阴影的偏移量
 *  \endif
 *  \sa getShadowOffset
*/
- (void)setShadowOffset:(CGPoint)shadowOffset;

/*! \if ENGLISH
 *  \brief Gets the offset of the caption shadow.
 *  \return Returns CGPoint object representing the caption shadow offset which obtained.
 *  \else
 *  \brief 获取当前字幕阴影的偏移量
 *  \return 返回CGPoint对象，表示获得的字幕阴影偏移量
 *  \endif
 *  \sa setShadowOffset:
*/
- (CGPoint)getShadowOffset;

/*! \if ENGLISH
 *  \brief Sets the feathering degree of the caption shadow.
 *  \param feather feathering degree
 *  \else
 *  \brief 设置字幕阴影的羽化程度
 *  \param feather 羽化程度
 *  \endif
 *  \sa getShadowFeather
*/
- (void)setShadowFeather:(float)feather;

/*! \if ENGLISH
 *  \brief Gets the feathering degree of the caption shadow
 *  \return Returns feathering degree
 *  \else
 *  \brief 获取当前字幕阴影的羽化程度
 *  \return 返回羽化程度
 *  \endif
 *  \sa setShadowFeather
*/
- (float)getShadowFeather;

/*! \if ENGLISH
 *  \brief Sets the font size of the caption.
 *  \param fontSize the font size of the caption
 *  \else
 *  \brief 设置字幕字体大小
 *  \param fontSize 字幕字体大小值
 *  \endif
 *  \sa getFontSize
*/
- (void)setFontSize:(float)fontSize;

/*! \if ENGLISH
 *  \brief Gets the font size of the caption.
 *  \return Returns the font size of the caption.
 *  \else
 *  \brief 获取当前字幕的字体大小
 *  \return 返回获得的字幕字体大小值
 *  \endif
 *  \sa setFontSize:
*/
- (float)getFontSize;

/*! \if ENGLISH
 *  \brief Sets the max font size of the frame caption. only apply to frame caption.
 *  \else
 *  \brief 设置边框字幕最大字体大小，只对边框型字幕有效果
 *  \endif
 *  \since 2.19.1
*/
- (void)setFrameCaptionMaxFontSize:(float)maxFontSize;

/*! \if ENGLISH
 *  \brief Sets the caption font.
 *  \param filePath The file path of the caption font. If it's a null string,it's set as the default font.
 *  \else
 *  \brief 设置字幕字体
 *  \param filePath 字幕字体文件路径，若设为空字符串，则设为默认字体
 *  \endif
 *  \since 1.3.0
 *  \sa getFontFilePath
*/
- (void)setFontWithFilePath:(NSString *)filePath;

/*! \if ENGLISH
 *  \brief Gets the file path of the caption font.
 *  \return Returns the file path of the caption font.
 *  \else
 *  \brief 获取字幕字体的文件路径
 *  \return 返回字幕字体的文件路径
 *  \endif
 *  \since 1.3.0
 *  \sa setFontWithFilePath:
*/
- (NSString *)getFontFilePath;

/*! \if ENGLISH
 *  \brief Gets the caption font.
 *  \else
 *  \brief 获取字幕字体
 *  \endif
 *  \since 2.13.3
 *  \sa setFontFamily
*/
- (NSString *)getFontFamily;

/*! \if ENGLISH
 *  \brief Sets the caption font.
 *  \param family The font family. if it's a null string, it's set as the default font.
 *  \else
 *  \brief 设置字幕字体
 *  \param family 字体名字，若设为空字符串，则设为默认字体
 *  \endif
 *  \since 2.4.2
 *  \sa getFontFamily
*/
- (void)setFontFamily:(NSString *)family;

/*! \if ENGLISH
 *  \brief Sets the translation amount of the caption.
 *  \param translation The horizontal and vertical absolute translation of the caption.
 *  \else
 *  \brief 设置字幕的平移量
 *  \param translation 字幕平移的水平和垂直的绝对平移值
 *  \endif
 *  \sa getCaptionTranslation
 *  \sa translateCaption:
*/
- (void)setCaptionTranslation:(CGPoint)translation;

/*! \if ENGLISH
 *  \brief Gets the translation amount of the caption.
 *  \return Returns the CGPoint object indicating the translation amount of the caption which obtained.
 *  \else
 *  \brief 获取字幕的平移量
 *  \return 返回CGPoint对象，表示获得的字幕平移量
 *  \endif
 *  \sa setCaptionTranslation:
*/
- (CGPoint)getCaptionTranslation;

/*! \if ENGLISH
 *  \brief translates the caption.
 *  \param translationOffset The horizontal and vertical offset values for the caption translation
 *  \else
 *  \brief 平移字幕
 *  \param translationOffset 字幕平移的水平和垂直的偏移值
 *  \endif
 *  \since 1.7.0
 *  \sa setCaptionTranslation:
 *  \sa getCaptionTranslation
*/
- (void)translateCaption:(CGPoint)translationOffset;

/*! \if ENGLISH
 *  \brief Sets the caption anchor.
 *  \param anchor Anchor
 *  \else
 *  \brief 设置字幕锚点
 *  \param anchor 锚点
 *  \endif
 *  \since 1.15.0
 *  \sa getAnchorPoint
*/
- (void)setAnchorPoint:(CGPoint)anchor;

/*! \if ENGLISH
 *  \brief Gets the caption anchor.
 *  \return Returns the caption anchor.
 *  \else
 *  \brief 获取字幕锚点
 *  \return 返回字幕锚点
 *  \endif
 *  \since 1.15.0
 *  \sa setAnchorPoint:
*/
- (CGPoint)getAnchorPoint;

/*! \if ENGLISH
 *  \brief Sets the horizontal scaling factor for the caption.
 *  \param scale The horizontal scaling factor
 *  \else
 *  \brief 对字幕设置水平缩放系数
 *  \param scale 水平缩放系数
 *  \endif
 *  \since 1.14.1
 *  \sa getScaleX
 *  \sa setScaleY:
*/
- (void)setScaleX:(float)scale;

/*! \if ENGLISH
 *  \brief Gets the horizontal scaling factor for the caption.
 *  \return Returns the horizontal scaling factor for the caption.
 *  \else
 *  \brief 获取字幕水平缩放系数
 *  \return 返回字幕水平缩放系数
 *  \endif
 *  \since 1.14.1
 *  \sa setScaleX:
 *  \sa getScaleY
*/
- (float)getScaleX;

/*! \if ENGLISH
 *  \brief Sets the vertical scaling factor for the caption.
 *  \param scale the vertical scaling factor
 *  \else
 *  \brief 对字幕设置垂直缩放系数
 *  \param scale 垂直缩放系数
 *  \endif
 *  \since 1.14.1
 *  \sa getScaleY
 *  \sa setScaleX:
*/
- (void)setScaleY:(float)scale;

/*! \if ENGLISH
 *  \brief Gets the vertical scaling factor for the caption.
 *  \return Returns the vertical scaling factor for the caption.
 *  \else
 *  \brief 获取字幕垂直缩放系数
 *  \return 返回字幕垂直缩放系数
 *  \endif
 *  \since 1.14.1
 *  \sa setScaleY:
 *  \sa getScaleX
*/
- (float)getScaleY;

/*! \if ENGLISH
 *  \brief Scales the caption.
 *  \param scaleFactor The scaling factor for the caption
 *  \param anchor The anchor for Scaling the caption
 *  \else
 *  \brief 缩放字幕
 *  \param scaleFactor 字幕缩放的因子
 *  \param anchor 字幕缩放的锚点
 *  \endif
 *  \since 1.8.1
*/
- (void)scaleCaption:(float)scaleFactor anchor:(CGPoint)anchor;

/*! \if ENGLISH
 *  \brief Sets the rotation angle for the caption.
 *  \param angle The rotation angle
 *  \else
 *  \brief 对字幕设置旋转角度
 *  \param angle 旋转角度
 *  \endif
 *  \since 1.14.1
 *  \sa getRotationZ
*/
- (void)setRotationZ:(float)angle;

/*! \if ENGLISH
 *  \brief Gets the rotation angle for the caption.
 *  \return Returns the rotation angle for the caption.
 *  \else
 *  \brief 获取字幕旋转角度
 *  \return 返回字幕旋转角度
 *  \endif
 *  \since 1.14.1
 *  \sa setRotationZ:
*/
- (float)getRotationZ;

/*! \if ENGLISH
 *  \brief Rotates the caption.
 *  \param angle The rotation angle of the caption
 *  \param anchor The rotation anchor of the caption
 *  \else
 *  \brief 旋转字幕
 *  \param angle 字幕旋转的角度
 *  \param anchor 字幕旋转的锚点
 *  \endif
 *  \since 1.8.1
 *  \sa rotateCaption:
*/
- (void)rotateCaption:(float)angle anchor:(CGPoint)anchor;

/*! \if ENGLISH
 *  \brief Rotates the caption with the caption center point as the anchor point.
 *  \param angle The rotation angle of caption
 *  \else
 *  \brief 以字幕中心点为锚点旋转字幕
 *  \param angle 字幕旋转的角度
 *  \endif
 *  \since 1.8.1
 *  \sa rotateCaption:anchor:
*/
- (void)rotateCaption:(float)angle;

/*! \if ENGLISH
 *  \brief Set the original frame size of the frame caption. If the current caption is not a frame caption, this function has no effect. You can get origin frame size
 *  \param rc New frame size.
 *  \else
 *  \brief 设置边框字幕的原始边框大小，如果当前字幕不是边框字幕，该函数没有效果. 可以通过getCaptionBoundingVertices中的BOUNDING_TYPE_TEXT_ORIGIN_FRAME获取原始边框大小
 *  \param rc 新的边框大小
 *  \endif
 *  \sa getCaptionBoundingVertices
 *  \since 2.19.0
 */
- (void)setTextFrameOriginRect:(NvsRect)rc;

/*! \if ENGLISH
 *  \brief Gets the rectangle of the caption text.
 *  \return Returns the NvsRect object representing the obtained rectangle.
 *  \else
 *  \brief 获取字幕文本矩形框
 *  \return 返回NvsRect对象，表示获得的字幕文本矩形框
 *  \endif
*/
- (NvsRect)getTextBoundingRect;

/*! \if ENGLISH
 *  \brief Gets the vertex position of the original enclosing rectangle of the caption after transformation.
 *  \return Returns the NSArray object, the object type is NSValue, and the actual data type is CGPoint, which contains four vertex positions corresponding to the upper left, lower left, lower right, and upper right vertex of the original enclosing rectangle.
 *  \else
 *  \brief 获取字幕的原始包围矩形框变换后的顶点位置
 *  \return 返回NSArray对象，里面的对象类型为NSValue，而实际包含的数据类型为CGPoint，包含四个顶点位置，依次分别对应原始包围矩形框的左上，左下，右下，右上顶点
 *  \endif
 *  \since 1.8.1
*/
- (NSArray *)getBoundingRectangleVertices;

/*! \if ENGLISH
 *  \brief Gets the transformed vertices position of the original caption bounding
 *  \param boundingType Bounding type. Please refer to [Bounding Type] (@ref NvsBoundingType)
 *  \return Returns the NSArray object, the object type is NSValue, and the actual data type is CGPoint, which correspond to the top left, bottom left, bottom right, and top right vertices of the original bounding.
 *  \else
 *  \brief 获取字幕原始边框变换后的顶点位置
 *  \param boundingType 边框类型。请参见[边框类型] [Bounding Type] (@ref NvsBoundingType)
 *  \return 返回NSArray对象，里面的对象类型为NSValue，而实际包含的数据类型为CGPoint，包含四个顶点位置，依次分别对应原始边框的左上，左下，右下，右上顶点
 *  \endif
 *  \since 2.9.0
 */
- (NSArray *)getCaptionBoundingVertices:(NvsBoundingType)boundingType;

/*! \if ENGLISH
 *  \brief Sets the polar angle of the center point for the caption. It's only valid for the panorama caption.
 *  \param centerPolarAngle The polar angle of the center point (in degrees).
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 对字幕设置中心点的极角。只对全景图字幕有效
 *  \param centerPolarAngle 中心点的极角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
*/
- (void)setCenterPolarAngle:(float)centerPolarAngle;

/*! \if ENGLISH
 *  \brief Gets the polar angle of the center point for the caption. It's only valid for the panorama caption.
 *  \return Returns the polar angle of the center point (in degrees).
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取字幕中心点的极角。只对全景图字幕有效
 *  \return 返回字幕中心点的极角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
*/
- (float)getCenterPolarAngle;

/*! \if ENGLISH
 *  \brief Gets the polar angle of the center point for the caption text. It's only valid for the panorama caption.
 *  \return Returns the polar angle of the center point (in degrees) for the caption text.
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取字幕文本中心点的极角。只对全景图字幕有效
 *  \return 返回字幕文本中心点的极角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 2.5.1
*/
- (float)getTextCenterPolarAngle;

/*! \if ENGLISH
 *  \brief Sets the azimuth angle of the center point for the caption. It's only valid for the panorama caption.
 *  \param centerAzimuthAngle the azimuth angle of the center point (in degrees)
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 对字幕设置中心点的方位角。只对全景图字幕有效
 *  \param centerAzimuthAngle 中心点的方位角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
*/
- (void)setCenterAzimuthAngle:(float)centerAzimuthAngle;

/*! \if ENGLISH
 *  \brief Gets the azimuth angle of the center point for the caption. It's only valid for the panorama caption.
 *  \return Returns the azimuth angle of the center point (in degrees).
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取字幕中心点的方位角。只对全景图字幕有效
 *  \return 返回字幕中心点的方位角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
*/

- (float)getCenterAzimuthAngle;

/*! \if ENGLISH
 *  \brief Gets the azimuth angle of the center point for the caption text. It's only valid for the panorama caption.
 *  \return Returns the polar angle of the center point (in degrees).
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取字幕文本中心点的方位角。只对全景图字幕有效
 *  \return 返回字幕文本中心点的方位角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 2.5.1
*/
- (float)getTextCenterAzimuthAngle;

/*! \if ENGLISH
 *  \brief Sets the ranging angle of the polar angle for the caption. It's only valid for the panorama caption.
 *  \param polarAngleRange the ranging angle of the polar angle (in degrees)
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 对字幕设置极角的张角。只对全景图字幕有效
 *  \param polarAngleRange 极角的张角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
*/
- (void)setPolarAngleRange:(float)polarAngleRange;

/*! \if ENGLISH
 *  \brief Gets the ranging angle of the polar angle for the caption. It's only valid for the panorama caption.
 *  \return Returns the ranging angle of the polar angle (in degrees).
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取字幕极角的张角。只对全景图字幕有效
 *  \return 返回字幕极角的张角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
*/
- (float)getPolarAngleRange;

/*! \if ENGLISH
 *  \brief Gets the ranging angle of the polar angle for the caption text. It's only valid for the panorama caption.
 *  \return Returns the ranging angle of the polar angle for the caption text (in degrees).
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取字幕文本极角的张角。只对全景图字幕有效
 *  \return 返回字幕文本极角的张角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 2.5.1
*/
- (float)getTextPolarAngleRange;

/*! \if ENGLISH
 *  \brief Gets the ranging angle which is perpendicular with the polar angle for the caption. It's only valid for the panorama caption.
 *  \return Returns the ranging angle which is perpendicular with the polar angle (in degrees).
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取字幕与极角垂直的张角。只对全景图字幕有效
 *  \return 返回字幕与极角垂直的张角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.7.0
*/
- (float)getOrthoAngleRange;

/*! \if ENGLISH
 *  \brief Gets the ranging angle of  which is perpendicular with the polar angle for the caption text. It's only valid for the panorama caption.
 *  \return Returns the ranging angle of  which is perpendicular with the polar angle (in degrees).
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取字幕文本与极角垂直的张角。只对全景图字幕有效
 *  \return 返回字幕文本与极角垂直的张角，单位为角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 2.5.1
*/
- (float)getTextOrthoAngleRange;

/*! \if ENGLISH
 *  \brief Sets the horizontal scaling factor for the caption. It's only valid for the panorama caption.
 *  \param scaleX The horizontal scaling factor
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 对字幕设置水平缩放系数。只对全景图字幕有效
 *  \param scaleX 水平缩放系数
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
*/
- (void)setPanoramicScaleX:(float)scaleX;

/*! \if ENGLISH
 *  \brief Gets the horizontal scaling factor for the caption. It's only valid for the panorama caption.
 *  \return Returns the horizontal scaling factor.
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取字幕水平缩放系数。只对全景图字幕有效
 *  \return 返回字幕水平缩放系数
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
*/
- (float)getPanoramicScaleX;

/*! \if ENGLISH
 *  \brief Sets the vertical scaling factor for the caption. It's only valid for the panorama caption.
 *  \param scaleY The vertical scaling factor
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 对字幕设置垂直缩放系数。只对全景图字幕有效
 *  \param scaleY 垂直缩放系数
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
*/
- (void)setPanoramicScaleY:(float)scaleY;

/*! \if ENGLISH
 *  \brief Gets the vertical scaling factor for the caption. It's only valid for the panorama caption.
 *  \return Returns the vertical scaling factor.
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取字幕垂直缩放系数。只对全景图字幕有效
 *  \return 返回字幕垂直缩放系数
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.6.0
*/
- (float)getPanoramicScaleY;

/*! \if ENGLISH
 *  \brief Sets the rotation angle for the caption. It's only valid for the panorama caption.
 *  \param rotationAngle The rotation angle
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 对字幕设置旋转角度。只对全景图字幕有效
 *  \param rotationAngle 旋转角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.7.1
*/
- (void)setPanoramicRotation:(float)rotationAngle;

/*! \if ENGLISH
 *  \brief Gets the rotation angle for the caption. It's only valid for the panorama caption.
 *  \return Returns the rotation angle of the caption.
 *  <br>Note: Panorama is not enabled by default after 3.13.0
 *  \else
 *  \brief 获取字幕旋转角度。只对全景图字幕有效
 *  \return 返回字幕旋转角度
 *  <br>注意: 注意：3.13.0以后默认不开启全景功能
 *  \endif
 *  \since 1.7.1
*/
- (float)getPanoramicRotation;

/*! \if ENGLISH
 *  \brief Sets the Z value of the caption.
 *  \param value The Z value
 *  \else
 *  \brief 设置字幕Z值
 *  \param value 字幕Z值
 *  \endif
 *  \sa getZValue
*/
- (void)setZValue:(float)value;

/*! \if ENGLISH
 *  \brief Gets the Z value of the caption.
 *  \return Returns the Z value of the caption.
 *  \else
 *  \brief 获取字幕Z值。
 *  \return 返回字幕Z值。
 *  \endif
 *  \sa setZValue:
*/
- (float)getZValue;

/*! \if ENGLISH
 *  \brief Sets whether to record user actions.
 *  \param recordingUserOperation
 *  \else
 *  \brief 设置字幕是否记录用户的操作
 *  \param recordingUserOperation 字幕是否记录用户操作
 *  \endif
 *  \since 2.11.0
*/
- (void)setRecordingUserOperation:(BOOL)recordingUserOperation;

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
 *  \brief Set text background color
 *  \param backgroundColor Background color value.
 *  \else
 *  \brief 设置字幕文本的背景颜色
 *  \param backgroundColor 文本背景颜色值
 *  \endif
 *  \sa getBackgroundColor:
 *  \since 2.15.1
 */
- (void)setBackgroundColor:(const NvsColor *)backgroundColor;

/*! \if ENGLISH
 *  \brief Get the current text background color value.
 *  \return Returns the NvsColor object representing the current background color.
 *  \else
 *  \brief 获取字幕文本的当前背景颜色值
 *  \return 返回NvsColor对象，表示当前的文本背景颜色值
 *  \endif
 *  \sa setBackgroundColor:
 *  \since 2.15.1
 */
- (NvsColor)getBackgroundColor;

/*! \if ENGLISH
 *  \brief Set text background rectangle's corner radius
 *  \param radius Corner radius value
 *  \else
 *  \brief 设置字幕文本的背景框的圆角半径
 *  \param radius 圆角半径值
 *  \endif
 *  \sa getBackgroundRadius:
 *  \since 2.15.1
 */
- (void)setBackgroundRadius:(float)radius;

/*! \if ENGLISH
 *  \brief Get the current text background rectangle's corner radius value
 *  \return Returns corner radius value
 *  \else
 *  \brief 获取字幕文本的当前背景框的圆角半径
 *  \return 返回圆角半径值
 *  \endif
 *  \sa setBackgroundRadius:
 *  \since 2.15.1
 */
- (float)getBackgroundRadius;


/*! \if ENGLISH
 *  \brief Sets the caption boundary padding ratio.
 *  \param ratio The padding ratio is a multiple of the font size, default is 0.15
 *  \else
 *  \brief 设置字幕边界扩展比率
 *  \param ratio 扩展比率为字体大小的倍数，默认值为0.15
 *  \endif
 *  \sa getBoundaryPaddingRatio
 */
-(void)setBoundaryPaddingRatio:(float)ratio;

/*! \if ENGLISH
 *  \brief Gets the caption boundary padding ratio.
 *  \return Returns padding ratio.
 *  \else
 *  \brief 获取字幕边界扩展比率
 *  \return 扩展比率
 *  \endif
 *  \sa setBoundaryPaddingRatio
 */
-(float)getBoundaryPaddingRatio;

/*! \if ENGLISH
 *  \brief Sets caption secondary color. it is only used in karaoke subtitles now
 *  \param textColor Caption color value.
 *  \else
 *  \brief 设置字幕第二个颜色, 目前只应用在卡拉OK字幕上
 *  \param color 字幕颜色值
 *  \endif
 *  \sa getSecondaryColor
 *  \since 2.19.0
 */
- (void)setSecondaryColor:(const NvsColor *)color;

/*! \if ENGLISH
 *  \brief Gets the current color value of the caption.
 *  \return Returns the NvsColor object representing the color value obtained.
 *  \else
 *  \brief 获取字幕字体的当前第二个颜色值
 *  \return 返回NvsColor对象，表示获得的颜色值
 *  \endif
 *  \sa setSecondaryColor
 *  \since 2.19.0
 */
- (NvsColor)getSecondaryColor;

/*! \if ENGLISH
 *  \brief Sets caption secondary outline color. it is only used in karaoke subtitles now
 *  \param color Caption outline color value.
 *  \else
 *  \brief 设置字幕描边的第二个颜色, 目前只应用在卡拉OK字幕上
 *  \param color 字幕描边颜色值
 *  \endif
 *  \sa getSecondaryOutlineColor
 *  \since 3.1.0
 */
- (void)setSecondaryOutlineColor:(const NvsColor *)color;

/*! \if ENGLISH
 *  \brief Gets the current outline sencondary color value of the caption.
 *  \return Returns the NvsColor object representing the outline sencondary color value obtained.
 *  \else
 *  \brief 获取字幕描边的第二个颜色值
 *  \return 返回NvsColor对象，表示获得的颜色值
 *  \endif
 *  \sa setSecondaryOutlineColor
 *  \since 3.1.0
 */
- (NvsColor)getSecondaryOutlineColor;

/*! \if ENGLISH
 *  \brief Set the caption KeyFrameTime.
 *  \else
 *  \brief 设置字幕的关键帧时间
 *  \endif
 *  \sa setCurrentKeyFrameTime
 *  \since 2.19.1
*/
- (void)setCurrentKeyFrameTime:(int64_t)time;

/*! \if ENGLISH
 *  \brief Set the caption's control point pair.
 *  \param fxParam The type of data parameter for the caption.
 *  \param controlPointPair control point pair.Set the control point to {0, 0}, that is, the current control point is linear interpolation, otherwise it is curve interpolation.
 *  \else
 *  \brief 设置字幕的关键帧控制点对
 *  \param fxParam 字幕参数的类型
 *  \param controlPointPair 控制点对，设置控制点为{0, 0}，即当前控制点为线性插值方式，否则为曲线插值方式
 *  \endif
 *  \sa getControlPoint
 *  \since 2.22.0
 */
- (bool)setControlPoint:(NSString *)fxParam controlPointPair:(NvsControlPointPair *)controlPointPair;

/*! \if ENGLISH
 *  \brief Get the caption's key frame control point pair.
 *  \param fxParam The type of data parameter for the caption.
 *  \return return control point data.If the control point is {0, 0},the current control point interpolation method is linear interpolation.[NvsControlPointPair] (@ref NvsControlPointPair)对象
 *  \else
 *  \brief 返回关键帧控制点对
 *  \param fxParam 字幕参数的类型
 *  \return 返回获得的控制点信息, 如果控制点为{0, 0}说明当前控制点插值方式为线性插值
 *  \endif
 *  \sa setControlPoint: controlPointPair
 *  \since 2.22.0
 */
- (NvsControlPointPair*)getControlPoint:(NSString*)fxParam;

/*! \if ENGLISH
 *  \brief Gets whether the caption is a frame caption.
 *  \return Gets whether the caption is a frame caption.
 *  \else
 *  \brief 获取字幕是否是边框字幕
 *  \return 字幕是否是边框字幕
 *  \endif
 *  \since 2.19.1
 */
- (BOOL)isFrameCaption;

/*! @if ENGLISH
 *  @brief
 *  @param
 *  @return
 *  @else
 *  @brief 用户可以指定字幕中位置从某一起始字符到某一结束字符之间，应用多种layout属性。
 *  @return 是否成功设置。
 *  @endif
 *  \since 3.5.0
*/
- (void)setTextSpanList:(NSArray<NvsCaptionSpan *>*)storyboardCaptionSpanList;

/*! @if ENGLISH
 *  @brief
 *  @param
 *  @else
 *  @brief 获取需要应用多种layout属性
 *  @endif
 *  \since 3.5.0
*/
- (NSArray<NvsCaptionSpan *>*)getTextSpanList;

/*! @if ENGLISH
 *  @brief
 *  @param
 *  @else
 *  @brief 获取字幕layout属性
 *  @endif
 *  \since 3.6.0
*/
- (NvsCaptionTextLayout *)getTextLayout;

/*! @if ENGLISH
 *  @brief Gets the number of complex caption layers.
 *  @return the number of caption layers.
 *  @else
 *  @brief 获取复杂字幕层数。
 *  @return 字幕层数。
 *  @endif
*/
- (int)getComplexRenderLayerCount;

/*! @if ENGLISH
 *  @brief Determine if the current layer has outline
 *  @param layerIndex layer index
 *  @return outline state
 *  @else
 *  @brief 判断当前层是否有描边
 *  @param layerIndex 字幕层数
 *  @return 描边状态
 *  @endif
*/
- (BOOL)hasOutlineLayerInComplexRender:(int)layerIndex;

/*! @if ENGLISH
 *  @brief Gets the outline color value for a layer of complex caption.
 *  @param layerIndex layer index
 *  @return outline color
 *  @else
 *  @brief 获取复杂字幕某层字幕描边颜色值。
 *  @param layerIndex 字幕层数
 *  @return 描边颜色值。
 *  @endif
*/
- (NvsColor)getComplexRenderLayerOutlineColor:(int)layerIndex;

/*! @if ENGLISH
 *  @brief Set the outline color value for a layer of complex caption.
 *  @param layerIndex layer index
 *  @param color color
 *  @return success status
 *  @else
 *  @brief 设置复杂字幕某层字幕描边颜色值。
 *  @param layerIndex 字幕层数
 *  @param color 颜色值
 *  @return 设置成功与否。
 *  @endif
*/
- (BOOL)setComplexRenderLayerOutlineColor:(int)layerIndex color:(NvsColor)color;

/*! @if ENGLISH
 *  @brief Gets the outline width of a layer of complex caption
 *  @param layerIndex layer index
 *  @return outline width
 *  @else
 *  @brief 获取复杂字幕某层字幕描边宽度。
 *  @param layerIndex 字幕层数
 *  @return 描边宽度。
 *  @endif
*/
- (float)getComplexRenderLayerOutlineWidth:(int)layerIndex;

/*! @if ENGLISH
 *  @brief set the outline width of a layer of complex caption
 *  @param layerIndex layer index
 *  @param width outline width
 *  @return success status
 *  @else
 *  @brief 设置复杂字幕某层字幕描边宽度。
 *  @param layerIndex 字幕层数
 *  @param width 描边宽度
 *  @return 设置成功与否
 *  @endif
*/
- (BOOL)setComplexRenderLayerOutlineWidth:(int)layerIndex width:(float)width;

/*! @if ENGLISH
 *  @brief Gets the opacity of a certain layer of complex caption.
 *  @param layerIndex layer index
 *  @return opacity
 *  @else
 *  @brief 获取复杂字幕某层字幕不透明度。
 *  @param layerIndex 字幕层数
 *  @return 不透明度。
 *  @endif
*/
- (float)getComplexRenderLayerOpacity:(int)layerIndex;

/*! @if ENGLISH
 *  @brief set the opacity of a certain layer of complex caption.
 *  @param layerIndex layer index
 *  @param opacity opacity
 *  @return success status
 *  @else
 *  @brief 设置复杂字幕某层字幕不透明度。
 *  @param layerIndex 字幕层数
 *  @param opacity 不透明度
 *  @return 设置成功与否
 *  @endif
*/
- (BOOL)setComplexRenderLayerOpacity:(int)layerIndex opacity:(float)opacity;


@end
