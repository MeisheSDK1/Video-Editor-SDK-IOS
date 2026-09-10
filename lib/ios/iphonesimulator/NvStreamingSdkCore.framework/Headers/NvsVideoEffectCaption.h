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

#import "NvsEffect.h"
#import <CoreGraphics/CGGeometry.h>

/*!
 *  \if ENGLISH
 *   @name Caption type
 *  \else
 *   @name 字幕种类
 *  \endif
 */
typedef enum NvsVideoEffectCategory
{
    NvsVideoEffectDefaultCategory,   //!< \if ENGLISH Default type \else 默认类型 \endif
    NvsVideoEffectUserCategory,      //!< \if ENGLISH User-defined type \else 用户自定义类型 \endif
    NvsVideoEffectThemeCategory      //!< \if ENGLISH Theme category \else 主题类型 \endif
} NvsVideoEffectCategory;

/*! \if ENGLISH
*   \brief The role of the clip in the theme
*   \else
*   \brief 片段在主题中的角色
*   \endif
*/
typedef enum NvsVideoEffectRoleInTheme
{
    NvsVideoEffectRoleInThemeGeneral,   //!< \if ENGLISH General \else 通用 \endif
    NvsVideoEffectRoleInThemeTitle,     //!< \if ENGLISH Title \else 片头 \endif
    NvsVideoEffectRoleInThemeTrailer    //!< \if ENGLISH Trailer \else 片尾 \endif
} NvsVideoEffectRoleInTheme;

/*! \if ENGLISH
*   \brief Text alignment style
*   \else
*   \brief 字幕对齐方式
*   \endif
*/
typedef enum NvsVideoEffectTextAlignment
{
    NvsVideoEffectTextAlignmentLeft = 0,
    NvsVideoEffectTextAlignmentCenter,
    NvsVideoEffectTextAlignmentRight,
    NvsVideoEffectTextAlignmentTop,
    NvsVideoEffectTextAlignmentBottom,
    NvsVideoEffectTextAlignmentVCenter
} NvsVideoEffectTextAlignment;

/*! \if ENGLISH
*   \brief Uses the default caption package
*   \else
*   \brief 使用默认的字幕包属性
*   \endif
*/
typedef enum NvsVideoEffectAssetDefaultParam
{
    VIDEO_EFFECT_USE_ASSET_DEFAULT_PARAM = 0,
    VIDEO_EFFECT_NOT_USE_ASSET_DEFAULT_PARAM
} NvsVideoEffectAssetDefaultParam;

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
    NvsVideoEffectBoundingType_Text = 0,               //!< \if ENGLISH The actual text bounding \else 文字的实际边框 \endif
    NvsVideoEffectBoundingType_Text_Frame = 1,         //!< \if ENGLISH Text frame bounding \else 文字框的边框 \endif
    NvsVideoEffectBoundingType_Frame = 2,              //!< \if ENGLISH The whole bounding including decoration \else 包括装饰在内的整体边框 \endif
    NvsVideoEffectBoundingType_Text_Origin_Frame = 3,   //!< \if ENGLISH Text frame bounding  that has not been transformed  \else 没有经过变换的文字框的边框 \endif
    NvsVideoEffectBoundingType_Typographic_Text = 4,    //!< \if ENGLISH The typographic text bounding \else 文字的排版边框 \endif
} NvsVideoEffectBoundingType;

/*! \if ENGLISH
*   \brief letter spacing type
*   \else
*   \brief 字间距类型
*   \endif
*/
typedef enum NvsVideoEffectLetterSpacingType
{
    NvsVideoEffectLetterSpacingTypePercentage = 0,
    NvsVideoEffectLetterSpacingTypeAbsolute
} NvsVideoEffectLetterSpacingType;



/*! \if ENGLISH
 *  \brief captions.
 *
 *  captions are custom text that is superimposed on the video. When editing a video, users can create and remove captions and adjust the captions position. After adding captions, user can also set the style, including font size, color, shadow, stroke, etc.
 *  \warning In the NvsVideoEffectCaption class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 字幕
 *
 *  字幕是视频上叠加的自定义文字。编辑视频时，可以创建和移除字幕，并对字幕位置进行调整处理。添加完字幕，还可以进行样式设置，包括字体大小，颜色，阴影，描边等。
 *  \warning
 *  \endif
 *  \since 2.20.0
 */
NVS_EXPORT @interface NvsVideoEffectCaption : NvsEffect

