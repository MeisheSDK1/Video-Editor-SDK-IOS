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
#import "NvUtils.h"
#import "NvsVideoFx.h"
#import "NVHeader.h"
#import "NvSDKUtils.h"
#import "NvsVideoTransition.h"
#import "NvBezierUtils.h"
#import "YYModel.h"
#import "SDKDemo-Swift.h"

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
    NvsTimeline *timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes];
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
    NvsTimeline *timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes];
    [timeline appendVideoTrack];
    [timeline appendAudioTrack]; //音乐轨道
    [timeline appendAudioTrack]; //配音轨道
    return timeline;
}

+ (void)removeTimeline:(NvsTimeline *)timeline {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    [context removeTimeline:timeline];
}

+ (NvsSize)calculateTimelineSize:(NvEditMode)editMode {
    int compileRes = [NvUtils compileResolutionSetting];
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
    } else if (editMode == NvEditMode9v21) {
        size.width = compileRes;
        size.height = compileRes * 21 / 9;
    } else if (editMode == NvEditMode18v9) {
        size.height = compileRes;
        size.width = compileRes * 18 / 9;
    } else if (editMode == NvEditMode9v18) {
        size.width = compileRes;
        size.height = compileRes * 18 / 9;
    }else {
        size.width = 1280;
        size.height = 720;
    }
    return size;
}

+ (NvsSize)calculateTimelineSizeWithAssetRatio:(float)assetRatio {
    int compileRes = [NvUtils compileResolutionSetting];
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
    return size;
}

//根据本地数据重建timeline
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
    // 先移除主题，确保添加前时间线是干净的
    [timeline removeCurrentTheme];
    [timeline deleteWatermark];
    NvTimelineData *timelineData = [NvTimelineData sharedInstance];
    [NvTimelineUtils resetTimeline:timeline data:timelineData];
}

