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

#import <Foundation/Foundation.h>
#import "NvsTimeline.h"
#import "NvsAssetPackageManager.h"
#import "NvsAVFileInfo.h"
#import "NvsVideoFrameRetriever.h"
#import "NvsVideoFrameReceiver.h"
#import "NvsCustomVideoFx.h"
#import "NvsCommonDef.h"
#import "NvsCaptureAnimatedSticker.h"
#import "NvsCaptureCompoundCaption.h"
#import "NvsCaptureCaption.h"
#import "NvsCaptureAudioFx.h"
#import "NvsCaptureSceneInfo.h"
#import <CoreMedia/CMSampleBuffer.h>

/*! \if ENGLISH
 *  \brief Streaming context creation flag
 *  \else
 *  \brief 流媒体上下文创建标志
 *  \endif
*/
typedef enum {
    NvsStreamingContextFlag_Support4KEdit                           = 1,        //!< \if ENGLISH Supports up to 4K video editing. \else 支持4K视频编辑 \endif
    NvsStreamingContextFlag_Support8KEdit                           = 1 << 2,   //!< \if ENGLISH Supports up to 8K (images only). \else 支持8K编辑(仅图片) \endif
    NvsStreamingContextFlag_AsyncEngineState                        = 1 << 4,   //!< \if ENGLISH Asynchronous engine \else 引擎状态切换使用异步方式以便减少主线程的卡顿 \endif
    NvsStreamingContextFlag_Support16KEdit                          = 1 << 7,   //!< \if ENGLISH Supports up to 16K (images only). \else 支持16K编辑(仅图片) \endif
    NvsStreamingContextFlag_EnableCaptionContextCacheLimit          = 1 << 10,  //!< \if ENGLISH Enable max cache cont limit of caption \else 开启最大字幕缓存限制 \endif
    NvsStreamingContextFlag_DisableCapture                          = 1 << 11,  //!< \if ENGLISH Disable capture \else 采集设备不可用 \endif
    NvsStreamingContextFlag_PlaybackDropFrameMode                   = 1 << 12,  //!< \if ENGLISH Drop frame mode in playback timeline \else 播放时间线的时候启用丢帧模式 \endif
    NvsStreamingContextFlag_NeedGifMotion                           = 1 << 13,  //!< \if ENGLISH Need gif motion in playback timeline \else 播放时间线的时候需要GIF运动 \endif
    NvsStreamingContextFlag_DisableHardwareAudioReader              = 1 << 14,  //!< \if ENGLISH Disable hardware audio reader in mac os \else 禁用Mac系统中的硬件音频读取\endif
    NvsStreamingContextFlag_InterruptStopForInternalStop            = 1 << 18,  //!< \if ENGLISH Interrupt stop is used for all internal stop, such as stop between seek state and playback state \else 使用中断式的Stop在所有内部使用的Stop操作，比如seek状态到playback状态中间的Stop \endif
    NvsStreamingContextFlag_UseFixedDefaultCaptionContextResolution = 1 << 22   //!< @if ENGLISH @brief  @else @brief 创建的默认样式字幕的描述文件分辨率固定为1280X720(16v9) @endif
} NvsStreamingContextFlag;

/*! \if ENGLISH
 *  \brief Clear cache flags
 *  \else
 *  \brief 清理缓存标志
 *  \endif
*/
typedef enum {
    NvsClearCacheFlag_StreamingEngine = 1,          //!< \if ENGLISH Cache of streaming engine \else 流媒体引擎的缓存 \endif
    NvsClearCacheFlag_IconEngine = 2,               //!< \if ENGLISH Cache of icon engine \else 缩略图的缓存 \endif
    NvsClearCacheFlag_WaveformEngine = 4,           //!< \if ENGLISH Cache of waveform engine \else 音频波形的缓存 \endif
    NvsClearCacheFlag_AVFileInfo = 8,               //!< \if ENGLISH Cache of avfile infors \else 视音频文件信息的缓存 \endif
    NvsClearCacheFlag_CaptionFontInfo = 16          //!< \if ENGLISH Cache of font infos \else 字幕字体信息的缓存 \endif
} NvsClearCacheFlag;


/*! \if ENGLISH
 *  \brief Resolution level for compiling video (define video resolution at time of createTimeline. Automatically defining rendering video width in according to output video height).
 *  \else
 *  \brief 生成视频文件的分辨率高度级别(创建时间线(createTimeline)时指定视频的宽高和横纵比，根据输出的视频分辨率高度算出生成视频文件的宽度)
 *  \endif
*/
typedef enum {
    NvsCompileVideoResolutionGrade360 = 0,                //!< \if ENGLISH Output height: 360 pixel \else 输出高度360像素 \endif
    NvsCompileVideoResolutionGrade480,                    //!< \if ENGLISH Output height: 480 pixel\else 输出高度480像素 \endif
    NvsCompileVideoResolutionGrade720,                    //!< \if ENGLISH Output height: 720 pixel\else 输出高度720像素 \endif
    NvsCompileVideoResolutionGrade1080,                   //!< \if ENGLISH Output height: 1080 pixel\else 输出高度1080像素 \endif
    NvsCompileVideoResolutionGrade2160,                   //!< \if ENGLISH Output height: 2160 pixel\else 输出高度2160像素 \endif
    NvsCompileVideoResolutionGradeCustom = 256            //!< \if ENGLISH Custom height, used with setCustomCompileVideoHeight\else 自定义生成视频高度，须和setCustomCompileVideoHeight配合使用 \endif
} NvsCompileVideoResolutionGrade;

/*! \if ENGLISH
 *  \brief The bitrate level of compiling the video file.
 *  \else
 *  \brief 生成视频文件的码率级别
 *  \endif
*/
typedef enum {
    NvsCompileBitrateGradeLow = 0,          //!< \if ENGLISH Low bitrate \else 低码率 \endif
    NvsCompileBitrateGradeMedium,           //!< \if ENGLISH Medium bitrate \else 中等码率 \endif
    NvsCompileBitrateGradeHigh              //!< \if ENGLISH High bitrate \else 高码率 \endif
} NvsCompileVideoBitrateGrade;

/*! \if ENGLISH
 *  \brief Flag of compiling video
 *  \else
 *  \brief 生成视频文件标志
 *  \endif
*/
typedef enum {
    NvsStreamingEngineCompileFlag_None = 0,          //!< \if ENGLISH None. \else 没有任何特殊标识 \endif
    NvsStreamingEngineCompileFlag_DisableHardwareEncoder = 1, //!< \if ENGLISH Disables the hardware encoder \else 禁用硬件编码器 \endif
    NvsStreamingEngineCompileFlag_OnlyVideo = 4,     //!< \if ENGLISH Compile the video file only. \else 仅生产只有视频流的文件 \endif
    NvsStreamingEngineCompileFlag_OnlyAudio = 8,      //!< \if ENGLISH Compile the audio file only. \else 仅生产只有音频流的文件 \endif
    NvsStreamingEngineCompileFlag_BuddyHostVideoFrame = 32,      //!< \if ENGLISH Buddy video frame in host. \else 伴侣视频帧 \endif
    NvsStreamingEngineCompileFlag_TruncateAudioStream = 128,     //!< \if ENGLISH Truncat audio stream make sure no longer than the length of the video  \else 截断音频流保证不超过视频的长度 \endif
    NvsStreamingEngineCompileFlag_DisableAlignVideoSize = 256,   //!< \if ENGLISH \else 禁用对输出的宽高做对齐操作 \endif
    NvsStreamingEngineCompileFlag_IgnoreTimelineVideoSize = 2048, //!< \if ENGLISH The resolution of output video can be over timeline's resolution \else 输出的视频分辨率可超过timeline的分辨率大小 \endif
    NvsStreamingEngineCompileFlag_BuddyOriginHostVideoFrame = 8192,      //!< \if ENGLISH Buddy video frame in host after decoding. \else 解码后伴侣视频帧 \endif
    NvsStreamingEngineCompileFlag_VariableFrameRateEnable = 16384,      //!< \if ENGLISH Enable variable frame rate export \else 开启变帧率导出 \endif
    NvsStreamingEngineCompileFlag_DontDownloadBuddyBufferForTimelineEffect = 1 << 15, //!< @if ENGLISH @brief  Flag for detecting AR texture on timeline disable downloaded @else @brief 禁止时间线AR特效下传纹理做检测 @endif
} NvsStreamingEngineCompileFlag;

/*! \if ENGLISH
 *  \brief Flag of compiling video
 *  \else
 *  \brief 直通生成视频文件标志
 *  \endif
*/
typedef enum {
    NvsStreamingEngineCompilePassthroughFlag_OnlyVideo = 4,         //!< \if ENGLISH Compile the video file only. \else 仅生产只有视频流的文件 \endif
    NvsStreamingEngineCompilePassthroughFlag_DisableTranscode = 8   //!< \if ENGLISH Disable transcode. \else 禁用转码 \endif
} NvsStreamingEngineCompilePassthroughFlag;

/*! \if ENGLISH
 *  \brief Mode of preview video.
 *  \else
 *  \brief 视频预览模式
 *  \endif
*/
typedef enum {
    NvsVideoPreviewSizeModeFullSize = 0,     //!< \if ENGLISH Preview in full size. \else 全屏预览 \endif
    NvsVideoPreviewSizeModeLiveWindowSize    //!< \if ENGLISH Preview in controll of "liveWindow" \else liveWindow预览 \endif
} NvsVideoPreviewSizeMode;

/*! \if ENGLISH
 *  \brief Resolution level for capturing video
 *  \else
 *  \brief 视频采集分辨率级别
 *  \endif
*/
typedef enum {
    NvsVideoCaptureResolutionGradeLow = 0,              //!< \if ENGLISH Low resolution \else 低分辨率 \endif
    NvsVideoCaptureResolutionGradeMedium,               //!< \if ENGLISH Medium resolution \else 中等分辨率 \endif
    NvsVideoCaptureResolutionGradeHigh,                 //!< \if ENGLISH High resolution \else 高分辨率 \endif
    NvsVideoCaptureResolutionGradeSupperHigh,           //!< \if ENGLISH Super high resolution \else 超高分辨率 \endif
    NvsVideoCaptureResolutionGradeExtremelyHigh         //!< \if ENGLISH Extremely high resolution \else 极高分辨率 \endif
} NvsVideoCaptureResolutionGrade;

/*! \if ENGLISH
 *  \brief Streaming engine status
 *  \else
 *  \brief 流媒体引擎状态
 *  \endif
*/
typedef enum {
    NvsStreamingEngineState_Stopped = 0,      //!< \if ENGLISH Engine stopped \else 引擎停止 \endif
    NvsStreamingEngineState_CapturePreview,   //!< \if ENGLISH Capturing preview \else 采集预览 \endif
    NvsStreamingEngineState_CaptureRecording, //!< \if ENGLISH Recording \else 采集录制 \endif
    NvsStreamingEngineState_Playback,         //!< \if ENGLISH Playback \else 播放 \endif
    NvsStreamingEngineState_Seeking,          //!< \if ENGLISH Seeking \else 定位 \endif
    NvsStreamingEngineState_Compile           //!< \if ENGLISH Compiling \else 生成 \endif
} NvsStreamingEngineState;

/*! \if ENGLISH
 *  \brief Flag of capturing
 *  \else
 *  \brief 采集标志
 *  \endif
*/
typedef enum
{
    NvsStreamingEngineCaptureFlag_GrabCapturedVideoFrame = 1,       //!< \if ENGLISH Gets the capture frame content(this operation may reduce performance, use it only when needed).\else 获取采集视频的帧内容（打开这个标志会降低性能，只有在必要的时候开启这个标志）\endif
    NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize = 8,       //!< \if ENGLISH Preview video size within system-defined size. \else 限定预览视频尺寸只能是系统自带的预览视频尺寸 \endif
    NvsStreamingEngineCaptureFlag_DontCaptureAudio = 16,            //!< \if ENGLISH No audio capturing. \else 不采集音频 \endif
    NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame = 32,  //!< \if ENGLISH Captures buddy video frames. \else 采集伴侣视频帧 \endif
    NvsStreamingEngineCaptureFlag_IgnoreScreenOrientation = 64,     //!< \if ENGLISH Does not apply screen coordinate for defining rotation angle of captured video. \else 不使用屏幕方向来确定采集画面的旋转角度 \endif \since 1.15.2
    NvsStreamingEngineCaptureFlag_AutoVideoStabilization = 128,     //!< \if ENGLISH Enables auto video stabilization. \else 启用视频防抖动 \endif \since 1.16.1
    NvsStreamingEngineCaptureFlag_FaceActionWithParticle = 256,     //!< \if ENGLISH Uses facial action to control particle effects. \else 使用脸部动作控制粒子特效 \endif \since 2.1.0
    NvsStreamingEngineCaptureFlag_LowPipelineSize = 512,            //!< \if ENGLISH Decreases the size of pipeline when engine is capturing \else 降低引擎在采集时内部的流水线尺寸 \endif
    NvsStreamingEngineCaptureFlag_DontAutomaticallyConfiguresApplicationAudioSession NS_ENUM_DEPRECATED_IOS(8_0, 9_0, "NvsStreamingEngineCaptureFlag_DontConfigAudioSession") = 1024, //!< \if ENGLISH Does not apply automatically configures application audiosession. Note：This option is not available after version 3.11.0. If you need echo cancellation, refer to the setAECEnabled method . \else 不使用自动配置AudioSession.注意：3.11.0版本后此项不可用，如需回声消除参考setAECEnabled方法 \endif \since 2.12.0
    NvsStreamingEngineCaptureFlag_DisableFlipOfFrontCamera = 2048,  //!< \if ENGLISH Disable flip of front camera \else 禁止在前置摄像头上翻转画面 \endif
    NvsStreamingEngineCaptureFlag_InputAspectRatioUsed = 4096,         //!< \if ENGLISH Capture preview size aspect ratio use user input \else 采集预览画面横纵比使用用户输入进行设置，如果Camera不支持当前的横纵比，找到最接近设置 \endif
    NvsStreamingEngineCaptureFlag_EnableTakePicture = 8192,         //!< \if ENGLISH Capture preview size aspect ratio use user input \else 采集预览画面横纵比使用用户输入进行设置，如果Camera不支持当前的横纵比，找到最接近设置 \endif
    NvsStreamingEngineCaptureFlag_EnableHDR = 1 << 16,         //!< \if ENGLISH Enable HDR video when Device is supported \else 如果设备支持开启HDR视频 \endif
    NvsStreamingEngineCaptureFlag_DontConfigAudioSession = 1 << 17,    //!< \if ENGLISH With this flag, you must be responsible for implementing AudioSession that meets the recording requirements in the playback and recording category to meet the normal functional requirements of the SDK. This SDK is no longer responsible for the configuration of AudioSession \else 采用该flag 外界必须自己负责实现满足播放录制模式下录音需求的AudioSession， 以满足sdk 正常功能需求, sdk 不再负责AudioSession 的配置 \endif
} NvsStreamingEngineCaptureFlag;

/*! \if ENGLISH
 *  \brief Enters the image rotation angle of the buffer.
 *  \else
 *  \brief 输入buffer的图像旋转角度
 *  \endif
*/
typedef enum
{
    BufferImageRotation_0 = 0,
    BufferImageRotation_90 = 1,
    BufferImageRotation_180 = 2,
    BufferImageRotation_270 = 3,
} BufferImageRotation;

/*! \if ENGLISH
 *  \brief Stabilization flag
 *  \else
 *  \brief 防抖动标志
 *  \endif
*/
typedef enum
{
    VideoStabilizationFlag_Off = 0,          //!< \if ENGLISH  Video stabilization mode is off. \else  视频防抖动模式关闭 \endif
    VideoStabilizationFlag_Auto = 1,         //!< \if ENGLISH  Video stabilization automatic mode. \else  视频防抖自动模式 \endif
    VideoStabilizationFlag_Standard = 2,     //!< \if ENGLISH  Video standard stabilization. \else  视频防抖自动模式 \endif
    VideoStabilizationFlag_Super = 3,        //!< \if ENGLISH  Video stabilization movie mode. \else  视频防抖电影模式 \endif
} VideoStabilizationFlag;

/*! \if ENGLISH
 *  \brief Flag of Recording
 *  \else
 *  \brief 录制标志
 *  \endif
*/
typedef enum
{
    NvsStreamingEngineRecordingFlag_VideoIntraFrameOnly = 2,  //!< \if ENGLISH Records a video file containing I-Frame only. \else 录制仅包含I-Frame的视频文件 \endif
    NvsStreamingEngineRecordingFlag_OnlyRecordVideo = 16,     //!< \if ENGLISH Records only video stream. \else 仅录制视频流 \endif
    NvsStreamingEngineRecordingFlag_IgnoreVideoRotation = 32,  //!< \if ENGLISH Ignores video device rotation while recording. Remark：it has only effects when using the method of "startRecordingWithFx:". \else 录制时不根据设备的手持方向对视频做旋转。注意：必须用startRecordingWithFx进行录制才有效果 \endif
    NvsStreamingEngineRecordingFlag_WithoutFxUseStreamingWriter = 256,  //!< \if ENGLISH Video record without fx that be streaming writer used. Remark：it has only effects when using the method of "startRecording:". \else 使用StreamingWirter进行不带特效录制。注意：必须用startRecording进行录制才有效果 \endif
    NvsStreamingEngineRecordingFlag_FlipHorizontally = 512  //!< \if ENGLISH Flip horizontally input video frame \else 镜像输入视频帧 \endif
} NvsStreamingEngineRecordingFlag;

/*! \if ENGLISH
 *  \brief Camera flash mode
 *  \else
 *  \brief 闪光灯模式
 *  \endif
*/
typedef enum
{
    NvsCameraFlashMode_FlashOff = 1,  //!< \if ENGLISH Turns off photo flash \else 关闭拍照闪光灯 \endif
    NvsCameraFlashMode_FlashOn = 2,   //!< \if ENGLISH Turns On photo flash \else 开启拍照闪光灯 \endif
    NvsCameraFlashMode_FlashAuto = 4,  //!< \if ENGLISH Turns On the take photo to auto \else 开启拍照闪光灯自动模式 \endif
    NvsCameraFlashMode_Torch = 8  //!< \if ENGLISH Turns On torch \else 开启补光灯 \endif
} NvsCameraFlashMode;

/*! \if ENGLISH
 *  \brief Flag of seeking engine
 *  \else
 *  \brief 引擎定位标识
 *  \endif
*/
typedef enum {
    NvsStreamingEngineSeekFlag_ShowCaptionPoster = 2,          //!< \if ENGLISH Shows entire caption. \else 整体展示字幕效果 \endif
    NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster = 4,  //!< \if ENGLISH Shows entire animated sticker. \else 整体展示动画贴纸效果 \endif
    NvsStreamingEngineSeekFlag_BuddyHostVideoFrame = 16,        //!< \if ENGLISH Buddy video frame in host. \else 伴侣视频帧 \endif
    NvsStreamingEngineSeekFlag_NotConnectToLivewindow = 128,        //!< \if ENGLISH Seek can be done without connecting to the LiveWindow. \else 不连接livewindow也可以做seek操作 \endif
    NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame = 256,          //!< \if ENGLISH Buddy video frame in host after decoding. \else 解码后伴侣视频帧 \endif
    NvsStreamingEngineSeekFlag_DontDownloadBuddyBufferForTimelineEffect = 1024, //!< @if ENGLISH @brief  Flag for detecting AR texture on timeline disable downloaded @else @brief 禁止时间线AR特效下传纹理做检测 @endif
    NvsStreamingEngineSeekFlag_AllowFastScrubbing NS_ENUM_DEPRECATED_IOS(8_0, 9_0, "NvsStreamingEngineSeekFlag_AllowFastScrubbing") = 2048, //!< @if ENGLISH @brief Flag for faster scrubbing at the expense of some accuracy @else @brief 以牺牲一定精度为代价实现更快速的scrubbing @endif
} NvsStreamingEngineSeekFlag;

/*! \if ENGLISH
 *  \brief Flag of playing engine
 *  \else
 *  \brief 引擎播放标志
 *  \endif
*/
typedef enum {
    NvsStreamingEnginePlaybackFlag_LowPipelineSize = 8,                 //!< \if ENGLISH Reduces the internal pipeline size of the engine during playback. \else 降低引擎在播放时内部的流水线尺寸 \endif
    NvsStreamingEnginePlaybackFlag_DisableFixedPrerollTime = 16,        //!< \if ENGLISH Reduces the engine's playback delay of the first frame during playback. \else 降低引擎在播放时首帧的播出延迟 \endif
    NvsStreamingEnginePlaybackFlag_BuddyHostVideoFrame = 32,            //!< \if ENGLISH Buddy video frame in host. \else 伴侣视频帧 \endif
    NvsStreamingEnginePlaybackFlag_AutoCacheAllCafFrames = 128,         //!< \if ENGLISH Cache all frames of caf file \else 自动缓存所有的CAF帧 \endif
    NvsStreamingEnginePlaybackFlag_SpeedCompMode = 512,           //!< \if ENGLISH Playback with speed compensation \else 速度补偿模式 \endif
    NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame = 2048,    //!< \if ENGLISH Buddy video frame in host after decoding. \else 解码后伴侣视频帧 \endif
    NvsStreamingEnginePlaybackFlag_VariableFrameRateEnable = 4096,    //!< \if ENGLISH Enable variable frame rate playback, and the playback frame rate will change with the video frame rate \else 开启变帧率播放，播放的帧率会随着视频帧率变化。 \endif
    NvsStreamingEnginePlaybackFlag_DisableDropFrameMode = 16384, //!< \if ENGLISH Disable the frame dropping mode for playback. If this flag is not added, the SDK will ensure continuous audio playback. If the video rendering is complex and so on, it will use the frame dropping mode to ensure video and audio synchronization \else 禁用丢帧模式进行播放，如果不添加这个flags，SDK是会保证音频播放连续，如果视频渲染复杂等等引起的不实时，会使用丢帧的方式保证视音频同步。 \endif
    NvsStreamingEnginePlaybackFlag_DontDownloadBuddyBufferForTimelineEffect = 1 << 17, //!< @if ENGLISH @brief  Flag for detecting AR texture on timeline disable downloaded @else @brief 禁止时间线AR特效下传纹理做检测 @endif
} NvsStreamingEnginePlaybackFlag;

/*! \if ENGLISH
 *  \brief Flag of stoppoing engine stopp
 *  \else
 *  \brief 停止引擎标志
 *  \endif
*/
typedef enum {
    NvsStreamingEngineStopFlag_Async = 2    //!< \if ENGLISH Stops the engine asynchronously, and avoids blocking the main thread. \else 异步停止引擎，避免阻塞主线程 \endif
} NvsStreamingEngineStopFlag;

/*! \if ENGLISH
 *  \brief Flag of human detection
 *  \else
 *  \brief 人体检测特征标志
 *  \endif
*/
typedef enum {
    NvsHumanDetectionFeature_FaceLandmark = 1,
    NvsHumanDetectionFeature_FaceAction = 2,
    NvsHumanDetectionFeature_AvatarExpression = 4,
    NvsHumanDetectionFeature_VideoMode = 8,
    NvsHumanDetectionFeature_ImageMode = 16,
    NvsHumanDetectionFeature_MultiThread = 32,
    NvsHumanDetectionFeature_SingleThread = 64,
    NvsHumanDetectionFeature_Extra = 128,
    NvsHumanDetectionFeature_Background = 256,
    NvsHumanDetectionFeature_HandLandmark = 512,
    NvsHumanDetectionFeature_HandAction = 1024,
    NvsHumanDetectionFeature_HandBone = 2048,
    NvsHumanDetectionFeature_EyeballLandmark = 4096,
    NvsHumanDetectionFeature_MultiDetect = 8192,
    NvsHumanDetectionFeature_SegmentationSky = 16384,
	NvsHumanDetectionFeature_SemiImageMode = 32768,
    NvsHumanDetectionFeature_HalfBody = 65536,
    NvsHumanDetectionFeature_FaceAttri = 131072,
    NvsHumanDetectionFeature_FaceAttriShape = 262144
} NvsHumanDetectionFeatureFlag;

/*! \anchor HUMAN_DETECTION_OPTIONS */
/*!
 *  \if ENGLISH
 *   @name Options of human detection
 *  \else
 *   @name 检测选项
 *  \endif
*/
//!@{
#define HUMAN_DETECTION_OPTIONS_FACE_DETECT_THREAD_NUM            @"Face Detect Thread Num"       //!< \if ENGLISH Face detect thread number \else 人脸检测线程数 \endif
#define HUMAN_DETECTION_OPTIONS_FACE_LANDMARK_THREAD_NUM          @"Face Landmark Thread Num"     //!< \if ENGLISH Face landmark thread number \else 人脸点位检测线程数 \endif
#define HUMAN_DETECTION_OPTIONS_FACE_TRACK_THREAD_NUM             @"Face Track Thread Num"        //!< \if ENGLISH Face track thread number \else 人脸跟踪线程数 \endif
#define HUMAN_DETECTION_OPTIONS_SKY_SEGMENTATION_THREAD_NUM       @"Sky Segmentation Thread Num"  //!< \if ENGLISH Face track thread number \else 天空分割线程数 \endif
//!@}

/*! \if ENGLISH
 *  \brief Type of human detection data package
 *  \else
 *  \brief 人体检测数据包类型
 *  \endif
*/
typedef enum {
    NvsHumanDetectionDataType_FakeFace = 0,
    NvsHumanDetectionDataType_Makeup,   // deprecated
    NvsHumanDetectionDataType_SkinColor,
    NvsHumanDetectionDataType_PE106,
    NvsHumanDetectionDataType_PE240,
    NvsHumanDetectionDataType_CustomAvatar,
    NvsHumanDetectionDataType_Makeup2,  // deprecated, replaced by NvsHumanDetectionDataType_FaceCommon
    NvsHumanDetectionDataType_FaceCommon,
    NvsHumanDetectionDataType_AdvancedBeauty,
} NvsHumanDetectionDataTypeFlag;

/*! \if ENGLISH
 *  \brief Hardware error type
 *  \else
 *  \brief 硬件错误类型
 *  \endif
 *  \deprecated
*/
typedef enum {
    NvsStreamingEngineHarwareErrorType_Video_Encoder_Setup_Error = 0,
    NvsStreamingEngineHarwareErrorType_Video_Encoding_Error,
    NvsStreamingEngineHarwareErrorType_Video_Decoder_Setup_Error,
    NvsStreamingEngineHarwareErrorType_Video_Decoding_Error
} NvsStreamingEngineHarwareErrorType;

