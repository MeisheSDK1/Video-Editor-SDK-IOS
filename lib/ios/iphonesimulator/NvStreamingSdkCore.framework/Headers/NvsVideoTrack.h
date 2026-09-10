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

/*! \file NvsVideoTrack.h 
*/
#pragma once

#import "NvsTrack.h"
#import "NvsTimeline.h"
#import "NvsTrackCaption.h"
#import "NvsTrackCompoundCaption.h"
#import "NvsCustomVideoFx.h"
#import "NvsCustomVideoTransition.h"
#import "NvsTrackAnimatedSticker.h"

@class NvsVideoClip;
@class NvsVideoTransition;
@class NvsTrackVideoFx;

/*! \if ENGLISH
 *  \brief Track type
 *  \else
 *  \brief 轨道类型
 *  \endif
*/
typedef enum NvsTrackAddFxFlags {
    NvsTrackAddFxFlags_RenderAtClipRawFilter = 1,   //!< \if ENGLISH Render this effect when rendering the raw filter on video clip\else 在片段渲染Raw filter时候，渲染这个特效 \endif
} NvsTrackAddFxFlags;


/*! \if ENGLISH
 *  \brief Video track is the collection of video clips.
 *
 *  A video track is an entity that holds video clips. Users can add, insert, and delete multiple video clips on the track. As the clip increases,the video track continues to expand. Video transitions can be used between clips.
 *  The video clip source added to the video track can be video or image. If the clip source is an image, it is recommended to give priority to the path (localIdentifier) in the album.
 *  The loaded image resolution cannot be higher than 1920 * 1080, otherwise it will not be rendered on the Live Window.
 *  If the loaded image causes a black screen,etc., users need to consider reducing the resolution and reloading.
 *  When adding a package transition, users must install it firstly. After the installation, users can get the package Id and then use. For the built-in effects, obtains the names and then uses it.
 *
 *  Note: The index of the video clip starts from 0.
 *  \warning In the NvsVideoTrack class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 视频轨道，视频片段的集合
 *
 *  视频轨道是容纳视频片段的实体，可以添加、插入、删移多个视频片段。视频轨道随着片段的增加不断延展，而片段与片段之间可进行视频转场设置。
 *  视频轨道添加的视频片段源可以是视频或图片。如果片段源选择的是图片，建议优先给出相册里的路径（localIdentifier）。加载的图片分辨率不能高于1920 * 1080，否则在Live Window 上渲染不出来。
 *  如果加载的图片出现黑屏等现象，此时需考虑缩小分辨率再加载。添加包裹转场时，都得先安装，安装成功后获取packageId才能使用，而内建转场(builtin)只需获取转场名称即可使用。
 *
 *  注：视频片段的索引都是从0开始。
 *  \warning NvsVideoTrack类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsVideoTrack : NvsTrack

/*! \if ENGLISH
 *  \brief Appends clip at the end of the video track.
 *  \param filePath The path of clip. For the method of the clip path, please refer to the "filePath" which is the parameter of [addClip:inPoint:](@ref addClip:inPoint:).
 *  \return Returns the appended NvsVideoClip object.
 *
 *  The example is as follows:
 *
 *  ![] (@ref TrackClip.PNG)
 *  There are three clips C1, C2, and C3 on the video track in the above figure. If a new clip C4 is added to the end of the video track, the code is:
 *
 *          NvsVideoTrack *videoTrack;          //The object of videoTrack's creation is omitted here
 *          [videoTrack appendClip:filepath];   //filepath:the path of the clip C4.
 *
 *  After addition, the result is as follows:
 *  ![] (@ref TrackAppendClip.PNG)
 *  \warning This interface causes the streaming engine state to jump to the state of stopping engine. For more details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 在视频轨道尾部追加片段
 *  \param filePath 片段路径。对于片段路径方式，请参见[addClip:inPoint:] (@ref addClip:inPoint:)的参数filePath。
 *  \return 返回追加的视频片段对象
 *
 *  示例如下:
 *
 *  ![] (@ref TrackClip.PNG)
 *  上图中视频轨道上有三个片段C1、C2、C3, 如果在视频轨道尾部追加一个新的片段C4,实现代码：
 *
 *          NvsVideoTrack *videoTrack;//videoTrack这里省略创建
 *          [videoTrack appendClip:filepath];//filepath为C4片段的视频文件路径
 *
 *  追加后的结果:
 *  ![] (@ref TrackAppendClip.PNG)
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa insertClip:clipIndex:
 *  \sa getClipWithIndex:
 *  \sa appendClip:trimIn:trimOut:
*/
- (NvsVideoClip *)appendClip:(NSString *)filePath;

/*! \if ENGLISH
 *  \brief Appends a video clip of the specified duration to the end of the video track.
 *  \param filePath The path of clip. For the method of the clip path, please refer to the "filePath" which is the parameter of [addClip:inPoint:](@ref addClip:inPoint:).
 *  \param trimIn The in point of triming on the video clip (in microseconds)
 *  \param trimOut The out point of triming on the video clip (in microseconds)
 *  \return Returns the appended NvsVideoClip object.
 *
 *  For more information of triming in and out points, please refer to [The Topic of Triming In and Out Points] (\ref TrimInOut.md).
 *  \warning This interface causes the streaming engine state to jump to the state of stopping engine. For more details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \warning Parameters need to meet (0 <= trimIn < trimOut). If trimOut is bigger than the file original duration, it will be played in the last frame
 *  \else
 *  \brief 在轨道尾部追加指定长度的片段
 *  \param filePath 片段路径。对于片段路径方式，请参见[addClip:inPoint:] (@ref addClip:inPoint:)的参数filePath。
 *  \param trimIn 片段裁剪入点（单位微秒）
 *  \param trimOut 片段裁剪出点（单位微秒）
 *  \return 返回追加的视频片段对象
 *
 *  对于片段裁剪入点与出点的理解，具体请参见[裁剪入点与出点(trimIn and trimOut)] (\ref TrimInOut.md)专题。
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \warning 参数需要满足（0 <= trimIn < trimOut），如果trimOut大于素材本身长度，后面会以最后一帧播放。
 *  \endif
 *  \sa appendClip:
 *  \sa insertClip:clipIndex:
 *  \sa getClipWithIndex:
*/
- (NvsVideoClip *)appendClip:(NSString *)filePath trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut;

/*! \if ENGLISH
 *  \brief Inserts a video clip at the specified clip index on the video track.
 *  \param filePath The path of clip. For the method of the clip path, please refer to the "filePath" which is the parameter of [addClip:inPoint:](@ref addClip:inPoint:).
 *  \param clipIndex Index of the specified clip
 *  \return Returns the inserted NvsVideoClip object.
 *
 *  Calling the function of insertClip:clipIndex: inserts a clip before the clip of the specified "clipIndex". An example is as follows:
 *
 *  ![] (@ref TrackClip.PNG)
 *  There are three video clips C1, C2, and C3 on the track in the above figure, and the clip to be inserted is recorded as C4. If the clip is inserted before C1, the value of "clipIndex" is 0 and same rule can be used in other cases. The corresponding code is implemented as follows:
 *
 *         NvsVideoTrack *videoTrack;                       //The object of videoTrack's creation is omitted here
 *         [videoTrack insertClip:filepath clipIndex:0];    //filepath: the path of clip C4, and the value of "clipIndex" is [0, clipCount-1]
 *
 *  After insertion, the result is as follows:
 *  ![] (@ref TrackInsertClip.PNG)
 *  \warning This interface causes the streaming engine state to jump to the state of stopping engine. For more details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \warning If index is greater than the number of existing clips, it is added at the end.If the value of clipIndex is equal to 0, meanwhile the timeline contain themeLeader,the return object is null.If the value of clipIndex is more or equal to the clipCount of this track, meanwhile the timeline contain themeTrailer,the return object is null.
 *  \else
 *  \brief 在视频轨道上指定片段索引处插入片段
 *  \param filePath 片段路径。对于片段路径方式，请参见[addClip:inPoint:] (@ref addClip:inPoint:)的参数filePath。
 *  \param clipIndex 指定片段索引
 *  \return 返回插入的视频片段对象
 *
 *  调用insertClip:clipIndex:执行的是前插入即在clipIndex所表示的片段之前进行插入。示例如下:
 *
 *  ![] (@ref TrackClip.PNG)
 *  上图中轨道上有三个视频片段C1、C2、C3，待插入的片段记为C4。如果在C1之前插入,则clipIndex值为0,其它以此类推。相应代码实现如下：
 *
 *         NvsVideoTrack *videoTrack;                   //videoTrack这里省略创建
 *         [videoTrack insertClip:filepath clipIndex:0];//filepath为片段C4的路径,clipIndex取值为[0,clipCount-1]
 *
 *  插入后结果:
 *  ![] (@ref TrackInsertClip.PNG)
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \warning 如果clipIndex大于已有片段数量，则会在最后添加。如果clipIndex 等于0，当存在主题片头的时候，返回对象为空。如果clipIndex>=clipCount,此时如果存在主题片尾的话，返回对象为空。
 *  \endif
 *  \sa appendClip:
 *  \sa getClipWithIndex:
 *  \sa insertClip:trimIn:trimOut:clipIndex:
*/
- (NvsVideoClip *)insertClip:(NSString *)filePath clipIndex:(unsigned int)clipIndex;

