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

struct NvsCustomVideoFxVideoFrame {
    int texId;                  //!< \if ENGLISH The texture ID of the video frame. \else 视频帧的纹理ID \endif
    int width;                  //!< \if ENGLISH The width of the video frame. \else 视频帧的宽度 \endif
    int height;                 //!< \if ENGLISH The height of the video frame. \else 视频帧的高度 \endif
    BOOL isUpsideDownTexture;   //!< \if ENGLISH YES means that the texture in this video frame is upside down. The user needs to deal with the texture coordinates when rendering. \else 值为YES表示这个视频帧中的纹理是上下颠倒的。用户在渲染时需对纹理坐标进行处理。 \endif
    NvsRational proxyScale;

    NvsGpuVideoFrameFormat texFormat;
};

struct NvsCustomVideoFxRenderContext {
    struct NvsCustomVideoFxVideoFrame inputVideoFrame;  //!< \if ENGLISH Inputs video frame. \else 输入视频帧 \endif
    bool hasBuddyVideoFrame;                            //!< \if ENGLISH Indicates that whether the buddy video frame exists or not.Buddy video frames will only exist which sets STREAMING_ENGINE_CAPTURE_FLAG_CAPTURE_BUDDY_HOST_VIDEO_FRAME when it is catpuring. \else 表示伴侣视频帧是否存在，伴侣视频帧只有在采集的时,而且设置了STREAMING_ENGINE_CAPTURE_FLAG_CAPTURE_BUDDY_HOST_VIDEO_FRAME才会存在 \endif
    NvsVideoFrameInfo inputBuddyVideoFrame;             //!< \if ENGLISH Data and information of the input video frame in Host Memory. \else 输入视频帧在Host Memory中数据和信息 \endif
    NvsVideoFrameYUVColorMatrix inputBuddyVideoFrameColorMatrix;
    NvsVideoFrameColorTransfer inputBuddyVideoFrameColorTransfer;
    NvsVideoFrameColorPrimaries inputBuddyVideoFrameColorPrimaries;
    struct NvsCustomVideoFxVideoFrame outputVideoFrame; //!< \if ENGLISH Output video frame. \else 输出视频帧 \endif
    int64_t effectTime;                                 //!< \if ENGLISH Special effect duration (in microseconds). \else 特效时间(单位微秒) \endif
    int64_t effectStartTime;                            //!< \if ENGLISH Effect starting time (in microseconds). \else 特效起始时间(单位微秒) \endif
    int64_t effectEndTime;                              //!< \if ENGLISH Effect ending time (in microseconds). \else 特效终止时间(单位微秒) \endif
    int64_t mediaStreamTime;                              //!< \if ENGLISH Effect ending time (in microseconds). \else 特效终止时间(单位微秒) \endif
};

@class NvsCustomVideoFxRenderHelper;

/*! \if ENGLISH
 *  \brief Custom video effects renderer interface.
 *  \warning In the NvsCustomVideoFxRenderer class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 自定义视频特效渲染器接口
 *  \warning NvsCustomVideoFxRenderer类中，所有public API都在UI线程使用！！！
 *  \endif
*/
@protocol NvsCustomVideoFxRenderer <NSObject>

/*! \if ENGLISH
 *  \brief Meishe SDK calls this method on custom video effects to let the user initialize resources.
 *
 *  This method will only be called at most once during the life cycle of a custom video effect. If the effect has never been used, this method will not be called.
 *  This method is called in the special effect rendering thread of Meishe SDK, and the current thread has already bound an EAGLContext.
 *  \else
 *  \brief 美摄SDK对自定义视频特效调用此方法以便让用户初始化一些资源
 *
 *  这个方法在自定义视频特效的生命周期里最多只会被调用一次。如果该特效从未被真正使用过，则这个方法将不会被调用。
 *  这个方法是在美摄SDK引擎的特效渲染线程里调用，并且当前线程已经绑定了一个EAGLContext。
 *  \endif
*/
- (void)didInit;

/*! \if ENGLISH
 *  \brief Meishe SDK calls this method on custom video special effects to let users clean up resources.
 *
 *  This method will only be called once at most in the life cycle of a custom video effect, and will definitely be called after didInit. If the didInit is not called, it will not be called.
 *  This method is called in the special effect rendering thread of Meishe SDK, and the current thread has already bound EAGLContext.
 *  \else
 *  \brief 美摄SDK对自定义视频特效调用此方法以便让用户清理资源
 *
 *  这个方法在自定义视频特效的生命周期里最多只会被调用一次，而且一定会在didInit之后调用，如果didInit没有被调用则也不会调用该方法。
 *  这个方法是在美摄SDK引擎的特效渲染线程里调用，并且当前线程已经绑定了一个EAGLContext。
 *  \endif
*/
- (void)didCleanup;