/*! \if ENGLISH
 *  \brief Media error type
 *  \else
 *  \brief 媒体错误类型
 *  \endif
*/
typedef enum {
    NvsStreamingEngineMediaErrorType_Unknown_Error = -1,
    NvsStreamingEngineMediaErrorType_Video_Encoder_Setup_Error = 0,
    NvsStreamingEngineMediaErrorType_Video_Encoding_Error,
    NvsStreamingEngineMediaErrorType_Video_Decoder_Setup_Error,
    NvsStreamingEngineMediaErrorType_Video_Decoding_Error
} NvsStreamingEngineMediaErrorType;

/*! \anchor COMPILE_ERROR_TYPE */
/*!
 *  \if ENGLISH
 *   @name compile error type
 *  \else
 *   @name 生成错误类型
 *  \endif
 */
typedef enum {
    NvsStreamingEngineCompileErrorType_No_Error = 0,
    NvsStreamingEngineCompileErrorType_Cancelation = 1,
    NvsStreamingEngineCompileErrorType_Video_Encoder_Setup_Error = 2,
    NvsStreamingEngineCompileErrorType_Video_Encoding_Error = 3,
    NvsStreamingEngineCompileErrorType_Video_Decoding_Error = 4,
    NvsStreamingEngineCompileErrorType_Muxing_Error = 5,
} NvsStreamingEngineCompileErrorType;

/*! \anchor CAPTURE_DEVICE_ERROR_CODE */
/*!
 *  \if ENGLISH
 *   @name capture device error code
 *  \else
 *   @name 采集设备错误码
 *  \endif
 */
typedef enum {
    NvsStreamingEngineCaptureDeviceErrorCode_Unknown = 1,
    NvsStreamingEngineCaptureDeviceErrorCode_ServerDied = 2,
    NvsStreamingEngineCaptureDeviceErrorCode_FailToStart = 3,
    NvsStreamingEngineCaptureDeviceErrorCode_FailToConnect = 4
} NvsStreamingEngineCaptureDeviceErrorCode;

/*! \if ENGLISH
 *  \brief Create timeline flag
 *  \else
 *  \brief 创建时间线标志
 *  \endif
*/
typedef enum {
    NvsCreateTimelineType_LongestDurationConsiderAllTracks = 1, //!< \if ENGLISH timeline's longest duration consider all tracks  \else 由所有音视频轨的最大时长决定时间线长度 \endif
    NvsCreateTimelineType_SyncAudioVideoTransOnVideoTrack = 2,  //!< \if ENGLISH Sync audio transition and video transiton on video track  \else 同步处理在视频轨道上的视频和音频转场 \endif
    NvsCreateTimelineType_UseMipmap = 4,                        //!< \if ENGLISH Use mipmap anti-aliasing  \else 使用mipmap抗锯齿 \endif
    NvsCreateTimelineType_VariantImageSize = 8,                 //!< \if ENGLISH Automatically adapt timeline resolution when add images  \else 加载图片时自动适配timeline分辨率 \endif
    NvsCreateTimelineType_DontAddDefaultVideoTransition = 16,   //!< \if ENGLISH Do not add a default video transition  \else 不添加默认视频转场 \endif
    NvsCreateTimelineType_Orphan = 128,                         //!< \if ENGLISH Orphan timeline flag, destroy the timeline after its parent timeline destroyed.  \else 孤儿时间线，销毁父亲时间线的同时销毁该时间线 \endif
    NvsCreateTimelineType_OriginalSizeUsedForRawFilter = 2048   //!< @if ENGLISH @brief  Flag for Raw filter input uses the original size of the file @else @brief Raw滤镜的输入使用文件原始的尺寸 @endif
} NvsCreateTimelineTypeFlag;

/*! \anchor  NvsHDRCapabilityFlag */
/*!
 *  \if ENGLISH
 *   @name HDR capability flags
 *  \else
 *   @name HDR能力
 *  \endif
 */
typedef enum {
    NvsHDRCapabilityFlagSupportedByImporter = 1,        //!< \if ENGLISH Support importing HDR video  \else 支持导入HDR视频 \endif
    NvsHDRCapabilityFlagSupportedByEditing = 2,         //!< \if ENGLISH Editing Support HDR  \else 编辑支持HDR \endif
    NvsHDRCapabilityFlagSupportedByExporter = 4,        //!< \if ENGLISH Support exporting HDR video  \else 支持导出HDR视频 \endif
    NvsHDRCapabilityFlagSupportedByLivewindow = 8,      //!< \if ENGLISH Livewindow support HDR \else 预览窗口支持HDR \endif
}NvsHDRCapabilityFlag;

/*!
 *  \if ENGLISH
 *   @name Playback exception types
 *  \else
 *   @name 播放错误类型
 *  \endif
 */
typedef enum
{
    NvsStreamingEnginePlaybackExceptionType_MediaFileError = 0
}NvsStreamingEnginePlaybackExceptionType;

typedef enum{
    NvsDebugLevelNone = 0,
    NvsDebugLevelError,
    NvsDebugLevelWarning,
    NvsDebugLevelDebug,
    NvsDebugLevelVerbose,
    NvsDebugLevelMax
} NvsDebugLevel;

/*! \anchor RECORD_CONFIGURATIONS */
/*!
 *  \if ENGLISH
 *   @name Configuration of recording video
 *  \else
 *   @name 录制视频配置
 *  \endif
*/
//!@{
#define NVS_RECORD_BITRATE                      @"bitrate"			//!< \if ENGLISH Record bitrate，type: int, such as 3000000 for 3M biterate \else 录制视频码率，类型：int，比如要设置3M码率，则传3000000 \endif
#define NVS_RECORD_GOP_SIZE                     @"gopsize"            //!< \if ENGLISH Record GOP size, type: int, default is 30 \else 录制视频GOP SIZE，类型：int，比如要设置gop size为15，则传15，默认值30  \endif
#define NVS_RECORD_VIDEO_ENCODEC_NAME           @"video encoder name"              //!< \if ENGLISH Assigned video encoding format, hevc(h.256) is supported, default is h.264\else 指定视频压缩格式，类型：string，目前支持hevc(h.265)，默认h.264\endif
#define NVS_RECORD_HDR_VIDEO_COLOR_TRANSFER     @"encorder color transfer"         //!< \if ENGLISH Set color transfer for HDR to encode, curve: string, default is "none", can support "st2084" and "hlg", \else 设置HDR视频输出的传输曲线，类型: string 默认值:"none", 可以支持"st2084"和"hlg"两种曲线 \endif
//!@}

/*! \anchor COMPILE_CONFIGURATIONS */
/*!
 *  \if ENGLISH
 *   @name Configuration of Compilation Timeline
 *  \else
 *   @name 生成时间线的配置，以键值对的形式设置
 *  \endif
*/
//!@{
#define NVS_COMPILE_BITRATE                          @"bitrate"                        //!< \if ENGLISH Compile bitrate，type: int, such as 3000000 for 3M biterate \else 生成视频码率，类型：int，比如要设置3M码率，则传3000000 \endif
#define NVS_COMPILE_GOP_SIZE                         @"gopsize"                        //!< \if ENGLISH Compile GOP size, type: int, default is 30 \else 生成视频GOP SIZE，类型：int，比如要设置gop size为15，则传15，默认值30 \endif
#define NVS_COMPILE_AUDIO_BITRATE                    @"audio bitrate"                  //!< \if ENGLISH Compile audio bitrate, type: int, such as 128000 for 128k bitrate \else 生成音频码率，类型：int，比如要设置128K码率，则传128000 \endif
#define NVS_COMPILE_LOSSLESS_AUDIO                   @"lossless audio"                 //!< \if ENGLISH Whether to compile lossless audio, type: boolean \else 是否生成无损音频，类型：bool，传true或者false \endif
#define NVS_COMPILE_OPTIMIZE_FOR_NETWORK_USE         @"optimize-for-network-use"       //!< \if ENGLISH Whether to prepose the index table, type: boolean \else 是否前置索引表，类型：bool，传true或者false \endif
#define NVS_COMPILE_VIDEO_ENCODEC_NAME               @"video encoder name"             //!< \if ENGLISH Assigned video encoding format, hevc(h.256) is supported, default is h.264\else 指定视频压缩格式，类型：string，目前支持hevc(h.265)，默认h.264\endif
#define NVS_COMPILE_AUDIO_ENCODEC_NAME               @"audio encoder name"             //!< \if ENGLISH Assigned audio encoding format, "amr-wb" and "mp3" are supported, default is "aac" \else 指定音频压缩格式，类型：string，目前支持“mp3”，"amr-wb"，默认"aac"\endif
#define NVS_COMPILE_VIDEO_FPS                        @"fps"                            //!< \if ENGLISH frames per second when compiling, type: NSData, such as NvsRational videoFps = {30, 1},[NSData dataWithBytes:&videoFps length:sizeof(NvsRational)] forKey:NVS_COMPILE_VIDEO_FPS]\else 生成的帧速率，类型：NSData，比如设置NvsRational videoFps = {30, 1},[NSData dataWithBytes:&videoFps length:sizeof(NvsRational)] forKey:NVS_COMPILE_VIDEO_FPS] \endif
#define NVS_COMPILE_DONT_USE_VIDEO_TOOLBOX           @"dont-use-video-toolbox"         //!< \if ENGLISH Whether to use video toolbox, type: boolean \else 是否使用VideoToolBox，类型：bool，传true或者false \endif
#define NVS_COMPILE_DISABLE_ENCODING_SPEED_PRIORITY  @"disable encoding speed priority"    //!< \if ENGLISH Disable VideoToolbox encoding speed priority. Type: boolean, pass true or false. \else 是否禁用 VideoToolbox 的编码速度优先策略，类型：bool，传 true 或 false。 \endif
#define NVS_COMPILE_HDR_VIDEO_COLOR_TRANSFER         @"encorder color transfer"        //!< \if ENGLISH Set color transfer for HDR to encode, curve: string, default is "none", can support "st2084" and "hlg", \else 设置HDR视频输出的传输曲线，类型: string 默认值:"none", 可以支持"st2084"和"hlg"两种曲线 \endif
#define NVS_COMPILE_ENABLE_BREAKPOINT_CONTINUATION   @"enable breakpoint continuation" //!< \if ENGLISH Set whether enable breakpoint continuation \else 设置是否开启断点续导 \endif
#define NVS_COMPILE_CACHE_FILE_PATH                  @"cache file path"                //!< \if ENGLISH Breakpoint continuation cache file path \else 断点续导缓存文件路径 \endif
#define NVS_COMPILE_CACHE_FILE_DURATION              @"cache file duration"            //!< \if ENGLISH Breakpoint continuation cache file duration，in microseconds. The minimum duration is 1,000,000 microseconds. The default value is 10,000,000 microseconds. \else 断点续导切片视频时长，单位为微秒，最小为1,000,000微秒, 默认值是10,000,000微秒 \endif
#define NVS_COMPILE_CACHE_FILE_SIZE                  @"cache file size"                //!< \if ENGLISH Breakpoint continuation cache file size. The minimum size is 1,000,000 bytes. The default value is 0. \else 断点续导切片视频大小, 最小为1,000,000字节，默认为0 \endif
#define NVS_COMPILE_SOFTWARE_ENCODER_CRF             @"software encorder crf"          //!< \if ENGLISH Preset crf parameters for software encoder, type: int, range is [1, 99], less is better，default is 23 \else 软编码crf预设值，类型：int，最大是99，最小是1，值越小视频质量越好，默认是23 \endif
#define NVS_COMPILE_SOFTWARE_ENCODER_CRF_BITRATE_MAX @"software encorder crf bitrate max" //!< \if ENGLISH Preset maximum bitrate for software encoder in crf mode, type: int \else 软编码crf模式bitrate max预设值，类型：int \endif
#define NVS_COMPILE_SOFTWARE_ENCODER_MODE            @"software encorder mode"         //!< \if ENGLISH Software encoder mode, type: string, support “abr”、“crf”，default is crf \else 软编码模式，类型：String，包括“abr”、“crf”，默认值是crf \endif

#define NVS_COMPILE_CREATION_TIME                    @"creation time" //!< \if ENGLISH Set creation time for this file. Foramt:"YYYY-MM-DDTHH:MM:SS",eg:2010-12-24T12:00:00(use location time) \else 设置媒体文件的创建时间,格式:"YYYY-MM-DDTHH:MM:SS"例如：2010-12-24T12:00:00(使用LocationTime)\endif
#define NVS_COMPILE_METADATADESCRIPTION              @"metadata description"         //!< \if ENGLISH Corresponding AVMetadataCommonKeyDescription, sets the metadata description of the video files \else 对应AVMetadataCommonKeyDescription，设置视频文件的metadata描述，不支持中文 \endif
#define NVS_COMPILE_AUDIO_SAMPLE_RATE                @"audio sample rate"          //!< \if ENGLISH Set the audio sampling rate, currently supporting a minimum of 16K and a maximum of 128K \else 设置音频采样率，目前最小支持16K，最大支持128K \endif
#define NVS_COMPILE_AUDIO_CHANNELS_MODE              @"audio channels mode"          //!< \if ENGLISH Set up audio channels, currently supporting "mixtomono", with default and timeline settings consistent \else 设置音频通道 目前支持"mixtomono", 默认和时间线设置一致 \endif
#define NVS_COMPILE_FILE_META_DATA                   @"file metadata"          //!< \if ENGLISH Set meta data, for example:"creation-time=xxxxx;location=17.641347+160.931648;" \else 设置meta-data，例如:"creation-time=xxxxx;location=17.641347+160.931648;" \endif
#define NVS_COMPILE_GIF_STATS_MODE                   @"gif stats mode"          //!< \if ENGLISH Set the statistical mode for GIF export. Currently, it supports diff, single, and defaults to single mode. If set to diff mode, it is best to export GIF for no more than 10 seconds. In this mode, memory requirements are relatively high \else 设置GIF导出是的统计模式，目前支持diff，和single，默认为single模式，如果设置为diff模式，导出GIF的长度最好不要超过10秒钟，在这种模式下对内存要求比较大 \endif
//!@}


/*! \if ENGLISH
 *  \brief Special identifier when acquiring audio and video information.
 *  \else
 *  \brief 获取音视频信息时的特殊标识
 *  \endif
*/
typedef enum {
    NvsAVFileinfoExtra_None = 0,          //!< \if ENGLISH Default. \else 默认值 \endif
    NvsAVFileinfoExtra_AVPixelFormat      //!< \if ENGLISH Gets AVPixelFormat. \else 获取AVPixelFormat \endif
} NvsAVFileinfoExtraFlag;

/*! \if ENGLISH
 *  \brief Camera Device Type.
 *  \else
 *  \brief 摄像头设备类型
 *  \endif
 *  \since 3.16.0
*/
typedef enum {
    NvsCameraDeviceType_None,                     //!< \if ENGLISH No camera found. \else 未找到摄像头 \endif
    NvsCameraDeviceType_WideAngle,                //!< \if ENGLISH WideAngle camera. \else 广角镜头 \endif
    NvsCameraDeviceType_Telephoto,                //!< \if ENGLISH Telephoto camera. \else 长焦镜头 \endif
    NvsCameraDeviceType_TrueDepth,                //!< \if ENGLISH TrueDepth camera. \else 原深感镜头 \endif
    NvsCameraDeviceType_WideAngleAndTelephoto,    //!< \if ENGLISH WideAngleAndTelephoto camera. \else 长焦广角镜头 \endif
    NvsCameraDeviceType_UltraWideCamera,          //!< \if ENGLISH UltraWideCamera camera. \else 超广角镜头 \endif
    NvsCameraDeviceType_SpecailDevice             //!< \if ENGLISH SpecailDevice camera. \else 特殊设备镜头 \endif
} NvsCameraDeviceType;

@class NvsCaptureDeviceCapability;
@class NvsCaptureVideoFx;
@class NvsFxDescription;
@class NvsMediaError;

@protocol NvsStreamingContextDelegate <NSObject>
@optional


/*! \if ENGLISH
 *  \brief The captured device is ready.
 *  \param captureDeviceIndex Device index
 *  \else
 *  \brief 采集设备准备完成
 *  \param captureDeviceIndex 设备索引
 *  \endif
*/
- (void)didCaptureDeviceCapsReady:(unsigned int)captureDeviceIndex;

/*! \if ENGLISH
 *  \brief Captured device resolution is ready.
 *  \param captureDeviceIndex Device index
 *  \else
 *  \brief 采集设备预览解析度准备完成
 *  \param captureDeviceIndex 设备索引
 *  \endif
*/
- (void)didCaptureDevicePreviewResolutionReady:(unsigned int)captureDeviceIndex;

/*! \if ENGLISH
 *  \brief Startes the captured device preview.
 *  \param captureDeviceIndex Device index
 *  \else
 *  \brief 采集设备预览开始
 *  \param captureDeviceIndex 设备索引
 *  \endif
*/
- (void)didCaptureDevicePreviewStarted:(unsigned int)captureDeviceIndex;

/*! \if ENGLISH
 *  \brief Capture device error.
 *  \param captureDeviceIndex Device index
 *  \param errorCode Error code, please refert to [CAPTURE_DEVICE_ERROR_CODE](@ref NvsStreamingEngineCaptureDeviceErrorCode)
 *  \else
 *  \brief 采集设备错误
 *  \param captureDeviceIndex 设备索引
 *  \param errorCode 错误码,请参见[采集设备错误码](@ref NvsStreamingEngineCaptureDeviceErrorCode)
 *  \endif
*/
- (void)didCaptureDeviceError:(unsigned int)captureDeviceIndex errorCode:(int32_t)errorCode;

/*! \if ENGLISH
 *  \brief Stopps  the captured device
 *  \param captureDeviceIndex Device index
 *  \else
 *  \brief 采集设备停止
 *  \param captureDeviceIndex 设备索引
 *  \endif
*/
- (void)didCaptureDeviceStopped:(unsigned int)captureDeviceIndex;

/*! \if ENGLISH
 *  \brief The captured device's autofocus is completed.
 *  \param captureDeviceIndex Device index
 *  \param succeeded Whether the autofocus is completed.
 *  \else
 *  \brief 采集设备自动对焦完成
 *  \param captureDeviceIndex 设备索引
 *  \param succeeded 对焦是否完成
 *  \endif
*/
- (void)didCaptureDeviceAutoFocusComplete:(unsigned int)captureDeviceIndex succeeded:(BOOL)succeeded;

/*! \if ENGLISH
 *  \brief Recording started.
 *  \param captureDeviceIndex Device index
 *  \else
 *  \brief 采集录制开始
 *  \param captureDeviceIndex 设备索引
 *  \endif
 *  \sa didCaptureRecordingFinished:
 *  \sa didCaptureRecordingError:
 *  \since 1.16.0
*/
- (void)didCaptureRecordingStarted:(unsigned int)captureDeviceIndex;

/*! \if ENGLISH
 *  \brief Recording first video frame is presented..
 *  \param captureDeviceIndex Device index
 *  \param timeStamp First video frame timestamp
 *  \else
 *  \brief 录制第一帧视频呈现
 *  \param captureDeviceIndex 设备索引
 *  \param timeStamp 录制第一帧视频帧的时间戳
 *  \endif
 *  \sa didCaptureRecordingFinished:
 *  \sa didCaptureRecordingError:
 *  \since 2.14.0
*/
- (void)didCaptureRecordingFirstVideoFrameReached:(unsigned int)captureDeviceIndex timeStamp:(int64_t)timestamp;

/*! \if ENGLISH
 *  \brief Notification of recording's duration.
 *  \param captureDeviceIndex Device index
 *  \param duration The duration that has been recorded (in microseconds).
 *  \else
 *  \brief 录制时长通知
 *  \param captureDeviceIndex 设备索引
 *  \param duration 已经录制的时长，单位是微秒
 *  \endif
 *  \since 1.17.0
*/
- (void)didCaptureRecordingDurationUpdated:(int)captureDeviceIndex duration:(int64_t)duration;

/*! \if ENGLISH
 *  \brief Recording is completed.
 *  \param captureDeviceIndex Device index
 *  \else
 *  \brief 采集录制完成
 *  \param captureDeviceIndex 设备索引
 *  \endif
 *  \sa didCaptureRecordingStarted:
 *  \sa didCaptureRecordingError:
*/
- (void)didCaptureRecordingFinished:(unsigned int)captureDeviceIndex;

/*! \if ENGLISH
 *  \brief Recording fails.
 *  \param captureDeviceIndex Device index
 *  \else
 *  \brief 采集录制失败
 *  \param captureDeviceIndex 设备索引
 *  \endif
 *  \sa didCaptureRecordingStarted:
 *  \sa didCaptureRecordingFinished:
*/
- (void)didCaptureRecordingError:(unsigned int)captureDeviceIndex;

/*! \if ENGLISH
 *  \brief Playback preload completed.
 *  \param timeline Timeline
 *  \else
 *  \brief 播放预先加载完成
 *  \param timeline 时间线
 *  \endif
*/
- (void)didPlaybackPreloadingCompletion:(NvsTimeline *)timeline;

/*! \if ENGLISH
 *  \brief Current position of timeline playback.
 *  \param timeline Timeline
 *  \param position Current position
 *  \else
 *  \brief 时间线播放的当前位置
 *  \param timeline 时间线
 *  \param position 当前位置
 *  \endif
 *  \since 1.6.0
*/
- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position;

/*! \if ENGLISH
 *  \brief Timeline playback delay.
 *  \param timeline Timeline
 *  \param time Delay time
 *  \param flag Whether it's video (true is video, false is audio).
 *  \else
 *  \brief 时间线播放视频延迟
 *  \param timeline 时间线
 *  \param time 延迟时间
 *  \param flag 是否是视频（true是视频，false是音频）
 *  \endif
 *  \since 2.5.0
*/
- (void)didPlaybackDelayed:(NvsTimeline *)timeline delayTime:(int64_t)time isVideo:(bool)flag;

/*! \if ENGLISH
 *  \brief Playback stopped.
 *  \param timeline Timeline
 *  \else
 *  \brief 播放停止
 *  \param timeline 时间线
 *  \endif
*/
- (void)didPlaybackStopped:(NvsTimeline *)timeline;

/*! \if ENGLISH
 *  \brief Playbacks to the end.
 *  \param timeline Timeline
 *  \else
 *  \brief 播放到结尾
 *  \param timeline 时间线
 *  \endif
*/
- (void)didPlaybackEOF:(NvsTimeline *)timeline;

/*! \if ENGLISH
 *  \brief Progress of compiling video file.
 *  \param timeline Timeline
 *  \param progress Progress
 *  \else
 *  \brief 生成视频文件进度
 *  \param timeline 时间线
 *  \param progress 进度值
 *  \endif
*/
- (void)didCompileProgress:(NvsTimeline *)timeline progress:(int)progress;

/*! \if ENGLISH
 *  \brief Progress of compiling video file.
 *  \param timeline Timeline
 *  \param progress float Progress
 *  \else
 *  \brief 生成视频文件进度
 *  \param timeline 时间线
 *  \param progress 浮点进度值
 *  \endif
*/
- (void)didCompileFloatProgress:(NvsTimeline *)timeline progress:(float)progress;

/*! \if ENGLISH
 *  \brief Compiling video file is completed.
 *  \param timeline Timeline
 *  \else
 *  \brief 生成视频文件完成
 *  \param timeline 时间线
 *  \endif
 *  \sa didCompileFailed:
*/
- (void)didCompileFinished:(NvsTimeline *)timeline;

/*! \if ENGLISH
 *  \brief Compiling video file is completed.
 *  \param timeline Timeline
 *  \param isCanceled The midway cancellation results in the completion of the compile. Note: any operations on the engine that causes compilation to stop are refer to as cancelation.
 *  \else
 *  \brief 生成视频文件完成
 *  \param timeline 时间线
 *  \param isCanceled 中途取消导致生成完成。注：任何对引擎操作引起的停止生成均视为中途取消
 *  \endif
 *  \since 1.6.0
 *  \sa didCompileFinished:
*/
- (void)didCompileCompleted:(NvsTimeline *)timeline isCanceled:(BOOL)isCanceled;

/*! \if ENGLISH
 *  \brief Timeline compile file completion.
 *  \param timeline Timeline.
 *  \param isHardwareEncoder Whether hardware coding is used for completion.
 *  \param errorType Type of compile error, please refert to [COMPILE_ERROR_TYPE](@ref NvsStreamingEngineCompileErrorType)
 *  \param stringInfo Assistance information.
 *  \param flags flags
 *  \else
 *  \brief 时间线生成文件完成
 *  \param timeline 时间线
 *  \param isHardwareEncoder 是否是硬件编码
 *  \param errorType 错误类型,请参见[生成错误类型](@ref NvsStreamingEngineCompileErrorType)
 *  \param stringInfo 辅助的字符串信息
 *  \param flags 标志量
 *  \endif
 *  \since 2.22.0
 */
- (void)didCompileCompleted:(NvsTimeline *)timeline isHardwareEncoding:(BOOL)isHardwareEncoding errorType:(int)errorType errorString:(NSString*)errorString flags:(int)flags;

/*! \if ENGLISH
 *  \brief Fails to compile video file.
 *  \param timeline Timeline
 *  \else
 *  \brief 生成视频文件失败
 *  \param timeline 时间线
 *  \endif
*/
- (void)didCompileFailed:(NvsTimeline *)timeline;

/*! \if ENGLISH
 *  \brief Timeline compile slice file completion.
 *  \param timeline Timeline.
 *  \param filePath Media file path
 *  \param isVideo Whether is video or audio
 *  \param index Media index
 *  \else
 *  \brief 时间线生成切片文件完成
 *  \param timeline 时间线
 *  \param filePath 文件路径
 *  \param isVideo 是否是视频
 *  \param index 文件序号
 *  \endif
 *  \since 3.13.0
 */
- (void)didCompileSliceCompleted:(NvsTimeline *)timeline filePath:(NSString*)filePath isVideo:(BOOL)isVideo index:(int)index;

/*! \if ENGLISH
 *  \brief Engine state changed.
 *  \param state Engine state
 *  \else
 *  \brief 引擎状态改变
 *  \param state 引擎状态
 *  \endif
*/
- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state;

