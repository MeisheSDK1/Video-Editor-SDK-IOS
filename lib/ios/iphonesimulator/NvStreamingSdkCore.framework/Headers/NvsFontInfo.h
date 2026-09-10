//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2017. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jan 3. 2017
//   Author:        Meishe video team
//================================================================================

#pragma once

#import "NvsCommonDef.h"
#import <Foundation/NSObject.h>

/*! \if ENGLISH
 *  \brief Font file information
  *  \else
 *  \brief 字体信息
 *  \endif
*/
NVS_EXPORT @interface NvsFontInfo : NSObject

@property (readonly) NSString* famlily;       //!< \if ENGLISH font famlily \else 字体类型 \endif
@property (readonly) int weight;               //!< \if ENGLISH font weight\else 字体粗细 \endif
@property (readonly) BOOL isItalic;              //!< \if ENGLISH Is italic or not \else 是否是斜体 \endif
@property (readonly) NSString* postScriptName;       //!< \if ENGLISH additional info \else 附加信息 \endif

@end

