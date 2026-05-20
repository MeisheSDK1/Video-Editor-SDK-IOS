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

/*! \anchor EFFECT_PARAM_TYPE */
/*!
 *  \if ENGLISH
 *   @name effect parameter type
 *  \else
 *   @name 特效参数类型
 *  \endif
*/
//!@{
#define NVS_PARAM_TYPE_INT              @"INT"          //!< \if ENGLISH int type \else 整型 \endif
#define NVS_PARAM_TYPE_FLOAT            @"FLOAT"        //!< \if ENGLISH float type \else 浮点型 \endif
#define NVS_PARAM_TYPE_BOOL             @"BOOL"         //!< \if ENGLISH bool type \else 布尔型 \endif
#define NVS_PARAM_TYPE_MENU             @"MENU"         //!< \if ENGLISH menu type \else 菜单型 \endif
#define NVS_PARAM_TYPE_STRING           @"STRING"       //!< \if ENGLISH string type \else 字符串型 \endif
#define NVS_PARAM_TYPE_COLOR            @"COLOR"        //!< \if ENGLISH color type \else 颜色型 \endif
#define NVS_PARAM_TYPE_POSITION2D       @"POSITION2D"   //!< \if ENGLISH 2D coordinates type \else 二维坐标型 \endif
#define NVS_PARAM_TYPE_POSITION3D       @"POSITION3D"   //!< \if ENGLISH 3D coordinates type \else 三维坐标型 \endif
#define NVS_PARAM_TYPE_ARBITRARY        @"ARBITRARY"    //!< \if ENGLISH custom arbitrary data type \else 自定义数据型 \endif

//!@}

#define NVS_PARAM_NAME                  @"paramName"  //!< \if ENGLISH Effect parameter name \else 特效参数名称 \endif

/*! \if ENGLISH
*   \brief [Special effect parameter type] (@ref EFFECT_PARAM_TYPE)
*   \else
*   \brief [特效参数类型] (@ref EFFECT_PARAM_TYPE)
*   \endif
*/
#define NVS_PARAM_TYPE                  @"paramType"

/*! \if ENGLISH
 *  @name The default value and value range of the effect parameter of integer type
 *  \else
 *  @name 特效参数整数类型的默认值和取值范围
 *  \endif
 */

//!@{
#define NVS_PARAM_INT_DEF_VAL           @"intDefVal"
#define NVS_PARAM_INT_MIN_VAL           @"intMinVal"
#define NVS_PARAM_INT_MAX_VAL           @"intMaxVal"
//!@}

/*! \if ENGLISH
 *  @name The effect's float type parameter default value and value range
 *  \else
 *  @name 特效参数浮点数类型的默认值和取值范围
 *  \endif
 */
//!@{
#define NVS_PARAM_FLOAT_DEF_VAL         @"floatDefVal"
#define NVS_PARAM_FLOAT_MIN_VAL         @"floatMinVal"
#define NVS_PARAM_FLOAT_MAX_VAL         @"floatMaxVal"
//!@}

/*! \if ENGLISH
 *  @name The effect's default boolean type parameter value
 *  \else
 *  @name 特效参数布尔值类型的默认值
 *  \endif
 */
#define NVS_PARAM_BOOL_DEF_VAL          @"boolDefVal"

/*! \if ENGLISH
 *  @name The effect's color type parameter value
 *  \else
 *  @name 特效参数颜色值类型的默认值
 *  \endif
 */
//!@{
#define NVS_PARAM_COLOR_DEF_R           @"colorDefR"
#define NVS_PARAM_COLOR_DEF_G           @"colorDefG"
#define NVS_PARAM_COLOR_DEF_B           @"colorDefB"
#define NVS_PARAM_COLOR_DEF_A           @"colorDefA"
//!@}

/*! \if ENGLISH
 *  @name The effect's 2D coordinates type default value
 *  \else
 *  @name 特效参数二维坐标的默认值
 *  \endif
 */
//!@{
#define NVS_PARAM_POSITION2D_DEF_X      @"position2DDefX"
#define NVS_PARAM_POSITION2D_DEF_Y      @"position2DDefY"
//!@}

/*! \if ENGLISH
 *  @name The effect's 3D coordinates type default value
 *  \else
 *  @name 特效参数三维坐标的默认值
 *  \endif
 */
//!@{
#define NVS_PARAM_POSITION3D_DEF_X      @"position3DDefX"
#define NVS_PARAM_POSITION3D_DEF_Y      @"position3DDefY"
#define NVS_PARAM_POSITION3D_DEF_Z      @"position3DDefZ"
//!@}

/*!
 *  \if ENGLISH
 *   @name Effect string parameter type,please refer to [NvsFxStringParamType] (@ref NvsFxStringParamType)。
 *  \else
 *   @name 特效字符串参数类型，请参见[NvsFxStringParamType] (@ref NvsFxStringParamType)。
 *  \endif
*/
#define NVS_PARAM_STRING_TYPE           @"stringType"

/*!
 *  \if ENGLISH
 *   @name Effect string parameter default value.
 *  \else
 *   @name 特效字符串参数默认值
 *  \endif
*/
#define NVS_PARAM_STRING_DEF            @"stringDef"

/*!
 *  \if ENGLISH
 *   @name Effect menu parameter default value.
 *  \else
 *   @name 特效菜单参数默认值
 *  \endif
*/
#define NVS_PARAM_MENU_DEF_VAL          @"menuDefVal"

/*!
 *  \if ENGLISH
 *   @name Effect menu parameter array.
 *  \else
 *   @name 特效菜单参数数组
 *  \endif
*/
#define NVS_PARAM_MENU_ARRAY            @"menuArray"

