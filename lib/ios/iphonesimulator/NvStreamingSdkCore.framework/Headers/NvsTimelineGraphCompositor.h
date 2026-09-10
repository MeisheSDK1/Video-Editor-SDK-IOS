//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jan 29. 2022
//   Author:        Meishe video team
//================================================================================
#pragma once

#import "NvsFx.h"
#import <CoreGraphics/CGGeometry.h>

/*! \if ENGLISH
 *  \brief Timeline video effect
 *  Timeline GraphCompositor is a video effect applied to a Timeline instance.
 *  \warning In the NvsTimelineVideoFx class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 时间线合成器
 *  时间线合成器是作用于时间线实例上的时间线合成器。
 *  \warning NvsTimelineGraphCompositor类中，所有public API都在UI线程使用！！！
 *  \endif
 */
NVS_EXPORT @interface NvsTimelineGraphCompositor : NvsFx

@property (readonly) NSString *packageId;          //!< \if ENGLISH The package ID of the GraphCompositor on the timeline. \else 时间线合成器ID。 \endif

@end

