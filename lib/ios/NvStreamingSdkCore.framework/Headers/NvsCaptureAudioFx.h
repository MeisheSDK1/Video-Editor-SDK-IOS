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
 *  \brief Capture audio effects.

 *  Capture audio effects is a special effect applied to audio capture. After obtaining a Streaming Context instance, you can add or remove multiple captured video effects in built-in, wrap, and beauty modes.
 *  \warning In the NvsCaptureAudioFx class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 采集音频特效

 *  \采集音频特效是一种应用在音频采集时的特效。获取流媒体上下文(Streaming Context)实例后，可按内建方式来添加或移除多个音频视频特效。
 *  \warning NvsCaptureAudioFx类中，所有public API都在UI线程使用！！！
 *  \endif
 */
NVS_EXPORT @interface NvsCaptureAudioFx : NvsFx

@property (readonly) unsigned int index;              //!< \if ENGLISH Audio special effects index \else 音频特效索引 \endif
@property (readonly) NSString *bultinAudioFxName;     //!< \if ENGLISH Build-in audio effects name. If it is not a build-in audio effect, return nil. \else 内嵌音频特效名字。如果不是内嵌音频特效返回nil \endif \since 1.16.0
@property (readonly) BOOL isCustomAudioFx;            //!< \if ENGLISH current audio fx is custom fx \else 获取当前特效是不是自定义特效 \endif
@end