/*! \if ENGLISH
 *  \brief First video frame is presented.
 *  \param timeline Timeline
 *  \else
 *  \brief 第一视频帧呈现
 *  \param timeline 时间线
 *  \endif
*/
- (void)didFirstVideoFramePresented:(NvsTimeline *)timeline;

/*! \if ENGLISH
 *  \brief Timeline out of bounds (Note: Do not use this callback interface if it is not necessary).
 *  \param timeline Timeline
 *  \else
 *  \brief 时间线越界（注：非必要情况请勿使用此回调接口）
 *  \param timeline 时间线
 *  \endif
 *  \since 1.2.0
*/
- (void)didTimestampOutOfRange:(NvsTimeline *)timeline;

/*! \if ENGLISH
 *  \brief Current position of seeking the timeline
 *  \param timeline Timeline
 *  \param position Current position
 *  \else
 *  \brief 时间线搜索的当前位置
 *  \param timeline 时间线
 *  \param position 当前位置
 *  \endif
 *  \since 2.5.0
*/
- (void)didSeekingTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position;

/*! \if ENGLISH
 *  \brief Gets the captured video frame.
 *
 *  Please pay attention: this function is called in a separate thread, not in the UI thread. Please consider thread-safe issues!!
 *  \param sampleBufferInfo The obtained image data
 *  \else
 *  \brief 获取采集预览图像
 *
 *  请特别注意:这个函数被调用是在一个单独的线程,而不是在UI线程.使用请考虑线程安全的问题!!!
 *  \param sampleBufferInfo 获取到的图像数据
 *  \endif
 *  \since 1.4.0
*/
- (void)captureVideoFrameGrabbedArrived:(NvsVideoFrameInfo*)sampleBufferInfo;

/*! \if ENGLISH
 *  \brief Get audio sample data from capture device.This interface triggers callbacks when recording.
 *
 *  \param audioSample  Captured audio sample data.
 *  \else
 *  \brief 获取采集的音频数据回调接口，此接口在录制的时候会触发回调
 *
 *  \param audioSample 音频数据
 *  \endif
 *  \since 3.0.3
 */
- (void)onAudioSampleArrived:(NvsAudioSampleBuffers*)audioSample;

/*! \if ENGLISH
 *  \brief Get audio sample data from capture device.This interface can fetch the audio callback while capturing the preview
 *
 *  \param audioSample  Captured audio sample data.
 *  \else
 *  \brief 获取采集的音频数据回调接口,此接口在采集预览时便可以获取音频回调
 *
 *  \param audioSample 音频数据
 *  \endif
 *  \since 3.11.0
 */
- (void)capturePreviewAudioSampleArrived:(NvsAudioSampleBuffers*)audioSample;

/*! \if ENGLISH
 *  \brief Gets the captured video frame.
 *
 *  Please pay attention: this function is called in a separate thread, not in the UI thread. Please consider thread-safe issues!!
 *  \param sampleBufferInfo The obtained image data
 *  \else
 *  \brief 获取采集预览图像
 *
 *  请特别注意:这个函数被调用是在一个单独的线程,而不是在UI线程.使用请考虑线程安全的问题!!!
 *  \param sampleBufferInfo 获取到的图像数据
 *  \endif
 *  \since 1.4.0
*/
- (void)capturePictureArrived:(NvsVideoFrameInfo*)sampleBufferInfo;

/*! \if ENGLISH
 *  \brief Exception in timeline playback.
 *  \param timeline Timeline.
 *  \param exceptionType Exception type，please refert to [STREAMING_ENGINE_PLAYBACK_EXCEPTION_TYPE](@ref STREAMING_ENGINE_PLAYBACK_EXCEPTION_TYPE)
 *  \param exceptionString Exception information
 *  \else
 *  \brief 时间线播放异常信息
 *  \param timeline 时间线
 *  \param exceptionType 异常类型。请参见[引擎播放异常类型](@ref STREAMING_ENGINE_PLAYBACK_EXCEPTION_TYPE)
 *  \param exceptionString 异常信息描述
 *  \endif
 *  \since 3.0.0
 */
- (void)onPlaybackException:(NvsTimeline *)timeline exceptionType:(NvsStreamingEnginePlaybackExceptionType)exceptionType exceptionString:(NSString *)exceptionString;

/*! \if ENGLISH
 *  \brief Hardware error information. Deprecated, use onMediaError instead.
 *  \param errorType Type of hardware error, please refert to [NvsStreamingEngineHarwareErrorType](@ref NvsStreamingEngineHarwareErrorType)
 *  \param stringInfo Assistance information.
 *  \else
 *  \brief 硬件错误信息. 已废弃，使用onMediaError替代
 *  \param errorType 硬件错误类型,请参见[硬件错误类型](@ref NvsStreamingEngineHarwareErrorType)
 *  \param stringInfo 辅助的字符串信息
 *  \endif
 *  \deprecated
 *  \since 1.16.0
 */
- (void)onHardwareError:(NvsStreamingEngineHarwareErrorType)errorType stringInfo:(NSString*)stringInfo;
/*! \if ENGLISH
 *  \brief Media error information.
 *  \param error error info
 *  \param stringInfo Assistance information.
 *  \else
 *  \brief 媒体异常信息
 *  \param error 媒体错误详细信息
 *  \endif
 *  \since 3.14.0
 */
- (void)onMediaError:(NvsMediaError*)error;
/*! \if ENGLISH
*  \brief Get DB value from timeline.
*
*  \param timeline Timeline.
*  \param leftVUValue Audio output left channel DB value.
*  \param rightVUValue Audio output right channel DB value.
*  \else
*  \brief 获取时间线音频输出的DB值回调接口
*
*  \param timeline 时间线
*  \param leftVUValue 左声道DB值
*  \param rightVUValue 右声道DB值
*  \endif
*/
- (void)didVUMeterValue:(NvsTimeline *)timeline leftValue:(float)left rightValue:(float)right timestamp:(int64_t)time;

/*! \if ENGLISH
 *  \brief Get audio sample data from timeline.
 *
 *  \param timeline Timeline.
 *  \param audioSample Audio output sample data.
 *  \else
 *  \brief 获取时间线音频输出的数据回调接口
 *
 *  \param timeline 时间线
 *  \param audioSample 音频数据
 *  \endif
 */
- (void)onAudioSampleArrived:(NvsTimeline *)timeline audioSample:(NvsAudioSampleBuffers*)audioSample;

@end

@protocol NvsImageGrabberDelegate <NSObject>
@optional

/*! \if ENGLISH
*  \brief Grab image from timeline.
*
*  Pay speical attention: this function is called in a seperate thread and not in the UI thread. Please consider the safety issues of threads!!
*  \param image The image obtained.
*  \param time The obtained timestamp.
*  \else
*  \brief 获取时间线某一时间戳图像
*
*  请特别注意:这个函数被调用是在一个单独的线程,而不是在UI线程.使用请考虑线程安全的问题!!
*  \param image 获取到的图像
*  \param time 获取到的图像时间戳
*  \endif
*/
- (void)onImageGrabbedArrived:(UIImage*)image timestamp:(int64_t)time;

/*! \if ENGLISH
*  \brief Grab image from timeline.
*
*  Pay speical attention: this function is called in a seperate thread and not in the UI thread. Please consider the safety issues of threads!!
*  \param timeline The timeline in which the acquired image is located.
*  \param image The image obtained.
*  \param time The obtained timestamp.
*  \else
*  \brief 获取时间线某一时间戳图像
*
*  请特别注意:这个函数被调用是在一个单独的线程,而不是在UI线程.使用请考虑线程安全的问题!!
*  \param timeline 获取到的图像所在的时间线
*  \param image 获取到的图像
*  \param time 获取到的图像时间戳
*  \since 3.8.0
*  \endif
*/
- (void)onImageGrabbedArrived:(NvsTimeline *)timeline image:(UIImage*)image timestamp:(int64_t)time;

@end

@protocol NvsStreamingContextDebugLogDelegate <NSObject>
@optional

/*! \if ENGLISH
*  \brief log information.
*  \param level log level
*  \param log log string.
*  \else
*  \brief 日志信息
*  \param level 日志级别, 请参见[日志级别](@ref NvsDebugLevel)
*  \param log 日志
*  \endif
*  \since 3.13.0
*/
- (void)onDebugLogArrived:(int)level logStr:(NSString*)logStr;
@end

@protocol NvsStreamingContextWebDelegate <NSObject>
@optional
/*! @if ENGLISH
 *  @brief Callback notifying Web request waiting status changed
 *  @param
 *  @param isVideo : boolean flag in bool, "true" = is video, "false" is not video
 *  @param waiting : boolean flag in bool, "true" = waiting, "false" = not waiting
 *  @return void
 *  @else
 *  @brief 通知Web请求等待状态更改。
 *  @param isVideo 是否是视频。
 *  @param waiting 是否在等待。
 *  @return 无返回值。
 *  @endif
*/
- (void)onWebRequestWaitStatusChange:(BOOL)isVideo waiting:(BOOL)waiting;

@end

/*! \if ENGLISH
 *  \brief information of template footage
 *  \param footageId footage ID
 *  \param filePath file path of footage
 *  \param reverseFilePath reverse file path of footage
 *  \else
 *  \brief 模板footage信息
 *  \param footageId footage ID
 *  \param filePath footage对应的文件路径
 *  \param reverseFilePath footage对应的倒放文件路径
 *  \endif
 */
NVS_EXPORT @interface NvsTemplateFootageInfo : NSObject

@property(nonatomic, strong) NSString *footageId;
@property(nonatomic, strong) NSString *filePath;
@property(nonatomic, strong) NSString *reverseFilePath;

@end

/*! \if ENGLISH
 *  \brief Streaming context.
 *
 *  The streaming context class is considered as the entry of the entire SDK framework. During development, the NvsStreamingContext class uses the static sharedInstance() interface to create an unique streaming context instance.
 *  Through this instantce object, we can turn on the recording device to record videos, adding effects to recorded videos, set various parameters for recording, which include autofocus, automatic exposure adjustment, swtiching on/off of the light supplement and so on.
 *  Meanwhile, this instance can also create timelines, connecting timelines to the real-time preview window which view the recorded videos in real-time. When the whole video has been produced completely, please destroy the instances of streaming context.
 *  When recording with special effects,users have to first install the package and obtain packageID after installation,before adding resources packages (recording effects package, scene resources package and so on),. For built-in special effects, users only need to obtain the name of the effect when using it.
 *  <br>In SDK interfaces, users need to use the full pathway when importing resources or authorizations.
 *  \warning For NvsStreamingContext class, all public APIs must be used in the UI thread except getAVFileInfo(), detectVideoFileKeyframeInterval(),createVideoFrameRetriever(), which can be used across threads.
 *  \else
 *  \brief 流媒体上下文
 *
 *  流媒体上下文类可视作整个SDK框架的入口。开发过程中，NvsStreamingContext类提供了静态sharedInstance()接口创建流上下文的唯一实例。
 *  通过这个实例对象，我们可以开启采集设备录制视频，添加采集视频特效，设置拍摄时的各项参数，包括自动聚焦，自动曝光调节，开关换补光灯等。
 *  同时，还能够创建时间线，并将时间线与实时预览窗口(Live Window)连接起来，实时预览播放已经拍摄完成的视频。整个视频制作完成后，要销毁流媒体上下文的对象实例。
 *  带特效拍摄时，添加素材资源包(采集特效包，场景资源包等)，都得先安装，安装成功后获取packageId才能使用，而内建采集特效(builtin)只需获取特效名称即可使用。
 *  <br>sdk接口中凡是需要传入资源、授权等文件路径时一定是全路径。
 *  \warning NvsStreamingContext类中，所有public API除了getAVFileInfo，detectVideoFileKeyframeInterval，createVideoFrameRetriever可以跨线程使用，其他都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsStreamingContext : NSObject

@property (nonatomic, weak) id<NvsStreamingContextDelegate> delegate;
@property (nonatomic, weak) id<NvsStreamingContextWebDelegate> webDelegate;
@property (readonly) NvsAssetPackageManager *assetPackageManager;       //!< \if ENGLISH Package manager \else 包管理器 \endif
@property (nonatomic) float compileVideoBitrateMultiplier;              //!< \if ENGLISH Bitrate multiplier of compiling video. \else 生成视频码率倍乘系数 \endif \since 1.5.0
@property (nonatomic) float recordVideoBitrateMultiplier;               //!< \if ENGLISH Bitrate multiplier of recording video. \else 录制视频码率倍乘系数 \endif \since 1.5.0
@property (nonatomic) BOOL defaultCaptionFade;                          //!< \if ENGLISH Whether the default caption effect is fade in and out. \else 默认字幕是否为淡入淡出 \endif \since 1.8.0
@property (nonatomic, weak) id<NvsImageGrabberDelegate> imageGrabberDelegate;

/*! \if ENGLISH
 *  \brief Sets the timeline configurations, which stay valid once set. For key values in NSMutableDictionary, please refer to [Configuration of Compilation Timeline](@ref COMPILE_CONFIGURATIONS)
 *         For instance: NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
 *              [config setValue:[NSNumber numberWithInteger:15] forKey:NVS_COMPILE_GOP_SIZE]; //If set to 1 then a I-frame-only video is compiled.
 *              [config setValue:[NSNumber numberWithInteger:10000000] forKey:NVS_COMPILE_BITRATE]; // 10M bps
 *              [config setValue:[NSNumber numberWithInteger:256000] forKey:NVS_COMPILE_AUDIO_BITRATE]; // Sets the audio bitrate to 256Kbps
 *              [config setValue:[NSNumber numberWithBool:YES] forKey:NVS_COMPILE_LOSSLESS_AUDIO]; //Sets to generate lossless audio
 *              [config setValue:[NSNumber numberWithBool:YES] forKey:NVS_COMPILE_OPTIMIZE_FOR_NETWORK_USE]; //Sets index table to prepose
 *              _streamingContext.compileConfigurations = config;
 *         Cancels configurations and returns to default settings:[_streamingContext.compileConfigurations setValue:nil forKey:NVS_COMPILE_GOP_SIZE];
 *  \else
 *  \brief 生成时间线配置，设置一次即一直生效。NSMutableDictionary中关键字的值请参见 [生成时间线的配置] (@ref COMPILE_CONFIGURATIONS)
 *         例如：NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
 *              [config setValue:[NSNumber numberWithInteger:15] forKey:NVS_COMPILE_GOP_SIZE]; // 设置为1即是生成全I帧视频
 *              [config setValue:[NSNumber numberWithInteger:10000000] forKey:NVS_COMPILE_BITRATE]; // 10M bps
 *              [config setValue:[NSNumber numberWithInteger:256000] forKey:NVS_COMPILE_AUDIO_BITRATE]; // 设置音频码率为256Kbps
 *              [config setValue:[NSNumber numberWithBool:YES] forKey:NVS_COMPILE_LOSSLESS_AUDIO]; // 设置生成无损音频
 *              [config setValue:[NSNumber numberWithBool:YES] forKey:NVS_COMPILE_OPTIMIZE_FOR_NETWORK_USE]; // 设置索引表前置
 *              NvsRational videoFps = {12, 1};
 *              [config setValue:[NSData dataWithBytes:&videoFps length:sizeof(NvsRational)] forKey:NVS_COMPILE_VIDEO_FPS]; // 设置帧速率FPS
 *              _streamingContext.compileConfigurations = config;
 *         取消设置并恢复默认方式例如：[_streamingContext.compileConfigurations setValue:nil forKey:NVS_COMPILE_GOP_SIZE];
 *  \endif
 *  \since 1.8.0
*/
@property (nonatomic) NSMutableDictionary *compileConfigurations;

/*! \if ENGLISH
 *  \brief Gets the version information of Meishe SDK
 *  \param majorVersion Major version number
 *  \param minorVersion Minor version number
 *  \param revisionNumber Revision number
 *  \else
 *  \brief 获取美摄SDK的版本信息
 *  \param majorVersion 主版本号
 *  \param minorVersion 次版本号
 *  \param revisionNumber 修订版本号
 *  \endif
 *  \since 1.4.1
*/
+ (void)getSdkVersion:(int *)majorVersion minorVersion:(int *)minorVersion revisionNumber:(int *)revisionNumber;

/*! \if ENGLISH
 *  \brief Sets Debug level.
 *  \param debugLevel debug‘s level.
 *  \else
 *  \brief 设置Debug的级别
 *  \param debugLevel 的级别
 *  \endif
 *  \since 3.6.0
*/
+ (void)setDebugLevel:(NvsDebugLevel)debugLevel;

/*! \if ENGLISH
 *  \brief Sets whether to write debugging information of the SDK to the file.
 *  \param saveDebugMessagesToFile Whether to write debugging information of the SDK to the file.In the /Library/Application Support/log/ path, a file will be generated every day, for example:meishesdklog(2023-01-17).log. If you need to delete the file, you need to delete this directory by yourself, and the Meishesdk will not delete it actively.
 *  \else
 *  \brief 设置是否将SDK的调试信息写入到文件中,在/Library/Application Support/log/路径下每天会生成一个文件,例如:meishesdklog(2023-01-17).log,如果需要删除文件用户需要自己删除这个目录,美摄sdk不会主动删除.
 *  \param saveDebugMessagesToFile 是否将SDK的调试信息写入到文件中
 *  \endif
 *  \since 1.17.0
*/
+ (void)setSaveDebugMessagesToFile:(BOOL)saveDebugMessagesToFile;

/*! \if ENGLISH
 *  \brief Sets whether to write debugging information of the SDK to std out.
 *  \param debugMessagesToStdOut Whether to write debugging information of the SDK to std out.
 *  \else
 *  \brief 设置是否将SDK的调试信息写入到标准输出
 *  \param debugMessagesToStdOut 是否将SDK的调试信息写入标准输出
 *  \endif
 *  \since 3.12.1
*/
+ (void)setDebugMessagesToStdOut:(BOOL)debugMessagesToStdOut;

+ (void)setDebugLogDelegate:(id<NvsStreamingContextDebugLogDelegate>)debugLogDelegate;
/*! \if ENGLISH
 *  \brief Verifies the SDK license file. Note: The license file interface must be called before the NvsStreamingContext is initialized.
 *  \param sdkLicenseFilePath Path of SDK license file
 *  \return Returns the BOOL value. YES indicates that the authorization verification is successful, and NO indicates that it fails. If the verification fails, a subsequent watermark will appear in the video preview and the compiled video.
 *  \else
 *  \brief 验证SDK授权文件。注意：授权文件接口必须在NvsStreamingContext初始化之前调用。
 *  \param sdkLicenseFilePath SDK授权文件路径
 *  \return 返回BOOL值。YES表示授权验证成功，NO则验证失败。若验证失败，则后续的视频预览和生成视频会出现水印。
 *  \endif
*/
+ (BOOL)verifySdkLicenseFile:(NSString *)sdkLicenseFilePath;

/*! \if ENGLISH
 *  \brief Gets a unique instance of the streaming context.
 *  \return Returns an object instance of the streaming context.
 *  \else
 *  \brief 获取流媒体上下文的唯一实例
 *  \return 返回流媒体上下文的对象实例
 *  \endif
 *  \sa destroyInstance
*/
+ (NvsStreamingContext *)sharedInstance;

/*! \if ENGLISH
 *  \brief Gets a unique instance of the streaming context. For details, please refer to [4k Video Editing](@ref support4kVideoEdit.md).
 *  \param flags Flag field. If there is no special requirement, please fill in 0.
 *  \return Returns the NvsStreamingContext object.
 *  \else
 *  \brief 获取流媒体上下文的唯一实例。详细了解参见[4k视频编辑专题] (@ref support4kVideoEdit.md)
 *  \param flags 标志字段，如无特殊需求请填写0。
 *  \return 返回流媒体上下文的对象实例
 *  \endif
 *  \since 1.5.0
 *  \sa destroyInstance
 *
*/
+ (NvsStreamingContext *)sharedInstanceWithFlags:(NvsStreamingContextFlag)flags;

/*! \if ENGLISH
 *  \brief Destroys the streaming context instance.
 *  \else
 *  \brief 销毁流媒体上下文实例。
 *  \endif
 *  \sa sharedInstance
*/
+ (void)destroyInstance;

/*! \if ENGLISH
 *  \brief Checks if the current SDK contains an AR module.
 *  \return The return value of 0 means no AR module, and greater than 0 means that the AR module is included.
 *  \else
 *  \brief 检测当前SDK是否含有AR模块
 *  \return 返回值0表示不含有AR模块，大于0表示含有AR模块
 *  \endif
 *  \since 2.5.0
*/
+ (int)hasARModule;

/*! \if ENGLISH
 *  \brief Initializes the human body detection mechanism.Only once needed
 *  \param modelFilePath Path of the model file
 *  \param licenseFilePath Path of the license file
 *  \param features human detection flag field. Please refer to [Flag of human detection](@ref NvsHumanDetectionFeatureFlag).
 *  \else
 *  \brief 初始化人体检测机制, 只初始化一次
 *  \param modelFilePath 模型文件路径
 *  \param licenseFilePath 授权文件路径
 *  \param features 人体检测特征标志字段。请参见[人体检测特征标志](@ref NvsHumanDetectionFeatureFlag)
 *  \endif
 *  \since 2.5.0
 *  \sa closeHumanDetection
*/
+ (BOOL)initHumanDetection:(NSString *)modelFilePath
           licenseFilePath:(NSString *)licenseFilePath
                  features:(int)features;

/*! \if ENGLISH
 *  \brief Initializes the human body detection mechanism.Only once needed
 *  \param modelFilePath Path of the model file
 *  \param licenseFilePath Path of the license file
 *  \param features human detection flag field. Please refer to [Flag of human detection](@ref NvsHumanDetectionFeatureFlag).
 *  \param options detect options, please refer to [Human detection features](@ref HUMAN_DETECTION_OPTIONS).
 *  \else
 *  \brief 初始化人体检测机制, 只初始化一次
 *  \param modelFilePath 模型文件路径
 *  \param licenseFilePath 授权文件路径
 *  \param features 人体检测特征标志字段。请参见[人体检测特征标志](@ref NvsHumanDetectionFeatureFlag)
 *  \param options 检测选项，请参加[检测选项](@ref HUMAN_DETECTION_OPTIONS)
 *  \endif
 *  \since 3.14.0
 *  \sa closeHumanDetection
*/
+ (BOOL)initHumanDetection:(NSString *)modelFilePath
           licenseFilePath:(NSString *)licenseFilePath
                  features:(int)features
                   options:(NSMutableDictionary *)options;

/*! \if ENGLISH
 *  \brief Human detection initialization extension. must called after initHumanDetection
 *  \param modelFilePath Path of the model file
 *  \param licenseFilePath Path of the license file
 *  \param features human detection flag field. Please refer to [Flag of human detection](@ref NvsHumanDetectionFeatureFlag).
 *  \else
 *  \brief 初始化人体检测扩展机制，必须先调用initHumanDetection
 *  \param modelFilePath 模型文件路径
 *  \param licenseFilePath 授权文件路径
 *  \param features 人体检测特征标志字段。请参见[人体检测特征标志](@ref NvsHumanDetectionFeatureFlag)
 *  \endif
 *  \since 2.5.0
*/
+ (BOOL)initHumanDetectionExt:(NSString *)modelFilePath
              licenseFilePath:(NSString *)licenseFilePath
                     features:(int)features;

/*! \if ENGLISH
 *  \brief Human detection initialization extension. must called after initHumanDetection
 *  \param modelFilePath Path of the model file
 *  \param licenseFilePath Path of the license file
 *  \param features human detection flag field. Please refer to [Flag of human detection](@ref NvsHumanDetectionFeatureFlag).
 *  \param options detect options, please refer to [Human detection features](@ref HUMAN_DETECTION_OPTIONS).
 *  \else
 *  \brief 初始化人体检测扩展机制，必须先调用initHumanDetection
 *  \param modelFilePath 模型文件路径
 *  \param licenseFilePath 授权文件路径
 *  \param features 人体检测特征标志字段。请参见[人体检测特征标志](@ref NvsHumanDetectionFeatureFlag)
 *  \param options 检测选项，请参加[检测选项](@ref HUMAN_DETECTION_OPTIONS)
 *  \endif
 *  \since 3.14.0
*/
+ (BOOL)initHumanDetectionExt:(NSString *)modelFilePath
              licenseFilePath:(NSString *)licenseFilePath
                     features:(int)features
                      options:(NSMutableDictionary *)options;

/*! \if ENGLISH
 *  \brief Initializes human detection data packets
 *  \param dataType Type of human detection packet. Please refer to [Type of human detection packete](@ref NvsHumanDetectionDataTypeFlag)
 *  \param dataFilePath Path of the data file
 *  \return The return value indicates whether it is successful.
 *  \else
 *  \brief 初始化人体检测数据包
 *  \param dataType 人体检测数据包类型。请参见[人体检测数据包类型](@ref NvsHumanDetectionDataTypeFlag)
 *  \param dataFilePath 数据文件路径
 *  \return 返回值表示是否成功
 *  \endif
 *  \since 2.6.0
*/
+ (BOOL)setupHumanDetectionData:(int)dataType
           dataFilePath:(NSString *)dataFilePath;

/*! \if ENGLISH
 *  \brief Close the human detection mechanism.
 *  \else
 *  \brief 关闭人体检测机制
 *  \endif
 *  \since 2.5.0
 *  \sa initHumanDetection
*/
+ (void)closeHumanDetection;

/*! \if ENGLISH
 *  \brief Preload effect resources.
 *  \else
 *  \brief 预加载特技资源
 *  \endif
 *  \since 2.18.1
 */
- (BOOL)preloadEffectResources;

/*! \if ENGLISH
 *  \brief Gets the directory path of log file.
 *  \else
 *  \brief 获取日志文件所在路径
 *  \endif
 *  \since 2.14.0
*/
+ (NSString *)getLogFileDirectory;

/*! \if ENGLISH
 *  \brief Gets the EAGLSharegroup object used by the engine from the streaming context.
 *  \else
 *  \brief 从流媒体上下文中获取引擎所用的EAGLSharegroup对象
 *  \endif
 *  \since 1.5.0
*/
- (EAGLSharegroup *)getEAGLSharegroup;

