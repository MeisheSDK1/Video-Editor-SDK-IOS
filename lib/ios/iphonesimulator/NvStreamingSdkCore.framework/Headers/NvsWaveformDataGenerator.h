//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2021. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Apr 08. 2021
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import "NvsAVFileInfo.h"

@protocol NvsWaveformDataGeneratorDelegate <NSObject>
@optional

/*! \if ENGLISH
 *  \brief waveform data generate successfully
 *  \param taskId task Id
 *  \param audioFilePath audio file path
 *  \param audioFileSampleCount audio file samples count
 *  \param samplesPerGroup number of samples per group
 *  \param leftWaveformData left channel waveform data
 *  \param rightWaveformData right channel waveform data
 *  \else
 *  \brief 波形数据生成成功
 *  \param taskId 任务序号
 *  \param audioFilePath 音频文件路径
 *  \param audioFileSampleCount 音频文件采样总数
 *  \param samplesPerGroup 每一组的采样数
 *  \param leftWaveformData 左声道波形数据
 *  \param rightWaveformData 右声道波形数据
 *  \endif
 *  \since 2.21.0
 */
- (void)didWaveformDataReady:(int64_t)taskId audioFilePath:(NSString*)audioFilePath audioFileSampleCount:(int64_t)audioFileSampleCount samplesPerGroup:(int64_t)samplesPerGroup leftWaveformData:(NSData *)leftWaveformData rightWaveformData:(NSData *)rightWaveformData;

/*! \if ENGLISH
 *  \brief waveform data generate failed
 *  \param taskId task Id
 *  \param audioFilePath audio file path
 *  \param samplesPerGroup number of samples per group
 *  \else
 *  \brief 波形数据生成失败
 *  \param taskId 任务序号
 *  \param audioFilePath 音频文件路径
 *  \param samplesPerGroup 每一组的采样数
 *  \endif
 *  \since 2.21.0
 */
- (void)didWaveformDataGenerationFailed:(int64_t)taskId audioFilePath:(NSString*)audioFilePath samplesPerGroup:(int64_t)samplesPerGroup;

@end

/*! \if ENGLISH
*   \brief Audio waveform data generator.
*
*   Audio waveform data generation class
*   \warning In the NvsWaveformDataGenerator class, all public APIs are used in the UI thread! ! !
*   \else
*   \brief 多缩略图序列
*
*   音频波形数据生成类。
*   \warning NvsWaveformDataGenerator类中，所有public API都在UI线程使用！！！
*   \endif
*   \since 2.21.0
*/
NVS_EXPORT @interface NvsWaveformDataGenerator : NSObject
@property (nonatomic, weak) id<NvsWaveformDataGeneratorDelegate> delegate;

/*! \if ENGLISH
 *  \brief Initialization.
 *  \return Returns the NvsWaveformDataGenerator object.
 *  \else
 *  \brief 初始化
 *  \return 返回对象实例
 *  \endif
 *  \since 2.21.0
*/
- (instancetype)init;

/*! \if ENGLISH
 *  \brief Get the audio file duration
 *  \param audioFilePath audio file path
 *  \return Return the audio file duration
 *  \else
 *  \brief 获取音频文件时长(单位微秒)
 *  \param audioFilePath 音频文件路径
 *  \return 返回音频文件时长
 *  \endif
 *  \since 2.21.0
*/
- (int64_t)getAudioFileDuration:(NSString*)audioFilePath;

/*! \if ENGLISH
 *  \brief Get the audio file sample count
 *  \param audioFilePath audio file path
 *  \return Return the audio file sample count
 *  \else
 *  \brief 获取音频文件采样数
 *  \param audioFilePath 音频文件路径
 *  \return 返回音频文件采样数
 *  \endif
 *  \since 2.21.0
*/
- (int64_t)getAudioFileSampleCount:(NSString*)audioFilePath;

/*! \if ENGLISH
 *  \brief cancel task
 *  \param taskId task id
 *  \else
 *  \brief 取消任务
 *  \param taskId 任务号
 *  \endif
 *  \since 2.21.0
*/
- (void)cancelTask:(int64_t)taskId;

/*! \if ENGLISH
 *  \brief Get the audio waveform data
 *  \param audioFilePath audio file path
 *  \param samplesPerGroup number of samples per group
 *  \param startGroupIndex start group index
 *  \param groupCount group count.When 0 is passed in and startgroupindex is also 0, all audio file data will be obtained
 *  \param flags flag field. If there is no special requirement, please fill in
 *  \return Return the task id
 *  \else
 *  \brief 获取音频波形数据
 *  \param audioFilePath 音频文件路径
 *  \param samplesPerGroup 每组采样数
 *  \param startGroupIndex 起始组序号
 *  \param groupCount 组数量 当传入0并且startGroupIndex也为0时为获取全部音频文件数据
 *  \param flags 标志字段，如无特殊需求请填写0
 *  \return 返回任务号
 *  \endif
 *  \since 2.21.0
*/
- (int64_t)generateWaveformData:(NSString*)audioFilePath samplesPerGroup:(int64_t)samplesPerGroup startGroupIndex:(int64_t)startGroupIndex groupCount:(int64_t)groupCount flags:(int)flags;

- (void)notifyWaveformDataReady:(int64_t)waveformTaskId samplesPerGroup:(int64_t)samplesPerGroup leftWaveformData:(NSData *)leftWaveformData rightWaveformData:(NSData *)rightWaveformData;

- (void)notifyWaveformDataFailed:(int64_t)waveformTaskId samplesPerGroup:(int64_t)samplesPerGroup;

@end