/*! \if ENGLISH
 *	\brief Inserts a video clip of the specified duration at the specified clip index on the video track.
 *  \param filePath The path of clip. For the method of the clip path, please refer to the "filePath" which is the parameter of [addClip:inPoint:](@ref addClip:inPoint:).
 *  \param trimIn The in point of triming on the video clip (in microseconds)
 *  \param trimOut The out point of triming on the video clip (in microseconds)
 *	\param clipIndex Index of the specified clip
 *  \return Returns the inserted NvsVideoClip object.
 *
 *  The example is as followes:
 *
 *  ![] (@ref beforeInsertClip.PNG)
 *  There are three video clips C1, C2, C3 on the track in the above figure, and the clip C4 is to be inserted. The point indicated by the arrow on the C4 clip is the triming in and out point of the clip, and the C4 is inserted into the track after triming.
 *  Note: The trim in and out values must be within the duration of this clip, and the in point of triming value must be less than the out point of triming value. The implementation code is as follows:
 *
 *         NvsVideoTrack *videoTrack;   //The object of videoTrack's creation is omitted here
 *         //filepath: the path of clip C4. "trimIn" and "trimOut" are the values at the position indicated by the arrow on the C4 clip of the above figure, and the value of "clipIndex" is [0, clipCount-1].
 *         [videoTrack insertClip:filepath trimIn:trimIn trimOut:trimOut clipIndex:0];
 *
 *  After insertion, the result is as follows:
 *  ![] (@ref TrackInsertClip.PNG)
 *  \warning This interface causes the streaming engine state to jump to the state of stopping engine. For more details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \warning If index is greater than the number of existing clips, it is added at the end.If the value of clipIndex is equal to 0, meanwhile the timeline contain themeLeader,the return object is null.If the value of clipIndex is more or equal to the clipCount of this track, meanwhile the timeline contain themeTrailer,the return object is null.
 *  \warning Parameters need to meet (0 <= trimIn < trimOut). If trimOut is bigger than the file original duration, it will be played in the last frame
 *  \else
 *	\brief 在轨道上指定片段索引处插入指定长度的片段
 *  \param filePath 片段路径。对于片段路径方式，请参见[addClip:inPoint:] (@ref addClip:inPoint:)的参数filePath。
 *  \param trimIn 片段裁剪入点（单位微秒）
 *  \param trimOut 片段裁剪出点（单位微秒）
 *	\param clipIndex 指定片段索引
 *  \return 返回插入的视频片段对象
 *
 *  示例如下:
 *
 *  ![] (@ref beforeInsertClip.PNG)
 *  上图中轨道上有三个视频片段C1、C2、C3，以及待插入的片段C4。C4片段上箭头所指处即为片段裁剪的的入点和出点，裁剪后将对应片段插入到轨道上。注意：裁剪入点和出点值必须在此片段的时长范围里，且裁剪入点值必须小于裁剪出点值。实现代码如下：
 *
 *         NvsVideoTrack *videoTrack; //videoTrack这里省略创建
 *         [videoTrack insertClip:filepath trimIn:trimIn trimOut:trimOut clipIndex:0];//filepath为片段C4的路径,trimIn和trimOut为上图C4片段上箭头所指位置处的值，clipIndex取值为[0,clipCount-1]
 *
 *  插入后结果:
 *  ![] (@ref TrackInsertClip.PNG)
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \warning 参数需要满足（0 <= trimIn < trimOut），如果trimOut大于素材本身长度，后面会以最后一帧播放。
 *  \warning 如果clipIndex大于已有片段数量，则会在最后添加。如果clipIndex 等于0，当存在主题片头的时候，返回对象为空。如果clipIndex>=clipCount,此时如果存在主题片尾的话，返回对象为空。
 *  \endif
 *  \sa appendClip:trimIn:trimOut:
 *  \sa insertClip:clipIndex:
 *  \sa getClipWithIndex:
*/
- (NvsVideoClip *)insertClip:(NSString *)filePath trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut clipIndex:(unsigned int)clipIndex;

/*! \if ENGLISH
 *  \brief  Adds the clip.
 *  \param filePath The path of clip
 *
 *  For the clip's path in IOS, there are four ways:
 *
 *  a. When imported through the MPMediaQuery instance of the IPod Library, the clip's path format is as follows: "ipod-library://item/item.mp3?id=1217463725835578132";
 *
 *  b. When imported through the sand box path, the clip's path format is as follows: "/var/mobile/Containers/Data/Documents/tmp/video20170406101714.mp4";
 *
 *  c. Imports via the PHAset instance. The clip's path is as follows: "file:///var/mobile/Media/DCIM/100APPLE/IMG_0646.MP4".
 *  \param inPoint The in point Which the clip is on the timeline (in microseconds)
 *  \return Returns the added NvsVideoClip object.
 *
 *  For more information of the in and out points of a clip on the timeline, please refer to [The Topic of Triming In and Out Points] (\ref TrimInOut.md).
 *  \warning This interface causes the streaming engine state to jump to the state of stopping engine. For more details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 添加片段
 *  \param filePath 片段路径
 *
 *  IOS中，对于导入的音视频片段的路径，有四种方式：
 *
 *  a. 通过IPod Library库的MPMediaQuery实例导入，片段路径格式如下："ipod-library://item/item.mp3?id=1217463725835578132"；
 *
 *  b. 通过沙河路径路径导入，片段路径格式如下："/var/mobile/Containers/Data/Documents/tmp/video20170406101714.mp4"；
 *
 *  c. 通过PHAsset实例导入，片段路径如下："file:///var/mobile/Media/DCIM/100APPLE/IMG_0646.MP4"。
 *  \param inPoint 片段在时间线上的入点（单位微秒）
 *  \return 返回添加的视频片段对象
 *
 *  对于片段在时间线上的入点与出点的理解，具体请参见[裁剪入点与出点(trimIn and trimOut)] (\ref TrimInOut.md)专题。
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa appendClip:
 *  \sa insertClip:clipIndex:
 *  \sa addClip:inPoint:trimIn:trimOut:
*/
- (NvsVideoClip *)addClip:(NSString *)filePath inPoint:(int64_t)inPoint;

/*! \if ENGLISH
 *  \brief Adds a clip of the specified duration.
 *  \param filePath The path of clip. For the method of the clip path, please refer to the "filePath" which is the parameter of [addClip:inPoint:](@ref addClip:inPoint:).
 *  \param inPoint The in point which the clip is on the timeline (in microseconds)
 *  \param trimIn The in point of triming on the video clip (in microseconds)
 *  \param trimOut The out point of triming on the video clip (in microseconds)
 *  \return Returns the added NvsVideoClip object.
 *
 *  When users use addClip:inPoint: to add a clip, the clip which will be added split firstly the current clip at the specified in point on the timeline.
 *  Then, from the current specified in point, the clips which contain in the position corresponding to the duaration on the track are deleted according to the duration of the clip which will be added.
 *  Then Add a clip of the specified duration. If there is a gap in the corresponding position, it will be covered directly.
 *
 *  Example is as follows:
 *
 *  ![] (@ref beforeAddClip.PNG)
 *  As shown above, there are three video clips C1, C2, C3 on the track, and a clip C4 will be added. The Arrow pointing on the C4 clip are the triming in and out point of the clip. The arrow on the track is the in-point of the clip on the timeline.
 *  After triming, the clip of the specified duration is added on the track. The code is implemented as follows:
 *
 *         NvsVideoTrack *videoTrack;   //The object of videoTrack's creation is omitted here
 *         //filepath: the path of the clip C4, and "inPoint" is the value of the position indicated by the arrow on the track in the figure, "trimIn" and "trimOut" are the values at the position indicated by the arrow on the C4 clip of the above figure.
 *         [videoTrack addClip:filepath inPoint:inPoint trimIn:trimIn trimOut:trimOut];
 *
 *  When added, the results are as follows:
 *
 *  ![] (@ref afterAddClip.PNG)
 *  \warning This interface causes the streaming engine state to jump to the state of stopping engine. For more details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \warning Parameters need to meet (0 <= trimIn < trimOut). If trimOut is bigger than the file original duration, it will be played in the last frame
 *
 *  \else
 *  \brief 添加指定长度的片段
 *  \param filePath 片段路径。对于片段路径方式，请参见[addClip:inPoint] (@ref addClip:inPoint:)的参数filePath。
 *  \param inPoint 片段在时间线上的入点（单位微秒）
 *  \param trimIn 片段裁剪入点（单位微秒）
 *  \param trimOut 片段裁剪出点（单位微秒）
 *  \return 返回添加的视频片段对象
 *
 *  使用addClip:inPoint:添加片段时，待添加的片段会在时间线上指定的入点分割当前片段，再从当前指定的入点起，在轨道上按待添加片段的长度删除对应长度的位置里面所包含的片段，然后添加指定时长的片段。如果在对应位置上有空隙，则直接覆盖。
 *
 *  示例如下:
 *
 *  ![] (@ref beforeAddClip.PNG)
 *  如上图，轨道上有三个视频片段C1、C2、C3，以及待添加的片段C4。C4片段上箭头所指处即为片段裁剪的的入点和出点，轨道上箭头所指即为片段在时间线上的入点，裁剪后指定长度的片段将添加到轨道上。代码实现如下：
 *
 *         NvsVideoTrack *videoTrack; //videoTrack这里省略创建
 *         [videoTrack addClip:filepath inPoint:inPoint trimIn:trimIn trimOut:trimOut];//filepath为片段C4的路径,inPoint为图中轨道上箭头所指位置的值，trimIn和trimOut为上图C4片段上箭头所指位置处的值
 *
 *  添加后结果如下：
 *
 *  ![] (@ref afterAddClip.PNG)
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \warning 参数需要满足（0 <= trimIn < trimOut），如果trimOut大于素材本身长度，后面会以最后一帧播放。
 *  \endif
 *  \sa appendClip:trimIn:trimOut:
 *  \sa insertClip:trimIn:trimOut:clipIndex:
 *  \sa addClip:inPoint:
*/
- (NvsVideoClip *)addClip:(NSString *)filePath inPoint:(int64_t)inPoint trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut;

