//
//  NvTimelineImageUtils.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/7/9.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsTimeline.h"
#import "NvTimelineDataModel.h"

@interface NvTimelineImageUtils : NSObject

/*
 * 根据时间点获取时间线上某帧图片 Obtain a frame image on the timeline according to the time point
 */
+ (UIImage *)getImageWithTime:(NvsTimeline *)timeline time:(int64_t)time;

/*
 * 根据片段信息获取该片段的首帧图片 Get the first frame of the segment based on the segment information
 */
+ (UIImage *)getImageWithClipInfo:(NvsTimeline *)timeline clipInfo:(NvEditDataModel *)clipInfo;

/*
 * 根据片段信息获取该片段的首帧图片,可以传比例 According to the segment information to obtain the first frame of the segment, you can transfer the ratio
 */
+ (UIImage *)getImageWithClipInfo:(NvsTimeline *)timeline clipInfo:(NvEditDataModel *)clipInfo proxyScale:(const NvsRational *)proxyScale;

/*
 * 保存原始image, 防止image 中透明的部分被iOS系统转为白色 Save the original image to prevent transparent parts from being turned white by the iOS system
 */
+ (UIImage *)imageWithTransparentPixelsAsBlack:(UIImage *)image;
@end