/*! \if ENGLISH
 *  \brief Get the current rendering speed of the engine from the streaming context that it's only valid after startCapturePreview and playbackTimeline.
 *  \else
 *  \brief 从流媒体上下文中获取引擎当前的渲染速度，只在startCapturePreview和playbackTimeline之后有效。
 *  \endif
 *  \since 2.8.0
*/
- (float)detectEngineRenderFramePerSecond;

/*! \if ENGLISH
 *  \brief Gets audio and video informations of a file.
 *  \param avFilePath File path
 *  \return Returns the NvsAVFileInfo Object
 *  \else
 *  \brief 获取文件的音视频信息，如果文件格式不支持，则返回null
 *  \param avFilePath 文件路径
 *  \return 返回音视频文件信息的对象
 *  \warning 如果是网络素材，最好不要在UI线程调用，否则网络不好的时候可能会ANR！
 *  \endif
*/
- (NvsAVFileInfo *)getAVFileInfo:(NSString *)avFilePath;

/*! \if ENGLISH
 *  \brief Gets audio and video information of a file.
 *  \param avFilePath File path
 *  \param extraFlag Special flag for Audio and video information. Please refer to [Special identifier when acquiring audio and video information.](@ref NvsAVFileinfoExtraFlag).
 *  \return 返回音视频文件信息的对象
 *  \else
 *  \brief 获取文件的音视频信息，如果文件格式不支持，则返回null
 *  \param avFilePath 文件路径
 *  \param extraFlag 音视频信息特殊标识。请参见[音视频信息flag](@ref NvsAVFileinfoExtraFlag)
 *  \return 返回音视频文件信息的对象
 *  \warning 如果是网络素材，最好不要在UI线程调用，否则网络不好的时候可能会ANR！
 *  \endif
*/
- (NvsAVFileInfo *)getAVFileInfoExtra:(NSString *)avFilePath extraFlag:(int) extraFlag;


/*! \if ENGLISH
 *  \brief Gets detailed information of the audio/video file
 *  \param avFilePath File path of the audio/video file
 *  \param extraFlag Get extra information of the audio/video file. please refer to [AV_FILEINFO_EXTRA](@ref AV_FILEINFO_EXTRA)
 *  \param errString Output param for error description is valid if current function return null.
 *  \return Returns the audio/video file information object，return null if file format is not supported
 *  \else
 *  \brief 获取音视频文件的详细信息
 *  \param avFilePath 音视频文件的路径
 *  \param extraFlag 获取音视频文件的详细信息的特殊标识。请参见[获取音视频信息时的特殊标识](@ref AV_FILEINFO_EXTRA)
 *  \param errString 如果当前函数返回为null， 当前参数有意义， 返回具体的错误信息。
 *  \return 返回获取的音视频信息对象，如果音视频文件格式不支持则返回null
 *  \endif
 *  \warning 如果是网络素材，最好不要在UI线程调用，否则网络不好的时候可能会ANR！
 *  \since 2.20.0
 */
- (NvsAVFileInfo *)getAVFileInfo:(NSString *)avFilePath extraFlag:(int) extraFlag withError:(NSMutableString*)errString;


/*! \if ENGLISH
 *  \brief Detects the I frame interval of video files.
 *  \param videoFilePath Video file path
 *  \return Returns the detected I frame interval, and returning 0 means the detection failed.
 *  \else
 *  \brief 探测视频文件的I帧间距
 *  \param videoFilePath 视频文件的路径
 *  \return 返回探测到的I帧间距，返回0表示探测失败
 *  \endif
 *  \since 1.6.0
*/
- (int)detectVideoFileKeyframeInterval:(NSString *)videoFilePath;

/*! \if ENGLISH
 *  \brief Sets the default theme logo image path.
 *  \param logoImageFilePath Path of logo image file
 *  \return Returns the BOOL value. YES means the setting is successful, NO means it fails.
 *  \else
 *  \brief 设置默认主题logo图片路径
 *  \param logoImageFilePath logo图片文件路径
 *  \return 返回BOOL值。YES 设置成功；NO 设置失败
 *  \endif
 *  \sa getDefaultThemeEndingLogoImageFilePath
*/
- (BOOL)setDefaultThemeEndingLogoImageFilePath:(NSString *)logoImageFilePath;

/*! \if ENGLISH
 *  \brief Gets the default theme logo image path.
 *  \return Returns the image path
 *  \else
 *  \brief 获取默认主题logo图片路径
 *  \return 返回表示图片路径
 *  \endif
 *  \sa setDefaultThemeEndingLogoImageFilePath:
*/
- (NSString *)getDefaultThemeEndingLogoImageFilePath;

/*! \if ENGLISH
 *  \brief Sets whether the logo effect at the end of the theme is displayed or not.
 *  \return Returns BOOL value. YES means setting is successful, NO means it fails.
 *  \else
 *  \brief 设置主题结尾logo特效是否显示
 *  \return 返回BOOL值。YES 设置成功；NO 设置失败
 *  \endif
 *  \sa setDefaultThemeEndingLogoImageFilePath:
*/
- (BOOL)setThemeEndingEnabled:(BOOL)enable;

/*! \if ENGLISH
 *  \brief Get HDR capability
 *  \return Returns a int value, Please refer to [HDR capability flags](@ref NvsHDRCapabilityFlag).
 *  \else
 *  \brief 获取引擎的HDR能力
 *  \return 返回int值。请参见[HDR能力标志] (@ref NvsHDRCapabilityFlag)
 *  \endif
 */
- (int)getEngineHDRCaps;

/*! \if ENGLISH
 *  \brief Enable DB value of audio output
 *  \param enable Enable
 *  \else
 *  \brief 设置是否输出音频输出的DB值
 *  \param enable 是否输出
  *  \endif
 *  \since 2.20.0
*/
- (void)setAudioVUMeterEnabled:(BOOL)enable;

/*! \if ENGLISH
 *  \brief Enable DB value of audio output
 *  \param enable Enable
 *  \else
 *  \brief 设置是否输出音频sample
 *  \param enable 是否输出
  *  \endif
 *  \since 3.2.0
*/
- (void)setEnableAudioSampleNotify:(BOOL)enable;

/*! \if ENGLISH
 *  \brief  Gets the fontFamily of the font file.
 *  \param fontFilePath Font file path
 *  \return Returns the fontFamily of the font.
 *  \else
 *  \brief 获取字体文件的fontFamily
 *  \param fontFilePath 字体文件路径
 *  \return 返回字体的fontFamily
 *  \endif
*/
- (NSString*)registerFontByFilePath:(NSString *)fontFilePath;

/*! \if ENGLISH
 *  \brief Gets font file's font information
 *  \param fontFilePath Font file path
 *  \return Returns file's all font information
 *  \else
 *  \brief 获取字体文件中字体信息
 *  \param fontFilePath 字体文件路径
 *  \return 返回文件中所有字体的信息
 *  \endif
 */
- (NSArray*)getFontInfoByFilePath:(NSString *)fontFilePath;

/*! \if ENGLISH
 *  \brief Sets the color gain during SDR to HDR conversion.
 *  \param gain color gain. range is [1.0, 10.0]
 *  \else
 *  \brief 设置在SDR向HDR转换时候色彩增益
 *  \param gain 为色彩增益 范围是【1.0，10.0】
 *  \endif
 *  \since 2.23.0
 *  \sa getColorGainForSDRToHDR
*/
- (void)setColorGainForSDRToHDR:(float)gain;

/*! \if ENGLISH
 *  \brief gets the color gain during SDR to HDR conversion.
 *  \return Returns color gain. range is [1.0, 10.0]
 *  \else
 *  \brief 获取在SDR向HDR转换时候色彩增益
 *  \return 返回色彩增益值 范围是【1.0，10.0】
 *  \endif
 *  \since 2.23.0
 *  \sa setColorGainForSDRToHDR
*/
- (float)getColorGainForSDRToHDR;

/*!
 *	\if ENGLISH
 *  \brief Export template information
 *  \param templateUuid  Template resource package ID
 *  \param timeline  Timeline Object
 *  \param requestedAspectRatio  Aspect ratio of template according to timeline。please refer to [Aspect ratio supported by the resource package](@ref ASSET_PACKAGE_ASPECT_RATIO)
 *  \return Returns suc or not
 *	\else
 *  \brief 输出模版包的信息
 *  \param templateUuid 模版资源包ID
 *  \param timeline 时间线对象
 *  \param requestedAspectRatio 所需的模版画幅比例，一般和timeline的画幅比例一致.请参见[模板资源包画幅比例] (@ref ASSET_PACKAGE_ASPECT_RATIO)
 *  \return 返回是否成功
 *	\endif
 */
- (BOOL)exportTemplateInfo:(NSString *)templateUuid timeline:(NvsTimeline *)timeline requestedAspectRatio:(int)requestedAspectRatio;

/*!
 *	\if ENGLISH
 *  \brief Generate template asset package
 *  \param templateUuid  Template resource package ID
 *  \param innerAssetDir  Path of internal assets of template
 *  \param templateOutputDir  Output path of template asset package
 *  \return Returns suc or not
 *	\else
 *  \brief 生成模版包
 *  \param templateUuid 模版资源包ID
 *  \param innerAssetDir 模版内部资源文件夹路径
 *  \param templateOutputDir 模版资源包的输出路径
 *  \return 返回是否成功
 *	\endif
 */
- (BOOL)generateTemplatePackage:(NSString *)templateUuid innerAssetDir:(NSString *)innerAssetDir templateOutputDir:(NSString *)templateOutputDir;

/*!
 *	\if ENGLISH
 *  \brief set templates custom resource folders
 *  \param templateUuid  template resource package ID
 *  \param innerAssetDir  Path of assets of project/template
 *	\else
 *  \brief 设置模版自定义资源所在文件夹
 *  \param templateUuid 模版资源包ID
 *  \param customResourceDir 模版资源文件夹路径
 *	\endif
 */
- (void)setTemplate:(NSString *)templateUuid customResourceDir:(NSString *)customResourceDir;

/*!
 *	\if ENGLISH
 *  \brief Export project information
 *  \param projectUuid  Project resource package ID
 *  \param timeline  Timeline Object
 *  \param requestedAspectRatio  Aspect ratio of project according to timeline。please refer to [Aspect ratio supported by the resource package](@ref ASSET_PACKAGE_ASPECT_RATIO)
 *  \return Returns suc or not
 *	\else
 *  \brief 输出项目包的信息
 *  \param projectUuid 项目资源包ID
 *  \param timeline 时间线对象
 *  \param requestedAspectRatio 所需的项目画幅比例，一般和timeline的画幅比例一致.请参见[资源包画幅比例] (@ref ASSET_PACKAGE_ASPECT_RATIO)
 *  \return 返回是否成功
 *	\endif
 */
- (BOOL)exportProjectInfo:(NSString *)projectUuid timeline:(NvsTimeline *)timeline requestedAspectRatio:(int)requestedAspectRatio;

/*!
 *	\if ENGLISH
 *  \brief Generate project asset package
 *  \param projectUuid  project resource package ID
 *  \param innerAssetDir  Path of internal assets of project
 *  \param projectOutputDir  Output path of project asset package
 *  \return Returns suc or not
 *	\else
 *  \brief 生成项目包
 *  \param projectUuid 项目资源包ID
 *  \param innerAssetDir 项目内部资源文件夹路径
 *  \param projectOutputDir 项目资源包的输出路径
 *  \return 返回是否成功
 *	\endif
 */
- (BOOL)generateProjectPackage:(NSString *)projectUuid innerAssetDir:(NSString *)innerAssetDir projectOutputDir:(NSString *)projectOutputDir;

/*! \if ENGLISH
 *  \brief Creates timeline.
 *  \param videoEditRes Video file's resolution (specify the width,height and ratio). For video editting resolution, when importing corresponding params, the imported image's width has to be a multiple of 4, the height has to be a multiple of 2.
 *   Note: if one creates NvsStreamingContext's instance that supports 4K video editting, then video editting's resolution cannot be higher then 3840*2160(imageWidth*imageHeight), otherwise the imageWidth*imageHeight cannot exceed 1920* 1080 pixels.
 *  \param videoFps Video frame rate, max fps is 60
 *  \param audioEditRes Audio editing resolution (specify the sampling rate, sampling format, and count of channels). For audio editing resolution, the incoming sample rate values support two types: 44100 and 48000.and support mono&stereo
 *  \return Returns the created NvsTimeline object. return null if params are invalid
 *  \else
 *  \brief 创建时间线
 *  \param videoEditRes 视频编辑解析度(指定视频宽高及像素比)。对于视频编辑解析度，在传入对应参数值时，目前要求传入的图像宽度值是4的倍数，高度值是2的倍数。注：如果创建NvsStreamingContext单例对象，支持4k视频编辑，则视频编辑解析度里的imageWidth * imageHeight不能高于3840*2160像素，否则视频编辑解析度里的imageWidth * imageHeight不能高于1920 * 1080像素。
 *  \param videoFps 视频帧率，最高60fps
 *  \param audioEditRes 音频编辑解析度(指定采样率、采样格式及声道数)。对于音频编辑解析度，传入的采样率值支持两种：44100与48000，支持单声道和双声道
 *  \return 返回创建的时间线对象，如果参数不满足上述条件，则返回null
 *  \endif
 *  \sa removeTimeline:
*/
- (NvsTimeline *)createTimeline:(NvsVideoResolution *)videoEditRes videoFps:(NvsRational *)videoFps audioEditRes:(NvsAudioResolution *)audioEditRes;

/*! \if ENGLISH
 *  \brief Creates timeline.
 *  \param videoEditRes Video file's resolution (specify the width,height and ratio). For video editting resolution, when importing corresponding params, the imported image's width has to be a multiple of 4, the height has to be a multiple of 2.
 *   Note: if one creates NvsStreamingContext's instance that supports 4K video editting, then video editting's resolution cannot be higher then 3840*2160(imageWidth*imageHeight), otherwise the imageWidth*imageHeight cannot exceed 1920* 1080 pixels.
 *  \param videoFps Video frame rate, max fps is 60
 *  \param audioEditRes Audio editing resolution (specify the sampling rate, sampling format, and count of channels). For audio editing resolution, the incoming sample rate values support two types: 44100 and 48000.and support mono&stereo
 *  \param flags Special flags for create timeline. If there is no special requirements please input 0. Please refer to [NvsCreateTimelineTypeFlag](@ref NvsCreateTimelineTypeFlag).
 *  \return Returns the created NvsTimeline object. return null if params are invalid
 *  \else
 *  \brief 创建时间线
 *  \param videoEditRes 视频编辑解析度(指定视频宽高及像素比)。对于视频编辑解析度，在传入对应参数值时，目前要求传入的图像宽度值是4的倍数，高度值是2的倍数。注：如果创建NvsStreamingContext单例对象，支持4k视频编辑，则视频编辑解析度里的imageWidth * imageHeight不能高于3840*2160像素，否则视频编辑解析度里的imageWidth * imageHeight不能高于1920 * 1080像素。
 *  \param videoFps 视频帧率，最高60fps
 *  \param audioEditRes 音频编辑解析度(指定采样率、采样格式及声道数)。对于音频编辑解析度，传入的采样率值支持两种：44100与48000，支持单声道和双声道
 *  \param flags 创建时间线的特殊标志，如果没有特殊需求，请填写0。请参见[NvsCreateTimelineTypeFlag] (@ref NvsCreateTimelineTypeFlag)
 *  \return 返回创建的时间线对象，如果参数不满足上述条件，则返回null
 *  \endif
 *  \since 2.21.0
 *  \sa removeTimeline:
*/
- (NvsTimeline *)createTimeline:(NvsVideoResolution *)videoEditRes videoFps:(NvsRational *)videoFps audioEditRes:(NvsAudioResolution *)audioEditRes flags:(int)flags;

/*! \if ENGLISH
 *  \brief Creates timeline.
 *  \param videoEditRes Video file's resolution (specify the width,height and ratio). For video editting resolution, when importing corresponding params, the imported image's width has to be a multiple of 4, the height has to be a multiple of 2.
 *   Note: if one creates NvsStreamingContext's instance that supports 4K video editting, then video editting's resolution cannot be higher then 3840*2160(imageWidth*imageHeight), otherwise the imageWidth*imageHeight cannot exceed 1920* 1080 pixels.
 *  \param videoFps Video frame rate, max fps is 60
 *  \param audioEditRes Audio editing resolution (specify the sampling rate, sampling format, and count of channels). For audio editing resolution, the incoming sample rate values support two types: 44100 and 48000.and support mono&stereo
 *  \param flags Special flags for create timeline. If there is no special requirements please input 0. Please refer to [NvsCreateTimelineTypeFlag](@ref NvsCreateTimelineTypeFlag).
 *  \return Returns the created NvsTimeline object. return null if params are invalid
 *  \else
 *  \brief 创建时间线
 *  \param videoEditRes 视频编辑解析度(指定视频宽高及像素比)。对于视频编辑解析度，在传入对应参数值时，目前要求传入的图像宽度值是4的倍数，高度值是2的倍数。注：如果创建NvsStreamingContext单例对象，支持4k视频编辑，则视频编辑解析度里的imageWidth * imageHeight不能高于3840*2160像素，否则视频编辑解析度里的imageWidth * imageHeight不能高于1920 * 1080像素。
 *  \param videoFps 视频帧率，最高60fps
 *  \param audioEditRes 音频编辑解析度(指定采样率、采样格式及声道数)。对于音频编辑解析度，传入的采样率值支持两种：44100与48000，支持单声道和双声道
 *  \param bitDepth 时间线视频的位深度，目前支持8bit， 16bit float，和auto
 *  \param flags 创建时间线的特殊标志，如果没有特殊需求，请填写0。请参见[NvsCreateTimelineTypeFlag] (@ref NvsCreateTimelineTypeFlag)
 *  \return 返回创建的时间线对象，如果参数不满足上述条件，则返回null
 *  \endif
 *  \since 2.24.0
 *  \sa removeTimeline:
*/
- (NvsTimeline *)createTimeline:(NvsVideoResolution *)videoEditRes videoFps:(NvsRational *)videoFps audioEditRes:(NvsAudioResolution *)audioEditRes bitDepth:(NvsVideoResolutionBitDepth)depth flags:(int)flags;

/*! \if ENGLISH
 *  \brief Creates timeline
 *  \param templateId template uuid
 *  \param templateFootages footage information in the template asset
 *  \return Returns created timeline object
 *  \else
 *  \brief 用模板资源创建时间线
 *  \param templateId 模板资源uuid
 *  \param templateFootages 模板资源里footage的对应信息
 *  \return 返回创建的时间线对象
 *  \endif
 *  \sa removeTimeline
 */
- (NvsTimeline *)createTimeline:(NSString *)templateId templateFootages:(NSArray <NvsTemplateFootageInfo*>*)templateFootages;

/*! \if ENGLISH
 *  \brief Creates timeline
 *  \param templateId template uuid
 *  \param templateFootages footage information in the template asset
 *  \param flags Special flags for create timeline. If there is no special requirements please input 0. Please refer to [NvsCreateTimelineTypeFlag](@ref NvsCreateTimelineTypeFlag).
 *  \return Returns created timeline object
 *  \else
 *  \brief 用模板资源创建时间线
 *  \param templateId 模板资源uuid
 *  \param templateFootages 模板资源里footage的对应信息
 *  \param flags 创建时间线的特殊标志，如果没有特殊需求，请填写0。请参见[NvsCreateTimelineTypeFlag] (@ref NvsCreateTimelineTypeFlag)
 *  \return 返回创建的时间线对象
 *  \endif
 *  \since 2.21.0
 *  \sa removeTimeline
 */
- (NvsTimeline *)createTimeline:(NSString *)templateId templateFootages:(NSArray <NvsTemplateFootageInfo*>*)templateFootages flags:(int)flags;


/*! \if ENGLISH
 *  \brief Creates timeline
 *  \param templateId template uuid，template must be installed firstly
 *  \param templateFootages footage information in the template asset
 *  \param flags Special flags for create timeline. If there is no special requirements please input 0. Please refer to [create timeline flag](@ref CREATE_TIMELINE_FLAG).
 *  \param videoFps Frame rate
 *  \param audioEditRes Audio file's resolution(specified file sampling rate, sampling format and number of channels. For audio editting resolution, imported audio only supports two types of sampling rate, 44100 or 48000.)
 * *  \return Returns created timeline object
 *  \else
 *  \brief 用模板资源创建时间线
 *  \param templateId 模板资源uuid，必须先安装模板
 *  \param templateFootages 模板资源里footage的对应信息
 *  \param flags 创建时间线的特殊标志，如果没有特殊需求，请填写0。请参见[创建时间线标志] (@ref CREATE_TIMELINE_FLAG)
 *  \param videoFps 视频帧率，最大60fps
 *  \param audioEditRes 音频解析度(指定采样率、采样格式及声道数)。对于音频编辑解析度，传入的采样率值支持两种：44100与48000。支持单声道和立体声
 *  \return 返回创建的时间线对象
 *  \endif
 *  \since 3.5.0
 *  \sa removeTimeline
 */
- (NvsTimeline *)createTimeline:(NSString *)templateId templateFootages:(NSArray <NvsTemplateFootageInfo*>*)templateFootages flags:(int)flags videoFps:(NvsRational *)videoFps audioEditRes:(NvsAudioResolution *)audioEditRes;

/*! \if ENGLISH
 *  \brief Creates timeline
 *  \param projectId project uuid
 *  \param resourceDir  Path of assets of project
 *  \return Returns created timeline object
 *  \else
 *  \brief 用项目资源创建时间线
 *  \param projectId 项目uuid
 *  \param resourceDir 项目资源文件夹路径
 *  \return 返回创建的时间线对象
 *  \endif
 *  \sa removeTimeline
 */
- (NvsTimeline *)loadProject:(NSString *)projectId resourceDir:(NSString*)resourceDir;

/*! \if ENGLISH
 *  \brief Removes timeline.
 *  \param timeline The timeline  which will be removed
 *  \return Returns the BOOL value. YES means removal succeeds, NO means removal fails.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 移除时间线
 *  \param timeline 要移除的时间线
 *  \return 返回BOOL值。YES 移除成功；NO 移除失败
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa createTimeline:videoFps:audioEditRes:
*/
- (BOOL)removeTimeline:(NvsTimeline *)timeline;

/*! \if ENGLISH
 *  \brief Gets the engine state.
 *  \return Returns the engine state.
 *  \else
 *  \brief 获取引擎状态
 *  \return 返回引擎状态
 *  \endif
*/
- (NvsStreamingEngineState)getStreamingEngineState;

/*! \if ENGLISH
 *  \brief Gets the current position of the timeline (in microseconds).
 *  \param timeline Timeline
 *  \return Returns the current position value of the timeline.
 *  \else
 *  \brief 取得时间线当前时间位置，单位为微秒
 *  \param timeline 时间线
 *  \return 返回时间线的当前位置值
 *  \endif
*/
- (int64_t)getTimelineCurrentPosition:(NvsTimeline *)timeline;

/*! \if ENGLISH
 *  \brief Compiles the video files by the timeline.
 *  \param timeline Timeline
 *  \param startTime Start time (in microseconds). The start time value ranges from [0, timeline.duration - 1], and other values are invalid.
 *  \param endTime End time (in microseconds). The value of endTime is in (startTime, timeline.duration], and the other values are invalid.
 *  \param outputFilePath The output video file path. Note: Currently only .mov format is supported.
 *  \param videoResolutionGrade Resolution level of video output.
 *  \param videoBitrateGrade The bitrate of the video output. The video output bitrate level is divided into low bitrate, medium bitrate, and high bitrate. The specific bitrate of video compiled is correlated with compiled file's resolution.
 *  Taking a 1280*720 pixels video for example, the approximate bitrates are as follows:
 *  <br>Bitrates for NvsCompileBitrateGradeLow, NvsCompileBitrateGradeMedium, NvsCompileBitrateGradeHigh are 2.2Mbps, 3.3Mbps and 6Mbps separately.s
 *  \param flags Special flag for video output (temporarily set to 0 only).Please refer to NvsStreamingEngineCompileFlag] (@ref NvsStreamingEngineCompileFlag).
 *  \return Returns the BOOL value. Note: Compiling timeline to video files is an asynchronous operation. If the return value is YES, compiling video startups successfully, otherwise it fails to startup.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 时间线生成视频文件
 *  \param timeline 时间线
 *  \param startTime 开始时间(单位微秒)。startTime取值范围在[0,timeline.duration - 1],传入其他值无效。
 *  \param endTime 结束时间(单位微秒)。endTime取值范围在(startTime,timeline.duration],同样传入其他值无效。
 *  \param outputFilePath 生成视频输出的文件路径。注意: 目前只支持输出.mov格式的文件
 *  \param videoResolutionGrade 生成视频输出的分辨率级别
 *  \param videoBitrateGrade 生成视频输出的码率。视频输出码率级别分为低码率，中等码率，高等码率。视频生成具体码率值跟生成视频的分辨率有关，这里以1280 * 720p为例，计算出不同码率级别对应的近似值，
 *                           NvsCompileBitrateGradeLow级别值为2.2Mbps，NvsCompileBitrateGradeMedium级别值为3.3Mbps，NvsCompileBitrateGradeHigh级别值为6Mbps。
 *  \param flags 生成视频输出的特殊标志。请参见 [NvsStreamingEngineCompileFlag] (@ref NvsStreamingEngineCompileFlag)
 *  \return 返回BOOL值。注意：时间线生成视频文件是异步操作。返回值为YES则启动时间线生成文件成功，NO则时间线生成文件启动失败。
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa seekTimeline:timestamp:videoSizeMode:flags:
 *  \sa playbackTimeline:startTime:endTime:videoSizeMode:preload:flags:
*/
- (BOOL)compileTimeline:(NvsTimeline *)timeline startTime:(int64_t)startTime endTime:(int64_t)endTime outputFilePath:(NSString *)outputFilePath videoResolutionGrade:(NvsCompileVideoResolutionGrade)videoResolutionGrade videoBitrateGrade:(NvsCompileVideoBitrateGrade)videoBitrateGrade flags:(int)flags;

