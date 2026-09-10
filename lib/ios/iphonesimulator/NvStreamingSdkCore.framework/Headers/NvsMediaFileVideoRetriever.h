//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2019. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Apr 16. 2019
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import "NvsAVFileInfo.h"


//private final String TAG = "NvsMediaFileVideoRetriever";

/*
 * 无压缩数据收集器
 * 这个接口可以在不同线程中使用。如果确定接口不使用了，请调用release（）方法
 *  \warning 如果是网络素材，最好不要在UI线程调用，否则网络不好的时候可能会ANR！
 */

typedef enum {
    NvsMediaFileVideoRetrieverError_Code_No_Error = 0,                   //!< \if ENGLISH no error \else 没有错误 \endif
    NvsMediaFileVideoRetrieverError_Code_No_Cancel = 1,                  //!< \if ENGLISH task is canceled \else 当前任务已经取消 \endif
    NvsMediaFileVideoRetrieverError_Video_Encode_Setup_Error = 2,        //!< \if ENGLISH video encoder setup error \else 视频编码器设置错误 \endif
    NvsMediaFileVideoRetrieverError_Video_Encoding_Error = 3,            //!< \if ENGLISH video encoder error \else 视频编码器编码过程中出现错误 \endif
    NvsMediaFileVideoRetrieverError_Video_Decoder_Error = 4,             //!< \if ENGLISH video decoder setup error \else 视频解码器设置过程中出现错误 \endif
    NvsMediaFileVideoRetrieverError_Video_Decoding_Error = 5,            //!< \if ENGLISH video decode error \else 视频解码器解码过程中出现错误 \endif
    NvsMediaFileVideoRetrieverError_Unknown = 65535,                     //!< \if ENGLISH task has unknown error \else 出现没有定义的错误 \endif
} NvsMediaFileVideoRetrieverError;


//public static final int VIDEO_RETRIEVER_FLAG_ONE_FRAME_IN_SEGMENT = 1;

/*
 *数据收集器回调接口
 */
@protocol NvsMediaFileVideoRetrieverDelegate <NSObject>

/*  \brief 通知数据
 *  \param taskId 任何id
 *  \param data 存储解码的无压缩数据，格式为YUV420P，YUV  4:2:0   12bpp ( 3通道, 一个亮度通道, 另两个为U分量和V分量通道, 所有通道都是连续的 )
 *  \param width 解码无压缩数据中图像宽度， 这里的宽度指的是420P中Y平面的宽度
 *  \param height 解码无压缩数据中图像高度， 这里的高度指的是420P中Y平面的高度
 *  \param rotation 解码输出数据的显示方向
 *  \param videoFrameSize 每一帧无压缩数据大小，字节为单位。（考虑内存对齐，有可能比实际的大）
 */
- (void)notifySengmentData:(int64_t)taskId data:(void *)data width:(int)width height:(int)height rotation:(int)rotation videoFrameSize:(int)videoFrameSize;

/*  \brief 通知数据
 *  \param taskId 任何id
 *  \param videoFrameInfo 视频帧数据信息
 */
- (void)notifySengmentData:(int64_t)taskId videoFrameInfo:(NvsVideoFrameInfo *)videoFrameInfo;

/*  \brief 通知进度
 *  \param taskId 任何id
 *  \param progress 已经完成的进度（范围是0到1.0）
 */
- (void)notifyProgress:(int64_t)taskId progress:(float)progress;
/*  \brief 通知进度
 *  \param taskId 任何id
 *  \param errorType 错误类型，请参考:RETRIEVER_ERROR_xxxx
 */
- (void)notifyFinsih:(int64_t)taskId errorType:(NvsMediaFileVideoRetrieverError)errorType;

@end

NVS_EXPORT @interface NvsMediaFileVideoRetriever : NSObject

@property (nonatomic, weak) id<NvsMediaFileVideoRetrieverDelegate> delegate;


- (void)close;
- (BOOL)isClosed;
- (NvsAVFileInfo*)getAVFileInfo:(NSString *)avFilePath;

/*  \brief 解码部分区域
 *  \param fromPositon 需要解码的起始位置单位是毫秒
 *  \param toPosition 需要解码的结束位置单位是毫秒
 *  \param costomHeight 解码输出数据的高度,如果小于0,输出的高度和原始大小一下,最大值不能大于2160
 *  \param grabInterval 解码输出数据的间隔时间,如果小于等于0,和原始视频的一直。
 *  \param flags 解码输出的标志，参考VIDEO_RETRIEVER_FLAG_xxxx
 *  \return 返回获取的当前解码任务的id
 */
- (int64_t)decodeVideoSegment:(NSString *)srcFile
                 fromPosition:(int64_t)fromPosition
                   toPosition:(int64_t)toPosition
                 customHeight:(int)customHeight
                 grabInterval:(int)grabInterval
                        flags:(int)flags;

/*  \brief 解码部分区域
 *  \param fromPositon 需要解码的起始位置单位是毫秒
 *  \param toPosition 需要解码的结束位置单位是毫秒
 *  \param outputPixelFormat 解码输出的数据格式
 *  \param costomHeight 解码输出数据的高度,如果小于0,输出的高度和原始大小一下,最大值不能大于2160
 *  \param grabInterval 解码输出数据的间隔时间,如果小于等于0,和原始视频的一直。
 *  \param flags 解码输出的标志，参考VIDEO_RETRIEVER_FLAG_xxxx
 *  \return 返回获取的当前解码任务的id
 */
- (int64_t)decodeVideoSegment:(NSString *)srcFile
                 fromPosition:(int64_t)fromPosition
                   toPosition:(int64_t)toPosition
                outputPixelFormat:(NvsVideoFramePixelFormat)outputPixelFormat
                 customHeight:(int)customHeight
                 grabInterval:(int)grabInterval
                        flags:(int)flags;

- (void)cancelTask:(int64_t)taskId;

@end
