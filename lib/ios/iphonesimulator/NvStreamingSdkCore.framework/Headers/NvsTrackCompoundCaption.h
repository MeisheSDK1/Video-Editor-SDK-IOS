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
 *  \brief Track compound caption.
 *
 *  Track compound captions are compound caption that is superimposed on the video, each compound caption
 *  may composed of several sub-captions. When editing a video, users can add or remove track compound captions and adjust the captions position.
 *  User can also set its properties such as font family, text color, etc.
 *  \warning In the NvsTrackCompoundCaption class, all public APIs should be used in the UI thread!!!
 *  \else
 *  \brief 时间线复合字幕
 *
 *  轨道复合字幕是视频上叠加的组合型文字，每个复合字幕包含若干个子字幕。编辑视频时，可以添加和移除轨道复合字幕，并对字幕位置进行调整处理，还可以对字体，颜色属性进行修改。
 *  \warning NvsTrackCompoundCaption类中，所有public API都必须在UI线程使用!!!
 *  \endif
 *  \since 2.20.0
 */

NVS_EXPORT @interface NvsTrackCompoundCaption : NvsCompoundCaption

/*! \if ENGLISH
 *  \brief Sets whether to turn on affinity between the caption and video clip.
 *  \param enable Whether to turn on affinity between the caption and video clip
 *  \else
 *  \brief 是否开启字幕与视频片段之间的亲和度
 *  \endif
 */
@property (nonatomic) BOOL clipAffinityEnabled;


@property (readonly) int64_t inPoint;                 //!< \if ENGLISH The in point of the caption on the timeline(in microseconds) \else 字幕在时间线上显示的入点（单位微秒） \endif
@property (readonly) int64_t outPoint;                //!< \if ENGLISH The out point of the caption on the timeline (in microseconds) \else 字幕在时间线显示上的出点（单位微秒） \endif


/*! \if ENGLISH
 *  \brief Changes the in-point of the caption on the track.
 *  \param newInPoint The new in-point of the caption on the track (in microseconds).
 *  \return Returns the in-point of the caption on the track (in microseconds).
 *  \else
 *  \brief 改变字幕在轨道上显示的入点
 *  \param newInPoint 字幕在轨道上的新的入点（单位微秒）
 *  \return 返回字幕在轨道上的显示的入点（单位微秒）
 *  \endif
 *  \sa changeOutPoint
 *  \sa getInPoint
 *  \sa movePosition
 */
- (int64_t)changeInPoint:(int64_t)newInPoint;

/*! \if ENGLISH
 *  \brief Changes the out-point of the caption on the track.
 *  \param newOutPoint The new out-point of the caption on the track (in microseconds).
 *  \return Returns the out-point of the caption on the track (in microseconds).
 *  \else
 *  \brief 改变字幕在轨道上显示的出点
 *  \param newOutPoint 字幕在轨道上的新的出点（单位微秒）
 *  \return 返回字幕在轨道上显示的出点（单位微秒）
 *  \endif
 *  \sa changeInPoint
 *  \sa getOutPoint
 *  \sa movePosition
 */
- (int64_t)changeOutPoint:(int64_t)newOutPoint;

/*! \if ENGLISH
 *  \brief Changes the display position of the caption on the track (the in and out points are offset from the offset value at the same time).
 *  \param offset Offset value for in and out points changes (in microseconds).
 *  \else
 *  \brief 改变字幕在轨道上的显示位置(入点和出点同时偏移offset值)
 *  \param offset 入点和出点改变的偏移值（单位微秒）
 *  \endif
 *  \sa changeInPoint
 *  \sa changeOutPoint
 */
- (void)movePosition:(int64_t)offset;

@end
