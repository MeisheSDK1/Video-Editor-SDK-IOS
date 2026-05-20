//
//  NvTimelineUtils.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/6/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvTimelineUtils.h"
#import "NvTimelineData.h"
#import "NvsVideoClip.h"
#import "NvsAudioClip.h"
#import "NvsTimelineCaption.h"
#import "NvsTimelineAnimatedSticker.h"
#import "NvsParticleSystemContext.h"
#import "NvsTimelineVideoFx.h"
#import "NvsStreamingContext.h"
#import <NvSDKCommon/NvUtils.h>
#import "NvsVideoFx.h"
#import "NVHeader.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvsVideoTransition.h"
#import "NvBezierUtils.h"
#import "YYModel.h"
#import "SDKDemo-Swift.h"
#import "NvVolumeKeyFrameInfo.h"
#import "NvsMakeupEffectInfo.h"
#import "NvsCaptionSpan.h"
#import "NvInitArScence.h"

#define UnSupport4kLength 1920
@implementation NvTimelineUtils

static NvTimelineUtils *sharedInstance = nil;

+ (NvTimelineUtils *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[NvTimelineUtils alloc] init];
    });
    
    return sharedInstance;
}


+ (NvsTimeline *)createTimeline:(NvEditMode)editMode {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    NvsSize size = [NvTimelineUtils calculateTimelineSize:editMode];
    NvsVideoResolution videoEditRes;
    videoEditRes.imageWidth = size.width;
    videoEditRes.imageHeight = size.height;
    videoEditRes.imagePAR = (NvsRational){1, 1};
    NvsRational videoFps = {30, 1};
    NvsAudioResolution audioEditRes;
    audioEditRes.sampleRate = 48000;
    audioEditRes.channelCount = 2;
    audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
    NvsTimeline *timeline;
    if ([NvHDRManager isSupportEditing]) {
        timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes bitDepth:[NvSDKUtils resolutionModelSetting] flags:0];
    }else{
        timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes flags:0];
    }
    [timeline appendVideoTrack];
    [timeline appendAudioTrack]; //音乐轨道 Musical track
    [timeline appendAudioTrack]; //配音轨道 Dubbing track
    return timeline;
}

+ (NvsTimeline *)createTimelineWithSize:(CGSize)size {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    NvsVideoResolution videoEditRes;
    videoEditRes.imageWidth = size.width;
    videoEditRes.imageHeight = size.height;
    videoEditRes.imagePAR = (NvsRational){1, 1};
    NvsRational videoFps = {30, 1};
    NvsAudioResolution audioEditRes;
    audioEditRes.sampleRate = 48000;
    audioEditRes.channelCount = 2;
    audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
    NvsTimeline *timeline;
    if ([NvHDRManager isSupportEditing]) {
        timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes bitDepth:[NvSDKUtils resolutionModelSetting] flags:0];
    }else{
        timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes flags:0];
    }
    [timeline appendVideoTrack];
    [timeline appendAudioTrack]; //音乐轨道 Musical track
    [timeline appendAudioTrack]; //配音轨道 Dubbing track
    return timeline;
}

+ (NvsTimeline *)createTimelineOrdinary:(NvEditMode)editMode {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    NvsSize size = [NvTimelineUtils calculateTimelineSize:editMode];
    NvsVideoResolution videoEditRes;
    videoEditRes.imageWidth = size.width;
    videoEditRes.imageHeight = size.height;
    videoEditRes.imagePAR = (NvsRational){1, 1};
    NvsRational videoFps = {30, 1};
    NvsAudioResolution audioEditRes;
    audioEditRes.sampleRate = 48000;
    audioEditRes.channelCount = 2;
    audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
    NvsTimeline *timeline;
    if ([NvHDRManager isSupportEditing]) {
        timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes bitDepth:[NvSDKUtils resolutionModelSetting] flags:0];
    }else{
        timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes flags:0];
    }
    [timeline appendVideoTrack];
    [timeline appendAudioTrack]; //音乐轨道
    [timeline appendAudioTrack]; //配音轨道
    return timeline;
}

+ (NvsTimeline *)createTimelineWithAssetRatio:(float)assetRatio {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    NvsSize size = [NvTimelineUtils calculateTimelineSizeWithAssetRatio:assetRatio];
    NvsVideoResolution videoEditRes;
    videoEditRes.imageWidth = size.width;
    videoEditRes.imageHeight = size.height;
    videoEditRes.imagePAR = (NvsRational){1, 1};
    NvsRational videoFps = {25, 1};
    NvsAudioResolution audioEditRes;
    audioEditRes.sampleRate = 48000;
    audioEditRes.channelCount = 2;
    audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
    NvsTimeline *timeline;
    if ([NvHDRManager isSupportEditing]) {
        timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes bitDepth:[NvSDKUtils resolutionModelSetting] flags:0];
    }else{
        timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes flags:0];
    }
    [timeline appendVideoTrack];
    [timeline appendAudioTrack]; //音乐轨道 Musical track
    [timeline appendAudioTrack]; //配音轨道 Dubbing track
    return timeline;
}

+ (void)removeTimeline:(NvsTimeline *)timeline {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    [context removeTimeline:timeline];
}

+ (NvsSize)calculateTimelineSize:(NvEditMode)editMode {
    int compileRes = 1080;
    NvsSize size;
    if (editMode == NvEditMode16v9) {
        size.height = compileRes;
        size.width = compileRes * 16 / 9;
    } else if (editMode == NvEditMode1v1) {
        size.height = compileRes;
        size.width = compileRes;
    } else if (editMode == NvEditMode9v16) {
        size.width = compileRes;
        size.height = compileRes * 16 / 9;
    } else if (editMode == NvEditMode3v4) {
        size.width = compileRes;
        size.height = compileRes * 4 / 3;
    } else if (editMode == NvEditMode4v3) {
        size.width = compileRes * 4 / 3;
        size.height = compileRes;
    } else if (editMode == NvEditMode21v9){
        size.height = compileRes;
        size.width = compileRes * 21 / 9;
        if ([NvUtils isUnSupport4KEdit] && size.width > UnSupport4kLength) {
            size.width = UnSupport4kLength;
            int h = UnSupport4kLength * 9 / 21;
            size.height = (h + 1) & ~1;
        }
    } else if (editMode == NvEditMode9v21) {
        size.width = compileRes;
        size.height = compileRes * 21 / 9;
        if ([NvUtils isUnSupport4KEdit] && size.height > UnSupport4kLength) {
            size.height = UnSupport4kLength;
            int w = UnSupport4kLength * 9 / 21;
            size.width =  (w + 3) & ~3;
        }
    } else if (editMode == NvEditMode18v9) {
        size.height = compileRes;
        size.width = compileRes * 18 / 9;
        if ([NvUtils isUnSupport4KEdit] && size.width > UnSupport4kLength) {
            size.width = UnSupport4kLength;
            int h = UnSupport4kLength * 9 / 18;
            size.height = (h + 1) & ~1;
        }
    } else if (editMode == NvEditMode9v18) {
        size.width = compileRes;
        size.height = compileRes * 18 / 9;
        if ([NvUtils isUnSupport4KEdit] && size.height > UnSupport4kLength) {
            size.height = UnSupport4kLength;
            int w = UnSupport4kLength * 9 / 18;
            size.width =  (w + 3) & ~3;
        }
    }else if (editMode == NvEditMode7v6) {
        size.height = compileRes;
        size.width = compileRes * 7 / 6;
    } else if (editMode == NvEditMode6v7) {
        size.width = compileRes;
        size.height = compileRes * 7 / 6;
    }else {
        size.width = 1280;
        size.height = 720;
    }
    NSNumber * OResolutionNum = NV_UserInfo(@"NvCompileResolution");
    if (OResolutionNum.intValue >= 2160) {
        NvsSize compileSize = [NvUtils calculateCompileSizeWithTimelineVideoSize:CGSizeMake(size.width, size.height) compileResolution:[NvUtils compileResolutionSetting]];
        size.width = compileSize.width;
        size.height = compileSize.height;
    }
    return size;
}

+ (NvsSize)calculateTimelineSizeWithAssetRatio:(float)assetRatio {
    int compileRes = 1080;
    NvsSize size;
    if (assetRatio<=9.0/16) {
        size.width = compileRes;
        float tmp = compileRes/assetRatio;
        NSInteger tmpInt = (NSInteger)tmp;
        size.height = (int)(tmpInt - tmpInt%2);
    }else {
        float tmp = compileRes*assetRatio;
        NSInteger tmpInt = (NSInteger)tmp;
        size.width = (int)(tmpInt - tmpInt%4);
        size.height = compileRes;
    }
    NSNumber * OResolutionNum = NV_UserInfo(@"NvCompileResolution");
    if (OResolutionNum.intValue >= 2160) {
        NvsSize compileSize = [NvUtils calculateCompileSizeWithTimelineVideoSize:CGSizeMake(size.width, size.height) compileResolution:[NvUtils compileResolutionSetting]];
        size.width = compileSize.width;
        size.height = compileSize.height;
    }
    return size;
}



//根据本地数据重建 timeline Rebuild timeline based on local data
+ (NvsTimeline *)createTimelineWithData:(NvTimelineData *)data {
    NvsTimeline *timeline = [NvTimelineUtils createTimeline:data.editMode];
    if (!timeline) {
        return nil;
    }
    [NvTimelineUtils resetTimeline:timeline data:data];
    return timeline;
}

+ (void)recreateTimeline:(NvsTimeline *)timeline
{
    if (timeline == nil ) {
        return;
    }
    // 先移除主题，确保添加前时间线是干净的 Remove the theme first to make sure the timeline is clean before adding
    [timeline removeCurrentTheme];
    [timeline deleteWatermark];
    NvTimelineData *timelineData = [NvTimelineData sharedInstance];
    [NvTimelineUtils resetTimeline:timeline data:timelineData];
}

+ (void)resetTimeline:(NvsTimeline *)timeline data:(NvTimelineData *)timelineData {
    //针对是否是dou视频进行区分处理 Distinguish whether the video is dou or not
    if (timelineData.isDou > 0){
        //dou视频音频轨道及转场处理 dou video audio track and transition processing
        [NvTimelineUtils resetDouEditData:timeline data:timelineData];
    }else{
        //拍摄及编辑模块 Shooting and editing module
        [NvTimelineUtils resetEditData:timeline editDataArray:timelineData.editDataArray];
    }
    
    NSMutableArray *order = [timelineData dataOrder];
    for (NSString *name in order) {
        if ([name isEqualToString:@"Music"]) {
            [NvTimelineUtils resetMusicTrack:timeline musicDataArray:timelineData.musicDataArray timelineData:timelineData];
        }
        if ([name isEqualToString:@"Dubbing"]) {
            [NvTimelineUtils resetDubbingTrack:timeline dubbingModel:timelineData.dubbingModel];
        }
        if ([name isEqualToString:@"Filter"]) {
            [NvTimelineUtils resetVideoFx:timeline videoFxDataArray:timelineData.videoFxDataArray timelineData:timelineData];
            [NvTimelineUtils resetTimelineFilter:timeline filterData:timelineData.timelineFilter];
            [NvTimelineUtils resetVideoFx:timeline timelineFilterArray:timelineData.timelineFilterArray];
            [NvTimelineUtils resetKeyframesFilter:timeline timelineData:timelineData];
        }
        if ([name isEqualToString:@"Sticker"]) {
            [NvTimelineUtils resetSticker:timeline stickerDataArray:timelineData.stickerDataArray];
        }
        if ([name isEqualToString:@"Caption"]) {
            [NvTimelineUtils resetCaption:timeline captionDataArray:timelineData.captionDataArray];
        }
        if ([name isEqualToString:@"CompoundCaption"]) {
            [NvTimelineUtils resetCompoundCaption:timeline captionDataArray:timelineData.compoundCaptionDataArray];
        }
        if ([name isEqualToString:@"Particle"]) {
            [NvTimelineUtils resetParticle:timeline particleDataArray:timelineData.particleDataArray];
        }
        
        if ([name isEqualToString:@"Watermark"]) {
            [NvTimelineUtils resetWatermark:timeline watermarkInfo:timelineData.watermarkInfo];
        }
        
        if ([name isEqualToString:@"Mask"]) {
            [NvTimelineUtils resetMaskFx:timeline model:timelineData];
        }
        if ([name isEqualToString:@"Theme"]) {
            [NvTimelineUtils resetTheme:timeline themeInfo:timelineData.themeInfo musicInfo:timelineData.musicDataArray];
            [NvTimelineUtils resetCaption:timeline captionDataArray:timelineData.captionDataArray];
        }
        if ([name isEqualToString:@"Makeup"]) {
            [NvTimelineUtils resetTimeline:timeline makeupData:timelineData.timelineMakeupModel];
        }
        if ([name isEqualToString:@"Beauty"]) {
            [NvTimelineUtils resetTimeline:timeline beautyEffect:timelineData.beautyArr shapeEffect:timelineData.shapeArr microShapeEffect:timelineData.microShapeArr];
        }
    }
    
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    for (int i = 0; i < timelineData.editDataArray.count; i++) {
        NvEditDataModel *editDataModel = timelineData.editDataArray[i];
        NvsVideoClip *videoClip = [videoTrack getClipWithIndex:i];
        if (editDataModel.sourceInfo.mediaFilePath.length > 0) {
            [videoClip setCropperWithModel:editDataModel.cropperModel
                          timelineVideoRes:timeline.videoRes
                                 assetSize:CGSizeMake(editDataModel.sourceInfo.pixelWidth, editDataModel.sourceInfo.pixelHeight)];
        }
        
        [NvTimelineUtils resetPropertyTransformEffect:videoClip editModel:editDataModel];
    }
    
    [NvTimelineUtils resetTransition:timeline transitionDataArray:timelineData.transitionDataArray];
    [NvTimelineUtils resetAnimationFx:timeline model:timelineData];
    [NvTimelineUtils resetBackgroundEffect:timeline model:timelineData];
}
+ (void)resetDouEditData:(NvsTimeline *)timeline data:(NvTimelineData *)timelineData {
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    NvsAudioTrack *audioTrack = [timeline getAudioTrackByIndex:0];
    
    if (timelineData.type != NvTimelineType_PlayRevert) {
        [NvTimelineUtils addClips:timelineData.editDataArray toTimeline:timeline];
    } else {
        NSMutableArray *sortFiles = [NSMutableArray array];
        for (int i = 0; i < timelineData.editDataArray.count; i++) {
            NvEditDataModel *info = timelineData.editDataArray[i];
            NvEditDataModel *infoRevert = [NvEditDataModel new];
            infoRevert.rotation = info.rotation;
            infoRevert.convertPath = info.convertPath;
            infoRevert.trimIn = info.trimIn;
            infoRevert.trimOut = info.trimOut;
            infoRevert.speed = info.speed;
            infoRevert.musicEndPos = info.musicEndPos;
            [sortFiles insertObject:infoRevert atIndex:0];
        }
        [NvTimelineUtils addClips:sortFiles toTimeline:timeline];
    }
    
    int64_t audioDuration = audioTrack.duration;
    if (timelineData.musicPath) {
        while (audioDuration < videoTrack.duration) {
            [audioTrack appendClip:timelineData.musicPath trimIn:timelineData.trimIn trimOut:timelineData.trimOut];
            audioDuration = audioTrack.duration;
        }
    }
    
    //实现dou视频相关时间特效 Implement dou video related time effects
    switch (timelineData.type) {
        case NvTimelineType_Repeat:
        {
            NvEditDataModel *model = timelineData.editDataArray.firstObject;
            NSString *jsonStr = [model yy_modelToJSONString];
            NvRecordingInfo *infoModel = [NvRecordingInfo yy_modelWithJSON:jsonStr];
            [NvTimelineUtils doRepeatTimeline:timeline.duration/2 videotrack:[timeline getVideoTrackByIndex:0] originCutTrimInfo:infoModel];
        }
            
            break;
        case NvTimelineType_Slow:
        {
            [NvTimelineUtils doSlowMotionTimeline:timeline.duration/2 videotrack:[timeline getVideoTrackByIndex:0]];
        }
            
            break;
            
        default:{
            
        }
            
            break;
    }
    
    //dou 视频内部不设置转场 No transition is set inside the dou video
    for (int i = 0; i < videoTrack.clipCount; i++) {
        [videoTrack setBuiltinTransition:i withName:NULL];
    }
    
}

+ (void)addClips:(NSArray <NvEditDataModel *>*)clips toTimeline:(NvsTimeline *)timeline {
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    [videoTrack setVolumeGain:0 rightVolumeGain:0];
    for (NvEditDataModel *info in clips) {
        NvsVideoClip *clip;
        if (info.localIdentifier.length > 0) {
            clip = [videoTrack appendClip:info.localIdentifier trimIn:info.trimIn trimOut:info.trimOut];
            [clip setExtraVideoRotation:info.rotation];
        } else {
            if (info.videoPath) {
                clip = [videoTrack appendClip:info.videoPath];
                [clip setExtraVideoRotation:info.rotation];
            } else {
                clip = [videoTrack appendClip:info.convertPath];
                [clip setExtraVideoRotation:info.rotation];
            }
        }
        [clip changeSpeed:info.speed];
    }
    
}

+ (void)resetClipCaption:(NvsVideoClip *)clip captionDataArray:(NSArray<NvCaptionInfoModel *> *)captionDataArray{
    NvsClipCaption *nextCaption = [clip getFirstCaption];
    do {
        if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
            nextCaption = [clip getNextCaption:nextCaption];
        }else{
            nextCaption = [clip removeCaption:nextCaption];
        }
    } while (nextCaption);
    // 根据编辑数据重新添加字幕 Re-add subtitles based on the edit data
    for (int i = 0; i < captionDataArray.count; i++) {
        NvCaptionInfoModel * info = (NvCaptionInfoModel *)captionDataArray[i];
        if (info.roleInTheme != NvsRoleInThemeGeneral && info.category == NvsThemeCategory) {
            continue;
        }
        
        
        NvsClipCaption* caption;
        if (info.type == Normal) {
            caption = [clip addCaption:info.text inPoint:info.inPoint duration:info.outPoint - info.inPoint captionStylePackageId:@""];
            [caption applyCaptionStyle:info.styleId];
            [caption setAbsoluteTimeUsed:true];
        } else {
            caption = [clip addModularCaption:info.text inPoint:info.inPoint duration:info.outPoint - info.inPoint];
            [caption setAbsoluteTimeUsed:true];
            [caption applyModularCaptionRenderer:info.renderId];
            [caption applyModularCaptionContext:info.contextId];
            if (info.animationModel.type == Caption) {
                [caption applyModularCaptionAnimation:info.animationModel.captionId];
                [caption setModularCaptionAnimationPeroid:info.animationModel.captionDuration];
            } else {
                [caption applyModularCaptionInAnimation:info.animationModel.inputId];
                [caption applyModularCaptionOutAnimation:info.animationModel.outputId];
                [caption setModularCaptionInAnimationDuration:info.animationModel.inputDuration];
                [caption setModularCaptionOutAnimationDuration:info.animationModel.outputDuration];
            }
        }
        if (info.keyFramesArray && info.keyFramesArray.count > 0) {
            BOOL opcacityControlRemove = YES;
            CGFloat opacity = info.keyFramesArray[0].opacity;
            for (NvKeyframeInfo *tempModel in info.keyFramesArray) {
                if (opacity != tempModel.opacity) {
                    opcacityControlRemove = NO;
                }
                [caption setCurrentKeyFrameTime:tempModel.pos];
                [caption setCaptionTranslation:tempModel.translation];
                [caption setScaleX:tempModel.scale];
                [caption setScaleY:tempModel.scale];
                [caption setRotationZ:tempModel.rotation];
                [caption setFloatValAtTime:@"Track Opacity" val:tempModel.opacity time:tempModel.pos];
//                NSLog(@"应用效果 Application opa %lld,%f",tempModel.pos,tempModel.opacity);
            }
            for (NvKeyframeInfo *tempModel in info.keyFramesArray) {
                [caption setCurrentKeyFrameTime:tempModel.pos];
                if (tempModel.translationPairX) {
                    [caption setControlPoint:@"Caption TransX" controlPointPair:tempModel.translationPairX];
                }
                if (tempModel.translationPairY) {
                    [caption setControlPoint:@"Caption TransY" controlPointPair:tempModel.translationPairY];
                }
                if (tempModel.opacity && opcacityControlRemove == NO) {
                    [caption setControlPoint:@"Track Opacity" controlPointPair:tempModel.opacityPairY];
//                    NSLog(@"应用效果 Application opa opacityPairY %f, %f, %f, %f",tempModel.opacityPairY.backwardControlPoint.x,tempModel.opacityPairY.backwardControlPoint.y,tempModel.opacityPairY.forwardControlPoint.x,tempModel.opacityPairY.forwardControlPoint.y);
                }
            }
        }else{
            if (info.isUserScale) {
                [caption setScaleX:info.scale];
                [caption setScaleY:info.scale];
            }
            if (info.isUserRotation) {
                [caption rotateCaption:info.rotation];
            }
            
            if (info.isUserTranslation) {
                [caption setCaptionTranslation:info.translation];
            }
            
        }
        NvsColor bgColor = info.textBgColor;
        [caption setBackgroundColor:&bgColor];
        
        [caption setBackgroundRadius:info.textBgRadius];
        [caption setBoundaryPaddingRatio:info.boundaryMargin];
        
        if (info.isUserOpacity) {
            [caption setOpacity:info.opacity];
        }
        
        if (info.isUserUnderLine) {
            if (info.isUnderLine) {
                [caption setUnderline:YES];
            } else {
                [caption setUnderline:NO];
            }
        }
        
        if (info.isModifyTextColor) {
            NvsColor color = info.textColor;
            [caption setTextColor:&color];
        }
        
        if (info.isModifyLetterSpace) {
            [caption setLetterSpacingType:NvsLetterSpacingTypeAbsolute];
            [caption setLetterSpacing:info.letterSpace];
        }
        
        if (info.isDrawOutline) {
            [caption setDrawOutline:YES];
            NvsColor color = info.outlineColor;
            [caption setOutlineColor:&color];
            [caption setOutlineWidth:info.outlineWidth];
        } else {
            [caption setDrawOutline:NO];
        }
        
        [caption setRecordingUserOperation:NO];
        [caption setVerticalLayout:info.isVerticalLayout];
        [caption setAttachment:info forKey:@"captionInfoModel"];
        if(caption == nil){
            continue;
        }
        [caption setFontSize:info.fontSize];
        
        [caption setTextAlignment:info.alignment];
        
        [caption setLineSpacing:info.letterLineSpace];
        
        if (info.isUserBold) {
            if (info.isBold) {
                [caption setBold:YES];
            } else {
                [caption setBold:NO];
            }
        }
        
        if (info.isUserItalic) {
            if (info.isItalic) {
                [caption setItalic:YES];
            } else {
                [caption setItalic:NO];
            }
        }
        
        if (info.isUserDrawShadow) {
            if (info.isDrawShadow) {
                [caption setDrawShadow:YES];
                NvsColor color = info.shadowColor;
                [caption setShadowColor:&color];
                [caption setShadowOffset:info.shadowOffset];
            } else {
                [caption setDrawShadow:NO];
            }
        }
        
        if (info.fontFilePath && ![info.fontFilePath isEqualToString:@""]) {
            [caption setFontWithFilePath:info.fontFilePath];
        } else {
            [caption setFontWithFilePath:@""];
        }
        [caption setRecordingUserOperation:YES];
    }
}

