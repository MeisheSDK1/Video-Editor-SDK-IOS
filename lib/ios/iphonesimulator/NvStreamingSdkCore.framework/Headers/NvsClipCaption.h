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
 *  \brief Clip captions.
 *
 *  Clip captions are custom text that is superimposed on the video. When editing a video, users can add and remove Clip captions and adjust the captions position. After adding captions, user can also set the style, including font size, color, shadow, stroke, etc.
 *  \warning In the NvsClipCaption class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 片段字幕
 *
 *  片段字幕是视频上叠加的自定义文字。编辑视频时，可以添加和移除片段字幕，并对字幕位置进行调整处理。添加完字幕，还可以进行样式设置，包括字体大小，颜色，阴影，描边等。
 *  \warning
 *  \endif
 *  \since 3.0.1
 */
NVS_EXPORT @interface NvsClipCaption : NvsCaption

@property (readonly) int64_t inPoint;                 //!< \if ENGLISH The in point of the caption on the timeline(in microseconds) \else 字幕在时间线上显示的入点（单位微秒）以当前片段的时间为基准，片段的起始时间为开始时间 \endif
@property (readonly) int64_t outPoint;                //!< \if ENGLISH The out point of the caption on the timeline (in microseconds) \else 字幕在时间线显示上的出点（单位微秒）以当前片段的时间为基准，片段的起始时间为开始时间 \endif

/*! \if ENGLISH
 *  \brief Changes the in-point of the caption on the Clip.
 *  \param newInPoint The new in-point of the caption on the timeline (in microseconds).
 *  \return Returns the in-point of the caption on the Clip (in microseconds).
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change](\ref EngineChange.md).
 *  \else
 *  \brief 改变字幕在片段上显示的入点,以当前片段的时间为基准，片段的起始时间为开始时间
 *  \param newInPoint 字幕在片段上的新的入点（单位微秒）
 *  \return 返回字幕在片段上的显示的入点（单位微秒）
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
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
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change].(\ref EngineChange.md).
 *  \else
 *  \brief 改变字幕在片段上显示的出点,以当前片段的时间为基准，片段的起始时间为开始时间
 *  \param newOutPoint 字幕在时间线上的新的出点（单位微秒）
 *  \return 返回字幕在片段上显示的出点（单位微秒）
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
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
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change] (\ref EngineChange.md).
 *  \else
 *  \brief 改变字幕在片段上的显示位置(入点和出点同时偏移offset值),以当前片段的时间为基准，片段的起始时间为开始时间
 *  \param offset 入点和出点改变的偏移值（单位微秒）, -1表示铺满整个片段
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
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

