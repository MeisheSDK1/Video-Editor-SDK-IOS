//
//  NvMimoTimelineData.h
//  SDKDemo
//
//  说明：这是一个单例类，里面记录了用户编辑过程中用到信息：片段、主题、字幕、贴纸、转场、粒子、滤镜、配音、音乐。
//  供NvTimelineUtil类的函数在重建时间线的时候使用。
//
//  Created by shizhouhu on 2018/6/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvMimoTimelineDataModel.h"

@interface NvMimoTimelineData : NSObject

+(NvMimoTimelineData *) sharedInstance;

/**
 * 编辑片段信息
 * Edit fragment information
 */
@property(strong, nonatomic) NSMutableArray<NvMimoEditDataModel *> *editDataArray;

/**
 * 已添加主题信息
 * Topic information has been added
 */
@property(strong, nonatomic) NvMimoThemeInfoModel *themeInfo;

/**
 * 已添加字幕信息
 * Caption information has been added
 */
@property(strong, nonatomic) NSMutableArray<NvMimoCaptionInfoModel *> *captionDataArray;

/**
 * 已添加贴纸信息
 * Sticker information has been added
 */
@property(strong, nonatomic) NSMutableArray<NvMimoStickerInfoModel *> *stickerDataArray;

/**
 * 已添加水印信息
 * Watermark information has been added
 */
@property(strong, nonatomic) NvMimoWatermarkInfoModel *watermarkInfo;

/**
 * 已添加转场信息
 * Transition information has been added
 */
@property(strong, nonatomic) NSMutableArray<NvMimoTransitionInfoModel *> *transitionDataArray;

/**
 * 已添加粒子信息
 * Particle information has been added
 */
@property(strong, nonatomic) NSMutableArray<NvMimoParticleInfoModel *> *particleDataArray;

/**
 * 已添加视频特效信息
 * Video effect information has been added
 */
@property(strong, nonatomic) NSMutableArray<NvMimoTimeFilterInfoModel *> *videoFxDataArray;

/**
 * 配音对象
 * Dubbing object
 */
@property(strong, nonatomic) NvMimoDubbingModel *dubbingModel;

/**
 * 已添加音乐信息
 * Music information added
 */
@property(strong, nonatomic) NSMutableArray<NvMimoMusicInfoModel *> *musicDataArray;

/**
 * 素材添加顺序
 * Asset adding order
 */
@property(strong, nonatomic) NSMutableArray<NSString *> *dataOrder;

/**
 * 清空数据
 * Clearing data
 */
- (void)clear;

@end