@property (readonly) BOOL isPanoramic;                //!< \if ENGLISH Whether it is a panorama caption \else 是否为全景图字幕 \endif \since 1.6.0
@property (readonly) BOOL isModular;                  //!< \if ENGLISH whether the current caption is a modular caption \else 当前字幕是否为模块字幕 \endif \since 2.15.2
@property (nonatomic) BOOL clipAffinityEnabled;       //!< \if ENGLISH Whether to enable the affinity with clip \else 是否开启与clip的亲和关系 \endif \since 1.7.1
@property (readonly) int64_t inPoint;                 //!< \if ENGLISH The in point of the caption on the timeline(in microseconds) \else 字幕在时间线上显示的入点（单位微秒） \endif
@property (readonly) int64_t outPoint;                //!< \if ENGLISH The out point of the caption on the timeline (in microseconds) \else 字幕在时间线显示上的出点（单位微秒） \endif
@property (readonly) NvsVideoEffectRoleInTheme roleInTheme;      //!< \if ENGLISH The role of captions in the theme (general, title, and trailer.) \else 字幕在主题中的角色(通用、片头、片尾) \endif
@property (readonly) NvsVideoEffectCategory category;            //!< \if ENGLISH Clip type \else 片段类型 \endif
@property (readonly) NSString* captionStylePackageId; //!< \if ENGLISH The package ID of the caption style\else 字幕样式包裹ID \endif \since 2.17.1
@property (readonly) NSString* modularCaptionContextPackageId;      //!< \if ENGLISH The package ID of the modular caption context style \else 模块字幕环境样式包裹ID \endif \since 2.15.2
@property (readonly) NSString* modularCaptionRendererPackageId;     //!< \if ENGLISH The package ID of the modular caption render style \else 模块字幕渲染样式包裹ID \endif \since 2.15.2
@property (readonly) NSString* modularCaptionAnimationPackageId;    //!< \if ENGLISH The package ID of the modular caption animation style \else 模块字幕循环动画样式包裹ID \endif \since 2.15.2
@property (readonly) NSString* modularCaptionInAnimationPackageId;  //!< \if ENGLISH The package ID of the modular caption in-animation style \else 模块字幕入动画样式包裹ID \endif \since 2.15.2
@property (readonly) NSString* modularCaptionOutAnimationPackageId; //!< \if ENGLISH The package ID of the modular caption out-animation style \else 模块字幕出动画样式包裹ID \endif \since 2.15.2

/*! \if ENGLISH
 *  \brief Set the sticker's video resolution
 *  \param resolution The sticker's video resolution
 *  \else
 *  \brief 设置字幕渲染的画幅解析度
 *  \param resolution 画幅解析度
 *  \endif
 *  \since 2.20.0
 */
- (void)setVideoResolution:(NvsEffectVideoResolution)resolution;

/*! \if ENGLISH
 *  \brief Changes the out point of the caption on the timeline.
 *  \param newInPoint The new out point of the caption on the timeline (in microseconds)
 *  \return Returns the in point of the caption which displayed on the timeline (in microseconds).
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 改变字幕在时间线上显示的入点
 *  \param newInPoint 字幕在时间线上的新的入点（单位微秒）
 *  \return 返回字幕在时间线上的显示的入点值（单位微秒）
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa changeOutPoint:
 *  \sa movePosition:
*/
- (int64_t)changeInPoint:(int64_t)newInPoint;

/*! \if ENGLISH
 *  \brief Changes the out point of the caption on the timeline.
 *  \param newOutPoint The new out point of the caption on the timeline (in microseconds)
 *  \return Returns the out point of the caption which displayed on the timeline (in microseconds).
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 改变字幕在时间线上显示的出点
 *  \param newOutPoint 字幕在时间线上的新的出点（单位微秒）
 *  \return 返回字幕在时间线上显示的出点值（单位微秒）
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa changeInPoint:
 *  \sa movePosition:
*/
- (int64_t)changeOutPoint:(int64_t)newOutPoint;

/*! \if ENGLISH
 *  \brief Changes the display position of the caption on the timeline (the in and out points move the value of "offset" at the same time).
 *  \param offset The offset value (in microseconds)
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 改变字幕在时间线上的显示位置(入点和出点同时偏移offset值)
 *  \param offset 偏移值（单位微秒）
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa changeInPoint:
 *  \sa changeOutPoint:
*/
- (void)movePosition:(int64_t)offset;

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
-(bool) applyCaptionStyleWithAssetDefaultParam:(NSString*) captionStylePackageId isUseDefaultAssetParam:(NvsVideoEffectAssetDefaultParam)isUseDefaultAssetParam;

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
- (void)setTextAlignment:(NvsVideoEffectTextAlignment)textAlign;

