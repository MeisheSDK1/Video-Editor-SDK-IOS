//
//  NvTimelineUtils.h
//  SDKDemo
//
//  说明：resetXXX接口适用于编辑过程中编辑信息的非连续变化操作，例如按钮的点击操作；不适用于信息的连续变化操作，例如滑动条的滑动的响应处理。

//  Note: The resetXXX interface is suitable for non-continuous operation of editing information during the editing process, such as button click operation; It is not suitable for the operation of continuous change of information, such as the response processing of sliding bar.
//
//  Created by shizhouhu on 2018/6/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsTimeline.h"
#import "NvsVideoTrack.h"
#import "NvsAudioTrack.h"
#import "NvTimelineData.h"
#import <NvSDKCommon/NvUtils.h>
#import "NvsVideoClip.h"
#import "NvsMultiThumbnailSequenceView.h"
#import "NvRecordingInfo.h"
NS_ASSUME_NONNULL_BEGIN
#define NV_TIME_BASE 1000000
#define TIMELINE_FX_REVERSE  1
#define TIMELINE_FX_REPEAT   2
#define TIMELINE_FX_SLOWMOTION  3


#define NV_MUSIC_SOUND_TRACK     0    //音乐轨道 Musical track
#define NV_DUBBING_SOUND_TRACK   1    //配音音轨 Dub track
#define VIDEO_FX_TYPE @"videoFxType" //背景特效类型 Background effects type
#define CLIP_BACKGROUND_ATTACHMENT @"clipBackgroundAttachment" //背景特效样式 Background effect style
#define CLIP_BACKGROUND_TRANSFORM_ATTACHMENT @"clipBackgroundTransformAttachment" //背景特效中关于缩放平移旋转的attachment attachment for scaling, translation and rotation in background effects
#define CLIP_PROPERTY_BACKGROUND_ATTACHMENT @"clipPropertyBackgroundAttachment"

//音频特技名称 Audio stunt name
#define NoiseSuppressionFx @"Audio Noise Suppression"
//音频特技程度值 Audio stunt level value
#define NoiseSuppressionLevel @"Level"

@interface NvTimelineUtils : NSObject

@property (nonatomic, assign) BOOL isCaptionVC;//是否是字幕页面 Subtitle page or not

@property (nonatomic, assign) BOOL isVideoFx;

+(NvTimelineUtils *_Nullable) sharedInstance;

/**
 * 创建时间线。 Create a timeline.
 */
+ (NvsTimeline *)createTimeline:(NvEditMode)editMode;

+ (NvsTimeline *)createTimelineWithSize:(CGSize)size;

/**
 * 创建普通时间线。 Create a common timeline.
 */
+ (NvsTimeline *)createTimelineOrdinary:(NvEditMode)editMode;


/**
 * 根据素材宽高比例创建时间线。 Create a timeline based on the aspect ratio of the material.
 */
+ (NvsTimeline *)createTimelineWithAssetRatio:(float)assetRatio;

/**
 * 根据素材宽高比例计算时间线宽高。 Calculate the time line width and height according to the ratio of material width and height.
 */
+ (NvsSize)calculateTimelineSize:(NvEditMode)editMode;

/**
* 根据本地数据重建timeline。 Rebuild timeline based on local data.
*/
+ (NvsTimeline *)createTimelineWithData:(NvTimelineData *)data;

/**
 * 删除时间线。 Delete the timeline.
 */
+ (void)removeTimeline:(NvsTimeline *)timeline;

/**
 * 根据timeline data单例中保存的信息重构时间线。 Reconstructs the timeline based on the information saved in the timeline data singleton.
 */
+ (void)recreateTimeline:(NvsTimeline *)timeline;

/**
* 根据数据建立指定timline。 Builds the specified timline based on the data.
*/
+ (void)resetTimeline:(NvsTimeline *)timeline data:(NvTimelineData *)timelineData;

/**
 * 根据片段信息重置时间线上的片段。 Reset the segment in the timeline based on the segment information.
 */
+ (void)resetEditData:(NvsTimeline *)timeline editDataArray:(NSArray<NvEditDataModel *> *)editDataArray;

/**
根据数据恢复背景特效 Restore background effects based on data
*/
+ (void)resetBackgroundEffect:(NvsTimeline *)timeline model:(NvTimelineData *)timelineData;

/**
 根据数据恢复clip背景特效 Restore clip background effects based on the data
 */