/*! \if ENGLISH
 *  \brief Appends a timeline clip at the end of the video track.
 *  \param timeline The timeline object to be appended.
 *  \return Returns the appended NvsVideoClip object.
 *  \warning This interface causes the streaming engine state to jump to the state of stopping engine. For more details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 在视频轨道尾部追加时间线片段
 *  \param timeline 待追加的时间线对象
 *  \return 返回追加的视频片段对象
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa insertTimelineClip:clipIndex:
 *  \sa getClipWithIndex:
 *  \sa appendTimelineClip:trimIn:trimOut:
 *  \since 2.24.0
*/
- (NvsVideoClip *)appendTimelineClip:(NvsTimeline *)timeline;

/*! \if ENGLISH
 *  \brief Appends a timeline clip of the specified duration to the end of the video track.
 *  \param timeline The timeline object to be appended.
 *  \param trimIn The in point of triming on the video clip (in microseconds)
 *  \param trimOut The out point of triming on the video clip (in microseconds)
 *  \return Returns the appended NvsVideoClip object.
 *  For more information of triming in and out points, please refer to [The Topic of Triming In and Out Points] (\ref TrimInOut.md).
 *  \warning This interface causes the streaming engine state to jump to the state of stopping engine. For more details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \warning Parameters need to meet (0 <= trimIn < trimOut). If trimOut is bigger than the file original duration, it will be played in the last frame
 *  \else
 *  \brief 在轨道尾部追加指定长度的时间线片段
 *  \param timeline 待追加的时间线对象
 *  \param trimIn 片段裁剪入点（单位微秒）
 *  \param trimOut 片段裁剪出点（单位微秒）
 *  \return 返回追加的视频片段对象
 *
 *  对于片段裁剪入点与出点的理解，具体请参见[裁剪入点与出点(trimIn and trimOut)] (\ref TrimInOut.md)专题。
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \warning 参数需要满足（0 <= trimIn < trimOut），如果trimOut大于待追加时间线长度，后面会以最后一帧播放。
 *  \endif
 *  \sa appendTimelineClip:
 *  \sa insertTimelineClip:clipIndex:
 *  \sa getClipWithIndex:
 *  \since 2.24.0
*/
- (NvsVideoClip *)appendTimelineClip:(NvsTimeline *)timeline trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut;

/*! \if ENGLISH
 *  \brief Inserts a timeline clip at the specified clip index on the video track.
 *  \param timeline The timeline object to be inserted.
 *  \return Returns the inserted NvsVideoClip object.
 *  \warning This interface causes the streaming engine state to jump to the state of stopping engine. For more details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \warning If index is greater than the number of existing clips, it is added at the end.If the value of clipIndex is equal to 0, meanwhile the timeline contain themeLeader,the return object is null.If the value of clipIndex is more or equal to the clipCount of this track, meanwhile the timeline contain themeTrailer,the return object is null.
 *  \else
 *  \brief 在视频轨道上指定片段索引处插入片段
 *  \param timeline 待插入的时间线对象
 *  \param clipIndex 指定片段索引
 *  \return 返回插入的视频片段对象
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \warning 如果clipIndex大于已有片段数量，则会在最后添加。如果clipIndex 等于0，当存在主题片头的时候，返回对象为空。如果clipIndex>=clipCount,此时如果存在主题片尾的话，返回对象为空。
 *  \endif
 *  \sa appendTimelineClip:
 *  \sa getClipWithIndex:
 *  \sa insertTimelineClip:trimIn:trimOut:clipIndex:
 *  \since 2.24.0
*/
- (NvsVideoClip *)insertTimelineClip:(NvsTimeline *)timeline clipIndex:(unsigned int)clipIndex;

/*! \if ENGLISH
 *	\brief Inserts a timeline clip of the specified duration at the specified clip index on the video track.
 *  \param timeline The timeline object to be inserted.
 *  \param trimIn The in point of triming on the video clip (in microseconds)
 *  \param trimOut The out point of triming on the video clip (in microseconds)
 *	\param clipIndex Index of the specified clip
 *  \return Returns the inserted NvsVideoClip object.
 *  \warning This interface causes the streaming engine state to jump to the state of stopping engine. For more details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \warning If index is greater than the number of existing clips, it is added at the end.If the value of clipIndex is equal to 0, meanwhile the timeline contain themeLeader,the return object is null.If the value of clipIndex is more or equal to the clipCount of this track, meanwhile the timeline contain themeTrailer,the return object is null.
 *  \warning Parameters need to meet (0 <= trimIn < trimOut). If trimOut is bigger than the inserted timeline duration, it will be played in the last frame
 *  \else
 *	\brief 在轨道上指定片段索引处插入指定长度的是时间线片段
 *  \param timeline 待插入的时间线对象
 *  \param trimIn 片段裁剪入点（单位微秒）
 *  \param trimOut 片段裁剪出点（单位微秒）
 *	\param clipIndex 指定片段索引
 *  \return 返回插入的视频片段对象
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \warning 参数需要满足（0 <= trimIn < trimOut），如果trimOut大于待插入时间线长度，后面会以最后一帧播放。
 *  \warning 如果clipIndex大于已有片段数量，则会在最后添加。如果clipIndex 等于0，当存在主题片头的时候，返回对象为空。如果clipIndex>=clipCount,此时如果存在主题片尾的话，返回对象为空。
 *  \endif
 *  \sa appendTimelineClip:trimIn:trimOut:
 *  \sa insertTimelineClip:clipIndex:
 *  \sa getClipWithIndex:
 *  \since 2.24.0
*/
- (NvsVideoClip *)insertTimelineClip:(NvsTimeline *)timeline trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut clipIndex:(unsigned int)clipIndex;

/*! \if ENGLISH
 *  \brief  Adds a timeline clip.
 *  \param timeline The timeline object to be added
 *  \param inPoint The in point Which the clip is on the timeline (in microseconds)
 *  \return Returns the added NvsVideoClip object.
 *
 *  For more information of the in and out points of a clip on the timeline, please refer to [The Topic of Triming In and Out Points] (\ref TrimInOut.md).
 *  \warning This interface causes the streaming engine state to jump to the state of stopping engine. For more details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 添加时间线片段
 *  \param timeline 待添加的时间线对象
 *  \param inPoint 片段在时间线上的入点（单位微秒）
 *  \return 返回添加的视频片段对象
 *
 *  对于片段在时间线上的入点与出点的理解，具体请参见[裁剪入点与出点(trimIn and trimOut)] (\ref TrimInOut.md)专题。
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa appendTimelineClip:
 *  \sa insertTimelineClip:clipIndex:
 *  \sa addTimelineClip:inPoint:trimIn:trimOut:
 *  \since 2.24.0
*/
- (NvsVideoClip *)addTimelineClip:(NvsTimeline *)timeline inPoint:(int64_t)inPoint;