/*! \if ENGLISH
 *  \brief Gets the caption horizontal alignment method.
 *  \return Returns the caption horizontal alignment method.
 *  \else
 *  \brief 获取字幕水平对齐方式
 *  \return 返回字幕水平对齐方式
 *  \endif
 *  \sa setTextAlignment:
*/
- (NvsVideoEffectTextAlignment)getTextAlignment;

/*! \if ENGLISH
 *  \brief Sets the caption vertical alignment method.
 *  \param textAlign the caption vertical alignment method
 *  \else
 *  \brief 设置字幕垂直对齐方式
 *  \param textVerticalAlign 字幕垂直对齐方式
 *  \endif
 *  \sa getTextVerticalAlignment
 *  \sa setTextAlignment
 *  \since 2.19.1
*/
- (void)setTextVerticalAlignment:(NvsVideoEffectTextAlignment)textVerticalAlign;

/*! \if ENGLISH
 *  \brief Gets the caption vertical alignment method.
 *  \return Returns the caption vertical alignment method.
 *  \else
 *  \brief 获取字幕垂直对齐方式
 *  \return 返回字幕垂直对齐方式
 *  \endif
 *  \sa setTextVerticalAlignment:
 *  \since 2.19.1
*/
- (NvsVideoEffectTextAlignment)getTextVerticalAlignment;

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
- (NvsVideoEffectLetterSpacingType)getLetterSpacingType;

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
- (void)setLetterSpacingType:(NvsVideoEffectLetterSpacingType)letterSpacingType;

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
- (void)setTextColor:(const NvsEffectColor *)textColor;

/*! \if ENGLISH
 *  \brief Gets the current color value of the caption font.
 *  \return Returns the NvsEffectColor object representing the obtained color value.
 *  \else
 *  \brief 获取字幕字体的当前颜色值
 *  \return 返回NvsEffectColor对象，表示获得的颜色值
 *  \endif
 *  \sa setTextColor:
*/
- (NvsEffectColor)getTextColor;

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
- (void)setOutlineColor:(const NvsEffectColor *)outlineColor;

/*! \if ENGLISH
 *  \brief Gets the color of the outline for the caption.
 *  \return  Returns the NvsEffectColor object representing the color of the outline for the caption.
 *  \else
 *  \brief 获取当前字幕描边的颜色值
 *  \return 返回NvsEffectColor对象，表示获得的字幕描边的颜色
 *  \endif
 *  \sa setOutlineColor:
*/
- (NvsEffectColor)getOutlineColor;

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
- (void)setShadowColor:(const NvsEffectColor *)shadowColor;

/*! \if ENGLISH
 *  \brief Gets the color of the caption shadow.
 *  \return Returns the NvsEffectColor object representing the caption shadow color which obtained.
 *  \else
 *  \brief 获取当前字幕阴影的颜色
 *  \return 返回NvsEffectColor对象，表示获得的字幕阴影颜色值
 *  \endif
 *  \sa setShadowColor:
*/
- (NvsEffectColor)getShadowColor;

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
- (void)setTextFrameOriginRect:(NvsEffectRect)rc;

/*! \if ENGLISH
 *  \brief Gets the rectangle of the caption text.
 *  \return Returns the NvsEffectRect object representing the obtained rectangle.
 *  \else
 *  \brief 获取字幕文本矩形框
 *  \return 返回NvsEffectRect对象，表示获得的字幕文本矩形框
 *  \endif
*/
- (NvsEffectRect)getTextBoundingRect:(BOOL)actualBoundingRect;

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
- (NSArray *)getCaptionBoundingVertices:(NvsVideoEffectBoundingType)boundingType;

/*! \if ENGLISH
 *  \brief Sets the polar angle of the center point for the caption. It's only valid for the panorama caption.
 *  \param centerPolarAngle The polar angle of the center point (in degrees).
 *  \else
 *  \brief 对字幕设置中心点的极角。只对全景图字幕有效
 *  \param centerPolarAngle 中心点的极角，单位为角度
 *  \endif
 *  \since 1.6.0
*/
- (void)setCenterPolarAngle:(float)centerPolarAngle;

