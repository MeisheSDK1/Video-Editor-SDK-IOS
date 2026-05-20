//
//  NvTimelineUtils.h
//  SDKDemo
//
//  说明：resetXXX接口适用于编辑过程中编辑信息的非连续变化操作，例如按钮的点击操作；不适用于信息的连续变化操作，例如滑动条的滑动的响应处理。
//
//  Created by shizhouhu on 2018/6/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsTimeline.h"
#import "NvsVideoTrack.h"
#import "NvsAudioTrack.h"
#import "NvTimelineData.h"
#import "NvUtils.h"
#import "NvsVideoClip.h"
#import "NvsMultiThumbnailSequenceView.h"
#import "NvRecordingInfo.h"

#define NV_TIME_BASE 1000000
#define TIMELINE_FX_REVERSE  1
#define TIMELINE_FX_REPEAT   2
#define TIMELINE_FX_SLOWMOTION  3


#define NV_MUSIC_SOUND_TRACK     0    //音乐轨道
#define NV_DUBBING_SOUND_TRACK   1    //配音音轨
#define VIDEO_FX_TYPE @"videoFxType" //背景特效类型
#define CLIP_BACKGROUND_ATTACHMENT @"clipBackgroundAttachment" //背景特效样式
#define CLIP_BACKGROUND_TRANSFORM_ATTACHMENT @"clipBackgroundTransformAttachment" //背景特效中关于缩放平移旋转的attachment
#define CLIP_PROPERTY_BACKGROUND_ATTACHMENT @"clipPropertyBackgroundAttachment"
@interface NvTimelineUtils : NSObject

@property (nonatomic, assign) BOOL isCaptionVC;//是否是字幕页面

@property (nonatomic, assign) BOOL isVideoFx;

+(NvTimelineUtils *) sharedInstance;

/**
 * 创建时间线。
 */
+ (NvsTimeline *)createTimeline:(NvEditMode)editMode;

/**
 * 根据素材宽高比例创建时间线。
 */
+ (NvsTimeline *)createTimelineWithAssetRatio:(float)assetRatio;

/**
 * 根据素材宽高比例计算时间线宽高。
 */
+ (NvsSize)calculateTimelineSize:(NvEditMode)editMode;

/**
* 根据本地数据重建timeline。
*/
+ (NvsTimeline *)createTimelineWithData:(NvTimelineData *)data;

/**
 * 删除时间线。
 */
+ (void)removeTimeline:(NvsTimeline *)timeline;

/**
 * 根据timeline data单例中保存的信息重构时间线。
 */
+ (void)recreateTimeline:(NvsTimeline *)timeline;

/**
* 根据数据建立指定timline。
*/
+ (void)resetTimeline:(NvsTimeline *)timeline data:(NvTimelineData *)timelineData;

/**
 * 根据片段信息重置时间线上的片段。
 */
+ (void)resetEditData:(NvsTimeline *)timeline editDataArray:(NSArray<NvEditDataModel *> *)editDataArray;

/**
根据数据恢复背景特效
*/
+ (void)resetBackgroundEffect:(NvsTimeline *)timeline model:(NvTimelineData *)timelineData;

/**
 根据数据恢复clip背景特效
 */
+ (void)resetBackgroundEffect:(NvsTimeline *)timeline clip:(NvsVideoClip *)clip model:(NvPropertyBackgroundEffectModel *)model editModel:(NvEditDataModel *)editModel ;

/**
* 根据片段信息重置时间线(dou 视频)上的片段。
*/
+ (void)resetDouEditData:(NvsTimeline *)timeline data:(NvTimelineData *)timelineData;

/**
 * 根据主题信息重置时间线上的主题。
 */
+ (void)resetTheme:(NvsTimeline *)timeline themeInfo:(NvThemeInfoModel *)themeInfo;

/**
* 根据主题信息及给定音乐信息重置时间线上的主题。
*/
+ (void)resetTheme:(NvsTimeline *)timeline themeInfo:(NvThemeInfoModel *)themeInfo musicInfo:(NSMutableArray *)musicInfo;

/**
 * 根据字幕信息重置时间线上的字幕。
 */
+ (void)resetCaption:(NvsTimeline *)timeline captionDataArray:(NSArray<NvCaptionInfoModel *> *)captionDataArray;

/**
 * 根据复合字幕信息重置时间线上的复合字幕。
 */
+ (void)resetCompoundCaption:(NvsTimeline *)timeline captionDataArray:(NSArray *)captionDataArray;

/**
* 根据动画信息重置时间线(Clip)上的动画。
*/
+ (void)resetAnimationFx:(NvsTimeline *)timeline model:(NvTimelineData *)timelineData;