/*! \if ENGLISH
*   \brief Effect string parameter type
*   \else
*   \brief 特效字符串参数类型
*   \endif
*/
typedef enum
{
    NvsFxStringParamType_Invalid = -1,     //!< \if ENGLISH Invalid \else 无效 \endif
    NvsFxStringParamType_SingleLine = 0,   //!< \if ENGLISH Single line \else 单行 \endif
    NvsFxStringParamType_MultiLine,        //!< \if ENGLISH Multiple line \else 多行 \endif
    NvsFxStringParamType_FilePath,         //!< \if ENGLISH File path \else 文件路径 \endif
    NvsFxStringParamType_DirectoryPath,    //!< \if ENGLISH Directory path \else 目录路径 \endif
    NvsFxStringParamType_Label             //!< \if ENGLISH Label \else 标签 \endif
} NvsFxStringParamType;

/*! \if ENGLISH
 *  \brief Effect parameter description class in effect sdk
 *
 *  A variety of different parameter types of effect are set during capturing and editing. The effect parameter description class is used to obtain various effect parameter values.
 *  \warning In the NvsFxDescription class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief effect sdk 中的特效参数描述类
 *
 *  在视频拍摄和编辑时会设置各种不同参数类型的特效，特效参数描述类就是专门用来获取各种特效参数值的，以便查看和了解。
 *  \warning NvsFxDescription类中，所有public API都在UI线程使用！！！
 *  \endif
 */
NVS_EXPORT @interface NvsEffectDescription : NSObject

@property (readonly) NSString *name;    //!< \if ENGLISH Effect name \else 特效名称 \endif

/*! \if ENGLISH
*   \brief Gets all the effect parameter information.
*   \retval (NSArray *) Returns an array object containing a list of all effect parameters.
*
*   Detailed description: return type(NSArray *) {(NSDictionary *), ...}
*
*   NSDictionary* Internal structure:
*
*   {
        NVS_PARAM_NAME:               (NSString *)
        NVS_PARAM_TYPE:               (NSString *)
        NVS_PARAM_INT_DEF_VAL:        (NSNumber)
        NVS_PARAM_INT_MIN_VAL:        (NSNumber)
        NVS_PARAM_INT_MAX_VAL:        (NSNumber)
        NVS_PARAM_FLOAT_DEF_VAL:      (NSNumber)
        NVS_PARAM_INT_MIN_VAL:        (NSNumber)
        NVS_PARAM_INT_MAX_VAL:        (NSNumber)
        NVS_PARAM_BOOL_DEF_VAL:       (NSNumber)
        NVS_PARAM_COLOR_DEF_R:        (NSNumber)
        NVS_PARAM_COLOR_DEF_G:        (NSNumber)
        NVS_PARAM_COLOR_DEF_B:        (NSNumber)
        NVS_PARAM_COLOR_DEF_A:        (NSNumber)
        NVS_PARAM_POSITION2D_DEF_X:   (NSNumber)
        NVS_PARAM_POSITION2D_DEF_Y:   (NSNumber)
        NVS_PARAM_POSITION3D_DEF_X:   (NSNumber)
        NVS_PARAM_POSITION3D_DEF_Y:   (NSNumber)
        NVS_PARAM_POSITION3D_DEF_Z:   (NSNumber)
        NVS_PARAM_STRING_TYPE:        (NSNumber)
        NVS_PARAM_STRING_DEF:         (NSString *)
        NVS_PARAM_MENU_DEF_VAL:       (NSString *)
        NVS_PARAM_MENU_ARRAY:         (NSArray *) {(NSString *), ...}
        }
*   \else
*   \brief 获取所有特效参数信息
*   \retval (NSArray *) 返回包含所有特效参数列表的数组对象
*
*   详细描述：返回类型(NSArray *) {(NSDictionary *), ...}

    NSDictionary*内部结构:

        {
        NVS_PARAM_NAME:               (NSString *)
        NVS_PARAM_TYPE:               (NSString *)
        NVS_PARAM_INT_DEF_VAL:        (NSNumber)
        NVS_PARAM_INT_MIN_VAL:        (NSNumber)
        NVS_PARAM_INT_MAX_VAL:        (NSNumber)
        NVS_PARAM_FLOAT_DEF_VAL:      (NSNumber)
        NVS_PARAM_INT_MIN_VAL:        (NSNumber)
        NVS_PARAM_INT_MAX_VAL:        (NSNumber)
        NVS_PARAM_BOOL_DEF_VAL:       (NSNumber)
        NVS_PARAM_COLOR_DEF_R:        (NSNumber)
        NVS_PARAM_COLOR_DEF_G:        (NSNumber)
        NVS_PARAM_COLOR_DEF_B:        (NSNumber)
        NVS_PARAM_COLOR_DEF_A:        (NSNumber)
        NVS_PARAM_POSITION2D_DEF_X:   (NSNumber)
        NVS_PARAM_POSITION2D_DEF_Y:   (NSNumber)
        NVS_PARAM_POSITION3D_DEF_X:   (NSNumber)
        NVS_PARAM_POSITION3D_DEF_Y:   (NSNumber)
        NVS_PARAM_POSITION3D_DEF_Z:   (NSNumber)
        NVS_PARAM_STRING_TYPE:        (NSNumber)
        NVS_PARAM_STRING_DEF:         (NSString *)
        NVS_PARAM_MENU_DEF_VAL:       (NSString *)
        NVS_PARAM_MENU_ARRAY:         (NSArray *) {(NSString *), ...}
        }
*   \endif
*/
- (NSArray *)getAllParamsInfo;

@end
