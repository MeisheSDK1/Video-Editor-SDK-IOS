//
//  ThemeHelper.h
//  ThemeHelper
//
//  Created by ms20180425 on 2019/12/26.
//  Copyright © 2019 ms20180425. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NvStreamingSdkCore/NvStreamingSdkCore.h>
#import "MusicClipModel.h"
#import "TemplateModel.h"
#import "TransModel.h"
#import "ClipPointModel.h"

@interface ThemeHelper : NSObject

/// 创建单例
+(instancetype)sharedInstance;

/// 解析json数据返回数据模型数组
/// @param path json路径
- (NSMutableArray *)configPath:(NSString *)path;

/// 给timeline填充数据
/// @param timeline timeline
/// @param assetArray 数据源
- (void)createTimeline:(NvsTimeline *)timeline withAsset:(NSArray *)assetArray;

/// 应用模板
/// @param model 模板数据模型
- (void)applicationTemplate:(TemplateModel *)model;

/// 修改字幕
/// @param text 文字
/// @param index 字幕所在的索引
- (void)changeCaption:(NSString *)text withIndex:(int)index;

- (void)changeTimelineDuration:(int64_t)duration;

/// 获取时间线上所有字幕文本
- (NSArray *)getAllCaptionArray;

/// 获取最大可修改的时长
- (int64_t)getMaxDuration;

/// 获取最小可修改的时长
- (int64_t)getMinDuration;

/// 获取当前时长
- (int64_t)getCurrentDuration;

@end