+ (void)resetCaption:(NvsTimeline *)timeline captionDataArray:(NSArray *)captionDataArray {
    NvsTimelineCaption *nextCaption = [timeline getFirstCaption];
    do {
        if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
            nextCaption = [timeline getNextCaption:nextCaption];
        }else{
            nextCaption = [timeline removeCaption:nextCaption];
        }
    } while (nextCaption);
    // 根据编辑数据重新添加字幕 Re-add subtitles based on the edit data
    for (int i = 0; i < captionDataArray.count; i++) {
        NvCaptionInfoModel * info = (NvCaptionInfoModel *)captionDataArray[i];
        if (info.roleInTheme != NvsRoleInThemeGeneral && info.category == NvsThemeCategory) {
            continue;
        }
        if (info.outPoint > timeline.duration) {
            info.outPoint = timeline.duration;
        }
        NvsTimelineCaption* caption;
        if (info.type == Normal) {
            caption = [timeline addCaption:info.text inPoint:info.inPoint duration:info.outPoint - info.inPoint captionStylePackageId:@""];
            [caption applyCaptionStyle:info.styleId];
        } else {
            caption = [timeline addModularCaption:info.text inPoint:info.inPoint duration:info.outPoint - info.inPoint];
            [caption resetTextColorState];
            [caption resetOutlineColorState];
            [caption applyModularCaptionRenderer:info.renderId];
            [caption applyModularCaptionContext:info.contextId];
            if (info.animationModel.type == Caption) {
                [caption applyModularCaptionAnimation:info.animationModel.captionId];
                [caption setModularCaptionAnimationPeroid:info.animationModel.captionDuration];
            } else {
                [caption applyModularCaptionInAnimation:info.animationModel.inputId];
                [caption applyModularCaptionOutAnimation:info.animationModel.outputId];
                [caption setModularCaptionInAnimationDuration:info.animationModel.inputDuration];
                [caption setModularCaptionOutAnimationDuration:info.animationModel.outputDuration];
            }
        }
        if (info.keyFramesArray && info.keyFramesArray.count > 0) {
            NSMutableArray *temp = [NSMutableArray array];
            BOOL opcacityControlRemove = YES;
            CGFloat opacity = info.keyFramesArray[0].opacity;
            for (NvKeyframeInfo *tempModel in info.keyFramesArray) {
                if (tempModel.time > timeline.duration) {
                    [temp addObject:tempModel];
                    continue;
                }
                if (opacity != tempModel.opacity) {
                    opcacityControlRemove = NO;
                }
                [caption setCurrentKeyFrameTime:tempModel.pos];
                [caption setCaptionTranslation:tempModel.translation];
                [caption setScaleX:tempModel.scale];
                [caption setScaleY:tempModel.scale];
                [caption setRotationZ:tempModel.rotation];
                [caption setFloatValAtTime:@"Track Opacity" val:tempModel.opacity time:tempModel.pos];
            }
            [info.keyFramesArray removeObjectsInArray:temp];
            for (NvKeyframeInfo *tempModel in info.keyFramesArray) {
                [caption setCurrentKeyFrameTime:tempModel.pos];
                if (tempModel.translationPairX) {
                    [caption setControlPoint:@"Caption TransX" controlPointPair:tempModel.translationPairX];
                }
                if (tempModel.translationPairY) {
                    [caption setControlPoint:@"Caption TransY" controlPointPair:tempModel.translationPairY];
                }
                if (tempModel.opacity && opcacityControlRemove == NO) {
                    [caption setControlPoint:@"Track Opacity" controlPointPair:tempModel.opacityPairY];
//                    NSLog(@"应用效果 Application opa opacityPairY timelinecaption %f, %f, %f, %f",tempModel.opacityPairY.backwardControlPoint.x,tempModel.opacityPairY.backwardControlPoint.y,tempModel.opacityPairY.forwardControlPoint.x,tempModel.opacityPairY.forwardControlPoint.y);
                }
            }
        }else{
            if (info.isUserScale) {
                [caption setScaleX:info.scale];
                [caption setScaleY:info.scale];
            }
            if (info.isUserRotation) {
                [caption rotateCaption:info.rotation];
            }
            
            if (info.isUserTranslation) {
                [caption setCaptionTranslation:info.translation];
            }
            
        }
        if (info.isModifyTextBgColor) {
            NvsColor bgColor = info.textBgColor;
            [caption setBackgroundColor:&bgColor];
        }
        if (info.isModifyTextBgRadius) {
            [caption setBackgroundRadius:info.textBgRadius];
        }
        
        [caption setBoundaryPaddingRatio:info.boundaryMargin];
        if (info.isUserOpacity) {
            [caption setOpacity:info.opacity];
        }
        
        if (info.isUserUnderLine) {
            if (info.isUnderLine) {
                [caption setUnderline:YES];
            } else {
                [caption setUnderline:NO];
            }
        }
        
        if (info.isModifyTextColor) {
            NvsColor color = info.textColor;
            [caption setTextColor:&color];
        }
        
        if (info.isModifyLetterSpace) {
            [caption setLetterSpacingType:NvsLetterSpacingTypeAbsolute];
            [caption setLetterSpacing:info.letterSpace];
        }
        
        if (info.isDrawOutline) {
            [caption setDrawOutline:YES];
            NvsColor color = info.outlineColor;
            [caption setOutlineColor:&color];
            [caption setOutlineWidth:info.outlineWidth];
        } else {
            [caption setDrawOutline:NO];
        }
        
        [caption setRecordingUserOperation:NO];
        [caption setVerticalLayout:info.isVerticalLayout];
        [caption setAttachment:info forKey:@"captionInfoModel"];
        if(caption == nil){
            continue;
        }
        [caption setFontSize:info.fontSize];
        
        
        [caption setTextAlignment:info.alignment];
        [caption setLineSpacing:info.letterLineSpace];
        
        if (info.isUserBold) {
            if (info.isBold) {
                [caption setBold:YES];
            } else {
                [caption setBold:NO];
            }
        }
        
        if (info.isUserItalic) {
            if (info.isItalic) {
                [caption setItalic:YES];
            } else {
                [caption setItalic:NO];
            }
        }
        
        if (info.isUserDrawShadow) {
            if (info.isDrawShadow) {
                [caption setDrawShadow:YES];
                NvsColor color = info.shadowColor;
                [caption setShadowColor:&color];
                [caption setShadowOffset:info.shadowOffset];
            } else {
                [caption setDrawShadow:NO];
            }
        }
        
        if (info.fontFilePath && ![info.fontFilePath isEqualToString:@""]) {
            [caption setFontWithFilePath:info.fontFilePath];
        } else {
            [caption setFontWithFilePath:@""];
        }
        [caption setRecordingUserOperation:YES];
        
        //Set the textSpanList
        if (info.textSpanArray.count > 0) {
            NSMutableArray *applyCaptionSpans = [NSMutableArray array];
            for (NvCaptionSpan *spanInfo in info.textSpanArray) {
                NSString *type = spanInfo.type;
                NSInteger start = spanInfo.start;
                NSInteger end = spanInfo.end;
                NSObject *value = spanInfo.value;
                if ([type isEqualToString:NVS_SPAN_TYPE_COLOR]) {
                    NvsCaptionColorSpan *span = [NvsCaptionColorSpan new];
                    span.type = type;
                    span.start = start;
                    span.end = end;
                    NSString *colorStr = (NSString *)value;
                    NSArray *colors = [colorStr componentsSeparatedByString:@","];
                    if (colors.count == 4) {
                        span.r = [colors[0] floatValue];
                        span.g = [colors[1] floatValue];
                        span.b = [colors[2] floatValue];
                    }
                    [applyCaptionSpans addObject:span];
                }else if ([type isEqualToString:NVS_SPAN_TYPE_FONT_FAMILY]) {
                    NvsCaptionFontFamilySpan *span = [NvsCaptionFontFamilySpan new];
                    span.type = type;
                    span.start = start;
                    span.end = end;
                    NSString *valueStr = (NSString *)value;
                    span.fontFamily = valueStr;
                    [applyCaptionSpans addObject:span];
                }else if ([type isEqualToString:NVS_SPAN_TYPE_ITALIC]) {
                    NvsCaptionItalicSpan *span = [NvsCaptionItalicSpan new];
                    span.type = type;
                    span.start = start;
                    span.end = end;
                    NSNumber *valueNumber = (NSNumber *)value;
                    span.italic = [valueNumber boolValue];
                    [applyCaptionSpans addObject:span];
                }else if ([type isEqualToString:NVS_SPAN_TYPE_UNDERLINE]) {
                    NvsCaptionUnderlineSpan  *span = [NvsCaptionUnderlineSpan new];
                    span.type = type;
                    span.start = start;
                    span.end = end;
                    NSNumber *valueNumber = (NSNumber *)value;
                    span.underline = [valueNumber boolValue];
                    [applyCaptionSpans addObject:span];
                }else if ([type isEqualToString:NVS_SPAN_TYPE_OPACITY]) {
                    NvsCaptionOpacitySpan *span = [NvsCaptionOpacitySpan new];
                    span.type = type;
                    span.start = start;
                    span.end = end;
                    NSNumber *valueNumber = (NSNumber *)value;
                    span.opacity = [valueNumber floatValue];
                    [applyCaptionSpans addObject:span];
                }else if ([type isEqualToString:NVS_SPAN_TYPE_RENDERERID]) {
                    [caption resetTextColorState];
                    [caption resetOutlineColorState];
                    NvsCaptionRendererIdSpan *span = [NvsCaptionRendererIdSpan new];
                    span.type = type;
                    span.start = start;
                    span.end = end;
                    NSString *rendererId = (NSString *)value;
                    span.rendererId = rendererId;
                    [applyCaptionSpans addObject:span];
                }else if ([type isEqualToString:NVS_SPAN_TYPE_OUTLINE_COLOR]) {
                    NvsCaptionOutlineColorSpan *span = [NvsCaptionOutlineColorSpan new];
                    span.type = type;
                    span.start = start;
                    span.end = end;
                    NSString *colorStr = (NSString *)value;
                    NSArray *colors = [colorStr componentsSeparatedByString:@","];
                    if (colors.count == 4) {
                        span.r = [colors[0] floatValue];
                        span.g = [colors[1] floatValue];
                        span.b = [colors[2] floatValue];
                    }
                    [applyCaptionSpans addObject:span];
                }else if ([type isEqualToString:NVS_SPAN_TYPE_OUTLINE_WIDTH]) {
                    NvsCaptionOutlineWidthSpan *span = [NvsCaptionOutlineWidthSpan new];
                    span.type = type;
                    span.start = start;
                    span.end = end;
                    NSNumber *valueNumber = (NSNumber *)value;
                    span.outlineWidth = [valueNumber floatValue];
                    [applyCaptionSpans addObject:span];
                }else if ([type isEqualToString:NVS_SPAN_TYPE_NORMAL_TEXT]) {
                    NvsCaptionNormalTextSpan *span = [NvsCaptionNormalTextSpan new];
                    span.type = type;
                    span.start = start;
                    span.end = end;
                    NSNumber *valueNumber = (NSNumber *)value;
                    span.outlineWidth = [valueNumber floatValue];
                    [applyCaptionSpans addObject:span];
                }else if ([type isEqualToString:NVS_SPAN_TYPE_FONT_SIZE_RATIO]) {
                    NvsCaptionFontSizeRatioSpan *fontSizeRatioSpan = [NvsCaptionFontSizeRatioSpan new];
                    fontSizeRatioSpan.type = NVS_SPAN_TYPE_FONT_SIZE_RATIO;
                    fontSizeRatioSpan.start = start;
                    fontSizeRatioSpan.end = end;
                    NSNumber *valueNumber = (NSNumber *)value;
                    fontSizeRatioSpan.fontSizeRatio = [valueNumber floatValue];
                    [applyCaptionSpans addObject:fontSizeRatioSpan];
                }else if ([type isEqualToString:NVS_SPAN_TYPE_BODY_OPACITY]) {
                    NvsCaptionBodyOpacitySpan *bodyOpacitySpan = [NvsCaptionBodyOpacitySpan new];
                    bodyOpacitySpan.type = NVS_SPAN_TYPE_BODY_OPACITY;
                    bodyOpacitySpan.start = start;
                    bodyOpacitySpan.end = end;
                    NSNumber *valueNumber = (NSNumber *)value;
                    bodyOpacitySpan.bodyOpacity = [valueNumber floatValue];
                    [applyCaptionSpans addObject:bodyOpacitySpan];
                }else if ([type isEqualToString:NVS_SPAN_TYPE_OUTLINE_OPACITY]) {
                    NvsCaptionOutlineOpacitySpan *outlineOpacitySpan = [NvsCaptionOutlineOpacitySpan new];
                    outlineOpacitySpan.type = NVS_SPAN_TYPE_OUTLINE_OPACITY;
                    outlineOpacitySpan.start = start;
                    outlineOpacitySpan.end = end;
                    NSNumber *valueNumber = (NSNumber *)value;
                    outlineOpacitySpan.outlineOpacity = [valueNumber floatValue];
                    [applyCaptionSpans addObject:outlineOpacitySpan];
                }else if ([type isEqualToString:NVS_SPAN_TYPE_SHADOW_OPACITY]) {
                    NvsCaptionShadowOpacitySpan *shadowOpacitySpan = [NvsCaptionShadowOpacitySpan new];
                    shadowOpacitySpan.type = NVS_SPAN_TYPE_SHADOW_OPACITY;
                    shadowOpacitySpan.start = start;
                    shadowOpacitySpan.end = end;
                    NSNumber *valueNumber = (NSNumber *)value;
                    shadowOpacitySpan.shadowOpacity = [valueNumber floatValue];
                    [applyCaptionSpans addObject:shadowOpacitySpan];
                }
            }
            [caption setTextSpanList:applyCaptionSpans];
        }
    }
}

+ (CGPoint)getCenterWithArray:(NSArray*)array {
    NSValue *leftTopValue = array[0];
    NSValue *rightBottomValue = array[2];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    return CGPointMake((topLeftCorner.x+rightBottomCorner.x)/2, (topLeftCorner.y+rightBottomCorner.y)/2);
}

+ (void)resetCompoundCaption:(NvsTimeline *)timeline captionDataArray:(NSArray *)captionDataArray {
    NvsTimelineCompoundCaption *nextCaption = [timeline getFirstCompoundCaption];
    do {
        nextCaption = [timeline removeCompoundCaption:nextCaption];
    } while (nextCaption);
    // 根据编辑数据重新添加字幕 Re-add subtitles based on the edit data
    for (int i = 0; i < captionDataArray.count; i++) {
        NvCompoundCaptionInfoModel * info = (NvCompoundCaptionInfoModel *)captionDataArray[i];
        NvsTimelineCompoundCaption *caption = [timeline addCompoundCaption:info.inPoint duration:info.outPoint - info.inPoint compoundCaptionPackageId:info.packageId];
        [caption setAttachment:info forKey:@"compoundInfoModel"];
        if (caption == nil) {
            continue;
        }
        //设置子字幕属性 Sets subtitle properties
        NSMutableArray *captionArr = info.captionArr;
        for (NvInnerCompoundCaptionModel *modelInfo in captionArr) {
            CGFloat r,g,b,a;
            if (modelInfo.colorString) {
                [[UIColor nv_colorWithHexARGB:modelInfo.colorString] getRed:&r green:&g blue:&b alpha:&a];
                NvsColor color = {r,g,b,a};
                [caption setTextColor:modelInfo.index textColor:&color];
            }
            if (modelInfo.text) {
                [caption setText:modelInfo.index text:modelInfo.text];
            }
            if (modelInfo.fontFamily) {
                [caption setFontFamily:modelInfo.index family:modelInfo.fontFamily];
            }
            if (modelInfo.hasTextBgColor) {
                [caption setBackgroundColor:modelInfo.textBgColor captionIndex:(int)modelInfo.index];
            }
            
            if (modelInfo.isUserDrawOutline) {
                [caption setDrawOutline:YES captionIndex:(int)modelInfo.index];
                [caption setOutlineWidth:modelInfo.outlineWidth captionIndex:(int)modelInfo.index];
                [caption setOutlineColor:modelInfo.outlineColor captionIndex:(int)modelInfo.index];
            }
            
            if (modelInfo.isItalic) {
                [caption setItalic:modelInfo.isItalic captionIndex:(int)modelInfo.index];
            }
        }
        //设置字幕属性 Set subtitle properties
        if (info.clipAffinityEnabled) {
            caption.clipAffinityEnabled = info.clipAffinityEnabled;
        }
        [caption setCaptionTranslation:info.translationOffset];
        [caption setRotationZ:info.rotation];
        [caption setScaleX:info.scale];
        [caption setScaleY:info.scale];
    }
}

+ (void)resetClipSticker:(NvsVideoClip *)clip stickerDataArray:(NSArray *)stickerDataArray{
    NvsClipAnimatedSticker *sticker = [clip getFirstAnimatedSticker];
    while (sticker) {
        sticker = [clip removeAnimatedSticker:sticker];
    }
    // 根据编辑数据重新添加贴纸 Re-add stickers according to the edit data
    for (int i = 0; i < stickerDataArray.count; i++) {
        NvStickerInfoModel *info = (NvStickerInfoModel *)stickerDataArray[i];
        NvsClipAnimatedSticker * sticker = nil;
        if (info.isCustomSticer) {
            sticker = [clip addCustomAnimatedSticker:info.inPoint duration:info.outPoint - info.inPoint animatedStickerPackageId:info.packageId customImagePath:info.customImagePath];
        } else {
            sticker = [clip addAnimatedSticker:info.inPoint duration:info.outPoint - info.inPoint animatedStickerPackageId:info.packageId];
        }
        if(sticker == nil){
            continue;
        }
        [sticker setAbsoluteTimeUsed:true];
        [sticker setAttachment:info forKey:@"stickerInfoModel"];
        
        if (info.keyFramesArray && info.keyFramesArray.count > 0) {
            for (NvKeyFrameStickerModel *tempModel in info.keyFramesArray) {
                [sticker setCurrentKeyFrameTime:tempModel.pos];
                [sticker setTranslation:tempModel.translation];
                [sticker setScale:tempModel.scale];
                [sticker setRotationZ:tempModel.rotation];
                
                NSLog(@"应用效果 Application effect%lld,%@",tempModel.time,NSStringFromCGPoint(tempModel.translation));
            }
        }else{
            [sticker setTranslation:info.translation];
            [sticker setScale:info.scale];
            [sticker setRotationZ:info.rotation];
        }
        [sticker setVolumeGain:info.volume rightVolumeGain:info.volume];
        [sticker setHorizontalFlip:info.isHorizontalFlip];
        if (info.stickerAnimationInfo.type == StickerCom) {
            [sticker applyAnimatedStickerPeriodAnimation:info.stickerAnimationInfo.stickerId];
            [sticker setAnimatedStickerAnimationPeriod:info.stickerAnimationInfo.stickerDuration];
        } else {
            [sticker applyAnimatedStickerInAnimation:info.stickerAnimationInfo.inputId];
            [sticker applyAnimatedStickerOutAnimation:info.stickerAnimationInfo.outputId];
            [sticker setAnimatedStickerInAnimationDuration:info.stickerAnimationInfo.inputDuration];
            [sticker setAnimatedStickerOutAnimationDuration:info.stickerAnimationInfo.outputDuration];
        }
    }
}



