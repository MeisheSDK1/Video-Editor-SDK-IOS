//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2019. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    May 7. 2019
//   Author:        Meishe video team
//================================================================================
#pragma once

#import "NvsFx.h"
#import "NvsCompoundCaption.h"
#import <CoreGraphics/CGGeometry.h>

/*! \if ENGLISH
 *  \brief Capture compound caption.
 *
 *  Capture compound captions are compound caption that is superimposed on capture, each compound caption
 *  may composed of several sub-captions. When in capture, users can add or remove capture compound captions and adjust the captions position.
 *  User can also set its properties such as font family, text color, etc.
 *  <br>Note: The offset-point and duration units of the capture compound captions are both in microseconds.
 *  <br>Note1: The default start time of the capture compound captions is capture time that was added, the datault start time is zero if it was added before StartCapturePreview called
 *  \warning In the NvsCaptureCompoundCaption class, all public APIs should be used in the UI thread!!!
 *  \else
 *  \brief 采集复合字幕
 *
 *  复合字幕是应用在视频采集时的组合型文字，每个复合字幕包含若干个子字幕。在采集时，可以添加和移除时间线复合字幕，并对字幕位置进行调整处理，还可以对字体，颜色属性进行修改。
 *  <br>注：复合字幕的偏移时间和持续时间单位都为微秒
 *  <br>注1：复合字幕的默认开始时间为添加时刻的采集时间，如果在StartCapturePreview调用之前添加的，起始时间都为0
 *  \warning NvsCaptureCompoundCaption类中，所有public API都必须在UI线程使用!!!
 *  \endif
 *  \since 2.21.0
 */

NVS_EXPORT @interface NvsCaptureCompoundCaption : NvsCompoundCaption

/*! \if ENGLISH
*  \brief Get caption's offset time.
*  \return The offset time of the caption (in microseconds).
*  \else
*  \brief 获取字幕的相对偏移时间
*  \return 字幕偏移时间（单位微秒）
*  \endif
*  \sa getOutPoint
*  \sa changeInPoint
*/
@property (readonly) int64_t offsetPoint;

/*! \if ENGLISH
 *  \brief Get caption's duration.
 *  \return the duration of the caption's (in microseconds).
 *  \else
 *  \brief 字幕在时间线显示上的出点
 *  \return 字幕在时间线显示上的出点（单位微秒）
 *  \endif
 *  \sa offsetPoint
 *  \sa changeDuration
 */
@property (readonly) int64_t duration;

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
 *  \param newOutPoint The new expected duration (in microseconds).
 *  \return Returns the out-point of the caption (in microseconds).
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
