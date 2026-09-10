//
//  NvMimoTimelineUtils.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/6/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMimoTimelineUtils.h"
#import "NvsVideoClip.h"
#import "NvsAudioClip.h"
#import "NvsTimelineCaption.h"
#import "NvsTimelineAnimatedSticker.h"
#import "NvsParticleSystemContext.h"
#import "NvsTimelineVideoFx.h"
#import "NvsStreamingContext.h"
#import "NvMimoUtils.h"
#import "NvsVideoFx.h"
#import "NVHeader.h"
#import "NvMimoSDKUtils.h"
#import "NvThemeModel.h"

@implementation NvMimoTimelineUtils

static NvMimoTimelineUtils *sharedInstance = nil;

+ (NvMimoTimelineUtils *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[NvMimoTimelineUtils alloc] init];
    });
    
    return sharedInstance;
}


+ (NvsTimeline *)createTimeline:(NvMimoEditMode)editMode {
    NvsStreamingContext *context = [NvsStreamingContext sharedInstance];
    NvsSize size = [NvMimoTimelineUtils calculateTimelineSize:editMode];
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
    [timeline appendAudioTrack];
    [timeline appendAudioTrack];
    return timeline;
}

+ (void)removeTimeline:(NvsTimeline *)timeline {
    NvsStreamingContext *context = [NvsStreamingContext sharedInstance];
    [context removeTimeline:timeline];
}

+ (NvsSize)calculateTimelineSize:(NvMimoEditMode)editMode {
    int compileRes = [NvMimoUtils compileResolutionSetting];
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
    } else if (editMode == NvEditMode2d39v1) {
        size.width = 1720;
        size.height = 720;
    } else if (editMode == NvEditMode2d55v1) {
        size.width = 1836;
        size.height = 720;
    }
    else {
        size.width = 1280;
        size.height = 720;
    }
    return size;
}

//处理用户选择素材
// handle user selection of assets
+ (void)arrangeVideoData:(NSMutableArray *)shotInfo dirPath:(NSString *)dirPath {
    //按照json文件要求修改时长(空镜头不用处理)
    // Change the duration as required by the json file (empty shots are not handled)
    for (int i=0; i<shotInfo.count; i++) {
        NvShotModel *editDataModel = shotInfo[i];
        if (editDataModel.source.length>0) {
            //空镜头视频
            // Empty shot video
            NSString *videoPath = [dirPath stringByAppendingPathComponent:editDataModel.source];
            editDataModel.videoPath = videoPath;
            editDataModel.isImage = NO;
            editDataModel.trimIn = 0;
            editDataModel.trimOut = editDataModel.duration;
           
        }else if(editDataModel.asset.asset.localIdentifier.length>0){
            //非剪辑不可进行赋值（用以区分"替换mode"）
            // Non-clips cannot be assigned (to distinguish "replace mode")
            if(editDataModel.trimOut<=0 || !editDataModel.trimOut){
                //用户可编辑镜头
                // User editable shot
                if (editDataModel.asset.asset.mediaType == PHAssetMediaTypeVideo) {
                    //选中资源为视频资源
                    // Select resource as video resource
                    [self arrangeVideoAsset:editDataModel];
                }else if (editDataModel.asset.asset.mediaType == PHAssetMediaTypeImage){
                    //选中资源为图片资源
                    // Select asset as image asset
                    [self arrangeImageAsset:editDataModel];
                    
                }
            }
        }
        
    }
}

