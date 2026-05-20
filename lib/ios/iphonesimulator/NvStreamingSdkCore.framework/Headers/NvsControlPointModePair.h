//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2021. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jul 21. 2022
//   Author:        Meishe video team
//================================================================================

#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"

/*! \if ENGLISH
*   \brief Key frame control point mode pair structure.
*   \else
*   \brief 关键帧控制点模式对类。
*   \endif
*/

NVS_EXPORT @interface NvsControlPointModePair : NSObject

@property (nonatomic, assign) int backwardControlPointMode;
@property (nonatomic, assign) int forwardControlPointMode;

@end
