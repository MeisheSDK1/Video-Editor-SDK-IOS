//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2017. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jan 3. 2017
//   Author:        Meishe video team
//================================================================================

#pragma once

#import "NvsCommonDef.h"
#import <Foundation/NSObject.h>

/*! \if ENGLISH
 *  \brief Audio and video file information
 *
 *  Shows information about audio and video files, including the duration of audio and video files, data rate, aspect ratio of pixels, audio and video streams count, etc.
 *
 *  \warning In the NvsAVFileInfo type, all public APIs can be used not only in the UI thread,but also across threads! ! !
 *  \else
 *  \brief 音视频文件信息
 *
 *  显示音视频文件的信息，包括音视频文件的时长，数据速率，像素横纵比，音视频流数目等。
 *
 *  \warning NvsAVFileInfo类中，所有public API不仅可以在UI线程使用，还可以跨线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsAVFileInfo : NSObject

@property (readonly) NvsAVFileType avFileType;       //!< \if ENGLISH File type \else 文件类型 \endif
@property (readonly) int64_t duration;               //!< \if ENGLISH Duration(in microseconds) \else 时长(单位微秒) \endif
@property (readonly) uint64_t dataRate;              //!< \if ENGLISH Data rate \else 数据速率 \endif
@property (readonly) unsigned int videoStreamCount;  //!< \if ENGLISH Video stream count \else 视频流数目 \endif
@property (readonly) unsigned int audioStreamCount;  //!< \if ENGLISH Audio stream count \else 音频流数目 \endif

/*! \if ENGLISH
 *  \brief Gets the duration of the video through the video stream index
 *  \param videoStreamIndex Video stream index
 *  \return Returns the duration of the current video stream (in microseconds).
 *  \else
 *  \brief 通过视频流索引获取视频流时长
 *  \param videoStreamIndex 视频流索引
 *  \return 返回当前视频流的时长(单位微秒)
 *  \endif
 *  \sa getAudioStreamDuration:
*/
- (int64_t)getVideoStreamDuration:(unsigned int)videoStreamIndex;

/*! \if ENGLISH
 *  \brief Gets the video stream size through the video stream index.
 *  \param videoStreamIndex Video stream index
 *  \return Returns the NvsSize object, which represents the size (width and height) of the video stream.
 *  \else
 *  \brief 通过视频流索引获取视频流尺寸
 *  \param videoStreamIndex 视频流索引
 *  \return 返回值为NvsSize对象，表示视频流的尺寸(宽度与高度)
 *  \endif
*/
- (NvsSize)getVideoStreamDimension:(unsigned int)videoStreamIndex;

/*! \if ENGLISH
 *  \brief Gets the video stream pixel aspect ratio through the video stream index
 *  \param videoStreamIndex Video stream index
 *  \return Returns the NvsRational object, which represents the pixel aspect ratio of the current video stream.
 *  \else
 *  \brief 通过视频流索引获取视频流像素横纵比
 *  \param videoStreamIndex 视频流索引
 *  \return 返回NvsRational对象，表示当前视频流的像素横纵比
 *  \endif
 *  \sa getVideoStreamFrameRate:
*/
- (NvsRational)getVideoStreamPixelAspectRatio:(unsigned int)videoStreamIndex;

/*! \if ENGLISH
 *  \brief Gets the video stream frame rate through the video stream index.
 *  \param videoStreamIndex Video stream index
 *  \return Returns the NvsRational object, which indicates the frame rate of the current video stream.
 *  \else
 *  \brief 通过视频流索引获取视频流帧速率
 *  \param videoStreamIndex 视频流索引
 *  \return 返回NvsRational对象，表示当前视频流的帧速率
 *  \endif
 *  \sa getVideoStreamPixelAspectRatio:
*/
- (NvsRational)getVideoStreamFrameRate:(unsigned int)videoStreamIndex;

/*! \if ENGLISH
 *  \brief Gets the video stream rotation angle type through the video stream index.
 *  \param videoStreamIndex Video stream index
 *  \return Returns the NvsVideoRotation object, which indicates the rotation angle type of the current video stream.
 *  \else
 *  \brief 通过视频流索引获取视频流旋转角度类型
 *  \param videoStreamIndex 视频流索引
 *  \return 返回NvsVideoRotation对象，表示当前视频流的旋转角度类型
 *  \endif
*/
- (NvsVideoRotation)getVideoStreamRotation:(unsigned int)videoStreamIndex;

/*! \if ENGLISH
 *  \brief Gets the effective count of bits per pixel component of the current video stream through the video stream index.
 *  \param videoStreamIndex Video stream index
 *  \return Returns the count of pixels in the current video stream
 *  \else
 *  \brief 通过视频流索引获取当前视频流的每个像素分量的有效比特数
 *  \param videoStreamIndex 视频流索引
 *  \return 返回当前视频流的Pixel位数
 *  \endif
*/
- (unsigned int)getVideoStreamComponentBitCount:(unsigned int)videoStreamIndex;

