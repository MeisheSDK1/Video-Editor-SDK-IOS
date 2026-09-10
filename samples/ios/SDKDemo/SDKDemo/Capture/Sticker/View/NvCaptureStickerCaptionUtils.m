//
//  NvCaptureStickerCaptionUtils.m
//  SDKDemo
//
//  Created by ms on 2021/7/1.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvCaptureStickerCaptionUtils.h"
#import "NvTimelineUtils.h"
#import "NvTimelineData.h"
#import <NvSDKCommon/NvUtils.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvsStreamingContext.h"

@implementation NvCaptureStickerCaptionUtils
/*
 获取贴纸数据
 Get the sticker data
 */
+ (NvStickerInfoModel *)getStickerByPointWithliveWindow:(NvsLiveWindow *)liveWindow point:(CGPoint)point{
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    int count = [context getCaptureAnimatedStickerCount];
    if (count == 0) {
        return nil;
    }
    
    for (int i = count - 1; i >= 0; i--) {
        NvsCaptureAnimatedSticker *sticker = [context getCaptureAnimatedStickerByIndex:i];
        NvStickerInfoModel *info = (NvStickerInfoModel*)[sticker getAttachment:@"stickerInfoModel"];
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
/*
 获取贴纸坐标
 Get the sticker coordinate
 */
+ (NSArray *)getStickerBoundingPointsWithliveWindow:(NvsLiveWindow *)liveWindow stickerInfo:(NvStickerInfoModel *)stickerInfo {
    NvsCaptureAnimatedSticker *sticker = [self findStickerObjectWithStickerInfo:stickerInfo];
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

/*
 获取贴纸
 Get the sticker
 */
+ (NvsCaptureAnimatedSticker *)findStickerObjectWithStickerInfo:(NvStickerInfoModel *)stickerInfo {
    
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    int count = [context getCaptureAnimatedStickerCount];
    if (count == 0) {
        return nil;
    }
    
    for (int i = count - 1; i >= 0; i--) {
        NvsCaptureAnimatedSticker *sticker = [context getCaptureAnimatedStickerByIndex:i];
        NvStickerInfoModel *info = (NvStickerInfoModel*)[sticker getAttachment:@"stickerInfoModel"];
        if ([info.uuid isEqualToString:stickerInfo.uuid])
            return sticker;
    }
    return nil;
}


/*
 根据字幕模型获取字幕
 Get the subtitles according to the subtitle model
 */
+ (NvsCaptureCompoundCaption *)findCompoundCaptionObjectWithStickerInfo:(NvCompoundCaptionInfoModel *)captionInfo {
    
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    int count = [context getCaptureCompoundCaptionCount];
    if (count == 0) {
        return nil;
    }
    
    for (int i = count - 1; i >= 0; i--) {
        NvsCaptureCompoundCaption *caption = [context getCaptureCompoundCaptionByIndex:i];
        NvCompoundCaptionInfoModel *info = (NvCompoundCaptionInfoModel*)[caption getAttachment:@"compoundInfoModel"];
        if ([info.uuid isEqualToString:captionInfo.uuid])
            return caption;
    }
    return nil;
}


//获取点击点是否在一个范围内--其中两者在一个坐标系下，不用转换坐标系
//Gets whether the click point is in a range where the two are in the same frame without converting the frame
+ (bool)pointIsInFrame:(CGPoint)point vertices:(NSArray *)vertices {
    NSValue *leftTopValue = vertices[0];
    NSValue *leftBottomValue = vertices[1];
    NSValue *rightBottomValue = vertices[2];
    NSValue *rightTopValue = vertices[3];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    CGPoint rightTopCorner = [rightTopValue CGPointValue];
    CGMutablePathRef pathRef=CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, topLeftCorner.x, topLeftCorner.y);
    CGPathAddLineToPoint(pathRef, NULL, bottomLeftCorner.x, bottomLeftCorner.y);
    CGPathAddLineToPoint(pathRef, NULL, rightBottomCorner.x, rightBottomCorner.y);
    CGPathAddLineToPoint(pathRef, NULL, rightTopCorner.x, rightTopCorner.y);
    CGPathCloseSubpath(pathRef);
    bool isIn = CGPathContainsPoint(pathRef, nil, point, false);
    return isIn;
}

//可修改字幕重新绘制边框--获取全部子字幕的顶点数组
// Modifiable subtitle redraw border -- gets an array of vertices for all subtitles
+ (NSArray *)changeModifiableInternalCaptionsWithCaption:(NvsCaptureCompoundCaption *)caption liveWindow:(NvsLiveWindow *)liveWindow rectView:(NvRectView *)rectView{

    NSMutableArray *captionArr = [NSMutableArray array];
    NSInteger count = caption.captionCount;
    for (int i=0; i<count; i++) {
        NSArray *pointArr = [caption getCaptionBoundingVertices:i boundingType:NvsBoundingType_Text];
        NSArray *subArr = [self changeModifiableSingleCaptionWithPoints:pointArr liveWindow:liveWindow rectView:rectView];
        if (subArr.count == 4) {
            [captionArr addObject:subArr];
        }
    }
    return [captionArr copy];
}

//单个子字幕重新绘制边框--获取单个字幕在rectview中的四个顶点
// Single subtitle redraws border -- Gets the four vertices of a single subtitle in rectview
+ (NSArray *)changeModifiableSingleCaptionWithPoints:(NSArray *)points liveWindow:(NvsLiveWindow *)liveWindow rectView:(NvRectView *)rectView{
    NSMutableArray *pointArr = [NSMutableArray array];
    for (int i=0; i<points.count; i++) {
        NSValue *value = points[i];
        CGPoint point = [value CGPointValue];
        point = [liveWindow mapCanonicalToView:point];
        CGPoint finalPoint = [liveWindow convertPoint:point toView:rectView];
        [pointArr addObject:[NSValue valueWithCGPoint:finalPoint]];
    }
    if (pointArr.count == 4) {
        return [pointArr copy];
    }
    return nil;
}

//将字幕框外围边框变大
// Make the surrounding border of the subtitle box larger
+ (void)enlargeVerticesWithArray:(NSArray *)array liveWindow:(NvsLiveWindow *)liveWindow rectView:(NvRectView *)rectView{
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

    CGPoint centerPointer = CGPointMake((topLeftCorner.x+rightBottomCorner.x)/2, (topLeftCorner.y+rightBottomCorner.y)/2);
    CGFloat newAngle = atan2f(topLeftCorner.y - centerPointer.y, topLeftCorner.x - centerPointer.x);
    CGFloat leftTopDistance = [self distanceWithFirst:topLeftCorner second:centerPointer];
    leftTopDistance = leftTopDistance*1.1;
    topLeftCorner.y = sinf(newAngle)*leftTopDistance + centerPointer.y;
    topLeftCorner.x = cosf(newAngle)*leftTopDistance + centerPointer.x;

    newAngle = atan2f(bottomLeftCorner.y - centerPointer.y, bottomLeftCorner.x - centerPointer.x);
    bottomLeftCorner.y = sinf(newAngle)*leftTopDistance + centerPointer.y;
    bottomLeftCorner.x = cosf(newAngle)*leftTopDistance + centerPointer.x;

    newAngle = atan2f(rightBottomCorner.y - centerPointer.y, rightBottomCorner.x - centerPointer.x);
    rightBottomCorner.y = sinf(newAngle)*leftTopDistance + centerPointer.y;
    rightBottomCorner.x = cosf(newAngle)*leftTopDistance + centerPointer.x;

    newAngle = atan2f(rightTopCorner.y - centerPointer.y, rightTopCorner.x - centerPointer.x);
    rightTopCorner.y = sinf(newAngle)*leftTopDistance + centerPointer.y;
    rightTopCorner.x = cosf(newAngle)*leftTopDistance + centerPointer.x;
    
    [rectView setPoints:@[[NSValue valueWithCGPoint:topLeftCorner],[NSValue valueWithCGPoint:bottomLeftCorner],[NSValue valueWithCGPoint:rightBottomCorner],[NSValue valueWithCGPoint:rightTopCorner]]];
}
//获取两点之间距离
// Obtain the distance between two points
+ (CGFloat)distanceWithFirst:(CGPoint)first second:(CGPoint)second {
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY );
};


@end
