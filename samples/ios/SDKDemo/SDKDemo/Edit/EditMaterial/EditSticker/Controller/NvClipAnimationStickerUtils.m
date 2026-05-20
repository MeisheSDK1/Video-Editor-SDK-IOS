//
//  NvClipAnimationStickerUtils.m
//  SDKDemo
//
//  Created by ms on 2021/8/26.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvClipAnimationStickerUtils.h"
#import "NvTimelineUtils.h"
#import "NvTimelineData.h"
#import <NvSDKCommon/NvUtils.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvsTimelineAnimatedSticker.h"
#import "NvsStreamingContext.h"

@implementation NvClipAnimationStickerUtils

+ (NSString *)addSticker:(NvsVideoClip *)clip Model:(NvEditDataModel *)model stickerInfo:(NvStickerInfoModel *)stickerInfo {
    [model.stickerDataArray addObject:stickerInfo];
    [NvTimelineUtils resetClipSticker:clip stickerDataArray:model.stickerDataArray];
    return stickerInfo.uuid;
}

+ (void)updateSticker:(NvsVideoClip *)clip Model:(NvEditDataModel *)model stickerInfo:(NvStickerInfoModel *)stickerInfo {
    NvsClipAnimatedSticker *stickerEffect = [NvClipAnimationStickerUtils findStickerObject:clip stickerInfo:stickerInfo];
    if (stickerEffect == nil)
        return;
    [stickerEffect setScale:stickerInfo.scale];
    [stickerEffect setTranslation:stickerInfo.translation];
    [stickerEffect setRotationZ:stickerInfo.rotation];
    [stickerEffect changeInPoint:stickerInfo.inPoint];
    [stickerEffect changeOutPoint:stickerInfo.outPoint];
    [stickerEffect setHorizontalFlip:stickerInfo.isHorizontalFlip];
    NSMutableArray *stickerlist = [model stickerDataArray];
    if (stickerlist.count == 0 || [NvUtils isStringEmpty:stickerInfo.uuid]) {
        return;
    }
    for (NvStickerInfoModel* info in stickerlist) {
        if ([stickerInfo.uuid isEqualToString:[(NvStickerInfoModel *)info uuid]]) {
            info.scale = stickerInfo.scale;
            info.translation = stickerInfo.translation;
            info.rotation = stickerInfo.rotation;
            info.inPoint = stickerInfo.inPoint;
            info.outPoint = stickerInfo.outPoint;
            info.isHorizontalFlip = stickerInfo.isHorizontalFlip;
            break;
        }
    }
}

+ (NvStickerInfoModel *)removeSticker:(NvsVideoClip *)clip Model:(NvEditDataModel *)model stickerInfo:(NvStickerInfoModel *)stickerInfo {
    NSMutableArray *stickerlist = model.stickerDataArray;
    NvStickerInfoModel *nextSticker = nil;
    for (int i = 0; i < stickerlist.count; i++) {
        NvStickerInfoModel *info = stickerlist[i];
        if ([info.uuid isEqualToString:stickerInfo.uuid]) {
            [stickerlist removeObject:info];
            if (i < stickerlist.count) {
                nextSticker = stickerlist[i];
            } else if (stickerlist.count > 0) {
                nextSticker = stickerlist[stickerlist.count-1];
            }
            break;
        }
    }
    [NvTimelineUtils resetClipSticker:clip stickerDataArray:model.stickerDataArray];
    return nextSticker;
}

