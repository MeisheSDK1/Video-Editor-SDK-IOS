//
//  NvTimelineData.h
//  SDKDemo
//
//  说明：这是一个单例类，里面记录了用户编辑过程中用到信息：片段、主题、字幕、贴纸、转场、粒子、滤镜、配音、音乐。
//  供NvTimelineUtil类的函数在重建时间线的时候使用。
//
//  Note: This is a singleton class, which records the information used in the editing process of the user: snippets, themes, subtitles, stickers, transitions, particles, filters, dubbing, music.
//  For NvTimelineUtil functions to reconstruct the timeline.

//  Created by shizhouhu on 2018/6/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvTimelineDataModel.h"
#import "NVDefineConfig.h"
#import "NvAlbumItem.h"
#import "NvMakeupModel.h"
#import "NvMakeupToolModel.h"

typedef NS_ENUM(NSUInteger, NvTimelineType) {
    NvTimelineType_None,
    NvTimelineType_PlayRevert,
    NvTimelineType_Repeat,
    NvTimelineType_Slow,
};

@interface NvTimelineData : NSObject

+(NvTimelineData *) sharedInstance;

/**
* 时间线尺寸比例 Time line size scale
*/
@property (nonatomic, assign) NvEditMode editMode;

/**
* 当前选择的状态 The state of the current selection
*/
@property (assign, nonatomic) NvTimelineType type;

/**
* 是否是dou视频 dou video or not
*/
@property (nonatomic, assign) BOOL isDou;

/**
 * 编辑片段信息 Edit fragment information
 */
@property(strong, nonatomic) NSMutableArray<NvEditDataModel *> *editDataArray;

/**
* 时间线滤镜信息（不包含片头片尾） Timeline filter information (excluding beginning and end)
*/
@property(strong, nonatomic) NvTimeFilterInfoModel *timelineFilter;

/**
* 时间线美妆信息 Timeline Beauty information
*/
@property(nonatomic, strong) NvMakeupToolModel *timelineMakeupModel;

/**
* 时间线美颜美型微整形信息 Timeline Beauty beauty type micro plastic surgery information
*/
@property(nonatomic, strong) NSMutableArray <NvBeautyTypeModel *>*beautyArr;

@property(nonatomic, strong) NSMutableArray <NvBeautyTypeModel *>*shapeArr;

@property(nonatomic, strong) NSMutableArray <NvBeautyTypeModel *>*microShapeArr;

/**
* 时间线滤镜信息 Timeline filter information
*/
@property(strong, nonatomic) NSMutableArray<NvTimeFilterInfoModel *>*timelineFilterArray;

/**
 * 已添加主题信息 The topic information has been added
 */
@property(strong, nonatomic) NvThemeInfoModel *themeInfo;

/**
 * 已添加字幕信息 Subtitle information has been added
 */
@property(strong, nonatomic) NSMutableArray<NvCaptionInfoModel *> *captionDataArray;

/**
 * 已添加复合字幕信息 Composite subtitle information has been added
 */
@property(strong, nonatomic) NSMutableArray<NvCompoundCaptionInfoModel *> *compoundCaptionDataArray;

/**
 * 已添加贴纸信息 Sticker information has been added
 */
@property(strong, nonatomic) NSMutableArray<NvStickerInfoModel *> *stickerDataArray;

/**
 * 已添加水印信息 A watermark has been added
 */
@property(strong, nonatomic) NvWatermarkInfoModel *watermarkInfo;

/**
 * 已添加转场信息 Transition information has been added
 */
@property(strong, nonatomic) NSMutableArray<NvTransitionInfoModel *> *transitionDataArray;

/**
 * 已添加粒子信息 Particle information has been added
 */
@property(strong, nonatomic) NSMutableArray<NvParticleInfoModel *> *particleDataArray;

/**
 * 已添加视频特效信息 The video effects information has been added
 */
@property(strong, nonatomic) NSMutableArray<NvTimeFilterInfoModel *> *videoFxDataArray;

/**
 * 配音对象 Dubbing object
 */
@property(strong, nonatomic) NvDubbingModel *dubbingModel;

/**
 * 已添加音乐信息 Music information has been added
 */
@property(strong, nonatomic) NSMutableArray<NvMusicInfoModel *> *musicDataArray;

/**
 * 素材添加顺序 Material addition order
 */
@property(strong, nonatomic) NSMutableArray<NSString *> *dataOrder;

/**
* dou视频音乐信息 dou video music information
*/
@property (nonatomic, strong) NSString *musicPath; //音乐文件路径 Music file path
@property (nonatomic, assign) float trimIn;
@property (nonatomic, assign) float trimOut;

/**
 * 清空数据 Clear data
 */
- (void)clear;

@end