/**
* 根据蒙版信息重置时间线(Clip)上的蒙版。
*/
+ (void)resetMaskFx:(NvsTimeline *)timeline model:(NvTimelineData *)timelineData;

/**
 * 根据贴纸信息重置时间线上的贴纸。
 */
+ (void)resetSticker:(NvsTimeline *)timeline stickerDataArray:(NSArray<NvStickerInfoModel *> *)stickerDataArray;

/**
 * 根据水印信息重置时间线上的水印。
 */
+ (void)resetWatermark:(NvsTimeline *)timeline watermarkInfo:(NvWatermarkInfoModel *)watermarkInfo;

/**
 * 根据转场信息重置时间线上的转场。
 */
+ (void)resetTransition:(NvsTimeline *)timeline transitionDataArray:(NSArray<NvTransitionInfoModel *> *)transitionDataArray;

/**
 * 根据粒子信息重置时间线上的粒子。
 */
+ (void)resetParticle:(NvsTimeline *)timeline particleDataArray:(NSArray<NvParticleInfoModel *> *)particleDataArray;

/**
* 根据滤镜信息重置时间线上(timeline)的滤镜。
*/
+ (void)resetTimelineFilter:(NvsTimeline *)timeline filterData:(NvTimeFilterInfoModel *)timelineFilterModel;

/**
* 根据滤镜信息重置时间线上的滤镜数组（根据出入点加载滤镜）。
*/
+ (void)resetVideoFx:(NvsTimeline *)timeline timelineFilterArray:(NSArray *)timelineFilterArray;

/**
 * 根据滤镜信息重置时间线上(clip)的滤镜。
 */
+ (void)resetVideoFx:(NvsTimeline *)timeline videoFxDataArray:(NSArray<NvTimeFilterInfoModel *> *)videoFxDataArray;

/**
* 根据滤镜信息重置时间线上(clip)的关键帧滤镜。
*/
+ (void)resetKeyframesFilter:(NvsTimeline *)timeline timelineData:(NvTimelineData *)timelineData;

/**
 * 根据曲线变速信息重置clip 曲线变速效果
 */
+ (void)applyCurveSpeed:(NvsVideoClip *)clip points:(NSMutableArray *)points;

/**
 * 根据曲线变速点位信息获取控制点信息
 */
+ (NSMutableArray *)convertToCurvePoints:(NSArray *)pointArr;

/**
 * 根据曲线变速控制点信息转化为符合条件的字符串
 */
+ (NSString *)bezierPointsConvertToString:(NSArray *)points;

/**
* 根据滤镜信息及指定timelineData数据重置时间线上(clip)的滤镜。
*/
+ (void)resetVideoFx:(NvsTimeline *)timeline videoFxDataArray:(NSArray *)videoFxDataArray timelineData:(NvTimelineData *)timelineData;

/**
 * 根据音乐信息重置时间线上的音乐。
 */
+ (void)resetMusicTrack:(NvsTimeline *)timeline musicDataArray:(NSArray<NvMusicInfoModel *> *)musicDataArray;

/**
* 根据音乐信息及给定timelineData数据重置时间线上的音乐。
*/
+ (void)resetMusicTrack:(NvsTimeline *)timeline musicDataArray:(NSArray<NvMusicInfoModel *> *)musicDataArray timelineData:(NvTimelineData *)timelineData;

/**
 * 根据配音信息重置时间线上的配音。
 */
+ (void)resetDubbingTrack:(NvsTimeline *)timeline dubbingModel:(NvDubbingModel *)dubbingModel;

/**
 * 根据片段信息获取片段在时间线的入点
 */
+ (int64_t)getClipInpoint:(NvsTimeline *)timeline clipInfo:(NvEditDataModel *)clipInfo;

/**
 * 根据片段信息获取片段在时间线的出点
 */
+ (int64_t)getClipOutpoint:(NvsTimeline *)timeline clipInfo:(NvEditDataModel *)clipInfo;

/**
 * 根据片段信息获取时间线上的视频片段.
 * 说明：如果需要连续改变片段的某个属性，例如片段的角度，饱和度等，上述resetXXX接口执行效率不如直接设置NvsVideoClip的对象。
 */
+ (NvsVideoClip *)getTimelineVideoClip:(NvsTimeline *)timeline clipInfo:(NvEditDataModel *)clipInfo;

/**
 * 获取视频轨道的缩略图描述数组
 */
+ (NSMutableArray<NvsThumbnailSequenceDesc *> *)getThumbnailSequenceDescArray:(NvsTimeline *)timeline;

