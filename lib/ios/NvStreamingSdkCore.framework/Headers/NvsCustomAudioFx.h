//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2017. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jul 20. 2017
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"
#import <CoreMedia/CMSampleBuffer.h>

struct NvsCustomAudioFxRenderContext {
    CMSampleBufferRef inputAudioSamples;  //!< \if ENGLISH Inputs audio samples. \else 输入音频数据 \endif
    int64_t effectTime;                                 //!< \if ENGLISH Special effect duration (in microseconds). \else 特效时间(单位微秒) \endif
    int64_t effectStartTime;                            //!< \if ENGLISH Effect starting time (in microseconds). \else 特效起始时间(单位微秒) \endif
    int64_t effectEndTime;                              //!< \if ENGLISH Effect ending time (in microseconds). \else 特效终止时间(单位微秒) \endif
};

typedef enum {
    NvsCustomAudioFxRenderError_NoError = 0,
    NvsCustomAudioFxRenderError_Unknown
} NvsCustomAudioFxRenderError;

/*! \if ENGLISH
 *  \brief Custom audio effects renderer interface.
 *  \warning In the NvsCustomAudioFxRenderer class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 自定义音频特效渲染器接口
 *  \warning NvsCustomAudioFxRenderer类中，所有public API都在UI线程使用！！！
 *  \endif
*/
@protocol NvsCustomAudioFxRenderer <NSObject>

/*! \if ENGLISH
 *  \brief Meishe SDK calls this method on custom audio effects to let the user initialize some resources.
 *
 *  This method will only be called at most once during the life cycle of a custom audio effect. If the effect has never been used, this method will not be called.
 *  \else
 *  \brief 美摄SDK对自定义音频特效调用此方法以便让用户初始化一些资源
 *
 *  这个方法在自定义音频特效的生命周期里最多只会被调用一次。如果该特效从未被真正使用过，则这个方法将不会被调用。
 *  \endif
 */
- (void)didInit;

/*! \if ENGLISH
 *  \brief Meishe SDK calls this method on custom audio effects to let sdk to known audio format.
 *
 *  This method will only be called at most once during the life cycle of a custom audio effect. If the effect has never been used, this method will not be called.
 *  \else
 *  \brief 美摄SDK对自定义音频特效调用此方法以便让SDK知道自定义音频特效希望得到的音频格式
 *
 *  这个方法在自定义音频特效的生命周期里最多只会被调用一次。如果该特效从未被真正使用过，则这个方法将不会被调用。
 *  \endif
 */
- (NvsAudioSampleFormat)didQuerySupportedInputAudioSampleFormat;

/*! \if ENGLISH
 *  \brief Meishe SDK calls this method on custom audio effects to let users clean up resources.
 *
 *  This method will only be called once at most in the life cycle of a custom audio effect, and will definitely be called after onInit. If onInit is not called, it will not be called.
 *  \else
 *  \brief 美摄SDK对自定义音频特效调用此方法以便让用户清理资源
 *
 *  这个方法在自定义音频特效的生命周期里最多只会被调用一次，而且一定会在onInit之后调用，如果onInit没有被调用则也不会调用该方法。
 *  \endif
 */
- (void)didCleanup;

/*! \if ENGLISH
 *  \brief Meishe SDK calls this method on custom audio effects to apply effect special effects on input audio samples.
 *
 *  \param renderContext Effects rendering context object

 *  \else
 *  \brief 美摄SDK对自定义音频特效调用此方法以便对输入音频数据进行特效处理
 *
 *  \param renderContext 特效渲染上下文对象
 *  \endif
 */
- (NvsCustomAudioFxRenderError)didRender:(struct NvsCustomAudioFxRenderContext *)renderContext outputSamples:(CMSampleBufferRef*)outputSamplesBuffer;

/*! \if ENGLISH
 *  \brief Meishe SDK calls this method on custom audio effects to apply effect special effects on input audio samples. Not implemented.
 *  \else
 *  \brief 美摄SDK对自定义音频特效调用此方法以便处理缓存的音频数据, 暂时不用实现
 *  \endif
 */
- (NvsCustomAudioFxRenderError)didFlushWithOutputSample:(CMSampleBufferRef*)outputSamplesBuffer;

@end


