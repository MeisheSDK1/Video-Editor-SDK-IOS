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

#import "NvsClip.h"
#import "NvsCustomAudioFx.h"

@class NvsAudioFx;

/*! \if ENGLISH
 *  \brief Audio clip, description of the audio file.
 *
 *  For audio clips, users can set its triming in-point and out-point, play speed, etc. Users can also add, insert, remove, and acquire multiple audio effects.
 *  \warning In the NvsAudioClip class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 音频片段，对音频文件的描述
 *
 *  音频片段既可以修改其裁剪入点和出点，播放速度等，还可以添加、插入、移除以及获取多个音频特效(Audio Fx)。
 *  \warning NvsAudioClip类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsAudioClip: NvsClip

/*! \if ENGLISH
 *  \brief Fade in duration (in microseconds), 0 means no fade-in.Duration must >= 0.
 *  \else
 *  \brief 淡入时长（单位微秒），为0表示没有淡入，单位为微秒。duration必须大于等于0
 *  \endif
 *  \since 1.16.0
*/
@property (nonatomic) int64_t fadeInDuration;

/*! \if ENGLISH
 *  \brief Fade out duration (in microseconds), 0 means no fade-out.Duration must >= 0.
 *  \else
 *  \brief 淡出时长（单位微秒），为0表示没有淡出，单位为微秒。duration必须大于等于0
 *  \endif
 *  \since 1.16.0
*/
@property (nonatomic) int64_t fadeOutDuration;

/*! \if ENGLISH
 *  \brief Appends special effects at the end of the clip
 *  \param fxName The name of special effect,please refer to [getAllBuiltinAudioFxNames()](@ref NvsStreamingContext::getAllBuiltinAudioFxNames) or [The List of Built-in Effect Name](\ref FxNameList.md).
 *  \return Returns the appended NvsAudioFx object.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine] (\ref EngineChange.md)。
 *  \else
 *  \brief 在片段尾部追加特效
 *  \param fxName 特效名称。获取特效名称，请参照[getAllBuiltinAudioFxNames()](@ref NvsStreamingContext::getAllBuiltinAudioFxNames)或[内建特效名称列表] (\ref FxNameList.md).
 *  \return 返回追加的音频特效对象
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa insertFx:fxIndex:
 *  \sa removeFx:
 *  \sa getFxWithIndex:
*/
- (NvsAudioFx *)appendFx:(NSString *)fxName;

/*! \if ENGLISH
 *  \brief Inserts a special effect at the index of the specified effect on the clip.
 *  \param fxName The name of special effect,please refer to [getAllBuiltinAudioFxNames()](@ref NvsStreamingContext::getAllBuiltinAudioFxNames) or [The List of Built-in Effect Name](\ref FxNameList.md).
 *  \param fxIndex The index of the specified effect. Range [0, [getFxCount()](@ref getFxCount) - 1 ). If index is outOfRange,It will be add in the end.
 *  \return Returns the inserted NvsAudioFx object.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine] (\ref EngineChange.md).
 *  \else
 *  \brief 在片段上指定特效索引处插入特效
 *  \param fxName 特效名称。获取特效名称，请参照[getAllBuiltinAudioFxNames()](@ref NvsStreamingContext::getAllBuiltinAudioFxNames)或[内建特效名称列表] (\ref FxNameList.md)。
 *  \param fxIndex 指定特效索引。范围[0, [getFxCount()](@ref getFxCount) - 1)。如果索引超出范围，会在最后面添加。
 *  \return 返回插入的音频特效对象
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa appendFx:
 *  \sa removeFx:
 *  \sa getFxWithIndex:
*/
- (NvsAudioFx *)insertFx:(NSString *)fxName fxIndex:(unsigned int)fxIndex;

/*! \if ENGLISH
*  \brief Appends custom audio effect to the clip.
*  \param NvsCustomAudioFx.Renderer User-implemented custom audio effect renderer interface.
*  \return Returns the appended audio effect object.
*  \warning This interface causes the streaming engine state to jump to the engine stop state. For more infomations please refer to [Engine Changes] (\ref EngineChange.md).
*  \else
*  \brief 在音频片段上追加自定义音频特效
*  \param NvsCustomAudioFx.Renderer 用户实现的自定义视频特效渲染器接口
*  \return 返回追加的音频特效对象
*  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
*	\endif
*/
- (NvsAudioFx *)appendCustomFx:(id<NvsCustomAudioFxRenderer>)customAudioFxRender;

/*! \if ENGLISH
*  \brief Inserts a custom audio effect at the specified effect index on the clip.
*  \param NvsCustomAudioFx.Renderer User-implemented custom audio effect renderer interface.
*  \param fxIndex audio effects' index to insert at.Range [0, [getFxCount()](@ref getFxCount) - 1 ). If index is outOfRange,It will be add in the end.
*  \return Returns the inserted audio effect object.
*  \warning This interface will cause the streaming engine state to jump to the engine stop state. For more information, please refer to [Engine Change] (\ref EngineChange.md).
*  \else
*  \brief 在片段上指定特效索引处插入自定义音频特效
*  \param NvsCustomAudioFx.Renderer 用户实现的自定义视频特效渲染器接口
*  \param fxIndex 插入音频特效索引。范围[0, [getFxCount()](@ref getFxCount) - 1)。如果索引超出范围，会在最后面添加。
*  \return 返回插入的音频特效对象
*  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
*	\endif
*/
- (NvsAudioFx *)insertCustomFx:(id<NvsCustomAudioFxRenderer>)customAudioFxRender fxIndex:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Removes the special effect from the specified index，The subsequent audioFx index moves forward
 *  \param fxIndex The index of the special effect. Range [0, [getFxCount()] (@ref getFxCount))
 *  \return Returns BOOL value. If the value is YES, the removal is successful, and the NO means it fails.
 *  \warning This interface will cause the streaming engine state to jump to the state of stopping engine. For details, please refer to [The Topic of Changing Engine] (\ref EngineChange.md).
 *  \else
 *  \brief 移除指定索引的特效，后面的特效索引前移。
 *  \param fxIndex 特效索引。范围[0, [getFxCount()] (@ref getFxCount))
 *  \return 返回BOOL值。值为YES则移除成功，NO则移除失败。
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa appendFx:
 *  \sa insertFx:fxIndex:
 *  \sa getFxWithIndex:
*/
- (BOOL)removeFx:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Gets the special effect by index
 *  \param fxIndex The index of the special effect. Range [0, [getFxCount()] (@ref getFxCount))
 *  \return Returns the acquired NvsAudioFx object.
 *  \else
 *  \brief 通过索引获取特效
 *  \param fxIndex 特效索引。范围[0, [getFxCount()] (@ref getFxCount))
 *  \return 返回获取的音频特效对象
 *  \endif
 *  \sa appendFx:
 *  \sa insertFx:fxIndex:
 *  \sa removeFx:
*/
- (NvsAudioFx *)getFxWithIndex:(unsigned int)fxIndex;

/*! \if ENGLISH
 *  \brief Remove all the effects.
 *  \return Determines whether the removal is successful. YES means that it's successful; NO means it fails.
 *  \else
 *  \brief 移除所有特效
 *  \return 判断是否移除成功。返回YES则移除成功，NO则失败。
 *  \endif
 *  \sa removeFx:
*/
- (BOOL)removeAllFx;

@end