//处理视频素材
// Process video footage
+ (void)arrangeVideoAsset:(NvShotModel *)editDataModel {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[PHImageManager defaultManager] requestAVAssetForVideo:editDataModel.asset.asset
                                                    options:options
                                              resultHandler:^(AVAsset * avAsset, AVAudioMix * audioMix, NSDictionary * info) {
        DLog(@"选择资源类型%@",[avAsset class]);
        
        if (avAsset && [avAsset isKindOfClass:[AVURLAsset class]]) {
            editDataModel.videoPath = editDataModel.asset.asset.localIdentifier;
            editDataModel.isImage = NO;
            editDataModel.trimIn = 0;
            editDataModel.trimOut = editDataModel.duration;
            editDataModel.assetDuration =avAsset.duration.value/(float)avAsset.duration.timescale*NV_TIME_BASE;
            if(editDataModel.duration > editDataModel.assetDuration) {
                editDataModel.trimOut = editDataModel.assetDuration;
                
            }
 
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

//处理图片素材
// Process the image asset
+ (void)arrangeImageAsset:(NvShotModel *)editDataModel {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = YES;
    [[PHImageManager defaultManager] requestImageForAsset:editDataModel.asset.asset
                                               targetSize:CGSizeMake(80, 80)
                                              contentMode:PHImageContentModeAspectFit
                                                  options:requestOptions
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL isIcloud =  [[info valueForKeyPath:@"PHImageResultIsInCloudKey"] boolValue];
        if (isIcloud) {
            
        } else {
            
            editDataModel.localIdentifier = editDataModel.asset.asset.localIdentifier;
            editDataModel.isImage = YES;
            editDataModel.trimIn = 0;
            editDataModel.isPhotoAlbum = YES;
            editDataModel.trimOut = editDataModel.duration;
            
        }
        dispatch_semaphore_signal(semaphore);
    }
     ];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

+ (void)recreateTimeline:(NvsTimeline *)timeline
{
    if (timeline == nil ) {
        return;
    }

    [timeline removeCurrentTheme];
    [timeline deleteWatermark];
    
    NvMimoTimelineData *timelineData = [NvMimoTimelineData sharedInstance];
    [NvMimoTimelineUtils resetEditData:timeline editDataArray:timelineData.editDataArray];
    
    NSMutableArray *order = [timelineData dataOrder];
    for (NSString *name in order) {
        if ([name isEqualToString:@"Music"]) {
            [NvMimoTimelineUtils resetMusicTrack:timeline musicDataArray:timelineData.musicDataArray];
        }
        if ([name isEqualToString:@"Dubbing"]) {
            [NvMimoTimelineUtils resetDubbingTrack:timeline dubbingModel:timelineData.dubbingModel];
        }
        if ([name isEqualToString:@"Filter"]) {
            [NvMimoTimelineUtils resetVideoFx:timeline videoFxDataArray:timelineData.videoFxDataArray];
        }
        if ([name isEqualToString:@"Sticker"]) {
            [NvMimoTimelineUtils resetSticker:timeline stickerDataArray:timelineData.stickerDataArray];
        }
        if ([name isEqualToString:@"Caption"]) {
            [NvMimoTimelineUtils resetCaption:timeline captionDataArray:timelineData.captionDataArray];
        }
        if ([name isEqualToString:@"Particle"]) {
            [NvMimoTimelineUtils resetParticle:timeline particleDataArray:timelineData.particleDataArray];
        }
        if ([name isEqualToString:@"Transition"]) {
            [NvMimoTimelineUtils resetTransition:timeline transitionDataArray:timelineData.transitionDataArray];
        }
        if ([name isEqualToString:@"Watermark"]) {
            [NvMimoTimelineUtils resetWatermark:timeline watermarkInfo:timelineData.watermarkInfo];
        }
        if ([name isEqualToString:@"Theme"]) {
            [NvMimoTimelineUtils resetTheme:timeline themeInfo:timelineData.themeInfo];
            [NvMimoTimelineUtils resetCaption:timeline captionDataArray:timelineData.captionDataArray];
        }
    }
}

+ (void)resetCaption:(NvsTimeline *)timeline captionDataArray:(NSArray *)captionDataArray {
    NvsTimelineCaption *nextCaption = [timeline getFirstCaption];
    do {
        DLog(@"-------%d,%d,%@",nextCaption.category,nextCaption.roleInTheme,nextCaption.getText);
        if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
            nextCaption = [timeline getNextCaption:nextCaption];
        }else{
            nextCaption = [timeline removeCaption:nextCaption];
        }
    } while (nextCaption);

    for (int i = 0; i < captionDataArray.count; i++) {
        NvMimoCaptionInfoModel * info = (NvMimoCaptionInfoModel *)captionDataArray[i];
        if (info.roleInTheme != NvsRoleInThemeGeneral && info.category == NvsThemeCategory) {
            continue;
        }
        NvsTimelineCaption* caption = [timeline addCaption:info.text inPoint:info.inPoint duration:info.outPoint - info.inPoint captionStylePackageId:info.styleId];
        [caption setAttachment:info forKey:@"captionInfoModel"];
        if(caption == nil){
            continue;
        }
        
        CGFloat r,g,b,a;
        if (info.colorString) {
            [[UIColor nv_colorWithHexARGB:info.colorString] getRed:&r green:&g blue:&b alpha:&a];
            NvsColor color = {r,g,b,info.alpha};
            [caption setTextColor:&color];
        }
        
        [caption setTextAlignment:info.alignment];
        
        [caption setCaptionTranslation:info.translation];
        
        [caption setScaleX:info.scale];
        [caption setScaleY:info.scale];
        [caption setRotationZ:info.rotation];
        if (info.isDrawOutline && info.outlineColorString) {
            [caption setDrawOutline:YES];
            CGFloat r,g,b,a;
            NSMutableArray *colors = [NvMimoUtils rgbWithColor:[UIColor nv_colorWithHexARGB:info.outlineColorString]];
            if (colors.count == 4) {
                r = [colors[0] integerValue]/255.0;
                g = [colors[1] integerValue]/255.0;
                b = [colors[2] integerValue]/255.0;
                a = info.outlineAlpha;
                NvsColor color = {r,g,b,a};
                [caption setOutlineColor:&color];
                [caption setOutlineWidth:info.outlineWidth];
            }
        } else {
            [caption setDrawOutline:NO];
        }
        if (info.isBold) {
            [caption setBold:YES];
        } else {
           [caption setBold:NO];
        }
        if (info.isItalic) {
            [caption setItalic:YES];
        } else {
            [caption setItalic:NO];
        }
        if (info.isDrawShadow) {
            [caption setDrawShadow:YES];
            NvsColor color = {0,0,0,0.5};
            [caption setShadowColor:&color];
            [caption setShadowOffset:CGPointMake(10, -10)];
        } else {
            [caption setDrawShadow:NO];
        }
        if (info.fontFilePath && ![info.fontFilePath isEqualToString:@""]) {
            [caption setFontWithFilePath:info.fontFilePath];
        } else {
            [caption setFontWithFilePath:@""];
        }
        
    }
}

+ (void)resetSticker:(NvsTimeline *)timeline stickerDataArray:(NSArray *)stickerDataArray{
    NvsTimelineAnimatedSticker *sticker = [timeline getFirstAnimatedSticker];
    while (sticker) {
        sticker = [timeline removeAnimatedSticker:sticker];
    }

    for (int i = 0; i < stickerDataArray.count; i++) {
        NvMimoStickerInfoModel *info = (NvMimoStickerInfoModel *)stickerDataArray[i];
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
        
        [sticker setTranslation:info.translation];
        [sticker setScale:info.scale];
        [sticker setRotationZ:info.rotation];
        [sticker setVolumeGain:info.volume rightVolumeGain:info.volume];
    }
}

+ (void)resetTheme:(NvsTimeline *)timeline themeInfo:(NvMimoThemeInfoModel *)themeInfo{
    [timeline removeCurrentTheme];
    [timeline applyTheme:themeInfo.themeName];
    NSMutableArray *musicDataArray = [[NvMimoTimelineData sharedInstance] musicDataArray];
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
    [timeline applyTheme:themeInfo.themeName];
}

+ (void)resetWatermark:(NvsTimeline *)timeline watermarkInfo:(NvMimoWatermarkInfoModel *)watermarkInfo{
    [timeline deleteWatermark];
    if (watermarkInfo.isCaf) {
        if ([NvMimoTimelineUtils sharedInstance].isVideoFx) {
            NvsTimelineVideoFx *videoFx = [timeline addBuiltinTimelineVideoFx:watermarkInfo.inPoint duration:watermarkInfo.outPoint videoFxName:@"Storyboard"];
            NSString *descString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><storyboard sceneWidth=\"Swidth\" sceneHeight=\"SHeight\"><track source=\"cafFile\" width=\"Nwidth\" height=\"Nheight\" clipStart=\"0\" clipDuration=\"2000\" repeat=\"true\"><effect name=\"transform\"><param name=\"opacity\" value=\"1\"/><param name=\"transX\" value=\"0\"/><param name=\"transY\" value=\"0\"/></effect></track></storyboard>"];
            
            descString = [descString stringByReplacingOccurrencesOfString:@"Swidth" withString:[NSString stringWithFormat:@"%d",(int)watermarkInfo.sceneWidth]];
            descString = [descString stringByReplacingOccurrencesOfString:@"SHeight" withString:[NSString stringWithFormat:@"%d",(int)watermarkInfo.sceneHeight]];
            descString = [descString stringByReplacingOccurrencesOfString:@"Nwidth" withString:[NSString stringWithFormat:@"%d",(int)watermarkInfo.displayWidth]];
            descString = [descString stringByReplacingOccurrencesOfString:@"Nheight" withString:[NSString stringWithFormat:@"%d",(int)watermarkInfo.displayHeight]];
            descString = [descString stringByReplacingOccurrencesOfString:@"cafFile" withString:[NSString stringWithFormat:@"%@.caf",watermarkInfo.imageUrl]];
            DLog(@"descString==%@",descString);
            [videoFx setStringVal:@"Resource Dir" val:WATEMARK_PATH];
            [videoFx setStringVal:@"Description String" val:descString];
            [videoFx setBooleanVal:@"Is Animated Sticker" val:true];
            [videoFx setFloatVal:@"Sticker TransX" val:watermarkInfo.marginX];
            [videoFx setFloatVal:@"Sticker TransY" val:watermarkInfo.marginY];
        }
    }else{
        NSString *path = [WATEMARK_PATH stringByAppendingPathComponent:[watermarkInfo.imageUrl stringByAppendingString:@".png"]];
        [timeline addWatermark:path displayWidth:watermarkInfo.displayWidth displayHeight:watermarkInfo.displayHeight opacity:watermarkInfo.opacity position:watermarkInfo.position marginX:watermarkInfo.marginX marginY:watermarkInfo.marginY];
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

    for (int i = 0; i < particleDataArray.count; i++) {
        NvMimoParticleInfoModel *info = (NvMimoParticleInfoModel *)particleDataArray[i];
        
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
        NvShotModel *editDataModel = editDataArray[i];
        CGFloat duration = editDataModel.isImage ? editDataModel.duration : editDataModel.assetDuration;
        NvsVideoClip *videoClip = [videoTrack appendClip:editDataModel.isImage ? editDataModel.localIdentifier : editDataModel.videoPath
                                                  trimIn:0
                                                 trimOut:duration];
        if (!videoClip) {
            continue;
        }

    }
}

+ (void)resetRegularEditData:(NvsTimeline *)timeline editDataArray:(NSArray *)editDataArray {
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    
    if (videoTrack == nil) {
        return;
    }
    [videoTrack removeAllClips];
    CGFloat duration;
    for (int i = 0; i < editDataArray.count; i++) {
        NvShotModel *editDataModel = editDataArray[i];
        if (editDataModel.speed.count>0) {
            duration = [NvMimoTimelineUtils requiredDurationForShotModel:editDataModel];
        }else{
            duration = editDataModel.duration;
        }
        NvsVideoClip *videoClip;
        if (!editDataModel.isImage && editDataModel.assetDuration < duration && editDataModel.source.length <= 0) {
            videoClip = [videoTrack appendClip:editDataModel.isImage ? editDataModel.localIdentifier : editDataModel.videoPath
                                        trimIn:editDataModel.trimIn
                                       trimOut:editDataModel.assetDuration];
            [videoClip changeSpeed:editDataModel.assetDuration/duration];
        }else{
            videoClip = [videoTrack appendClip:editDataModel.isImage ? editDataModel.localIdentifier : editDataModel.videoPath
                                        trimIn:editDataModel.trimIn
                                       trimOut:editDataModel.trimIn + duration];
        }

        if (!videoClip) {
            continue;
        }
    }
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

+ (void)resetMusicTrack:(NvsTimeline *)timeline musicDataArray:(NSArray<NvMimoMusicInfoModel *> *)musicDataArray {
    NvsAudioTrack *musicTrack = [timeline getAudioTrackByIndex:NV_MUSIC_SOUND_TRACK];
    [musicTrack removeAllClips];

    if ([musicDataArray count] > 0) {
        if ([musicDataArray count] == 1 && [(NvMimoMusicInfoModel *)musicDataArray[0] isBGM]) {
            NvMimoMusicInfoModel *musicInfo = musicDataArray[0];
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
                NvMimoMusicInfoModel *musicInfo = musicDataArray[i];
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
                            clip.fadeInDuration = NV_TIME_BASE;
                            clip.fadeOutDuration = NV_TIME_BASE;
                        }else{
                            if (j == 0) {
                                clip.fadeInDuration = NV_TIME_BASE;
                                clip.fadeOutDuration = 0;
                            }else if ((musicInfo.outPoint - musicInfo.inPoint)/(float)(musicInfo.trimOut - musicInfo.trimIn) - j < 1){
                                clip.fadeInDuration = 0;
                                clip.fadeOutDuration = NV_TIME_BASE;
                            }
                        }
                    }
                    [clip setVolumeGain:musicInfo.volume rightVolumeGain:musicInfo.volume];
                }
            }
        }
        [timeline setThemeMusicVolumeGain:0 rightVolumeGain:0];
    } else {
        if (![NvMimoUtils isStringEmpty:[timeline getCurrentThemeId]]) {
            NvMimoThemeInfoModel *themeInfo = [[NvMimoTimelineData sharedInstance] themeInfo];
            [timeline setThemeMusicVolumeGain:themeInfo.volume rightVolumeGain:themeInfo.volume];
        }
    }
   
}