+ (void)resetSticker:(NvsTimeline *)timeline stickerDataArray:(NSArray *)stickerDataArray{
    NvsTimelineAnimatedSticker *sticker = [timeline getFirstAnimatedSticker];
    while (sticker) {
        sticker = [timeline removeAnimatedSticker:sticker];
    }
    // 根据编辑数据重新添加贴纸 Re-add stickers according to the edit data
    for (int i = 0; i < stickerDataArray.count; i++) {
        NvStickerInfoModel *info = (NvStickerInfoModel *)stickerDataArray[i];
        NvsTimelineAnimatedSticker * sticker = nil;
        if (info.isCustomSticer) {
            sticker = [timeline addCustomAnimatedSticker:info.inPoint duration:info.outPoint - info.inPoint animatedStickerPackageId:info.packageId customImagePath:info.customImagePath];
        } else {
            sticker = [timeline addAnimatedSticker:info.inPoint duration:info.outPoint - info.inPoint animatedStickerPackageId:info.packageId];
        }
        if(sticker == nil){
            continue;
        }
        
        [sticker setAttachment:info forKey:@"stickerInfoModel"];
        
        if (info.keyFramesArray && info.keyFramesArray.count > 0) {
            for (NvKeyFrameStickerModel *tempModel in info.keyFramesArray) {
                [sticker setCurrentKeyFrameTime:tempModel.pos];
                [sticker setTranslation:tempModel.translation];
                [sticker setScale:tempModel.scale];
                [sticker setRotationZ:tempModel.rotation];
                
                NSLog(@"应用效果 Application effect%lld,%@",tempModel.time,NSStringFromCGPoint(tempModel.translation));
            }
        }else{
            [sticker setTranslation:info.translation];
            [sticker setScale:info.scale];
            [sticker setRotationZ:info.rotation];
        }
        [sticker setVolumeGain:info.volume rightVolumeGain:info.volume];
        [sticker setHorizontalFlip:info.isHorizontalFlip];
        if (info.stickerAnimationInfo.type == StickerCom) {
            [sticker applyAnimatedStickerPeriodAnimation:info.stickerAnimationInfo.stickerId];
            [sticker setAnimatedStickerAnimationPeriod:info.stickerAnimationInfo.stickerDuration];
        } else {
            [sticker applyAnimatedStickerInAnimation:info.stickerAnimationInfo.inputId];
            [sticker applyAnimatedStickerOutAnimation:info.stickerAnimationInfo.outputId];
            [sticker setAnimatedStickerInAnimationDuration:info.stickerAnimationInfo.inputDuration];
            [sticker setAnimatedStickerOutAnimationDuration:info.stickerAnimationInfo.outputDuration];
        }
    }
}

+ (void)resetTheme:(NvsTimeline *)timeline themeInfo:(NvThemeInfoModel *)themeInfo {
    [NvTimelineUtils resetTheme:timeline themeInfo:themeInfo musicInfo:[[NvTimelineData sharedInstance] musicDataArray]];
}

+ (void)resetTheme:(NvsTimeline *)timeline themeInfo:(NvThemeInfoModel *)themeInfo musicInfo:(NSMutableArray *)musicInfo {
    [timeline removeCurrentTheme];
    [timeline applyTheme:themeInfo.themeName];
    NSMutableArray *musicDataArray = musicInfo;
    if ([musicDataArray count] > 0) {
        [timeline setThemeMusicVolumeGain:0 rightVolumeGain:0];
    } else {
        [timeline setThemeMusicVolumeGain:themeInfo.volume rightVolumeGain:themeInfo.volume];
    }
    if (themeInfo.thenmeRoleInTheme == NvsRoleInThemeTitle) {
        [timeline setThemeTitleCaptionText:themeInfo.themeString];
    }else if(themeInfo.thenmeRoleInTheme == NvsRoleInThemeTrailer){
        [timeline setThemeTrailerCaptionText:themeInfo.themeString];
    }
    //应用两次是因为改完主题的字幕文字的时候，不生效 Apply it twice because after changing the title text of the theme, it does not take effect
    [timeline applyTheme:themeInfo.themeName];
}

+ (void)resetAnimationFx:(NvsTimeline *)timeline model:(NvTimelineData *)timelineData{
    
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    for (int i = 0; i < timelineData.editDataArray.count; i++) {
        NvEditDataModel *editDataModel = timelineData.editDataArray[i];
        NvAnimationInfoModel *model = editDataModel.animationInfoModel;
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        
        if (![clip isPropertyVideoFxEnabled] && model.isUsePropertyEffect) {
            [clip enablePropertyVideoFx:YES];
        }
        [NvTimelineUtils setAnimationFx:videoTrack clip:clip model:model];
    }
    
}

+ (void)resetAnimationFxFollowTransition:(NvsTimeline *)timeline transitionIndex:(int)index transitionDuration:(double)transitionDuration {
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    NvsVideoClip *preClip = [videoTrack getClipWithIndex:index];
    NvTimelineData *timelineData = [NvTimelineData sharedInstance];
    NvEditDataModel *editDataModel = timelineData.editDataArray[index];
    NvAnimationInfoModel *model = editDataModel.animationInfoModel;
    if (![preClip isPropertyVideoFxEnabled] && model.isUsePropertyEffect) {
        [preClip enablePropertyVideoFx:YES];
    }
    [NvTimelineUtils setAnimationFx:videoTrack clip:preClip model:model];
    if (index<videoTrack.clipCount-1) {
        NvsVideoClip *nextClip = [videoTrack getClipWithIndex:index+1];
        NvEditDataModel *editDataModel = timelineData.editDataArray[index+1];
        NvAnimationInfoModel *model1 = editDataModel.animationInfoModel;
        
        if (![nextClip isPropertyVideoFxEnabled] && model.isUsePropertyEffect) {
            [nextClip enablePropertyVideoFx:YES];
        }
        [NvTimelineUtils setAnimationFx:videoTrack clip:nextClip model:model1];
    }
}

+ (void)setAnimationFx:(NvsVideoTrack *)track clip:(NvsVideoClip *)clip model:(NvAnimationInfoModel *)model {
    /*
     动画需要考虑转场引起的时间问题
     入动画：inPoint 不变， outPoint = outPoint + 0.5*preTransitionTime
     出动画：inPoint = inPoint + 0.5*preTransitionTime, outPoint = outPoint + 0.5*preTransitionTime + 0.5*transitionTime
     组合动画：inPoint 不变，outPoint = outPoint + 0.5*preTransitionTime + 0.5*transitionTime
     注： 还需考虑clip 的index 因素，如第一个clip 前面没有转场，最后一个clip 后面没有转场
     
     Animations need to consider the timing issues caused by transitions
     inPoint: outPoint = outPoint + 0.5*preTransitionTime
     Animation: inPoint = inPoint + 0.5*preTransitionTime, outPoint = outPoint + 0.5*preTransitionTime + 0.5*transitionTime
     Combined animation: inPoint does not change, outPoint = outPoint + 0.5*preTransitionTime + 0.5*transitionTime
     Note: The index factor of clip should also be considered. For example, there is no transition in front of the first clip and no transition in back of the last clip
     */
    NvsVideoFx *fx = [clip getPropertyVideoFx];
    if (!model.isUsePropertyEffect) {
        [fx setStringVal:@"Package Id" val:nil];
        [fx setStringVal:@"Post Package Id" val:nil];
        [fx setFloatVal:@"Package Effect In" val:0];
        [fx setFloatVal:@"Package Effect Out" val:0];
        [fx setStringVal:@"Package2 Id" val:nil];
        [fx setStringVal:@"Post Package2 Id" val:nil];
        [fx setFloatVal:@"Package2 Effect In" val:0];
        [fx setFloatVal:@"Package2 Effect Out" val:0];
    } else {
        NvsVideoTransition *preTransition = [track getTransitionWithSourceClipIndex:clip.index-1];
        NvsVideoTransition *transition = [track getTransitionWithSourceClipIndex:clip.index];
        if (model.animationCategory == NvAnimationCategoryCombine) {
            NSString *packageIdParam = model.isPostPackage ? @"Post Package Id" : @"Package Id";
            NSString *invalidPackageIdParam = model.isPostPackage ? @"Package Id" : @"Post Package Id";
            [fx setStringVal:packageIdParam val:model.packageId];
            [fx setStringVal:invalidPackageIdParam val:nil];
            double inPoint = model.animationStart;
            double outPoint = model.animationEnd + preTransition.getVideoTransitionDuration * 0.5 + transition.getVideoTransitionDuration * 0.5;
            [fx setFloatVal:@"Package Effect In" val:inPoint];
            [fx setFloatVal:@"Package Effect Out" val:outPoint];
            
            [fx setStringVal:@"Package2 Id" val:nil];
            [fx setStringVal:@"Post Package2 Id" val:nil];
            [fx setFloatVal:@"Package2 Effect In" val:0];
            [fx setFloatVal:@"Package2 Effect Out" val:0];
        } else {
            //包中带这个表达式的才需要这个字段 单位秒，这个字段表示的是动画的时长.只有入动画才有必要设置该属性。
            //The package with this expression requires this field in seconds, which represents the length of the animation. It is only necessary to set this property when animating.
            
            NSString *packageIdParam = model.isPostPackage ? @"Post Package Id" : @"Package Id";
            NSString *invalidPackageIdParam = model.isPostPackage ? @"Package Id" : @"Post Package Id";
            [fx setStringVal:packageIdParam val:model.packageId];
            [fx setStringVal:invalidPackageIdParam val:nil];
            
            double inPoint = model.animationStart;
            double outPoint = model.animationEnd + transition.getVideoTransitionDuration * 0.5;
            [fx setExprVar:@"amplitude" varValue:(outPoint - inPoint) * 1.0f / NV_TIME_BASE];
            [fx setFloatVal:@"Package Effect In" val:inPoint];
            [fx setFloatVal:@"Package Effect Out" val:outPoint];
            
            NSString *packageIdParam2 = model.isPostPackage2 ? @"Post Package2 Id" : @"Package2 Id";
            NSString *invalidPackageIdParam2 = model.isPostPackage2 ? @"Package2 Id" : @"Post Package2 Id";
            [fx setStringVal:packageIdParam2 val:model.packageId2];
            [fx setStringVal:invalidPackageIdParam2 val:nil];
            double inPoint2 = model.animationStart2 + preTransition.getVideoTransitionDuration * 0.5;
            double outPoint2 = model.animationEnd2 + preTransition.getVideoTransitionDuration * 0.5 + transition.getVideoTransitionDuration * 0.5;
            [fx setFloatVal:@"Package2 Effect In" val:inPoint2];
            [fx setFloatVal:@"Package2 Effect Out" val:outPoint2];
        }
    }
}


+ (void)resetMaskFx:(NvsTimeline *)timeline model:(NvTimelineData *)timelineData{
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    for (int i = 0; i < timelineData.editDataArray.count; i++) {
        NvEditDataModel *editDataModel = timelineData.editDataArray[i];
        NvMaskModel *model = editDataModel.maskInfoModel;
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        
        if(model.maskType != NvClipMaskTypeNone) {
            [clip setImageMotionMode:NvsStreamingEngineImageClipMotionMode_LetterBoxZoomIn];
            [clip setImageMotionAnimationEnabled:NO];
        }
        
        CGSize assetSize = CGSizeZero;
        if (editDataModel.cropperModel) {
            assetSize = editDataModel.cropperModel.cropSize;
        }
        if(CGSizeEqualToSize(assetSize, CGSizeZero)){
            if (editDataModel.isImage) {
                assetSize = [NvTimelineUtils getAVFileSize:editDataModel.localIdentifier];
            }else{
                assetSize = [NvTimelineUtils getAVFileSize:editDataModel.videoPath];
            }
        }
        [NvMaskHelper prepareMaskRegionPointsWithMaskModel:model assetResolution:assetSize];
        [clip setMaskWithMaskModel:model resolution:assetSize];
    }
}

+ (void)resetWatermark:(NvsTimeline *)timeline watermarkInfo:(NvWatermarkInfoModel *)watermarkInfo{
    [timeline deleteWatermark];
    NvsTimelineVideoFx *nextFx = [timeline getFirstTimelineVideoFx];
    while (nextFx) {
        if ([nextFx.bultinTimelineVideoFxName isEqualToString:@"Storyboard"] || [nextFx.bultinTimelineVideoFxName isEqualToString:@"Mosaic"] || [nextFx.bultinTimelineVideoFxName isEqualToString:@"Fast Blur"]){
            nextFx = [timeline removeTimelineVideoFx:nextFx];
        }else{
            nextFx = [timeline getNextTimelineVideoFx:nextFx];
        }
    }
    if (watermarkInfo.isCaf) {
        NvsTimelineVideoFx *videoFx = [timeline addBuiltinTimelineVideoFx:0 duration:timeline.duration videoFxName:@"Storyboard"];
        NSString *descString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><storyboard sceneWidth=\"Swidth\" sceneHeight=\"SHeight\"><track source=\"cafFile\" width=\"Nwidth\" height=\"Nheight\" clipStart=\"0\" clipDuration=\"2000\" repeat=\"true\"><effect name=\"transform\"><param name=\"opacity\" value=\"1\"/><param name=\"transX\" value=\"0\"/><param name=\"transY\" value=\"0\"/></effect></track></storyboard>"];
        
        descString = [descString stringByReplacingOccurrencesOfString:@"Swidth" withString:[NSString stringWithFormat:@"%d",(int)watermarkInfo.sceneWidth]];
        descString = [descString stringByReplacingOccurrencesOfString:@"SHeight" withString:[NSString stringWithFormat:@"%d",(int)watermarkInfo.sceneHeight]];
        descString = [descString stringByReplacingOccurrencesOfString:@"Nwidth" withString:[NSString stringWithFormat:@"%d",(int)watermarkInfo.displayWidth]];
        descString = [descString stringByReplacingOccurrencesOfString:@"Nheight" withString:[NSString stringWithFormat:@"%d",(int)watermarkInfo.displayHeight]];
        descString = [descString stringByReplacingOccurrencesOfString:@"cafFile" withString:[NSString stringWithFormat:@"%@.caf",watermarkInfo.imageUrl]];
        NSLog(@"descString==%@",descString);
        [videoFx setStringVal:@"Resource Dir" val:WATEMARK_PATH];
        [videoFx setStringVal:@"Description String" val:descString];
        [videoFx setBooleanVal:@"Is Animated Sticker" val:true];
        [videoFx setFloatVal:@"Sticker TransX" val:watermarkInfo.marginX];
        [videoFx setFloatVal:@"Sticker TransY" val:watermarkInfo.marginY];
    }else if (watermarkInfo.isBuiltInEffect) {
        CGRect rect = CGRectMake(watermarkInfo.marginX, watermarkInfo.marginY, watermarkInfo.displayWidth, watermarkInfo.displayHeight);
        NvsTimelineVideoFx *videoFx = [timeline addBuiltinTimelineVideoFx:watermarkInfo.inPoint duration:watermarkInfo.outPoint videoFxName:watermarkInfo.builtInEffect.effectName];
        [videoFx setRegional:YES];
        NSArray *pointsArr = [NvTimelineUtils getRegionWithRect:rect sceneWidth:watermarkInfo.sceneWidth sceneHeight:watermarkInfo.sceneHeight];
        [videoFx setRegion:pointsArr];
        if (watermarkInfo.builtInEffect.unitSize >= 0) {
            [videoFx setFloatVal:@"Unit Size" val:watermarkInfo.builtInEffect.unitSize];
        }
        if (watermarkInfo.builtInEffect.intensity > 0) {
            [videoFx setFilterIntensity:watermarkInfo.builtInEffect.intensity];
        }
    }else{
        if (watermarkInfo.imageUrl) {
            NSString *path = [WATEMARK_PATH stringByAppendingPathComponent:[watermarkInfo.imageUrl stringByAppendingString:@".png"]];
            [timeline addWatermark:path displayWidth:watermarkInfo.displayWidth displayHeight:watermarkInfo.displayHeight opacity:watermarkInfo.opacity position:watermarkInfo.position marginX:watermarkInfo.marginX marginY:watermarkInfo.marginY];
        }
    }
}

+ (void)resetParticle:(NvsTimeline *)timeline particleDataArray:(NSArray *)particleDataArray {
    NvsTimelineVideoFx *videoFx = [timeline getFirstTimelineVideoFx];
    while (videoFx) {
        NvsParticleSystemContext *particleContext = [videoFx getParticleSystemContext];
        if (particleContext) {
            videoFx = [timeline removeTimelineVideoFx:videoFx];
            continue;
        }
        videoFx = [timeline getNextTimelineVideoFx:videoFx];
    }
    // 根据编辑数据重新添加粒子 Re-add particles based on the edited data
    for (int i = 0; i < particleDataArray.count; i++) {
        NvParticleInfoModel *info = (NvParticleInfoModel *)particleDataArray[i];
        
        NvsTimelineVideoFx *particleVideoFx = [timeline addPackagedTimelineVideoFx:info.inPoint duration:info.outPoint - info.inPoint videoFxPackageId:info.name];
        if (particleVideoFx == nil) {
            continue;
        }
        NvsParticleSystemContext *particleSystemContext = [particleVideoFx getParticleSystemContext];
        if (particleSystemContext == nil) {
            continue;
        }
        
        for (NSMutableDictionary * dict in info.particleLocation) {
            for (NSString *key in dict) {
                CGPoint point = [(NSValue *)dict[key] CGPointValue];
                for (int j = 0; j < info.emitterName.count; j++) {
                    [particleSystemContext appendPositionToEmitterPositionCurve:info.emitterName[j]
                                                                      curveTime:(float)([(NSString *)key longLongValue] - info.inPoint)/NV_TIME_BASE
                                                               emitterPositionX:point.x
                                                               emitterPositionY:point.y];
                    [particleSystemContext setEmitterRateGain:info.name emitterGain:info.particleRateValue];
                    [particleSystemContext SetEmitterParticleSizeGain:info.name emitterGain:info.particleSizeValue];
                }
            }
        }
    }
}

