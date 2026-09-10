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

#import "NvsObject.h"
#import "NvsTimeline.h"

@class NvsAudioFx;

/*! \if ENGLISH
 *  \brief Clip type
 *  \else
 *  \brief 片段类型
 *  \endif
*/
typedef enum NvsClipType {
    NvsClipType_Video = 0,     //!< \if ENGLISH Video clip. \else 视频片段 \endif
    NvsClipType_Audio,         //!< \if ENGLISH Audio clip. \else 音频片段 \endif
} NvsClipType;


/*!
 * \if ENGLISH
 * \brief Defines the clip mode.
 * \details
 * This enum specifies how a clip is created and managed,
 * either from a media asset or directly on the timeline.
 * \else
 * \brief 定义片段模式
 * \details
 * 该枚举用于描述片段的创建和管理方式，
 * 包括从媒体资源创建或直接在时间线上创建。
 * \endif
 */
typedef enum NvsClipMode {
    NvsClipMode_Media = 0,     //!< \if ENGLISH Media clip mode (video or audio sourced from media files). \else 媒体片段模式 \endif
    NvsClipMode_Timeline,     //!< \if ENGLISH Timeline clip mode (clip generated or managed on the timeline). \else 时间线片段模式 \endif
} NvsClipMode;


/*! \if ENGLISH
 *  \brief Clips are specific description of audio and video files.
 *
 *  A clip is an entity that accommodates audio and video content and a description of video and audio files which divided into an audio clip and a video clip.
 *  It defines the common attributes and behaviors of different types of clips,that is,the derived audio clips and video clips can be modified as needed for each triming in and out point, left and right channel, playback speed, etc. In the SDK framework, corresponding audio clips and video clips can be added to the track.
 *  \warning In the NvsClip class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 片段，音视频文件的具体描述
 *
 *  片段是容纳音视频内容的实体，是对视频、音频文件的描述，分为音频片段(Audio Clip)和视频片段(Video Clip)。它定义了不同类型片段所拥有的共同属性和行为，
 *  即派生的音频片段和和视频片段可根据需要修改各自的裁剪出入点，左右声道，播放速度等。在SDK框架中，在轨道(Track)上可添加相应的音频片段和视频片段。
 *  \warning NvsClip类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsClip : NvsObject                                

@property (readonly) int64_t trimIn;             //!< \if ENGLISH Clip triming in point (in microseconds). \else 片段裁剪入点(单位微秒)\endif

@property (readonly) int64_t trimOut;            //!< \if ENGLISH Clip triming out point (in microseconds). \else 片段裁剪出点(单位微秒) \endif

@property (readonly) int64_t inPoint;            //!< \if ENGLISH The in point of the clip on the timeline (in microseconds). \else 片段在时间线上的入点(单位微秒) \endif

@property (readonly) int64_t outPoint;           //!< \if ENGLISH The out point of the clip on the timeline (in microseconds). \else 片段在时间线上的出点(单位微秒) \endif

@property (readonly) NvsClipType type;           //!< \if ENGLISH Clip type (video, audio). \else 片段类型（视频、音频） \endif

@property (readonly) unsigned int index;         //!< \if ENGLISH The index of the clip on the track. \else 片段在轨道上的索引 \endif

@property (readonly) NSString *filePath;         //!< \if ENGLISH File path of clip. \else 片段文件路径 \endif

@property (readonly) unsigned int fxCount;       //!< \if ENGLISH The count of special effects on the clip. \else 片段上的特效数量 \endif


/*!
 *  \if ENGLISH
 *  \brief Gets the clip mode.
 *  \return The current clip mode.
 *  The return value indicates whether the clip is created from a media asset
 *  (video/audio file) or created and controlled directly on the timeline.
 *  Please refer to @ref NvsClipMode.
 *  \else
 *  \brief 获取片段模式
 *  \return 当前片段模式。
 *  返回值表示片段是从媒体资源（视频/音频文件）创建，
 *  还是直接在时间线上创建并控制。
 *  请参见 @ref NvsClipMode
 *  \endif
 *  \since 3.13.0
 */
- (NvsClipMode)getClipMode;

