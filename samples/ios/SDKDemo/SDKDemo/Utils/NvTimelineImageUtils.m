//
//  NvTimelineImageUtils.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/7/9.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvTimelineImageUtils.h"
#import "NvsStreamingContext.h"
#import "NvTimelineData.h"
#import <NvSDKCommon/NvUtils.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvsVideoTrack.h"
#import "NvsVideoClip.h"

@implementation NvTimelineImageUtils

+ (UIImage *)getImageWithTime:(NvsTimeline *)timeline time:(int64_t)time {
    return [[NvSDKUtils getSDKContext] grabImageFromTimeline:timeline timestamp:time proxyScale:nil];
}

+ (UIImage *)getImageWithClipInfo:(NvsTimeline *)timeline clipInfo:(NvEditDataModel *)clipInfo {
    NSMutableArray *editDataArray = [[NvTimelineData sharedInstance] editDataArray];
    for (int i = 0; i < editDataArray.count; i++) {
        NvEditDataModel *info = editDataArray[i];
        if ([info.uuid isEqualToString:clipInfo.uuid]) {
            NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
            NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
            return [NvTimelineImageUtils getImageWithTime:timeline time:clip.inPoint];
        }
    }
    return nil;
}

+ (UIImage *)getImageWithClipInfo:(NvsTimeline *)timeline clipInfo:(NvEditDataModel *)clipInfo proxyScale:(const NvsRational *)proxyScale{
    NSMutableArray *editDataArray = [[NvTimelineData sharedInstance] editDataArray];
    for (int i = 0; i < editDataArray.count; i++) {
        NvEditDataModel *info = editDataArray[i];
        if ([info.uuid isEqualToString:clipInfo.uuid]) {
            NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
            NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
            return [[NvSDKUtils getSDKContext] grabImageFromTimeline:timeline timestamp:clip.inPoint proxyScale:proxyScale];
        }
    }
    return nil;
}

+ (UIImage *)imageWithTransparentPixelsAsBlack:(UIImage *)image {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize resultSize = CGSizeMake(image.size.width*scale, image.size.height*scale);
    
    CGRect imageRect = CGRectMake(0, 0, resultSize.width, resultSize.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(nil, resultSize.width, resultSize.height, 8, 0, colorSpace, kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    return newImage;
}
@end