+ (void)resetEditData:(NvsTimeline *)timeline editDataArray:(NSArray *)editDataArray {
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    
    if (videoTrack == nil) {
        return;
    }
    [videoTrack removeAllClips];
    
    for (int i = 0; i < editDataArray.count; i++) {
        NvEditDataModel *editDataModel = editDataArray[i];
        NvsVideoClip *videoClip = [videoTrack appendClip:editDataModel.isImage ? editDataModel.localIdentifier : editDataModel.videoPath
                                                  trimIn:editDataModel.trimIn
                                                 trimOut:editDataModel.trimOut];
        
        if (!videoClip) {
            continue;
        }
        [videoClip setClipWrapMode:NvsClipWrapMode_Repeat];
        BOOL isBlur = [[[NSUserDefaults standardUserDefaults] valueForKey:@"NvBackgroudBlurFilled"] boolValue];
        if (isBlur) {
            [videoClip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
        } else {
            [videoClip setSourceBackgroundMode:NvsSourceBackgroundModeColorSolid];
        }
        
        
        //曲线变速 Curve speed change
        if (editDataModel.curveSpeeds.count > 0) {
            [NvTimelineUtils applyCurveSpeed:videoClip points:editDataModel.curveSpeeds];
        }else {
            //普通变速 Ordinary speed change
            [videoClip changeSpeed:editDataModel.speed keepAudioPitch:editDataModel.keepAudioPitchNormalChangeSpeed];
        }
        
        if (editDataModel.captionDataArray.count) {
            [self resetClipCaption:videoClip captionDataArray:editDataModel.captionDataArray];
        }
        
        if (editDataModel.stickerDataArray.count) {
            [self resetClipSticker:videoClip stickerDataArray:editDataModel.stickerDataArray];
        }
        
        [videoClip setVolumeGain:editDataModel.volume rightVolumeGain:editDataModel.volume];
        
        if (editDataModel.audioNoiseSuppressionLevel > 0) {
            NvsAudioFx *audioNoiseSuppressionFx = [videoClip appendAudioFx:@"Audio Noise Suppression"];
            [audioNoiseSuppressionFx setIntVal:@"Level" val:editDataModel.audioNoiseSuppressionLevel];
        }
        if (editDataModel.keyFramesArray && editDataModel.keyFramesArray.count) {
            NvsAudioFx * audioVolumeFx = [videoClip getAudioVolumeFx];
            for (NvVolumeKeyFrameInfo *tempModel in editDataModel.keyFramesArray) {
                
                [audioVolumeFx setFloatValAtTime:@"Left Gain" val:tempModel.leftGainValue time:tempModel.pos];
                [audioVolumeFx setFloatValAtTime:@"Right Gain" val:tempModel.rightGainValue time:tempModel.pos];
                
                if (tempModel.leftGainPair) {
                    [audioVolumeFx setKeyFrameControlPoint:@"Left Gain" time:tempModel.pos controlPointPair:tempModel.leftGainPair];
                }
                if (tempModel.rightGainPair) {
                    [audioVolumeFx setKeyFrameControlPoint:@"Right Gain" time:tempModel.pos controlPointPair:tempModel.rightGainPair];
                }
            }
        }
        
        if (editDataModel.brightness == 0 && editDataModel.saturation == 0 && editDataModel.contrast == 0 && editDataModel.highlight == 0 && editDataModel.shadow == 0 && editDataModel.blackpoint == 0 ){
            
        } else {
            NvsVideoFx *colorVideoFx = [videoClip appendBuiltinFx:@"BasicImageAdjust"];
            [colorVideoFx setFloatVal:@"Brightness" val:editDataModel.brightness];
            [colorVideoFx setFloatVal:@"Saturation" val:editDataModel.saturation];
            [colorVideoFx setFloatVal:@"Contrast" val:editDataModel.contrast];
            [colorVideoFx setFloatVal:@"Highlight" val:editDataModel.highlight];
            [colorVideoFx setFloatVal:@"Shadow" val:editDataModel.shadow];
            [colorVideoFx setFloatVal:@"Blackpoint" val:-editDataModel.blackpoint];
            [colorVideoFx setAbsoluteTimeUsed:true];
        }
        if (editDataModel.Sharpen == 0) {
            
        } else {
            NvsVideoFx *sharpenVideoFx = [videoClip appendBuiltinFx:@"Sharpen"];
            [sharpenVideoFx setFloatVal:@"Amount" val:editDataModel.Sharpen];
            [sharpenVideoFx setAbsoluteTimeUsed:true];
        }
        if (editDataModel.intensity == 0 && editDataModel.density == 0) {
            
        } else {
            NvsVideoFx *denoiseVideoFx = [videoClip appendBuiltinFx:@"Noise"];
            [denoiseVideoFx setFloatVal:@"Intensity" val:editDataModel.intensity];
            [denoiseVideoFx setFloatVal:@"Density" val:editDataModel.density];
            [denoiseVideoFx setBooleanVal:@"Grayscale" val:editDataModel.grayscale];
            [denoiseVideoFx setAbsoluteTimeUsed:true];
        }
        if (editDataModel.Vignette == 0) {
            
        } else {
            NvsVideoFx *vignetteVideoFx = [videoClip appendBuiltinFx:@"Vignette"];
            [vignetteVideoFx setFloatVal:@"Degree" val:editDataModel.Vignette];
            [vignetteVideoFx setAbsoluteTimeUsed:true];
        }
        if (editDataModel.temperature == 0 && editDataModel.tint == 0 ) {
            
        } else {
            NvsVideoFx *tintVideoFx = [videoClip appendBuiltinFx:@"Tint"];
            [tintVideoFx setFloatVal:@"Temperature" val:editDataModel.temperature];
            [tintVideoFx setFloatVal:@"Tint" val:editDataModel.tint];
            [tintVideoFx setAbsoluteTimeUsed:true];
        }

        
        if (editDataModel.isImage && editDataModel.isDefault) {
            [videoClip setImageMotionAnimationEnabled:editDataModel.hasMotion];
            [videoClip setImageMotionMode:editDataModel.motionMode];
            if (editDataModel.isArea) {
                NvsRect startRect = editDataModel.startRect;
                NvsRect endRect = editDataModel.endRect;
                [videoClip setImageMotionROI:&startRect endROI:&endRect];
            }
            
        }
    }
}

+ (void)resetBackgroundEffect:(NvsTimeline *)timeline model:(NvTimelineData *)timelineData {
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    for (int i = 0; i < timelineData.editDataArray.count; i++) {
        NvEditDataModel *editDataModel = timelineData.editDataArray[i];
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        [NvTimelineUtils resetPropertyBackgroundEffect:clip model:editDataModel.backgroundEffectModel];
    }
}

+ (void)resetBackgroundEffect:(NvsTimeline *)timeline clip:(NvsVideoClip *)clip model:(NvPropertyBackgroundEffectModel *)model editModel:(NvEditDataModel *)editModel {
    [NvTimelineUtils resetPropertyBackgroundEffect:clip model:model];
}

+ (NvsVideoRotation)getRotation:(NvsAVFileInfo *) fileInfo {
    if (fileInfo == nil) {
        return NvsVideoRotation_0;
    }
    NvsVideoRotation rotation = [fileInfo getVideoStreamRotation:0];
    if (rotation == NvsVideoRotation_90) {
        rotation = NvsVideoRotation_270;
    } else if (rotation == NvsVideoRotation_180) {
        rotation = NvsVideoRotation_180;
    } else if (rotation == NvsVideoRotation_270) {
        rotation = NvsVideoRotation_90;
    }
    return rotation;
}

+ (NvsAudioFx *)getAudioFx:(NvsVideoClip *)clip name:(NSString *)name {
    for (int i = 0; i < clip.audioFxCount; i++) {
        NvsAudioFx *videoFx = [clip getAudioFxWithIndex:i];
        if ([videoFx.bultinAudioFxName isEqualToString:name])
            return videoFx;
    }
    return nil;
}

+ (CGSize)getAVFileSize:(NSString *)assetPath {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    NvsAVFileInfo *fileInfo = [context getAVFileInfo:assetPath];
    NvsSize size = [fileInfo getVideoStreamDimension:0];
    NvsVideoRotation rotation = [fileInfo getVideoStreamRotation:0];
    CGFloat width = size.width;
    CGFloat height = size.height;
    if (rotation == NvsVideoRotation_90 || rotation == NvsVideoRotation_270) {
        width = size.height;
        height = size.width;
    }
    return CGSizeMake(width, height);
}

+ (void)resetMusicTrack:(NvsTimeline *)timeline musicDataArray:(NSArray<NvMusicInfoModel *> *)musicDataArray {
    [NvTimelineUtils resetMusicTrack:timeline musicDataArray:musicDataArray timelineData:[NvTimelineData sharedInstance]];
}

+ (void)resetMusicTrack:(NvsTimeline *)timeline musicDataArray:(NSArray<NvMusicInfoModel *> *)musicDataArray timelineData:(NvTimelineData *)timelineData {
    NvsAudioTrack *musicTrack = [timeline getAudioTrackByIndex:NV_MUSIC_SOUND_TRACK];
    [musicTrack removeAllClips];
    
    if ([musicDataArray count] > 0) {
        // 单段音乐，当裁剪长度小于视频长度时，循环 Single piece of music, when cropping length is less than the video length, loop
        // 多段音乐，当每一段的裁剪长度小于时间线入出点之差时，循环 Multiple pieces of music, loop when the clipping length of each piece is less than the difference between the entry and exit points of the timeline
        if ([musicDataArray count] == 1 && [(NvMusicInfoModel *)musicDataArray[0] isBGM]) {
            NvMusicInfoModel *musicInfo = musicDataArray[0];
            NvsAudioClip *clip = [musicTrack appendClip:musicInfo.musicPath
                                                 trimIn:musicInfo.trimIn
                                                trimOut:musicInfo.trimOut];
            [clip setVolumeGain:musicInfo.volume rightVolumeGain:musicInfo.volume];
            
            while (musicTrack.duration < [timeline duration]) {
                NvsAudioClip *audioClip = [musicTrack appendClip:musicInfo.musicPath
                                                          trimIn:musicInfo.trimIn
                                                         trimOut:musicInfo.trimOut];
                [audioClip setVolumeGain:musicInfo.volume rightVolumeGain:musicInfo.volume];
            }
        } else {
            for (int i = 0; i < musicDataArray.count; i++) {
                NvMusicInfoModel *musicInfo = musicDataArray[i];
                for (int j = 0; j < (musicInfo.outPoint - musicInfo.inPoint)/(float)(musicInfo.trimOut - musicInfo.trimIn); j++) {
                    int64_t trimOut = (j == (musicInfo.outPoint - musicInfo.inPoint)/(musicInfo.trimOut - musicInfo.trimIn))
                    ? musicInfo.trimIn + musicInfo.outPoint - musicInfo.inPoint - j*(musicInfo.trimOut-musicInfo.trimIn)
                    : musicInfo.trimOut;
                    NvsAudioClip *clip = [musicTrack addClip:musicInfo.musicPath
                                                     inPoint:musicInfo.inPoint + j*(musicInfo.trimOut-musicInfo.trimIn)
                                                      trimIn:musicInfo.trimIn
                                                     trimOut:trimOut];
                    if (musicInfo.isFade) {
                        if ((musicInfo.outPoint - musicInfo.inPoint)/(float)(musicInfo.trimOut - musicInfo.trimIn) == 1) {
                            clip.fadeInDuration = 3*NV_TIME_BASE;
                            clip.fadeOutDuration = 3*NV_TIME_BASE;
                        }else{
                            if (j == 0) {
                                clip.fadeInDuration = 3*NV_TIME_BASE;
                                clip.fadeOutDuration = 0;
                            }else if ((musicInfo.outPoint - musicInfo.inPoint)/(float)(musicInfo.trimOut - musicInfo.trimIn) - j < 1){
                                clip.fadeInDuration = 0;
                                clip.fadeOutDuration = 3*NV_TIME_BASE;
                            }
                        }
                    }
                    [clip setVolumeGain:musicInfo.volume rightVolumeGain:musicInfo.volume];
                }
            }
        }
        [timeline setThemeMusicVolumeGain:0 rightVolumeGain:0];
    } else {
        if (![NvUtils isStringEmpty:[timeline getCurrentThemeId]]) {
            NvThemeInfoModel *themeInfo = [timelineData themeInfo];
            [timeline setThemeMusicVolumeGain:themeInfo.volume rightVolumeGain:themeInfo.volume];
        }
    }
    
}

+ (void)resetDubbingTrack:(NvsTimeline *)timeline dubbingModel:(NvDubbingModel *)dubbingModel {
    NvsAudioTrack *audioTrack = [timeline getAudioTrackByIndex:NV_DUBBING_SOUND_TRACK];
    if (audioTrack == nil) {
        audioTrack = [timeline appendAudioTrack];
    }
    [audioTrack removeAllClips];
    for (int i = 0; i < dubbingModel.dubbingInfoModels.count; i++) {
        NvDubbingInfoModel *dubbingDataModel = dubbingModel.dubbingInfoModels[i];
        NvsAudioClip *audioClip = [audioTrack addClip:dubbingDataModel.dubbingFilePath
                                              inPoint:dubbingDataModel.inPoint trimIn:dubbingDataModel.trimIn trimOut:dubbingDataModel.duration];
        [audioClip appendFx:dubbingDataModel.builtInFxName];
        [audioClip changeSpeed:dubbingDataModel.speed keepAudioPitch:YES];
        [audioClip setVolumeGain:dubbingDataModel.volume rightVolumeGain:dubbingDataModel.volume];
        if (dubbingDataModel.audioNoiseSuppressionLevel > 0) {
            NvsAudioFx *audioNoiseSuppressionFx = [audioClip appendFx:@"Audio Noise Suppression"];
            [audioNoiseSuppressionFx setIntVal:@"Level" val:dubbingDataModel.audioNoiseSuppressionLevel];
        }
    }
    if (dubbingModel) {
        [audioTrack setVolumeGain:dubbingModel.volume rightVolumeGain:dubbingModel.volume];
    } else {
        [audioTrack setVolumeGain:1 rightVolumeGain:1];
    }
}

+ (void)resetTransition:(NvsTimeline *)timeline transitionDataArray:(NSArray *)transitionDataArray {
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    [NvTimelineUtils removeAllVideoTransitions:videoTrack];
    
    for (int i = 0; i < transitionDataArray.count; i++) {
        NvTransitionInfoModel *info = transitionDataArray[i];
        NvsVideoTransition *transition;
        if ([NvUtils isStringEmpty:info.packageId]) {
            transition = [videoTrack setBuiltinTransition:i withName:info.builtinName];
        } else {
            transition = [videoTrack setPackagedTransition:i withPackageId:info.packageId];
        }
        if (transition) {
            [transition setVideoTransitionDuration:info.duration withMatchMode:NvsVideoTransitionDurationMatchMode_Stretch];
        }
    }
}

+ (void)resetTimelineFilter:(NvsTimeline *)timeline filterData:(NvTimeFilterInfoModel *)timelineFilterModel {
    BOOL isBuiltin = [NvSDKUtils isBuiltinFilter:timelineFilterModel.name];
    
    NvsTimelineVideoFx *newTimelineFilter;
    NvsTimelineVideoFx *nextFx = [timeline getFirstTimelineVideoFx];
    while (nextFx) {
        if ([nextFx.bultinTimelineVideoFxName isEqualToString:@"Storyboard"] || [nextFx.bultinTimelineVideoFxName isEqualToString:@"Mosaic"] || [nextFx.bultinTimelineVideoFxName isEqualToString:@"Fast Blur"]){
            nextFx = [timeline getNextTimelineVideoFx:nextFx];
        }else{
            if (timelineFilterModel.name) {
                if (isBuiltin) {
                    if ([nextFx.bultinTimelineVideoFxName isEqualToString:timelineFilterModel.name]) {
                        newTimelineFilter = nextFx;
                        nextFx = [timeline getNextTimelineVideoFx:nextFx];
                        continue;
                    }
                } else {
                    if ([nextFx.timelineVideoFxPackageId isEqualToString:timelineFilterModel.name]) {
                        newTimelineFilter = nextFx;
                        nextFx = [timeline getNextTimelineVideoFx:nextFx];
                        continue;
                    }
                }
            } 
            nextFx = [timeline removeTimelineVideoFx:nextFx];
        }
    }
    if (timelineFilterModel.name) {
        if (!newTimelineFilter) {
            NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
            NvsVideoClip *firstClip = [videoTrack getClipWithIndex:0];
            NvsVideoClip *lastClip = [videoTrack getClipWithIndex:videoTrack.clipCount -1 ];
            
            //判断是不是主题片头、片尾数据 Determine whether it is the subject title data, the end of the title data
            int64_t timelineFilterStartPoint = 0;
            int64_t timelineFilterEndPoint = timeline.duration;
            if (firstClip.roleInTheme == NvsRoleInThemeTitle) {
                timelineFilterStartPoint = firstClip.outPoint;
            }
            if (lastClip.roleInTheme == NvsRoleInThemeTrailer) {
                timelineFilterEndPoint = lastClip.inPoint;
            }
            
            if ([NvSDKUtils isBuiltinFilter:timelineFilterModel.name]) {
                newTimelineFilter = [timeline addBuiltinTimelineVideoFx:timelineFilterStartPoint duration:timelineFilterEndPoint - timelineFilterStartPoint videoFxName:timelineFilterModel.name];
                
                if ([timelineFilterModel.name isEqualToString:@"Cartoon"]) {
                    [newTimelineFilter setBooleanVal:@"Stroke Only" val:timelineFilterModel.strokeOnly];
                    [newTimelineFilter setBooleanVal:@"Grayscale" val:timelineFilterModel.grayscale];
                }
            } else if(timelineFilterModel && timelineFilterModel.name.length > 0){
                newTimelineFilter = [timeline addPackagedTimelineVideoFx:timelineFilterStartPoint duration:timelineFilterEndPoint videoFxPackageId:timelineFilterModel.name];
            }
        }
        if (!newTimelineFilter) {
            return;
        }
        if ([NvSDKUtils isBuiltinFilter:timelineFilterModel.name]) {
            if ([timelineFilterModel.name isEqualToString:@"Cartoon"]) {
                [newTimelineFilter setBooleanVal:@"Stroke Only" val:timelineFilterModel.strokeOnly];
                [newTimelineFilter setBooleanVal:@"Grayscale" val:timelineFilterModel.grayscale];
            }
        }
        [newTimelineFilter setFilterIntensity:timelineFilterModel.strength];
        if (timelineFilterModel.expModels.count>0) {
            for (NvAjustFxParamModel * model in timelineFilterModel.expModels) {
                if (model.type == NvAjustFxParamCategoryColor) {
                    NvsColor color;
                    color.r = model.r;
                    color.g = model.g;
                    color.b = model.b;
                    color.a = model.a;
                    [newTimelineFilter setColorExprVar:model.name varValue:&color];
                }
                else if (model.type == NvAjustFxParamCategoryInt || model.type == NvAjustFxParamCategoryFloat) {
                    [newTimelineFilter setExprVar:model.name varValue:model.currentValue];
                }
            }
        }
    }
}

+ (void)resetTimelineMakeUp:(NvsTimeline *)timeline MakeUpData:(NvMakeupEffectModel *)timelineMakeUpModel {
    if (!timelineMakeUpModel || !timeline) {
        return;
    }
    NSMutableArray *kindArr = [@[@"Lip",
                                 @"Eyeshadow",
                                 @"Eyebrow",
                                 @"Eyelash",
                                 @"Eyeliner",
                                 @"Blusher", 
                                 @"Brighten",
                                 @"Shadow",
                                 @"Eyeball"] mutableCopy];
    NSMutableArray *containKindArr = [NSMutableArray array];
    
    NvsVideoTrack *track = [timeline getVideoTrackByIndex:0];
    for (int i = 0 ; i < track.clipCount; i++) {
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvsVideoFx *fx = [NvSDKUtils getClipVideoFx:@"AR Scene" withClip:clip];
        if (!fx) {
            fx = [NvSDKUtils createClipVideoFx:@"AR Scene" withClip:clip];
            [fx setBooleanVal:@"Max Faces Respect Min" val:YES];
            BOOL highVersion = [NvInitArScence isHighVersionPhone];
            if(highVersion) {
                [fx setBooleanVal:@"AI Face Occlusion Enabled" val:YES];
            }
//            if (ARSCENE_ST_240 || ARSCENE_MS_240) {
//                // !!!: 设置后就会走检测， 不需要设置 3.12.0+
//                [fx setBooleanVal:@"Use Face Extra Info" val:YES];
//            }
        }
        [fx setBooleanVal:@"Beauty Effect" val:timelineMakeUpModel.beauty.count > 0 ? YES : NO];
        if (timelineMakeUpModel.shape.count || timelineMakeUpModel.microShape.count > 0) {
            [fx setBooleanVal:@"Beauty Shape" val:YES];
            [fx setBooleanVal:@"Face Mesh Internal Enabled" val:YES];
        }else{
            [fx setBooleanVal:@"Beauty Shape" val:NO];
            [fx setBooleanVal:@"Face Mesh Internal Enabled" val:NO];
        }
        [fx setIntVal:@"Makeup Custom Enabled Flag" val:NvsMakeupEffectCustomEnabledFlag_None];
        if (ARSCENE_MS || ARSCENE_MS_240) {
            [[fx getARSceneManipulate] setDetectionMode:NvsARSceneDetectionMode_SemiImage];
        }
        BOOL compound = NO;
        
        //处理效果 Treatment effect
        if(timelineMakeUpModel.makeup.count > 0){
            for (NvMakeupEffectContentModel *model in timelineMakeUpModel.makeup) {
                NSLog(@"package:%@ value:%@ intensity %f",model.className,model.uuid,model.intensity);
                if ([model.className isEqualToString:@"Makeup Compound Package Id"]) {
                    compound = YES;
                }else{
                    //整妆优先级高于单妆和妆容，所以如果当前不是整妆应该将整妆设为空 Makeup takes precedence over makeup and makeup, so leave makeup blank if it's not currently makeup
                    //否则不生效 Otherwise, it will not take effect.
                    [fx setStringVal:@"Makeup Compound Package Id" val:@""];
                }
                if (model.makeupId) {
                    NSString *baseStr = [@"Makeup " stringByAppendingString:model.makeupId];
                    NSString *packageId = [baseStr stringByAppendingString:@" Package Id"];
                    if ([packageId caseInsensitiveCompare:model.className] == NSOrderedSame && ![model.className isEqualToString:@"Makeup Compound Package Id"]) {
                        [fx setStringVal:model.className val:model.uuid];
                        NSString *colorStr = [baseStr stringByAppendingString:@" Color"];
                        NSString *intensityStr = [baseStr stringByAppendingString:@" Intensity"];
                        [fx setFloatVal:intensityStr val:model.intensity];
                        if (model.color.length > 0) {
                            NvsColor color = [self nvsColorWithValue:model.color];
                            [fx setColorVal:colorStr val:&color];
                        }
                        
                        [containKindArr addObject:model.makeupId];
                        
                    }
                }else{
                    [fx setStringVal:model.className val:model.uuid];
                }
                
            }
        }else if([timelineMakeUpModel.makeupId isEqualToString:@"Compound"]){
            [fx setStringVal:@"Makeup Compound Package Id" val:@""];
        }
        
        [kindArr removeObjectsInArray:containKindArr];
        for (NSString *item in kindArr) {
            NSString *baseStr = [@"Makeup " stringByAppendingString:item];
            NSString *packageId = [baseStr stringByAppendingString:@" Package Id"];
            [fx setStringVal:packageId val:@""];
            NSString *intensityStr = [baseStr stringByAppendingString:@" Intensity"];
            [fx setFloatVal:intensityStr val:0];
        }
        if (!compound) {
            for (NSString *item in kindArr) {
                NvsColor color;
                color.r = 0;
                color.g = 0;
                color.b = 0;
                color.a = 0;
                NSString *baseStr = [@"Makeup " stringByAppendingString:item];
                NSString *colorStr = [baseStr stringByAppendingString:@" Color"];
                [fx setColorVal:colorStr val:&color];
            }
        }
        
        [fx setFloatVal:@"Makeup Intensity" val:1];
        
        
        //妆容中的美颜 Beauty in makeup
        if (timelineMakeUpModel.beauty.count > 0) {
            for (NvMakeupEffectBeautyContentModel *model in timelineMakeUpModel.beauty) {
                if ([model.fxName isEqualToString:@"Default Sharpen Enabled"]){
                    [fx setBooleanVal:model.fxName val:model.value];
                }else if ([model.fxName isEqualToString:@"ColorCorrect"]){
                    [NvTimelineUtils applyColorCorrectFilterWithModel:model timeline:timeline];
                }else if ([model.fxName containsString:@"Beauty Whitening"]) {
                    if (model.whiteningLutEnabled){
                        NSString *path = [[NSBundle mainBundle] pathForResource:@"whitenLut" ofType:@"bundle"];
                        NSString *imagePath = [path stringByAppendingPathComponent:@"filter.png"];
                        [fx setStringVal:@"Whitening Lut File" val:imagePath];
                        [fx setBooleanVal:@"Whitening Lut Enabled" val:YES];
                        [fx setFloatVal:@"Beauty Whitening" val:model.value];
                    }else {
                        [fx setStringVal:@"Whitening Lut File" val:@""];
                        [fx setBooleanVal:@"Whitening Lut Enabled" val:NO];
                        [fx setFloatVal:@"Beauty Whitening" val:model.value];
                    }
                }
                else if ([model.fxName isEqualToString:@"Beauty Strength"]) {
                    //普通磨皮 Ordinary dermabrasion
                    [fx setFloatVal:@"Advanced Beauty Intensity" val:0];
                    [fx setFloatVal:model.fxName val:model.value];
                }
                else if (model.advancedBeautyEnable) {
                    if (model.advancedBeautyType == 0) {
                        //高级磨皮0 Advanced Dermabrasion 0
                        [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
                        [fx setIntVal:@"Advanced Beauty Type" val:0];
                        [fx setFloatVal:@"Beauty Strength" val:0];
                        [fx setFloatVal:@"Advanced Beauty Intensity" val:model.value];
                        
                    }else if (model.advancedBeautyType == 1){
                        //高级磨皮1 Advanced Dermabrasion 1
                        [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
                        [fx setIntVal:@"Advanced Beauty Type" val:1];
                        [fx setFloatVal:@"Beauty Strength" val:0];
                        [fx setFloatVal:@"Advanced Beauty Intensity" val:model.value];
                    }else if (model.advancedBeautyType == 2){
                        //高级磨皮2 Advanced Dermabrasion 2
                        [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
                        [fx setIntVal:@"Advanced Beauty Type" val:2];
                        [fx setFloatVal:@"Beauty Strength" val:0];
                        [fx setFloatVal:@"Advanced Beauty Intensity" val:model.value];
                    }else if (model.advancedBeautyType == 3){
                        //高级磨皮3 Advanced Dermabrasion 3
                        [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
                        [fx setIntVal:@"Advanced Beauty Type" val:3];
                        [fx setFloatVal:@"Beauty Strength" val:0];
                        [fx setFloatVal:@"Advanced Beauty Intensity" val:model.value];
                    }
                }
                else{
                    if (model.fxName.length > 0) {
                        [fx setFloatVal:model.fxName val:model.value];
                    }
                    
                }
            }
        }
        //妆容中的美型 Beauty in makeup
        if (timelineMakeUpModel.shape.count > 0) {
            for (NvMakeupEffectBeautyContentModel *model in timelineMakeUpModel.shape) {
                NSString *degreeName = model.degreeName;
                if ([model.fxName isEqualToString:@"Warp Forehead Height Custom Package Id"]) {
                    [fx setIntVal:@"Forehead Height Warp Strategy" val:0x7FFFFFFF];
                }
                else if ([model.fxName isEqualToString:@"Warp Head Size Custom Package Id"]) {
                    [fx setIntVal:@"Head Size Warp Strategy" val:0x7FFFFFFF];
                }
                [fx setStringVal:model.fxName val:model.uuid];
                [fx setFloatVal:degreeName val:model.value];
            }
        }
        //妆容中的微整形 Micro-cosmetic changes in makeup
        if (timelineMakeUpModel.microShape.count > 0) {
            for (NvMakeupEffectBeautyContentModel *model in timelineMakeUpModel.microShape) {
                NSString *degreeName = model.degreeName;
                if(degreeName.length > 0) {
                    /*
                     warp or facemesh
                     */
                    if ([model.fxName isEqualToString:@"Warp Forehead Height Custom Package Id"]) {
                        [fx setIntVal:@"Forehead Height Warp Strategy" val:0x7FFFFFFF];
                    }
                    else if ([model.fxName isEqualToString:@"Warp Head Size Custom Package Id"]) {
                        [fx setIntVal:@"Head Size Warp Strategy" val:0x7FFFFFFF];
                    }
                    [fx setStringVal:model.fxName val:model.uuid];
                    [fx setFloatVal:degreeName val:model.value];
                }else{
                    /*
                     advaced beauty
                     */
                    [fx setFloatVal:model.fxName val:model.value];
                }
            }
        }
    }
    
    
    //妆容中的滤镜 Filters in makeup
    if (timelineMakeUpModel.filter.count >0) {
        for (int k = 0 ; k < track.clipCount; k++) {
            NvsVideoClip *clip = [track getClipWithIndex:k];
            for (int i=0; i<clip.fxCount; i++) {
                NvsVideoFx *fx = [clip getFxWithIndex:i];
                if ([fx.bultinVideoFxName isEqualToString:@"AR Scene"]) {
                    continue;
                }else {
                    [clip removeFx:i];
                    i--;
                    
                }
            }
            for (int i=0; i<timelineMakeUpModel.filter.count; i++) {
                NvMakeupEffectFilterContentModel *filterModel = timelineMakeUpModel.filter[i];
                if (filterModel.isBuiltIn) {
                    NvsVideoFx *fx = [clip appendBuiltinFx:filterModel.uuid];
                    [fx setFilterIntensity:filterModel.value];
                    
                } else if (filterModel.uuid) {
                    NvsVideoFx *fx = [clip appendPackagedFx:filterModel.uuid];
                    [fx setFilterIntensity:filterModel.value];
                }
            }
        }
        
    }
    
}

+ (void)resetTimeline:(NvsTimeline *)timeline makeupData:(NvMakeupToolModel *)model {
    if (!model || !timeline) {
        return;
    }
    NvMakeupToolEffectContentModel *effectContent = model.effectContent;
    NvsVideoTrack *track = [timeline getVideoTrackByIndex:0];
    for (int i = 0 ; i < track.clipCount; i++) {
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvsVideoFx *fx = [NvSDKUtils getClipVideoFx:@"AR Scene" withClip:clip];
        if (!fx) {
            fx = [NvSDKUtils createClipVideoFx:@"AR Scene" withClip:clip];
        }
        if (ARSCENE_MS || ARSCENE_MS_240) {
            [[fx getARSceneManipulate] setDetectionMode:NvsARSceneDetectionMode_SemiImage];
        }
        BOOL highVersion = [NvInitArScence isHighVersionPhone];
        if(highVersion) {
            [fx setBooleanVal:@"AI Face Occlusion Enabled" val:YES];
        }
        [fx setBooleanVal:@"Max Faces Respect Min" val:YES];
//        if(ARSCENE_MS_240){
//            // !!!: 设置后就会走检测， 不需要设置 3.12.0+
//            [fx setBooleanVal:@"Use Face Extra Info" val:YES];
//        }
        
        
        //------------         美妆 makeup         ------------//
        if (effectContent.makeup.count > 0) {
            for (NvMakeupToolEffectModel *effect in effectContent.makeup) {
                for(NvMakeupToolElementModel *item in effect.params) {
                    [NvTimelineUtils applyMakeupToolElements:fx item:item packagePath:model.packagePath reset:YES];
                }
            }
        }
        
        //------------         美颜 beauty         ------------//
        NSMutableArray *containKindArr = [NSMutableArray array];
        if (effectContent.beauty.count > 0) {
            
            for (NvMakeupToolEffectModel *effect in effectContent.beauty) {
                
                if (effect.params.count>0) {
                    for(NvMakeupToolElementModel *item in effect.params) {
                        NSString *appliedItem = [NvTimelineUtils applyMakeupToolElements:fx item:item packagePath:model.packagePath reset:NO];
                        if (appliedItem) {
                            [containKindArr addObject:appliedItem];
                        }
                    }
                }else if ([effect.type caseInsensitiveCompare:@"ColorCorrect"] == NSOrderedSame) {
                    if (effect.isBuiltIn) {
                        NvsVideoFx *fx = [clip appendBuiltinFx:effect.uuid];
                        [fx setFilterIntensity:effect.value];
                        
                    } else if (effect.uuid) {
                        NvsVideoFx *fx = [clip appendPackagedFx:effect.uuid];
                        [fx setFilterIntensity:effect.value];
                    }
                    [containKindArr addObject:effect.type];
                }
            }
        }
        //未使用美颜数据 Beauty data not used
        NSMutableArray *unInitailizedBeauties = [NvTimelineUtils getAllUNIntializedBeauties];
        
        //将未应用的美颜特效程度值设为0 Set the unapplied beauty effect level value to 0
        for(NvMakeupToolElementModel *model1 in unInitailizedBeauties) {
            BOOL hasApplied = NO;
            for(NSString *item in containKindArr) {
                if ([item caseInsensitiveCompare:model1.key] == NSOrderedSame) {
                    hasApplied = YES;
                    break;
                }
            }
            if (hasApplied) {
                continue;
            }
            if ([model1.key caseInsensitiveCompare:@"ColorCorrect"] != NSOrderedSame) {
                [NvTimelineUtils applyMakeupToolElements:fx item:model1 packagePath:model.packagePath reset:YES];
            }
            
        }
        
        //------------         美型  Beauty type        ------------//
        NSMutableArray *containedShapeArr = [NSMutableArray array];
        if (effectContent.shape.count > 0) {
            for (NvMakeupToolEffectModel *effect in effectContent.shape) {
                for(NvMakeupToolElementModel *item in effect.params) {
                    NSString *appliedItem = [NvTimelineUtils applyMakeupToolElements:fx item:item packagePath:model.packagePath reset:NO];
                    if (appliedItem) {
                        [containedShapeArr addObject:appliedItem];
                    }
                }
            }
        }
        //将未应用的美型特效程度值设为0 Set the unapplied beauty effect level value to 0
        NSMutableArray *unInitailizedShapes = [NvTimelineUtils getAllUNIntializedShapes];
        for(NvMakeupToolElementModel *model1 in unInitailizedShapes) {
            BOOL hasApplied = NO;
            for(NSString *item in containedShapeArr) {
                if ([item caseInsensitiveCompare:model1.key] == NSOrderedSame) {
                    hasApplied = YES;
                    break;
                }
            }
            if (hasApplied) {
                continue;
            }
            
            [NvTimelineUtils applyMakeupToolElements:fx item:model1 packagePath:model.packagePath reset:YES];
            
        }
        
        //------------         微整形 microshaping         ------------//
        NSMutableArray *containedMicroShapeArr = [NSMutableArray array];
        if (effectContent.microShape.count > 0) {
            for (NvMakeupToolEffectModel *effect in effectContent.microShape) {
                for(NvMakeupToolElementModel *item in effect.params) {
                    NSString *appliedItem = [NvTimelineUtils applyMakeupToolElements:fx item:item packagePath:model.packagePath reset:NO];
                    if (appliedItem) {
                        [containedMicroShapeArr addObject:appliedItem];
                    }
                }
            }
        }
        //将未应用的微整形特效程度值设为0 Set the unapplied microshaping effect degree value to 0
        NSMutableArray *unInitailizedMicroShapes = [NvTimelineUtils getAllUNIntializedMicroShapes];
        for(NvMakeupToolElementModel *model1 in unInitailizedMicroShapes) {
            BOOL hasApplied = NO;
            for(NSString *item in containedMicroShapeArr) {
                if ([item caseInsensitiveCompare:model1.key] == NSOrderedSame) {
                    hasApplied = YES;
                    break;
                }
            }
            if (hasApplied) {
                continue;
            }
            
            [NvTimelineUtils applyMakeupToolElements:fx item:model1 packagePath:model.packagePath reset:YES];
            
        }
        
        //------------         滤镜 filter         ------------//
        if (effectContent.filter.count > 0) {
            for (NvMakeupToolEffectModel *effect in effectContent.filter) {
                if (effect.isBuiltIn) {
                    NvsVideoFx *fx = [clip appendBuiltinFx:effect.uuid];
                    [fx setFilterIntensity:effect.value];
                    
                } else if (effect.uuid) {
                    NvsVideoFx *fx = [clip appendPackagedFx:effect.uuid];
                    [fx setFilterIntensity:effect.value];
                }
            }
        }
    }
}

+ (NSMutableArray *)getAllUNIntializedBeauties {
    NSMutableArray *unInitailizedBeauties = [NSMutableArray array];
    //普通磨皮 Ordinary dermabrasion
    NvMakeupToolElementFloatModel *effect = [NvMakeupToolElementFloatModel new];
    effect.key = @"Beauty Strength";
    effect.value = 0.f;
    effect.type = @"float";
    [unInitailizedBeauties addObject:effect];
    
    //高级磨皮 Advanced dermabrasion
    NvMakeupToolElementFloatModel *effect1 = [NvMakeupToolElementFloatModel new];
    effect1.key = @"Advanced Beauty Intensity";
    effect1.value = 0.f;
    effect1.type = @"float";
    [unInitailizedBeauties addObject:effect1];
    
    //美白 whitening
    NvMakeupToolElementFloatModel *effect2 = [NvMakeupToolElementFloatModel new];
    effect2.key = @"Beauty Whitening";
    effect2.value = 0.f;
    effect2.type = @"float";
    [unInitailizedBeauties addObject:effect2];
    
    //去油光 degreasing
    NvMakeupToolElementFloatModel *effect3 = [NvMakeupToolElementFloatModel new];
    effect3.key = @"Advanced Beauty Matte Intensity";
    effect2.value = 0.f;
    effect3.type = @"float";
    [unInitailizedBeauties addObject:effect3];
    
    //红润 ruddy
    NvMakeupToolElementFloatModel *effect4 = [NvMakeupToolElementFloatModel new];
    effect4.key = @"Beauty Reddening";
    effect4.value = 0.f;
    effect4.type = @"float";
    [unInitailizedBeauties addObject:effect4];
    
    //锐度 sharpness
    NvMakeupToolElementBOOLModel *effect5 = [NvMakeupToolElementBOOLModel new];
    effect5.key = @"Default Sharpen Enabled";
    effect5.value = NO;
    effect5.type = @"boolean";
    [unInitailizedBeauties addObject:effect5];
    return unInitailizedBeauties;
}

+ (NSMutableArray *)getAllUNIntializedShapes {
    NSArray *degreeNames = @[@"Eye Size Warp Degree",
                             @"Eye Corner Stretch Degree",
                             @"Face Size Warp Degree",
                             @"Face Width Warp Degree",
                             @"Face Length Warp Degree",
                             @"Forehead Height Warp Degree",
                             @"Hairline Height Warp Degree",
                             @"Chin Length Warp Degree",
                             @"Eyebrow Width Warp Degree",
                             @"Nose Length Warp Degree",
                             @"Nose Width Warp Degree",
                             @"Mouth Size Warp Degree",
                             @"Mouth Width Warp Degree",
                             @"Mouth Corner Lift Degree",
                             @"Face Mesh Eye Size Degree",
                             @"Face Mesh Eye Corner Stretch Degree",
                             @"Face Mesh Face Size Degree",
                             @"Face Mesh Face Width Degree",
                             @"Face Mesh Face Length Degree",
                             @"Face Mesh Forehead Height Degree",
                             @"Face Mesh Hairline Height Degree",
                             @"Face Mesh Chin Length Degree",
                             @"Face Mesh Eyebrow Width Degree",
                             @"Face Mesh Nose Length Degree",
                             @"Face Mesh Nose Width Degree",
                             @"Face Mesh Mouth Size Degree",
                             @"Face Mesh Mouth Width Degree",
                             @"Face Mesh Mouth Corner Lift Degree",
                             
    ];
    NSMutableArray *unInitailizedShapes = [NSMutableArray array];
    for(int i=0; i<degreeNames.count; i++) {
        NvMakeupToolElementFloatModel *model = [NvMakeupToolElementFloatModel new];
        model.key = degreeNames[i];
        model.value = 0.f;
        model.type = @"float";
        [unInitailizedShapes addObject:model];
    }
    return unInitailizedShapes;
}

+ (NSMutableArray *)getAllUNIntializedMicroShapes {
    NSArray *degreeNames =  @[
        @"Advanced Beauty Remove Nasolabial Folds Intensity",
        @"Advanced Beauty Remove Dark Circles Intensity",
        @"Advanced Beauty Brighten Eyes Intensity",
        @"Advanced Beauty Whiten Teeth Intensity",
        @"Malar Width Warp Degree",
        @"Jaw Width Warp Degree",
        @"Eye Distance Warp Degree",
        @"Temple Width Warp Degree",
        @"Head Size Warp Degree",
        @"Eye Angle Warp Degree",
        @"Nose Bridge Width Warp Degree",
        @"Philtrum Length Warp Degree",
        @"Face Mesh Malar Width Degree",
        @"Face Mesh Jaw Width Degree",
        @"Face Mesh Eye Distance Degree",
        @"Face Mesh Temple Width Degree",
        @"Face Mesh Head Size Degree",
        @"Face Mesh Eye Angle Degree",
        @"Face Mesh Nose Bridge Width Degree",
        @"Face Mesh Philtrum Length Degree",
        @"Face Mesh Eye Arc Degree",
        @"Face Mesh Eye Width Degree",
        @"Face Mesh Eye Height Degree",
        @"Face Mesh Eye Y Offset Degree",
        @"Face Mesh Eyebrow Angle Degree",
        @"Face Mesh Eyebrow Thickness Degree",
        @"Face Mesh Eyebrow X Offset Degree",
        @"Face Mesh Eyebrow Y Offset Degree",
        @"Face Mesh Nose Head Width Degree"
    ];
    NSMutableArray *unInitailizedMicroShapes = [NSMutableArray array];
    for(int i=0; i<degreeNames.count; i++) {
        NvMakeupToolElementFloatModel *model = [NvMakeupToolElementFloatModel new];
        model.key = degreeNames[i];
        model.value = 0.f;
        model.type = @"float";
        [unInitailizedMicroShapes addObject:model];
    }
    return unInitailizedMicroShapes;
}

+ (NSString *)applyMakeupToolElements:(NvsFx *)fx item:(NvMakeupToolElementModel *)item packagePath:(NSString *)packagePath reset:(BOOL)reset {
    NSString *appliedItem;
    if ([item.type caseInsensitiveCompare:@"string"] == NSOrderedSame) {
        NvMakeupToolElementStringModel *effect = (NvMakeupToolElementStringModel *)item;
        [fx setStringVal:effect.key val:effect.value];
        NSLog(@"应用特效 Applied special effect%@   ----   %@",effect.key,effect.value);
    }else if ([item.type caseInsensitiveCompare:@"float"] == NSOrderedSame || [item.type caseInsensitiveCompare:@"double"] == NSOrderedSame) {
        NvMakeupToolElementFloatModel *effect = (NvMakeupToolElementFloatModel *)item;
        [fx setFloatVal:effect.key val:effect.value];
        appliedItem = effect.key;
        NSLog(@"应用特效 Applied special effect%@   ----   %f",effect.key,effect.value);
    }else if ([item.type caseInsensitiveCompare:@"path"] == NSOrderedSame) {
        NvMakeupToolElementStringModel *effect = (NvMakeupToolElementStringModel *)item;
        [fx setStringVal:effect.key val:[packagePath stringByAppendingPathComponent:effect.value]];
        NSLog(@"应用特效 Applied special effect%@   ----   %@",effect.key,[packagePath stringByAppendingPathComponent:effect.value]);
    }else if ([item.type caseInsensitiveCompare:@"boolean"] == NSOrderedSame) {
        NvMakeupToolElementBOOLModel *effect = (NvMakeupToolElementBOOLModel *)item;
        [fx setBooleanVal:effect.key val:effect.value];
        appliedItem = effect.key;
        NSLog(@"应用特效 Applied special effect%@   ----   %@",effect.key,effect.value ? @"YES" : @"NO");
    }else if ([item.type caseInsensitiveCompare:@"int"] == NSOrderedSame) {
        NvMakeupToolElementIntModel *effect = (NvMakeupToolElementIntModel *)item;
        [fx setIntVal:effect.key val:effect.value];
        NSLog(@"应用特效 Applied special effect%@   ----   %d",effect.key,effect.value);
    }else if ([item.type caseInsensitiveCompare:@"color"] == NSOrderedSame) {
        NvMakeupToolElementColorModel *effect = (NvMakeupToolElementColorModel *)item;
        NvsColor color = {effect.r,effect.g,effect.b,effect.a};
        [fx setColorVal:effect.key val:&color];
    }
    if (reset) {
        return nil;
    }
    return appliedItem;
}

+ (void)resetTimeline:(NvsTimeline *)timeline beautyEffect:(NSMutableArray <NvBeautyTypeModel *>*)beautyArr shapeEffect:(NSMutableArray <NvBeautyTypeModel *>*)shapeArr microShapeEffect:(NSMutableArray <NvBeautyTypeModel *>*)microShapeArr {
    if (beautyArr.count == 0 && shapeArr.count == 0 && microShapeArr.count == 0) {
        return;
    }
    NvsVideoTrack *track = [timeline getVideoTrackByIndex:0];
    
    BOOL beautyOpen = beautyArr.firstObject.isOperation;
    BOOL shapeOpen = shapeArr.firstObject.isOperation;
    BOOL microShapeOpen = microShapeArr.firstObject.isOperation;
    
    for (int i=0; i<track.clipCount; i++) {
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvsVideoFx *fx = [NvSDKUtils getClipVideoFx:@"AR Scene" withClip:clip];
        if (!fx) {
            fx = [NvSDKUtils createClipVideoFx:@"AR Scene" withClip:clip];
        }
        if (ARSCENE_MS || ARSCENE_MS_240) {
            [[fx getARSceneManipulate] setDetectionMode:NvsARSceneDetectionMode_SemiImage];
        }
        BOOL highVersion = [NvInitArScence isHighVersionPhone];
        if(highVersion) {
            [fx setBooleanVal:@"AI Face Occlusion Enabled" val:YES];
        }
        
        [fx setBooleanVal:@"Max Faces Respect Min" val:YES];
//        if(ARSCENE_MS_240) {
//            // !!!: 设置后就会走检测， 不需要设置 3.12.0+
//            [fx setBooleanVal:@"Use Face Extra Info" val:YES];
//        }
        if (beautyArr.count > 0 || shapeArr.count > 0) {
            if (beautyArr.count > 0 && beautyOpen) {
                [fx setBooleanVal:@"Beauty Effect" val:YES];
                [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
            }
            if (shapeArr.count > 0 && shapeOpen) {
                [fx setBooleanVal:@"Beauty Shape" val:YES];
                [fx setBooleanVal:@"Face Mesh Internal Enabled" val:YES];
            }
        }
        if (microShapeArr.count && microShapeOpen) {
            NvBeautyTypeModel *firstModel = microShapeArr.firstObject;
            if (firstModel.isOperation && firstModel.value != 0) {
                [fx setBooleanVal:@"Beauty Shape" val:YES];
            }
            for (int j = 1; j < microShapeArr.count; j++) {
                NvBeautyTypeModel *model = microShapeArr[j];
                if (model.isOperation && model.value != 0) {
                    [fx setBooleanVal:@"Face Mesh Internal Enabled" val:YES];
                    break;
                }
            }
        }
    }
    if (beautyArr.count > 0 && beautyOpen) {
        [NvTimelineUtils applyEffect:timeline category:0 modelArr:beautyArr];
    }
    if (shapeArr.count > 0 && shapeOpen) {
        [NvTimelineUtils applyEffect:timeline category:1 modelArr:shapeArr];
    }
    if (microShapeArr.count > 0 && microShapeOpen) {
        [NvTimelineUtils applyEffect:timeline category:2 modelArr:microShapeArr];
    }
}

+ (void)applyEffect:(NvsTimeline *)timeline category:(int)category modelArr:(NSMutableArray <NvBeautyTypeModel *>*)modelArr {
    for(NvBeautyTypeModel *model in modelArr) {
        if (category == 0 && [model.fxName isEqualToString:@"ColorCorrect"]) {
            [NvTimelineUtils resetTimeline:timeline applyColorCorrectFilter:model];
        }else{
            [NvTimelineUtils applyEffect:timeline category:category model:model];
        }
    }
}

+ (void)applyEffect:(NvsTimeline *)timeline category:(int)category model:(NvBeautyTypeModel *)model {
    NvsVideoTrack *track = [timeline getVideoTrackByIndex:0];
    for (int i=0; i<track.clipCount; i++) {
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvsVideoFx *fx = [NvSDKUtils getClipVideoFx:@"AR Scene" withClip:clip];
        if (!fx) {
            fx = [NvSDKUtils createClipVideoFx:@"AR Scene" withClip:clip];
            if (ARSCENE_MS || ARSCENE_MS_240) {
                [[fx getARSceneManipulate] setDetectionMode:NvsARSceneDetectionMode_SemiImage];
            }
            BOOL highVersion = [NvInitArScence isHighVersionPhone];
            if(highVersion) {
                [fx setBooleanVal:@"AI Face Occlusion Enabled" val:YES];
            }
            [fx setBooleanVal:@"Max Faces Respect Min" val:YES];
//            if(ARSCENE_MS_240){
//                // !!!: 设置后就会走检测， 不需要设置 3.12.0+
//                [fx setBooleanVal:@"Use Face Extra Info" val:YES];
//            }
        }
        
        [NvTimelineUtils applyFx:fx category:category model:model];
    }
}

+ (void)applyFx:(NvsFx *)fx category:(int)category model:(NvBeautyTypeModel *)model {
    if (!fx || !(model.fxName.length > 0 || model.degreeName.length > 0) || [model.fxName caseInsensitiveCompare:@"none"] == NSOrderedSame) {
        return;
    }
    NvsVideoFx *vf = (NvsVideoFx *)fx;
    NSLog(@"滤镜 filter%@   %@",vf.bultinVideoFxName,vf.videoFxPackageId);
    
    if (category == 0) {
        NSLog(@"========%@ value: %f   extValue: %f",model.fxName,model.value,model.extValue);
        if ([model.fxName isEqualToString:@"Default Sharpen Enabled"]) {
            BOOL value = model.switchSelected;
            [fx setBooleanVal:model.fxName val:value];
        }else if ([model.fxName isEqualToString:@"Advanced Beauty Type Zero"]) {
            [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
            [fx setIntVal:@"Advanced Beauty Type" val:0];
            [fx setFloatVal:@"Beauty Strength" val:0];
            [fx setFloatVal:@"Advanced Beauty Intensity" val:model.value];
            
        }else if ([model.fxName isEqualToString:@"Advanced Beauty Type One"]) {
            [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
            [fx setIntVal:@"Advanced Beauty Type" val:1];
            [fx setFloatVal:@"Beauty Strength" val:0];
            [fx setFloatVal:@"Advanced Beauty Intensity" val:model.value];
            
        }else if ([model.fxName isEqualToString:@"Advanced Beauty Type Two"]) {
            [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
            [fx setIntVal:@"Advanced Beauty Type" val:2];
            [fx setFloatVal:@"Beauty Strength" val:0];
            [fx setFloatVal:@"Advanced Beauty Intensity" val:model.value];
            
        }else if ([model.fxName isEqualToString:@"Advanced Beauty Type Three"]) {
            [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
            [fx setIntVal:@"Advanced Beauty Type" val:3];
            [fx setFloatVal:@"Beauty Strength" val:0];
            [fx setFloatVal:@"Advanced Beauty Intensity" val:model.value];
            
        }else if ([model.fxName isEqualToString:@"Beauty Strength"]){
            [fx setFloatVal:@"Advanced Beauty Intensity" val:0];
            [fx setFloatVal:model.fxName val:model.value];
        }else if ([model.fxName isEqualToString:@"Shiny"]){
            [fx setFloatVal:@"Advanced Beauty Matte Intensity" val:model.value];
            [fx setFloatVal:@"Advanced Beauty Matte Fill Radius" val:3+model.extValue*27];
        }else if ([model.fxName isEqualToString:@"Beauty Whitening"]){
            [NvTimelineUtils applyBeauty:fx lutWhiten:model.switchSelected];
            [fx setFloatVal:model.fxName val:model.value];
        }
        else if(![model.fxName containsString:@"Advanced Beauty Type"] && ![model.fxName isEqualToString:@""] && ![model.fxName isEqualToString:@"Beauty Strength"] && ![model.fxName isEqualToString:@"none"]){
            [fx setFloatVal:model.fxName val:model.value];
        }
    }else if (category == 1 || category == 2) {
        NSLog(@"======== %@ uuid:%@ degreeName:%@ value: %f   extValue: %f",model.fxName,model.uuid,model.degreeName,model.value,model.extValue);
        if (model.fxName.length > 0) {
            [fx setStringVal:model.fxName val:model.uuid];
            if ([model.fxName isEqualToString:@"Warp Forehead Height Custom Package Id"]) {
                [fx setIntVal:@"Forehead Height Warp Strategy" val:0x7FFFFFFF];
            }
            else if ([model.fxName isEqualToString:@"Warp Head Size Custom Package Id"]) {
                [fx setIntVal:@"Head Size Warp Strategy" val:0x7FFFFFFF];
            }
        }
        if (model.degreeName.length > 0) {
            [fx setFloatVal:model.degreeName val:model.value];
        }
    }
}

+ (void)resetTimeline:(NvsTimeline *)timeline applyColorCorrectFilter:(NvBeautyTypeModel *)model {
    NvsVideoTrack *track = [timeline getVideoTrackByIndex:0];
    for (int i=0; i<track.clipCount; i++) {
        BOOL containTargetFx = NO;
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvsVideoFx *targetFx;
        for (int j = 0; j < clip.fxCount; j++) {
            NvsVideoFx *fx = [clip getFxWithIndex:j];
            if ([fx.bultinVideoFxName isEqualToString:model.uuid] || [fx.videoFxPackageId isEqualToString:model.uuid]) {
                containTargetFx = YES;
                targetFx = fx;
                break;
            }
        }
        if (model.switchSelected) {
            if (!containTargetFx) {
                targetFx = [clip appendPackagedFx:model.uuid];
            }
            [targetFx setFilterIntensity:model.value];
        }else if (targetFx.bultinVideoFxName.length > 0 || targetFx.videoFxPackageId.length > 0){
            [clip removeFx:targetFx.index];
        }
    }
}

//切换美白 Switching whitening
+ (void)applyBeauty:(NvsFx *)fx lutWhiten:(BOOL)isLutWhiten {
    NSString *imagePath;
    if (isLutWhiten) {
        /*
         轻言美白(模式B)
         Whitening (mode B)
         */
        NSString *path = [[NSBundle mainBundle] pathForResource:@"whitenLut" ofType:@"bundle"];
        imagePath = [path stringByAppendingPathComponent:@"WhiteB.mslut"];
        
    }else{
        /*
         美白(模式A)
         Whitening (mode A)
         */
        imagePath = @"";
        
    }
    [fx setStringVal:@"Whitening Lut File" val:imagePath];
    [fx setBooleanVal:@"Whitening Lut Enabled" val:isLutWhiten];
}


#pragma mark - 编辑模块应用校色滤镜
/*
 编辑模块应用校色滤镜
 Apply a color correction filter to the timeline
 */
+ (void)applyColorCorrectFilterWithModel:(NvMakeupEffectBeautyContentModel *)model timeline:(NvsTimeline *)timeline {
    NSString *uuid = model.uuid;
    if (!model.uuid) {
        uuid = [NvTimelineUtils installColorCorrectFilterWithModel:model];
    }
    NvsTimelineVideoFx *colorCorrectFilter = [NvTimelineUtils getPackageVideoFx:timeline fxName:uuid];
    if (!colorCorrectFilter) {
        colorCorrectFilter = [timeline addPackagedTimelineVideoFx:0 duration:timeline.duration videoFxPackageId:uuid];
    }
    
    [colorCorrectFilter setFilterIntensity:model.value];
}
+ (NSMutableString *)installColorCorrectFilterWithModel:(NvMakeupEffectBeautyContentModel *)model {
    NSString *basePath = [[NSBundle mainBundle] pathForResource:@"colorCorrection" ofType:@"bundle"];
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:basePath error:nil];
    NSString *fullPath;
    NSString * licensePath;
    for (NSString *path in dirArray) {
        if ([path.pathExtension isEqualToString:@"videofx"]) {
            fullPath = [basePath stringByAppendingPathComponent:path];
            licensePath = [NSString convertFilePathToNewPath:fullPath WithExtension:@"lic"];
            break;
        }
    }
    if (!fullPath) {
        return nil;
    }
    NSMutableString *uuid = [[NSMutableString alloc] init];
    NvsAssetPackageManagerError error = [[NvSDKUtils getSDKContext].assetPackageManager installAssetPackage:fullPath license:licensePath type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:uuid];
    if (error == NvsAssetPackageManagerError_AlreadyInstalled) {
        [[NvSDKUtils getSDKContext].assetPackageManager upgradeAssetPackage:fullPath license:licensePath type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:uuid];
    }
    return uuid;
}

+ (NSMutableString *)installColorCorrectFilter {
    NSString *basePath = [[NSBundle mainBundle] pathForResource:@"colorCorrection" ofType:@"bundle"];
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:basePath error:nil];
    NSString *fullPath;
    NSString * licensePath;
    for (NSString *path in dirArray) {
        if ([path.pathExtension isEqualToString:@"videofx"]) {
            fullPath = [basePath stringByAppendingPathComponent:path];
            licensePath = [NSString convertFilePathToNewPath:fullPath WithExtension:@"lic"];
            break;
        }
    }
    if (!fullPath) {
        return nil;
    }
    NSMutableString *uuid = [[NSMutableString alloc] init];
    NvsAssetPackageManagerError error = [[NvSDKUtils getSDKContext].assetPackageManager installAssetPackage:fullPath license:licensePath type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:uuid];
    if (error == NvsAssetPackageManagerError_AlreadyInstalled) {
        [[NvSDKUtils getSDKContext].assetPackageManager upgradeAssetPackage:fullPath license:licensePath type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:uuid];
    }
    return uuid;
}


+ (NvsColor)nvsColorWithValue:(NSString *)value {
    NSArray *arr = [value componentsSeparatedByString:@","];
    NvsColor color;
    color.r = 0;
    color.g = 0;
    color.b = 0;
    color.a = 0;
    if (arr.count == 4) {
        color.r = [arr[0] floatValue];
        color.g = [arr[1] floatValue];
        color.b = [arr[2] floatValue];
        color.a = [arr[3] floatValue];
    }
    return color;
}

+ (void)resetVideoFx:(NvsTimeline *)timeline videoFxDataArray:(NSArray *)videoFxDataArray {
    [NvTimelineUtils resetVideoFx:timeline videoFxDataArray:videoFxDataArray timelineData:[NvTimelineData sharedInstance]];
}

+ (void)resetVideoFx:(NvsTimeline *)timeline timelineFilterArray:(NSArray *)timelineFilterArray {
    for (int i = 0; i < timelineFilterArray.count; i++) {
        NvTimeFilterInfoModel *model = timelineFilterArray[i];
        if ([NvSDKUtils isBuiltinFilter:model.name]) {
            [timeline addBuiltinTimelineVideoFx:model.inPoint
                                       duration:model.outPoint - model.inPoint
                                    videoFxName:model.name];
        } else {
            [timeline addPackagedTimelineVideoFx:model.inPoint
                                        duration:model.outPoint - model.inPoint
                                videoFxPackageId:model.name];
        }
    }
}

+ (BOOL)checkBultinWhiteList:(NSString *)name {
    if (!name) {
        return NO;
    }
    NSArray<NSString *> *array = @[@"Mask Generator",
                                   @"Transform 2D",
                                   @"Color Property",
                                   @"Sharpen",
                                   @"Vignette",
                                   @"BasicImageAdjust",
                                   @"Tint",
                                   @"Noise",
                                   @"Storyboard",
                                   @"AR Scene",
                                   @"Crop"];
    return [array containsObject:name];
}

+ (void)resetVideoFx:(NvsTimeline *)timeline videoFxDataArray:(NSArray *)videoFxDataArray timelineData:(NvTimelineData *)timelineData {
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    for (int i = 0; i < videoTrack.clipCount; i++) {
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        for (int j = 0; j < clip.fxCount; j++) {
            NvsVideoFx *videoFx = [clip getFxWithIndex:j];
            NSString *name = [videoFx bultinVideoFxName];
            if([self checkBultinWhiteList:name]) {
                continue;
            }
            [clip removeFx:j];
            j--;
        }
    }
    for (int i = 0; i < videoTrack.clipCount; i++) {
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        for (int j = 0; j < clip.getRawFxCount; j++) {
            NvsVideoFx *videoFx = [clip getRawFxByIndex:j];
            NSString *name = [videoFx bultinVideoFxName];
            if([self checkBultinWhiteList:name]) {
                continue;
            }
            [clip removeRawFx:j];
            j--;
        }
    }
    
    NvsVideoClip *firstClip = [videoTrack getClipWithIndex:0];
    int i = 0;
    //判断是不是主题片头、片尾数据 Determine whether it is the subject title data, the end of the title data
    if (firstClip.roleInTheme == NvsRoleInThemeTitle) {
        i ++;
    }
    // 根据编辑数据重新添加滤镜 Re-add filters based on the edited data
    for (int j = 0 ; j < videoFxDataArray.count; i++, j++) {
        NvTimeFilterInfoModel *info = (NvTimeFilterInfoModel *)videoFxDataArray[j];
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        if(clip.videoType == NvsVideoClipType_AV){
            
        }
        NvsVideoFx *fx;
        if ([NvSDKUtils isBuiltinFilter:info.name]) {
            fx = [clip appendRawBuiltinFx:info.name];
            [fx setFilterIntensity:info.strength];
            if ([info.name isEqualToString:@"Cartoon"]) {
                [fx setBooleanVal:@"Stroke Only" val:info.strokeOnly];
                [fx setBooleanVal:@"Grayscale" val:info.grayscale];
            }
            
        } else {
            fx = [clip appendRawPackagedFx:info.name];
            if (info.expModels.count>0) {
                for (NvAjustFxParamModel * model in info.expModels) {
                    if (model.type == NvAjustFxParamCategoryColor) {
                        NvsColor color;
                        color.r = model.r;
                        color.g = model.g;
                        color.b = model.b;
                        color.a = model.a;
                        [fx setColorExprVar:model.name varValue:&color];
                    }else if (model.type == NvAjustFxParamCategoryInt || model.type == NvAjustFxParamCategoryFloat) {
                        [fx setExprVar:model.name varValue:model.currentValue];
                    }
                }
            }else{
                [fx setFilterIntensity:info.strength];
            }
        }
        if(fx){
            [fx setAbsoluteTimeUsed:true];
        }
    }
}

+ (void)resetKeyframesFilter:(NvsTimeline *)timeline timelineData:(NvTimelineData *)timelineData {
    NvsVideoTrack *track = [timeline getVideoTrackByIndex:0];
    NvsVideoClip *firstClip = [track getClipWithIndex:0];
    int i = 0;
    //判断是不是主题片头、片尾数据 Determine whether it is the subject title data, the end of the title data
    if (firstClip.roleInTheme == NvsRoleInThemeTitle) {
        i ++;
    }
    for (int j = 0 ; j < timelineData.editDataArray.count; i++, j++) {
        NvEditDataModel *clipModel = timelineData.editDataArray[j];
        NvsVideoClip *clip = [track getClipWithIndex:i];
        
        NSLog(@"滤镜关键帧数量 Number of filter keyframes%lu",(unsigned long)clipModel.filterKeyFrames.count);
        for (int k=0; k<clipModel.filterKeyFrames.count; k++) {
            NvKeyFrameFilterModel *model = clipModel.filterKeyFrames[k];
            if (clip.getRawFxCount >0) {
                NvsVideoFx *fx = [clip getRawFxByIndex:clip.getRawFxCount - 1];
                if(clipModel.trimOut >= model.time && clipModel.trimIn <= model.time) {
                    [fx setFloatValAtTime:model.fxParam val:model.value time:model.time - clipModel.trimIn];
                }else{
                    
                }
            }
        }
        
    }
}

+ (void)applyCurveSpeed:(NvsVideoClip *)clip points:(NSMutableArray *)points {
    [clip changeSpeed:1.0 keepAudioPitch:YES];
    NSString *bezierPoints;
    if (points.count > 0) {
        NSMutableArray *curvePoints = [NvTimelineUtils convertToCurvePoints:points];
        bezierPoints = [NvTimelineUtils bezierPointsConvertToString:curvePoints];
    }
    if (!bezierPoints) {
        //曲线变速选择“无” Curve speed change select "None"
        return;
    }
    BOOL result = [clip changeCurvesVariableSpeed:bezierPoints keepAudioPitch:YES];
    if (!result) {
        NSLog(@"应用曲线变速失败 Application of curve speed change failed");
    }
}

+ (NSString *)bezierPointsConvertToString:(NSArray *)points {
    NSMutableString *str = [NSMutableString string];
    for (int i=0; i<points.count; i++) {
        CGPoint point = [points[i] CGPointValue];
        [str appendFormat:@"(%.10f,%.10f)",point.x,point.y];
    }
    return str;
}

+ (NSMutableArray *)convertToCurvePoints:(NSArray *)pointArr {
    NSMutableArray *curvePoints = [NSMutableArray array];
    if (pointArr.count >1) {
        for (int i=0; i<pointArr.count; i++) {
            CGPoint point = [pointArr[i] CGPointValue];
            CGFloat speed = point.y;
            CGPoint curPoint = CGPointMake(point.x, speed);
            CGPoint prePoint = CGPointMake(0, speed);
            CGPoint nexPoint = CGPointMake(0, speed);
            if (i==pointArr.count -1) {
                CGPoint previousPoint = [pointArr[i-1] CGPointValue];
                CGFloat delta = (curPoint.x - previousPoint.x) * (1/3.0);
                prePoint.x = curPoint.x - delta;
                nexPoint.x = curPoint.x + delta;
            }else if (i==0){
                CGPoint nextPoint = [pointArr[i+1] CGPointValue];
                CGFloat delta = (nextPoint.x - curPoint.x) * (1/3.0);
                prePoint.x = -delta;
                nexPoint.x =  delta;
            }else{
                CGPoint previousPoint = [pointArr[i-1] CGPointValue];
                CGPoint nextPoint = [pointArr[i+1] CGPointValue];
                prePoint.x = curPoint.x - (curPoint.x - previousPoint.x) * (1/3.0);
                nexPoint.x = curPoint.x + (nextPoint.x - curPoint.x) * (1/3.0);
            }
            [curvePoints addObject:[NSValue valueWithCGPoint:curPoint]];
            [curvePoints addObject:[NSValue valueWithCGPoint:prePoint]];
            [curvePoints addObject:[NSValue valueWithCGPoint:nexPoint]];
        }
    }
    return curvePoints;
}

+ (void)rebuildTimelineStructure:(NvsVideoTrack *)videoTrack
                      audioTrack:(NvsAudioTrack *)audioTrack
                  timelineFxMode:(int)timelineFxMode
              timelineFxPosition:(int64_t)timelineFxPosition
{
    if (videoTrack == nil || audioTrack == nil) {
        return;
    }
    [videoTrack removeAllClips];
    [audioTrack removeAllClips];
    
    NvTimelineData *timelineData = [NvTimelineData sharedInstance];
    if (timelineFxMode == TIMELINE_FX_REVERSE) {
        for (int i = (int)timelineData.editDataArray.count - 1; i >= 0; i--) {
            NvEditDataModel *editDataModel = timelineData.editDataArray[i];
            NvsVideoClip *videoClip = [videoTrack appendClip:editDataModel.videoPath
                                                      trimIn:editDataModel.trimIn
                                                     trimOut:editDataModel.trimOut];
            if (!videoClip) {
                continue;
            }
            [videoClip changeSpeed:editDataModel.speed keepAudioPitch:YES];
            [videoClip setPlayInReverse:YES];
            [videoClip setVolumeGain:0 rightVolumeGain:0];
        }
    } else {
        for (int i = 0; i < timelineData.editDataArray.count; i++) {
            NvEditDataModel *editDataModel = timelineData.editDataArray[i];
            NvsVideoClip *videoClip = [videoTrack appendClip:editDataModel.videoPath
                                                      trimIn:editDataModel.trimIn
                                                     trimOut:editDataModel.trimOut];
            if (!videoClip) {
                continue;
            }
            [videoClip changeSpeed:editDataModel.speed keepAudioPitch:YES];
            [videoClip setVolumeGain:0 rightVolumeGain:0];
        }
    }
    
    for (int i = 0; i < timelineData.editDataArray.count; i++) {
        NvEditDataModel *editDataModel = timelineData.editDataArray[i];
        NvsAudioClip *audioClip = [audioTrack appendClip:editDataModel.videoPath
                                                  trimIn:editDataModel.trimIn
                                                 trimOut:editDataModel.trimOut];
        [audioClip changeSpeed:editDataModel.speed keepAudioPitch:YES];
        if (editDataModel.mute) {
            [audioClip setVolumeGain:0 rightVolumeGain:0];
        } else {
            [audioClip setVolumeGain:editDataModel.volume rightVolumeGain:editDataModel.volume];
        }
        
    }
    
    if (timelineFxMode == TIMELINE_FX_REPEAT) {
        [NvTimelineUtils doRepeatTimeline:timelineFxPosition videotrack:videoTrack originCutTrimInfo:nil];
    } else if (timelineFxMode == TIMELINE_FX_SLOWMOTION) {
        [NvTimelineUtils doSlowMotionTimeline:timelineFxPosition videotrack:videoTrack];
    }
    
    [NvTimelineUtils removeAllTransitions:videoTrack audioTrack:audioTrack];
}

+ (BOOL)doRepeatTimeline:(uint64_t)point videotrack:(NvsVideoTrack*_Nullable)track originCutTrimInfo:(NvRecordingInfo *)info
{
    if(!track) {
        return NO;
    }
    
    uint64_t duration = track.duration;
    uint64_t repeatDuration = NV_TIME_BASE / 2;
    if(duration < repeatDuration) {
        return NO;
    }
    
    if(duration < (point + repeatDuration)) {
        point = duration - repeatDuration;
    }
    
    if(![NvTimelineUtils splitClip:point videotrack:track]) {
        NSLog(@"splitClip failure");
        return NO;
    }
    
    if(![NvTimelineUtils splitClip:point+repeatDuration videotrack:track]) {
        NSLog(@"splitClip--point+repeatDuration--failure");
        return NO;
    }
    //splite clip
    NSMutableArray* cliplist = [NvTimelineUtils getClipRange:point duration:repeatDuration videotrack:track];
    if(cliplist.count < 1) {
        NSLog(@"cliplist.count < 1");
        return NO;
    }
    
    NSMutableArray* durationArray = [[NSMutableArray alloc] init];
    uint64_t segmentDuration = repeatDuration;
    for(int i = 0; i < cliplist.count; i++){
        NvsVideoClip* orgClip = cliplist[i];
        uint64_t newTrimOut = orgClip.trimIn + segmentDuration;
        if(newTrimOut > orgClip.trimOut)
            newTrimOut = orgClip.trimOut;
        
        NSNumber *clipDuration = [NSNumber numberWithLongLong:newTrimOut - orgClip.trimIn];
        segmentDuration = segmentDuration - (newTrimOut - orgClip.trimIn);
        [durationArray addObject:clipDuration];
    }
    
    NvsVideoClip* lastClip = cliplist[cliplist.count - 1];
    int clipIndex = lastClip.index + 1;
    if(clipIndex >= track.clipCount)
        clipIndex = track.clipCount - 1;
    for(int i = 0; i < 4; i++){
        
        //insert clip
        bool bReverse = false;
        int start = 0;
        int end = (int)cliplist.count - 1;
        int step = 1;
        if((i % 2) == 0){
            bReverse = true;
            start = (int)cliplist.count - 1;
            end = 0;
            step = -1;
        }
        
        for(int n = start; bReverse ? n >= end : n <= end; n+= step) {
            NvsVideoClip* orgClip = cliplist[n];
            uint64_t duration_new = [durationArray[n] longLongValue];
            NSString *orgFilePath = orgClip.filePath;
            int64_t trimIn_new = orgClip.trimIn;
            int64_t trimOut = duration_new + orgClip.trimIn;
            if(bReverse){
                NSString *lastPath = [orgFilePath lastPathComponent];
                orgFilePath = [CONVERTPATH stringByAppendingPathComponent:lastPath];
                int64_t dur = [[[NvsStreamingContext sharedInstance] getAVFileInfo:orgFilePath] getVideoStreamDuration:0];
                
                if (info.asset) {
                    orgFilePath = info.convertPath;
                    dur = info.trimOut-info.trimIn;
                }
                
                trimIn_new = dur - duration_new - (orgClip.trimIn - info.trimIn);
                if (trimIn_new < 0) {
                    trimIn_new = 0;
                }
                trimOut = dur - (orgClip.trimIn - info.trimIn);
                
            }
            NvsVideoClip* clip = [track insertClip:orgFilePath trimIn:trimIn_new trimOut:trimOut clipIndex:clipIndex];
            if(!clip){
                continue;
            }
            
            float lvolumeGain = 1.0f;
            float rvolumeGain = 1.0f;
            double speed = [orgClip getSpeed];
            NvsExtraVideoRotation rotation = [orgClip getExtraVideoRotation];
            [orgClip getVolumeGain:&lvolumeGain rightVolumeGain:&rvolumeGain];
            if (speed > 1) {
                [clip changeSpeed:speed keepAudioPitch:YES];
            } else {
                [clip changeSpeed:speed*1.5 keepAudioPitch:YES];
            }
            
            [clip setVolumeGain:0.0f rightVolumeGain:0.0f];
            [clip setExtraVideoRotation:rotation];
            
            clipIndex++;
        }
        
    }
    
    //超出时长移除 Outage removal
    [track removeRange:duration endTimelinePos:track.duration keepSpace:false];
    return YES;
}

+ (BOOL)doSlowMotionTimeline:(uint64_t)point videotrack:(NvsVideoTrack*_Nullable)track
{
    if(!track)
        return NO;
    uint64_t duration = track.duration;
    if(duration < NV_TIME_BASE)
        return NO;
    
    if(duration < (point + NV_TIME_BASE))
        point = duration - NV_TIME_BASE;
    
    if(![NvTimelineUtils splitClip:point videotrack:track])
        return NO;
    
    if(![NvTimelineUtils splitClip:point + NV_TIME_BASE videotrack:track])
        return NO;
    
    uint64_t prePoint = 0;
    uint64_t preduration = NV_TIME_BASE;
    uint64_t afterPoint = point + NV_TIME_BASE;
    uint64_t afterduration = NV_TIME_BASE;
    if(point <  NV_TIME_BASE){
        preduration = point;
        afterduration += NV_TIME_BASE - preduration;
        if((afterPoint + afterduration) > duration)
            afterduration = duration - afterPoint;
    }else{
        if((afterPoint + afterduration) > duration)
            afterduration = duration - afterPoint;
        
        preduration += (NV_TIME_BASE - afterduration);
        if(preduration > point){
            preduration = point;
        }
        prePoint = point - preduration;
    }
    
    if(point > preduration){
        //need split clips
        [NvTimelineUtils splitClip:prePoint videotrack:track];
    }
    
    if((afterPoint + afterduration) < duration){
        //need split clips
        [NvTimelineUtils splitClip:afterPoint + afterduration videotrack:track];
    }
    //splite clip
    NSMutableArray* cliplist = [NvTimelineUtils getClipRange:point duration:NV_TIME_BASE videotrack:track];
    if(cliplist.count < 1)
        return NO;
    
    //pre clip
    
    NSMutableArray* precliplist = [NvTimelineUtils getClipRange:prePoint duration:preduration videotrack:track];
    
    //after process
    
    NSMutableArray* aftercliplist = [NvTimelineUtils getClipRange:afterPoint duration:afterduration videotrack:track];
    
    //
    for(int i = 0; i < cliplist.count; i++){
        NvsVideoClip* orgClip = cliplist[i];
        
        double speed = [orgClip getSpeed];
        [orgClip changeSpeed:speed / 2.0 keepAudioPitch:YES];
    }
    //慢动作前面的时间点快放 Put it in front of slow motion
    for(int i = 0; i < precliplist.count; i++){
        NvsVideoClip* orgClip = precliplist[i];
        
        double speed = [orgClip getSpeed];
        [orgClip changeSpeed:speed * 2.0 keepAudioPitch:YES];
    }
    //慢动作后面的时间点快放 I'm going to put it back in slow motion
    for(int i = 0; i < aftercliplist.count; i++){
        NvsVideoClip* orgClip = aftercliplist[i];
        
        double speed = [orgClip getSpeed];
        [orgClip changeSpeed:speed * 2.0 keepAudioPitch:YES];
    }
    //超出时长移除 Outage removal
    if(duration < track.duration)
        [track removeRange:duration endTimelinePos:track.duration keepSpace:false];
    
    return YES;
}

+ (NSMutableArray*) getClipRange:(uint64_t)point duration:(uint64_t)duration videotrack:(NvsVideoTrack*_Nullable)track
{
    NSMutableArray* cliplist = [[NSMutableArray alloc] init];
    
    uint64_t ptindex = point;
    while(ptindex < (point + duration)){
        NvsVideoClip* clip = [track getClipWithTimelinePosition: ptindex];
        if(!clip)
            break;
        
        ptindex = clip.outPoint;
        [cliplist addObject:clip];
    }
    
    return cliplist;
}

+(BOOL)splitClip:(uint64_t)point videotrack:(NvsVideoTrack*_Nullable)track
{
    if(!track)
        return NO;
    
    NvsVideoClip* splitClip = [track getClipWithTimelinePosition:point];
    if(splitClip.inPoint != point){
        if (![track splitClip:splitClip.index splitPoint:point]) {
            return NO;
        }
    }
    
    return YES;
}
+ (BOOL)MuteVideoTrack:(NvsVideoTrack*_Nullable)track
{
    if(!track)
        return NO;
    
    for(int i = 0; i < track.clipCount; i++){
        NvsVideoClip* orgClip = [track getClipWithIndex:i];
        [orgClip setVolumeGain:0 rightVolumeGain:0];
        [orgClip setPan:0 andScan:1];
    }
    
    return YES;
}

+ (void)removeAllVideoTransitions:(NvsVideoTrack *)videoTrack {
    if (videoTrack == nil)
        return;
    for (int i = 0; i < (int)videoTrack.clipCount - 1; i++) {
        [videoTrack setBuiltinTransition:i withName:nil];
    }
}

+ (void)removeAllTransitions:(NvsVideoTrack *)videoTrack audioTrack:(NvsAudioTrack *)audioTrack {
    if (videoTrack == nil)
        return;
    for (int i = 0; i < (int)videoTrack.clipCount - 1; i++) {
        [videoTrack setBuiltinTransition:i withName:nil];
    }
    if (audioTrack == nil)
        return;
    for (int i = 0; i < (int)audioTrack.clipCount - 1; i++) {
        [audioTrack setBuiltinTransition:i withName:nil];
    }
}

+ (int64_t)getClipInpoint:(NvsTimeline *)timeline clipInfo:(NvEditDataModel *)clipInfo {
    NSMutableArray *editDataArray = [[NvTimelineData sharedInstance] editDataArray];
    for (int i = 0; i < editDataArray.count; i++) {
        NvEditDataModel *info = editDataArray[i];
        if ([info.uuid isEqualToString:clipInfo.uuid]) {
            NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
            NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
            return clip.inPoint;
        }
    }
    return 0;
}

+ (int64_t)getClipOutpoint:(NvsTimeline *)timeline clipInfo:(NvEditDataModel *)clipInfo {
    NSMutableArray *editDataArray = [[NvTimelineData sharedInstance] editDataArray];
    for (int i = 0; i < editDataArray.count; i++) {
        NvEditDataModel *info = editDataArray[i];
        if ([info.uuid isEqualToString:clipInfo.uuid]) {
            NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
            NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
            return clip.outPoint;
        }
    }
    return 0;
}

+ (void)removeClipCropAndTransformFx:(NvsVideoClip *)clip{
    [clip enablePropertyVideoFx:NO];
    [clip enableRawSourceMode:NO];
    clip.rawFilterProcessesMode = NvsClipRawFilterProcessesModeNone;
    
    for (int j = 0; j < clip.getRawFxCount; j++) {
        NvsVideoFx *videoFx = [clip getRawFxByIndex:j];
        NSString *name = [videoFx bultinVideoFxName];
        if([name isEqualToString:@"Crop"] || [name isEqualToString:@"Transform 2D"]) {
            [clip removeRawFx:j];
            j--;
        }
    }
    
    for (int j = 0; j < clip.fxCount; j++) {
        NvsVideoFx *videoFx = [clip getFxWithIndex:j];
        NSString *name = [videoFx bultinVideoFxName];
        if([name isEqualToString:@"Crop"] || [name isEqualToString:@"Transform 2D"]) {
            [clip removeRawFx:j];
            j--;
        }
    }
}

+ (NvsVideoClip *)getTimelineVideoClip:(NvsTimeline *)timeline clipInfo:(NvEditDataModel *)clipInfo {
    NSMutableArray *editDataArray = [[NvTimelineData sharedInstance] editDataArray];
    for (int i = 0; i < editDataArray.count; i++) {
        NvEditDataModel *info = editDataArray[i];
        if ([info.uuid isEqualToString:clipInfo.uuid]) {
            NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
            NvsVideoClip *clip = [videoTrack getClipWithIndex:0];
            if (clip.roleInTheme == NvsRoleInThemeTitle) {
                return [videoTrack getClipWithIndex:i+1];
            } else {
                return [videoTrack getClipWithIndex:i];
            }
        }
    }
    return nil;
}

+ (NSMutableArray<NvsThumbnailSequenceDesc *> *)getThumbnailSequenceDescArray:(NvsTimeline *)timeline {
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    NSMutableArray *thumbnailSequenceDescArray = [NSMutableArray array];
    for (int i = 0; i < videoTrack.clipCount; i++) {
        NvsVideoClip *videoClip = [videoTrack getClipWithIndex:i];
        NvsThumbnailSequenceDesc *info = [[NvsThumbnailSequenceDesc alloc] init];
        info.stillImageHint = NO;
        info.mediaFilePath = videoClip.filePath;
        info.trimIn = videoClip.trimIn;
        info.trimOut = videoClip.trimOut;
        info.inPoint = videoClip.inPoint;
        info.outPoint = videoClip.outPoint;
        
        [thumbnailSequenceDescArray addObject:info];
    }
    return thumbnailSequenceDescArray;
}

+ (void)seekTimeline:(NvsTimeline *)timeline atTime:(int64_t)atTime {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    [context seekTimeline:timeline timestamp:atTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

+ (void)seekTimeline:(NvsTimeline *)timeline timestamp:(int64_t)timestamp flags:(int)flags {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    NSNumber * OResolutionNum = NV_UserInfo(@"NvCompileResolution");
    if (OResolutionNum.intValue >= 2160) {
        NvsRational rational = {1,4};
        if (![context seekTimeline:timeline timestamp:timestamp proxyScale:&rational flags:flags]) {
            NSLog(@"定位时间线失败！seek timeline failed!");
        }
    }else {
        if (![context seekTimeline:timeline timestamp:timestamp videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flags]){
            NSLog(@"定位时间线失败！seek timeline failed!");
        }
    }
}

+ (void)playTimeline:(NvsTimeline *)timeline atTime:(int64_t)atTime {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    [context playbackTimeline:timeline startTime:atTime endTime:timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

+ (BOOL)playbackTimeline:(NvsTimeline *)timeline startTime:(int64_t)startTime endTime:(int64_t)endTime flags:(int)flags {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    NSNumber * OResolutionNum = NV_UserInfo(@"NvCompileResolution");
    if (OResolutionNum.intValue >= 2160) {
        NvsRational rational = {1,4};
        if (![context playbackTimeline:timeline startTime:startTime endTime:endTime proxyScale:&rational preload:YES flags:flags]) {
            NSLog(@"播放时间线失败！play timeline failed!");
            return NO;
        }
        
    }else if (![context playbackTimeline:timeline startTime:startTime endTime:endTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:flags]) {
        NSLog(@"播放时间线失败！play timeline failed!");
        return NO;
    }
    return YES;
}

+ (NSArray *)getRegionWithRect:(CGRect)rect sceneWidth:(CGFloat)sceneWidth sceneHeight:(CGFloat)sceneHeight {
    CGFloat left = [NvTimelineUtils getRatioValue:rect.origin.x denValue:sceneWidth];
    CGFloat right = [NvTimelineUtils getRatioValue:CGRectGetMaxX(rect) denValue:sceneWidth];
    CGFloat top = [NvTimelineUtils getRatioValue:sceneHeight -rect.origin.y denValue:sceneHeight];
    CGFloat bottom = [NvTimelineUtils getRatioValue:sceneHeight -CGRectGetMaxY(rect) denValue:sceneHeight];
    NSArray *points = @[@(left),@(top),@(left),@(bottom),@(right),@(bottom),@(right),@(top)];
    return points;
}

//获取占比（范围：-1～1） Obtain the ratio (range: -1 to 1)
+ (CGFloat)getRatioValue:(CGFloat)num denValue:(CGFloat)den {
    CGFloat value = num/den;
    return value*2-1;
}

+ (NSString *)saveTimelineDataToFile:(NvTimelineData *)originModel {
    NSData *jsonObject = [originModel yy_modelToJSONData];
    NSString *bundlePath = NV_TIMELINEDATA_SAVE_PATH;
    NSString *currentTime = [NvUtils currentDateAndTime];
    NSString *savePath = [[bundlePath stringByAppendingPathComponent:currentTime] stringByAppendingString:@".json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:bundlePath]) {
        [fileManager createDirectoryAtPath:bundlePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    BOOL result = [jsonObject writeToFile:savePath atomically:YES];
    if (result) {
        NSLog(@"保存成功 Save successfully%@",savePath);
    }else{
        NSLog(@"保存失败 Save failure%@",savePath);
    }
    return savePath;
    
}

+ (NvsTimelineVideoFx *)getBuiltInVideoFx:(NvsTimeline *)timeline fxName:(NSString *)fxName {
    NvsTimelineVideoFx *videoFx = [timeline getFirstTimelineVideoFx];
    NvsTimelineVideoFx *currentFx;
    while (videoFx != nil) {
        if ([[videoFx bultinTimelineVideoFxName] isEqualToString:fxName]) {
            currentFx = videoFx;
            break;
        }
        videoFx = [timeline getNextTimelineVideoFx:videoFx];
    }
    return currentFx;
}

+ (NvsTimelineVideoFx *)getPackageVideoFx:(NvsTimeline *)timeline fxName:(NSString *)fxName {
    NvsTimelineVideoFx *videoFx = [timeline getFirstTimelineVideoFx];
    NvsTimelineVideoFx *currentFx;
    while (videoFx != nil) {
        if ([[videoFx timelineVideoFxPackageId] isEqualToString:fxName]) {
            currentFx = videoFx;
            break;
        }
        videoFx = [timeline getNextTimelineVideoFx:videoFx];
    }
    return currentFx;
}

+ (void)resetPropertyBackgroundEffect:(NvsVideoClip *)clip model:(NvPropertyBackgroundEffectModel *)model {
    [clip setAttachment:model forKey:CLIP_PROPERTY_BACKGROUND_ATTACHMENT];
    if (![clip isPropertyVideoFxEnabled] && model.isUsePropertyEffect) {
        [clip enablePropertyVideoFx:YES];
    }
    
    NvsVideoFx *backgroundFx = [clip getPropertyVideoFx];
    [backgroundFx setBooleanVal:@"Background Blur New Mode Enable" val:YES];
    switch (model.backgroundCategory) {
        case NvBackgroundFxBlur:
        {
            [backgroundFx setMenuVal:@"Background Mode" val:@"Color Solid"];
            NvsColor nColor;
            nColor.r = 0;
            nColor.g = 0;
            nColor.b = 0;
            nColor.a = 0;
            [backgroundFx setColorVal:@"Background Color" val:&nColor];
            
            [backgroundFx setMenuVal:@"Background Mode" val:@"Blur"];
            [backgroundFx setFloatVal:@"Background Blur Radius" val:model.radius];
        }
            break;
            
        case NvBackgroundFxStyle:
        {
            NSLog(@"背景图片路径 Background image path%@",model.imageFile);
            [backgroundFx setMenuVal:@"Background Mode" val:@"Image File"];
            
            [backgroundFx setStringVal:@"Background Image" val:model.imageFile];
            if ([model.imageFile isEqualToString:@""]) {
                [backgroundFx setMenuVal:@"Background Mode" val:@"Color Solid"];
                NvsColor nColor;
                nColor.r = 0;
                nColor.g = 0;
                nColor.b = 0;
                nColor.a = 0;
                [backgroundFx setColorVal:@"Background Color" val:&nColor];
            }
        }
            break;
            
        default:{
            [backgroundFx setMenuVal:@"Background Mode" val:@"Color Solid"];
            NvsColor nColor;
            nColor.r = model.colorR;
            nColor.g = model.colorG;
            nColor.b = model.colorB;
            nColor.a = model.colorA;
            [backgroundFx setColorVal:@"Background Color" val:&nColor];
        }
            break;
    }
    
}

+ (void)resetPropertyTransformEffect:(NvsVideoClip *)clip editModel:(NvEditDataModel *)editModel {
    NvPropertyBackgroundEffectModel *backgroundModel = editModel.backgroundEffectModel;
    [NvTimelineUtils resetPropertyTransformEffect:clip backgroundModel:backgroundModel];
}

+ (void)resetPropertyTransformEffect:(NvsVideoClip *)clip backgroundModel:(NvPropertyBackgroundEffectModel *)backgroundModel {
    if (![clip isPropertyVideoFxEnabled] && backgroundModel.isUsePropertyEffect) {
        [clip enablePropertyVideoFx:YES];
    }
    NvsVideoFx *propertyFx = [clip getPropertyVideoFx];
    [propertyFx setFloatVal:@"Scale X" val:backgroundModel.scaleX];
    [propertyFx setFloatVal:@"Scale Y" val:backgroundModel.scaleY];
    [propertyFx setFloatVal:@"Rotation" val:backgroundModel.rotation];
    [propertyFx setFloatVal:@"Anchor X" val:0];
    [propertyFx setFloatVal:@"Anchor Y" val:0];
    [propertyFx setFloatVal:@"Trans X" val:backgroundModel.transformX];
    [propertyFx setFloatVal:@"Trans Y" val:backgroundModel.transformY];
    [propertyFx setFloatVal:@"Opacity" val:backgroundModel.opacity];
}

//通过storyboard 设置背景模糊方法 Set the background blur method through storyboard
+ (void)resetBackgroundBlurXMLEffect:(NvsTimeline *)timeline clip:(NvsVideoClip *)clip model:(NvPropertyBackgroundEffectModel *)model editModel:(NvEditDataModel *)editModel {
    [clip setAttachment:model forKey:CLIP_PROPERTY_BACKGROUND_ATTACHMENT];
    NvsVideoResolution videoRes = timeline.videoRes;
    NvsVideoFx *backgroundVideoFx;
    NvsVideoFx *fx;
    for (int i=0; i<clip.fxCount; i++) {
        fx = [clip getFxWithIndex:i];
        NSString *type = (NSString *)[fx getAttachment:VIDEO_FX_TYPE];
        if ([type isEqualToString:CLIP_BACKGROUND_ATTACHMENT]) {
            backgroundVideoFx = fx;
            break;
        }
    }
    if (backgroundVideoFx == nil) {
        backgroundVideoFx = [clip appendBuiltinFx:@"Storyboard"];
        [backgroundVideoFx setAttachment:CLIP_BACKGROUND_ATTACHMENT forKey:VIDEO_FX_TYPE];
    }
    
    CGSize assetSize = [NvTimelineUtils getAVFileSize:editModel.videoPath];
    float blurScale = [NvTimelineUtils getBackgroundScaleValue:CGSizeMake(videoRes.imageWidth, videoRes.imageHeight) assetSize:assetSize];
    if (model.radius == 0) {
        blurScale = 0;
    }
    NSString *xmlStr;
    
    if ([model.imageFile isEqualToString:@"None"]) {
        xmlStr = [NvTimelineUtils getImageBgTransformXmlFormat:videoRes.imageWidth sceneHeight:videoRes.imageHeight width:videoRes.imageWidth height:videoRes.imageHeight scaleX:model.scaleX scaleY:model.scaleY rotationZ:model.rotation transX:model.transformX transY:model.transformY opacity:model.opacity];
        
    }else{
        xmlStr = [NvTimelineUtils getImageBgBlurXmlFormat:videoRes.imageWidth sceneHeight:videoRes.imageHeight fastBlur:model.radius width:videoRes.imageWidth height:videoRes.imageHeight scaleX:model.scaleX scaleY:model.scaleY rotationZ:model.rotation transX:model.transformX transY:model.transformY opacity:model.opacity blurScaleX:blurScale blurScaleY:blurScale];
    }
    [backgroundVideoFx setStringVal:@"Description String" val:xmlStr];
    [backgroundVideoFx setBooleanVal:@"No Background" val:YES];
    [backgroundVideoFx setAbsoluteTimeUsed:true];
    
}

//通过storyboard 设置背景颜色、背景图片方法 Set background color and background image method through storyboard
+ (void)resetBackgroundXMLEffect:(NvsTimeline *)timeline clip:(NvsVideoClip *)clip model:(NvPropertyBackgroundEffectModel *)model {
    NSString *imageFile ;
    if(model.imageFile.length > 0 ){
        imageFile = model.imageFile;
    }else{
        imageFile = @":1";
    }
    [clip setAttachment:model forKey:CLIP_PROPERTY_BACKGROUND_ATTACHMENT];
    NvsVideoResolution videoRes = timeline.videoRes;
    NvsVideoFx *backgroundVideoFx;
    NvsVideoFx *fx;
    for (int i=0; i<clip.fxCount; i++) {
        fx = [clip getFxWithIndex:i];
        NSString *type = (NSString *)[fx getAttachment:VIDEO_FX_TYPE];
        if ([type isEqualToString:CLIP_BACKGROUND_ATTACHMENT]) {
            backgroundVideoFx = fx;
            break;
        }
    }
    if (backgroundVideoFx == nil) {
        backgroundVideoFx = [clip appendBuiltinFx:@"Storyboard"];
        [backgroundVideoFx setAttachment:CLIP_BACKGROUND_ATTACHMENT forKey:VIDEO_FX_TYPE];
    }
    
    NSString *xmlStr ;
    if(![model.imageFile isEqualToString:@"None"] && model.imageFile.length > 0){
        xmlStr = [NvTimelineUtils getImageBgXmlFormat:videoRes.imageWidth sceneHeight:videoRes.imageHeight trackSource:model.imageFile width:videoRes.imageWidth height:videoRes.imageHeight scaleX:model.scaleX scaleY:model.scaleY rotationZ:model.rotation transX:model.transformX transY:model.transformY opacity:model.opacity];
    }
    else{
        xmlStr = [NvTimelineUtils getImageBgTransformXmlFormat:videoRes.imageWidth sceneHeight:videoRes.imageHeight width:videoRes.imageWidth height:videoRes.imageHeight scaleX:model.scaleX scaleY:model.scaleY rotationZ:model.rotation transX:model.transformX transY:model.transformY opacity:model.opacity];
    }
    [backgroundVideoFx setStringVal:@"Description String" val:xmlStr];
    [backgroundVideoFx setBooleanVal:@"No Background" val:YES];
    [backgroundVideoFx setAbsoluteTimeUsed:true];
    
}

+ (float)getBackgroundScaleValue:(CGSize)timelineSize assetSize:(CGSize)assetSize {
    float timelineRatio = timelineSize.width * 1.0f / timelineSize.height;
    float fileRatio = assetSize.width * 1.0f / assetSize.height;
    float scale = 1.0f;
    if (fileRatio > timelineRatio) {//此时是宽对齐，需要高对齐 In this case, the width alignment is required and the height alignment is required
        float scaleBefore = timelineSize.width * 1.0F / assetSize.width;
        scale = timelineSize.height * 1.0F / (assetSize.height * scaleBefore);
    } else {//此时是高对齐，需要宽对齐 In this case, it is high alignment, and you need wide alignment
        float scaleBefore = timelineSize.height * 1.0F / assetSize.height;
        scale = timelineSize.width * 1.0F / (assetSize.width * scaleBefore);
    }
    return scale;
}

+ (NSString *)getImageBgTransformXmlFormat:(int)sceneWidth sceneHeight:(int)sceneHeight width:(int)width height:(int)height scaleX:(float)scaleX scaleY:(float)scaleY rotationZ:(float)rotationZ transX:(float)transX transY:(float)transY opacity:(float)opacity {
    NSString *descString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><storyboard sceneWidth=\"sceneWidthValue\" sceneHeight=\"sceneHeightValue\"><track source=\":1\" clipStart=\"0\" clipDuration=\"1\" repeat=\"true\"><effect name=\"transform\"><param name=\"scaleX\" value=\"scaleXValue\"/><param name=\"scaleY\" value=\"scaleYValue\"/><param name=\"rotation\" value=\"rotationZValue\"/><param name=\"transX\" value=\"transXValue\"/><param name=\"transY\" value=\"transYValue\"/><param name=\"opacity\" value=\"opacityValue\"/></effect></track></storyboard>";
    
    descString = [descString stringByReplacingOccurrencesOfString:@"sceneWidthValue" withString:[NSString stringWithFormat:@"%d",sceneWidth]];
    descString = [descString stringByReplacingOccurrencesOfString:@"sceneHeightValue" withString:[NSString stringWithFormat:@"%d",sceneHeight]];
    
    descString = [descString stringByReplacingOccurrencesOfString:@"widthValue" withString:[NSString stringWithFormat:@"%d",width]];
    descString = [descString stringByReplacingOccurrencesOfString:@"heightValue" withString:[NSString stringWithFormat:@"%d",height]];
    descString = [descString stringByReplacingOccurrencesOfString:@"scaleXValue" withString:[NSString stringWithFormat:@"%f",scaleX]];
    descString = [descString stringByReplacingOccurrencesOfString:@"scaleYValue" withString:[NSString stringWithFormat:@"%f",scaleY]];
    descString = [descString stringByReplacingOccurrencesOfString:@"rotationZValue" withString:[NSString stringWithFormat:@"%f",rotationZ]];
    descString = [descString stringByReplacingOccurrencesOfString:@"transXValue" withString:[NSString stringWithFormat:@"%f",transX]];
    descString = [descString stringByReplacingOccurrencesOfString:@"transYValue" withString:[NSString stringWithFormat:@"%f",transY]];
    descString = [descString stringByReplacingOccurrencesOfString:@"opacityValue" withString:[NSString stringWithFormat:@"%f",opacity]];
    NSLog(@"descString==%@",descString);
    return descString;
}

+ (NSString *)getImageBgXmlFormat:(int)sceneWidth sceneHeight:(int)sceneHeight trackSource:(NSString *)trackSource width:(int)width height:(int)height scaleX:(float)scaleX scaleY:(float)scaleY rotationZ:(float)rotationZ transX:(float)transX transY:(float)transY opacity:(float)opacity {
    NSString *descString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><storyboard sceneWidth=\"sceneWidthValue\" sceneHeight=\"sceneHeightValue\"><track source=\"trackSourceValue\" width=\"widthValue\" height=\"heightValue\" clipStart=\"0\" clipDuration=\"1\" repeat=\"true\"></track><track source=\":1\" clipStart=\"0\" clipDuration=\"1\" repeat=\"true\"><effect name=\"transform\"><param name=\"scaleX\" value=\"scaleXValue\"/><param name=\"scaleY\" value=\"scaleYValue\"/><param name=\"rotation\" value=\"rotationZValue\"/><param name=\"transX\" value=\"transXValue\"/><param name=\"transY\" value=\"transYValue\"/><param name=\"opacity\" value=\"opacityValue\"/></effect></track></storyboard>";
    
    descString = [descString stringByReplacingOccurrencesOfString:@"sceneWidthValue" withString:[NSString stringWithFormat:@"%d",sceneWidth]];
    descString = [descString stringByReplacingOccurrencesOfString:@"sceneHeightValue" withString:[NSString stringWithFormat:@"%d",sceneHeight]];
    descString = [descString stringByReplacingOccurrencesOfString:@"trackSourceValue" withString:trackSource.length > 0 ? trackSource : @""];
    descString = [descString stringByReplacingOccurrencesOfString:@"widthValue" withString:[NSString stringWithFormat:@"%d",width]];
    descString = [descString stringByReplacingOccurrencesOfString:@"heightValue" withString:[NSString stringWithFormat:@"%d",height]];
    descString = [descString stringByReplacingOccurrencesOfString:@"scaleXValue" withString:[NSString stringWithFormat:@"%f",scaleX]];
    descString = [descString stringByReplacingOccurrencesOfString:@"scaleYValue" withString:[NSString stringWithFormat:@"%f",scaleY]];
    descString = [descString stringByReplacingOccurrencesOfString:@"rotationZValue" withString:[NSString stringWithFormat:@"%f",rotationZ]];
    descString = [descString stringByReplacingOccurrencesOfString:@"transXValue" withString:[NSString stringWithFormat:@"%f",transX]];
    descString = [descString stringByReplacingOccurrencesOfString:@"transYValue" withString:[NSString stringWithFormat:@"%f",transY]];
    descString = [descString stringByReplacingOccurrencesOfString:@"opacityValue" withString:[NSString stringWithFormat:@"%f",opacity]];
    NSLog(@"descString==%@",descString);
    return descString;
}

+ (NSString *)getImageBgBlurXmlFormat:(int)sceneWidth sceneHeight:(int)sceneHeight fastBlur:(float)radius width:(int)width height:(int)height scaleX:(float)scaleX scaleY:(float)scaleY rotationZ:(float)rotationZ transX:(float)transX transY:(float)transY opacity:(float)opacity blurScaleX:(float)blurScaleX blurScaleY:(float)blurScaleY {
    NSString *descString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><storyboard sceneWidth=\"sceneWidthValue\" sceneHeight=\"sceneHeightValue\"><track source=\":1\" width=\"widthValue\" height=\"heightValue\" clipStart=\"0\" clipDuration=\"1\" repeat=\"true\"><effect name=\"fastBlur\"><param name=\"radius\" value=\"radiusValue\"/></effect><effect name=\"transform\"><param name=\"scaleX\" value=\"blurScaleXValue\"/><param name=\"scaleY\" value=\"blurScaleYValue\"/></effect></track><track source=\":1\" width=\"widthValue\" height=\"heightValue\" clipStart=\"0\" clipDuration=\"1\" repeat=\"true\"><effect name=\"transform\"><param name=\"scaleX\" value=\"scaleXValue\"/><param name=\"scaleY\" value=\"scaleYValue\"/><param name=\"rotation\" value=\"rotationZValue\"/><param name=\"transX\" value=\"transXValue\"/><param name=\"transY\" value=\"transYValue\"/><param name=\"opacity\" value=\"opacityValue\"/></effect></track></storyboard>";
    
    descString = [descString stringByReplacingOccurrencesOfString:@"sceneWidthValue" withString:[NSString stringWithFormat:@"%d",sceneWidth]];
    descString = [descString stringByReplacingOccurrencesOfString:@"sceneHeightValue" withString:[NSString stringWithFormat:@"%d",sceneHeight]];
    descString = [descString stringByReplacingOccurrencesOfString:@"radiusValue" withString:[NSString stringWithFormat:@"%f",radius]];
    descString = [descString stringByReplacingOccurrencesOfString:@"widthValue" withString:[NSString stringWithFormat:@"%d",width]];
    descString = [descString stringByReplacingOccurrencesOfString:@"heightValue" withString:[NSString stringWithFormat:@"%d",height]];
    descString = [descString stringByReplacingOccurrencesOfString:@"scaleXValue" withString:[NSString stringWithFormat:@"%f",scaleX]];
    descString = [descString stringByReplacingOccurrencesOfString:@"scaleYValue" withString:[NSString stringWithFormat:@"%f",scaleY]];
    descString = [descString stringByReplacingOccurrencesOfString:@"rotationZValue" withString:[NSString stringWithFormat:@"%f",rotationZ]];
    descString = [descString stringByReplacingOccurrencesOfString:@"transXValue" withString:[NSString stringWithFormat:@"%f",transX]];
    descString = [descString stringByReplacingOccurrencesOfString:@"transYValue" withString:[NSString stringWithFormat:@"%f",transY]];
    descString = [descString stringByReplacingOccurrencesOfString:@"opacityValue" withString:[NSString stringWithFormat:@"%f",opacity]];
    descString = [descString stringByReplacingOccurrencesOfString:@"blurScaleXValue" withString:[NSString stringWithFormat:@"%f",blurScaleX]];
    descString = [descString stringByReplacingOccurrencesOfString:@"blurScaleYValue" withString:[NSString stringWithFormat:@"%f",blurScaleY]];
    NSLog(@"blur descString==%@",descString);
    return descString;
}

+ (NvsVideoClip *)getCurrentClip:(NvsStreamingContext *)streamingContext timeline:(NvsTimeline *)timeline {
    int64_t currentTime = [streamingContext getTimelineCurrentPosition:timeline];
    NvsVideoTrack *track = [timeline getVideoTrackByIndex:0];
    NvsVideoClip *clip = [track getClipWithTimelinePosition:currentTime];
    return clip;
}

+ (NSMutableArray *)getClipTimelineFilter:(NvEditDataModel *)clipInfo timeline:(NvsTimeline *)timeline {
    NSUInteger index = [[NvTimelineData sharedInstance].editDataArray indexOfObject:clipInfo];
    NSMutableArray *filters = [[NvTimelineData sharedInstance] videoFxDataArray];
    NSMutableArray *clipFilters = NSMutableArray.new;
    if (filters.count > index) {
        NvTimeFilterInfoModel *filterModel = filters[index];
        NvTimeFilterInfoModel *clipFilter = [filterModel copy];
        clipFilter.inPoint = 0;
        clipFilter.outPoint = timeline.duration;
        [clipFilters addObject:clipFilter];
    } else {
        
    }
    return clipFilters;
}

+ (void)resetAllClipManipulatesTracking:(NvsTimeline *)timeline {
    NvsVideoTrack *track = [timeline getVideoTrackByIndex:0];
    
    for (int i=0; i<track.clipCount; i++) {
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvsVideoFx *fx = [NvSDKUtils getClipVideoFx:@"AR Scene" withClip:clip];
        if (fx) {
            [[fx getARSceneManipulate] resetTracking];
        }
    }
}
@end