/*! \if ENGLISH
 *  \brief Meishe SDK calls this method on custom video effects to allow some resource preprocessing.
 *
 *  This method is called multiple times during the life cycle of a custom video effect, and will definitely be called after didInit, which is generally called before each timeline is played.
 *  In general, users need to do work such as building a shader program in this function.
 *  This method is called in the special effect rendering thread of Meishe SDK, and the current thread has already bound EAGLContext.
 *  \else
 *  \brief 美摄SDK对自定义视频特效调用此方法以便让进行一些资源预处理
 *
 *  这个方法在自定义视频特效的生命周期里会被多次调用，而且一定会在didInit之后调用，一般来讲是在每次播放时间线之前调用。
 *  一般来讲用户需要在此函数里面进行诸如构建shader program的工作。
 *  这个方法是在美摄SDK引擎的特效渲染线程里调用，并且当前线程已经绑定了一个EAGLContext。
 *  \endif
*/
- (void)didPreloadResources;

/*! \if ENGLISH
 *  \brief Meishe SDK calls this method to effect Fx on input video frame for customized video effects.
 *
 *  The users apply this method to process the input video frame and write the result to the output video frame to complete the effect rendering.
 *  This method is called in the special effect rendering thread of  Meishe SDK, and the current thread has already bound an EGL Context.
 *  The current thread has already bound an FBO, and the user only needs to bind the color buffer, depth buffer, etc on the corresponding attachment point.
 *  Note: Be sure to reset the state of the OpenGL ES context to the default state after rendering is complete, such as glEnable(GL_BLEND) is called during user rendering.
 *  Then glDisable(GL_BLEND) must be called after rendering is completed, because the blend is off by default. About the default state of the OpenGL ES context,
 *  please refer to https://www.khronos.org/opengles/see https://www.khronos.org/opengles/.
 *  Warning: If the state of the OpenGL ES context is not reset to the default state after rendering is completed, it may cause an error in subsequent effects rendering!
 *
 *  \param renderContext Effects rendering context object
 *  \param renderHelper The effect rendering interface. Pay attention and do not save this interface, users can only use it in the didRender!
 *  \else
 *  \brief 美摄SDK对自定义视频特效调用此方法以便对输入视频帧进行特效处理
 *
 *  用户实现这个方法对输入视频帧进行处理并将结果写入到输出视频帧中去以便完成特效渲染。
 *  这个方法是在美摄SDK引擎的特效渲染线程里调用，并且当前线程已经绑定了一个EGL Context。
 *  当前线程已经绑定了一个FBO，用户只需在相应的attachment point上面绑定color buffer, depth buffer...即可
 *  注意：请务必在渲染完成后，将OpenGL ES context的状态复位到默认状态，比如用户渲染过程中调用了glEnable(GL_BLEND),
 *  则渲染完成后一定要调用glDisable(GL_BLEND),因为默认状态下blend是关闭的。关于OpenGL ES context的默认状态
 *  请参考https://www.khronos.org/opengles/
 *  警告：如果渲染完成后，没有将OpenGL ES context的状态复位到默认状态，则可能导致后续特效渲染发生错误！
 *
 *  \param renderContext 特效渲染上下文对象
 *  \param renderHelper 特效渲染辅助方法接口，注意用户不要保存这个接口，只能在didRender里面使用它！
 *  \endif
*/
- (void)didRender:(struct NvsCustomVideoFxRenderContext *)renderContext
     renderHelper:(NvsCustomVideoFxRenderHelper *)renderHelper;

@optional

/*! \if ENGLISH
 *  \brief Meishe SDK calls this method on custom video effects to allow some resource preprocessing.
 *
 *  This method is called when user call clearCacheResources in streamingContext.
 *  This method is called in the special effect rendering thread of Meishe SDK, and the current thread has already bound EAGLContext.
 *  \else
 *  \brief 美摄SDK对自定义视频特效调用此方法以便让进行资源清理。
 *
 *  当用户调用streamingContext中的clearCacheResources方法时，该回调函数被调用。
 *  这个方法是在美摄SDK引擎的特效渲染线程里调用，并且当前线程已经绑定了一个EAGLContext。
 *  \endif
*/
- (void)didClearCacheResources;

