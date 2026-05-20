//
//  NvMimoTimelineUtils.h
//  SDKDemo
//
//  说明：resetXXX接口适用于编辑过程中编辑信息的非连续变化操作，例如按钮的点击操作；不适用于信息的连续变化操作，例如滑动条的滑动的响应处理。
//  Description: resetXXX interface is suitable for editing information in the process of non-continuous change operation, such as button click operation; It is not suitable for continuous change of information, such as the response processing of the sliding of the slider.
//
//  Created by shizhouhu on 2018/6/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NvStreamingSdkCore/NvsTimeline.h>
#import "NvsVideoTrack.h"
#import "NvsAudioTrack.h"
#import "NvMimoTimelineData.h"
#import "NvMimoUtils.h"
#import "NvsVideoClip.h"
#import "NvsMultiThumbnailSequenceView.h"
#import "NvThemeModel.h"

#define NV_TIME_BASE 1000000
#define TIMELINE_FX_REVERSE  1
#define TIMELINE_FX_REPEAT   2
#define TIMELINE_FX_SLOWMOTION  3


#define NV_MUSIC_SOUND_TRACK     0
#define NV_DUBBING_SOUND_TRACK   1


@interface NvMimoTimelineUtils : NSObject

@property (nonatomic, assign) BOOL isCaptionVC;

@property (nonatomic, assign) BOOL isVideoFx;

+(NvMimoTimelineUtils *) sharedInstance;

/**
 * 创建时间线。
 * Create a timeline.
 */
+ (NvsTimeline *)createTimeline:(NvMimoEditMode)editMode;

/**
 * 删除时间线。
 * remove timeline
 */
+ (void)removeTimeline:(NvsTimeline *)timeline;

/**
 整理镜头数据
 Organizing shot data
 @param shotInfo 镜头数组
 @param dirPath 文件夹位置
 */
+ (void)arrangeVideoData:(NSMutableArray *)shotInfo dirPath:(NSString *)dirPath;

/**
 * 根据timeline data单例中保存的信息重构时间线。
 * Reconstruct the timeline based on the information saved in the timeline data singleton.
 */
+ (void)recreateTimeline:(NvsTimeline *)timeline;

/**
 * 根据片段信息重置时间线上的片段。
 * Resets the segments on the timeline based on the segment information.
 */
+ (void)resetEditData:(NvsTimeline *)timeline editDataArray:(NSArray<NvMimoEditDataModel *> *)editDataArray;

/**
 * 根据片段信息重置时间线上的片段。
 * 速度为常速（一倍速）
 * Resets a fragment on the timeline based on the fragment information.
 * Constant speed (one speed)
 */
+ (void)resetRegularEditData:(NvsTimeline *)timeline editDataArray:(NSArray *)editDataArray;

/**
 * 根据主题信息重置时间线上的主题。
 * Resets the topics in the timeline based on the topic information.
 */
+ (void)resetTheme:(NvsTimeline *)timeline themeInfo:(NvMimoThemeInfoModel *)themeInfo;

/**
 * 根据字幕信息重置时间线上的字幕。
 * Resets the subtitles on the timeline based on the caption information.
 */
+ (void)resetCaption:(NvsTimeline *)timeline captionDataArray:(NSArray<NvMimoCaptionInfoModel *> *)captionDataArray;

/**
 * 根据贴纸信息重置时间线上的贴纸。
 * Resets the stickers on the timeline based on the sticker information.
 */
+ (void)resetSticker:(NvsTimeline *)timeline stickerDataArray:(NSArray<NvMimoStickerInfoModel *> *)stickerDataArray;

/**
 * 根据水印信息重置时间线上的水印。
 * Resets the watermark on the timeline based on the watermark information.
 */
+ (void)resetWatermark:(NvsTimeline *)timeline watermarkInfo:(NvMimoWatermarkInfoModel *)watermarkInfo;

/**
 * 根据转场信息重置时间线上的转场。
 * Resets transitions in the timeline based on transition information.
 */
