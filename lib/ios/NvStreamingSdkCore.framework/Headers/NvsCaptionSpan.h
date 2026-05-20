//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    May 17. 2022
//   Author:        Meishe video team
//================================================================================

#pragma once
#import "NvsArbitraryData.h"
#import "NvsCommonDef.h"

/*! \anchor SPAN_TYPE */
/*!
 *  \if ENGLISH
 *   @name Span type
 *  \else
 *   @name Span种类
 *  \endif
 */
//!@{
#define NVS_SPAN_TYPE_COLOR             @"color"  //!< \if ENGLISH The color to set, defalut 1,1,1. type is float. \else 指定所设置的颜色。默认值为1,1,1,类型为float。 \endif
#define NVS_SPAN_TYPE_FONT_SIZE_RATIO   @"fontSizeRatio"  //!< \if ENGLISH The size ratio to set, defalut 1f, type is Float. \else 指定设置的字号比例，默认值为1f，类型为Float。 \endif
#define NVS_SPAN_TYPE_FONT_FAMILY       @"fontFamily"  //!< \if ENGLISH The font for the text, defalut is "", type is String. \else 指定文字的字体，默认值为空字符串，类型为String。 \endif
#define NVS_SPAN_TYPE_WEIGHT            @"weight"  //!< \if ENGLISH Control the size of the font, range [100,900], type is Integer. \else 控制字体的粗细，无默认值，有效值范围为[100, 900]，类型为Integer。 \endif
#define NVS_SPAN_TYPE_ITALIC            @"italic"  //!< \if ENGLISH Whether to use italics for characters within span, type is Boolean. \else 是否对span内的字符使用斜体，类型为Boolean。 \endif
#define NVS_SPAN_TYPE_UNDERLINE         @"underline"  //!< \if ENGLISH Whether to underline characters within span, type is Boolean. \else 是否对span内的字符绘制下划线，类型为Boolean。 \endif
#define NVS_SPAN_TYPE_STRIKEOUT         @"strikeOut"  //!< \if ENGLISH Whether to strikeOut characters within span, type is Boolean. \else 是否对span内的字符绘制删除线，类型为Boolean。 \endif
#define NVS_SPAN_TYPE_OPACITY           @"opacity"  //!< \if ENGLISH Set transparency,default 1, type is Float. \else 用于设置透明度，默认值为1，类型为Float。 \endif
#define NVS_SPAN_TYPE_RENDERERID        @"rendererId"  //!< \if ENGLISH There is a rendererId element inside, type is String. \else 内部含有一个rendercontext package id 如果rendererId span是Style 本身有的，id为：SDK:internalComplexRender0,SDK:internalComplexRender1，类型为String \endif
#define NVS_SPAN_TYPE_OUTLINE_COLOR     @"outlineColor"  //!< \if ENGLISH The outlineColor to set, defalut 1,1,1, type is float. \else 指定所设置描边的颜色。默认值为1,1,1，类型为float。 \endif
#define NVS_SPAN_TYPE_OUTLINE_WIDTH     @"outlineWidth"  //!< \if ENGLISH The outlineWidth to set, defalut 0, type is Float. \else 指定设置的描边宽度，默认值为0f，类型为Float。 \endif
#define NVS_SPAN_TYPE_NORMAL_TEXT       @"normalText"  //!< \if ENGLISH The normalText to set, defalut 0, type is Float. \else 指定设置的普通样式，默认值为0f，类型为Float。 \endif
#define NVS_SPAN_TYPE_BODY_OPACITY      @"bodyOpacity"  //!< \if ENGLISH Used to set the transparency of the text body. The default value is 1, type is Float. \else 用于设置文字本体的透明度，默认值为1，类型为Float。 \endif
#define NVS_SPAN_TYPE_OUTLINE_OPACITY   @"outlineOpacity" //!< \if ENGLISH Used to set the opacity of the text outline. The default value is 1, type is Float. \else 用于设置文字描边的透明度，默认值为1，类型为Float。 \endif
#define NVS_SPAN_TYPE_SHADOW_OPACITY    @"shadowOpacity" //!< \if ENGLISH Used to set the opacity of text shadows. The default value is 1, type is Float. \else 用于设置文字阴影的透明度，默认值为1，类型为Float。 \endif
//!@}
//!

NVS_EXPORT @interface NvsCaptionSpan : NSObject
@property (nonatomic, strong) NSString* type;
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger end;
@end

NVS_EXPORT @interface NvsCaptionColorSpan : NvsCaptionSpan
@property (nonatomic, assign) float r;
@property (nonatomic, assign) float g;
@property (nonatomic, assign) float b;
@end

NVS_EXPORT @interface NvsCaptionFontSizeRatioSpan : NvsCaptionSpan
@property (nonatomic, assign) float fontSizeRatio;
@end

NVS_EXPORT @interface NvsCaptionFontFamilySpan : NvsCaptionSpan
@property (nonatomic, strong) NSString* fontFamily;
@end

NVS_EXPORT @interface NvsCaptionWeightSpan : NvsCaptionSpan
@property (nonatomic, assign) int weight;
@end

NVS_EXPORT @interface NvsCaptionItalicSpan : NvsCaptionSpan
@property (nonatomic, assign) BOOL italic;
@end

NVS_EXPORT @interface NvsCaptionUnderlineSpan : NvsCaptionSpan
@property (nonatomic, assign) BOOL underline;
@end

NVS_EXPORT @interface NvsCaptionStrikeOutSpan : NvsCaptionSpan
@property (nonatomic, assign) BOOL strikeOut;
@end

NVS_EXPORT @interface NvsCaptionOpacitySpan : NvsCaptionSpan
@property (nonatomic, assign) float opacity;
@end

NVS_EXPORT @interface NvsCaptionRendererIdSpan : NvsCaptionSpan
@property (nonatomic, strong) NSString* rendererId;
@end

NVS_EXPORT @interface NvsCaptionOutlineColorSpan : NvsCaptionSpan
@property (nonatomic, assign) float r;
@property (nonatomic, assign) float g;
@property (nonatomic, assign) float b;
@end

NVS_EXPORT @interface NvsCaptionOutlineWidthSpan : NvsCaptionSpan
@property (nonatomic, assign) float outlineWidth;
@end

NVS_EXPORT @interface NvsCaptionNormalTextSpan : NvsCaptionSpan
@property (nonatomic, assign) float outlineWidth;
@end

NVS_EXPORT @interface NvsCaptionBodyOpacitySpan : NvsCaptionSpan
@property (nonatomic, assign) float bodyOpacity;
@end

NVS_EXPORT @interface NvsCaptionOutlineOpacitySpan : NvsCaptionSpan
@property (nonatomic, assign) float outlineOpacity;
@end

NVS_EXPORT @interface NvsCaptionShadowOpacitySpan : NvsCaptionSpan
@property (nonatomic, assign) float shadowOpacity;
@end