/*!
 *  \if ENGLISH
 *  \brief Changes the clip mode.
 *  \param clipMode The new clip mode to set.
 *  The clip can be created from a media asset (video/audio file)
 *  or created and controlled directly on the timeline.
 *  Please refer to @ref NvsClipMode.
 *  \return YES if the clip mode is changed successfully; otherwise, NO.
 *  \else
 *  \brief 更改片段模式
 *  \param clipMode 要设置的新片段模式。
 *  片段可以从媒体资源（视频/音频文件）创建，
 *  或直接在时间线上创建并控制。
 *  请参见 @ref NvsClipMode
 *  \endif
 *  \since 3.13.0
 */
- (BOOL)changeClipMode:(NvsClipMode)clipMode;

/*! \if ENGLISH
 *  \brief Change the clip internal timeline
 *  \param timeline new timeline
 *  \return Returns whether suc.
 *  \else
 *  \brief 更改片段的时间线
 *  \param timeline 新的时间线
 *  \return 返回是否成功
 *	\endif
 *  \since 3.13.0
 */
- (BOOL)changeInternalTimeline:(NvsTimeline *)timeline;

/*! \if ENGLISH
 *  \brief Get the internal timeline object from the clip.
 *  \return Returns the timeline object of the clip.If the clip is not the timeline clip, returns nil.
 *  \else
 *  \brief 获取片段的时间线对象
 *  \return 返回时间线对象，如果片段不是时间线片段则返回nil
 *	\endif
 *  \since 2.24.0
 */
- (NvsTimeline *)getInternalTimeline;

/*! \if ENGLISH
 *  \brief Change the clip file path.
 *  \param filePath new file path
 *  \return Returns whether suc.
 *  \else
 *  \brief 更改片段文件路径
 *  \param filePath 新的文件路径
 *  \return 返回是否成功
 *	\endif
 */
- (BOOL)changeFilePath:(NSString *)filePath;

/*! \if ENGLISH
 *  \brief Change the trimming in point of the clip.
 *  \param newTrimInPoint New trimming in point (in microseconds)
 *  \param affectSibling Whether it affects other clips on the same track
 *  \return Returns the actual reachable trimming in point (in microseconds). Note: The range of the actual achievable trimming in point is [0,trimOut - 1].
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 修改片段裁剪入点
 *  \param newTrimInPoint 新裁剪入点(单位微秒)
 *  \param affectSibling 是否影响同轨道上其他片段
 *  \return 返回实际可到达的裁剪入点(单位微秒)。注意：实际可达到的裁剪入点范围在[0,trimOut - 1]
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa changeTrimOutPoint:affectSibling:
*/
- (int64_t)changeTrimInPoint:(int64_t)newTrimInPoint affectSibling:(BOOL)affectSibling;

/*! \if ENGLISH
 *  \brief Move trim points of clip(in microseconds)
 *  \param offset value，the existing trimIn + offset shall not exceed the original length of the clip
 *  \return Returns true if succeeded
 *  \since 2.18.1
 *  \else
 *  \brief 移动片段的裁剪入出点（微秒）
 *  \param offset 偏移值，已有的trimIn + offset不能超过片段的原始长度
 *  \return 如果移动成功返回true
 *  \since 2.18.1
 *	\endif
 */
- (BOOL)moveTrimPoint:(int64_t)offset;

/*! \if ENGLISH
 *  \brief Change the trimming out point of the clip.
 *  \param newTrimOutPoint New trimming out point (in microseconds)
 *  \param affectSibling Whether it affects other clips on the same track
 *  \return Returns the actual reachable trimming out point (in microseconds). Note: The range of the actual achievable trimming out point is [trimIn + 1,clipDuration).
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 修改片段裁剪出点
 *  \param newTrimOutPoint 新裁剪出点(单位微秒)
 *  \param affectSibling 是否影响同轨道上其他片段
 *  \return 返回实际可到达的裁剪出点(单位微秒)。注意：实际可达到的裁剪出点范围在[trimIn + 1,clipDuration),clipDuration为片段时长。
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa changeTrimInPoint:affectSibling:
*/
- (int64_t)changeTrimOutPoint:(int64_t)newTrimOutPoint affectSibling:(BOOL)affectSibling;

/*! \if ENGLISH
 *  \brief Get the playback speed of the clip.
 *
 *  The default value is 1, which means it plays at normal speed; the value less than 1 means it slowly plays; the value greater than 1 means it fast plays.
 *  \return Returns the playback speed of the current clip.
 *  \else
 *  \brief 获取片段的播放速度。
 *
 *  默认值为1，表示按正常速度播放;小于1的值表示慢放;大于1的值表示快放。
 *  \return 返回当前片段的播放速度
 *  \endif
 *  \sa changeSpeed:
*/
- (double)getSpeed;

