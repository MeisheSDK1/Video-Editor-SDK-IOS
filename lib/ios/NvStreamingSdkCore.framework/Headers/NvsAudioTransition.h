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

#pragma once

#import "NvsFx.h"

/*! \if ENGLISH
 *  \brief Audio transitions are the special effects that the clips of audio can jump dynamically.
 *
 *  Audio transitions are typically set and obtained via audio track. The current default audio transition is fade.
 *  \warning In the NvsAudioTransition class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 音频转场,音频片段间切换的特效
 *
 *  一般通过音频轨道(Audio Track)来设置和获取音频转场。目前默认音频转场是淡入淡出转场(fade)。
 *  \warning NvsAudioTransition类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsAudioTransition : NvsFx

@end