/*! \if ENGLISH
 *  \brief Compiles the video files by the timeline.
 *  \param timeline Timeline
 *  \param startTime Start time (in microseconds). The start time value ranges from [0, timeline.duration - 1], and other values are invalid.
 *  \param endTime End time (in microseconds). The value of endTime is in (startTime, timeline.duration], and the other values are invalid.
 *  \param outputFilePath The output video file path. Note: Currently only .mov format is supported.
 *  \param videoResolutionGrade Resolution level of video output.
 *  \param videoBitrateGrade The bitrate of the video output. The video output bitrate level is divided into low bitrate, medium bitrate, and high bitrate. The specific bitrate of video compiled is correlated with compiled file's resolution.
 *  Taking a 1280*720 pixels video for example, the approximate bitrates are as follows:
 *  <br>Bitrates for NvsCompileBitrateGradeLow, NvsCompileBitrateGradeMedium, NvsCompileBitrateGradeHigh are 2.2Mbps, 3.3Mbps and 6Mbps separately.s
 *  \param configurations the timeline configurations. For key values in NSMutableDictionary please refer to [Configuration of compiling timeline](@ref COMPILE_CONFIGURATIONS)
 *  \param flags Special flag for video output (temporarily set to 0 only).Please refer to NvsStreamingEngineCompileFlag] (@ref NvsStreamingEngineCompileFlag).
 *  \return Returns the BOOL value. Note: Compiling timeline to video files is an asynchronous operation. If the return value is YES, compiling video startups successfully, otherwise it fails to startup.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 时间线生成视频文件
 *  \param timeline 时间线
 *  \param startTime 开始时间(单位微秒)。startTime取值范围在[0,timeline.duration - 1],传入其他值无效。
 *  \param endTime 结束时间(单位微秒)。endTime取值范围在(startTime,timeline.duration],同样传入其他值无效。
 *  \param outputFilePath 生成视频输出的文件路径。注意: 目前只支持输出.mov格式的文件
 *  \param videoResolutionGrade 生成视频输出的分辨率级别
 *  \param videoBitrateGrade 生成视频输出的码率。视频输出码率级别分为低码率，中等码率，高等码率。视频生成具体码率值跟生成视频的分辨率有关，这里以1280 * 720p为例，计算出不同码率级别对应的近似值，
 *                           NvsCompileBitrateGradeLow级别值为2.2Mbps，NvsCompileBitrateGradeMedium级别值为3.3Mbps，NvsCompileBitrateGradeHigh级别值为6Mbps。
 *  \param compileConfigurations 时间线配置 NSMutableDictionary中关键字的值请参见 [生成时间线的配置] (@ref COMPILE_CONFIGURATIONS)
 *  \param flags 生成视频输出的特殊标志。请参见 [NvsStreamingEngineCompileFlag] (@ref NvsStreamingEngineCompileFlag)
 *  \return 返回BOOL值。注意：时间线生成视频文件是异步操作。返回值为YES则启动时间线生成文件成功，NO则时间线生成文件启动失败。
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \since 3.1.0
 *  \sa seekTimeline:timestamp:videoSizeMode:flags:
 *  \sa playbackTimeline:startTime:endTime:videoSizeMode:preload:flags:
*/
- (BOOL)compileTimeline:(NvsTimeline *)timeline startTime:(int64_t)startTime endTime:(int64_t)endTime outputFilePath:(NSString *)outputFilePath videoResolutionGrade:(NvsCompileVideoResolutionGrade)videoResolutionGrade videoBitrateGrade:(NvsCompileVideoBitrateGrade)videoBitrateGrade compileConfigurations:(NSMutableDictionary *)compileConfigurations flags:(int)flags;

/*! \if ENGLISH
 *  \brief Compile passthrough the video clips on video track 0 in the timeline into a file without processing filter, multi track and nested timeline.
 *         If there are photos, it will fail.
 *  \param timeline Timeline
 *  \param outputFilePath The path of output file.
 *  \param configurations the timeline configurations,only supports NVS_COMPILE_CREATION_TIME, NVS_COMPILE_OPTIMIZE_FOR_NETWORK_USE, NVS_COMPILE_METADATADESCRIPTION, NVS_COMPILE_FILE_META_DATA
 *  \param flags Special flags for output file. If there is no special requirements please input 0.
 *  \return Returns a boolean value. Note: compiling timeline to file is an asynchronous operation. Returns true if compile successful and false if compile failed.
 *  \warning This interface will trigger streaming engine to jump to stop state. For detailed situations please refer to [the state changes of engine](\ref EngineChange.md).
 *  \else
 *  \brief 将时间线中视频轨道0上的视频片段直通生成一个视频，不处理滤镜、多轨和嵌套时间线，如果有图片则失败
 *  \param timeline 时间线对象
 *  \param outputFilePath 生成输出的文件路径
 *  \param configurations 时间线配置,只支持添加NVS_COMPILE_CREATION_TIME、NVS_COMPILE_OPTIMIZE_FOR_NETWORK_USE、NVS_COMPILE_METADATADESCRIPTION、NVS_COMPILE_FILE_META_DATA
 *  \param flags 生成文件输出的特殊标志，如果没有特殊需求，请填写0。
 *  \return 返回布尔值。注意：时间线生成文件是异步操作。返回true，则启动生成成功；false，则启动生成失败
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \since 3.4.0
 *  \sa seekTimeline
 *  \sa playbackTimeline
 *  \sa compileTimeline
 */
- (BOOL)compilePassthroughTimeline:(NvsTimeline *)timeline
                    outputFilePath:(NSString *)outputFilePath
             compileConfigurations:(NSMutableDictionary *)configurations flags:(int)flags;

/*! \if ENGLISH
 *  \brief Pause compiling timeline
 *  \return Returns a BOOL value indicating whether the pause was successful
 *  \else
 *  \brief 暂定生成时间线
 *  \return 返回布尔值表示暂停是否成功
 *  \endif
 *  \since 2.9.0
 *  \sa resumeCompiling
 */
- (BOOL)pauseCompiling;

/*! \if ENGLISH
 *  \brief Resume compiling timeline
 *  \return Returns a boolean value indicating whether the resume was successful
 *  \else
 *  \brief 恢复生成时间线
 *  \return 返回布尔值表示恢复是否成功
 *  \endif
 *  \since 2.9.0
 *  \sa pauseCompiling
 */
- (BOOL)resumeCompiling;

/*! \if ENGLISH
 *  \brief Check if compiling timeline is paused
 *  \return Returns a boolean value indicating whether compiling timeline is paused
 *  \else
 *  \brief 检查生成时间线是否暂停了
 *  \return 返回布尔值表示生成时间线是否暂停了
 *  \endif
 *  \since 2.9.0
 *  \sa pauseCompiling
 */
- (BOOL)isCompilingPaused;

/*! \if ENGLISH
 *  \brief Pause playback timeline
 *  \return Returns a boolean value indicating whether the pause was successful
 *  \else
 *  \brief 暂停播放时间线
 *  \return 返回布尔值表示暂停是否成功
 *  \endif
 *  \since 2.18.0
 *  \sa resumeCompiling
 */
- (BOOL)pausePlayback;

/*! \if ENGLISH
*  \brief Resume playback timeline
 *  \return Returns a boolean value indicating whether the resume was successful
 *  \else
 *  \brief 恢复播放时间线
 *  \return 返回布尔值表示恢复是否成功
 *  \endif
 *  \since 2.18.0
 *  \sa pausePlayback
 */
- (BOOL)resumePlayback;

/*! \if ENGLISH
 *  \brief Check if playback timeline is paused
 *  \return Returns a boolean value indicating whether compiling timeline is paused
 *  \else
 *  \brief 检查播放时间线是否暂停了
 *  \return 返回布尔值表示播放时间线是否暂停了
 *  \endif
 *  \since 2.18.0
 *  \sa pauseCompiling
 */
- (BOOL)isPlaybackPaused;

/*! \if ENGLISH
 *  \brief Sets the customized height for video.
 *   <br> When compiling videos, set the bitrate grade for compiled video to COMPILE_VIDEO_RESOLUTION_GRADE_CUSTOM.
            Plesae note, to make sure the file is compiled successfully, Meishe SDK would calibrate the height accordingly, thus the final output file may not necessarily be the height set here.
 *  \param videoHeight Custom height of the compiled video
 *  \else
 *  \brief 设置自定义的生成视频高度。
 *         <br>在生成时视频时，设置生成视频的分辨率高度级别为NvsCompileVideoResolutionGradeCustom
 *         就可以使用自定义的生成视频高度。但是请注意，为了保证视频生成成功，美摄SDK会对高度进行适当的对齐，
 *         因此最终生成的视频高度不一定就是这里设置的高度！
 *  \param videoHeight 自定义的生成视频高度
 *  \endif
 *  \since 1.6.1
 *  \sa compileTimeline
*/
- (void)setCustomCompileVideoHeight:(unsigned int)videoHeight;

/*! \if ENGLISH
 *  \brief Gets the custom video height
 *  \return Returns the custom video height
 *  \else
 *  \brief 获取当前自定义的生成视频高度。
 *  \return 返回当前自定义的生成视频高度
 *  \endif
 *  \since 1.6.1
*/
- (unsigned int)getCustomCompileVideoHeight;

/*! \if ENGLISH
 *  \brief Connects timeline with live window.
 *  \param timeline Timeline
 *  \param liveWindow Live window
 *  \return Returns BOOL value. YES means a successful connection, and NO means the opposite.
 *  \else
 *  \brief 连接时间线和实时预览窗口
 *  \param timeline 时间线
 *  \param liveWindow 实时预览窗口
 *  \return 返回BOOL值。返回YES则连接成功，NO则连接失败。
 *  \endif
*/
- (BOOL)connectTimeline:(NvsTimeline *)timeline withLiveWindow:(NvsLiveWindow *)liveWindow;

/*! \if ENGLISH
 *  \brief Connects timeline with video frame receiver.
 *  \param timeline Timeline
 *  \param receiver Video frame receiver
 *  \return  Returns BOOL value. YES means a successful connection, and NO means the opposite.
 *  \else
 *  \brief 连接时间线和视频帧接收器
 *  \param timeline 时间线
 *  \param receiver 视频帧接收器
 *  \return 返回BOOL值。返回YES则连接成功，NO则连接失败。
 *  \endif
*/
- (BOOL)connectTimeline:(NvsTimeline *)timeline withVideoFrameReceiver:(NvsVideoFrameReceiver *)receiver;

/*! \if ENGLISH
 *  \brief Set scale in seconds per pixel of a timeline to detect scrubbing.
 *         You should do this before each seek operation that sets the (@ref NvsStreamingEngineSeekFlag_AllowFastScrubbing) flag.
 *  \param timeline Timeline
 *  \param secondsPerPixel scale in seconds per pixel
 *  \else
 *  \brief 设置时间线的比例尺（单位是秒/像素）以便进行scrubbing检测。
 *         使用者应该在每个设置了(@ref NvsStreamingEngineSeekFlag_AllowFastScrubbing)标志的seek操作之前调用此方法。
 *  \param timeline 时间线
 *  \param secondsPerPixel 比例尺（单位是秒/像素）
 *  \endif
 *  \since 3.13.1
 */
- (void)setTimeline:(NvsTimeline *)timeline scaleForSeek:(double)secondsPerPixel API_DEPRECATED("",macos(10.3, 10.11), ios(7.0, 8.0));

/*! \if ENGLISH
 *  \brief Seeks to a certain timestamp of images
 *  \param timeline Timeline
 *  \param timestamp Timestamp (in microseconds). The range of timestamp value is [0, timeline.duration - 1]. And any other input value is invalid, seekTimeline will return No, resulting in seek failure.
 *  \param videoSizeMode Mode of previewing image
 *  \param flags Special seek flag for engine. Please refer to [NvsStreamingEngineSeekFlag] (@ref NvsStreamingEngineSeekFlag)
 *  \return Returns BOOL value. Note: Seeking to a timestamp is an asynchronous operation. A return value of YES means that seeking video startups successfully, otherwise it fails to startup.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 定位某一时间戳的图像
 *  \param timeline 时间线
 *  \param timestamp 时间戳(单位是微秒)。timestamp取值范围在[0,timeline.duration - 1]。传入其他值无效，seekTimeline会返回No,导致无法开启定位。
 *  \param videoSizeMode 图像预览模式
 *  \param flags 引擎定位的特殊标志。请参见 [NvsStreamingEngineSeekFlag] (@ref NvsStreamingEngineSeekFlag)
 *  \return 返回BOOL值。注意：定位某时间戳图像是异步操作。返回值为YES则成功开启定位，NO则无法开启定位。
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa compileTimeline:startTime:endTime:outputFilePath:videoResolutionGrade:videoBitrateGrade:flags:
 *  \sa playbackTimeline:startTime:endTime:proxyScale:preload:flags:
 *  \sa seekTimeline:timestamp:proxyScale:flags:
*/
- (BOOL)seekTimeline:(NvsTimeline *)timeline timestamp:(int64_t)timestamp videoSizeMode:(NvsVideoPreviewSizeMode)videoSizeMode flags:(int)flags;

/*! \if ENGLISH
 *  \brief Seeks to a certain timestamp of images
 *  \param timeline Timeline
 *  \param timestamp Timestamp (in microseconds). The range of timestamp value is [0, timeline.duration - 1]. And any other input value is invalid, seekTimeline will return No, resulting in seek failure.
 *  \param proxyScale Proxy scale value
 *  \param flags Special seek flag for engine. Please refer to [NvsStreamingEngineSeekFlag] (@ref NvsStreamingEngineSeekFlag)
 *  \return Returns BOOL value. Note: Seeking to a timestamp is an asynchronous operation. A return value of YES means that seeking video startups successfully, otherwise it fails to startup.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 定位某一时间戳的图像
 *  \param timeline 时间线
 *  \param timestamp 时间戳(单位是微秒)。timestamp取值范围在[0,timeline.duration - 1]。传入其他值无效，seekTimeline会返回No,导致无法开启定位。
 *  \param proxyScale 代理缩放比例
 *  \param flags 引擎定位的特殊标志。请参见 [NvsStreamingEngineSeekFlag] (@ref NvsStreamingEngineSeekFlag)
 *  \return 返回BOOL值。注意：定位某时间戳图像是异步操作。返回值为YES则成功开启定位，NO则无法开启定位。
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa seekTimeline:timestamp:videoSizeMode:flags:
 *  \sa playbackTimeline:startTime:endTime:videoSizeMode:preload:flags:
 *  \sa compileTimeline:startTime:endTime:outputFilePath:videoResolutionGrade:videoBitrateGrade:flags:
*/
- (BOOL)seekTimeline:(NvsTimeline *)timeline timestamp:(int64_t)timestamp proxyScale:(const NvsRational *)proxyScale flags:(int)flags;

/*! \if ENGLISH
 *  \brief Gets the image in the timeline of a certain timestamp. For details, refer to [The Topic of Video Frame Image Extraction] (@ref videoFrameRetriever.md).
 *  \param timeline The timeline object which gets the image
 *  \param timestamp The timestamp (in microseconds) for the image. The range of timestamp is [0, timeline.duration - 1]. Other values are invalid, and grabImageFromTimeline will return nil.
 *  \param proxyScale Proxy scale.Setting nil indicates the default ratio of 1:1.
 *  \return Returns the UIImage object of the image, it will return nil if grabbing image is failed.
 *  \else
 *  \brief 获取时间线某一时间戳的图像。详细情况参见[视频帧图像提取专题] (@ref videoFrameRetriever.md)
 *  \param timeline 欲获取图像的时间线对象
 *  \param timestamp 欲获取图像的时间戳(单位是微秒)。timestamp取值范围在[0,timeline.duration - 1]。传入其他值无效，grabImageFromTimeline会返回nil。
 *  \param proxyScale 代理缩放比例，填写nil表示使用默认比例1:1
 *  \return 返回该时间戳图像的UIImage对象，如果获取图像失败返回nil
 *  \endif
 *  \since 1.1.2
*/
- (UIImage *)grabImageFromTimeline:(NvsTimeline *)timeline
                         timestamp:(int64_t)timestamp
                        proxyScale:(const NvsRational *)proxyScale;


/*! \if ENGLISH
 *  \brief Gets the image in the timeline of a certain timestamp. For details, refer to [The Topic of Video Frame Image Extraction] (@ref videoFrameRetriever.md).
 *  \param timeline The timeline object which gets the image
 *  \param timestamp The timestamp (in microseconds) for the image. The range of timestamp is [0, timeline.duration - 1]. Other values are invalid, and grabImageFromTimeline will return nil.
 *  \param proxyScale Proxy scale.Setting nil indicates the default ratio of 1:1.
 *  \param flags Special flag for seeking engine. Please refer to [NvsStreamingEngineSeekFlag] (@ref NvsStreamingEngineSeekFlag).
 *  \return Returns the UIImage object of the image, it will return nil if grabbing image is failed.
 *  \else
 *  \brief 获取时间线某一时间戳的图像。详细情况参见[视频帧图像提取专题] (@ref videoFrameRetriever.md)
 *  \param timeline 欲获取图像的时间线对象
 *  \param timestamp 欲获取图像的时间戳(单位是微秒)。timestamp取值范围在[0,timeline.duration - 1]。传入其他值无效，grabImageFromTimeline会返回nil。
 *  \param proxyScale 代理缩放比例，填写nil表示使用默认比例1:1
 *  \param flags 引擎定位的特殊标志。请参见 [NvsStreamingEngineSeekFlag] (@ref NvsStreamingEngineSeekFlag)
 *  \return 返回该时间戳图像的UIImage对象，如果获取图像失败返回nil
 *  \endif
 *  \since 1.16.0
*/
- (UIImage *)grabImageFromTimeline:(NvsTimeline *)timeline timestamp:(int64_t)timestamp proxyScale:(const NvsRational *)proxyScale flags:(int)flags;

/*! \if ENGLISH
 *  \brief Gets the specific frame in timeline with a specific timestamp. For details please refer to [The video frame retriever] (@ref videoFrameRetriever.md).
 *  This function is an internal asynchronous call. It is necessary to ensure that SeekTimeline () will not be invoked before getting the image. If the function that calls SeekTimeline after calling this function may not get the callback of the image, it can call Stop after this function to ensure that the Grab image can be executed successfully.
 *  \param timeline The timeline that will be grabbed from.
 *  \param timestamp The desired frame's timestamp(in microseconds). Timestamp should be within range [0,timeline.duration - 1]. Other inputs are invalid and will results grabImageFromTimeline returns null.
 *  \param proxyScale Zoom scale of proxy
 *  \param flags Flags for streaming engine seeking. For specific please refer to [The seek flag of streaming engine](@ref STREAMING_ENGINE_SEEK_FLAG).
 *  \return Returns a boolean value.
 *  \else
 *  \brief 获取时间线某一时间戳的图像。详细情况参见[视频帧图像提取专题] (@ref videoFrameRetriever.md)
 *   这个函数是内部异步调用,需要保证在获取到图像之前不会调用SeekTimeline(),如果在调用这个函数之后调用SeekTimeline的函数有可能收不到图像的回调，可以在这个函数之后调用Stop保证Grab image能执行成功
 *  \param timeline 欲获取图像的时间线对象
 *  \param timestamp 欲获取图像的时间戳（单位微秒）。timestamp取值范围在[0,timeline.duration - 1]。传入其他值无效，grabImageFromTimeline会返回null。
 *  \param proxyScale 代理缩放比例
 *  \param flags 引擎定位的特殊标志。具体参见[引擎定位标识](@ref STREAMING_ENGINE_SEEK_FLAG)
 *  \return 返回布尔值,
 *  \endif
 *  \since 2.15.0
 */

- (BOOL)grabImageFromTimelineAsync:(NvsTimeline *)timeline
                              timestamp:(int64_t)timestamp
                             proxyScale:(const NvsRational *)proxyScale
                                  flags:(int)flags;

/*! \if ENGLISH
 *  \brief Playback timeline
 *  \param timeline Timeline
 *  \param startTime Start time (in microseconds). The value range of startTime is [0, timeline.duration - 1]. Any other value is invalid, and the playbackTimeline will return NO, resulting in startuping unsuccessfully for the playback video.
 *  \param endTime End time (in microseconds). If the input endTime value is negative, it will play to the end of the video by default.
 *  \param videoSizeMode Mode of previewing image
 *  \param preload Whether it preloads or not
 *  \param flags Special flag for previewing. If there is no special need, please fill in 0. Please refer to [NvsStreamingEnginePlaybackFlag] (@ref NvsStreamingEnginePlaybackFlag).
 *  \return Returns BOOL value. Note: The timeline playback is an asynchronous operation. Returning YES will start the timeline playback, and NO will not.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 播放时间线
 *  \param timeline 时间线
 *  \param startTime 开始时间(单位是微秒)。startTime取值范围在[0,timeline.duration - 1]。传入其他值无效，playbackTimeline会返回No导致无法开启播放。
 *  \param endTime 结束时间(单位是微秒)。如果endTime值传入是负值，则默认播放到视频末尾。
 *  \param videoSizeMode 图像预览模式
 *  \param preload 是否预先加载
 *  \param flags 预览的特殊标志，如无特殊需求，请填写0。请参见 [NvsStreamingEnginePlaybackFlag] (@ref NvsStreamingEnginePlaybackFlag)
 *  \return 返回BOOL值。注意：播放时间线是异步操作。返回YES则可以开启播放时间线，NO则无法开启播放。
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa playbackTimeline:startTime:endTime:proxyScale:preload:flags:
 *  \sa compileTimeline:startTime:endTime:outputFilePath:videoResolutionGrade:videoBitrateGrade:flags:
 *  \sa seekTimeline:timestamp:videoSizeMode:flags:
*/
- (BOOL)playbackTimeline:(NvsTimeline *)timeline startTime:(int64_t)startTime endTime:(int64_t)endTime videoSizeMode:(NvsVideoPreviewSizeMode)videoSizeMode preload:(BOOL)preload flags:(int)flags;

/*! \if ENGLISH
 *  \brief Playback timeline
 *  \param timeline Timeline
 *  \param startTime Start time (in microseconds). The value range of startTime is [0, timeline.duration - 1]. Any other value is invalid, and the playbackTimeline will return NO, resulting in startuping unsuccessfully for the playback video.
 *  \param endTime End time (in microseconds). If the input endTime value is negative, it will play to the end of the video by default.
 *  \param proxyScale Proxy scale
 *  \param preload Whether it preloads or not
 *  \param flags Special flag for previewing. If there is no special need, please fill in 0. Please refer to [NvsStreamingEnginePlaybackFlag] (@ref NvsStreamingEnginePlaybackFlag).
 *  \return Returns BOOL value. Note: The timeline playback is an asynchronous operation. Returning YES will start the timeline playback, and NO will not.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 播放时间线
 *  \param timeline 时间线
 *  \param startTime 开始时间(单位是微秒)。startTime取值范围在[0,timeline.duration - 1]。传入其他值无效，playbackTimeline会返回No导致无法开启播放。
 *  \param endTime 结束时间(单位是微秒)。如果endTime值传入是负值，则默认播放到视频末尾。
 *  \param proxyScale 代理缩放比例
 *  \param preload 是否预先加载
 *  \param flags 预览的特殊标志，如无特殊需求，请填写0。请参见 [NvsStreamingEnginePlaybackFlag] (@ref NvsStreamingEnginePlaybackFlag)
 *  \return 返回BOOL值。注意：播放时间线是异步操作。返回YES则可以开启播放时间线，NO则无法开启播放。
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa playbackTimeline:startTime:endTime:videoSizeMode:preload:flags:
 *  \sa seekTimeline:timestamp:proxyScale:flags:
 *  \sa compileTimeline:startTime:endTime:outputFilePath:videoResolutionGrade:videoBitrateGrade:flags:
*/
- (BOOL)playbackTimeline:(NvsTimeline *)timeline startTime:(int64_t)startTime endTime:(int64_t)endTime proxyScale:(const NvsRational *)proxyScale preload:(BOOL)preload flags:(int)flags;

/*! \if ENGLISH
 *  \brief Stops the engine
 *  \else
 *  \brief 停止引擎
 *  \endif
*/
- (void)stop;

/*! \if ENGLISH
 *  \brief tops the engine
 *  \param flags Flag of stopping the engine. Please refer to [NvsStreamingEngineStopFlag] (@ref NvsStreamingEngineStopFlag).
 *  \else
 *  \brief 停止引擎
 *  \param flags 停止引擎标志。请参见 [NvsStreamingEngineStopFlag] (@ref NvsStreamingEngineStopFlag)
 *  \endif
 *  \since 2.3.0
*/
- (void)stop:(int)flags;

/*! \if ENGLISH
 *  \brief Clears the cached resources.
 *  \param asynchronous Whether it's Asynchronous or not.
 *  \else
 *  \brief 清除缓存资源
 *  \param asynchronous 是否异步
 *  \endif
*/
- (void)clearCachedResources:(BOOL)asynchronous;

/*! \if ENGLISH
 *  \brief Clears the cached resources.
 *  \param asynchronous Whether it's Asynchronous or not.
 *  \else
 *  \brief 清除缓存资源
 *  \param asynchronous 是否异步
 *  \param flags 清除缓存标志，如无特殊需求请填写0。请参见 [NvsClearCacheFlag] (@ref NvsClearCacheFlag)。
 *  \endif
*/
- (void)clearCachedResources:(BOOL)asynchronous flags:(int)flags;

/*! \if ENGLISH
 *  \brief Count of captureing devices
 *  \return Returns the count of captureing devices.
 *  \else
 *  \brief 采集设备的数量
 *  \return 返回采集设备数
 *  \endif
*/
- (unsigned int)captureDeviceCount;

/*! \if ENGLISH
 *  \brief Obtain the type of capture device
 *  \return Returns the type of capture device.
 *  \else
 *  \brief 获取采集设备的类型
 *  \return 返回采集设备类型
 *  \endif
 *  \since 3.16.0
*/
- (NvsCameraDeviceType)getCaptureDeviceType:(unsigned int)captureIndex;

/*! \if ENGLISH
 *  \brief Whether it's a rear capturing device.
 *  \param catpureDeviceIndex Index of capturing device
 *  \return Returns BOOL value. YES means it is a rear capture device, and NO means the opposite.
 *  \else
 *  \brief 是否为后置采集设备
 *  \param catpureDeviceIndex 采集设备索引
 *  \return 返回BOOL值。返回YES则是后置采集设备，NO则不是。
 *  \endif
*/
- (BOOL)isCaptureDeviceBackFacing:(unsigned int)catpureDeviceIndex;

/*! \if ENGLISH
 *  \brief Obtains the capability description object of the capture device.
 *  \param catpureDeviceIndex Index of capturing device
 *  \return Returns the NvsCaptureDeviceCapability object.
 *  \else
 *  \brief 获取采集设备的能力描述对象
 *  \param catpureDeviceIndex 采集设备索引
 *  \return 返回采集设备能力描述对象
 *  \endif
*/
- (NvsCaptureDeviceCapability *)getCaptureDeviceCapability:(unsigned int)catpureDeviceIndex;

