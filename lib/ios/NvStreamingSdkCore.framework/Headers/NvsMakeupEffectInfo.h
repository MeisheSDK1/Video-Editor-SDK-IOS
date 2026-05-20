//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Mar 9. 2020
//   Author:        Meishe video team
//================================================================================

#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"
#import "NvsArbitraryData.h"

/*! \anchor MAKEUP_EFFECT_LAYER_TYPE */
/*!
 *  \if ENGLISH
 *   @name Makeup effect layer type.
 *  \else
 *   @name 美妆特效层类型。
 *  \endif
 *  \deprecated
 */
//!@{
typedef enum {
    NvsMakeupEffectLayerType_3D = 0,        //!< \if ENGLISH Makeup 3d layer type \else 美妆三维层 \endif
    NvsMakeupEffectLayerType_Lut = 1,       //!< \if ENGLISH Makeup lut layer type \else 美妆LUT校色层 \endif
    NvsMakeupEffectLayerType_Highlight = 2  //!< \if ENGLISH Makeup highlight layer type \else 美妆高光层 \endif
} NvsMakeupEffectLayerType;
//!@}

/*! \anchor MAKEUP_EFFECT_BLENDING_MODE */
/*!
 *  \if ENGLISH
 *   @name Makeup effect layer blending mode.
 *  \else
 *   @name 美妆特效层叠加模式。
 *  \endif
 *  \deprecated
 */
//!@{
typedef enum {
    NvsMakeupEffectBlendingMode_Unknown = -1,   //!< \if ENGLISH Unknown blending mode \else 无效叠加方式 \endif
    NvsMakeupEffectBlendingMode_Normal = 0,     //!< \if ENGLISH Normal blending mode \else Normal 叠加方式 \endif
    NvsMakeupEffectBlendingMode_Multiply,       //!< \if ENGLISH Multiply blending mode \else Multiply 叠加方式 \endif
    NvsMakeupEffectBlendingMode_Subtract,       //!< \if ENGLISH Subtract blending mode \else Subtract 叠加方式 \endif
    NvsMakeupEffectBlendingMode_Screen,         //!< \if ENGLISH Screen blending mode \else Screen 叠加方式 \endif
    NvsMakeupEffectBlendingMode_Add,            //!< \if ENGLISH Add blending mode \else Add 叠加方式 \endif
    NvsMakeupEffectBlendingMode_Exclusion       //!< \if ENGLISH Exclusion blending mode \else Exclusion 叠加方式 \endif
} NvsMakeupEffectBlendingMode;
//!@}

/*! \anchor MAKEUP_EFFECT_CUSTOM_ENABLED_FLAG */
/*!
 *  \if ENGLISH
 *   @name Makeup effect custom enabled flag.
 *  \else
 *   @name 美妆特效自定义项使能标志。
 *  \endif
 *  \deprecated
 */
//!@{
typedef enum {
    NvsMakeupEffectCustomEnabledFlag_None = 0x00,       //!< \if ENGLISH No custom item \else 无自定义项 \endif
    NvsMakeupEffectCustomEnabledFlag_Lip = 0x01,        //!< \if ENGLISH Enable custom lip \else 自定义嘴唇 \endif
    NvsMakeupEffectCustomEnabledFlag_Eyebrow = 0x02,    //!< \if ENGLISH Enable custom eyebrow \else 自定义眉毛 \endif
    NvsMakeupEffectCustomEnabledFlag_Eyeshadow = 0x04,  //!< \if ENGLISH Enable custom eyeshadow \else 自定义眼影 \endif
    NvsMakeupEffectCustomEnabledFlag_Eyelash = 0x08,    //!< \if ENGLISH Enable custom eyelash \else 自定义睫毛 \endif
    NvsMakeupEffectCustomEnabledFlag_Eyeliner = 0x10,   //!< \if ENGLISH Enable custom eyeliner \else 自定义眼线 \endif
    NvsMakeupEffectCustomEnabledFlag_Blusher = 0x20,    //!< \if ENGLISH Enable custom blusher \else 自定义腮红 \endif
    NvsMakeupEffectCustomEnabledFlag_Shadow = 0x40,     //!< \if ENGLISH Enable custom shadow \else 自定义阴影 \endif
    NvsMakeupEffectCustomEnabledFlag_Highlight = 0x80,  //!< \if ENGLISH Enable custom brighten \else 自定义提亮 \endif
    NvsMakeupEffectCustomEnabledFlag_All = 0xFF         //!< \if ENGLISH Enable all custom makeup \else 自定义所有美妆效果 \endif
} NvsMakeupEffectCustomEnabledFlag;
//!@}

/*! \if ENGLISH
 *  \brief Makeup effect layer information
 *  \else
 *  \brief 美妆特效渲染层数据
 *  \endif
 *  \deprecated
 */
NVS_EXPORT @interface NvsMakeupEffectLayer : NSObject

@property (nonatomic, copy) NSString *layerId;                      //!< \if ENGLISH Makeup effect layer id \else 美妆特效层ID \endif
@property (nonatomic, assign) float intensity;                      //!< \if ENGLISH Effect layer intensity \else 特效层强度 \endif

