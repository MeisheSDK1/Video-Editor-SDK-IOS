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
 *  \brief Audio effects
 *
 *  Audio effects are effects that are superimposed on an audio clip which can change the tone and rate of the audio clip. After getting an audio clip object, users can add or remove multiple audio effects as needed.
 *  \warning In the NvsAudioFx class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 音频特效
 *
 *  音频特效是叠加显示在音频片段上的特效，可以改变音频片段的声调和速率。获取音频片段(Audio Clip)对象实例后，根据需要来添加或者移除多个音频特效。
 *  \warning NvsAudioFx类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsAudioFx : NvsFx

@property (readonly) unsigned int index;              //!< \if ENGLISH Audio special effects index \else 音频特效索引 \endif
@property (readonly) NSString *bultinAudioFxName;     //!< \if ENGLISH Build-in audio effects name. If it is not a build-in audio effect, return nil. \else 内嵌音频特效名字。如果不是内嵌音频特效返回nil \endif \since 1.16.0
@property (readonly) BOOL isCustomAudioFx;            //!< \if ENGLISH current audio fx is custom fx \else 获取当前特效是不是自定义特效 \endif
@end
