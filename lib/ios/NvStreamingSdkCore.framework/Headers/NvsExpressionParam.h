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
#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"


/*! \if ENGLISH
*   \brief Effect parameter type
*   \else
*   \brief 特效参数类型
*   \endif
*/
typedef enum {
    NvsFxParamTypeInvalid = -1,
    NvsFxParamTypeFirst = 0,
    NvsFxParamTypeArbitrary = 0,
    NvsFxParamTypeInt,
    NvsFxParamTypeFloat,
    NvsFxParamTypeBoolean,
    NvsFxParamTypeMenu,
    NvsFxParamTypeString,
    NvsFxParamTypeColor,
    NvsFxParamTypePosition2D,
    NvsFxParamTypePosition3D,
    NvsFxParamTypeCount,
} NvsFxParamType;

NVS_EXPORT @interface NvsFxParamIntDef : NSObject
@property (nonatomic, assign) int defaultValue; //!< \if ENGLISH The default value \else 默认值 \endif
@property (nonatomic, assign) int minValue;     //!< \if ENGLISH The min value \else 最小值 \endif
@property (nonatomic, assign) int maxValue;     //!< \if ENGLISH The max value \else 最大值 \endif
@end

NVS_EXPORT @interface NvsFxParamFloatDef : NSObject
@property (nonatomic, assign) double defaultValue; //!< \if ENGLISH The default value \else 默认值 \endif
@property (nonatomic, assign) double minValue;     //!< \if ENGLISH The min value \else 最小值 \endif
@property (nonatomic, assign) double maxValue;     //!< \if ENGLISH The max value \else 最大值 \endif
@end

NVS_EXPORT @interface NvsFxParamBOOLDef : NSObject
@property (nonatomic, assign) BOOL defaultValue; //!< \if ENGLISH The default value \else 默认值 \endif
@end

NVS_EXPORT @interface NvsFxParamColorDef : NSObject
@property (nonatomic, assign) NvsColor defaultColor; //!< \if ENGLISH The default value \else 默认值 \endif
@end

NVS_EXPORT @interface NvsExpressionParam : NSObject

@property (nonatomic, strong) NSString *name;  //!< \if ENGLISH The id of caption，The ID value is equal to[getTemplateAttachment()] (@ref com.meicam.sdk.NvsObject.getTemplateAttachment),The KEY used is [TEMPLATE_KEY_REPLACE_ID] (@ref com.meicam.sdk.NvsObject.TEMPLATE_KEY_REPLACE_ID)\else 字幕的id。ID值等同于[getTemplateAttachment()] (@ref com.meicam.sdk.NvsObject.getTemplateAttachment)，用到的KEY为[TEMPLATE_KEY_REPLACE_ID] (@ref com.meicam.sdk.NvsObject.TEMPLATE_KEY_REPLACE_ID) \endif
@property (nonatomic, assign) NvsFxParamType type;            //!< \if Effect parameter type \else 特效参数类型 \endif
@end

NVS_EXPORT @interface NvsExpressionIntParam : NvsExpressionParam

@property (nonatomic, strong) NvsFxParamIntDef *intParam;      //!< \if NvsFxParamIntDef value  \else NvsFxParamIntDef 值 \endif
@end

NVS_EXPORT @interface NvsExpressionFloatParam : NvsExpressionParam

@property (nonatomic, strong) NvsFxParamFloatDef *floatParam;  //!< \if NvsFxParamFloatDef value \else NvsFxParamFloatDef 值 \endif
@end

NVS_EXPORT @interface NvsExpressionBOOLParam : NvsExpressionParam

@property (nonatomic, strong) NvsFxParamBOOLDef *boolParam;    //!< \if NvsFxParamBOOLDef value \else NvsFxParamBOOLDef 值 \endif
@end

NVS_EXPORT @interface NvsExpressionColorParam : NvsExpressionParam

@property (nonatomic, strong) NvsFxParamColorDef *colorParam;  //!< \if NvsFxParamColorDef value \else NvsFxParamColorDef 值 \endif
@end