+ (NvStickerInfoModel *)getStickerByPoint:(NvsVideoClip *)clip timeline:(NvsTimeline *)timeline liveWindow:(NvsLiveWindow *)liveWindow point:(CGPoint)point{
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    NSArray *stickerList = [clip getAnimatedStickersByClipTimePosition:[context getTimelineCurrentPosition:timeline]];
    if (stickerList.count == 0) {
        return nil;
    }
    
    for (int i = (int)stickerList.count - 1; i >= 0; i--) {
        NvsClipAnimatedSticker *sticker = stickerList[i];
        NvStickerInfoModel *info = (NvStickerInfoModel*)[sticker getAttachment:@"stickerInfoModel"];
        NSArray *array = [sticker getBoundingRectangleVertices];
        if (info) {
            if (info.keyFramesArray.count > 0) {
                BOOL hasKeyFrame = NO;
                for (NvKeyFrameStickerModel *model in info.keyFramesArray) {
                    if (model.time == [context getTimelineCurrentPosition:timeline]) {
                        hasKeyFrame = YES;
                        break;
                    }
                }
                if (hasKeyFrame) {
                    if ([context getTimelineCurrentPosition:timeline] == 0) {
                        [sticker setCurrentKeyFrameTime:0];
                    }
                }else{
                    [sticker setCurrentKeyFrameTime:[context getTimelineCurrentPosition:timeline] - info.inPoint];
                    array = [sticker getBoundingRectangleVertices];
                    for (NSString *string in info.keyArray) {
                        [sticker removeKeyframeAtTime:string time:[context getTimelineCurrentPosition:timeline]-info.inPoint];
                    }
                }
            }
        }
        
        NSValue *leftTopValue = array[0];
        NSValue *leftBottomValue = array[1];
        NSValue *rightBottomValue = array[2];
        NSValue *rightTopValue = array[3];
        CGPoint topLeftCorner = [leftTopValue CGPointValue];
        CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
        CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
        CGPoint rightTopCorner = [rightTopValue CGPointValue];
        
        topLeftCorner = [liveWindow mapCanonicalToView:topLeftCorner];
        rightBottomCorner = [liveWindow mapCanonicalToView:rightBottomCorner];
        bottomLeftCorner = [liveWindow mapCanonicalToView:bottomLeftCorner];
        rightTopCorner = [liveWindow mapCanonicalToView:rightTopCorner];
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGMutablePathRef pathRef=CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, topLeftCorner.x, topLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, bottomLeftCorner.x, bottomLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightBottomCorner.x, rightBottomCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightTopCorner.x, rightTopCorner.y);
        CGPathCloseSubpath(pathRef);
        CGContextAddPath(ctx, pathRef);
        
        bool isSelected = CGPathContainsPoint(pathRef, nil, point, false);
        CGPathRelease(pathRef);
        if (isSelected) {
            return info;
        }
    }
    return nil;
}

+ (NSArray *)getStickerBoundingPoints:(NvsVideoClip *)clip liveWindow:(NvsLiveWindow *)liveWindow stickerInfo:(NvStickerInfoModel *)stickerInfo {
    NvsClipAnimatedSticker *sticker = [NvClipAnimationStickerUtils findStickerObject:clip stickerInfo:stickerInfo];
    NSArray *array = [sticker getBoundingRectangleVertices];
    NSValue *leftTopValue = array[0];
    NSValue *leftBottomValue = array[1];
    NSValue *rightBottomValue = array[2];
    NSValue *rightTopValue = array[3];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    CGPoint rightTopCorner = [rightTopValue CGPointValue];
    
    topLeftCorner = [liveWindow mapCanonicalToView:topLeftCorner];
    rightBottomCorner = [liveWindow mapCanonicalToView:rightBottomCorner];
    bottomLeftCorner = [liveWindow mapCanonicalToView:bottomLeftCorner];
    rightTopCorner = [liveWindow mapCanonicalToView:rightTopCorner];
    
    NSMutableArray *newarray = NSMutableArray.new;
    [newarray addObject:[NSValue valueWithCGPoint:topLeftCorner]];
    [newarray addObject:[NSValue valueWithCGPoint:bottomLeftCorner]];
    [newarray addObject:[NSValue valueWithCGPoint:rightBottomCorner]];
    [newarray addObject:[NSValue valueWithCGPoint:rightTopCorner]];
    return newarray;
}

+ (NvsClipAnimatedSticker *)findStickerObject:(NvsVideoClip *)clip stickerInfo:(NvStickerInfoModel *)stickerInfo {
    NvsClipAnimatedSticker *sticker = [clip getFirstAnimatedSticker];
    while (sticker) {
        NvStickerInfoModel *info = (NvStickerInfoModel *)[sticker getAttachment:@"stickerInfoModel"];
        if ([info.uuid isEqualToString:stickerInfo.uuid])
            return sticker;
        sticker = [clip getNextAnimatedSticker:sticker];
    }
    return nil;
}
@end
