//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jan 22. 2017
//   Author:        Meishe video team
//================================================================================

#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"
#import "NvsEffectDescription.h"

/*! \if ENGLISH
 *  \brief Effect parameter description class
 *
 *  A variety of different parameter types of effect are set during capturing and editing. The effect parameter description class is used to obtain various effect parameter values.
 *  \warning In the NvsFxDescription class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 特效参数描述类
 *
 *  在视频拍摄和编辑时会设置各种不同参数类型的特效，特效参数描述类就是专门用来获取各种特效参数值的，以便查看和了解。
 *  \warning NvsFxDescription类中，所有public API都在UI线程使用！！！
 *  \endif
 */
NVS_EXPORT @interface NvsFxDescription : NSObject

@property (readonly) NSString *name;    //!< \if ENGLISH \else 特效名称 \endif

/*! \if ENGLISH
*   \brief Get all the effect parameter information.
*   \retval (NSArray *) Return an array object containing a list of all effect parameters.
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