+ (void)resetTimeline:(NvsTimeline *)timeline data:(NvTimelineData *)timelineData {
    //针对是否是dou视频进行区分处理
    if (timelineData.isDou > 0){
        //dou视频音频轨道及转场处理
        [NvTimelineUtils resetDouEditData:timeline data:timelineData];
    }else{
        //拍摄及编辑模块
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
        if ([name isEqualToString:@"Transition"]) {
            [NvTimelineUtils resetTransition:timeline transitionDataArray:timelineData.transitionDataArray];
        }
        if ([name isEqualToString:@"Watermark"]) {
            [NvTimelineUtils resetWatermark:timeline watermarkInfo:timelineData.watermarkInfo];
        }
        if ([name isEqualToString:@"Animation"]) {
            [NvTimelineUtils resetAnimationFx:timeline model:timelineData];
        }
        if ([name isEqualToString:@"Mask"]) {
            [NvTimelineUtils resetMaskFx:timeline model:timelineData];
        }
        if ([name isEqualToString:@"Theme"]) {
            [NvTimelineUtils resetTheme:timeline themeInfo:timelineData.themeInfo musicInfo:timelineData.musicDataArray];
            [NvTimelineUtils resetCaption:timeline captionDataArray:timelineData.captionDataArray];
        }
    }
    
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
//    int count = videoTrack.clipCount-1;
//    if (count < 1) {
//        return;
//    }
//    for (int i = 0; i < count; i++) {
//        [videoTrack setBuiltinTransition:i withName:NULL];
//    }
    
    int64_t audioDuration = audioTrack.duration;
    if (timelineData.musicPath) {
        while (audioDuration < videoTrack.duration) {
            [audioTrack appendClip:timelineData.musicPath trimIn:timelineData.trimIn trimOut:timelineData.trimOut];
            audioDuration = audioTrack.duration;
        }
    }
    
    //实现dou视频相关时间特效
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
    
    //dou 视频内部不设置转场
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

+ (void)resetCaption:(NvsTimeline *)timeline captionDataArray:(NSArray *)captionDataArray {
    NvsTimelineCaption *nextCaption = [timeline getFirstCaption];
    do {
        if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
            nextCaption = [timeline getNextCaption:nextCaption];
        }else{
            nextCaption = [timeline removeCaption:nextCaption];
        }
    } while (nextCaption);
    // 根据编辑数据重新添加字幕
    for (int i = 0; i < captionDataArray.count; i++) {
        NvCaptionInfoModel * info = (NvCaptionInfoModel *)captionDataArray[i];
        if (info.roleInTheme != NvsRoleInThemeGeneral && info.category == NvsThemeCategory) {
            continue;
        }
        NvsTimelineCaption* caption;
        if (info.type == Normal) {
            caption = [timeline addCaption:info.text inPoint:info.inPoint duration:info.outPoint - info.inPoint captionStylePackageId:@""];
            [caption applyCaptionStyle:info.styleId];
        } else {
            caption = [timeline addModularCaption:info.text inPoint:info.inPoint duration:info.outPoint - info.inPoint];
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
            for (NvKeyframeInfo *tempModel in info.keyFramesArray) {
                [caption setCurrentKeyFrameTime:tempModel.pos];
                [caption setCaptionTranslation:tempModel.translation];
                [caption setScaleX:tempModel.scale];
                [caption setScaleY:tempModel.scale];
                [caption setRotationZ:tempModel.rotation];
                
                NSLog(@"应用效果%lld,%@",tempModel.time,NSStringFromCGPoint(tempModel.translation));
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
        [caption setLetterSpacing:info.letterSpace];
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
    // 根据编辑数据重新添加字幕
    for (int i = 0; i < captionDataArray.count; i++) {
        NvCompoundCaptionInfoModel * info = (NvCompoundCaptionInfoModel *)captionDataArray[i];
        NvsTimelineCompoundCaption *caption = [timeline addCompoundCaption:info.inPoint duration:info.outPoint - info.inPoint compoundCaptionPackageId:info.packageId];
        [caption setAttachment:info forKey:@"compoundInfoModel"];
        if (caption == nil) {
            continue;
        }
        //设置子字幕属性
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
            
        }
        //设置字幕属性
        if (info.clipAffinityEnabled) {
            caption.clipAffinityEnabled = info.clipAffinityEnabled;
        }
        [caption setCaptionTranslation:info.translationOffset];
        [caption setRotationZ:info.rotation];
        [caption setScaleX:info.scale];
        [caption setScaleY:info.scale];
    }
}

+ (void)resetSticker:(NvsTimeline *)timeline stickerDataArray:(NSArray *)stickerDataArray{
    NvsTimelineAnimatedSticker *sticker = [timeline getFirstAnimatedSticker];
    while (sticker) {
        sticker = [timeline removeAnimatedSticker:sticker];
    }
    // 根据编辑数据重新添加贴纸
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
                
                NSLog(@"应用效果%lld,%@",tempModel.time,NSStringFromCGPoint(tempModel.translation));
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
//    NSMutableArray *musicDataArray = [[NvTimelineData sharedInstance] musicDataArray];
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
    //应用两次是因为改完主题的字幕文字的时候，不生效
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
        NvsVideoFx *fx = [clip getPropertyVideoFx];
        if (model.packageId == nil || [model.packageId isEqualToString:@""] || !model.isUsePropertyEffect) {
            [fx setStringVal:@"Package Id" val:model.packageId];
            [fx setBooleanVal:@"Enable MutliSample" val:NO];
        } else {
            [fx setStringVal:@"Package Id" val:model.packageId];
            [fx setBooleanVal:@"Enable MutliSample" val:YES];
            [fx setFloatVal:@"Package Effect In" val:model.animationStart];
            [fx setFloatVal:@"Package Effect Out" val:model.animationEnd];
            [fx setExprVar:@"amplitude" varValue:(model.animationEnd - model.animationStart) * 1.0f / NV_TIME_BASE];
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
        if (editDataModel.isImage) {
            assetSize = [NvTimelineUtils getAVFileSize:editDataModel.localIdentifier];
        }else{
            assetSize = [NvTimelineUtils getAVFileSize:editDataModel.videoPath];
        }
        
        [clip setMaskWithMaskModel:model resolution:assetSize];
    }
}

+ (void)resetWatermark:(NvsTimeline *)timeline watermarkInfo:(NvWatermarkInfoModel *)watermarkInfo{
    [timeline deleteWatermark];
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
    }
    else if (watermarkInfo.isBuiltInEffect) {
        CGRect rect = CGRectMake(watermarkInfo.sceneWidth - watermarkInfo.displayWidth - watermarkInfo.marginX, watermarkInfo.marginY, watermarkInfo.displayWidth, watermarkInfo.displayHeight);
        NvsTimelineVideoFx *videoFx = [timeline addBuiltinTimelineVideoFx:watermarkInfo.inPoint duration:watermarkInfo.outPoint videoFxName:watermarkInfo.builtInEffect.effectName];
        [videoFx setRegional:YES];
        NSArray *pointsArr = [NvTimelineUtils getRegionWithRect:rect sceneWidth:watermarkInfo.sceneWidth sceneHeight:watermarkInfo.sceneHeight];
        [videoFx setRegion:pointsArr];
        if (watermarkInfo.builtInEffect.unitSize > 0) {
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
    // 根据编辑数据重新添加粒子
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
         BOOL isBlur = [[[NSUserDefaults standardUserDefaults] valueForKey:@"NvBackgroudBlurFilled"] boolValue];
         if (isBlur) {
             [videoClip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
         } else {
             [videoClip setSourceBackgroundMode:NvsSourceBackgroundModeColorSolid];
         }
         

        //曲线变速
        if (editDataModel.curveSpeeds.count > 0) {
            [NvTimelineUtils applyCurveSpeed:videoClip points:editDataModel.curveSpeeds];
        }else {
            //普通变速
            [videoClip changeSpeed:editDataModel.speed keepAudioPitch:editDataModel.keepAudioPitchNormalChangeSpeed];
        }
            
        
        [videoClip setVolumeGain:editDataModel.volume rightVolumeGain:editDataModel.volume];
        
        [videoClip setPan:editDataModel.pan andScan:editDataModel.scan];
        
        NvsVideoFx *colorVideoFx = [videoClip appendBuiltinFx:@"BasicImageAdjust"];
        [colorVideoFx setFloatVal:@"Brightness" val:editDataModel.brightness];
        [colorVideoFx setFloatVal:@"Saturation" val:editDataModel.saturation];
        [colorVideoFx setFloatVal:@"Contrast" val:editDataModel.contrast];
        [colorVideoFx setFloatVal:@"Highlight" val:editDataModel.highlight];
        [colorVideoFx setFloatVal:@"Shadow" val:editDataModel.shadow];
        [colorVideoFx setFloatVal:@"Blackpoint" val:editDataModel.blackpoint];
        NvsVideoFx *sharpenVideoFx = [videoClip appendBuiltinFx:@"Sharpen"];
        [sharpenVideoFx setFloatVal:@"Amount" val:editDataModel.Sharpen];
        NvsVideoFx *vignetteVideoFx = [videoClip appendBuiltinFx:@"Vignette"];
        [vignetteVideoFx setFloatVal:@"Degree" val:editDataModel.Vignette];
        NvsVideoFx *tintVideoFx = [videoClip appendBuiltinFx:@"Tint"];
        [tintVideoFx setFloatVal:@"Temperature" val:editDataModel.temperature];
        [tintVideoFx setFloatVal:@"Tint" val:editDataModel.tint];
        NvsVideoFx *denoiseVideoFx = [videoClip appendBuiltinFx:@"Noise"];
        [denoiseVideoFx setFloatVal:@"Intensity" val:editDataModel.intensity];
        [denoiseVideoFx setFloatVal:@"Density" val:editDataModel.density];
        [denoiseVideoFx setBooleanVal:@"Grayscale" val:editDataModel.grayscale];

        if (editDataModel.isImage && editDataModel.isDefault) {
            [videoClip setImageMotionAnimationEnabled:editDataModel.hasMotion];
            [videoClip setImageMotionMode:editDataModel.motionMode];
            if (editDataModel.isArea) {
                NvsRect startRect = editDataModel.startRect;
                NvsRect endRect = editDataModel.endRect;
                [videoClip setImageMotionROI:&startRect endROI:&endRect];
            }
            
        }
        if (editDataModel.sourceInfo.mediaFilePath.length > 0) {
            [videoClip setCropperWithModel:editDataModel.cropperModel timelineVideoRes:timeline.videoRes];
        }
        
        [NvTimelineUtils resetPropertyTransformEffect:videoClip editModel:editDataModel];
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
        // 单段音乐，当裁剪长度小于视频长度时，循环
        // 多段音乐，当每一段的裁剪长度小于时间线入出点之差时，循环
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
            [transition setVideoTransitionDuration:info.duration withMatchMode:NvsVideoTransitionDurationMatchMode_None];
        }
    }
}

+ (void)resetTimelineFilter:(NvsTimeline *)timeline filterData:(NvTimeFilterInfoModel *)timelineFilterModel {
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    NvsVideoClip *firstClip = [videoTrack getClipWithIndex:0];
    NvsVideoClip *lastClip = [videoTrack getClipWithIndex:videoTrack.clipCount -1 ];
    
    //判断是不是主题片头、片尾数据
    int64_t timelineFilterStartPoint = 0;
    int64_t timelineFilterEndPoint = timeline.duration;
    if (firstClip.roleInTheme == NvsRoleInThemeTitle) {
        timelineFilterStartPoint = firstClip.outPoint;
    }
    if (lastClip.roleInTheme == NvsRoleInThemeTrailer) {
        timelineFilterEndPoint = lastClip.inPoint;
    }
    NvsTimelineVideoFx *nextFx = [timeline getFirstTimelineVideoFx];
    while (nextFx) {
        nextFx = [timeline removeTimelineVideoFx:nextFx];
    }

    if ([NvSDKUtils isBuiltinFilter:timelineFilterModel.name]) {
       NvsTimelineVideoFx *newTimelineFilter = [timeline addBuiltinTimelineVideoFx:timelineFilterStartPoint duration:timelineFilterEndPoint videoFxName:timelineFilterModel.name];
        [newTimelineFilter setFilterIntensity:timelineFilterModel.strength];
        if ([timelineFilterModel.name isEqualToString:@"Cartoon"]) {
            [newTimelineFilter setBooleanVal:@"Stroke Only" val:timelineFilterModel.strokeOnly];
            [newTimelineFilter setBooleanVal:@"Grayscale" val:timelineFilterModel.grayscale];
        }
    }else{
       NvsTimelineVideoFx *newTimelineFilter = [timeline addPackagedTimelineVideoFx:timelineFilterStartPoint duration:timelineFilterEndPoint videoFxPackageId:timelineFilterModel.name];
        [newTimelineFilter setFilterIntensity:timelineFilterModel.strength];
    }
    
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

+ (void)resetVideoFx:(NvsTimeline *)timeline videoFxDataArray:(NSArray *)videoFxDataArray timelineData:(NvTimelineData *)timelineData {
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    for (int i = 0; i < videoTrack.clipCount; i++) {
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        int fxCount = clip.fxCount;
        for (int j = 0; j < fxCount; j++) {
            NvsVideoFx *videoFx = [clip getFxWithIndex:j];
            NSString *name = [videoFx bultinVideoFxName];
            if([name isEqualToString:@"Mask Generator"] || [name isEqualToString:@"Transform 2D"] || [name isEqualToString:@"Color Property"] || [name isEqualToString:@"Sharpen"] || [name isEqualToString:@"Vignette"] || [name isEqualToString:@"BasicImageAdjust"] || [name isEqualToString:@"Tint"] || [name isEqualToString:@"Noise"] || [name isEqualToString:@"Storyboard"]) {
                continue;
            }
            [clip removeFx:j];
        }
    }
    // 根据编辑数据重新添加滤镜
    for (int i = 0; i < videoFxDataArray.count; i++) {
        NvTimeFilterInfoModel *info = (NvTimeFilterInfoModel *)videoFxDataArray[i];
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        //判断是不是主题片头数据
        __block BOOL isSrcVideoAsset = NO;
        [timelineData.editDataArray enumerateObjectsUsingBlock:^(NvEditDataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.localIdentifier isEqualToString:clip.filePath] || [obj.videoPath isEqualToString:clip.filePath]) {
                isSrcVideoAsset = YES;
            }
        }];
        if (!isSrcVideoAsset) {
            continue;
        }
        NvsVideoFx *fx;
        if ([NvSDKUtils isBuiltinFilter:info.name]) {
            
            fx = [clip appendBuiltinFx:info.name];
            [fx setFilterIntensity:info.strength];
            if ([info.name isEqualToString:@"Cartoon"]) {
                [fx setBooleanVal:@"Stroke Only" val:info.strokeOnly];
                [fx setBooleanVal:@"Grayscale" val:info.grayscale];
            }
            
        } else {
            fx = [clip appendPackagedFx:info.name];
            [fx setFilterIntensity:info.strength];
            
        }

    }
}

+ (void)resetKeyframesFilter:(NvsTimeline *)timeline timelineData:(NvTimelineData *)timelineData {
    NvsVideoTrack *track = [timeline getVideoTrackByIndex:0];
    for (int i=0; i<track.clipCount; i++) {
        NvEditDataModel *clipModel = timelineData.editDataArray[i];
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NSLog(@"滤镜关键帧数量%lu",(unsigned long)clipModel.filterKeyFrames.count);
        for (int k=0; k<clipModel.filterKeyFrames.count; k++) {
            NvKeyFrameFilterModel *model = clipModel.filterKeyFrames[k];
            if (clip.fxCount >0) {
                NvsVideoFx *fx = [clip getFxWithIndex:clip.fxCount-1];
                if(clipModel.trimOut >= model.time && clipModel.trimIn <= model.time) {
                    [fx setFloatValAtTime:model.fxParam val:model.value time:model.time - clipModel.trimIn];
                }else{
                    NSLog(@"时间错误");
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
        //曲线变速选择“无”
        return;
    }
    BOOL result = [clip changeCurvesVariableSpeed:bezierPoints keepAudioPitch:YES];
    if (!result) {
        NSLog(@"应用曲线变速失败");
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
        NSLog(@"splitClip失败");
        return NO;
    }
    
    if(![NvTimelineUtils splitClip:point+repeatDuration videotrack:track]) {
        NSLog(@"splitClip--point+repeatDuration--失败");
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
            
            //            [clip setImageMotionROI:&startROI endROI:&endROI];
            if (speed > 1) {
                [clip changeSpeed:speed keepAudioPitch:YES];
            } else {
                [clip changeSpeed:speed*1.5 keepAudioPitch:YES];
            }
            
            [clip setVolumeGain:0.0f rightVolumeGain:0.0f];
            [clip setExtraVideoRotation:rotation];
            //            if(bReverse)
            //                [clip setPlayInReverse:YES];
            
            clipIndex++;
        }
        
    }
    
    //超出时长移除
    [track removeRange:duration endTimelinePos:track.duration keepSpace:false];
    
    //    [NvTimelineUtils MuteVideoTrack:track];
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
    //慢动作前面的时间点快放
    for(int i = 0; i < precliplist.count; i++){
        NvsVideoClip* orgClip = precliplist[i];
        
        double speed = [orgClip getSpeed];
        [orgClip changeSpeed:speed * 2.0 keepAudioPitch:YES];
    }
    //慢动作后面的时间点快放
    for(int i = 0; i < aftercliplist.count; i++){
        NvsVideoClip* orgClip = aftercliplist[i];
        
        double speed = [orgClip getSpeed];
        [orgClip changeSpeed:speed * 2.0 keepAudioPitch:YES];
    }
    //超出时长移除
    if(duration < track.duration)
        [track removeRange:duration endTimelinePos:track.duration keepSpace:false];
    //mute all clips
    //    [NvTimelineUtils MuteVideoTrack:track];
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
    [context seekTimeline:timeline timestamp:atTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:0];
}

+ (void)playTimeline:(NvsTimeline *)timeline atTime:(int64_t)atTime {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    [context playbackTimeline:timeline startTime:atTime endTime:timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:0];
}

+ (NSArray *)getRegionWithRect:(CGRect)rect sceneWidth:(CGFloat)sceneWidth sceneHeight:(CGFloat)sceneHeight {
    CGFloat left = [NvTimelineUtils getRatioValue:rect.origin.x denValue:sceneWidth];
    CGFloat right = [NvTimelineUtils getRatioValue:CGRectGetMaxX(rect) denValue:sceneWidth];
    CGFloat top = [NvTimelineUtils getRatioValue:sceneHeight -rect.origin.y denValue:sceneHeight];
    CGFloat bottom = [NvTimelineUtils getRatioValue:sceneHeight -CGRectGetMaxY(rect) denValue:sceneHeight];
    NSArray *points = @[@(left),@(top),@(left),@(bottom),@(right),@(bottom),@(right),@(top)];
    return points;
}

//获取占比（范围：-1～1）
+ (CGFloat)getRatioValue:(CGFloat)num denValue:(CGFloat)den {
    CGFloat value = num/den;
    return value*2-1;
}

+ (NSString *)saveTimelineDataToFile:(NvTimelineData *)originModel {
    NSArray *compoundArr = originModel.compoundCaptionDataArray;
    NSData *jsonObject = [originModel yy_modelToJSONData];
    NSString *bundlePath = NV_TIMELINEDATA_SAVE_PATH;
    NSString *currentTime = [NvUtils currentDateAndTime];
    NSString *savePath = [[bundlePath stringByAppendingPathComponent:currentTime] stringByAppendingString:@".json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:bundlePath]) {
        [fileManager createDirectoryAtPath:bundlePath withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"创建文件");
    }
    
    BOOL result = [jsonObject writeToFile:savePath atomically:YES];
    if (result) {
        NSLog(@"保存成功%@",savePath);
    }else{
        NSLog(@"保存失败%@",savePath);
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

+ (void)resetPropertyBackgroundEffect:(NvsVideoClip *)clip model:(NvPropertyBackgroundEffectModel *)model {
    [clip setAttachment:model forKey:CLIP_PROPERTY_BACKGROUND_ATTACHMENT];
    if (![clip isPropertyVideoFxEnabled] && model.isUsePropertyEffect) {
        [clip enablePropertyVideoFx:YES];
    }

    NvsVideoFx *backgroundFx = [clip getPropertyVideoFx];
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
            NSLog(@"背景图片路径%@",model.imageFile);
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

//通过storyboard 设置背景模糊方法
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
//    if (model.scaleX > 1) {
//        blurScale *= model.scaleX;
//    }
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
    
}

//通过storyboard 设置背景颜色、背景图片方法
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


}

+ (float)getBackgroundScaleValue:(CGSize)timelineSize assetSize:(CGSize)assetSize {
    float timelineRatio = timelineSize.width * 1.0f / timelineSize.height;
    float fileRatio = assetSize.width * 1.0f / assetSize.height;
    float scale = 1.0f;
    if (fileRatio > timelineRatio) {//此时是宽对齐，需要高对齐
        float scaleBefore = timelineSize.width * 1.0F / assetSize.width;
        scale = timelineSize.height * 1.0F / (assetSize.height * scaleBefore);
    } else {//此时是高对齐，需要宽对齐
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
        NSLog(@"滤镜为空！");
    }
    return clipFilters;
}
@end