+ (void)resetBackgroundEffect:(NvsTimeline *)timeline clip:(NvsVideoClip *)clip model:(NvPropertyBackgroundEffectModel *)model editModel:(NvEditDataModel *)editModel ;

/**
* 根据片段信息重置时间线(dou 视频)上的片段。 Reset the segment on the timeline (dou Video) based on the segment information.
*/
+ (void)resetDouEditData:(NvsTimeline *)timeline data:(NvTimelineData *)timelineData;

/**
 * 根据主题信息重置时间线上的主题。 Reset the topic in the timeline based on the topic information.
 */
+ (void)resetTheme:(NvsTimeline *)timeline themeInfo:(NvThemeInfoModel *)themeInfo;

/**
* 根据主题信息及给定音乐信息重置时间线上的主题。 Reset the theme in the timeline based on the theme information and the given music information.
*/
+ (void)resetTheme:(NvsTimeline *)timeline themeInfo:(NvThemeInfoModel *)themeInfo musicInfo:(NSMutableArray *)musicInfo;

/**
 * 根据字幕信息重置时间线上的字幕。 Reset subtitle on timeline based on subtitle information.
 */
+ (void)resetCaption:(NvsTimeline *)timeline captionDataArray:(NSArray<NvCaptionInfoModel *> *)captionDataArray;

+ (void)resetClipCaption:(NvsVideoClip *)clip captionDataArray:(NSArray<NvCaptionInfoModel *> *)captionDataArray;

/**
 * 根据复合字幕信息重置时间线上的复合字幕。 Reset the composite subtitles on the timeline based on the composite subtitles information.
 */
+ (void)resetCompoundCaption:(NvsTimeline *)timeline captionDataArray:(NSArray *)captionDataArray;

/**
* 根据动画信息重置时间线(Clip)上的动画。 Reset the animation on the timeline (Clip) based on the animation information.
*/
+ (void)resetAnimationFx:(NvsTimeline *)timeline model:(NvTimelineData *)timelineData;

/**
* 根据动画信息设置时间线(Clip)上的动画。 Set the animation on the timeline (Clip) based on the animation information.
*/
+ (void)setAnimationFx:(NvsVideoTrack *)track clip:(NvsVideoClip *)clip model:(NvAnimationInfoModel *)model;

/**
* 依据调节转场时间来刷新动画 Refresh the animation by adjusting the transition time
*/
+ (void)resetAnimationFxFollowTransition:(NvsTimeline *)timeline transitionIndex:(int)index transitionDuration:(double)transitionDuration;

/**
* 根据蒙版信息重置时间线(Clip)上的蒙版。 Reset the mask on the Timeline (Clip) based on the mask information.
*/
+ (void)resetMaskFx:(NvsTimeline *)timeline model:(NvTimelineData *)timelineData;

/**
 * 根据贴纸信息重置时间线上的贴纸。 Reset the stickers in the timeline based on the sticker information.
 */
+ (void)resetSticker:(NvsTimeline *)timeline stickerDataArray:(NSArray<NvStickerInfoModel *> *)stickerDataArray;

+ (void)resetClipSticker:(NvsVideoClip *)clip stickerDataArray:(NSArray<NvStickerInfoModel *>*)stickerDataArray;
/**
 * 根据水印信息重置时间线上的水印。 Reset the watermark on the timeline based on the watermark information.
 */
+ (void)resetWatermark:(NvsTimeline *)timeline watermarkInfo:(NvWatermarkInfoModel *)watermarkInfo;

/**
 * 根据转场信息重置时间线上的转场。 Reset transitions on the timeline based on transitions information.
 */
+ (void)resetTransition:(NvsTimeline *)timeline transitionDataArray:(NSArray<NvTransitionInfoModel *> *)transitionDataArray;

/**
 * 根据粒子信息重置时间线上的粒子。 Reset the particles in the timeline based on particle information.
 */
+ (void)resetParticle:(NvsTimeline *)timeline particleDataArray:(NSArray<NvParticleInfoModel *> *)particleDataArray;

/**
* 根据滤镜信息重置时间线上(timeline)的滤镜。 Reset the filters on the timeline based on the filter information.
*/
+ (void)resetTimelineFilter:(NvsTimeline *)timeline filterData:(NvTimeFilterInfoModel *)timelineFilterModel;