+ (void)resetTransition:(NvsTimeline *)timeline transitionDataArray:(NSArray<NvMimoTransitionInfoModel *> *)transitionDataArray;

/**
 * 根据粒子信息重置时间线上的粒子。
 * Resets the particles on the timeline based on the particle information.
 */
+ (void)resetParticle:(NvsTimeline *)timeline particleDataArray:(NSArray<NvMimoParticleInfoModel *> *)particleDataArray;

/**
 * 根据滤镜信息重置时间线上的滤镜。
 * Resets the filter on the timeline based on the filter information.
 */
+ (void)resetVideoFx:(NvsTimeline *)timeline videoFxDataArray:(NSArray<NvMimoTimeFilterInfoModel *> *)videoFxDataArray;

/**
 * 根据音乐信息重置时间线上的音乐。
 * Resets the music on the timeline based on the music information.
 */
+ (void)resetMusicTrack:(NvsTimeline *)timeline musicDataArray:(NSArray<NvMimoMusicInfoModel *> *)musicDataArray;

/**
 * 根据配音信息重置时间线上的配音。
 * Resets the dubbing on the timeline based on dubbing information.
 */
+ (void)resetDubbingTrack:(NvsTimeline *)timeline dubbingModel:(NvMimoDubbingModel *)dubbingModel;

/**
 * 根据片段信息获取片段在时间线的入点
 * The entry point of the fragment in the timeline is obtained according to the fragment information
 */
+ (int64_t)getClipInpoint:(NvsTimeline *)timeline clipInfo:(NvMimoEditDataModel *)clipInfo;

/**
 * 根据片段信息获取片段在时间线的出点
 * The exit point of the fragment in the timeline is obtained according to the fragment information
 */
+ (int64_t)getClipOutpoint:(NvsTimeline *)timeline clipInfo:(NvMimoEditDataModel *)clipInfo;

/**
 * 根据片段信息获取时间线上的视频片段.
 * 说明：如果需要连续改变片段的某个属性，例如片段的角度，饱和度等，上述resetXXX接口执行效率不如直接设置NvsVideoClip的对象。
 * * Get video clips on the timeline based on clip information.
 * Note: If you need to continuously change a certain property of the fragment, such as the fragment Angle, saturation, etc., the above resetXXX interface is not as efficient as setting the NvsVideoClip object directly.
 */
+ (NvsVideoClip *)getTimelineVideoClip:(NvsTimeline *)timeline clipInfo:(NvMimoEditDataModel *)clipInfo;

/**
 * 获取视频轨道的缩略图描述数组
 * Gets an array of thumbnail descriptions of a video track
 */
+ (NSMutableArray<NvsThumbnailSequenceDesc *> *)getThumbnailSequenceDescArray:(NvsTimeline *)timeline;

/**
 * 定位到时间线上某一点
 * Locate a point on the timeline
 */
+ (void)seekTimeline:(NvsTimeline *)timeline atTime:(int64_t)atTime;

/**
 * 从时间线上某一点开始播放
 * Starting at some point on the timeline
 */
+ (void)playTimeline:(NvsTimeline *)timeline atTime:(int64_t)atTime;

//慢动作
//SlowMotion
+ (BOOL)doSlowMotionTimeline:(uint64_t)point videotrack:(NvsVideoTrack*_Nullable)track;

/**
 计算model真正需要的素材时长--针对镜头本身存在变速
 Calculate how long the model really needs - there is a variable speed for the shot itself
 @return 返回结束时间点，而不是duration Returns the end point, not duration
 */
+ (CGFloat)requiredDurationForShotModel:(NvShotModel *)model;

/**
根据字符串获取对应时间线比例
 Get the timeline proportion from the string
*/
+ (NvMimoEditMode)editModeWithString:(NSString *)supportRatio;

/**
根据时间线比例获取liveWindow界面大小（默认宽为screen_width）
 Gets the liveWindow screen size based on the timeline ratio (default width is screen_width)
*/
+ (CGSize)liveWindowSizeWithEditMode:(NvMimoEditMode)editMode;
@end