/*! \if ENGLISH
 *  \brief Connects the captured preview with live window.
 *  \param liveWindow Live window for previewing
 *  \return Returns the BOOL value. YES indicates a successful connection, and NO means the opposite.
 *  \else
 *  \brief 连接采集预览和实时预览窗口
 *  \param liveWindow 实时预览窗口
 *  \return 返回BOOL值。返回YES则连接成功，NO则连接失败。
 *  \endif
 *  \sa connectTimeline:withLiveWindow:
*/
- (BOOL)connectCapturePreviewWithLiveWindow:(NvsLiveWindow *)liveWindow;

/*! \if ENGLISH
 *  \brief Connects the captured preview with video frame receiver.
 *  \param receiver Video frame receiver
 *  \return Returns the BOOL value. YES indicates a successful connection, and NO means the opposite.
 *  \else
 *  \brief 连接采集预览和视频帧接收器
 *  \param receiver 视频帧接收器
 *  \return 返回BOOL值。返回YES则连接成功，NO则连接失败。
 *  \endif
 *  \since 1.7.1
*/
- (BOOL)connectCapturePreviewWithVideoFrameReceiver:(NvsVideoFrameReceiver *)receiver;

/*! \if ENGLISH
 *  \brief Adds a custom watermark for capturing video.
 *  \param watermarkFilePath Path of the watermark file, which should be a .PNG or .JPG file.
 *  \param displayWidth The width of the watermark displayed in the preview. If it is 0, the original width of the image is used.
 *  \param displayHeight The height of the watermark displayed in the preview. If it is 0, the original height of the image is used.
 *  \param opacity Watermark opacity, the range of which is 0~1
 *  \param position Position of the watermark, please refer to [NvsTimelineWatermarkPosition] (@ref NvsTimelineWatermarkPosition).
 *  \param marginX Watermark horizontal margin
 *  \param marginY Watermark vertical margin
 *  \else
 *  \brief 为视频采集添加用户水印
 *  \param watermarkFilePath 水印文件的路径，须为PNG或JPG文件
 *  \param displayWidth 水印在视频预览画面中显示的宽度，为0则使用图片文件的宽度
 *  \param displayHeight 水印在视频预览画面中显示的高度，为0则使用图片文件的高度
 *  \param opacity 水印的不透明度, 取值范围 0~1
 *  \param position 水印的位置，请参见 [NvsTimelineWatermarkPosition] (@ref NvsTimelineWatermarkPosition)
 *  \param marginX 水印在X方向的边距
 *  \param marginY 水印在Y方向的边距
 *  \endif
 *  \since 2.0.1
*/
-(void)setUserWatermarkForCapture:(NSString *)watermarkFilePath
                     displayWidth:(int)displayWidth
                    displayHeight:(int)displayHeight
                          opacity:(float)opacity
                         position:(NvsTimelineWatermarkPosition)position
                          marginX:(int)marginX
                          marginY:(int)marginY;

/*! \if ENGLISH
 *  \brief Removes custom watermark which added for capturing video.
 *  \else
 *  \brief 移除为视频采集添加的用户水印。
 *  \endif
 *  \since 2.0.1
*/
-(void)removeUserWatermarkForCapture;

/*! \if ENGLISH
 *  \brief Starts the capture preview.
 *  \param captureDeviceIndex Index of the capture device
 *  \param videoResGrade Video capture resolution level. The video resolution is defined by the short side (width or height) of the captured video. Value of the other side (width or height) is calculated according to the video aspect ratio (nil means the aspect ratio will be determined by the system capture device).
 *  It includes three levels, namely low, medium and high, the front camera corresponds to 480P, 540P, 720P, and the rear camera corresponds to 540P, 720P, 1080P.
 *  If the user wants to customize the recording resolution, such as 540*960 pixels, then it will need to record a video with equal aspect ratio, create a timeline with aspect ratio of 540*960 and compile it to file.
 *  When compiling, there is no grade corresponding to a height of 960p, thus the user needs to call setCustomCompileVideoHeight() to customize the height before compilation. Then call compileTimeline(),
 *  and the compiled level should be set to NvsCompileVideoResolutionGradeCustom. The example code is as follows:
 *
 *          NvsVideoResolution videoEditRes;
 *          videoEditRes.imageWidth = 540;
 *          videoEditRes.imageHeight = 960;
 *          videoEditRes.imagePAR = (NvsRational){1, 1};
 *          NvsRational videoFps = {25, 1};
 *          NvsAudioResolution audioEditRes;
 *          audioEditRes.sampleRate = 48000;
 *          audioEditRes.channelCount = 2;
 *          audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
 *          self.timeline = [_context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes];
 *          [_context setCustomCompileVideoHeight:960];
 *          [self.context compileTimeline:self.timeline startTime:0 endTime:self.timeline.duration outputFilePath:videoPath
 *          videoResolutionGrade:NvsCompileVideoResolutionGradeCustom videoBitrateGrade:NvsCompileBitrateGradeMedium flags:0];
 *  \param flags Flag field, if there is no special requirement, please fill in 0. Please refer to [NvsStreamingEngineCaptureFlag] (@ref NvsStreamingEngineCaptureFlag). The application scene for each flag  is as follows:
 *  <br>NvsStreamingEngineCaptureFlag_GrabCapturedVideoFrame which is used in grabing video frame；
 *  <br>NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize is used for face detection combination with NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame;
 *  <br>NvsStreamingEngineCaptureFlag_DontCaptureAudio Used for live video without audio stream. Usually not used.
 *  \param aspectRatio Aspect ratio for previewing, setting nil means that it will be determined by the system capture device.
 *  \return Returns BOOL value. YES indicates that the preview is started successfully, and NO means the opposite.
 *  \else
 *  \brief 启动采集设备预览
 *  \param captureDeviceIndex 采集设备索引
 *  \param videoResGrade 视频采集分辨率级别。视频分辨率等级是指录制时所拍摄视频短边（即可能是宽度或者是高度）的分辨率值，根据视频横纵比aspectRatio(值为nil则由系统采集设备来决定横纵比)计算得到另一边（即可能是宽度或者是高度）的值。
 *  其包括三种级别，分别是LOW，MEDIUM，HIGH，前置摄像头依次对应480p，540p，720p，后置摄像头依次对应540p，720p，1080p。如果有用户想自定义录制视频的等级，
 *  例如540 * 960,则需要拍摄等横纵比的视频，通过创建宽高依次是540和960的时间线，编辑然后生成。生成时，生成分辨率高度等级里面没有960p的等级，因此需要在生成前调用
 *  setCustomCompileVideoHeight()接口来自定义高度，然后调用生成接口compileTimeline()，生成高度级别设置为NvsCompileVideoResolutionGradeCustom即可。实例代码如下：
 *
 *          NvsVideoResolution videoEditRes;
 *          videoEditRes.imageWidth = 540;
 *          videoEditRes.imageHeight = 960;
 *          videoEditRes.imagePAR = (NvsRational){1, 1};
 *          NvsRational videoFps = {25, 1};
 *          NvsAudioResolution audioEditRes;
 *          audioEditRes.sampleRate = 48000;
 *          audioEditRes.channelCount = 2;
 *          audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
 *          self.timeline = [_context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes];
 *          [_context setCustomCompileVideoHeight:960];
 *          [self.context compileTimeline:self.timeline startTime:0 endTime:self.timeline.duration outputFilePath:videoPath
 *          videoResolutionGrade:NvsCompileVideoResolutionGradeCustom videoBitrateGrade:NvsCompileBitrateGradeMedium flags:0];
 *  \param flags 标志字段，如无特殊需求请填写0。请参见 [NvsStreamingEngineCaptureFlag] (@ref NvsStreamingEngineCaptureFlag)。每个Flag应用场景如下：
 *  <br>NvsStreamingEngineCaptureFlag_GrabCapturedVideoFrame用于视频抠像；
 *  <br>NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize与NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame结合用于人脸检测；
 *  <br>NvsStreamingEngineCaptureFlag_DontCaptureAudio用于视频直播，不采集音频流，一般不常用。
 *  \param aspectRatio 预览视频横纵比，传入nil则由系统采集设备来决定横纵比
 *  \return 返回BOOL值。返回YES则启动预览成功，NO则启动预览失败。
 *  \endif
*/
- (BOOL)startCapturePreview:(unsigned int)captureDeviceIndex
              videoResGrade:(NvsVideoCaptureResolutionGrade)videoResGrade
                      flags:(int)flags
                aspectRatio:(const NvsRational *)aspectRatio;

/*! \if ENGLISH
 *  \brief Starts the capture preview with inputting buffer mode.
 *  \param width Input buffer width.
 *  \param height Input buffer height.
 *  \param fps Input buffer framerate.
 *  \param rotation Input buffer rotation angle. Please refer to [Image rotation angle of input buffer](@ref BufferImageRotation)
 *  \param flipHorizontally whether to flip the buffer horizontally.
 *  \return Returns BOOL value. YES indicates that the preview is started successfully, and NO means the opposite.
 *  \else
 *  \brief 启动输入buffer模式的采集设备预览
 *  \param width 输入buffer的宽
 *  \param height 输入buffer的高
 *  \param fps 输入buffer的帧率
 *  \param rotation 输入buffer的图像旋转角度。请参见 [输入buffer的图像旋转角度] (@ref BufferImageRotation)
 *  \param flipHorizontally 是否需要水平翻转
 *  \return 返回BOOL值。返回YES则启动预览成功，NO则启动预览失败。
 *  \endif
 *  \sa sendBufferToCapturePreview
*/
- (BOOL)startBufferCapturePreview:(unsigned int)width
                                                height:(unsigned int)height
  fps:(const NvsRational *)fps
  rotation:(int)rotation
  flipHorizontally:(BOOL)flipHorizontally;

/*! \if ENGLISH
 *  \brief Transfers the input buffer to capture preivew.
 *  \param data Data and information of the input buffer. Only NV12 format is supported.
 *  \return Returns BOOL value.
 *  \else
 *  \brief 输入buffer给采集设备预览
 *  \param data 输入buffer的数据和相应信息。仅支持NV12格式的数据
 *  \return 返回BOOL值。
 *  \endif
 *  \sa startBufferCapturePreview
*/
- (BOOL)sendBufferToCapturePreview:(const NvsVideoFrameInfo *)data;

/*! \if ENGLISH
 *  \brief Transfers the input buffer to capture preivew.
 *  \param data Data and information of the input buffer. Only NV12 format is supported.
 *  \return Returns BOOL value.
 *  \else
 *  \brief 输入buffer给采集设备预览
 *  \param data 输入buffer的数据和相应信息。
 *  \return 返回BOOL值。
 *  \endif
 *  \sa startBufferCapturePreview
*/
- (BOOL)sendAudioSamplesToCapturePreview:(CMSampleBufferRef)data;

/*! \cond */
- (BOOL)startCapturePreviewForLiveStreaming:(unsigned int)captureDeviceIndex
                              videoResGrade:(NvsVideoCaptureResolutionGrade)videoResGrade
                                      flags:(int)flags
                                aspectRatio:(const NvsRational *)aspectRatio
                      liveStreamingEndPoint:(NSString *)liveStreamingEndPoint;
/*! \endcond */

/*! \if ENGLISH
 *  \brief Gets the capture preview resolution.
 *  \param catpureDeviceIndex Index of capturing device
 *  \return Gets the capture preview resolution.
 *  \else
 *  \brief 获取采集预览视频分辨率
 *  \param catpureDeviceIndex 采集设备索引
 *  \return 获取采集预览视频分辨率
 *  \endif
 *  \since 1.7.1
*/
- (NvsSize)getCapturePreviewVideoSize:(unsigned int)catpureDeviceIndex;

/*! \if ENGLISH
 *  \brief Samples the capture device's video frame
 *  \param sampleRect Rectangular area to sample, of which coordinates are in livewindow's coordinate system
 *  \return Returns the NvsColor object. This color value is the average color value of all pixels in sampled rectangular area.
 *  \else
 *  \brief 对采集设备的视频帧内容进行采样
 *  \param sampleRect 采样的矩形区域，坐标为实时预览窗口的自身坐标系
 *  \return 返回值为采样的颜色值，该颜色值是采样的矩形区域内所有像素颜色的平均值
 *  \endif
 *  \since 1.2.0
*/
- (NvsColor)sampleColorFromCapturedVideoFrame:(CGRect)sampleRect;

/*! \if ENGLISH
 *  \brief Starts autofocus.
 *  \param focusPointOfInterest The target area for autofocus, of which coordinates are in live-window's coordinate system
 *  \else
 *  \brief 启动自动聚焦
 *  \param focusPointOfInterest 自动聚焦的目标点，坐标为实时预览窗口的自身坐标系
 *  \endif
 *  \sa cancelAutoFocus
*/
- (void)startAutoFocus:(CGPoint)focusPointOfInterest;

/*! \if ENGLISH
 *  \brief Cancels the ongoing autofocus
 *  \else
 *  \brief 取消正在进行中的自动聚焦
 *  \endif
 *  \sa startAutoFocus:
*/
- (void)cancelAutoFocus;

/*! \if ENGLISH
 *  \brief Starts continuous focus.
 *  \else
 *  \brief 启动连续聚焦
 *  \endif
*/
- (void)startContinuousFocus;

/*! \if ENGLISH
 *  \brief Starts automatic exposure adjustment.
 *  \param pointOfInterest Exposure adjustment point
 *  \else
 *  \brief 启动自动曝光调节
 *  \param pointOfInterest 曝光调节点
 *  \endif
*/
- (void)startAutoExposure:(CGPoint)pointOfInterest;

/*! \if ENGLISH
 *  \brief Sets the zoom factor.
 *  \param zoomFactor Zoom ratio
 *  \else
 *  \brief 设置缩放因子
 *  \param zoomFactor 缩放比例,取值范围可从getCaptureDeviceCapability接口查询
 *  \endif
 *  \sa getZoomFactor
*/
- (void)setZoomFactor:(float)zoomFactor;

/*! \if ENGLISH
 *  \brief Gets the zoom factor.
 *  \return Returns zoom factor value.
 *  \else
 *  \brief 获取缩放因子
 *  \return 返回缩放因子值
 *  \endif
 *  \sa setZoomFactor:
*/
- (float)getZoomFactor;

/*! \if ENGLISH
 *  \brief Sets which the flash light is on/off.
 *  \param on whether the flash light is on or not
 *  \else
 *  \brief 开/关换补光灯
 *  \param on 闪光灯是否开或关
 *  \endif
 *  \sa isFlashOn
*/
- (void)toggleFlash:(BOOL)on;

/*! \if ENGLISH
 *  \brief get state of the flash light.
 *  \return Returns a BOOL value, true means flash light is on and false means off.
 *  \else
 *  \brief 开/关换补光灯状态
 *  \return 返回BOOL值。返回YES则换补光灯是打开状态，NO则是关闭状态。
 *  \endif
 *  \sa toggleFlash:
*/
- (BOOL)isFlashOn;

/*! \if ENGLISH
 *  \brief Sets the flash mode.
 *  \param mode flash mode value, please refer to [Flash Mode](@ref CAMERA_FLASH_MODE)
 *  \else
 *  \brief 切换闪光灯模式
 *  \param mode 闪光灯模式值。请参见[闪光灯模式](@ref CAMERA_FLASH_MODE)。
 *  \endif
 *  \sa getFlashMode
*/
- (void)toggleFlashMode:(NvsCameraFlashMode)mode;

/*! \if ENGLISH
 *  \brief get state of the flash light.
 *  \return Returns flash mode value, please refer to [Flash Mode](@ref CAMERA_FLASH_MODE)
 *  \else
 *  \brief 获取当前闪光灯模式
 *  \return 闪光灯模式值。请参见[闪光灯模式](@ref CAMERA_FLASH_MODE)。
 *  \endif
 *  \sa toggleFlashMode
*/
- (NvsCameraFlashMode)getFlashMode;

/*! \if ENGLISH
 *  \brief Gets the current video’s stabilization flag.
 *  \return Returns the current flag.
 *  \else
 *  \brief 获取当前的视频防抖动标志
 *  \return 返回当前标志.
 *  \endif
 *  \sa setVideoStabilization:
*/
- (VideoStabilizationFlag)getVideoStabilization;

/*! \if ENGLISH
 *  \brief Sets video stabilization.
 *  \param flags Video stabilization value
 *  \else
 *  \brief 设置视频防抖动
 *  \param flags 视频防抖动值
 *  \endif
 *  \sa getVideoStabilization
*/
- (void)setVideoStabilization:(VideoStabilizationFlag)flags;

/*! \if ENGLISH
 *  \brief Set exposure compensation.
 *  \param exposureBias Exposure compensation value
 *  \else
 *  \brief 设置曝光补偿
 *  \param exposureBias 曝光补偿值,取值范围可从getCaptureDeviceCapability接口查询
 *  \endif
 *  \sa getExposureBias
*/
- (void)setExposureBias:(float)exposureBias;

/*! \if ENGLISH
 *  \brief Gets exposure compensation.
 *  \return Returns exposure compensation value
 *  \else
 *  \brief 获取曝光补偿
 *  \return 返回曝光补偿值
 *  \endif
 *  \sa setExposureBias:
*/
- (float)getExposureBias;

/*! \if ENGLISH
 *  \brief Appends a built-in capture video effect.
 *  \param videoFxName Video effect name. To get the video effect name, please refer to [getAllBuiltinCaptureVideoFxNames()] (@ref getAllBuiltinCaptureVideoFxNames) or [The List of Built-in Effect Name] (\ref FxNameList.md).
 *  \return Returns the appended NvsCaptureVideoFx object.
 *  \else
 *  \brief 追加一个内建视频特效
 *  \param videoFxName 视频特效名。获取视频特效名称，请参见[getAllBuiltinCaptureVideoFxNames()] (@ref getAllBuiltinCaptureVideoFxNames)或[内建特效名称列表] (\ref FxNameList.md)。
 *  \return 返回追加的内建视频特效对象
 *  \endif
 *  \sa insertBuiltinCaptureVideoFx:withInsertPosition:
*/
- (NvsCaptureVideoFx *)appendBuiltinCaptureVideoFx:(NSString *)videoFxName;

/*! \if ENGLISH
 *  \brief Inserts a built-in video capture effect.
 *  \param videoFxName Video effect name. To get the video effect name, please refer to [getAllBuiltinCaptureVideoFxNames()] (@ref getAllBuiltinCaptureVideoFxNames) or [The List of Built-in Effect Name] (\ref FxNameList.md).
 *  \param insertPosition Insertion position.
 *  \return Returns the inserted NvsCaptureVideoFx object.
 *  \else
 *  \brief 插入一个内建视频特效
 *  \param videoFxName 视频特效名。获取视频特效名称，请参见[getAllBuiltinCaptureVideoFxNames()] (@ref getAllBuiltinCaptureVideoFxNames)或[内建特效名称列表] (\ref FxNameList.md)。
 *  \param insertPosition 插入位置，是指特效的渲染顺序
 *  \return 返回插入的内建视频特效对象
 *  \endif
 *  \sa appendBuiltinCaptureVideoFx:
*/
- (NvsCaptureVideoFx *)insertBuiltinCaptureVideoFx:(NSString *)videoFxName withInsertPosition:(unsigned int)insertPosition;

/*! \if ENGLISH
 *  \brief Appends a package capture effectx.
 *  \param videoFxPackageId Video effect package ID
 *  \return Returns the appended NvsCaptureVideoFx object.
 *  \else
 *  \brief 追加一个包裹视频特效
 *  \param videoFxPackageId 视频特效包裹ID
 *  \return 返回追加的包裹视频特效对象
 *  \endif
 *  \sa insertPackagedCaptureVideoFx:withInsertPosition:
*/
- (NvsCaptureVideoFx *)appendPackagedCaptureVideoFx:(NSString *)videoFxPackageId;

/*! \if ENGLISH
 *  \brief Inserts a package capture effect.
 *  \param videoFxPackageId Video effect package ID
 *  \param insertPosition Insertion position
 *  \return Returns the inserted NvsCaptureVideoFx object.
 *  \else
 *  \brief 插入一个包裹视频特效
 *  \param videoFxPackageId 视频特效包裹ID
 *  \param insertPosition 插入位置，是指特效的渲染顺序
 *  \return 返回插入的包裹视频特效对象
 *  \endif
 *  \sa appendPackagedCaptureVideoFx:
*/
- (NvsCaptureVideoFx *)insertPackagedCaptureVideoFx:(NSString *)videoFxPackageId withInsertPosition:(unsigned int)insertPosition;

/*! \if ENGLISH
 *  \brief Appends a custom capture video effect.
 *  \param customVideoFxRender Interface of user-implemented custom video effect renderer
 *  \return Returns the appended NvsCaptureVideoFx object.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 追加自定义采集视频特效
 *  \param customVideoFxRender 用户实现的自定义视频特效渲染器接口
 *  \return 返回追加的采集视频特效对象
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \since 1.7.0
*/
- (NvsCaptureVideoFx *)appendCustomCaptureVideoFx:(id<NvsCustomVideoFxRenderer>)customVideoFxRender;

/*! \if ENGLISH
 *  \brief Inserts a custom capture video effect.
 *  \param customVideoFxRender Interface of user-implemented custom video effect renderer
 *  \param insertPosition Insertion position
 *  \return Returns the inserted NvsCaptureVideoFx object.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 插入自定义采集视频特效
 *  \param customVideoFxRender 用户实现的自定义视频特效渲染器接口
 *  \param insertPosition 插入位置，是指特效的渲染顺序
 *  \return 返回插入的采集视频特效对象
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \since 1.7.0
*/
- (NvsCaptureVideoFx *)insertCustomCaptureVideoFx:(id<NvsCustomVideoFxRenderer>)customVideoFxRender withInsertPosition:(int)insertPosition;

/*! \if ENGLISH
 *  \brief Appends a beauty effect.
 *  \return Returns the Appended NvsCaptureVideoFx object.
 *  \else
 *  \brief 追加一个美颜视频特效
 *  \return 返回追加的美颜视频特效对象
 *  \endif
 *  \sa insertBeautyCaptureVideoFx:
*/
- (NvsCaptureVideoFx *)appendBeautyCaptureVideoFx;

/*! \if ENGLISH
 *  \brief Inserts a skin beauty video effect.
 *  \param insertPosition Insertion position
 *  \return Returns the inserted NvsCaptureVideoFx object.
 *  \else
 *  \brief 插入一个美颜视频特效
 *  \param insertPosition 插入位置，是指特效的渲染顺序
 *  \return 返回插入的美颜视频特效对象
 *  \endif
 *  \sa appendBeautyCaptureVideoFx:
*/
- (NvsCaptureVideoFx *)insertBeautyCaptureVideoFx:(unsigned int)insertPosition;

/*! \if ENGLISH
 *  \brief Removes a certain capture video effect indicated by its index
 *  \param captureVideoFxIndex Video effect index
 *  \return Returns a BOOL value. If it is YES, the removal is successful, and NO means failure.
 *  \else
 *  \brief 对移除特定索引值的采集视频特效
 *  \param captureVideoFxIndex 视频特效索引
 *  \return 返回BOOL值。返回YES则移除成功，NO则失败
 *  \endif
 *  \sa appendBuiltinCaptureVideoFx:
 *  \sa appendPackagedCaptureVideoFx:
 *  \sa appendBeautyCaptureVideoFx
*/
- (BOOL)removeCaptureVideoFx:(unsigned int)captureVideoFxIndex;

/*! \if ENGLISH
 *  \brief Removes all capture video effects.
 *  \else
 *  \brief 移除所有采集视频特效
 *  \endif
 *  \sa removeCaptureVideoFx:
 *  \sa getCaptureVideoFxCount
*/
- (void)removeAllCaptureVideoFx;

/*! \if ENGLISH
 *  \brief Gets the count of video effects.
 *  \return Returns the count of video effects.
 *  \else
 *  \brief 获得采集视频特效的数量
 *  \return 返回视频特效数量
 *  \endif
*/
- (unsigned int)getCaptureVideoFxCount;

/*! \if ENGLISH
 *  \brief Gets a certain capture video effect
 *  \param captureVideoFxIndex Video effect index
 *  \return Returns the NvsCaptureVideoFx object.
 *  \else
 *  \brief 获得采集视频特效
 *  \param captureVideoFxIndex 视频特效索引
 *  \return 返回视频特效对象
 *  \endif
 *  \sa removeCaptureVideoFx:
*/
- (NvsCaptureVideoFx *)getCaptureVideoFxByIndex:(unsigned int)captureVideoFxIndex;

/*! \if ENGLISH
 *  \brief Appends a built-in capture audio effect.
 *  \param audioFxName audio effect name. To get the audio effect name, please refer to [getAllBuiltinCaptureAudioFxNames()] (@ref getAllBuiltinCaptureAudioFxNames) or [The List of Built-in Effect Name] (\ref FxNameList.md).
 *  \return Returns the appended NvsCaptureAudioFx object.
 *  \else
 *  \brief 追加一个内建音频特效
 *  \param audioFxName 音频特效名。获取音频特效名称，请参见[getAllBuiltinCaptureAudioFxNames()] (@ref getAllBuiltinCaptureAudioFxNames)或[内建特效名称列表] (\ref FxNameList.md)。
 *  \return 返回追加的内建音频特效对象
 *  \endif
 *  \sa insertBuiltinCaptureVideoFx
 *  \since 2.21.0
*/
- (NvsCaptureAudioFx *)appendBuiltinCaptureAudioFx:(NSString *)audioFxName;

/*! \if ENGLISH
 *  \brief Inserts a built-in audio capture effect.
 *  \param audioFxName audio effect name. To get the audio effect name, please refer to [getAllBuiltinCaptureAudioFxNames()] (@ref getAllBuiltinCaptureAudioFxNames) or [The List of Built-in Effect Name] (\ref FxNameList.md).
 *  \param insertPosition Insertion position.
 *  \return Returns the inserted NvsCaptureVideoFx object.
 *  \else
 *  \brief 插入一个内建音频特效
 *  \param audioFxName 音频特效名。获取音频特效名称，请参见[getAllBuiltinCaptureAudioFxNames()] (@ref getAllBuiltinCaptureAudioFxNames)或[内建特效名称列表] (\ref FxNameList.md)。
 *  \param insertPosition 插入位置，是指特效的渲染顺序
 *  \return 返回插入的内建音频特效对象
 *  \endif
 *  \sa appendBuiltinCaptureAudioFx
 *  \since 2.21.0
*/
- (NvsCaptureAudioFx *)insertBuiltinCaptureAudioFx:(NSString *)audioFxName withInsertPosition:(unsigned int)insertPosition;

