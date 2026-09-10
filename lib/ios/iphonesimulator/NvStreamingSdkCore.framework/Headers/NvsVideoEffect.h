//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Sep 7. 2019
//   Author:        Meishe video team
//================================================================================
#pragma once

#import "NvsEffect.h"


/*! \if ENGLISH
 *  \brief The type of the video effect
 *  \else
 *  \brief 视频特效类型
 *  \endif
*/
typedef enum {
    NvsVideoEffectType_Builtin = 0,
    NvsVideoEffectType_Package,
    NvsVideoEffectType_Custom
} NvsVideoEffectType;


/*! \if ENGLISH
 *  \brief Video effect
 *
 *  The video effect can change the overall or partial color, brightness, transparency, etc. of the video image, so that the video can show a special effect.
 *  \warning In the NvsVideoEffect class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 视频特效
 *
 *  视频特效能够改变视频图像整体或者局部的颜色、亮度、透明度等，使视频显示出特殊的效果。
 *  \warning NvsVideoEffect类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsVideoEffect : NvsEffect

@property (readonly) NvsVideoEffectType type;   //!< \if ENGLISH The type of the video effect. \else 视频特效类型 \endif
@property (readonly) NSString *builtinName;     //!< \if ENGLISH The name of the built-in video effect. If it's not a built-in video effect, return nil. \else 内嵌视频特效名字。如果不是内嵌视频特效返回nil \endif
@property (readonly) NSString *packageId;       //!< \if ENGLISH The ID of the resource package video effect. If it's not a resource package video effect, return nil. \else 视频特效资源包ID。如果不是资源包视频特效返回nil \endif

/*! \if ENGLISH
  *  \brief Changes the in-point of the fx on the Clip.
  *  \param newInPoint The new in-point of the fx on the timeline (in microseconds).
  *  \return Returns the in-point of the fx on the Clip (in microseconds).
  *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change](\ref EngineChange.md).
  *  \else
  *  \brief 改变视频特效在片段上显示的入点,相对于每个片段的时间段，以当前片段的起始时间为时间起始点。
  *  \param newInPoint 视频特效在片段上的新的入点（单位微秒）
  *  \return 返回视频特效在片段上的显示的入点（单位微秒）
  *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
  *  \endif
  *  \sa changeOutPoint
  *  \sa getInPoint
  *  \sa movePosition
  *  \since 3.0.1
  */
- (int64_t)changeInPoint:(int64_t)newInPoint;

/*! \if ENGLISH
*  \brief Changes the out-point of the fx on the Clip.
*  \param newOutPoint The new out-point of the fx on the Clip (in microseconds).
*  \return Returns the out-point of the fx on the Clip (in microseconds).
*  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change].(\ref EngineChange.md).
*  \else
*  \brief 改变视频特效在片段上显示的出点,相对于每个片段的时间段，以当前片段的起始时间为时间起始点。
*  \param newOutPoint 视频特效在时间线上的新的出点（单位微秒）
*  \return 返回视频特效在片段上显示的出点（单位微秒）
*  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)
*  \endif
*  \sa changeInPoint
*  \sa getOutPoint
*  \sa movePosition
*  \since 3.0.1
*/
- (int64_t)changeOutPoint:(int64_t)newOutPoint;

@end