/**
* 根据滤镜信息重置时间线上的滤镜数组（根据出入点加载滤镜）。 Reset the filter array on the timeline based on filter information (load filters based on entry and exit points).
*/
+ (void)resetVideoFx:(NvsTimeline *)timeline timelineFilterArray:(NSArray *)timelineFilterArray;

/**
 * 根据滤镜信息重置时间线上(clip)的滤镜。 Reset the filter on the Timeline (clip) based on the filter information.
 */
+ (void)resetVideoFx:(NvsTimeline *)timeline videoFxDataArray:(NSArray<NvTimeFilterInfoModel *> *)videoFxDataArray;

/**
* 根据滤镜信息重置时间线上(clip)的关键帧滤镜。 Reset the keyframe filter on the Timeline (clip) based on the filter information.
*/
+ (void)resetKeyframesFilter:(NvsTimeline *)timeline timelineData:(NvTimelineData *)timelineData;

/**
 * 根据曲线变速信息重置clip 曲线变速效果 Reset clip curve shift effect according to curve shift information
 */
+ (void)applyCurveSpeed:(NvsVideoClip *)clip points:(NSMutableArray *)points;

/**
 * 根据曲线变速点位信息获取控制点信息 Obtain the control point information according to the curve change point position information
 */
+ (NSMutableArray *)convertToCurvePoints:(NSArray *)pointArr;

/**
 * 根据曲线变速控制点信息转化为符合条件的字符串 According to the curve change control point information is converted into a string that meets the conditions
 */
+ (NSString *)bezierPointsConvertToString:(NSArray *)points;

/**
* 根据滤镜信息及指定timelineData数据重置时间线上(clip)的滤镜。 Reset the clip filter based on the filter information and the specified timelineData.
*/
+ (void)resetVideoFx:(NvsTimeline *)timeline videoFxDataArray:(NSArray *)videoFxDataArray timelineData:(NvTimelineData *)timelineData;

/**
 * 根据音乐信息重置时间线上的音乐。 Reset the music in the timeline based on the music information.
 */
+ (void)resetMusicTrack:(NvsTimeline *)timeline musicDataArray:(NSArray<NvMusicInfoModel *> *)musicDataArray;

/**
* 根据音乐信息及给定timelineData数据重置时间线上的音乐。 Reset the music in the timeline based on the music information and given timelineData.
*/
+ (void)resetMusicTrack:(NvsTimeline *)timeline musicDataArray:(NSArray<NvMusicInfoModel *> *)musicDataArray timelineData:(NvTimelineData *)timelineData;

/**
 * 根据配音信息重置时间线上的配音。 Reset the voice acting in the timeline based on the voice acting information.
 */
+ (void)resetDubbingTrack:(NvsTimeline *)timeline dubbingModel:(NvDubbingModel *)dubbingModel;

/**
 * 根据片段信息获取片段在时间线的入点 Gets the entry point of the segment in the timeline based on the segment information
 */
+ (int64_t)getClipInpoint:(NvsTimeline *)timeline clipInfo:(NvEditDataModel *)clipInfo;

/**
 * 根据片段信息获取片段在时间线的出点 Get the exit point of the segment in the timeline based on the segment information
 */
+ (int64_t)getClipOutpoint:(NvsTimeline *)timeline clipInfo:(NvEditDataModel *)clipInfo;

/**
 * 删除片段上的裁剪效果 Remove the cropping effect on the fragment
 */
+ (void)removeClipCropAndTransformFx:(NvsVideoClip *)clip;

/**
 * 根据片段信息获取时间线上的视频片段.
 * Get video clips from the timeline based on the snippet information.
 * 说明：如果需要连续改变片段的某个属性，例如片段的角度，饱和度等，上述resetXXX接口执行效率不如直接设置NvsVideoClip的对象。
 * Note: If you need to continuously change a segment attribute, such as segment Angle, saturation, etc., the above resetXXX interface is not as efficient as setting the NvsVideoClip object directly.
 */
+ (NvsVideoClip *)getTimelineVideoClip:(NvsTimeline *)timeline clipInfo:(NvEditDataModel *)clipInfo;

/**
 * 获取视频轨道的缩略图描述数组 Gets an array of thumbnail descriptions of the video track
 */
+ (NSMutableArray<NvsThumbnailSequenceDesc *> *)getThumbnailSequenceDescArray:(NvsTimeline *)timeline;

/**
 * 定位到时间线上某一点 Locate a location on the timeline
 */
+ (void)seekTimeline:(NvsTimeline *)timeline timestamp:(int64_t)timestamp flags:(int)flags;

