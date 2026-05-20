//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2017. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Feb 17. 2017
//   Author:        Meishe video team
//================================================================================
#pragma once

#import "NvsFx.h"
#import "NvsAnimatedSticker.h"
#import <CoreGraphics/CGGeometry.h>

/*! \if ENGLISH
 *  \brief Timeline animated sticker class.
 *
 *   Users can add and remove animated stickers for Catpure, the start time is the current shooting time and the given offset time to start loading the animation sticker. The end time is the sum of time position, offset time and duration.
 *  <br>Note: The offset-point and duration units of the animated sticker are both in microseconds.
 *  <br>Note1: The default start time of the animated sticker is capture time that was added, the datault start time is zero if it was added before StartCapturePreview called
 *  \warning In the NvsCaptureAnimatedSticker class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 采集动画贴纸类
 *
 *  动画贴纸添加后，起始时间为当前的拍摄的位置和给定的偏移时间开始加载动画贴纸。结束时间为添加时候的时间位置，偏移时间和持续时间之和。
 *  通过各种API调整贴纸的各种属性，如位置、大小、显示时间等等。
 *  <br>注：动画贴纸的偏移时间和持续时间单位都为微秒
 *  <br>注1：动画贴纸的默认开始时间为添加时刻的采集时间，如果在StartCapturePreview调用之前添加的，起始时间都为0
 *  \warning NvsCaptureAnimatedSticker类中，所有public API都在UI线程使用！！！
 *  \endif
 *  \since 2.21.0
 */
NVS_EXPORT @interface NvsCaptureAnimatedSticker : NvsAnimatedSticker

@property (readonly) int64_t offsetPoint;       //!< \if ENGLISH the offset of the animated sticker(in microseconds) \else 动画贴纸偏移时间（单位微秒） \endif \since 2.21.0
@property (readonly) int64_t duration;           //!< \if ENGLISH Get animated sticker's duration (in microseconds). \else 动画贴纸持续时间（单位微秒） \endif \since 2.21.0


/*! \if ENGLISH
 *  \brief Change the offset time of the animated sticker.
 *  The offset time is the capture time relative to the time when the animation sticker was added.
 *  \param newInPoint The new offset time of the animated sticker(in microseconds).
 *  \return Return the offset time of the animated sticker(in microseconds).
 *  \else
 *  \brief 改变动画贴纸的相对偏移时间
 * 相对偏移时间是相对于添加动画贴纸时候的采集时间。
 *  \param newOffset 新的相对偏移时间（单位微秒）
 *  \return 返回新的相对偏移时间（单位微秒）
 *  \endif
 *  \sa changeDuration
 *  \sa offsetPoint
 */
- (int64_t)changeOffsetPoint:(int64_t)newOffset;

/*! \if ENGLISH
 *  \brief Change the duration of the animated sticker.
 *  \param newOutPoint The expected duration of the animated sticker(in microseconds).
 *  \return Return the duraiton of the animated sticker(in microseconds).
 *  \else
 *  \brief 改变动画贴纸持续时间
 *  \param newOutPoint 动画贴纸新的期望持续时间（单位微秒）
 *  \return 返回动画贴纸新的持续时间（单位微秒）
 *  \endif
 */
- (int64_t)changeDuration:(int64_t)newOutPoint;

/*! \if ENGLISH
*  \brief Set start time of the animated sticker.
*  \param startTime The start time(in microseconds).
*  \else
*  \brief 设置动画贴纸的起始时间
*  \param startTime 起始时间
*  \endif
*  \since 3.4.0
*/
- (void)setStartTime:(int64_t)startTime;

/*! \if ENGLISH
*  \brief Reset start time of the animated sticker.
*  \else
*  \brief 重置动画贴纸的起始时间
*  \endif
*/
- (void)resetStartTime;

@end