/*! \if ENGLISH
 *  \brief Adds a timeline clip of the specified duration.
 *  \param timeline The timeline object to be added
 *  \param inPoint The in point which the clip is on the timeline (in microseconds)
 *  \param trimIn The in point of triming on the video clip (in microseconds)
 *  \param trimOut The out point of triming on the video clip (in microseconds)
 *  \return Returns the added NvsVideoClip object.
 *  \warning This interface causes the streaming engine state to jump to the state of stopping engine. For more details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \warning Parameters need to meet (0 <= trimIn < trimOut). If trimOut is bigger than the added timeline duration, it will be played in the last frame
 *  \else
 *  \brief 添加指定长度的片段
 *  \param timeline 待添加时间线对象
 *  \param inPoint 片段在时间线上的入点（单位微秒）
 *  \param trimIn 片段裁剪入点（单位微秒）
 *  \param trimOut 片段裁剪出点（单位微秒）
 *  \return 返回添加的视频片段对象
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \warning 参数需要满足（0 <= trimIn < trimOut），如果trimOut大于待添加时间线长度，后面会以最后一帧播放。
 *  \endif
 *  \sa appendTimelineClip:trimIn:trimOut:
 *  \sa insertTimelineClip:trimIn:trimOut:clipIndex:
 *  \sa addTimelineClip:inPoint:
 *  \since 2.24.0
*/
- (NvsVideoClip *)addTimelineClip:(NvsTimeline *)timeline inPoint:(int64_t)inPoint trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut;

/*! \if ENGLISH
 *  \brief Gets the video clip by index.
 *  \param clipIndex The index of clip. Range of "clipIndex" is [0,clipCount-1].
 *  \return Returns the obtained NvsVideoClip object.
 *  \else
 *  \brief 通过索引获取片段对象
 *  \param clipIndex 片段索引。clipIndex的取值范围：[0,clipCount-1]
 *  \return 返回获取的视频片段对象
 *  \endif
 *  \sa getClipWithTimelinePosition:
 *  \sa appendClip:
 *  \sa insertClip:clipIndex:
*/
- (NvsVideoClip *)getClipWithIndex:(unsigned int)clipIndex;

/*! \if ENGLISH
 *  \brief Gets the video clip by time.
 *  \param timelinePos The position on the timeline (in microseconds)
 *  \return Returns he obtained NvsVideoClip object.
 *  \else
 *  \brief 通过时间获取片段对象
 *  \param timelinePos 时间线上的位置（单位微秒）
 *  \return 返回获取的视频片段对象
 *  \endif
 *  \sa getClipWithIndex:
*/
- (NvsVideoClip *)getClipWithTimelinePosition:(int64_t)timelinePos;

/*! \if ENGLISH
 *  \brief Sets built-in transitions.
 *  \param srcClipIndex The index of the source video clip.Note:If the value of srcClipIndex is more than clipCount-2 of this track ,the return object is nil.
 *  \param  transitionName The name of the transition. if users want to get the video transition name, please refer to [getAllBuiltinVideoTransitionNames()] (@ref NvsStreamingContext::getAllBuiltinVideoTransitionNames) or [The List of Built-in Effect Name] (@ref FxNameList.md).
 *  Note: If the transition name is a null string, the original transition will be deleted.
 *  \return Returns the NvsVideoTransition object. If the transition name is a null string(namely, delete the original transition), the function will return null.
 *
 *  Example is as follows:
 *
 *  ![] (@ref Clip.PNG)
 *
 *  The video transition is used to realize a smooth transition between clips and avoid jumping when previewing videos.
 *  The transition must be set between the connected clips. Between the clips with gaps, the transition cannot be set.
 *  For instance, there are four video clips C1, C2, C3, C4 in the image above, we could set a built-in transition between C1 and C2, while we can't do it between C3 and C4.
 *  Codes are as follow:
 *
 *        NvsVideoTrack *videoTrack;
 *        [videoTrack setBuiltinTransition:0 withName:transitionName];
 *
 *  After setting a built-in transition, the result is as follow:
 *  ![] (@ref TrackTransition.PNG)
 *  \warning This interface causes the streaming engine state to jump to the state of stopping engine. For more details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief  设置内嵌式转场
 *  \param  srcClipIndex 源片段索引。注意：如果srcClipIndex 大于等于clipCount - 1，返回对象为空。
 *  \param  transitionName 转场名称。获取视频转场名称，请参见[getAllBuiltinVideoTransitionNames()] (@ref NvsStreamingContext::getAllBuiltinVideoTransitionNames)或[内建特效名称列表] (\ref FxNameList.md)。
 *  注意：转场名称若设为空字符串，则删除原有转场
 *  \return 返回设置的视频转场对象。若transitionName设为空字符串(即删除原有转场),返回nil
 *
 *  示例如下:
 *
 *  ![] (@ref Clip.PNG)
 *
 *  设置视频转场的作用是为了片段与片段间的平缓过渡，避免视频预览时出现跳跃。转场必须设置在相互连接的片段间，而在有空隙的片段之间，则不能设置视频转场。
 *  如上图中轨道上有四个视频片段C1、C、C3、C4,在C1和C2之间可以设置一个内嵌式转场，而C3和C4则不能设置视频转场。实现代码：
 *
 *        NvsVideoTrack *videoTrack;
 *        [videoTrack setBuiltinTransition:0 withName:transitionName];
 *
 *  设置转场后:
 *  ![] (@ref TrackTransition.PNG)
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa setPackagedTransition:withPackageId:
*/
- (NvsVideoTransition *)setBuiltinTransition:(unsigned int)srcClipIndex withName:(NSString *)transitionName;

/*! \if ENGLISH
 *  \brief Sets the package transition.
 *  \param srcClipIndex The index of the source video clip.Note:If the value of srcClipIndex is more than clipCount-2 of this track ,the return object is null.
 *  \param packageId The ID of the resource package. If the package Id is a null string, the transition will be deleted; if the package Id is set to "theme", the transition at the video clip will be set to the one in the current theme. Note: If there is no theme, the transition at the video clip will be deleted.
 *  \return Returns the NvsVideoTransition object.
 *  \warning This interface causes the streaming engine state to jump to the state of stopping engine. For more details, please refer to [The Topic of Changing Engine](\ref EngineChange.md).
 *  \else
 *  \brief 设置包裹转场
 *  \param srcClipIndex 源片段索引。注意：如果srcClipIndex 大于等于clipCount - 1，返回对象为空。
 *  \param packageId 资源包ID。若packageId为空，则删除该视频片段处的转场；若packageId设为"theme",则该视频片段处的转场设为当前主题的转场。注意：若无主题，则删除该视频片段处的转场。
 *  \return 返回设置的视频转场对象
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \endif
 *  \sa setBuiltinTransition:withName:
*/
- (NvsVideoTransition *)setPackagedTransition:(unsigned int)srcClipIndex withPackageId:(NSString *)packageId;

/*!
 *  \if ENGLISH
 *  \brief Sets custom video transition.
 *  \param srcClipIndex Source video clip index.Note:If the value of srcClipIndex is more than clipCount-2 of this track ,the return object is null.
 *  \param customVideoTransitionRender User-implemented custom video effects renderer interface;
 *  \return Returns the video transition object.
 *  \warning This interface will cause the streaming engine state to jump to the engine stop state. For details, please refer to [Engine Change](\ref EngineChange.md).
 *  \sa setBuiltinTransition
 *  \else
 *  \brief 设置自定义转场
 *  \param srcClipIndex 源视频片段索引。注意：如果srcClipIndex 大于等于clipCount - 1，返回对象为空。
 *  \param customVideoTransitionRender 用户自定义转场特效

 *  \return 返回设置的视频转场对象
 *  \warning 此接口会引发流媒体引擎状态跳转到引擎停止状态，具体情况请参见[引擎变化专题] (\ref EngineChange.md)。
 *  \sa setBuiltinTransition
 *  \endif
*/
- (NvsVideoTransition *)setCustomVideoTransition:(unsigned int)srcClipIndex withCustomRender:(id<NvsCustomVideoTransitionRenderer>)customVideoFxRender;

/*! \if ENGLISH
 *  \brief Gets the transition by the source clip index.
 *  \param srcClipIndex The index of the source clip.Note:If the value of srcClipIndex is more than clipCount-2 of this track ,the return object is null.
 *  \return Returns the obtained NvsVideoTransition object.
 *  \else
 *  \brief 通过源片段索引获取转场
 *  \param srcClipIndex 源片段索引。注意：如果srcClipIndex 大于等于clipCount - 1，返回对象为空。
 *  \return 返回获取的视频转场对象
 *  \endif
 *  \sa setBuiltinTransition:withName:
*/
- (NvsVideoTransition *)getTransitionWithSourceClipIndex:(unsigned int)srcClipIndex;