+ (void)resetDubbingTrack:(NvsTimeline *)timeline dubbingModel:(NvMimoDubbingModel *)dubbingModel {
    NvsAudioTrack *audioTrack = [timeline getAudioTrackByIndex:NV_DUBBING_SOUND_TRACK];
    if (audioTrack == nil) {
        audioTrack = [timeline appendAudioTrack];
    }
    [audioTrack removeAllClips];
    for (int i = 0; i < dubbingModel.dubbingInfoModels.count; i++) {
        NvMimoDubbingInfoModel *dubbingDataModel = dubbingModel.dubbingInfoModels[i];
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
    [NvMimoTimelineUtils removeAllVideoTransitions:videoTrack];
    
    for (int i = 0; i < transitionDataArray.count; i++) {
        NvMimoTransitionInfoModel *info = transitionDataArray[i];
        if ([NvMimoUtils isStringEmpty:info.builtinName]) {
            [videoTrack setPackagedTransition:i withPackageId:info.packageId];
        } else {
            [videoTrack setBuiltinTransition:i withName:info.builtinName];
        }
    }
}

+ (void)resetVideoFx:(NvsTimeline *)timeline videoFxDataArray:(NSArray *)videoFxDataArray {
    
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    for (int i = 0; i < videoTrack.clipCount; i++) {
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        for (int j = 0; j < clip.fxCount; j++) {
            NvsVideoFx *videoFx = [clip getFxWithIndex:j];
            NSString *name = [videoFx bultinVideoFxName];
            if([name isEqualToString:@"Transform 2D"] || [name isEqualToString:@"Color Property"] || [name isEqualToString:@"Sharpen"] || [name isEqualToString:@"Vignette"]) {
                continue;
            }
            [clip removeFx:j];
            j--;
        }
    }
    for (int i = 0; i < videoFxDataArray.count; i++) {
        NvMimoTimeFilterInfoModel *info = (NvMimoTimeFilterInfoModel *)videoFxDataArray[i];
        if ([NvMimoSDKUtils isBuiltinFilter:info.name]) {
            for (int i = 0; i < videoTrack.clipCount; i++) {
                NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
                NvMimoTimelineData *timelineData = [NvMimoTimelineData sharedInstance];
                __block BOOL isSrcVideoAsset = NO;
                [timelineData.editDataArray enumerateObjectsUsingBlock:^(NvMimoEditDataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.localIdentifier isEqualToString:clip.filePath] || [obj.videoPath isEqualToString:clip.filePath]) {
                        isSrcVideoAsset = YES;
                    }
                }];
                if (!isSrcVideoAsset) {
                    continue;
                }
                
                NvsVideoFx *fx = [clip appendBuiltinFx:info.name];
                [fx setAbsoluteTimeUsed:true];
                [fx setFilterIntensity:info.strength];
                if ([info.name isEqualToString:@"Cartoon"]) {
                    [fx setBooleanVal:@"Stroke Only" val:info.strokeOnly];
                    [fx setBooleanVal:@"Grayscale" val:info.grayscale];
                }
            }
        } else {
            for (int i = 0; i < videoTrack.clipCount; i++) {
                NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
                NvMimoTimelineData *timelineData = [NvMimoTimelineData sharedInstance];
                __block BOOL isSrcVideoAsset = NO;
                [timelineData.editDataArray enumerateObjectsUsingBlock:^(NvMimoEditDataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.localIdentifier isEqualToString:clip.filePath] || [obj.videoPath isEqualToString:clip.filePath]) {
                        isSrcVideoAsset = YES;
                    }
                }];
                if (!isSrcVideoAsset) {
                    continue;
                }
                
                NvsVideoFx *fx = [clip appendPackagedFx:info.name];
                [fx setFilterIntensity:info.strength];
                [fx setAbsoluteTimeUsed:true];
            }
        }
    }
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
    
    if(![NvMimoTimelineUtils splitClip:point videotrack:track])
        return NO;
    
    if(![NvMimoTimelineUtils splitClip:point + NV_TIME_BASE videotrack:track])
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
        [NvMimoTimelineUtils splitClip:prePoint videotrack:track];
    }
    
    if((afterPoint + afterduration) < duration){
        //need split clips
        [NvMimoTimelineUtils splitClip:afterPoint + afterduration videotrack:track];
    }
    //splite clip
    NSMutableArray* cliplist = [NvMimoTimelineUtils getClipRange:point duration:NV_TIME_BASE videotrack:track];
    if(cliplist.count < 1)
        return NO;
    
    //pre clip
    
    NSMutableArray* precliplist = [NvMimoTimelineUtils getClipRange:prePoint duration:preduration videotrack:track];
    
    //after process
    
    NSMutableArray* aftercliplist = [NvMimoTimelineUtils getClipRange:afterPoint duration:afterduration videotrack:track];
    
    //
    for(int i = 0; i < cliplist.count; i++){
        NvsVideoClip* orgClip = cliplist[i];
        
        double speed = [orgClip getSpeed];
        [orgClip changeSpeed:speed / 2.0 keepAudioPitch:YES];
    }

    for(int i = 0; i < precliplist.count; i++){
        NvsVideoClip* orgClip = precliplist[i];

        double speed = [orgClip getSpeed];
        [orgClip changeSpeed:speed * 2.0 keepAudioPitch:YES];
    }

    for(int i = 0; i < aftercliplist.count; i++){
        NvsVideoClip* orgClip = aftercliplist[i];

        double speed = [orgClip getSpeed];
        [orgClip changeSpeed:speed * 2.0 keepAudioPitch:YES];
    }

    if(duration < track.duration)
        [track removeRange:duration endTimelinePos:track.duration keepSpace:false];
    //mute all clips
