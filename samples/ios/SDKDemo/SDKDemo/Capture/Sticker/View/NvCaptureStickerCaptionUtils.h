//
//  NvCaptureStickerCaptionUtils.h
//  SDKDemo
//
//  Created by ms on 2021/7/1.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsTimeline.h"
#import "NvTimelineData.h"
#import "NvRectView.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvCaptureStickerCaptionUtils : NSObject
+ (NvStickerInfoModel *)getStickerByPointWithliveWindow:(NvsLiveWindow *)liveWindow point:(CGPoint)point;
+ (NSArray *)getStickerBoundingPointsWithliveWindow:(NvsLiveWindow *)liveWindow stickerInfo:(NvStickerInfoModel *)stickerInfo;
+ (NvsCaptureAnimatedSticker *)findStickerObjectWithStickerInfo:(NvStickerInfoModel *)stickerInfo;
+ (NvsCaptureCompoundCaption *)findCompoundCaptionObjectWithStickerInfo:(NvCompoundCaptionInfoModel *)captionInfo ;
//获取点击点是否在一个范围内--其中两者在一个坐标系下，不用转换坐标系
//Gets whether the click point is in a range where the two are in the same frame without converting the frame
+ (bool)pointIsInFrame:(CGPoint)point vertices:(NSArray *)vertices;
//可修改字幕重新绘制边框--获取全部子字幕的顶点数组
//Modifiable subtitle redraw border -- Gets an array of vertices for all subtitles
+ (NSArray *)changeModifiableInternalCaptionsWithCaption:(NvsCaptureCompoundCaption *)caption liveWindow:(NvsLiveWindow *)liveWindow rectView:(NvRectView *)rectView;
//将字幕框外围边框变大 Make the surrounding border of the subtitle box larger
+ (void)enlargeVerticesWithArray:(NSArray *)array liveWindow:(NvsLiveWindow *)liveWindow rectView:(NvRectView *)rectView;
@end

NS_ASSUME_NONNULL_END