/*! \if ENGLISH
 *  \brief Get the first track video effect on the track.
 *  \return Returns the acquired NvsTrackVideoFx object.
 *  \since 2.15.0
 *  \else
 *  \brief 获取轨道上第一个轨道视频特效
 *  \return 返回获取的轨道视频特效对象
 *  \since 2.15.0
 *  \endif
*/
- (NvsTrackVideoFx *)getFirstTrackVideoFx;

/*! \if ENGLISH
 *  \brief Get the last track video effect on the track.
 *  \return Returns the acquired NvsTrackVideoFx object.
 *  \since 2.15.0
 *  \else
 *  \brief 获取轨道上最后一个轨道视频特效
 *  \return 返回获取的轨道视频特效对象
 *  \since 2.15.0
 *  \endif
*/
- (NvsTrackVideoFx *)getLastTrackVideoFx;

/*! \if ENGLISH
 *  \brief Get the previous track video effect of a track video effect on the track.
 *  \param videoFx The NvsTrackVideoFx object
 *  \return Returns the acquired NvsTrackVideoFx object.
 *  \since 2.15.0
 *  \else
 *  \brief 获取轨道上某个轨道视频特效的前一个轨道视频特效
 *  \param videoFx 轨道视频特效对象
 *  \return 返回获取的轨道视频特效对象
 *  \since 2.15.0
 *  \endif
*/
- (NvsTrackVideoFx *)getPrevTrackVideoFx:(NvsTrackVideoFx *)videoFx;

/*! \if ENGLISH
 *  \brief Get the next track video effect of a track video effect on the track.
 *  \param videoFx The NvsTrackVideoFx object
 *  \return Returns the acquired NvsTrackVideoFx object.
 *  \since 2.15.0
 *  \else
 *  \brief 获取轨道上某个轨道视频特效的下一个轨道视频特效
 *  \param videoFx 轨道视频特效对象
 *  \return 返回获取的轨道视频特效对象
 *  \since 2.15.0
 *  \endif
*/
- (NvsTrackVideoFx *)getNextTrackVideoFx:(NvsTrackVideoFx *)videoFx;

/*! \if ENGLISH
 *  \brief Get a list of track video effects based on position on the track.
 *  \param pos The position on the track (in microseconds)
 *  \return Returns an array of track video effects in current position.
 *  <br>The ordering rules for the acquired track video effects are as follows:
 *  <br>1.When adding, the in points are different, arranged in the order of the in points;
 *  <br>2.When adding, the entry points are the same, arranged in the order of adding timeline video effects.
 *  \since 2.15.0
 *  \else
 *  \brief 根据轨道上的位置获得轨道视频特效列表
 *  \param pos 轨道上的位置（单位微秒）
 *  \return 返回当前位置轨道视频特效对象的数组
 *  <br>获取的轨道视频特效排序规则如下：
 *  <br>1.添加时入点不同，按入点的先后顺序排列；
 *  <br>2.添加时入点相同，按添加轨道视频特效的先后顺序排列。
 *  \since 2.15.0
 *  \endif
*/
- (NSArray *)getTrackVideoFxByPosition:(int64_t)pos;

/*!
 *  \if ENGLISH
 *  \brief Turn on special effect rendering based on the original scale of the video track.
 *  \param Enable Turn on or not.
 *  \sa isOriginalRender
 *  \else
 *  \brief 开启按照视频轨道的原始比例进行特效渲染
 *  \param enable  是否开启
 *  \sa isOriginalRender
 *  \endif
*/
- (void)setEnableOriginalRender:(BOOL)enable;

/*!
 *  \if ENGLISH
 *  \brief Gets whether the original scale rendering mode is turned on.
 *  \return Turn on or not.
 *  \sa setEnableOriginalRender
 *  \else
 *  \brief 获取是否开启了原始比例渲染的模式
 *  \return 返回是否开启
 *  \sa setEnableOriginalRender
 *  \endif
*/
- (BOOL)isOriginalRender;

/*!
 *  \if ENGLISH
 *  \brief Disable the current track from rendering at the proxy scale.
 *  \param disable Disable or not.
 *  \sa isProxyScaleDisable
 *  \else
 *  \brief 设置当前轨道渲染的代理级别
 *  \param proxyScale  代理级别
 *  \sa isProxyScaleDisable
 *  \endif
 *  \since 2.19.1
*/
- (void)setProxyScale:(NvsRational)proxyScale;

/*!
 *  \if ENGLISH
 *  \brief Gets whether the current track is disabled from rendering at the proxy scale
 *  \return Disable or not.
 *  \sa disableProxyScale
 *  \else
 *  \brief 获取当前轨道渲染的代理级别
 *  \return 代理级别
 *  \sa setProxyScale
 *  \endif
 *  \since 2.19.1
*/
- (NvsRational)getProxyScale;

/*! \if ENGLISH
 *  \brief Get the first caption on the track.
 *  \return Returns the NvsTrackCaption object.
 *  \else
 *  \brief 获取轨道上的第一个字幕
 *  \return 返回获取的轨道字幕对象
 *  \endif
 *  \sa getLastCaption
 *  \sa addCaption
*/
- (NvsTrackCaption *)getFirstCaption;

/*! \if ENGLISH
 *  \brief Get the last caption on the track.
 *  \return Returns the NvsTrackCaption object.
 *  \else
 *  \brief 获取轨道上的最后一个字幕
 *  \return 返回获取的轨道字幕对象
 *  \endif
 *  \sa getFirstCaption
 *  \sa addCaption
*/
- (NvsTrackCaption *)getLastCaption;

/*! \if ENGLISH
 *  \brief Get the previous caption of the current caption on the track
 *  \param caption The current caption on the track
 *  \return Returns the NvsTrackCaption object.
 *  \else
 *  \brief 获取轨道上的当前字幕的前一个字幕
 *  \param caption 轨道上当前字幕对象
 *  \return 返回获取的轨道字幕对象
 *  \endif
 *  \sa getNextCaption
*/
- (NvsTrackCaption *)getPrevCaption:(NvsTrackCaption *)caption;

/*! \if ENGLISH
 *  \brief Get the next caption of the current caption on the track
 *  \param caption The current caption on the track
 *  \return Returns the NvsTrackCaption object.
 *  \else
 *  \brief 获取轨道上的当前字幕的前一个字幕
 *  \param caption 轨道上当前字幕对象
 *  \return 返回获取的轨道字幕对象
 *  \endif
 *  \sa getPrevCaption
*/
- (NvsTrackCaption *)getNextCaption:(NvsTrackCaption *)caption;

/*! \if ENGLISH
 *  \brief Get a list of captions based on the position on the track.
 *  \param trackPos The position on the track(in micro-second)
 *  \return Returns a list of arrays of captions at the current position。
 *  <br>The sorting rules for the obtained captions list are as follows:
 *  <br>1.When adding, the in points are different, and captions are arranged in the order of the in points;
 *  <br>2.When adding, the in points are the same, and captions are arranged in the order of adding captions.
 *  \else
 *  \brief 根据轨道上的位置获得字幕列表。
 *  \param trackPos 轨道上的位置（单位微秒）
 *  \return 返回当前位置字幕的List集合
 *  <br>获取的字幕列表排序规则如下：
 *  <br>1.添加时字幕入点不同，按入点的先后顺序排列；
 *  <br>2.添加时字幕入点相同，按添加字幕的先后顺序排列。
 *  \endif
 *  \sa addCaption
*/
- (NSArray *)getCaptionsByTimelinePosition:(int64_t)timelinePos;

/*! \if ENGLISH
 *  \brief Add a caption on the track
 *  \param captionText Text of caption
 *  \param inPoint The in point of the caption on the track (in microseconds)
 *  \param duration Caption display duration (in microseconds)
 *  \param captionStylePackageId Caption style package Id.If it does not exist, you can pass an empty string or null.
 *  \return Returns the NvsTrackCaption object.
 *  <br>It will return null in the following situations:
 *  <br>1. No caption function authorization;
 *  <br>2. If inPoint is less than 0 or greater than or equal to the current track duration, or duration is not greater than 0.
 *  \else
 *  \brief 在轨道上添加字幕
 *  \param captionText 字幕的文字
 *  \param inPoint 字幕在轨道上的起点（单位微秒）
 *  \param duration 字幕显示时长（单位微秒）
 *  \param captionStylePackageId 字幕样式包Id，不存在的话，可以传空字符串或者null
 *  \return 返回轨道字幕对象
 *  <br>以下情况会返回null：
 *  <br>1.没有字幕功能授权；
 *  <br>2.如果inPoint小于0或者大于等于当前轨道时长，或者duration不大于0。
 *  \endif
 *  \sa removeCaption
*/
- (NvsTrackCaption *)addCaption:(NSString *)captionText inPoint:(int64_t)inPoint duration:(int64_t)duration captionStylePackageId:(NSString *)captionStylePackageId;