/*! \if ENGLISH
 *  \brief Removes a certain capture audio effect indicated by its index
 *  \param captureAudioFxIndex audio effect index
 *  \return Returns a boolean value. If it is YES, the removal is successful, and NO means failure.
 *  \else
 *  \brief 对移除特定索引值的采集音频特效
 *  \param captureVideoFxIndex 音频特效索引
 *  \return 返回boolean值。返回YES则移除成功，NO则失败
 *  \endif
 *  \sa appendBuiltinCaptureAudioFx
 *  \since 2.21.0
*/
- (BOOL)removeCaptureAudioFx:(unsigned int)captureAudioFxIndex;

/*! \if ENGLISH
 *  \brief Removes all capture audio effects.
 *  \else
 *  \brief 移除所有采集视频特效
 *  \endif
 *  \sa removeCaptureAudioFx
 *  \sa getCaptureAudioFxCount
 *  \since 2.21.0
*/
- (void)removeAllCaptureAudioFx;

/*! \if ENGLISH
 *  \brief Gets the count of audio effects.
 *  \return Returns the count of audio effects.
 *  \else
 *  \brief 获得采集音频特效的数量
 *  \return 返回音频特效数量
 *  \endif
 *  \since 2.21.0
*/
- (unsigned int)getCaptureAudioFxCount;

/*! \if ENGLISH
 *  \brief Gets a certain capture audio effect
 *  \param captureVideoFxIndex audio effect index
 *  \return Returns the NvsCaptureAudioFx object.
 *  \else
 *  \brief 获得采集音频特效
 *  \param captureAudioFxIndex 音频特效索引
 *  \return 返回音频特效对象
 *  \endif
 *  \sa removeCaptureAudioFx
 *  \since 2.21.0
*/
- (NvsCaptureAudioFx *)getCaptureAudioFxByIndex:(unsigned int)captureAudioFxIndex;

/*! \if ENGLISH
 *  \brief Appends a animated sticker.
 *  \param offsetTime animated sticker's offset time.
 *  \param duration animated sticker's duration.
 *  \param animatedStickerPackageId Animated sticker package Id.
 *  \return Returns the appended NvsCaptureAnimatedSticker object.
 *  <br>It will return null in the following situations:
 *  <br>1. No animated sticker function authorization;
 *  <br>2. The animatedStickerPackageId is empty or null;
 *  <br>3. The animatedSticker has not install successed;
 *  \else
 *  \brief 追加一个动画贴纸
 *  \param offsetTime 动画贴纸的偏移时间。
 *  \param duration 动画贴纸的持续时间。
 *  \param animatedStickerPackageId 动画贴纸包Id。
 *  \return 返回采集动画贴纸对象
 *  <br>以下情况会返回null：
 *  <br>1.没有动画贴纸功能授权；
 *  <br>2.animatedStickerPackageId参数为空字符串或者null；
 *  <br>3.该动画贴纸包没有安装成功；
 *  \endif
 *  \sa insertCaptureAnimatedSticker
 *  \since 2.21.0
*/
- (NvsCaptureAnimatedSticker *)appendCaptureAnimatedSticker:(int64_t)offsetTime duration:(int64_t)duration animatedStickerPackageId:(NSString *)animatedStickerPackageId;

/*! \if ENGLISH
 *  \brief Appends a animated sticker.
 *  \param offsetTime animated sticker's offset time.
 *  \param duration animated sticker's duration.
 *  \param animatedStickerPackageId Animated sticker package Id.
 *  \param insertPosition Insertion position.
 *  \return Returns the appended NvsCaptureAnimatedSticker object.
 *  <br>It will return null in the following situations:
 *  <br>1. No animated sticker function authorization;
 *  <br>2. The animatedStickerPackageId is empty or null;
 *  <br>3. The animatedSticker has not install successed;
 *  \else
 *  \brief 追加一个动画贴纸
 *  \param offsetTime 动画贴纸的偏移时间。
 *  \param duration 动画贴纸的持续时间。
 *  \param animatedStickerPackageId 动画贴纸包Id。
 *  \param insertPosition 插入位置.
 *  \return 返回采集动画贴纸对象
 *  <br>以下情况会返回null：
 *  <br>1.没有动画贴纸功能授权；
 *  <br>2.animatedStickerPackageId参数为空字符串或者null；
 *  <br>3.该动画贴纸包没有安装成功；
 *  \endif
 *  \sa appendCaptureAnimatedSticker
 *  \since 2.21.0
*/
- (NvsCaptureAnimatedSticker *)insertCaptureAnimatedSticker:(int64_t)offsetTime duration:(int64_t)duration animatedStickerPackageId:(NSString *)animatedStickerPackageId insertPosition:(unsigned int)insertPosition;

/*! \if ENGLISH
 *  \brief Add a custom animated sticker on capture.
 *  \param inPoint The in point of custom animated sticker on the timeline (in microseconds)
 *  \param duration The duration of custom animation sticker which displayed (in microseconds)
 *  \param animatedStickerPackageId Animated sticker package Id
 *  \param customImagePath Path of custom animated sticker image(It can be a jpg, png image, or a dynamic caf format image supported by Meishe sdk)
 *  \return Return the NvsCaptureAnimatedSticker object.
 *  <br>It will return nil in the following situations:
 *  <br>1. No animated sticker function authorization;
 *  <br>2. The animatedStickerPackageId is empty or nil;
 *  <br>3. The animatedSticker has not install successed;
 *  <br>4. If inPoint is less than 0, or duration is not greater than 0.
 *  <br>Note: If the return value is not nil, you still cannot see the sticker effect, you need to check whether the customImagePath actually exists.
 *  \else
 *  \brief 在拍摄上添加自定义动画贴纸
 *  \param inPoint 自定义动画贴纸在时间线上的入点（单位微秒）
 *  \param duration 自定义动画贴纸的显示时长（单位微秒）
 *  \param animatedStickerPackageId 自定义动画贴纸包Id
 *  \param customImagePath 自定义动画贴纸图像路径（可以是jpg、png图像，或者美摄sdk内部支持的动态caf格式图像）
 *  \return 返回拍摄自定义动画贴纸对象
 *  <br>以下情况会返回nil：
 *  <br>1.没有动画贴纸功能授权；
 *  <br>2.animatedStickerPackageId参数为空字符串或者nil；
 *  <br>3.该动画贴纸包没有安装成功；
 *  <br>4.如果inPoint小于0，或者duration不大于0。
 *  <br>注意：如果返回值非空，依旧看不到贴纸效果，需要检查customImagePath是否真实存在
 *  \endif
 *  \sa removeCaptureAnimatedSticker:
 *  \since 3.2.0
*/
- (NvsCaptureAnimatedSticker *)addCustomCaptureAnimatedSticker:(int64_t)inPoint duration:(int64_t)duration animatedStickerPackageId:(NSString *)animatedStickerPackageId customImagePath:(NSString *)customImagePath;

/*! \if ENGLISH
 *  \brief Insert a animated sticker.
 *  \param offsetTime animated sticker's offset time.
 *  \param duration animated sticker's duration.
 *  \param animatedStickerPackageId Animated sticker package Id.
 *  \param customImagePath Path of custom animated sticker image(It can be a jpg, png image, or a dynamic caf format image supported by Meishe sdk)
 *  \param insertPosition Insertion position.
 *  \return Returns the appended NvsCaptureAnimatedSticker object.
 *  <br>It will return null in the following situations:
 *  <br>1. No animated sticker function authorization;
 *  <br>2. The animatedStickerPackageId is empty or null;
 *  <br>3. The animatedSticker has not install successed;
 *  \else
 *  \brief 插入一个动画贴纸
 *  \param offsetTime 动画贴纸的偏移时间。
 *  \param duration 动画贴纸的持续时间。
 *  \param animatedStickerPackageId 动画贴纸包Id。
 *  \param customImagePath 自定义动画贴纸图像路径（可以是jpg、png图像，或者美摄sdk内部支持的动态caf格式图像）
 *  \param insertPosition 插入位置.
 *  \return 返回采集动画贴纸对象
 *  <br>以下情况会返回null：
 *  <br>1.没有动画贴纸功能授权；
 *  <br>2.animatedStickerPackageId参数为空字符串或者null；
 *  <br>3.该动画贴纸包没有安装成功；
 *  \endif
 *  \sa appendCaptureAnimatedSticker
 *  \since 3.2.0
*/
- (NvsCaptureAnimatedSticker *)insertCustomCaptureAnimatedSticker:(int64_t)offsetTime duration:(int64_t)duration animatedStickerPackageId:(NSString *)animatedStickerPackageId customImagePath:(NSString *)customImagePath insertPosition:(unsigned int)insertPosition;

/*! \if ENGLISH
 *  \brief Removes a certain capture animated sticker indicated by its index
 *  \param captureAnimagedStickerIndex animated sticker index
 *  \return Returns a boolean value. If it is YES, the removal is successful, and NO means failure.
 *  \else
 *  \brief 对移除特定索引值的采集动画贴纸
 *  \param captureVideoFxIndex 动画贴纸索引
 *  \return 返回boolean值。返回YES则移除成功，NO则失败
 *  \endif
 *  \sa appendCaptureAnimatedSticker
 *  \since 2.21.0
*/
- (BOOL)removeCaptureAnimatedSticker:(unsigned int)captureAnimagedStickerIndex;

/*! \if ENGLISH
 *  \brief Removes all capture animated sticker.
 *  \else
 *  \brief 移除所有采集动画贴纸
 *  \endif
 *  \sa removeCaptureAnimatedSticker
 *  \sa getCaptureAnimatedStickerCount
 *  \since 2.21.0
*/
- (void)removeAllCaptureAnimatedSticker;

/*! \if ENGLISH
 *  \brief Gets the count of capture animated sticker.
 *  \return Returns the count of capture animated sticker.
 *  \else
 *  \brief 获得采集动画贴纸的数量
 *  \return 返回动画贴纸数量
 *  \endif
 *  \since 2.21.0
*/
- (unsigned int)getCaptureAnimatedStickerCount;

/*! \if ENGLISH
 *  \brief Gets a certain capture animated sticker
 *  \param captureStikcerIndex audio effect index
 *  \return Returns the NvsCaptureAudioFx object.
 *  \else
 *  \brief 获得采集动画贴纸
 *  \param captureStikcerIndex 动画贴纸索引
 *  \return 返回动画贴纸对象
 *  \endif
 *  \sa removeCaptureAnimatedSticker
 *  \since 2.21.0
*/
- (NvsCaptureAnimatedSticker *)getCaptureAnimatedStickerByIndex:(unsigned int)captureStikcerIndex;

/*! \if ENGLISH
 *  \brief Appends a compound caption.
 *  \param offsetTime compound catpion's offset time.
 *  \param duration compound catpion's duration.
 *  \param compoundCaptionPackageId Caption style package Id.If it does not exist, you can pass an empty string or null.
 *  \return Returns the appended NvsCaptureCompoundCaption object.
 *  <br>It will return null in the following situations:
 *  <br>1. No compound caption function authorization;
 *  \else
 *  \brief 追加一个复合字幕
 *  \param offsetTime 复合字幕的偏移时间。
 *  \param duration 复合字幕的持续时间。
 *  \param compoundCaptionPackageId 复合字幕包Id。
 *  \return 返回采集复合字幕对象
 *  <br>以下情况会返回null：
 *  <br>1.没有复合字幕功能授权；
 *  \endif
 *  \sa insertCaptureCompoundCaption
 *  \since 2.21.0
*/
- (NvsCaptureCompoundCaption *)appendCaptureCompoundCaption:(int64_t)offsetTime duration:(int64_t)duration compoundCaptionPackageId:(NSString *)compoundCaptionPackageId;

/*! \if ENGLISH
*  \brief Insert a compound caption.
*  \param offsetTime compound catpion's offset time.
*  \param duration compound catpion's duration.
*  \param compoundCaptionPackageId Caption style package Id.If it does not exist, you can pass an empty string or null.
*  \param insertPosition Insertion position.
*  \return Returns the appended NvsCaptureCompoundCaption object.
*  <br>It will return null in the following situations:
*  <br>1. No compound caption function authorization;
*  \else
*  \brief 插入一个复合字幕
*  \param offsetTime 复合字幕的偏移时间。
*  \param duration 复合字幕的持续时间。
*  \param compoundCaptionPackageId 复合字幕包Id。
*  \param insertPosition 插入位置.
*  \return 返回采集复合字幕对象
*  <br>以下情况会返回null：
*  <br>1.没有复合字幕功能授权；
*  \endif
*  \sa appendCaptureCompoundCaption
*  \since 2.21.0
*/
- (NvsCaptureCompoundCaption *)insertCaptureCompoundCaption:(int64_t)offsetTime duration:(int64_t)duration compoundCaptionPackageId:(NSString *)compoundCaptionPackageId insertPosition:(unsigned int)insertPosition;

/*! \if ENGLISH
*  \brief Removes a certain capture compound caption indicated by its index
*  \param captureCompoundCaptionIndex compound caption index
*  \return Returns a boolean value. If it is YES, the removal is successful, and NO means failure.
*  \else
*  \brief 对移除特定索引值的采集复合字幕
*  \param captureCompoundCaptionIndex 复合字幕索引
*  \return 返回boolean值。返回YES则移除成功，NO则失败
*  \endif
*  \since 2.21.0
*/
-(BOOL)removeCaptureCompoundCaption:(unsigned int)captureCompoundCaptionIndex;

/*! \if ENGLISH
*  \brief Removes all capture compound caption.
*  \else
*  \brief 移除所有采集复合字幕
*  \endif
*  \since 2.21.0
*/
- (void)removeAllCaptureCompoundCaption;

/*! \if ENGLISH
*  \brief Gets the count of capture compound caption.
*  \return Returns the count of capture compound caption.
*  \else
*  \brief 获得采集复合字幕的数量
*  \return 返回复合字幕数量
*  \endif
*  \since 2.21.0
*/
- (unsigned int)getCaptureCompoundCaptionCount;

/*! \if ENGLISH
*  \brief Gets a certain capture compound caption
*  \param captureCaptionIndex compound caption index
*  \return Returns the NvsCaptureCompoundCaption object.
*  \else
*  \brief 获得采集复合字幕
*  \param captureStikcerIndex 复合字幕索引
*  \return 返回复合字幕对象
*  \endif
*  \since 2.21.0
*/
- (NvsCaptureCompoundCaption *)getCaptureCompoundCaptionByIndex:(unsigned int)captureCaptionIndex;

/*! \if ENGLISH
 *  \brief Appends a caption.
 *  \param captionText Text of caption
 *  \param offsetTime catpion's offset time.
 *  \param duration catpion's duration.
 *  \param captionStylePackageId Caption style package Id.If it does not exist, you can pass an empty string or null.
 *  \return Returns the appended NvsCaptureCaption object.
 *  <br>It will return null in the following situations:
 *  <br>1. No compound caption function authorization;
 *  \else
 *  \brief 追加一个字幕
 *  \param captionText 字幕的文字
 *  \param offsetTime 字幕的偏移时间。
 *  \param duration 字幕的持续时间。
 *  \param captionStylePackageId 字幕样式包Id，不存在的话，可以传空字符串或者null
 *  \return 返回采集字幕对象
 *  <br>以下情况会返回null：
 *  <br>1.没有复合字幕功能授权；
 *  \endif
 *  \sa insertCaptureCompoundCaption
 *  \since 2.21.0
*/
- (NvsCaptureCaption *)appendCaptureCaption:(NSString *)captionText offsetTime:(int64_t)offsetTime duration:(int64_t)duration captionStylePackageId:(NSString *)captionStylePackageId;

/*! \if ENGLISH
*  \brief Insert a caption.
*  \param captionText Text of caption
*  \param offsetTime catpion's offset time.
*  \param duration catpion's duration.
*  \param captionStylePackageId Caption style package Id.If it does not exist, you can pass an empty string or null.
*  \param insertPosition Insertion position.
*  \return Returns the appended NvsCaptureCompoundCaption object.
*  <br>It will return null in the following situations:
*  <br>1. No caption function authorization;
*  \else
*  \brief 插入一个字幕
*  \param captionText 字幕的文字
*  \param offsetTime 字幕的偏移时间。
*  \param duration 字幕的持续时间。
*  \param captionStylePackageId 字幕样式包Id，不存在的话，可以传空字符串或者null
*  \param insertPosition 插入位置.
*  \return 返回采集字幕对象
*  <br>以下情况会返回null：
*  <br>1.没有复合字幕功能授权；
*  \endif
*  \sa appendCaptureCompoundCaption
*  \since 2.21.0
*/
- (NvsCaptureCaption *)insertCaptureCaption:(NSString *)captionText offsetTime:(int64_t)offsetTime duration:(int64_t)duration captionStylePackageId:(NSString *)captionStylePackageId insertPosition:(unsigned int)insertPosition;

/*! \if ENGLISH
 *  \brief Appends a modular caption.
 *  \param captionText Text of caption
 *  \param offsetTime catpion's offset time.
 *  \param duration catpion's duration.
 *  \return Returns the appended NvsCaptureCaption object.
 *  <br>It will return null in the following situations:
 *  <br>1. No compound caption function authorization;
 *  \else
 *  \brief 追加一个模块字幕
 *  \param captionText 字幕的文字
 *  \param offsetTime 字幕的偏移时间。
 *  \param duration 字幕的持续时间。
 *  \return 返回采集字幕对象
 *  <br>以下情况会返回null：
 *  <br>1.没有复合字幕功能授权；
 *  \endif
 *  \sa insertCaptureCompoundCaption
 *  \since 2.21.0
*/
- (NvsCaptureCaption *)appendCaptureModularCaption:(NSString *)captionText offsetTime:(int64_t)offsetTime duration:(int64_t)duration;

/*! \if ENGLISH
*  \brief Insert a modular caption.
*  \param captionText Text of caption
*  \param offsetTime catpion's offset time.
*  \param duration catpion's duration.
*  \param insertPosition Insertion position.
*  \return Returns the appended NvsCaptureCompoundCaption object.
*  <br>It will return null in the following situations:
*  <br>1. No caption function authorization;
*  \else
*  \brief 插入一个模块字幕
*  \param captionText 字幕的文字
*  \param offsetTime 字幕的偏移时间。
*  \param duration 字幕的持续时间。
*  \param insertPosition 插入位置.
*  \return 返回采集字幕对象
*  <br>以下情况会返回null：
*  <br>1.没有复合字幕功能授权；
*  \endif
*  \sa appendCaptureCompoundCaption
*  \since 2.21.0
*/
- (NvsCaptureCaption *)insertCaptureModularCaption:(NSString *)captionText offsetTime:(int64_t)offsetTime duration:(int64_t)duration insertPosition:(unsigned int)insertPosition;

/*! \if ENGLISH
*  \brief Removes a certain capture caption indicated by its index
*  \param captureCaptionIndex caption index
*  \return Returns a boolean value. If it is YES, the removal is successful, and NO means failure.
*  \else
*  \brief 对移除特定索引值的采集字幕
*  \param captureCompoundCaptionIndex 字幕贴纸索引
*  \return 返回boolean值。返回YES则移除成功，NO则失败
*  \endif
*  \since 2.21.0
*/
- (BOOL)removeCaptureCaption:(unsigned int)captureCaptionIndex;

/*! \if ENGLISH
*  \brief Removes all capture caption.
*  \else
*  \brief 移除所有采集字幕
*  \endif
*  \since 2.21.0
*/
- (void)removeAllCaptureCaption;

/*! \if ENGLISH
*  \brief Gets the count of capture caption.
*  \return Returns the count of capture caption.
*  \else
*  \brief 获得采集字幕的数量
*  \return 返回字幕数量
*  \endif
*  \since 2.21.0
*/
- (unsigned int)getCaptureCaptionCount;

/*! \if ENGLISH
*  \brief Gets a certain capture caption
*  \param captureCaptionIndex caption index
*  \return Returns the NvsCaptureCaption object.
*  \else
*  \brief 获得采集字幕
*  \param captureStikcerIndex 字幕索引
*  \return 返回字幕对象
*  \endif
*  \since 2.21.0
*/
- (NvsCaptureCaption *)getCaptureCaptionByIndex:(unsigned int)captureCaptionIndex;

/*! \if ENGLISH
 *  \brief Apply a capture scene resource package to the capture device.
 *  \param captureSceneId The ID of capture scene resource package
 *  \return Returns a BOOL value. A value of YES will result in a successful application and NO means it fails to apply.
 *  \else
 *  \brief 对采集设备应用拍摄场景资源包
 *  \param captureSceneId 拍摄场景资源包的ID
 *  \return 返回BOOL值。值为YES则应用成功，NO则失败。
 *  \endif
 *  \since 1.2.0
 *  \sa getCurrentCaptureSceneId
 *  \sa removeCurrentCaptureScene
*/
- (BOOL)applyCaptureScene:(NSString *)captureSceneId;

/*! \if ENGLISH
 *  \brief Apply a capture scene resource package to the capture device.
 *  \param captureSceneId The ID of capture scene resource package
 *  \param info Resource information to be replaced
 *  \return Returns a BOOL value. A value of YES will result in a successful application and NO means it fails to apply.
 *  \else
 *  \brief 对采集设备应用拍摄场景资源包
 *  \param captureSceneId 拍摄场景资源包的ID
 *  \param info 待替换的资源信息
 *  \return 返回BOOL值。值为YES则应用成功，NO则失败。
 *  \endif
 *  \since 3.2.0
 *  \sa getCurrentCaptureSceneId
 *  \sa removeCurrentCaptureScene
*/
- (BOOL)applyCaptureScene:(NSString *)captureSceneId captureSceneInfo:(NvsCaptureSceneInfo*)info;

/*! \if ENGLISH
 *  \brief Gets the ID of the current capture scene resource package.
 *  \return Retruns the current ID of the capture scene resource package. nil indicates that there is no capture scene resource package for now.
 *  \else
 *  \brief 取得当前拍摄场景资源包的ID
 *  \return 当前拍摄场景资源包的ID字符串，返回nil表示当前没有拍摄场景资源包
 *  \endif
 *  \since 1.2.0
 *  \sa applyCaptureScene:
 *  \sa removeCurrentCaptureScene
*/
- (NSString *)getCurrentCaptureSceneId;

/*! \if ENGLISH
 *  \brief Removes the current capture scene.
 *  \else
 *  \brief 移除当前拍摄场景
 *  \endif
 *  \since 1.2.0
 *  \sa applyCaptureScene:
 *  \sa getCurrentCaptureSceneId
*/
- (void)removeCurrentCaptureScene;

/*! \if ENGLISH
 *  \brief Starts recording. Please refer to [Method of Recording Video](\ref videoRecorderMode.md).
 *  \param outputFilePath The path to the recording file. Note: .mov is recommended as the output format.
 *  \return Returns a BOOL value. Returning YES means it starts recording successfully, and NO means it fails to start.
 *  \else
 *  \brief 启动录制采集设备信号。请参见[视频录制方式] (\ref videoRecorderMode.md)
 *  \param outputFilePath 录制文件的路径。注意: 我们建议输出.mov格式的文件
 *  \return 返回BOOL值。返回YES则启动录制成功，NO则启动失败。
 *  \endif
 *  \sa stopRecording
*/
- (BOOL)startRecording:(NSString *)outputFilePath;

/*! \if ENGLISH
 *  \brief Starts recording. Please refer to [Method of Recording Video](\ref videoRecorderMode.md).
 *  \param outputFilePath The path to the recording file. Note: .mov is recommended as the output format.
 *  \param flags Flag field, if there is no special requirement, please fill in 0. Please refer to [NvsStreamingEngineRecordingFlag] (@ref NvsStreamingEngineRecordingFlag)
 *  \return Returns a BOOL value. Returning YES means it starts recording successfully, and NO means it fails to start.
 *  \else
 *  \brief 启动录制采集设备信号。请参见[视频录制方式] (\ref videoRecorderMode.md)
 *  \param outputFilePath 录制文件的路径。注意: 我们建议输出.mov格式的文件
 *  \param flags 标志字段，如无特殊需求请填写0。请参见 [NvsStreamingEngineRecordingFlag] (@ref NvsStreamingEngineRecordingFlag)
 *  \return 返回BOOL值。返回YES则启动录制成功，NO则启动失败。
 *  \endif
 *  \since 1.5.1
 *  \sa stopRecording
*/
- (BOOL)startRecording:(NSString *)outputFilePath withFlags:(int)flags;

/*! \if ENGLISH
 *  \brief Starts recording. Please refer to [Method of Recording Video](\ref videoRecorderMode.md).
 *  \param outputFilePath The path to the recording file. Note: .mov is recommended as the output format.
 *  \param flags Flag field, if there is no special requirement, please fill in 0. Please refer to [NvsStreamingEngineRecordingFlag] (@ref NvsStreamingEngineRecordingFlag)
 *  \param withRecordConfigurations Recording configuration. For the key values in NSMutableDictionary, please refer to [Recording Video Configuration](@ref RECORD_CONFIGURATIONS):
 *          <br>For instance：NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
 *              [config setValue:[NSNumber numberWithInteger:15] forKey:NVS_RECORD_GOP_SIZE]; // setting 1 means it will generate an I-frame video.
 *              [config setValue:[NSNumber numberWithInteger:10000000] forKey:NVS_RECORD_BITRATE]; // 10M bps
 *  \return Returns a BOOL value. Returning YES means it starts recording successfully, and NO means it fails to start.
 *  \else
 *  \brief 启动录制采集设备信号。请参见[视频录制方式] (\ref videoRecorderMode.md)
 *  \param outputFilePath 录制文件的路径。注意: 我们建议输出.mov格式的文件
 *  \param flags 标志字段，如无特殊需求请填写0。请参见 [NvsStreamingEngineRecordingFlag] (@ref NvsStreamingEngineRecordingFlag)
 *  \param withRecordConfigurations 录制视频配置。NSMutableDictionary中关键字的值请参见 [录制视频配置] (@ref RECORD_CONFIGURATIONS)
 *         <br>例如：NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
 *              [config setValue:[NSNumber numberWithInteger:15] forKey:NVS_RECORD_GOP_SIZE]; // 设置为1即是生成全I帧视频
 *              [config setValue:[NSNumber numberWithInteger:10000000] forKey:NVS_RECORD_BITRATE]; // 10M bps
 *  \return 返回BOOL值。返回YES则启动录制成功，NO则启动失败。
 *  \endif
 *  \since 1.16.0
 *  \sa stopRecording
*/
- (BOOL)startRecording:(NSString *)outputFilePath withFlags:(int)flags withRecordConfigurations:(NSMutableDictionary *)withRecordConfigurations;