/*! \if ENGLISH
 *  \brief Gets the polar angle of the center point for the caption. It's only valid for the panorama caption.
 *  \return Returns the polar angle of the center point (in degrees).
 *  \else
 *  \brief 获取字幕中心点的极角。只对全景图字幕有效
 *  \return 返回字幕中心点的极角，单位为角度
 *  \endif
 *  \since 1.6.0
*/
- (float)getCenterPolarAngle;

/*! \if ENGLISH
 *  \brief Gets the polar angle of the center point for the caption text. It's only valid for the panorama caption.
 *  \return Returns the polar angle of the center point (in degrees) for the caption text.
 *  \else
 *  \brief 获取字幕文本中心点的极角。只对全景图字幕有效
 *  \return 返回字幕文本中心点的极角，单位为角度
 *  \endif
 *  \since 2.5.1
*/
- (float)getTextCenterPolarAngle;

/*! \if ENGLISH
 *  \brief Sets the azimuth angle of the center point for the caption. It's only valid for the panorama caption.
 *  \param centerAzimuthAngle the azimuth angle of the center point (in degrees)
 *  \else
 *  \brief 对字幕设置中心点的方位角。只对全景图字幕有效
 *  \param centerAzimuthAngle 中心点的方位角，单位为角度
 *  \endif
 *  \since 1.6.0
*/
- (void)setCenterAzimuthAngle:(float)centerAzimuthAngle;

/*! \if ENGLISH
 *  \brief Gets the azimuth angle of the center point for the caption. It's only valid for the panorama caption.
 *  \return Returns the azimuth angle of the center point (in degrees).
 *  \else
 *  \brief 获取字幕中心点的方位角。只对全景图字幕有效
 *  \return 返回字幕中心点的方位角，单位为角度
 *  \endif
 *  \since 1.6.0
*/

- (float)getCenterAzimuthAngle;

/*! \if ENGLISH
 *  \brief Gets the azimuth angle of the center point for the caption text. It's only valid for the panorama caption.
 *  \return Returns the polar angle of the center point (in degrees).
 *  \else
 *  \brief 获取字幕文本中心点的方位角。只对全景图字幕有效
 *  \return 返回字幕文本中心点的方位角，单位为角度
 *  \endif
 *  \since 2.5.1
*/
- (float)getTextCenterAzimuthAngle;

/*! \if ENGLISH
 *  \brief Sets the ranging angle of the polar angle for the caption. It's only valid for the panorama caption.
 *  \param polarAngleRange the ranging angle of the polar angle (in degrees)
 *  \else
 *  \brief 对字幕设置极角的张角。只对全景图字幕有效
 *  \param polarAngleRange 极角的张角，单位为角度
 *  \endif
 *  \since 1.6.0
*/
- (void)setPolarAngleRange:(float)polarAngleRange;

/*! \if ENGLISH
 *  \brief Gets the ranging angle of the polar angle for the caption. It's only valid for the panorama caption.
 *  \return Returns the ranging angle of the polar angle (in degrees).
 *  \else
 *  \brief 获取字幕极角的张角。只对全景图字幕有效
 *  \return 返回字幕极角的张角，单位为角度
 *  \endif
 *  \since 1.6.0
*/
- (float)getPolarAngleRange;

/*! \if ENGLISH
 *  \brief Gets the ranging angle of the polar angle for the caption text. It's only valid for the panorama caption.
 *  \return Returns the ranging angle of the polar angle for the caption text (in degrees).
 *  \else
 *  \brief 获取字幕文本极角的张角。只对全景图字幕有效
 *  \return 返回字幕文本极角的张角，单位为角度
 *  \endif
 *  \since 2.5.1
*/
- (float)getTextPolarAngleRange;

/*! \if ENGLISH
 *  \brief Gets the ranging angle which is perpendicular with the polar angle for the caption. It's only valid for the panorama caption.
 *  \return Returns the ranging angle which is perpendicular with the polar angle (in degrees).
 *  \else
 *  \brief 获取字幕与极角垂直的张角。只对全景图字幕有效
 *  \return 返回字幕与极角垂直的张角，单位为角度
 *  \endif
 *  \since 1.7.0
*/
- (float)getOrthoAngleRange;

/*! \if ENGLISH
 *  \brief Gets the ranging angle of  which is perpendicular with the polar angle for the caption text. It's only valid for the panorama caption.
 *  \return Returns the ranging angle of  which is perpendicular with the polar angle (in degrees).
 *  \else
 *  \brief 获取字幕文本与极角垂直的张角。只对全景图字幕有效
 *  \return 返回字幕文本与极角垂直的张角，单位为角度
 *  \endif
 *  \since 2.5.1
*/
- (float)getTextOrthoAngleRange;

