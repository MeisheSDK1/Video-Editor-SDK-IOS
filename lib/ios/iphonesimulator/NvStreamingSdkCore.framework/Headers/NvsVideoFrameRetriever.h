//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    May 2. 2017
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"

/*! \if ENGLISH
 *  \brief The height level of the extracted video frame
 *  \else
 *  \brief 生成提取视频帧的高度级别
 *  \endif
 *  \since 1.2.0
*/
typedef enum {
    NvsVideoFrameHeightGrade360 = 0, //!< \if ENGLISH Video frame of 360 pixels in height \else 生成视频帧高度360像素 \endif
    NvsVideoFrameHeightGrade480,     //!< \if ENGLISH Video frame of 480 pixels in height \else 生成视频帧高度480像素 \endif
    NvsVideoFrameHeightGrade720      //!< \if ENGLISH Video frame of 720 pixels in height \else 生成视频帧高度720像素 \endif
} NvsVideoFrameHeightGrade;

@class UIImage;

/*! \if ENGLISH
 *  \brief Video frame extraction
 *
 *  The video frame extraction class can acquire the original video frame image at a certain moment.
 *  \warning In the NvsVideoFrameRetriever class, all public APIs can be used not only in the UI thread, but also across threads! ! !
 *  \else
 *  \brief 视频帧提取
 *
 *  视频帧提取类，可以获取某一时刻的原始视频帧图像。
 *  \warning NvsVideoFrameRetriever类中，所有public API不仅可以在UI线程使用，也可以跨线程使用！！！
 *  \endif
 *  \since 1.2.0
*/
NVS_EXPORT @interface NvsVideoFrameRetriever : NSObject

/*! \if ENGLISH
*  \brief Set the time tolerance for acquiring video frames. The actual time of the generated images will be within the range [time-timeTolerance，time+timeTolerance] and may differ from the requested time for efficiency.Pass 0 for to request frame-accurate image generation; this may incur additional decoding delay.Default is 500000.
*  \param timeTolerance the time value (in microseconds)
*  \else
*  \brief 设置获取视频帧图像的时间容忍度。生成图像的实际时间将在[time-timeTolerance，time+timeTolerance]范围内，并且可能与实际要求的时间不同。传0以请求帧准确的图像，这可能导致额外的解码延迟。默认值为500000
*  \param timeTolerance 时间值(单位微秒)
*  \endif
*  \since 2.20.0
*/
- (void)setFrameTimeTolerance:(int64_t)timeTolerance;

/*! \if ENGLISH
 *  \brief Gets a video frame image at a certain moment. For details, please refer to [Video Frame Image Extraction](@ref videoFrameRetriever.md).
 *  \param time the time value (in microseconds)
 *  \param videoFrameHeightGrade The height level of the extracted video frame
 *  \return Returns a UIImage object representing the video frame image at a certain moment.
 *  \else
 *  \brief 获取某一时刻视频帧图像。详细情况参见[视频帧图像提取专题] (@ref videoFrameRetriever.md)
 *  \param time 时间值(单位微秒)
 *  \param videoFrameHeightGrade 生成视频帧图像的高度级别
 *  \return 返回UIImage对象，表示某一时刻视频帧图像
 *  \endif
*/
- (UIImage *)getFrameAtTime:(int64_t)time videoFrameHeightGrade:(NvsVideoFrameHeightGrade)videoFrameHeightGrade;

/*! \if ENGLISH
 *  \brief Gets a video frame image at a certain time which users can customize the height of the video frame. For details, please refer to [Video Frame Image Extraction] (@ref videoFrameRetriever.md).
 *  \param time the time value (in microseconds)
 *  \param videoFrameHeight Custom video frame height.
 *  \return Returns a UIImage object representing the video frame image at a certain moment.
 *  \else
 *  \brief 获取某一时刻视频帧图像，可以自定义视频帧的高度。详细情况参见[视频帧图像提取专题] (@ref videoFrameRetriever.md)
 *  \param time 时间值(单位微秒)
 *  \param videoFrameHeight 自定义视频帧高度
 *  \return 返回UIImage对象，表示某一时刻视频帧图像
 *  \endif
 *  \since 1.15.0
*/
- (UIImage *)getFrameAtTimeWithVideoFrameHeight:(int64_t)time videoFrameHeight:(unsigned int)videoFrameHeight;
@end

