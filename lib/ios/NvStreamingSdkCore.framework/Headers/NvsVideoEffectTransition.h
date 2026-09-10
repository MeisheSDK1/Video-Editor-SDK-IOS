//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jan 15. 2021
//   Author:        Meishe video team
//================================================================================
#pragma once

#import "NvsEffect.h"


/*! \if ENGLISH
 *  \brief The type of the video transition
 *  \else
 *  \brief 视频转场类型
 *  \endif
*/
typedef enum {
    NvsVideoEffectTransitionType_Builtin = 0,
    NvsVideoEffectTransitionType_Package,
    NvsVideoEffectTransitionType_Custom
} NvsVideoEffectTransitionType;


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
 *  \warning NvsVideoEffectTransition 的所有API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsVideoEffectTransition : NvsEffect

@property (readonly) NvsVideoEffectTransitionType type;   //!< \if ENGLISH The type of the video transition. \else 视频转场类型 \endif
@property (readonly) NSString *builtinName;     //!< \if ENGLISH The name of the built-in video transition. If it's not a built-in video transition, return nil. \else 内嵌视频转场名字。如果不是内嵌视频转场返回nil \endif
@property (readonly) NSString *packageId;       //!< \if ENGLISH The ID of the resource package video transition. If it's not a resource package video transition, return nil. \else 视频转场资源包ID。如果不是资源包视频转场返回nil \endif

/*! \if ENGLISH
 *  \brief Sets video transition duration.
 *  \param duration Video transition duration
 *  \param scaleMode Video transition duration scale mode
 *  \else
 *  \brief 设置视频转场持续时间
 *  \endif
 *  \since 2.20.0
 */
- (void)setVideoTransitionDuration:(int64_t)duration;

/*! \if ENGLISH
*  \brief Gets video transition duration.
*  \return Returns the video transition duration.
*  \else
*  \brief 获取视频转场持续时间
*  \return 返回视频转场持续时间
*  \endif
*  \since 2.20.0
*/
- (int64_t)getVideoTransitionDuration;

@end

