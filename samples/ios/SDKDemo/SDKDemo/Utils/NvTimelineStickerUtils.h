//
//  NvTimelineStickerUtils.h
//  SDKDemo
//
//  Created by 施周虎 on 2018/6/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsTimeline.h"
#import "NvTimelineData.h"

@interface NvTimelineStickerUtils : NSObject

/*
 * 添加贴纸 Add stickers
 */
+ (NSString *)addSticker:(NvsTimeline *)timeline stickerInfo:(NvStickerInfoModel *)stickerInfo;

/*
 * 更新贴纸:缩放，平移，旋转 Update sticker: Zoom, pan, rotate
 */
+ (void)updateSticker:(NvsTimeline *)timeline stickerInfo:(NvStickerInfoModel *)stickerInfo;

/*
 * 删除贴纸 Remove sticker
 */
+ (NvStickerInfoModel *)removeSticker:(NvsTimeline *)timeline stickerInfo:(NvStickerInfoModel *)stickerInfo;

/*
 * 根据live window上的点查找贴纸 Look for stickers based on the points on the live window
 */
+ (NvStickerInfoModel *)getStickerByPoint:(NvsTimeline *)timeline liveWindow:(NvsLiveWindow *)liveWindow point:(CGPoint)point;

/*
 * 获取贴纸包围框 Get the sticker box
 */
+ (NSArray *)getStickerBoundingPoints:(NvsTimeline *)timeline liveWindow:(NvsLiveWindow *)liveWindow stickerInfo:(NvStickerInfoModel *)stickerInfo;

/*
 * 获取贴纸 Get sticker
 */
+ (NvsTimelineAnimatedSticker *)findStickerObject:(NvsTimeline *)timeline stickerInfo:(NvStickerInfoModel *)stickerInfo;

@end