/*! \if ENGLISH
 *  \brief Add a panorama caption on the track
 *  \param captionText Text of caption
 *  \param inPoint The in point of the caption on the track (in microseconds)
 *  \param duration Caption display duration (in microseconds)
 *  \param captionStylePackageId Caption style package Id.If it does not exist, you can pass an empty string or null.
 *  \return Returns the NvsTrackCaption object.
 *  <br>It will return null in the following situations:
 *  <br>1. No caption function authorization;
 *  <br>2. If inPoint is less than 0 or greater than or equal to the current track duration, or duration is not greater than 0.
 *  \else
 *  \brief 在轨道上添加全景图字幕
 *  \param captionText 字幕的文字
 *  \param inPoint 字幕在轨道上的入点（单位微秒）
 *  \param duration 字幕的显示时长（单位微秒）
 *  \param captionStylePackageId 字幕样式包Id，不存在的话，可以传空字符串或者null
 *  \return 返回轨道字幕对象
 *  <br>以下情况会返回null：
 *  <br>1.没有字幕功能授权；
 *  <br>2.如果inPoint小于0或者大于等于当前轨道时长，或者duration不大于0。
 *  \endif
 *  \since 1.6.0
 *  \sa removeCaption
*/
- (NvsTrackCaption *)addPanoramicCaption:(NSString *)captionText inPoint:(int64_t)inPoint duration:(int64_t)duration captionStylePackageId:(NSString *)captionStylePackageId;

   /*! \if ENGLISH
    *  \brief Add a modular caption on the track
    *  \param captionText Text of caption
    *  \param inPoint The in point of the caption on the track (in microseconds)
    *  \param duration Caption display duration (in microseconds)
    *  \return Returns the NvsTrackCaption object.
    *  <br>It will return null in the following situations:
    *  <br>1. No caption function authorization;
    *  <br>2. If inPoint is less than 0 or greater than or equal to the current track duration, or duration is not greater than 0.
    *  \else
    *  \brief 在轨道上添加模块字幕
    *  \param captionText 字幕的文字
    *  \param inPoint 字幕在轨道上的起点（单位微秒）
    *  \param duration 字幕显示时长（单位微秒）
    *  \return 返回轨道字幕对象
    *  <br>以下情况会返回null：
    *  <br>1.没有字幕功能授权；
    *  <br>2.如果inPoint小于0或者大于等于当前轨道时长，或者duration不大于0。
    *  \endif
    *  \sa removeCaption
    */
- (NvsTrackCaption *)addModularCaption:(NSString *)captionText inPoint:(int64_t)inPoint duration:(int64_t)duration;

/*! \if ENGLISH
 *  \brief Remove the caption on the track.
 *  \param caption track caption object which removed
 *  \return Returns the next NvsTrackCaption object.
 *  \else
 *  \brief 移除轨道上的字幕
 *  \param caption 要移除的轨道字幕对象
 *  \return 返回下一个轨道字幕对象
 *  \endif
 *  \sa addCaption
*/
- (NvsTrackCaption *)removeCaption:(NvsTrackCaption *)caption;

/*! \if ENGLISH
 *  \brief Get the first compound caption on the track.
 *  \return Returns the compound caption object.
 *  \else
 *  \brief 获取轨道上的第一个复合字幕
 *  \return 返回获取的轨道复合字幕对象
 *  \endif
 *  \since 2.9.0
 *  \sa getLastCompoundCaption
 *  \sa addCompoundCaption
 */
- (NvsTrackCompoundCaption *)getFirstCompoundCaption;

/*! \if ENGLISH
 *  \brief Get the last compound caption on the track.
 *  \return Returns the compound caption object.
 *  \else
 *  \brief 获取轨道上的最后一个复合字幕
 *  \return 返回获取的轨道复合字幕对象
 *  \endif
 *  \since 2.9.0
 *  \sa getFirstCompoundCaption
 *  \sa addCompoundCaption
 */
- (NvsTrackCompoundCaption *)getLastCompoundCaption;

/*! \if ENGLISH
 *  \brief Get the previous compound caption of the current compound caption on the track
 *  \param caption The current compound caption on the track
 *  \return Returns the compound caption object.
 *  \else
 *  \brief 获取轨道上的当前复合字幕的前一个复合字幕
 *  \param caption 轨道上当前复合字幕对象
 *  \return 返回获取的轨道复合字幕对象
 *  \endif
 *  \since 2.9.0
 *  \sa getNextCompoundCaption
 */
- (NvsTrackCompoundCaption *)getPrevCompoundCaption:(NvsTrackCompoundCaption *)caption;

/*! \if ENGLISH
 *  \brief Get the next compound caption of the current compound caption on the track
 *  \param caption The current compound caption on the track
 *  \return Returns the compound caption object.
 *  \else
 *  \brief 获取轨道上的当前复合字幕的前一个复合字幕
 *  \param caption 轨道上当前复合字幕对象
 *  \return 返回获取的轨道复合字幕对象
 *  \endif
 *  \since 2.9.0
 *  \sa getPrevCompoundCaption
*/
- (NvsTrackCompoundCaption *)getNextCompoundCaption:(NvsTrackCompoundCaption *)caption;

/*! \if ENGLISH
 *  \brief Get a list of compound captions based on the position on the track.
 *  \param trackPos The position on the track(in micro-second)
 *  \return Returns a list of compound captions at the current position。
 *  <br>The sorting rules for the obtained captions list are as follows:
 *  <br>1. If the in points are different, captions are sorted in the order of the in points;
 *  <br>2. If the in points are the same, and captions are sorted in the order of compound caption added.
 *  \else
 *  \brief 根据轨道上的位置获得复合字幕列表
 *  \param trackPos 轨道上的复合位置（单位微秒）
 *  \return 返回当前位置复合字幕的列表
 *  <br>获取的字幕列表排序规则如下：
 *  <br>1.如果字幕入点不同，按入点时间排列
 *  <br>2.如果字幕入点相同，按添加字幕的先后顺序排列。
 *  \endif
 *  \since 2.9.0
 *  \sa addCompoundCaption
*/
- (NSArray<NvsTrackCompoundCaption*> *)getCompoundCaptionsByTimelinePosition:(int64_t)timelinePos;

/*! \if ENGLISH
 *  \brief Add a caption on the track
 *  \param captionText Text of caption
 *  \param inPoint The in point of the caption on the track (in microseconds)
 *  \param duration Caption display duration (in microseconds)
 *  \param captionStylePackageId Caption style package Id.If it does not exist, you can pass an empty string or null.
 *  \return Returns the NvsTrackCaption object.
 *  <br>It will return null in the following situations:
 *  <br>1. No compound caption function authorization;
 *  <br>2. If inPoint is less than 0 or greater than or equal to the current track duration, or duration is not greater than 0.
 *  \else
 *  \brief 在轨道上添加字幕
 *  \param inPoint 字幕在轨道上的起点（单位微秒）
 *  \param duration 字幕显示时长（单位微秒）
 *  \param captionStylePackageId 字幕样式包Id，不存在的话，可以传空字符串或者null
 *  \return 返回轨道字幕对象
 *  <br>以下情况会返回null：
 *  <br>1.没有复合字幕功能授权；
 *  <br>2.如果inPoint小于0或者大于等于当前轨道时长，或者duration不大于0。
 *  \endif
 *  \since 2.9.0
 *  \sa removeCompoundCaption
*/
- (NvsTrackCompoundCaption *)addCompoundCaption:(int64_t)inPoint
                                          duration:(int64_t)duration
                          compoundCaptionPackageId:(NSString *)compoundCaptionPackageId;

/*! \if ENGLISH
 *  \brief Remove compound caption from the track.
 *  \param caption track compound caption object which to be removed
 *  \return Returns the next compound caption object.
 *  \else
 *  \brief 移除轨道上的复合字幕
 *  \param caption 要移除的轨道复合字幕对象
 *  \return 返回下一个轨道复合字幕对象
 *  \endif
 *  \since 2.9.0
 *  \sa addCompoundCaption
 */
- (NvsTrackCompoundCaption *)removeCompoundCaption:(NvsTrackCompoundCaption *)caption;

/*! \if ENGLISH
 *  \brief Get the first animated sticker on the track.
 *  \return Return the acquired NvsTrackAnimatedSticker object.
 *  \else
 *  \brief 获取轨道上第一个动画贴纸
 *  \return 返回获取的轨道动画贴纸对象
 *  \endif
 *  \sa getLastAnimatedSticker
 *  \sa addAnimatedSticker
*/
- (NvsTrackAnimatedSticker *)getFirstAnimatedSticker;

