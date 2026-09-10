//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2018. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Dec 18. 2020
//   Author:        Meishe video team
//================================================================================
#pragma once

#import "NvsFx.h"
#import "NvsCompoundCaption.h"
#import <CoreGraphics/CGGeometry.h>

/*! \if ENGLISH
 *  \brief Clip compound caption.
 *
 *  Clip compound captions are compound caption that is superimposed on the video, each compound caption
 *  may composed of several sub-captions. When editing a video, users can add or remove Clip compound captions and adjust the captions position.
 *  User can also set its properties such as font family, text color, etc.
 *  \warning In the NvsClipCompoundCaption class, all public APIs should be used in the UI thread!!!
 *  \else
 *  \brief 片段复合字幕
 *
 *  片段复合字幕是视频上叠加的组合型文字，每个复合字幕包含若干个子字幕。编辑视频时，可以添加和移除片段复合字幕，并对字幕位置进行调整处理，还可以对字体，颜色属性进行修改。
 *  \warning NvsClipCompoundCaption类中，所有public API都必须在UI线程使用!!!
 *  \endif
 *  \since 3.0.1
 */

NVS_EXPORT @interface NvsClipCompoundCaption : NvsCompoundCaption


@property (readonly) int64_t inPoint;                 //!< \if ENGLISH The in point of the caption on the timeline(in microseconds) \else 字幕在时间线上显示的入点（单位微秒）以当前片段的时间为基准，片段的起始时间为开始时间 \endif
@property (readonly) int64_t outPoint;                //!< \if ENGLISH The out point of the caption on the timeline (in microseconds) \else 字幕在时间线显示上的出点（单位微秒）以当前片段的时间为基准，片段的起始时间为开始时间 \endif


/*! \if ENGLISH
 *  \brief Changes the in-point of the caption on the Clip.
 *  \param newInPoint The new in-point of the caption on the Clip (in microseconds).
 *  \return Returns the in-point of the caption on the Clip (in microseconds).
 *  \else
 *  \brief 改变字幕在片段上显示的入点，以当前片段的起始时间为时间的起始点
 *  \param newInPoint 字幕在片段上的新的入点（单位微秒）
 *  \return 返回字幕在片段上的显示的入点（单位微秒）
 *  \endif
 *  \sa changeOutPoint
 *  \sa getInPoint
 *  \sa movePosition
 *  \since 3.0.1
 */
- (int64_t)changeInPoint:(int64_t)newInPoint;

/*! \if ENGLISH
 *  \brief Changes the out-point of the caption on the Clip.
 *  \param newOutPoint The new out-point of the caption on the Clip (in microseconds).
 *  \return Returns the out-point of the caption on the Clip (in microseconds).
 *  \else
 *  \brief 改变字幕在片段上显示的出点，以当前片段的起始时间为时间的起始点
 *  \param newOutPoint 字幕在片段上的新的出点（单位微秒）
 *  \return 返回字幕在片段上显示的出点（单位微秒）
 *  \endif
 *  \sa changeInPoint
 *  \sa getOutPoint
 *  \sa movePosition
 *  \since 3.0.1
 */
- (int64_t)changeOutPoint:(int64_t)newOutPoint;

/*! \if ENGLISH
 *  \brief Changes the display position of the caption on the Clip (the in and out points are offset from the offset value at the same time).
 *  \param offset Offset value for in and out points changes (in microseconds), -1 indicates that the whole clip is covered.
 *  \else
 *  \brief 改变字幕在片段上的显示位置(入点和出点同时偏移offset值)，以当前片段的起始时间为时间的起始点，改变单一片段上的时间
 *  \param offset 入点和出点改变的偏移值（单位微秒）, -1表示铺满整个片段
 *  \endif
 *  \sa changeInPoint
 *  \sa changeOutPoint
 *  \since 3.0.1
 */
- (void)movePosition:(int64_t)offset;

/*! \if ENGLISH
 *  \brief Set the caption in and out point to absolute time
 *  \param enable switch checker
 *  \else
 *  \brief 设置字幕入出点为绝对时间。
 *  \param enable 检测开关
 *  \endif
 *  \since 3.0.2
 */
- (void)setAbsoluteTimeUsed:(bool)enable;

/*! \if ENGLISH
 *  \brief Get whether the caption in and out point is absolute time
 *  \return Returns a boolean value. true for yes, false for no.
 *  \else
 *  \brief 获取字幕入出点是否为绝对时间。
 *  \return 返回一个布尔值，true表示是，false表示否
 *  \endif
 *  \since 3.0.2
 */
- (bool)getAbsoluteTimeUsed;

@end
