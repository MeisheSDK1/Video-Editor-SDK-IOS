//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Dec 29. 2016
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"

/*! \anchor TEMPLATE_ASSET_KEY */
/*!
 *  \if ENGLISH
 *   @name template asset key
 *  \else
 *   @name 模板资源的键值
 *  \endif
 */

//!@{
#define NVS_TEMPLATE_KEY_REPLACE_ID                   @"MSTemplate-ReplaceId"
#define NVS_TEMPLATE_KEY_FOOTAGE_CAN_REPLACE          @"MSTemplate-FootageCanReplace"
#define NVS_TEMPLATE_KEY_FOOTAGE_ID                   @"MSTemplate-FootageId"
#define NVS_TEMPLATE_KEY_FOOTAGE_NAME                 @"MSTemplate-FootageName"
#define NVS_TEMPLATE_KEY_FOOTAGE_TAGS                 @"MSTemplate-FootageTags"
#define NVS_TEMPLATE_KEY_FOOTAGE_TYPE                 @"MSTemplate-FootageType"
#define NVS_TEMPLATE_KEY_FOOTAGE_NEED_REVERSE         @"MSTemplate-FootageNeedReverse"
#define NVS_TEMPLATE_KEY_CLIP_RAW_WIDTH               @"MSTemplate-ClipRawWidth"
#define NVS_TEMPLATE_KEY_CLIP_RAW_HEIGHT              @"MSTemplate-ClipRawHeight"
#define NVS_TEMPLATE_KEY_VOLUME_TYPE                  @"MSTemplate-VolumeType"
#define NVS_TEMPLATE_KEY_FX_GROUP                     @"MSTemplate-FxGroup"
#define NVS_TEMPLATE_KEY_FOOTAGE_M3U8_NAME            @"MSTemplate-FootageM3U8Name"
#define NVS_TEMPLATE_ASSET_KEY_BEST_SEEK_TIME         @"MSTemplate-BestSeekTime"
#define NVS_TEMPLATE_ASSET_KEY_TRIM_IN                @"MSTemplate-TrimIn"
#define NVS_TEMPLATE_ASSET_KEY_TRIM_OUT               @"MSTemplate-TrimOut"
#define NVS_TEMPLATE_ASSET_KEY_DISPLAY_NAME           @"MSTemplate-DisplayName"

#define NVS_TEMPLATE_KEY_MASK_TYPE                    @"MSTemplate-MaskType"
#define NVS_TEMPLATE_VALUE_MASK_TYPE_LINE             @"MSTemplate-MaskType-Line"
#define NVS_TEMPLATE_VALUE_MASK_TYPE_MIRROR           @"MSTemplate-MaskType-Mirror"
#define NVS_TEMPLATE_VALUE_MASK_TYPE_CIRCLE           @"MSTemplate-MaskType-Circle"
#define NVS_TEMPLATE_VALUE_MASK_TYPE_RECT             @"MSTemplate-MaskType-Rect"
#define NVS_TEMPLATE_VALUE_MASK_TYPE_HEART            @"MSTemplate-MaskType-Heart"
#define NVS_TEMPLATE_VALUE_MASK_TYPE_STAR             @"MSTemplate-MaskType-Star"
#define NVS_TEMPLATE_VALUE_MASK_TYPE_CUT              @"MSTemplate-MaskType-Cut"

#define NVS_TEMPLATE_KEY_CURVE_SPEED_TYPE             @"MSTemplate-CurveSpeedType"
#define NVS_TEMPLATE_VALUE_CURVE_SPEED_TYPE_CUSTOM    @"MSTemplate-CurveSpeedType-Custom"
#define NVS_TEMPLATE_VALUE_CURVE_SPEED_TYPE_MONTAGE   @"MSTemplate-CurveSpeedType-Montage"
#define NVS_TEMPLATE_VALUE_CURVE_SPEED_TYPE_HERO      @"MSTemplate-CurveSpeedType-Hero"
#define NVS_TEMPLATE_VALUE_CURVE_SPEED_TYPE_BULLET    @"MSTemplate-CurveSpeedType-bullet"
#define NVS_TEMPLATE_VALUE_CURVE_SPEED_TYPE_PLUS      @"MSTemplate-CurveSpeedType-Plus"
#define NVS_TEMPLATE_VALUE_CURVE_SPEED_TYPE_IN        @"MSTemplate-CurveSpeedType-In"
#define NVS_TEMPLATE_VALUE_CURVE_SPEED_TYPE_OUT       @"MSTemplate-CurveSpeedType-Out"

//!@}

/*! \if ENGLISH
 *  \brief The NvsObject class inherits from the NSObject class in object-c.
 *
 *  The NvsObject class is the base class for most classes in the SDK. Through the NvsObject class, other classes inherit some basic interface with the object-c language compilation system and get the ability to behave as an object in its instance.
 *  \warning In the NvsObject class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief NvsObject类，继承自object-c里的NSObject类。
 *
 *  NvsObject类是SDK里大多数类的基类，通过NvsObject类，其他类继承了一些基础的与object-c语言编译系统之间的接口，并且获得了在它的实例中表现为一个对象的能力。
 *  \warning NvsObject类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsObject : NSObject

/*! \if ENGLISH
*   \brief Adds an attachment to the NvsObject object to identify the object of the NvsObject or for other purposes.
*   \param key The key corresponding to the attachment to be added.
*   \param value Attachment to be added.
*   \else
*   \brief 给NvsObject对象添加附件，用来标识NvsObject的对象或者用于其他用途
*   \param key 要添加的附件所对应的key
*   \param value 要添加的附件
*   \endif
*   \since 1.11.1
*   \sa getAttachment:
*/
- (void)setAttachment:(NSObject*)value forKey:(NSString*)key;

/*! \if ENGLISH
 *   \brief Adds additional template data to the NvsObject object to identify the NvsObject template object
 *   \param key The key of the attachment to be added(@ref NVS_TEMPLATE_KEY_REPLACE_ID)
 *   \param value Attachment to be added
 *   \else
 *   \brief 为NvsObject对象添加模板资源的附加数据，用来标识NvsObject的模板数据
 *   \param key 要添加的附件的key(@ref NVS_TEMPLATE_KEY_REPLACE_ID)
 *   \param value 要添加的附件
 *   \endif
 *   \since 2.18.1
 *   \sa getTemplateAttachment
 */
- (void)setTemplateAttachment:(NSString*)value forKey:(NSString*)key;

/*! \if ENGLISH
*   \brief Gets attached attachments.
*   \param key The key corresponding to the attachment
*   \return Returns the attachment corresponding to the key.
*   \else
*   \brief 获取已经添加的附件
*   \param key 附件所对应的key
*   \return 返回key所对应的附件
*   \endif
*   \since 1.11.1
*   \sa setAttachment:forKey:
*/
- (NSObject*)getAttachment:(NSString*)key;

/*! \if ENGLISH
 *   \brief Gets an template attachment to NvsObject.
 *   \param key the key that has been added attachment.(@ref NVS_TEMPLATE_KEY_REPLACE_ID)
 *   \return Returns the attachment corresponding to the key.
 *   \else
 *   \brief 获取NvsObject的模板资源附件
 *   \param key 已添加附件的key(@ref NVS_TEMPLATE_KEY_REPLACE_ID)
 *   \return 返回key对应的附件
 *   \endif
 *   \since 2.18.1
 *   \sa setTemplateAttachment
 */
- (NSString*)getTemplateAttachment:(NSString*)key;

@end