/*! \if ENGLISH
 *  \brief Get the last animated sticker on the track.
 *  \return Return the acquired NvsTrackAnimatedSticker object.
 *  \else
 *  \brief 获取轨道上最后一个动画贴纸
 *  \return 返回获取的轨道动画贴纸对象
 *  \endif
 *  \sa getFirstAnimatedSticker
*/
- (NvsTrackAnimatedSticker *)getLastAnimatedSticker;

/*! \if ENGLISH
 *  \brief Get the previous animated sticker of the current animated sticker of the track.
 *  \param animatedSticker the current NvsTrackAnimatedSticker obejct
 *  \return Return the acquired NvsTrackAnimatedSticker object.
 *  \else
 *  \brief 获取轨道当前动画贴纸的前一个动画贴纸
 *  \param animatedSticker 轨道动画贴纸对象
 *  \return 返回获取的轨道动画贴纸对象
 *  \endif
 *  \sa getNextAnimatedSticker
*/
- (NvsTrackAnimatedSticker *)getPrevAnimatedSticker:(NvsTrackAnimatedSticker *)animatedSticker;

/*! \if ENGLISH
 *  \brief Get the next animated sticker of the current animated sticker of the track.
 *  \param animatedSticker the current NvsTrackAnimatedSticker obejct
 *  \return Return the acquired NvsTrackAnimatedSticker object.
 *  \else
 *  \brief 获取轨道当前动画贴纸的后一个动画贴纸
 *  \param animatedSticker 轨道动画贴纸对象
 *  \return 返回获取的轨道动画贴纸对象
 *  \endif
 *  \sa getPrevAnimatedSticker
*/
- (NvsTrackAnimatedSticker *)getNextAnimatedSticker:(NvsTrackAnimatedSticker *)animatedSticker;

/*! \if ENGLISH
 *  \brief Get an animated sticker list based on the position on the track.
 *  \param trackPos Position on the track (in microseconds)
 *  \return Returns a list which holding the current position animated sticker object
 *  <br>The sorting rules for the obtained animated sticker list are as follows:
 *  <br>1.When adding, the in points are different,animated stickers are arranged in the order of the in points;
 *  <br>2.When adding, the in points are the same, they are arranged in the order in which the animation stickers are added.
 *  \else
 *  \brief 根据轨道上的位置获得动画贴纸列表
 *  \param trackPos 轨道上的位置（单位微秒）
 *  \return 返回保存当前位置动画贴纸对象的数组
 *  <br>获取的动画贴纸列表排序规则如下：
 *  <br>1.添加时入点不同，按入点的先后顺序排列；
 *  <br>2.添加时入点相同，按添加动画贴纸的先后顺序排列。
 *  \endif
 *  \sa addAnimatedSticker
*/
- (NSArray *)getAnimatedStickersByTimelinePosition:(int64_t)timelinePos;

/*! \if ENGLISH
 *  \brief Add a animated sticker on the track.
 *  \param inPoint The in point of the animated sticker on the track (in microseconds)
 *  \param duration The duration of the animation sticker which displayed (in microseconds)
 *  \param animatedStickerPackageId Animated sticker package Id
 *  \return Return the NvsTrackAnimatedSticker object.
 *  <br>It will return null in the following situations:
 *  <br>1. No animated sticker function authorization;
 *  <br>2. The animatedStickerPackageId is empty or null;
 *  <br>3. The animatedSticker has not install successed;
 *  <br>4. If inPoint is less than 0 or greater than or equal to the current track duration, or duration is not greater than 0.
 *  \else
 *  \brief 在轨道上添加动画贴纸
 *  \param inPoint 动画贴纸在轨道上的入点（单位微秒）
 *  \param duration 动画贴纸的显示时长（单位微秒）
 *  \param animatedStickerPackageId 动画贴纸包Id
 *  \return 返回轨道动画贴纸对象
 *  <br>以下情况会返回null：
 *  <br>1.没有动画贴纸功能授权；
 *  <br>2.animatedStickerPackageId参数为空字符串或者null；
 *  <br>3.该动画贴纸包没有安装成功；
 *  <br>4.如果inPoint小于0或者大于等于当前轨道时长，或者duration不大于0。
 *  \endif
 *  \sa removeAnimatedSticker
*/
- (NvsTrackAnimatedSticker *)addAnimatedSticker:(int64_t)inPoint duration:(int64_t)duration animatedStickerPackageId:(NSString*)animatedStickerPackageId;

/*! \if ENGLISH
 *  \brief Add a panorama animation sticker on the track.
 *  \param inPoint The in point of the animated sticker on the track (in microseconds)
 *  \param duration The duration of the animation sticker which displayed (in microseconds)
 *  \param animatedStickerPackageId Animated sticker package Id
 *  \return Return the NvsTrackAnimatedSticker object.
 *  <br>It will return null in the following situations:
 *  <br>1. No animated sticker function authorization or no panoramic function authorization;
 *  <br>2. The animatedStickerPackageId is empty or null;
 *  <br>3. The animatedSticker has not install successed;
 *  <br>4. If inPoint is less than 0 or greater than or equal to the current track duration, or duration is not greater than 0.
 *  \else
 *  \brief 在轨道上添加全景图动画贴纸
 *  \param inPoint 动画贴纸在轨道上的起点（单位微秒）
 *  \param duration 动画贴纸的显示时长（单位微秒）
 *  \param animatedStickerPackageId 动画贴纸资源包ID
 *  \return 返回轨道动画贴纸对象
 *  <br>以下情况会返回null：
 *  <br>1.没有动画贴纸功能授权或者没有全景编辑功能授权；
 *  <br>2.animatedStickerPackageId参数为空字符串或者null；
 *  <br>3.该动画贴纸包没有安装成功；
 *  <br>4.如果inPoint小于0或者大于等于当前轨道时长，或者duration不大于0。
 *  \endif
 *  \since 1.6.0
 *  \sa removeAnimatedSticker
*/
- (NvsTrackAnimatedSticker *)addPanoramicAnimatedSticker:(int64_t)inPoint duration:(int64_t)duration animatedStickerPackageId:(NSString*)animatedStickerPackageId;

/*! \if ENGLISH
 *  \brief Add a custom animated sticker on the track.
 *  \param inPoint The in point of custom animated sticker on the track (in microseconds)
 *  \param duration The duration of custom animation sticker which displayed (in microseconds)
 *  \param animatedStickerPackageId Animated sticker package Id
 *  \param customImagePath Path of custom animated sticker image(It can be a jpg, png image, or a dynamic caf format image supported by Meishe sdk)
 *  \return Return the NvsTrackAnimatedSticker object.
 *  <br>It will return null in the following situations:
 *  <br>1. No animated sticker function authorization;
 *  <br>2. The animatedStickerPackageId is empty or null;
 *  <br>3. The animatedSticker has not install successed;
 *  <br>4. If inPoint is less than 0 or greater than or equal to the current track duration, or duration is not greater than 0.
 *  <br>Note: If the return value is not null, you still cannot see the sticker effect, you need to check whether the customImagePath actually exists.
 *  \else
 *  \brief 在轨道上添加自定义动画贴纸
 *  \param inPoint 自定义动画贴纸在轨道上的入点（单位微秒）
 *  \param duration 自定义动画贴纸的显示时长（单位微秒）
 *  \param animatedStickerPackageId 自定义动画贴纸包Id
 *  \param customImagePath 自定义动画贴纸图像路径（可以是jpg、png图像，或者美摄sdk内部支持的动态caf格式图像）
 *  \return 返回轨道自定义动画贴纸对象
 *  <br>以下情况会返回null：
 *  <br>1.没有动画贴纸功能授权；
 *  <br>2.animatedStickerPackageId参数为空字符串或者null；
 *  <br>3.该动画贴纸包没有安装成功；
 *  <br>4.如果inPoint小于0或者大于等于当前轨道时长，或者duration不大于0。
 *  <br>注意：如果返回值非空，依旧看不到贴纸效果，需要检查customImagePath是否真实存在
 *  \endif
 *  \sa removeAnimatedSticker
*/
- (NvsTrackAnimatedSticker *)addCustomAnimatedSticker:(int64_t)inPoint duration:(int64_t)duration animatedStickerPackageId:(NSString*)animatedStickerPackageId customImagePath:(NSString*)customImagePath;