/**
 * 播放时间线 Play timeline
 */
+ (BOOL)playbackTimeline:(NvsTimeline *)timeline startTime:(int64_t)startTime endTime:(int64_t)endTime flags:(int)flags;

/**
 重复轨道上的某个点 Repeat some point on the track
 */
+ (BOOL)doRepeatTimeline:(uint64_t)point videotrack:(NvsVideoTrack*_Nullable)track originCutTrimInfo:(NvRecordingInfo *_Nullable)info;
/**
慢动作 Slow motion
*/
+ (BOOL)doSlowMotionTimeline:(uint64_t)point videotrack:(NvsVideoTrack*_Nullable)track;

/**
根据数据给timeline添加clip Add clip to timeline based on the data
*/
+ (void)addClips:(NSArray <NvEditDataModel *>*)clips toTimeline:(NvsTimeline *)timeline;


/// 获取目标区域在时间线坐标上的region（左上点起始逆时针环绕一周，x、y 取值范围-1~1） Obtain the region of the target region in time line coordinates (the upper left point starts to circle counterclockwise, x and y values range -1~1).
/// @param rect 目标区域 Target region
/// @param sceneWidth 等比例下画布宽度 Canvas width at equal scale
/// @param sceneHeight 等比例下画布高度 Canvas height at equal scale
+ (NSArray *)getRegionWithRect:(CGRect)rect sceneWidth:(CGFloat)sceneWidth sceneHeight:(CGFloat)sceneHeight;

//获取占比（范围：-1～1）
// Obtain the ratio (range: -1 to 1)
+ (CGFloat)getRatioValue:(CGFloat)num denValue:(CGFloat)den;


/// 获取timeline指定fx Gets the timeline specified fx
/// @param timeline 目标时间线
/// @param fxName 特效名称
+ (NvsTimelineVideoFx *)getBuiltInVideoFx:(NvsTimeline *)timeline fxName:(NSString *)fxName;

+ (NvsTimelineVideoFx *)getPackageVideoFx:(NvsTimeline *)timeline fxName:(NSString *)fxName;

/**
保存timelineData到json文件 Save timelineData to a json file
*/
+ (NSString *)saveTimelineDataToFile:(NvTimelineData *)originaModel;

/**
 设置背景属性方法 Method for setting background properties
 */
+ (void)resetPropertyBackgroundEffect:(NvsVideoClip *)clip model:(NvPropertyBackgroundEffectModel *)model;

/**
 设置背景属性Transform特效方法 Sets the background property Transform effect method
 */
+ (void)resetPropertyTransformEffect:(NvsVideoClip *)clip backgroundModel:(NvPropertyBackgroundEffectModel *)backgroundModel;

/**
 获取当前时间点videoClip Gets the current point-in-time videoClip
 */
+ (NvsVideoClip *)getCurrentClip:(NvsStreamingContext *)streamingContext timeline:(NvsTimeline *)timeline ;

/**
获取资源宽高 Obtain the resource width and height
*/
+ (CGSize)getAVFileSize:(NSString *)assetPath;

/**
获取clip model 中滤镜数组 Gets the filter array in clip model
*/
+ (NSMutableArray *)getClipTimelineFilter:(NvEditDataModel *)clipInfo timeline:(NvsTimeline *)timeline ;

/**
 安装调色滤镜 Install the palette filter
*/
+ (NSMutableString *)installColorCorrectFilterWithModel:(NvMakeupEffectBeautyContentModel *)model ;
+ (NSMutableString *)installColorCorrectFilter;

/**
 应用美妆效果 Apply beauty effects
*/
+ (NSString *)applyMakeupToolElements:(NvsFx *)fx item:(NvMakeupToolElementModel *)item packagePath:(NSString * _Nullable )packagePath reset:(BOOL)reset;

+ (void)resetTimeline:(NvsTimeline *)timeline beautyEffect:(NSMutableArray <NvBeautyTypeModel *>*)beautyArr shapeEffect:(NSMutableArray <NvBeautyTypeModel *>*)shapeArr microShapeEffect:(NSMutableArray <NvBeautyTypeModel *>*)microShapeArr;

/*
 重置timeline 上所有clip 的manipulate 跟踪
 reset all clip's manipulate tracking in timeline
 */
+ (void)resetAllClipManipulatesTracking:(NvsTimeline *)timeline;
@end
NS_ASSUME_NONNULL_END