/*! \if ENGLISH
 *  \brief Change the playback speed of the clip.
 *  \param newSpeed New playback speed.Attention newSpeed > 0.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 改变片段的播放速度
 *  \param newSpeed 新的播放速度,注意newSpeed > 0
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa getSpeed
*/
- (void)changeSpeed:(double)newSpeed;

/*! \if ENGLISH
 *  \brief Change the playback speed of the clip.
 *  \param newSpeed The new playback speed.Attention newSpeed > 0.
 *  \param keepAudioPitch Whether to keep the tone unchanged
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 改变片段的播放速度
 *  \param newSpeed 新的播放速度,注意newSpeed > 0
 *  \param keepAudioPitch 保持音调不变
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa getSpeed
 *  \since 1.15.1
*/
- (void)changeSpeed:(double)newSpeed keepAudioPitch:(BOOL)keepAudioPitch;

/*! \if ENGLISH
 *  \brief Get Audio Pitch State.
 *  \else
 *  \brief 获取音调状态
 *  \endif
 *  \sa changeSpeed
 *  \since 3.7.0
*/
-(BOOL)isKeepAudioPitch;

/*! \if ENGLISH
 *  \brief Changes the playback speed of the clip by curves(only support for video clip).
 *  \param curvesString description of the variable speed curves.
 *  \string foramt : (endpoint1)(endpoint1.backward)(endpoint1.frontward)(endpoint2)(endpoint2.backward)(endpoint2.frontward)……
 *  \coords foramt : (x,y)
 *  \note1 : the y coords means the multiple speed. the range of y is 0.001 to 100
 *  \note2 : all x coord values cannot be repeated. endpoint1.backward.x < endpoint1.x < endpoint1.frontward.x < endpoint2.backward.x <endpoint2.x……
 *  \note3 : if you set an empty  curvesString,it means you want to disable curves variable speed,the clip will back to const speed.
 *  \eg : curvesString = "(0,1)(-3,1)(3,1)(7,5)(6,5)(8,5)(10,0.4)(9,0.4)(11,0.4)(17,0.4)(16,0.4)(18,0.4)(20,5)(19,5)(21,5)(27,1)(24,1)(30,1)" curvesString included 6 group end point info .
 *  \param keepAudioPitch Keep the tone unchanged.
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state, see [Engine Change Feature] (\ref EngineChange.md) for details.
 *  \since 2.17.0
 *  \else
 *  \brief 使用贝塞尔曲线改变片段的播放速度(仅支持视频片段)
 *  \param curvesString 贝塞尔曲线描述字符串
 *  \字符串格式：(端点1坐标)(端点1后控制点坐标)(端点1前控制点坐标)(端点2坐标)(端点2后控制点坐标)(端点2前控制点坐标)(端点3坐标)(端点3后控制点坐标)(端点3前控制点坐标)……
 *  \坐标格式：(坐标X值，坐标Y值)
 *  \注1：Y坐标为播放倍速值，范围在0.001-100之间。
 *  \注2：每个端点及控制点的X坐标必须不能相等。大小规定为：端点1后控制点的X坐标 < 端点1的X坐标 <端点1的前控制点的X坐标 < 端点2后控制点的X坐标 < 端点2的X坐标……
 *  \注3：如果设置的curvesString为空字符串，则表示对该片段取消之前的曲线变速，恢复到匀速状态。
 *  \例如：curvesString = "(0,1)(-3,1)(3,1)(7,5)(6,5)(8,5)(10,0.4)(9,0.4)(11,0.4)(17,0.4)(16,0.4)(18,0.4)(20,5)(19,5)(21,5)(27,1)(24,1)(30,1)"包含了6组端点及其控制点坐标信息。
 *  \param keepAudioPitch 保持音调不变
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \since 2.17.0
 *	\endif
 */
- (BOOL)changeCurvesVariableSpeed:(NSString *)curvesString keepAudioPitch:(BOOL)keepAudioPitch;

/*! \if ENGLISH
 *  \brief get current variable speed curves of clip.
 *  \warning the x coords at the each output curves' endpoint is relative,user can scale x to any size. eg: scale curves range to equal with clip length.
 *  \sa changeCurvesVariableSpeed
 *  \since 2.17.0
 *  \else
 *  \brief 获得当前片段的变速曲线字符串
 *  \warning 获得的贝塞尔曲线中各点数据的横坐标均为相对位置关系，用户可以按需伸缩横轴坐标的比例，比如将曲线拉长到clip的长度。
 *  \sa changeCurvesVariableSpeed
 *  \since 2.17.0
 *	\endif
 */