/**
 * 定位到时间线上某一点
 */
+ (void)seekTimeline:(NvsTimeline *)timeline atTime:(int64_t)atTime;

/**
 * 从时间线上某一点开始播放
 */
+ (void)playTimeline:(NvsTimeline *)timeline atTime:(int64_t)atTime;

/**
 重复轨道上的某个点
 */
+ (BOOL)doRepeatTimeline:(uint64_t)point videotrack:(NvsVideoTrack*_Nullable)track originCutTrimInfo:(NvRecordingInfo *)info;
/**
慢动作
*/
+ (BOOL)doSlowMotionTimeline:(uint64_t)point videotrack:(NvsVideoTrack*_Nullable)track;

/**
根据数据给timeline添加clip
*/
+ (void)addClips:(NSArray <NvEditDataModel *>*)clips toTimeline:(NvsTimeline *)timeline;


/// 获取目标区域在时间线坐标上的region（左上点起始逆时针环绕一周，x、y 取值范围-1~1）
/// @param rect 目标区域
/// @param sceneWidth 等比例下画布宽度
/// @param sceneHeight 等比例下画布高度
+ (NSArray *)getRegionWithRect:(CGRect)rect sceneWidth:(CGFloat)sceneWidth sceneHeight:(CGFloat)sceneHeight;

//获取占比（范围：-1～1）
+ (CGFloat)getRatioValue:(CGFloat)num denValue:(CGFloat)den;


/// 获取timeline指定fx
/// @param timeline 目标时间线
/// @param fxName 特效名称
+ (NvsTimelineVideoFx *)getBuiltInVideoFx:(NvsTimeline *)timeline fxName:(NSString *)fxName;

/**
保存timelineData到json文件
*/
+ (NSString *)saveTimelineDataToFile:(NvTimelineData *)originaModel;

/**
 设置背景属性方法
 */
+ (void)resetPropertyBackgroundEffect:(NvsVideoClip *)clip model:(NvPropertyBackgroundEffectModel *)model;

/**
 设置背景属性Transform特效方法
 */
+ (void)resetPropertyTransformEffect:(NvsVideoClip *)clip backgroundModel:(NvPropertyBackgroundEffectModel *)backgroundModel;

///**
// 设置属性特技Transform 2D 效果
// */
//+ (void)resetPropertyTransformEffect:(NvsVideoClip *)clip cropperModel:(NvCropperModel *)cropperModel backgroundModel:(NvPropertyBackgroundEffectModel *)backgroundModel;

/**
  设置背景画布样式及颜色（通过storyboard 方式）
*/
//+ (void)resetBackgroundXMLEffect:(NvsTimeline *)timeline clip:(NvsVideoClip *)clip model:(NvPropertyBackgroundEffectModel *)model;

/**
  设置背景模糊通过storyboard 方式）
*/
//+ (void)resetBackgroundBlurXMLEffect:(NvsTimeline *)timeline clip:(NvsVideoClip *)clip model:(NvPropertyBackgroundEffectModel *)model editModel:(NvEditDataModel *)editModel;

/**
 获取设置背景画布样式xml信息
 */
//+ (NSString *)getImageBgXmlFormat:(int)sceneWidth sceneHeight:(int)sceneHeight trackSource:(NSString *)trackSource width:(int)width height:(int)height scaleX:(float)scaleX scaleY:(float)scaleY rotationZ:(float)rotationZ transX:(float)transX transY:(float)transY opacity:(float)opacity;

/**
 获取设置背景模糊xml信息
 */
//+ (NSString *)getImageBgBlurXmlFormat:(int)sceneWidth sceneHeight:(int)sceneHeight fastBlur:(float)radius width:(int)width height:(int)height scaleX:(float)scaleX scaleY:(float)scaleY rotationZ:(float)rotationZ transX:(float)transX transY:(float)transY opacity:(float)opacity;

/**
 移除当前类型不需要的特效（背景样式、背景颜色、背景模糊）
 */
//+ (void)removeUselessBackgroundEffect:(NvsVideoClip *)clip currentType:(NvBackgroundFxCategory)currentType;

/**
 获取当前时间点videoClip
 */
+ (NvsVideoClip *)getCurrentClip:(NvsStreamingContext *)streamingContext timeline:(NvsTimeline *)timeline ;

/**
获取资源宽高
*/
+ (CGSize)getAVFileSize:(NSString *)assetPath;

/**
获取clip model 中滤镜数组
*/
+ (NSMutableArray *)getClipTimelineFilter:(NvEditDataModel *)clipInfo timeline:(NvsTimeline *)timeline ;
@end