/*! \if ENGLISH
 *  \brief Effect layer type. For all supported type, please refer to [MAKEUP_EFFECT_LAYER_TYPE].
 *  \else
 *  \brief 特效层类型。支持类型请参见[美妆特效层类型](@ref MAKEUP_EFFECT_LAYER_TYPE)。
 *  \endif
 *  \deprecated
 */
@property (nonatomic, assign) NvsMakeupEffectLayerType type;

@end

/*! \if ENGLISH
 *  \brief Makeup effect 3d layer information
 *  \else
 *  \brief 美妆特效三维渲染层数据
 *  \endif
 *  \deprecated
 */
NVS_EXPORT @interface NvsMakeupEffectLayer3D : NvsMakeupEffectLayer

@property (nonatomic, copy) NSString *texFilePath;          //!< \if ENGLISH Effect layer texture file path \else 特效层纹理文件路径 \endif
/*!
 *  \if ENGLISH
 *  \brief effect layer texture color.
 *
 *          The color is only valid if its alpha is positive, otherwise texture's original color will be used.
 *          Effect layer color has lower priority than effect's.
 *  \else
 *  \brief 特效层纹理颜色
 *
 *          特效层颜色的alpha通道值必须是正的才能生效，否则会用纹理本身的颜色进行渲染。
 *          特效层颜色与特效颜色相比具有更低的优先级。
 *  \endif
 *  \deprecated
 */
@property (nonatomic, assign) NvsColor texColor;

/*! \if ENGLISH
 *  \brief Effect layer blending mode. For all supported mode, please refer to [MAKEUP_EFFECT_BLENDING_MODE].
 *  \else
 *  \brief 特效层叠加模式。支持模式请参见[MAKEUP_EFFECT_BLENDING_MODE](@ref 美妆特效层叠加模式)。
 *  \endif
 *  \deprecated
 */
@property (nonatomic, assign) NvsMakeupEffectBlendingMode blendingMode;

@end

/*! \if ENGLISH
 *  \brief Makeup effect lut layer information
 *  \else
 *  \brief 美妆特效Lut校色渲染层数据
 *  \endif
 *  \deprecated
 */
NVS_EXPORT @interface NvsMakeupEffectLayerLut : NvsMakeupEffectLayer
@property (nonatomic, copy) NSString *lutFilePath;      //!< \if ENGLISH LUT file path \else LUT文件路径 \endif
@end

/*! \if ENGLISH
 *  \brief Makeup effect highlight layer information
 *  \else
 *  \brief 美妆特效高光渲染层数据
 *  \endif
 *  \deprecated
 */
NVS_EXPORT @interface NvsMakeupEffectLayerHighlight : NvsMakeupEffectLayer

@end

/*! \if ENGLISH
 *  \brief Makeup effect information for each part, say eyelash, eyebrow, lips, etc.
 *  \else
 *  \brief 局部美妆特效数据，例如睫毛，眉毛，嘴唇等
 *  \endif
 *  \deprecated
 */
NVS_EXPORT @interface NvsMakeupEffect : NSObject

/*!
 *  \if ENGLISH
 *  \brief effect ID, which is unique and fixed for each effect. Currently supported ids are
 *          "lip", "eyebrow", "eyeshadow", "eyelash", "eyeliner", "blusher", "shadow" and "brighten".
 *  \else
 *  \brief 特效ID，每种特效的ID是固定的且只有一个。现在支持的特效有
 *          "lip", "eyebrow", "eyeshadow", "eyelash", "eyeliner", "blusher", "shadow" and "brighten"。
 *  \endif
 *  \deprecated
 */
@property (nonatomic, copy) NSString *effectId;

/*!
 *  \if ENGLISH
 *  \brief effect texture color.
 *
 *          The color is only valid if its alpha is positive, otherwise texture's original color will be used.
 *          If effect color is used, all textures of this effect's layers will be set.
 *          Effect color has higher priority than layer's.
 *  \else
 *  \brief 特效纹理颜色
 *
 *          特效颜色的alpha通道值必须是正的才能生效，否则会用纹理本身的颜色进行渲染。
 *          一但使用特效颜色，那么属于该特效的渲染层的纹理颜色都会被设置。
 *          特效颜色与特效层颜色相比具有更高的优先级。
 *  \endif
 *  \deprecated
 */
@property (nonatomic, assign) NvsColor color;
@property (nonatomic, assign) float intensity;                                                  //!< \if ENGLISH Effect intensity \else 特效强度 \endif
@property (nonatomic, strong) NSMutableArray<NvsMakeupEffectLayer *> *makeupEffectLayerArray;   //!< \if ENGLISH Effect layers contained \else 包含的特效层 \endif
@end

/*! \if ENGLISH
 *  \brief Makeup effect control parameter set class
 *
 *          Makeup effect control params is a set of effect descriptions on lip, eyebrow, etc.
 *          Each effect is composed by one or multiple rendering layers.
 *  \else
 *  \brief 美妆特效输入控制参数类
 *
 *          美妆特效输入控制参数是一组不同面部特效描述的集合，例如嘴唇，眉毛等,
 *          每个面部特效会包含一个或多个渲染层。
 *  \endif
 *  \since 2.14.0
 *  \deprecated
 */
NVS_EXPORT @interface NvsMakeupEffectInfo : NvsArbitraryData
@property (nonatomic, strong) NSMutableArray<NvsMakeupEffect *> *makeupEffectArray;
@end


