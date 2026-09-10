//
//  NvTimelineFilterUtils.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvTimelineDataModel.h"
#import "NvsTimeline.h"

@interface NvTimelineFilterUtils : NSObject

/*
 * 点击添加滤镜 Click Add Filter
 */
+ (void)addFilter:(NvsTimeline *)timeline filterInfo:(NvTimeFilterInfoModel *)filterInfo;

/*
 * 长按开始添加滤镜 Long press to start adding filters
 */
+ (void)startFilter:(NvsTimeline *)timeline filterInfo:(NvTimeFilterInfoModel *)filterInfo;

/*
 * 长按结束添加滤镜 Long press to finish adding filters
 */
+ (void)stopFilter:(NvsTimeline *)timeline filterInfo:(NvTimeFilterInfoModel *)filterInfo;

/*
 * 删除滤镜 Remove filter
 */
+ (void)removeFilter:(NvsTimeline *)timeline filterInfo:(NvTimeFilterInfoModel *)filterInfo;

@end