- (NSString *)getClipVariableSpeedCurvesString;

/*! \if ENGLISH
 *  \brief Gets the pos in clip by current timeline pos when used curves variable speed.
 *  \return Returns long value to indicate the clip pos,return -1 indicate failed .
 *  \else
 *  \brief 在曲线变速状态下，通过给定时间线位置返回片段上的位置。
 *  \return 返回long 表示片段上的位置，返回-1表示失败。
 *	\endif
 *  \since 2.17.0
 */
- (int64_t)getClipPosByTimelinePosCurvesVariableSpeed:(int64_t) timelinePos;

/*! \if ENGLISH
 *  \brief Gets the pos in timeline by current clip pos when used curves variable speed.
 *  \return Returns long value to indicate the timeline pos,return -1 indicate failed .
 *  \else
 *  \brief 在曲线变速状态下，通过给定片段上位置返回时间线位置。
 *  \return 返回long 表示时间线上的位置，返回-1表示失败。
 *	\endif
 *  \since 2.17.0
 */
- (int64_t)getTimelinePosByClipPosCurvesVariableSpeed:(int64_t) clipPos;

/*! \if ENGLISH
 *  \brief Set the channels (left and right).
 *  \param leftVolumeGain The left channel value to be set, the range value is [0, 4).
 *  \param rightVolumeGain The right channel value to be set, the range value is [0, 4).
 *  \else
 *  \brief 设置声道（左声道和右声道）
 *  \param leftVolumeGain 要设置的左声道值，取值范围[0,4)。
 *  \param rightVolumeGain 要设置的右声道值，取值范围[0,4)。
 *  \endif
 *  \sa getVolumeGain:rightVolumeGain:
*/
- (void)setVolumeGain:(float)leftVolumeGain rightVolumeGain:(float)rightVolumeGain;

/*! \if ENGLISH
 *  \brief Get the channel values (left and right)
 *  \param leftVolumeGain The left channel value to be set, the range value is [0, 4).
 *  \param rightVolumeGain The right channel value to be set, the range value is [0, 4).
 *  \else
 *  \brief 获取置声道值（左声道和右声道）
 *  \param leftVolumeGain Output the left channel value.
 *  \param rightVolumeGain Output the right channel value.
 *  \endif
 *  \sa getVolumeGain:rightVolumeGain:
*/
- (void)getVolumeGain:(float *)leftVolumeGain rightVolumeGain:(float *)rightVolumeGain;

/*! \if ENGLISH
 *  \brief Get the real-time volume at a specified time point.
 *  \param leftVolumeGain The left channel volume.
 *  \param rightVolumeGain The right channel volume.
 *  \else
 *  \brief 获取指定时间点上的实时音量
 *  \param leftVolumeGain 左声道音量.
 *  \param rightVolumeGain 右声道音量.
 *	\endif
 *  \since 3.0.0
 */
- (void)getRealVolumeAtTime:(float *)leftVolume rightVolumeGain:(float *)rightVolume time:(int64_t)time;

/*! \if ENGLISH
 *  \brief Sets whether to loop audio if the clip' trim out go beyond its audio stream's duration
 *  \param loop whether to loop audio
 *  \else
 *  \brief 设置当前片段的剪辑出点超过其音频流长度时是否循环播放音频
 *  \param loop 是否循环播放音频
 *	\endif
 *  \sa getLoopAudio
 *  \since 2.9.0
 */
- (void)setLoopAudio:(BOOL)loop;

/*! \if ENGLISH
 *  \brief Gets whether to loop audio if the clip' trim out go beyond its audio stream's duration
 *  \return Returns boolean value to indicate whether to loop audio
 *  \else
 *  \brief 检查当前片段的剪辑出点超过其音频流长度时是否循环播放音频
 *  \return 返回Boolean值表示是否循环播放音频
 *	\endif
 *  \sa setLoopAudio
 *  \since 2.9.0
 */
- (BOOL)getLoopAudio;

/*! \if ENGLISH
 *  \brief Gets the audio volume effect of the clip
 *  \return Returns the obtained NvsAudioFx object.
 *  \else
 *  \brief 获取当前片段音量特效
 *  \return 返回获取的音频特效对象
 *  \endif
*/
- (NvsAudioFx *)getAudioVolumeFx;

@end