/*! \if ENGLISH
 *  \brief Sets the horizontal scaling factor for the caption. It's only valid for the panorama caption.
 *  \param scaleX The horizontal scaling factor
 *  \else
 *  \brief 对字幕设置水平缩放系数。只对全景图字幕有效
 *  \param scaleX 水平缩放系数
 *  \endif
 *  \since 1.6.0
*/
- (void)setPanoramicScaleX:(float)scaleX;

/*! \if ENGLISH
 *  \brief Gets the horizontal scaling factor for the caption. It's only valid for the panorama caption.
 *  \return Returns the horizontal scaling factor.
 *  \else
 *  \brief 获取字幕水平缩放系数。只对全景图字幕有效
 *  \return 返回字幕水平缩放系数
 *  \endif
 *  \since 1.6.0
*/
- (float)getPanoramicScaleX;

/*! \if ENGLISH
 *  \brief Sets the vertical scaling factor for the caption. It's only valid for the panorama caption.
 *  \param scaleY The vertical scaling factor
 *  \else
 *  \brief 对字幕设置垂直缩放系数。只对全景图字幕有效
 *  \param scaleY 垂直缩放系数
 *  \endif
 *  \since 1.6.0
*/
- (void)setPanoramicScaleY:(float)scaleY;

/*! \if ENGLISH
 *  \brief Gets the vertical scaling factor for the caption. It's only valid for the panorama caption.
 *  \return Returns the vertical scaling factor.
 *  \else
 *  \brief 获取字幕垂直缩放系数。只对全景图字幕有效
 *  \return 返回字幕垂直缩放系数
 *  \endif
 *  \since 1.6.0
*/
- (float)getPanoramicScaleY;

/*! \if ENGLISH
 *  \brief Sets the rotation angle for the caption. It's only valid for the panorama caption.
 *  \param rotationAngle The rotation angle
 *  \else
 *  \brief 对字幕设置旋转角度。只对全景图字幕有效
 *  \param rotationAngle 旋转角度
 *  \endif
 *  \since 1.7.1
*/
- (void)setPanoramicRotation:(float)rotationAngle;

/*! \if ENGLISH
 *  \brief Gets the rotation angle for the caption. It's only valid for the panorama caption.
 *  \return Returns the rotation angle of the caption.
 *  \else
 *  \brief 获取字幕旋转角度。只对全景图字幕有效
 *  \return 返回字幕旋转角度
 *  \endif
 *  \since 01.7.1
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
 *  \since 02.11.0
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
- (void)setBackgroundColor:(const NvsEffectColor *)backgroundColor;

/*! \if ENGLISH
 *  \brief Get the current text background color value.
 *  \return Returns the NvsEffectColor object representing the current background color.
 *  \else
 *  \brief 获取字幕文本的当前背景颜色值
 *  \return 返回NvsEffectColor对象，表示当前的文本背景颜色值
 *  \endif
 *  \sa setBackgroundColor:
 *  \since 2.15.1
 */
- (NvsEffectColor)getBackgroundColor;

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
 *  \brief Sets caption secondary color. it is only used in karaoke subtitles now
 *  \param textColor Caption color value.
 *  \else
 *  \brief 设置字幕第二个颜色, 目前只应用在卡拉OK字幕上
 *  \param color 字幕颜色值
 *  \endif
 *  \sa getSecondaryColor
 *  \since 2.19.0
 */
- (void)setSecondaryColor:(const NvsEffectColor *)color;

/*! \if ENGLISH
 *  \brief Gets the current color value of the caption.
 *  \return Returns the NvsEffectColor object representing the color value obtained.
 *  \else
 *  \brief 获取字幕字体的当前第二个颜色值
 *  \return 返回NvsEffectColor对象，表示获得的颜色值
 *  \endif
 *  \sa setSecondaryColor
 *  \since 2.19.0
 */
- (NvsEffectColor)getSecondaryColor;

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
 *  \brief Gets whether the caption is a frame caption.
 *  \return Gets whether the caption is a frame caption.
 *  \else
 *  \brief 获取字幕是否是边框字幕
 *  \return 字幕是否是边框字幕
 *  \endif
 *  \since 2.19.1
 */
- (BOOL)isFrameCaption;

@end