/*! \if ENGLISH
 *  \brief Meishe SDK calls this method on custom video effects to allow input buddy frame.
 *
 * The current method requires NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame or NvsStreamingEngineCompileFlag_SuddyHostVideoFrame,
 *   NvsStreamingEngineCompileFlag_BuddyOriginHostVideoFrame，NvsStreamingEngineSeekFlag_BuddyHostVideoFrame，NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame
 *   NvsStreamingEnginePlaybackFlag_SuddyHostVideoFrame is used in conjunction with NvsStreamingEnginePlaybackFlag_SuddyOriginHostVideoFrame.
 *  \else
 *  \brief 美摄SDK对自定义视频特效调用此方法以便确认CustomVideoFx是否需要侣视频帧。
 *
 *  当前方法需要和NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame或者NvsStreamingEngineCompileFlag_BuddyHostVideoFrame，
 *  NvsStreamingEngineCompileFlag_BuddyOriginHostVideoFrame，NvsStreamingEngineSeekFlag_BuddyHostVideoFrame，NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame
 *  NvsStreamingEnginePlaybackFlag_BuddyHostVideoFrame，NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame配合使用。
 *  \endif
*/
- (bool)needInputBuddyFrame;

@end

/*! \if ENGLISH
 *  \brief Auxiliary method interface for custom video effects
 *  \else
 *  \brief 自定义视频特效的辅助方法接口
 *  \endif
*/
NVS_EXPORT @interface NvsCustomVideoFxRenderHelper : NSObject

/*! \if ENGLISH
 *  \brief Users of custom video effects call this method to request a RGBA texture.
 *
 *  Note: The texture requested in this method must be recycled by calling reclaimTexture, otherwise there will be a leak!
 *  \param texSize Applies for the size of the texture
 *  \return Returns the texture ID of the application, and returns 0 to indicate that the application failed.
 *  \else
 *  \brief 自定义视频特效的用户调用此方法来申请一个RGBA纹理
 *
 *  注意：使用这个方法申请的纹理一定要调用reclaimTexture进行回收，否则会出现泄漏！
 *  \param texSize 申请纹理的尺寸
 *  \return 返回申请到的纹理ID，返回0表示申请失败
 *  \endif
*/
- (int)allocateRGBATexture:(NvsSize)texSize;

/*! \if ENGLISH
 *  \brief Users of custom video effects call this method to request a RGBA texture.
 *
 *  Note: The texture requested in this method must be recycled by calling reclaimTexture, otherwise there will be a leak!
 *  \param texSize Applies for the size of the texture
 *  \param fmt Applies for format of the texture
 *  \return Returns the texture ID of the application, and returns 0 to indicate that the application failed.
 *  \else
 *  \brief 自定义视频特效的用户调用此方法来申请一个RGBA纹理
 *
 *  注意：使用这个方法申请的纹理一定要调用reclaimTexture进行回收，否则会出现泄漏！
 *  \param texSize 申请纹理的尺寸
 *  \param fmt 申请纹理的格式
 *  \return 返回申请到的纹理ID，返回0表示申请失败
 *  \endif
*/
- (int)allocateRGBATexture:(NvsSize)texSize format:(NvsGpuVideoFrameFormat)fmt;

/*! \if ENGLISH
 *  \brief Users which using custom video special effects call this method to reclaim a previously applied texture.
 *  \param texId The texture ID to release
 *  \else
 *  \brief 自定义视频特效的用户调用此方法来回收一个之前申请的纹理
 *  \param texId 要释放的纹理ID
 *  \endif
*/
- (void)reclaimTexture:(int)texId;

/*! \if ENGLISH
 *  \brief Users which using custom video effects call this method to upload a Host buffer to the OpenGL texture.
 *  \param hostBuffer Host buffer uploading
 *  \param tId The texture ID of uploading.
 *  \else
 *  \brief 自定义视频特效的用户调用此方法来上传一个Host buffer 到 OpenGL的纹理上
 *  \param hostBuffer 要上传到host buffer
 *  \param tId 要上传到纹理ID
 *  \endif
*/
- (BOOL)uploadHostBufferToOpenGLTexture:(NvsVideoFrameInfo*)hostBuffer textureId:(int)tId;

/*! \if ENGLISH
 *  \brief Users which using custom video effects call this method to upload a Host buffer to the OpenGL texture.
 *  \param hostBuffer Host buffer uploading
 *  \param tId The texture ID of uploading.
 *  \else
 *  \brief 自定义视频特效的用户调用此方法来上传一个Host buffer 到 OpenGL的纹理上
 *  \param hostBuffer 要上传到host buffer
 *  \param tId 要上传到纹理ID
 *  \endif
*/
- (BOOL)uploadHostBufferToOpenGLTexture:(NvsVideoFrameInfoExt*)hostBuffer gpuVideoFrame:(struct NvsCustomVideoFxVideoFrame*)tex;

@end