/*! \if ENGLISH
 *  \brief Starts to record, and the recorded content contains all the special effects which applied.
 *
 *  Note: If the effect processed is too complicated, it may cause the recorded video to drop frames.
 *  Therefore, users must be careful when using this method. Make sure that the effects can be processed in real time for the current phone. Please refer to [Method of Recording  Video] (\ref videoRecorderMode.md).
 *  \param outputFilePath The path to the recording file. Note: .mov is recommended as the output format.
 *  \return Returns a BOOL value. Returning YES means it starts recording successfully, and NO means it fails to start.
 *  \else
 *  \brief 启动采集设备的录制，录制的内容包含所有的特效处理效果。
 *
 *  注意：如果特效处理过于复杂可能会导致录制的视频丢帧，所以使用这个方法一定要慎重，要确保特效的处理对于当前
 *  手机是完全可以实时处理的。请参见[视频录制方式] (\ref videoRecorderMode.md)
 *  \param outputFilePath 录制文件的路径。我们建议输出.mov格式的文件
 *  \return 返回BOOL值。返回YES则启动录制成功，NO则启动失败。
 *  \endif
 *  \sa stopRecording
*/
- (BOOL)startRecordingWithFx:(NSString *)outputFilePath;

/*! \if ENGLISH
 *  \brief Starts to record, and the recorded content contains all the special effects which applied.
 *
 *  Note: If the effect processed is too complicated, it may cause the recorded video to drop frames.
 *  Therefore, users must be careful when using this method. Make sure that the effects can be processed in real time for the current phone. Please refer to [Method of Recording  Video] (\ref videoRecorderMode.md).
 *  \param outputFilePath The path to the recording file. Note: .mov is recommended as the output format.
 *  \param flags Flag field, if there is no special requirement, please fill in 0. Please refer to [NvsStreamingEngineRecordingFlag] (@ref NvsStreamingEngineRecordingFlag)
 *  \return Returns a BOOL value. Returning YES means it starts recording successfully, and NO means it fails to start.
 *  \else
 *  \brief 启动采集设备的录制，录制的内容包含所有的特效处理效果。
 *
 *  注意：如果特效处理过于复杂可能会导致录制的视频丢帧，所以使用这个方法一定要慎重，要确保特效的处理对于当前
 *  手机是完全可以实时处理的。请参见[视频录制方式] (\ref videoRecorderMode.md)
 *  \param outputFilePath 录制文件的路径。我们建议输出.mov格式的文件
 *  \param flags 标志字段，如无特殊需求请填写0。请参见 [NvsStreamingEngineRecordingFlag] (@ref NvsStreamingEngineRecordingFlag)
 *  \return 返回BOOL值。返回YES则启动录制成功，NO则启动失败。
 *  \endif
 *  \since 1.5.1
 *  \sa stopRecording
*/
- (BOOL)startRecordingWithFx:(NSString *)outputFilePath withFlags:(int)flags;

/*! \if ENGLISH
 *  \brief Starts recording. Please refer to [Method of Recording Video](\ref videoRecorderMode.md).
 *  \param outputFilePath The path to the recording file. Note: .mov is recommended as the output format.
 *  \param flags Flag field, if there is no special requirement, please fill in 0. Please refer to [NvsStreamingEngineRecordingFlag] (@ref NvsStreamingEngineRecordingFlag)
 *  \param withRecordConfigurations Recording configuration. For the key values in NSMutableDictionary, please refer to [Recording Video Configuration](@ref RECORD_CONFIGURATIONS):
 *          <br>For instance：NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
 *              [config setValue:[NSNumber numberWithInteger:15] forKey:NVS_RECORD_GOP_SIZE]; // setting 1 means it will generate an I-frame video.
 *              [config setValue:[NSNumber numberWithInteger:10000000] forKey:NVS_RECORD_BITRATE]; // 10M bps
 *  \return Returns a BOOL value. Returning YES means it starts recording successfully, and NO means it fails to start.
 *  \else
 *  \brief 启动录制采集设备信号。请参见[视频录制方式] (\ref videoRecorderMode.md)
 *  \param outputFilePath 录制文件的路径。注意: 我们建议输出.mov格式的文件
 *  \param flags 标志字段，如无特殊需求请填写0。请参见 [NvsStreamingEngineRecordingFlag] (@ref NvsStreamingEngineRecordingFlag)
 *  \param withRecordConfigurations 录制视频配置。NSMutableDictionary中关键字的值请参见 [录制视频配置] (@ref RECORD_CONFIGURATIONS)
 *         例如：NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
 *              [config setValue:[NSNumber numberWithInteger:15] forKey:NVS_RECORD_GOP_SIZE]; // 设置为1即是生成全I帧视频
 *              [config setValue:[NSNumber numberWithInteger:10000000] forKey:NVS_RECORD_BITRATE]; // 10M bps
 *  \return 返回BOOL值。返回YES则启动录制成功，NO则启动失败。
 *  \endif
 *  \since 1.16.0
 *  \sa stopRecording
*/
- (BOOL)startRecordingWithFx:(NSString *)outputFilePath withFlags:(int)flags withRecordConfigurations:(NSMutableDictionary *)withRecordConfigurations;

/*! \if ENGLISH
 *  \brief Set audio sample information for callback of capturing
 *  \param info audio sample information
 *  \else
 *  \brief 设置需要回调的采集音频信息
 *  \param info 采集音频信息
 *  \endif
 */
- (void)setAudioSampleInfoForCallback:(NvsCapturedAudioSampleInfo*)info;

/*! \if ENGLISH
 *  \brief Stops recording
 *  \else
 *  \brief 结束录制采集设备信号
 *  \endif
 *  \sa startRecording:
*/
- (void)stopRecording;

/*! \if ENGLISH
 *  \brief Pause to record. Resuming recording after a pause will output the recorded video to the same file. Note: Recording can only be paused without using the built-in recorder!
 *  \return Returns a boolean value. A value of YES pause to record successfully and NO means it fails to pause.
 *  \else
 *  \brief 暂停录制采集信号。暂停录制之后再继续录制会录制到同一个媒体文件中。注意：只有不使用系统内置recorder时才能暂停录制！
 *  \return 返回布尔值。值为YES则暂停录制成功，NO则失败。
 *  \endif
 *  \since 1.17.0
 *  \sa resumeRecording
*/
- (BOOL)pauseRecording;

/*! \if ENGLISH
 *  \brief Continues to record. Continuing recording will output the recorded video to the same media file, to which the recording before suspend outputs contents.
 *  \return Returns a boolean value. A value of YES means it continues recording successfully and NO means it fails to continue.
 *  \else
 *  \brief 继续录制采集信号。继续录制会录制到暂停之前的同一个媒体文件中。
 *  \return 返回布尔值。值为YES则继续录制成功，NO则失败。
 *  \endif
 *  \since 1.17.0
 *  \sa pauseRecording
*/
- (BOOL)resumeRecording;

/*! \if ENGLISH
 *  \brief Checks if the recording has been paused.
 *  \return Returns a boolean value. If the value is YES, the recording has been paused, and NO means it's not paused.
 *  \else
 *  \brief 检查录制是否已经暂停
 *  \return 返回布尔值。值为YES则录制已经暂停，NO为未暂停。
 *  \endif
 *  \since 1.17.0
 *  \sa pauseRecording
 *  \sa resumeRecording
*/
- (BOOL)isRecordingPaused;

/*! \if ENGLISH
 *  \brief take a picture with the max resolution of camera which matches the preview resolution best
 *  \param flags  take picture flag. value is 0
 *  \else
 *  \brief 以最接近预览比例的摄像头的最大分辨率拍摄一张照片
 *  \param flags 拍照的标志，目前没有使用， 值为0
 *  \endif
*/
- (BOOL)takePicture:(int)flags;

/*! \if ENGLISH
 *  \brief Gets the list of all built-in video effect names.
 *  \return Returns an array object containing all the built-in video effects’ names.
 *  \else
 *  \brief 获取全部内嵌视频特效名称
 *  \return 返回包含所有内嵌的视频特效名称的数组对象
 *  \endif
 *  \sa getAllBuiltinAudioFxNames
*/
- (NSArray *)getAllBuiltinVideoFxNames;

/*! \if ENGLISH
 *  \brief Gets the list of all built-in audio effect names.
 *  \return Returns an array object containing all the built-in audio effects’ names.
 *  \else
 *  \brief 获取全部内嵌音频特效名称
 *  \return 返回包含所有内嵌的音频特效名称的数组对象
 *  \endif
 *  \sa getAllBuiltinVideoFxNames
*/
- (NSArray *)getAllBuiltinAudioFxNames;

/*! \if ENGLISH
 *  \brief Gets the list of all built-in video transitions’ names.
 *  \return Returns an array object containing all built-in video transitions’ names.
 *  \else
 *  \brief 获取全部内嵌视频转场名称
 *  \return 返回包含所有内嵌的视频转场名称的数组对象
 *  \endif
 *  \sa getAllBuiltinCaptureVideoFxNames
 *  \sa getBeautyVideoFxName
 *  \sa getDefaultVideoTransitionName
*/
- (NSArray *)getAllBuiltinVideoTransitionNames;

/*! \if ENGLISH
 *  \brief Gets the list of all built-in capture video effects’ names.
 *  \return Returns an array object containing all built-in capture video effects’ names.
 *  \else
 *  \brief 获取全部内嵌采集视频特效名称
 *  \return 返回包含所有内嵌的采集视频特效名称的数组对象
 *  \endif
 *  \sa getBeautyVideoFxName
 *  \sa getAllBuiltinVideoFxNames
*/
- (NSArray *)getAllBuiltinCaptureVideoFxNames;

/*! \if ENGLISH
 *  \brief Gets the name of beauty effect.
 *  \return Returns the name of beauty effect.
 *  \else
 *  \brief 获得美颜的视频特效名称
 *  \return 返回美颜视频特效名称
 *  \endif
 *  \sa getAllBuiltinVideoFxNames
 *  \sa getAllBuiltinCaptureVideoFxNames
*/
- (NSString *)getBeautyVideoFxName;

/*! \if ENGLISH
 *  \brief Gets the default video transition’s name.
 *  \return Returns a string representing the default transition’s name.
 *  \else
 *  \brief 获得默认视频转场名称
 *  \return 返回表示默认转场名称的字符串
 *  \endif
 *  \sa getAllBuiltinVideoTransitionNames
*/
- (NSString *)getDefaultVideoTransitionName;

/*! \if ENGLISH
 *  \brief Sets the default audio transition’s name.
 *  \param name audio transition’s name
 *  \else
 *  \brief 设置默认视频转场名称
 *  \param name 音频转场的名字
 *  \endif
 *  \sa getAllBuiltinVideoTransitionNames
*/
- (void)setDefaultAudioTransitionName:(NSString *)name;

/*! \if ENGLISH
 *  \brief Gets the description of a video effect.
 *  \param fxName Video effect’s name
 *  \return Returns the object of the video effect description.
 *  \else
 *  \brief 获取视频特效描述
 *  \param fxName 视频特效名称
 *  \return 返回视频特效描述的对象
 *  \endif
 *  \sa getAudioFxDescription:
*/
- (NvsFxDescription *)getVideoFxDescription:(NSString *)fxName;

/*! \if ENGLISH
 *  \brief Gets the description of an audio effect.
 *  \param fxName Audio effect’s name
 *  \return Returns the object of the audio effect description.
 *  \else
 *  \brief 获取音频特效描述
 *  \param fxName 音频特效名称
 *  \return 返回音频特效描述的对象
 *  \endif
 *  \sa getVideoFxDescription:
*/
- (NvsFxDescription *)getAudioFxDescription:(NSString *)fxName;

/*! \if ENGLISH
 *  \brief Creates an object of video frame retriever.
 *  \param videoFilePath Path of the original video
 *  \return Returns an NvsVideoFrameRetriever object representing the video frame retriever object.
 *  \else
 *  \brief 创建视频帧提取对象
 *  \param videoFilePath 原始视频文件路径
 *  \return 返回NvsVideoFrameRetriever对象，表示视频帧提取对象
 *  \endif
 *  \since 1.2.0
*/
- (NvsVideoFrameRetriever *)createVideoFrameRetriever:(NSString *)videoFilePath;

/*! \if ENGLISH
 *  \brief Creates an object of auxiliary streaming context.
 *  \param lags Flag field. If there is no special requirement, please fill in 0.
 *  \return Returns an NvsStreamingContext object .
 *  \else
 *  \brief 创建辅助流媒体上下文对象
 *  \param flags 流媒体上下文创建标志
 *  \return 返回NvsVideoFrameRetriever对象，表示辅助流媒体上下文对象
 *  \endif
 *  \since 2.12.0
*/
- (NvsStreamingContext *)createAuxiliaryStreamingContext:(int)flags;

/*! \if ENGLISH
 *  \brief  destory auxiliary streaming context.
 *  \param NvsStreamingContext. destoryed auxiliary streaming context
  *  \else
 *  \brief 销毁辅助流媒体上下文对象
 *  \param NvsStreamingContext 被销毁的流媒体上下文对象
 *  \endif
 *  \since 2.12.0
*/
- (void)destoryAuxiliaryStreamingContext:(NvsStreamingContext*)auxContext;

/*! \if ENGLISH
 *  \brief set volume to audio output device.
 *  \param volume new volume to device, value range[0, 1]
 *  \else
 *  \brief 设置音频输出设备音量
 *  \param volume 新的音量 取值范围[0,1]
 *  \endif
 *  \since 2.14.0
*/
- (void)setAudioOutputDeviceVolume:(float)volume;

/*! \if ENGLISH
 *  \brief Verifies whether a feature is available or not.
 *  \param sdkFunctionName The name of the SDK’s function
 *  \return Returns a BOOL value. YES indicates that the authorization verification is successful, and NO indicates that the verification fails.
 *  \else
 *  \brief 验证某项功能是否可用。
 *  \param sdkFunctionName sdk功能的名字
 *  \return 返回BOOL值。YES表示授权验证成功，NO则验证失败。
 *  \endif
*/
+ (BOOL)functionalityAuthorised:(NSString *)sdkFunctionName;

/*! \if ENGLISH
 *  \brief set special camera device type to sdk.
 *  \param specialCameraType special device type
 *  \else
 *  \brief 设置特殊的Camera 的设备类型。
 *  \param specialCameraType 特殊设备类型
 *  \endif
*/
+ (void)setSpecialCameraDeviceType:(NSString*)specialCameraType;

/*! \if ENGLISH
 *  \brief Whether to enable finding special device cameras (wide-angle, ultra-wide-angle, telephoto, etc.).
 *  \param enable determines whether to enable the search for specific devices.
 *  \else
 *  \brief 是否启用查找特殊设备摄像头（广角，超广角，长焦等）.
 *  \param enable 是否启用查找特殊设备.
 *  \endif
 *  \since 3.15.1
*/
+ (void)setEnableFindExtraDeviceType:(BOOL)enable;

/*! \if ENGLISH
 *  \brief set the maximum cache for CAF.
 *  \param maxMemorySize maximum cache
 *  \else
 *  \brief 设置caf的最大缓存。
 *  \param maxMemorySize 最大缓存
 *  \endif
*/
+ (void)setMaxCafCacheMemorySize:(int)maxMemorySize;

/*! \if ENGLISH
 *  \brief set camera device capture fps.
 *  \param fps the frame count of per second
 *  \else
 *  \brief 设置采集帧率。
 *  \param fps 每秒钟的帧数量
 *  \endif
*/
- (void)setCaptureFps:(int)fps;

/*! \if ENGLISH
 *  \brief set image reader count.
 *  \param count the image reader
 *  \else
 *  \brief 设置image reader 最大个数。
 *  \param image reader 最大个数
 *  \endif
*/
- (void)setImageReaderCount:(int)count API_DEPRECATED("Use +setMaxImageReaderCount:", macos(10.3, 10.11), ios(7.0, 8.0));

/*! \if ENGLISH
 *  \brief  Sets the default image clip duration
 *  \param bitmap. image clip duration
 *  \since 3.4.0
 *  \else
 *  \brief 设置缺省图像片段持续时长
 *  \param defaultImageClipDuration 图像片段持续时长
 *  \endif
 *  \since 3.4.0
 */
- (void)setDefaultImageClipDuration:(int64_t)defaultImageClipDuration;

/*! \if ENGLISH
 *  \brief set max image reader count.
 *  \param count the max image reader
 *  \else
 *  \brief 设置max image reader 最大个数。
 *  \param max image reader 最大个数
 *  \endif
*/
+ (void)setMaxImageReaderCount:(int)count;

/*! \if ENGLISH
 *  \brief set the path of the effects plug-in.
 *  \param effects plug-in path array
 *  \else
 *  \brief 设置特效插件路径。
 *  \param 特效插件路径数组
 *  \endif
*/
+ (void)setFxPluginBundlePathList:(NSArray *)list;

/*! \if ENGLISH
 *  \brief set max audio reader count.
 *  \param max count the audio reader
 *  \else
 *  \brief 设置 audio reader 最大个数。
 *  \param audio reader 最大个数
 *  \endif
*/
+ (void)setMaxAudioReaderCount:(int)count;

/*! \if ENGLISH
 *  \brief set max file reader count.
 *  \param max count the file reader
 *  \else
 *  \brief 设置 file reader 最大个数。
 *  \param file reader 最大个数
 *  \endif
*/
+ (void)setMaxReaderCount:(int)count;
/*! @if ENGLISH
 *  @brief set max video decode error count，default is 80.
 *  @param count count
 *  @else
 *  @brief 设置最大视频硬件解码错误次数，默认80.
 *  @param count 数量。
 *  @endif
*/
+ (void)setMaxVideoDecodeErrorCount:(int)count;
/*! \if ENGLISH
 *  \brief set max soft file reader count.
 *  \param max count the soft file reader
 *  \else
 *  \brief 设置软件的 file reader 最大个数。
 *  \param soft file reader 最大个数
 *  \endif
*/
+ (void)setMaxSoftReaderCount:(int)count;

/*! \if ENGLISH
 *  \brief set max icon reader count.
 *  \param max count the icon reader
 *  \else
 *  \brief 设置 icon reader 最大个数。
 *  \param icon reader 最大个数
 *  \endif
*/
+ (void)setMaxIconReaderCount:(int)count;

/*! \if ENGLISH
 *  \brief set max image reader count.
 *  \param count the max image reader
 *  \else
 *  \brief 设置max image reader 最大个数。
 *  \param max image reader 最大个数
 *  \endif
*/
+ (void)setStreamingPoolSizeInByte:(int)maxMemorySize;

/*! \if ENGLISH
 *  \brief Set the maximum number of caption context cached during editing.
 *  \param Maximum number of cached caption contexts
 *  \else
 *  \brief 设置编辑时缓存的caption context 最大个数。
 *  \param 缓存的caption context 最大个数
 *  \endif
*/
+ (void)setMaxEditCaptionCachedContextCount:(int)count;

/*! \if ENGLISH
 *  \brief Set the maximum number of caption context cached during compile.
 *  \param Maximum number of cached caption contexts
 *  \else
 *  \brief 设置导出时缓存的caption context 最大个数。
 *  \param 缓存的caption context 最大个数
 *  \endif
*/
+ (void)setMaxCompileCaptionCachedContextCount:(int)count;

/*! \if ENGLISH
 *  \brief calc the duration after use curves variable speed.note： the origin duration is the curves's last endpoint.x-first endpoint.x
 *  \param curvesString description of the variable speed curves.
 *  \string foramt : (endpoint1)(endpoint1.backward)(endpoint1.frontward)(endpoint2)(endpoint2.backward)(endpoint2.frontward)……
 *  \coords foramt : (x,y)
 *  \note1 : the y coords means the multiple speed. the range of y is 0.1 to 10
 *  \note2 : all x coord values cannot be repeated. endpoint1.backward.x < endpoint1.x < endpoint1.frontward.x < endpoint2.backward.x <endpoint2.x……
 *  \note3 : if you set an empty  curvesString,it means you want to disable curves variable speed,the clip will back to const speed.
 *  \eg : curvesString = "(0,1)(-3,1)(3,1)(7,5)(6,5)(8,5)(10,0.4)(9,0.4)(11,0.4)(17,0.4)(16,0.4)(18,0.4)(20,5)(19,5)(21,5)(27,1)(24,1)(30,1)" curvesString included 6 group end point info .
 *  \brief 返回经过曲线变速后的时长。注：原始时长为曲线段中尾端点与首端点X坐标值之差
 *  \param curvesString 贝塞尔曲线描述字符串
 *  \字符串格式：(端点1坐标)(端点1后控制点坐标)(端点1前控制点坐标)(端点2坐标)(端点2后控制点坐标)(端点2前控制点坐标)(端点3坐标)(端点3后控制点坐标)(端点3前控制点坐标)……
 *  \坐标格式：(坐标X值，坐标Y值)
 *  \注1：Y坐标为播放倍速值，范围在0.1-10之间。
 *  \注2：每个端点及控制点的X坐标必须不能相等。大小规定为：端点1后控制点的X坐标 < 端点1的X坐标 <端点1的前控制点的X坐标 < 端点2后控制点的X坐标 < 端点2的X坐标……
 *  \注3：如果设置的curvesString为空字符串，则表示对该片段取消之前的曲线变速，恢复到匀速状态。
 *  \例如：curvesString = "(0,1)(-3,1)(3,1)(7,5)(6,5)(8,5)(10,0.4)(9,0.4)(11,0.4)(17,0.4)(16,0.4)(18,0.4)(20,5)(19,5)(21,5)(27,1)(24,1)(30,1)"包含了6组端点及其控制点坐标信息。
 *  \endif
 *  \since 2.17.0
*/
- (long)calcDurationAfterCurvesVariableSpeed:(NSString*)curvesString;

/*! \if ENGLISH
 *  \brief check the image is a black image or not.
 *  \param the image to be checked
 *  \else
 *  \brief 检测是否是纯黑色的图片。
 *  \param 待检测的image
 *  \endif
*/
- (BOOL)isBlackFrame:(UIImage *)image;

/*! @if ENGLISH
 *  @brief Get whether AEC(Acoustic Echo Cancellation) is enabled.
 *  @return Returns whether AEC(Acoustic Echo Cancellation) is enabled.
 *  @else
 *  @brief 获取回声消除是否开启。
 *  @return 返回回声消除是否开启。
 *  @endif
 *  \since 3.11.0
*/
- (BOOL)getAECEnabled;

/*! @if ENGLISH
 *  @brief Set whether to enable AEC(Acoustic Echo Cancellation).Note: Each time you startCapturePreview, this will be set to off, which means that if you want to use echo cancellation, you will need to enable it again after each preview.
 *  @param whether to enable AEC.
 *  @return No return value.
 *  @else
 *  @brief 设置是否开启回声消除。注意：每次startCapturePreview都会将此设置为关闭状态，也就是说如果要使用回声消除功能每次启动预览后需要再次启用它。
 *  @param enable 是否开启回声消除。
 *  @return 无返回值。
 *  @endif
 *  @since 3.11.0
*/
- (void)setAECEnabled:(BOOL)enable;

@end

/*! \if ENGLISH
 *  \brief Description of capture device capability
 *
 *  Defines the relevant properties of the capture device, including auto focus, auto exposure, zoom, etc.
 *  \else
 *  \brief 采集设备能力描述
 *
 *  定义采集设备的相关属性，包含自动聚焦，自动曝光，缩放等
 *  \endif
*/
NVS_EXPORT @interface NvsCaptureDeviceCapability : NSObject

@property (readonly) BOOL supportAutoFocus;                     //!< \if ENGLISH Whether to support auto focus. \else 是否支持自动聚焦 \endif
@property (readonly) BOOL supportContinuousFocus;               //!< \if ENGLISH Whether to support continuous focus. \else 是否支持连续聚焦 \endif
@property (readonly) BOOL supportAutoExposure;                  //!< \if ENGLISH Whether to support automatic exposure. \else 是否支持自动曝光 \endif
@property (readonly) BOOL supportZoom;                          //!< \if ENGLISH Whether to support zoom. \else 是否支持缩放 \endif
@property (readonly) float maxZoomFactor;                       //!< \if ENGLISH Maximum zoom factor. \else 最大缩放比例 \endif
@property (readonly) BOOL supportFlash;                         //!< \if ENGLISH Whether to support flash light. \else 是否支持换补灯光 \endif
@property (readonly) BOOL supportVideoStabilization;            //!< \if ENGLISH Whether to support video stabilization. \else 是否支持防抖动 \endif
@property (readonly) BOOL supportExposureBias;                  //!< \if ENGLISH Whether to support exposure compensation. \else 是否支持曝光补偿 \endif
@property (readonly) float minExposureBias;                     //!< \if ENGLISH Minimum exposure compensation coefficient.\else 最小曝光补偿系数 \endif
@property (readonly) float maxExposureBias;                     //!< \if ENGLISH Maximum exposure compensation coefficient.\else 最大曝光补偿系数 \endif

@end

/*! \if ENGLISH
 *  \brief Media error info from callback
 *  \else
 *  \brief 回调的媒体错误信息
 *  \endif
*/
NVS_EXPORT @interface NvsMediaError : NSObject

@property(atomic) NvsStreamingEngineMediaErrorType errorType;            //!< \if Type of media error, please refert to [NvsStreamingEngineMediaErrorType](@ref NvsStreamingEngineMediaErrorTypes) \else 媒体错误类型 \endif
@property(atomic) BOOL isHardwareError;                                  //!< \if ENGLISH Whether is hardware error or not. \else 是否是硬件错误 \endif
@property(atomic) NSString* errorInfo;                                   //!< \if ENGLISH error information. \else 错误信息 \endif

@end