/*! \if ENGLISH
 *  \brief Gets the video codec type of the current video stream through the video stream index.
 *  \param videoStreamIndex Video stream index
 *  \return Returns the NvsVideoCodecType object，which indicates the video codec type in the current video stream
 *  \else
 *  \brief 通过视频流索引获取当前视频流的编码类型
 *  \param videoStreamIndex 视频流索引
 *  \return 返回NvsVideoCodecType对象，表示当前视频流的编码类型
 *  \endif
*/
- (NvsVideoCodecType)getVideoStreamCodecType:(unsigned int)videoStreamIndex;


/*! \if ENGLISH
 *  \brief Gets the video codec profile of the current video stream through the video stream index.
 *  \param videoStreamIndex Video stream index
 *  \return Returns the int object，which indicates the video codec profile in the current video stream
 *  \else
 *  \brief 通过视频流索引获取当前视频流的画质等级
 *  \param videoStreamIndex 视频流索引
 *  \return 返回当前视频流的等级profile
 *  \endif
*/
- (int)getVideoCodecProfile:(unsigned int)videoStreamIndex;

/*! \if ENGLISH
 *  \brief Gets the video codec level of the current video stream through the video stream index.
 *  \param videoStreamIndex Video stream index
 *  \return Returns the int object，which indicates the video codec level in the current video stream
 *  \else
 *  \brief 通过视频流索引获取当前视频流的编码等级
 *  \param videoStreamIndex 视频流索引
 *  \return 返回当前视频流的等级level
 *  \endif
*/
- (int)getVideoCodecLevel:(unsigned int)videoStreamIndex;

/*! \if ENGLISH
 *  \brief Gets the video color transfer of the current video stream through the video stream index.
 *  \param videoStreamIndex vedio stream index
 *  \return Returns the video color transfer of the current video stream.
 *  \note : To get this information, call NvsStreamingContext.getAVFileInfo () must use AV_ FILEINFO_ EXTRA_ Info flag
 *  \else
 *  \brief 通过视频流索引获取当前视频流的颜色转换曲线。
 *  \param videoStreamIndex 视频流索引
 *  \return 返回当前视频流的颜色转换曲线
 *  \注： 要正确的获取这个信息，在调用NvsStreamingContext.getAVFileInfo()必须使用AV_FILEINFO_EXTRA_INFO标志。
 *  \endif
*/
- (NvsVideoColorTransfer)getVideoStreamColorTranfer:(unsigned int)videoStreamIndex;

/*! \if ENGLISH
 *  \brief Gets the video HDR type of the current video stream through the video stream index.
 *  \param videoStreamIndex vedio stream index
 *  \return Returns the video HDR type of the current video stream.
 *  \note : To get this information, call NvsStreamingContext.getAVFileInfo () must use AV_ FILEINFO_ EXTRA_ Info flag
 *  \else
 *  \brief 通过视频流索引获取当前视频流的HDR类型。
 *  \param videoStreamIndex 视频流索引
 *  \return 返回当前视频流的HDR类型
 *  \注： 要正确的获取这个信息，在调用NvsStreamingContext.getAVFileInfo()必须使用AV_FILEINFO_EXTRA_INFO标志。
 *  \endif
*/
- (NvsVideoHDRType)getVideoStreamHDRType:(unsigned int)videoStreamIndex;

/*! \if ENGLISH
 *  \brief Gets the audio stream duration through the audio stream index.
 *  \param audioStreamIndex Audio stream index
 *  \return Returns the duration of the current audio stream (in microseconds).
 *  \else
 *  \brief 通过音频流索引获取音频流时长
 *  \param audioStreamIndex 音频流索引
 *  \return 返回当前音频流的时长(单位微秒)
 *  \endif
 *  \sa getVideoStreamDuration:
*/
- (int64_t)getAudioStreamDuration:(unsigned int)audioStreamIndex;

/*! \if ENGLISH
 *  \brief Gets the sampling rate of the audio stream through the audio stream index.
 *  \param audioStreamIndex Audio stream index
 *  \return Returns the sampling rate of the current audio stream
 *  \else
 *  \brief 通过音频流索引获取音频流的采样率
 *  \param audioStreamIndex 音频流索引
 *  \return 返回当前音频流的采样率
 *  \endif
*/
- (unsigned int)getAudioStreamSampleRate:(unsigned int)audioStreamIndex;

/*! \if ENGLISH
 *  \brief Gets the channel count of the audio stream through the audio stream index.
 *  \param audioStreamIndex Audio stream index
 *  \return Returns the channel count of the current audio stream
 *  \else
 *  \brief 通过音频流索引获取音频流的声道数
 *  \param audioStreamIndex 音频流索引
 *  \return 返回当前音频流的声道数
 *  \endif
*/
- (unsigned int)getAudioStreamChannelCount:(unsigned int)audioStreamIndex;

/*! \if ENGLISH
 *  \brief Gets whether codec is supported of the audio stream through the audio stream index.
 *  \param audioStreamIndex Audio stream index
 *  \return Returns whether codec is supported
 *  \else
 *  \brief 通过音频流索引获取音频流编码格式是否支持
 *  \param audioStreamIndex 音频流索引
 *  \return 返回编码格式是否支持
 *  \endif
*/
- (BOOL)getAudioStreamCodecSupport:(unsigned int)audioStreamIndex;
@end

