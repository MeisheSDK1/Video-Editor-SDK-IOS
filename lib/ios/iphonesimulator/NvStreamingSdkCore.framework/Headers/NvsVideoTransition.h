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

/*! \file NvsVideoTransition.h */
#pragma once

#import "NvsFx.h"


/*! \if ENGLISH
 *  \brief Type of transition.
 *  \else
 *  \brief 转场类型
 *  \endif
*/
typedef enum {
    NvsVideoTransitionType_Builtin = 0,
    NvsVideoTransitionType_Package,
} NvsVideoTransitionType;

/*!
 *  \if ENGLISH
 *   @name Video transition duration matching mode
 *  \else
 *   @name 视频转场长度匹配模式
 *  \endif
 */
typedef enum {
    NvsVideoTransitionDurationMatchMode_None = 0,//!< \if ENGLISH The length set beyond the clip length is invalid \else 设置的长度超出clip长度无效。 \endif
    NvsVideoTransitionDurationMatchMode_Stretch,//!< \if ENGLISH The length can be set beyond the clip length,Transitions are proportionally elongated \else 设置的长度可以超出clip长度，转场等比例拉长。 \endif
} NvsVideoTransitionDurationMatchMode;

/*! \if ENGLISH
 *  \brief Video transition is a effect of switching between clips.
 *
 *  There are multiple clips on the track. The transition is the transition effect from one video clip to another,
 *  and no video transitions can be added between clips with gaps. Currently it supports multiple video transitions including fade,
 *  turning, swap, stretch in, page curl, lens flare, star, dip to black, dip to white,push to right, push to top, upper left into.
 *  <br> Each video transition can be set and retrieved via video track (NvsVideoTrack). The default transition is fade.
 *  \warning In the NvsVideoTransition class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 视频转场，片段间切换的特效
 *
 *  轨道上有多个片段，转场是从一个视频片段播放到另一个视频片段的衔接过渡效果，而在有间隙的片段之间不能添加视频转场。目前支持多种视频转场，
 *  包括Fade(淡入淡出)、Turning(翻转)、Swap(层叠)、Stretch In(伸展进入)、Page Curl(卷页)、Lens Flare(镜头眩光)、Star(星形)、Dip To Black(闪黑)、Dip To White(闪白)、
 *  Push To Right(右推拉)、Push To Top(上推拉)、Upper Left Into(斜推)。
 *  <br>每种视频转场都可通过视频轨道(NvsVideoTrack)来设置和获取。默认转场是Fade(淡入淡出)。
 *  \warning NvsVideoTransition类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsVideoTransition : NvsFx

@property (readonly) NvsVideoTransitionType videoTransitionType;    //!< \if ENGLISH Type of transition. \else 视频转场类型 \endif
@property (readonly) NSString *bultinVideoTransitionName;           //!< \if ENGLISH The name of built in video transition. If it is not an inline video transition, return nil. \else 内嵌视频转场名字。如果不是内嵌视频转场返回nil \endif
@property (readonly) NSString *videoTransitionPackageId;            //!< \if ENGLISH Video The ID if transition Resource Package. If it is not a resource bundle video transition returns nil. \else 视频转场资源包ID。如果不是资源包视频转场返回nil \endif
@property (nonatomic) float videoTransitionDurationScaleFactor;     //!< \if ENGLISH The factor of video transition duration scaling, range of values [0.05,1) \else 视频转场持续时间缩放比例，取值范围[0.05,1] \endif

/*! \if ENGLISH
 *  \brief Sets video transition duration.
 *  \param duration Video transition duration, min value 250000
 *  \param scaleMode Video transition duration scale mode
 *  \else
 *  \brief 设置视频转场持续时间
 *  \param duration 视频转场持续时间，最小值为250000
 *  \param scaleMode 视频转场长度匹配模式
 *  \endif
 *  \since 2.13.0
 */
- (void)setVideoTransitionDuration:(int64_t)duration withMatchMode:(NvsVideoTransitionDurationMatchMode)matchMode;

/*! \if ENGLISH
*  \brief Gets video transition duration.
*  \return Returns the video transition duration.
*  \else
*  \brief 获取视频转场持续时间
*  \return 返回视频转场持续时间
*  \endif
*  \since 2.13.0
*/

- (int64_t)getVideoTransitionDuration;

/*! \if ENGLISH
*  \brief Gets video transition duration scale mode.
*  \return Returns the video transition duration scale mode.
*  \else
*  \brief 获取视频转场长度匹配模式
*  \return 视频转场长度匹配模式
*  \endif
*  \since 2.13.0
*/
- (NvsVideoTransitionDurationMatchMode)getVideoTransitionDurationMatchMode;

@end
