//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2019. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Apr 20. 2019
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <UIKit/UIImage.h>
#import "NvsCommonDef.h"

/*! \if ENGLISH
 *  \brief Type of convertor error
 *  \else
 *  \brief 转码错误
 *  \endif
*/
typedef enum {
    keNvsMediaConvertorErrorType_NoError = 0,                        //!< \if ENGLISH no error \else 没有错误 \endif
    keNvsMediaConvertorErrorType_Cancled,                            //!< \if ENGLISH task is canceled \else 当前任务已经取消 \endif
    keNvsMediaConvertorErrorType_HardwareVideoEncoderSetupError, //!< \if ENGLISH video encoder setup error \else 视频编码器设置错误 \endif
    keNvsMediaConvertorErrorType_HardwareVideoEncodingError,         //!< \if ENGLISH video encoder error \else 视频编码器编码过程中出现错误 \endif
    keNvsMediaConvertorErrorType_HardwareVideoDecoderSetupError,     //!< \if ENGLISH video decoder setup error \else 视频解码器设置过程中出现错误 \endif
    keNvsMediaConvertorErrorType_HardwareVideoDecodingError,         //!< \if ENGLISH video decode error \else 视频解码器解码过程中出现错误 \endif
    keNvsMediaConvertorErrorType_ProcessVideoError,
    keNvsMediaConvertorErrorType_ProcessAudioError,
    keNvsMediaConvertorErrorType_ReadFileEof,
    keNvsMediaConvertorErrorType_UnkownError = 65535                //!< \if ENGLISH task has unknown error \else 出现没有定义的错误 \endif
} NvsMediaConvertorErrorType;

/*! \anchor CONVERTOR_CONFIGURATIONS */
/*!
 *  \if ENGLISH
 *   @name Configuration of media convertor
 *  \else
 *   @name 转码配置
 *  \endif
*/
//!@{
#define NVS_MEDIA_CONVERTOR_CUSTOM_HEIGHT                   @"custom-video-height"			//!< \if ENGLISH Set custom video height，width will be automatic scaled to keep aspect ratio. type：int \else 设置自定义视频输出高度，宽度会等比例自动缩放。类型：int \endif
#define NVS_MEDIA_CONVERTOR_CUSTOM_AUDIO_SAMPLE_RATE        @"custom-audio-sample-rate"     //!< \if ENGLISH Set custom audio sample rate，type：int \else 设置自定义音频采样率，类型：int \endif
#define NVS_MEDIA_CONVERTOR_NO_VIDEO                        @"convertor-no-video"           //!< \if ENGLISH only convert audio stream，type：bool  \else 只进行音频转码，类型：bool \endif
#define NVS_MEDIA_CONVERTOR_NO_AUDIO                        @"convertor-no-audio"           //!< \if ENGLISH only convert video stream，type：bool \else 只进行视频转码，类型：bool \endif
#define NVS_MEDIA_CONVERTOR_CUSTOM_AUDIO_CHANNEL            @"custom-audio-channel"         //!< \if ENGLISH Set custom audio channels，type：int \else 设置自定义音频通道数，类型：int\endif
#define NVS_MEDIA_CONVERTOR_REVERSE_AUDIO_STREAM            @"convertor-reverse-audio"      //!< \if ENGLISH  Reverse audio stream，type：bool \else 倒放音频流，类型：bool\endif
#define NVS_MEDIA_CONVERTOR_MAX_CACHE_SIZE_IN_MEMORY        @"max_cache_size_in_memory"     //!< \if ENGLISH max cache video frame buffer count in host memory，type：int \else 在内存中缓存的视频帧数量，类型：int \endif
#define NVS_MEDIA_CONVERTOR_CUSTOM_FRAME_RATE               @"custom-video-frame-rate"     //!< \if ENGLISH Set custom video frame rate, type: int \else 设置自定义视频帧率，类型：int \endif
#define NVS_MEDIA_CONVERTOR_CUSTOM_AUDIO_PCM_FILE           @"custom-audio-pcm-file"        //!< \if ENGLISH Set output audio pcm stream，type：bool \else 设置输出音频PCM文件，类型：bool\endif
#define NVS_MEDIA_CONVERTOR_COMPILE_GOP_SIZE                @"gopsize"                      //!< \if ENGLISH GOP SIZE for convert video. type:int \else 生成视频GOP SIZE。类型：整型 \endif
#define NVS_MEDIA_CONVERTOR_COMPILE_BITRATE                 @"bitrate"                      //!< \if ENGLISH Bitrate for convert video in bps. type:int \else 生成视频码率，单位bps。类型：整型 \endif
#define NVS_MEDIA_CONVERTOR_COMPILE_AUDIO_BITRATE           @"audio bitrate"                //!< \if ENGLISH Bitrate for convert audio in bps. type:int \else 生成音频码率，单位bps。类型：整型 \endif
#define NVS_EDIA_CONVERTOR_VIDEO_ENCODEC_NAME               @"video encoder name"             //!< \if ENGLISH Assigned video encoding format, hevc(h.256) is supported, default is h.264\else 指定视频压缩格式，类型：string，目前支持hevc(h.265)，默认h.264\endif
#define NVS_EDIA_CONVERTOR_AUDIO_ENCODEC_NAME               @"audio encoder name"             //!< \if ENGLISH Assigned audio encoding format, "amr-wb" and "mp3" are supported, default is "aac" \else 指定音频压缩格式，类型：string，目前支持“mp3”，"amr-wb"，默认"aac"\endif
//!@}

@protocol NvsMediaFileConvertorDelegate<NSObject>

- (void)didConvertorProgress:(int64_t)taskId progress:(float)progress;

- (void)didConvertorFinish:(int64_t)taskId sourceFile:(NSString*)src outputFile:(NSString*)dst errorCode:(NvsMediaConvertorErrorType)error;

- (void)didAudioMuteRage:(int64_t)taskId muteStart:(int64_t)start muteEnd:(int64_t)end;

@end


NVS_EXPORT @interface NvsMediaFileConvertor : NSObject

@property (nonatomic, weak) id<NvsMediaFileConvertorDelegate> delegate;

- (instancetype)init;

/*! \if ENGLISH
 *  \brief Start to convert file
 *  \param srcFilePath source file
 *  \param outputFilePath destination file
 *  \param isReverse reverse convert file
 *  \param from start time
 *  \param to end time
 *  \param options convert options
 *  \return Task ID
 *  \else
 *  \brief 开始转码
 *  \param srcFilePath 源文件
 *  \param outputFilePath 目标文件
 *  \param isReverse 是否倒放转码
 *  \param from 转码的起点时间
 *  \param to 转码的止点时间
 *  \param options 转码参数集合
 *  \return 转码任务ID
 *  \endif
 */
- (int64_t)convertMeidaFile:(NSString *)srcFilePath
                   outputFile:(NSString *)outputFilePath
             isReverseConvert:(bool)isReverse
                 fromPosition:(int64_t)from
                   toPosition:(int64_t)to
                      options:(NSMutableDictionary *)options;

/*! \if ENGLISH
 *  \brief Cancel task
 *  \param taskId Task Id
 *  \else
 *  \brief 取消转码任务
 *  \param taskId 任务id
 *  \endif
 */
- (void)cancelTask:(int64_t)taskId;

/*! \if ENGLISH
 *  \brief 关闭转码操作，清理资源，建议在销毁对象前先清理资源
 *  \else
 *  \brief Close the transcoding operation and clean up the resources. It is recommended to clean up the resources before destroying the object.
 *  \endif
 */
-(void)close;

@end

