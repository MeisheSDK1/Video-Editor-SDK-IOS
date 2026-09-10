//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2017. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Feb 16. 2017
//   Author:        Meishe video team
//================================================================================
#pragma once

#import "NvsFx.h"
#import "NvsCaption.h"
#import <CoreGraphics/CGGeometry.h>

/*! \if ENGLISH
 *  \brief Capture captions.
 *
 *  Capture captions are custom text that is superimposed on capture. Users can add and remove capture captions and adjust the captions position. After adding captions, user can also set the style, including font size, color, shadow, stroke, etc.
 *  <br>Note: The offset-point and duration units of the Capture captions are both in microseconds.
 *  <br>Note1: The default start time of the Capture captions is capture time that was added, the datault start time is zero if it was added before StartCapturePreview called
 *  \warning In the NvsCaptureCaption class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 采集字幕
 *
 *  采集字幕是应用在视频采集时的自定义文字。可以添加和移除时间线字幕，并对字幕位置进行调整处理。添加完字幕，还可以进行样式设置，包括字体大小，颜色，阴影，描边等。
 *  <br>注：采集字幕的偏移时间和持续时间单位都为微秒
 *  <br>注1：采集字幕的默认开始时间为添加时刻的采集时间，如果在StartCapturePreview调用之前添加的，起始时间都为0
 *  \warning
 *  \endif
 */
NVS_EXPORT @interface NvsCaptureCaption : NvsCaption

@property (readonly) int64_t offsetPoint;         //!< \if ENGLISH Get caption's offset time. \else 字幕偏移时间（单位微秒） \endif \since 2.21.0
@property (readonly) int64_t duration;         //!< \if ENGLISH Get the duration of the caption (in microseconds). \else 字幕的持续时间（单位微秒） \endif \since 2.21.0


/*! \if ENGLISH
 *  \brief Changes the offset of the caption.
 *  The offset time is the capture time relative to the time when the caption was added.
 *  \param newInPoint The new offset of the caption (in microseconds).
 *  \return Returns the offset of the caption (in microseconds).
 *  \else
 *  \brief 改变字幕的相对偏移时间
 *  \param newInPoint 新的相对偏移时间（单位微秒）
 *  \return 返回新的相对偏移时间（单位微秒）
 *  \endif
 */
- (int64_t)changeOffsetPoint:(int64_t)newOffset;

/*! \if ENGLISH
 *  \brief Changes the duration of the caption.
 *  \param newOutPoint The new expected duration of the caption on the timeline (in microseconds).
 *  \return Returns the out-point of the caption on the timeline (in microseconds).
 *  \else
 *  \brief 改变字幕持续时间
 *  \param newOutPoint 字幕新的期望持续时间（单位微秒）
 *  \return 返回字幕新的持续时间（单位微秒）
 *  \endif
 */
- (int64_t)changeDuration:(int64_t)newOutPoint;

/*! \if ENGLISH
*  \brief Set start time of the caption.
*  \param startTime The start time(in microseconds).
*  \else
*  \brief 设置字幕的起始时间
*  \param startTime 起始时间
*  \endif
*  \since 3.4.0
*/
- (void)setStartTime:(int64_t)startTime;

/*! \if ENGLISH
*  \brief Reset start time of the caption.
*  \else
*  \brief 重置字幕的起始时间
*  \endif
*/
- (void)resetStartTime;

@end

