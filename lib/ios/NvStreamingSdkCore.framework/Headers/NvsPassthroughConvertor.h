//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2022. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Mar 21. 2022
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"

/*! \cond */

/*! \if ENGLISH
 *  \brief Type of convertor error
 *  \else
 *  \brief 转码错误
 *  \endif
*/
typedef enum {
        NvsPassthroughConvertorErrorType_NoError = 0,                  //!< \if ENGLISH no error \else 没有错误 \endif
        NvsPassthroughConvertorErrorType_Cancled = 1,                  //!< \if ENGLISH task is canceled \else 当前任务已经取消 \endif
        NvsPassthroughConvertorErrorType_SetupAudioEncoder = 2,        //!< \if ENGLISH setup audio encoder error \else 音频编码器初始化错误 \endif
        NvsPassthroughConvertorErrorType_SetupAudioDecoder = 3,        //!< \if ENGLISH setup audio decoder error \else 音频解码器初始化失败 \endif
        NvsPassthroughConvertorErrorType_ProcessVideo = 4,             //!< \if ENGLISH process video error \else 输出视频帧失败 \endif
        NvsPassthroughConvertorErrorType_ProcessAudio = 5,             //!< \if ENGLISH process audio error \else 输出音频帧失败 \endif
        NvsPassthroughConvertorErrorType_InvalidData = 6,              //!< \if ENGLISH invalid data error \else 无效参数 \endif
        NvsPassthroughConvertorErrorType_IO = 7,                       //!< \if ENGLISH input/output error \else IO错误 \endif
        NvsPassthroughConvertorErrorType_ConvertFile = 8,              //!< \if ENGLISH file convert error \else 文件转换错误 \endif
        NvsPassthroughConvertorErrorType_UnkownError = 65535           //!< \if ENGLISH task has unknown error \else 出现没有定义的错误 \endif
} NvsPassthroughConvertorErrorType;

/*! \if ENGLISH
 *  \brief Passthrough type
 *  \else
 *  \brief 直通类型
 *  \endif
*/
typedef enum {
    NvsPassthroughType_All = 0,                  //!< \if ENGLISH passthrough both video and audio \else 直通音视频 \endif
    NvsPassthroughType_OnlyVideo = 1,            //!< \if ENGLISH passthrough only video \else 只直通视频 \endif
    NvsPassthroughType_DisableTranscode = 2      //!< \if ENGLISH passthrough disable transcode. When the starting position is not an I-frame, the frames between the current frame and the I-frame will be transcoded. After disabling transcoding, passthrough will start from the last I-frame closest to the current location, and the output file will be slightly larger than the specified file length \else 禁用转码。当起始位置不是I帧的时候，会将当前帧与I帧之间的帧做转码。禁用转码后会从离当前位置最近的上一个I帧开始做直通，输出的文件会比指定的文件长度大一些。 \endif
} NvsPassthroughType;

#define PASSTHROUGH_OPTIMIZE_FOR_NETWORK_USE         @"optimize-for-network-use"       //!< \if ENGLISH Whether to prepose the index table, type: boolean \else 是否前置索引表，类型：bool，传true或者false \endif
#define PASSTHROUGH_CREATION_TIME                    @"creation time"                  //!< \if ENGLISH Set creation time for this file. Foramt:"YYYY-MM-DDTHH:MM:SS",eg:2010-12-24T12:00:00(use location time) \else 设置媒体文件的创建时间,格式:"YYYY-MM-DDTHH:MM:SS"例如：2010-12-24T12:00:00(使用LocationTime)\endif
#define PASSTHROUGH_METADATADESCRIPTION              @"metadata description"           //!< \if ENGLISH Corresponding AVMetadataCommonKeyDescription, sets the metadata description of the video files \else 对应AVMetadataCommonKeyDescription，设置视频文件的metadata描述，不支持中文 \endif

@protocol NvsPassthroughConvertorDelegate<NSObject>

- (void)didConvertorProgress:(int64_t)taskId progress:(float)progress;

- (void)didConvertorFinish:(int64_t)taskId errorCode:(NvsPassthroughConvertorErrorType)error errorString:(NSString*)errorString;

@end

/*! \if ENGLISH
*   \brief Passthrough file information description.
*   \else
*   \brief 直通文件信息描述
*   \endif
*   \since 3.12.0
*/
NVS_EXPORT @interface NvsPassthroughFileInfo : NSObject

@property (nonatomic) NSString *mediaFilePath;      //!< \if ENGLISH The absolute path to the media file. \else 媒体文件绝对路径 \endif
@property (nonatomic) int64_t trimIn;               //!< \if ENGLISH The in point of trimming (in microseconds) \else 裁剪入点(单位微秒) \endif
@property (nonatomic) int64_t trimOut;              //!< \if ENGLISH The out point of trimming (in microseconds) \else 裁剪出点(单位微秒) \endif

@end


NVS_EXPORT @interface NvsPassthroughConvertor : NSObject

@property (nonatomic, weak) id<NvsPassthroughConvertorDelegate> delegate;

- (instancetype)init;

/*! \if ENGLISH
 *  \brief Start to passthrough file
 *  \param srcFileInfos Source file infos
 *  \param dstFile Destination file
 *  \param configurations Passthrough params, only supports PASSTHROUGH_CREATION_TIME, PASSTHROUGH_OPTIMIZE_FOR_NETWORK_USE and PASSTHROUGH_METADATADESCRIPTION
 *  \param passthroughType Passthrough type
 *  \return Task ID
 *  \else
 *  \brief 开始直通
 *  \param srcFileInfos 源文件数据集
 *  \param dstFile 目标文件
 *  \param options 直通参数集合,只支持添加PASSTHROUGH_CREATION_TIME，PASSTHROUGH_OPTIMIZE_FOR_NETWORK_USE和PASSTHROUGH_METADATADESCRIPTION
 *  \param passthroughType 直通类型
 *  \return 直通任务ID
 *  \endif
 */
- (int64_t)convertMediaFile:(NSArray<NvsPassthroughFileInfo*>*)srcFileInfos
                 outputFile:(NSString *)outputFilePath
                    options:(NSMutableDictionary *)options
            passthroughType:(int)passthroughType;

- (void)cancelTask:(int64_t)taskId;

@end
/*! \endcond */

