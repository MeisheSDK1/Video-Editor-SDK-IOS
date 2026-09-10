//
//  NvClipAnimationStickerUtils.h
//  SDKDemo
//
//  Created by ms on 2021/8/26.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsTimeline.h"
#import "NvTimelineData.h"

@interface NvClipAnimationStickerUtils : NSObject

/*
 * 添加贴纸
 Add stickers
 */
+ (NSString *)addSticker:(NvsVideoClip *)clip Model:(NvEditDataModel *)model stickerInfo:(NvStickerInfoModel *)stickerInfo;

/*
 * 更新贴纸:缩放，平移，旋转
 Update sticker: Zoom, pan, rotate
 */
+ (void)updateSticker:(NvsVideoClip *)clip Model:(NvEditDataModel *)model stickerInfo:(NvStickerInfoModel *)stickerInfo;

/*
 * 删除贴纸
 Remove sticker
 */
+ (NvStickerInfoModel *)removeSticker:(NvsVideoClip *)clip Model:(NvEditDataModel *)model stickerInfo:(NvStickerInfoModel *)stickerInfo;

/*
 * 根据live window上的点查找贴纸
 Look for stickers based on the points on the live window
 */
+ (NvStickerInfoModel *)getStickerByPoint:(NvsVideoClip *)clip timeline:(NvsTimeline *)timeline liveWindow:(NvsLiveWindow *)liveWindow point:(CGPoint)point;

/*
 * 获取贴纸包围框
 Get the sticker box
 */
+ (NSArray *)getStickerBoundingPoints:(NvsVideoClip *)clip liveWindow:(NvsLiveWindow *)liveWindow stickerInfo:(NvStickerInfoModel *)stickerInfo;

/*
 * 获取贴纸
 Get sticker
 */
+ (NvsClipAnimatedSticker *)findStickerObject:(NvsVideoClip *)clip stickerInfo:(NvStickerInfoModel *)stickerInfo;

@end

