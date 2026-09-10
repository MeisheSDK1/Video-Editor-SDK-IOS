//
//  NvBoomerang.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/12/19.
//  Copyright © 2018 meishe. All rights reserved.
//

#import "NvBoomerang.h"
#import "NvUtils.h"
#import "NvsStreamingContext.h"
#import "NvsAVFileInfo.h"
#import "NvsVideoClip.h"
#import "NvsVideoTrack.h"
#import "NvSDKUtils.h"

@implementation NvBoomerang

+ (NvsTimeline *)createTimeline:(NSString *)videoSourcePath {
    if ([NvUtils isStringEmpty:videoSourcePath]) {
        NSLog(@"createTimeline: videoSourcePath is null!");
        return nil;
    }
    
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    if (context == nil) {
        NSLog(@"createTimeline: nvsStreamingContext is null!");
        return nil;
    }
    
    NvsAVFileInfo *fileInfo = [context getAVFileInfo:videoSourcePath];
    if (fileInfo == nil) {
        NSLog(@"createTimeline: fileInfo is null!");
        return nil;
    }
    
    NvsSize size = [fileInfo getVideoStreamDimension:0];
    NvsVideoResolution videoEditRes;
    videoEditRes.imageWidth = size.width;
    videoEditRes.imageHeight = size.height;
    videoEditRes.imagePAR = (NvsRational){1, 1};
    NvsRational videoFps = {20, 1};
    NvsAudioResolution audioEditRes;
    audioEditRes.sampleRate = 44100;
    audioEditRes.channelCount = 2;

    NvsTimeline *timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes];
    if (timeline == nil) {
        NSLog(@"createTimeline: failed to create timeline!");
        return nil;
    }
    
    NvsVideoTrack *videoTrack = [timeline appendVideoTrack];
    [videoTrack setVolumeGain:0 rightVolumeGain:0];
    if (videoTrack == nil) {
        NSLog(@"createTimeline: failed to appendVideoTrack!");
        return nil;
    }
    
    int rotation = 0;
    if ([fileInfo videoStreamCount] > 0) {
        rotation = [fileInfo getVideoStreamRotation:0];
        if (rotation == NvsVideoRotation_90) {
            rotation = NvsVideoRotation_270;
        } else if (rotation == NvsVideoRotation_180) {
            rotation = NvsVideoRotation_180;
        } else if (rotation == NvsVideoRotation_270) {
            rotation = NvsVideoRotation_90;
        }
    }
    
    for (int i = 0; i < 8; ++i) {
        NvsVideoClip *clip = [videoTrack appendClip:videoSourcePath];
        if (clip == nil)
            continue;
        [clip setExtraVideoRotation:rotation];
        if (i % 2 != 00)
            [clip setPlayInReverse:YES];
    }
    
    for (int i = 0; i < videoTrack.clipCount; ++i) {
        [videoTrack setBuiltinTransition:i withName:nil];
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        if (clip != nil) {
            [clip changeSpeed:2.21f];
            if (i > 0) {
                [clip changeTrimInPoint:45000 affectSibling:YES];
            }
        }
    }
    return timeline;
}

@end