/*! \if ENGLISH
 *  \brief Add a a custom panorama animated sticker on the track.
 *  \param inPoint The in point of custom animated sticker on the track (in microseconds)
 *  \param duration The duration of custom animation sticker which displayed (in microseconds)
 *  \param animatedStickerPackageId Animated sticker package Id
 *  \param customImagePath Path of custom animated sticker image
 *  \return Return the NvsTrackAnimatedSticker object.
 *  <br>It will return null in the following situations:
 *  <br>1. No animated sticker function authorization or no panoramic function authorization;
 *  <br>2. The animatedStickerPackageId is empty or null;
 *  <br>3. The animatedSticker has not install successed;
 *  <br>4. If inPoint is less than 0 or greater than or equal to the current track duration, or duration is not greater than 0.
 *  <br>Note: If the return value is not null, you still cannot see the sticker effect, you need to check whether the customImagePath actually exists.
 *  \else
 *  \brief 在轨道上添加自定义全景图动画贴纸
 *  \param inPoint 动画贴纸在轨道上的起点（单位微秒）
 *  \param duration 动画贴纸的显示时长（单位微秒）
 *  \param animatedStickerPackageId 动画贴纸资源包ID
 *  \param customImagePath 自定义动画贴纸图像路径（可以是jpg、png图像，或者美摄sdk内部支持的动态caf格式图像）
 *  \return 返回轨道动画贴纸对象
 *  <br>以下情况会返回null：
 *  <br>1.没有动画贴纸功能授权或者没有全景编辑功能授权；
 *  <br>2.animatedStickerPackageId参数为空字符串或者null；
 *  <br>3.该动画贴纸包没有安装成功；
 *  <br>4.如果inPoint小于0或者大于等于当前轨道时长，或者duration不大于0。
 *  <br>注意：如果返回值非空，依旧看不到贴纸效果，需要检查customImagePath是否真实存在
 *  \endif
 *  \since 1.6.0
 *  \sa removeAnimatedSticker
*/
- (NvsTrackAnimatedSticker *)addCustomPanoramicAnimatedSticker:(int64_t)inPoint duration:(int64_t)duration animatedStickerPackageId:(NSString*)animatedStickerPackageId customImagePath:(NSString*)customImagePath;

/*! \if ENGLISH
 *  \brief Remove an animated sticker on the track.
 *  \param animatedSticker The NvsTrackAnimatedSticker object which will be removed
 *  \return Return the next NvsTrackAnimatedSticker object.
 *  \else
 *  \brief 移除轨道上的动画贴纸
 *  \param animatedSticker 要移除的动画贴纸对象
 *  \return 返回下一个轨道动画贴纸对象
 *  \endif
 *  \sa addAnimatedSticker
*/
- (NvsTrackAnimatedSticker *)removeAnimatedSticker:(NvsTrackAnimatedSticker *)animatedSticker;

/*! \if ENGLISH
 *  \brief Update the audio information in the current track effect.
 *  \return
 *  \else
 *  \brief 更新当前轨道特效中携带的音频信息。
 *  \return 无返回值。
 *  \endif
 *  \since 3.8.0
*/
- (void)updateAudioForTrackVideoFx;

/*! \if ENGLISH
 *  \brief Add a built-in track video effect on the track
 *  \param inPoint The in point of the track video effect on the track (in microseconds)
 *  \param duration Duration of the track video effect which displayed (in microseconds)
 *  \param videoFxName The video effect name
 *  \return Return the NvsTrackVideoFx object
 *  \since 2.15.0
 *  \else
 *  \brief 在轨道上添加内嵌的轨道视频特效
 *  \param inPoint 轨道视频特效在时间线上的入点（单位微秒）
 *  \param duration 轨道视频特效显示的时长（单位微秒）
 *  \param videoFxName 内嵌的轨道视频特效名字
 *  \return 返回轨道视频特对象
 *  \since 2.15.0
 *  \endif
*/
- (NvsTrackVideoFx *)addBuiltinTrackVideoFx:(int64_t)inPoint duration:(int64_t)duration videoFxName:(NSString *)videoFxName;

/*! \if ENGLISH
 *  \brief Add a built-in track video effect on the track
 *  \param inPoint The in point of the track video effect on the track (in microseconds)
 *  \param duration Duration of the track video effect which displayed (in microseconds)
 *  \param videoFxName The video effect name
 *  \param flags Special flag for previewing. If there is no special need, please fill in 0. Please refer to [NvsTrackAddFxFlags] (@ref NvsTrackAddFxFlags).
 *  \return Return the NvsTrackVideoFx object
 *  \since 3.8.0
 *  \else
 *  \brief 在轨道上添加内嵌的轨道视频特效
 *  \param inPoint 轨道视频特效在时间线上的入点（单位微秒）
 *  \param duration 轨道视频特效显示的时长（单位微秒）
 *  \param videoFxName 内嵌的轨道视频特效名字
 *  \param flags 标志字段，如无特殊需求，请填写0。请参见 [NvsTrackAddFxFlags] (@ref NvsTrackAddFxFlags)
 *  \return 返回轨道视频特对象
 *  \since 3.8.0
 *  \endif
*/
- (NvsTrackVideoFx *)addBuiltinTrackVideoFx:(int64_t)inPoint duration:(int64_t)duration videoFxName:(NSString *)videoFxName flags:(int)flags;

/*! \if ENGLISH
 *  \brief Add a track video effect in the form of a resource package on the track.
 *  \param inPoint The in point of the track video effect on the track (in microseconds)
 *  \param duration  Duration of the timeline video effect which displayed (in microseconds)
 *  \param videoFxPackageId The Id of resource package
 *  \return Return the NvsTrackVideoFx object
 *  \since 2.15.0
 *  \else
 *  \brief 在轨道上添加资源包形式的轨道视频特效
 *  \param inPoint 轨道视频特效在时间线上的入点（单位微秒）
 *  \param duration 轨道视频特效显示的时长（单位微秒）
 *  \param videoFxPackageId 轨道视频特效资源包Id
 *  \return 返回轨道视频特对象
 *  \since 2.15.0
 *  \endif
*/
- (NvsTrackVideoFx *)addPackagedTrackVideoFx:(int64_t)inPoint duration:(int64_t)duration videoFxPackageId:(NSString *)videoFxPackageId;

/*! \if ENGLISH
 *  \brief Add a track video effect in the form of a resource package on the track.
 *  \param inPoint The in point of the track video effect on the track (in microseconds)
 *  \param duration  Duration of the timeline video effect which displayed (in microseconds)
 *  \param videoFxPackageId The Id of resource package
 *  \param flags Special flag for previewing. If there is no special need, please fill in 0. Please refer to [NvsTrackAddFxFlags] (@ref NvsTrackAddFxFlags).
 *  \return Return the NvsTrackVideoFx object
 *  \since 3.8.0
 *  \else
 *  \brief 在轨道上添加资源包形式的轨道视频特效
 *  \param inPoint 轨道视频特效在时间线上的入点（单位微秒）
 *  \param duration 轨道视频特效显示的时长（单位微秒）
 *  \param videoFxPackageId 轨道视频特效资源包Id
 *  \param flags 标志字段，如无特殊需求，请填写0。请参见 [NvsTrackAddFxFlags] (@ref NvsTrackAddFxFlags)
 *  \return 返回轨道视频特对象
 *  \since 3.8.0
 *  \endif
*/
- (NvsTrackVideoFx *)addPackagedTrackVideoFx:(int64_t)inPoint duration:(int64_t)duration videoFxPackageId:(NSString *)videoFxPackageId flags:(int)flags;

/*! \if ENGLISH
 *  \brief Add a custom track video effect on the track
 *  \param inPoint The in point of the track video effect on the track (in microseconds)
 *  \param duration  Duration of the track video effect which displayed (in microseconds)
 *  \param customVideoFxRender User-implemented custom video effects renderer interface
 *  \return Return the NvsTrackVideoFx object
 *  \since 2.15.0
 *  \else
 *  \brief 在轨道上添加自定义轨道视频特效
 *  \param inPoint 轨道视频特效在时间线上的入点（单位微秒）
 *  \param duration 轨道视频特效的时长（单位微秒）
 *  \param customVideoFxRender 用户实现的自定义视频特效渲染器接口
 *  \return 返回轨道视频对象
 *  \endif
 *  \since 2.15.0
*/
- (NvsTrackVideoFx *)addCustomTrackVideoFx:(int64_t)inPoint
                                  duration:(int64_t)duration
                       customVideoFxRender:(id<NvsCustomVideoFxRenderer>)customVideoFxRender;

/*! \if ENGLISH
 *  \brief Remove a track video effect from the track.
 *  \param videoFx The NvsTrackVideoFx object which will be removed
 *  \return Returns the next NvsTrackVideoFx object of current track video effect which has removed.
 *  \since 2.15.0
 *  \else
 *  \brief 移除轨道上的轨道视频特效
 *  \param videoFx 要移除的轨道视频特效对象
 *  \return 返回被删除的轨道视频特效的下一个轨道视频特效对象
 *  \since 2.15.0
 *  \endif
*/
- (NvsTrackVideoFx *)removeTrackVideoFx:(NvsTrackVideoFx *)videoFx;

@end