//    [NvMimoTimelineUtils MuteVideoTrack:track];
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

+ (int64_t)getClipInpoint:(NvsTimeline *)timeline clipInfo:(NvMimoEditDataModel *)clipInfo {
    NSMutableArray *editDataArray = [[NvMimoTimelineData sharedInstance] editDataArray];
    for (int i = 0; i < editDataArray.count; i++) {
        NvMimoEditDataModel *info = editDataArray[i];
        if ([info.uuid isEqualToString:clipInfo.uuid]) {
            NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
            NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
            return clip.inPoint;
        }
    }
    return 0;
}

+ (int64_t)getClipOutpoint:(NvsTimeline *)timeline clipInfo:(NvMimoEditDataModel *)clipInfo {
    NSMutableArray *editDataArray = [[NvMimoTimelineData sharedInstance] editDataArray];
    for (int i = 0; i < editDataArray.count; i++) {
        NvMimoEditDataModel *info = editDataArray[i];
        if ([info.uuid isEqualToString:clipInfo.uuid]) {
            NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
            NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
            return clip.outPoint;
        }
    }
    return 0;
}

+ (NvsVideoClip *)getTimelineVideoClip:(NvsTimeline *)timeline clipInfo:(NvMimoEditDataModel *)clipInfo {
    NSMutableArray *editDataArray = [[NvMimoTimelineData sharedInstance] editDataArray];
    for (int i = 0; i < editDataArray.count; i++) {
        NvMimoEditDataModel *info = editDataArray[i];
        if ([info.uuid isEqualToString:clipInfo.uuid]) {
            NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
            return [videoTrack getClipWithIndex:i];
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
    NvsStreamingContext *context = [NvsStreamingContext sharedInstance];
    [context seekTimeline:timeline timestamp:atTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

+ (void)playTimeline:(NvsTimeline *)timeline atTime:(int64_t)atTime {
    NvsStreamingContext *context = [NvsStreamingContext sharedInstance];
    [context playbackTimeline:timeline startTime:atTime endTime:-1 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

/**
 计算model真正需要的素材时长--针对镜头本身存在变速
 @return 返回结束时间点，而不是duration
 Calculate how long the model really needs - there is a variable speed for the shot itself
 @return Returns the end point, not duration
 */
+ (CGFloat)requiredDurationForShotModel:(NvShotModel *)model {
    //CGFloat trimIn = 0;
    CGFloat trimOut = 0;
    CGFloat speedDuration = 0;
    
    /*
     * 计算单个镜头各个分节速度model
     Each segment velocity model of a single shot is calculated
     */
    NSMutableArray *tmpSpeedArr = [NSMutableArray array];
    for (int m=0; m<model.speed.count; m++) {
        NvShotSpeedModel *speedModel =model.speed[m];
        if(speedModel.start != speedDuration){
            NvShotSpeedModel *regularSpeed = [NvShotSpeedModel new];
            regularSpeed.start = speedDuration;
            regularSpeed.end = speedModel.start;
            regularSpeed.speed0 = 1;
            regularSpeed.speed1 = 1;
            [tmpSpeedArr addObject:regularSpeed];
            speedDuration += regularSpeed.end - regularSpeed.start;
        }
        [tmpSpeedArr addObject:[speedModel copy]];
        speedDuration += speedModel.end - speedModel.start;
    }
    if (speedDuration < model.duration) {
        NvShotSpeedModel *regularSpeed = [NvShotSpeedModel new];
        regularSpeed.start = speedDuration;
        regularSpeed.end = model.duration;
        regularSpeed.speed0 = 1;
        regularSpeed.speed1 = 1;
        [tmpSpeedArr addObject:regularSpeed];
        speedDuration += regularSpeed.end - regularSpeed.start;
    }
    /*
     * 计算资源时长是否小于规定时长（速度全部转换为1的规定时长）
     Whether the duration of the computing resource is less than the specified time (the specified time when the speed is all converted to 1)
     */
    for (int n=0; n<tmpSpeedArr.count; n++) {
        NvShotSpeedModel *speedModel =tmpSpeedArr[n];
        CGFloat speed = (speedModel.speed0 + speedModel.speed1)/2;
        if (speed<1) {
            speed = 1;
        }
        trimOut += speed * (speedModel.end - speedModel.start);
    }
    return trimOut;
}

+ (NvMimoEditMode)editModeWithString:(NSString *)supportRatio {
    if ([supportRatio containsString:@"16v9"]) {
        return NvEditMode16v9;
    }else if ([supportRatio containsString:@"1v1"]) {
        return NvEditMode1v1;
    }else if ([supportRatio containsString:@"9v16"]) {
        return NvEditMode9v16;
    }else if ([supportRatio containsString:@"3v4"]) {
        return NvEditMode3v4;
    }else if ([supportRatio containsString:@"4v3"]) {
        return NvEditMode4v3;
    }else if ([supportRatio containsString:@"2d39v1"]) {
        return NvEditMode2d39v1;
    }else if ([supportRatio containsString:@"2d55v1"]) {
        return NvEditMode2d55v1;
    }
    return NvEditMode16v9;
}

+ (CGSize)liveWindowSizeWithEditMode:(NvMimoEditMode)editMode {
    CGFloat width = SCREANWIDTH;
    CGFloat height = SCREANWIDTH*9.0/16.0;
    if (editMode == NvEditMode16v9) {
        height = SCREANWIDTH*9.0/16.0;
    }else if (editMode == NvEditMode1v1) {
        height = SCREANWIDTH;
    }else if (editMode == NvEditMode9v16) {
        height = SCREANWIDTH*16.0/9.0;
    }else if (editMode == NvEditMode3v4) {
        height = SCREANWIDTH*4.0/3.0;
    }else if (editMode == NvEditMode4v3) {
        height = SCREANWIDTH*3.0/4.0;
    }else if (editMode == NvEditMode2d39v1) {
        height = SCREANWIDTH*1.0/2.39;
    }else if (editMode == NvEditMode2d55v1) {
        height = SCREANWIDTH*1.0/2.55;
    }
    CGSize size = CGSizeMake(width, height);
    return size;
}
@end
