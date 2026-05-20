//
//  NvSDKUtils.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvSDKUtils.h"
#import "NvUtils.h"
#import <NvBaseCommon/NSString+NvPath.h>
#define UnSupport4kLength 1920
@implementation NvSDKUtils

+ (NvsStreamingContext *)getSDKContext {
    int compileResolutionValue = [NvUtils compileResolutionSetting];
    if (compileResolutionValue > 1080) {
        return [NvsStreamingContext sharedInstanceWithFlags:NvsStreamingContextFlag_Support4KEdit | NvsStreamingContextFlag_InterruptStopForInternalStop | NvsStreamingContextFlag_NeedGifMotion];
    }
    return [NvsStreamingContext sharedInstance];
}

+ (NSString *)getSDKVersion {
    int large,minor,revision;
    [NvsStreamingContext getSdkVersion:&large minorVersion:&minor revisionNumber:&revision];
    return [NSString stringWithFormat:@"%d.%d.%d",large,minor,revision];
}

+ (NSString *)getMoreTitleName:(AssetType )type {
    NSString *string = @"";
    switch (type) {
        case ASSET_THEME:
            string = NvLocalString(@"MoreTheme", @"更多主题");
            break;
        case ASSET_FILTER:
            string = NvLocalString(@"MoreFilter", @"更多滤镜");
            break;
        case ASSET_CAPTION_STYLE:
            string = NvLocalString(@"MoreCaptionStyle", @"更多字幕样式");
            break;
        case ASSET_COMPOUND_CAPTION:
            string = NvLocalString(@"MoreCompoundCaptionStyle", @"更多组合字幕样式");
            break;
        case ASSET_ANIMATED_STICKER:
            string = NvLocalString(@"MoreSticker", @"更多贴纸");
            break;
        case ASSET_CUSTOM_ANIMATED_STICKER:
            string = NvLocalString(@"MoreCustomStickerEffect", @"更多自定义效果");
            break;
        case ASSET_VIDEO_TRANSITION:
            string = NvLocalString(@"MoreTransition", @"更多转场");
            break;
        case ASSET_CAPTURE_SCENE:
            string = NvLocalString(@"MoreCaptionScence", @"更多拍摄场景");
            break;
        case ASSET_PARTICLE:
            string = NvLocalString(@"MoreParticle", @"更多粒子");
            break;
        case ASSET_FACE_STICKER:
            string = NvLocalString(@"MoreFaceSticker", @"更多人脸道具");
            break;
        case ASSET_FACE1_STICKER:
            string = NvLocalString(@"MoreFaceSticker", @"更多人脸道具");
            break;
        case ASSET_SUPERZOOM:
            string = NvLocalString(@"MoreSuperzoom", @"更多推镜特效");
            break;
        case ASSET_ARSCENE:
            string = NvLocalString(@"MoreFaceSticker", @"更多人脸道具");
            break;
        default:
            break;
    }
    return string;
}

+ (AspectRatio)convertRatio:(NvEditMode)editMode {
    AspectRatio ratio;
    switch (editMode) {
        case NvEditMode16v9:
            ratio = AspectRatio_16v9;
            break;
        case NvEditMode1v1:
            ratio = AspectRatio_1v1;
            break;
        case NvEditMode9v16:
            ratio = AspectRatio_9v16;
            break;
        case NvEditMode3v4:
            ratio = AspectRatio_3v4;
            break;
        case NvEditMode4v3:
            ratio = AspectRatio_4v3;
            break;
        case NvEditMode18v9:
            ratio = AspectRatio_18v9;
            break;
        case NvEditMode9v18:
            ratio = AspectRatio_9v18;
            break;
        case NvEditMode2d39v1:
            ratio = AspectRatio_2d39v1;
            break;
        case NvEditMode2d55v1:
            ratio = AspectRatio_2d55v1;
            break;
        case NvEditMode21v9:
            ratio = AspectRatio_21v9;
            break;
        case NvEditMode9v21:
            ratio = AspectRatio_9v21;
            break;
        case NvEditMode7v6:
            ratio = AspectRatio_7v6;
            break;
        case NvEditMode6v7:
            ratio = AspectRatio_6v7;
            break;
        default:
            ratio = AspectRatio_All;
            break;
    }
    return ratio;
}

+ (NSString *)getAssetAspectRatioString:(int)aspectRatio {
    if (aspectRatio == 2047) {
        return NvLocalString(@"General", nil);
    }
    NSString *string = @"";
    if ((aspectRatio&AspectRatio_9v16) == AspectRatio_9v16) {
        string = [string stringByAppendingString:@"9v16,"];
    }
    if ((aspectRatio&AspectRatio_16v9) == AspectRatio_16v9) {
        string = [string stringByAppendingString:@"16v9,"];
    }
    if ((aspectRatio&AspectRatio_3v4) == AspectRatio_3v4) {
        string = [string stringByAppendingString:@"3v4,"];
    }
    if ((aspectRatio&AspectRatio_4v3) == AspectRatio_4v3) {
        string = [string stringByAppendingString:@"4v3,"];
    }
    if ((aspectRatio&AspectRatio_1v1) == AspectRatio_1v1) {
        string = [string stringByAppendingString:@"1v1,"];
    }
    if ((aspectRatio&AspectRatio_18v9) == AspectRatio_18v9) {
        string = [string stringByAppendingString:@"18v9,"];
    }
    if ((aspectRatio&AspectRatio_9v18) == AspectRatio_9v18) {
        string = [string stringByAppendingString:@"9v18,"];
    }
    if ((aspectRatio&AspectRatio_2d39v1) == AspectRatio_2d39v1) {
        string = [string stringByAppendingString:@"2d39v1,"];
    }
    if ((aspectRatio&AspectRatio_2d55v1) == AspectRatio_2d55v1) {
        string = [string stringByAppendingString:@"2d55v1,"];
    }
    if ((aspectRatio&AspectRatio_9v21) == AspectRatio_9v21) {
        string = [string stringByAppendingString:@"9v21,"];
    }
    if ((aspectRatio&AspectRatio_21v9) == AspectRatio_21v9) {
        string = [string stringByAppendingString:@"21v9,"];
    }
    if (string && string.length != 0) {
        [string substringToIndex:string.length - 1];
    }
    return string;
}

+ (NSString *)getAssetPackageSizeString:(int)packageSize {
    if (packageSize < 1024) {
        return [NSString stringWithFormat:@"<1KB"];
    } else if (packageSize >= 1024 && packageSize < 1024*1024) {
        return [NSString stringWithFormat:@"%dKB", packageSize/1024];
    } else if (packageSize >= 1024*1024 && packageSize < 1024*1024*1024) {
        return [NSString stringWithFormat:@"%.2fMB", (float)packageSize/(1024*1024)];
    } else {
        return [NSString stringWithFormat:@">1GB"];
    }
}

+ (NSString *)getAssetDownloadPath {
    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH];
    if (![[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:file withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return file;
}

+ (NSString *)getAssetDownloadPath:(AssetType)assetType {
    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH];
    if (![[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:file withIntermediateDirectories:YES attributes:nil error:nil];
    }
    switch (assetType) {
        case ASSET_THEME: {
            NSString *theme = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_THEME];
            if (![[NSFileManager defaultManager] fileExistsAtPath:theme isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:theme withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return theme;
        }
        case ASSET_FILTER: {
            NSString *filter = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_FILTER];
            if (![[NSFileManager defaultManager] fileExistsAtPath:filter isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:filter withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return filter;
        }
        case ASSET_CAPTION_STYLE: {
            NSString *caption = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_CAPTION];
            if (![[NSFileManager defaultManager] fileExistsAtPath:caption isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:caption withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return caption;
        }
        case ASSET_CAPTION_RENDERER: {
            NSString *caption = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_CAPTION_RENDERER];
            if (![[NSFileManager defaultManager] fileExistsAtPath:caption isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:caption withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return caption;
        }
        case ASSET_CAPTION_CONTEXT: {
            NSString *caption = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_CAPTION_CONTEXT];
            if (![[NSFileManager defaultManager] fileExistsAtPath:caption isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:caption withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return caption;
        }
        case ASSET_CAPTION_ANIMATION: {
            NSString *caption = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_CAPTION_ANIMATION];
            if (![[NSFileManager defaultManager] fileExistsAtPath:caption isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:caption withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return caption;
        }
        case ASSET_CAPTION_INANIMATION: {
            NSString *caption = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_CAPTION_INANIMATION];
            if (![[NSFileManager defaultManager] fileExistsAtPath:caption isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:caption withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return caption;
        }
        case ASSET_CAPTION_OUTANIMATION: {
            NSString *caption = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_CAPTION_OUTANIMATION];
            if (![[NSFileManager defaultManager] fileExistsAtPath:caption isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:caption withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return caption;
        }
        case ASSET_COMPOUND_CAPTION: {
            NSString *compoundCaption = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_COMPOUND_CAPTION];
            if (![[NSFileManager defaultManager] fileExistsAtPath:compoundCaption isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:compoundCaption withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return compoundCaption;
        }
        case ASSET_ANIMATED_STICKER: {
            NSString *animatedSticker = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_ANIMATEDSTICKER];
            if (![[NSFileManager defaultManager] fileExistsAtPath:animatedSticker isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:animatedSticker withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return animatedSticker;
        }
        case ASSET_VIDEO_TRANSITION: {
            NSString *transition = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_TRANSITION];
            if (![[NSFileManager defaultManager] fileExistsAtPath:transition isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:transition withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return transition;
        }
        case ASSET_CAPTURE_SCENE: {
            NSString *captureScene = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_CAPTURE_SCENE];
            if (![[NSFileManager defaultManager] fileExistsAtPath:captureScene isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:captureScene withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return captureScene;
        }
        case ASSET_FONT: {
            NSString *font = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_FONT];
            if (![[NSFileManager defaultManager] fileExistsAtPath:font isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:font withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return font;
        }
        case ASSET_PARTICLE: {
            NSString *particle = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_PARTICLE];
            if (![[NSFileManager defaultManager] fileExistsAtPath:particle isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:particle withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return particle;
        }
        case ASSET_FACE_STICKER: {
            NSString *faceSticker = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_FACE_STICKER];
            if (![[NSFileManager defaultManager] fileExistsAtPath:faceSticker isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:faceSticker withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return faceSticker;
        }
        case ASSET_CUSTOM_ANIMATED_STICKER: {
            NSString *customSticker = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_CUSTOM_ANIMATED_STICKER];
            if (![[NSFileManager defaultManager] fileExistsAtPath:customSticker isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:customSticker withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return customSticker;
        }
        case ASSET_FACE1_STICKER: {
            NSString *face1Sticker = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_FACE1_STICKER];
            if (![[NSFileManager defaultManager] fileExistsAtPath:face1Sticker isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:face1Sticker withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return face1Sticker;
        }
        case ASSET_SUPERZOOM: {
            NSString *superzoom = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_SUPERZOOM];
            if (![[NSFileManager defaultManager] fileExistsAtPath:superzoom isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:superzoom withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return superzoom;
        }
        case ASSET_ARSCENE: {
            NSString *arscene = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_ARSCENE];
            if (![[NSFileManager defaultManager] fileExistsAtPath:arscene isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:arscene withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return arscene;
        }
        case ASSET_ANIMATION_IN: {
            NSString *animation = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_ANIMATIONIN];
            if (![[NSFileManager defaultManager] fileExistsAtPath:animation isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:animation withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return animation;
        }
        case ASSET_ANIMATION_OUT: {
            NSString *animation = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_ANIMATIONOUT];
            if (![[NSFileManager defaultManager] fileExistsAtPath:animation isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:animation withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return animation;
        }
        case ASSET_ANIMATION_COMBINE: {
            NSString *animation = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_ANIMATIONCOMBINE];
            if (![[NSFileManager defaultManager] fileExistsAtPath:animation isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:animation withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return animation;
        }
        case ASSET_STICKER_ANIMATION: {
            NSString *animation = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_STICKERANIMATIONCOMBINE];
            if (![[NSFileManager defaultManager] fileExistsAtPath:animation isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:animation withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return animation;
        }
        case ASSET_STICKER_INANIMATION: {
            NSString *animation = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_STICKERANIMATIONIN];
            if (![[NSFileManager defaultManager] fileExistsAtPath:animation isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:animation withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return animation;
        }
        case ASSET_STICKER_OUTANIMATION: {
            NSString *animation = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_STICKERANIMATIONOUT];
            if (![[NSFileManager defaultManager] fileExistsAtPath:animation isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:animation withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return animation;
        }
        case ASSET_MAKEUP: {
            NSString *makeup = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_MAKEUP];
            if (![[NSFileManager defaultManager] fileExistsAtPath:makeup isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:makeup withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return makeup;
        }
        case ASSET_BEAUTY_TEMPLATE: {
            NSString *beautyTemplate = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_BEAUTY_TEMPLATE];
            if (![[NSFileManager defaultManager] fileExistsAtPath:beautyTemplate isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:beautyTemplate withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return beautyTemplate;
        }
            
        default:
            break;
    }
    return file;
}

#pragma mark 创建一个clip特效
///Create a clip effect
+ (NvsVideoFx *)createClipVideoFx:(NSString *)string withClip:(NvsVideoClip *)clip{
    if ([self checkString:string] && clip) {
        if ([string isEqualToString:@"AR Scene"]){
            NvsVideoFx *fx = [clip insertRawBuiltinFx:string fxIndex:0];
            [fx setAbsoluteTimeUsed:true];
            return fx;
        }
        NvsVideoFx *fx = [clip insertBuiltinFx:string fxIndex:0];
        if (!fx) {
            fx = [clip appendPackagedFx:string];
        }
        [fx setAbsoluteTimeUsed:true];
        return fx;
    }
    return nil;
}

#pragma mark 获取片段上的某个特效
///Gets a special effect on the clip
+ (NvsVideoFx *)getClipVideoFx:(NSString *)string withClip:(NvsVideoClip *)clip{
    if ([self checkString:string] && clip) {
        NvsVideoFx *fx;
        if ([string isEqualToString:@"AR Scene"]){
            for (int i = 0; i < clip.getRawFxCount; i++) {
                NvsVideoFx *tempFx = [clip getRawFxByIndex:i];
                if ([tempFx.bultinVideoFxName isEqualToString:string] || [tempFx.videoFxPackageId isEqualToString:string]) {
                    fx = tempFx;
                    break;
                }
            }
        }else{
            for (int i = 0; i < clip.fxCount; i++) {
                NvsVideoFx *tempFx = [clip getFxWithIndex:i];
                if ([tempFx.bultinVideoFxName isEqualToString:string] || [tempFx.videoFxPackageId isEqualToString:string]) {
                    fx = tempFx;
                    break;
                }
            }
        }
        
        return fx;
    }
    return nil;
}

#pragma mark 检查字符串的有效性
///Check the validity of the string
+ (BOOL)checkString:(NSString *)string{
    if (string && string.length != 0) {
        return YES;
    }
    return NO;
}


+ (BOOL)isBuiltinFilter:(NSString *)filterName {
    if (!filterName) {
        return NO;
    }
    NvsStreamingContext *context = [NvsStreamingContext sharedInstance];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[context getAllBuiltinVideoFxNames]];
    [array addObject:@"Video Echo"];
    [array addObject:@"Cartoon"];
    
    for (NSString *_Nullable str in array) {
        if ([str isEqualToString:filterName]) {
            return YES;
        }
    }
    return NO;
}

+ (int)getAssetVersionWithPath:(NSString *)path {
    NSArray *array = [path componentsSeparatedByString:@"/"];
    if (array.count > 0) {
        NSString *filename = [array lastObject];
        NSArray *arr = [filename componentsSeparatedByString:@"."];
        if (arr.count == 3) {
            return [(NSString *)arr[1] intValue];
        } else {
            return 1;
        }
    } else {
        return 1;
    }
}

+ (NSString *)getColorWithIndex:(NSInteger)index {
    NSArray *array = [NvUtils captionColors];
    if (index < array.count) {
        return array[index];
    }
    unsigned long idx = array.count % index;
    return array[idx-1];
}

+ (NSString *)getEffectColor:(NSString *)fxUUID {
    NSString *packagePath = [[NSBundle mainBundle] pathForResource:@"shortVideoPackage" ofType:@"bundle"];
    NSString *jsonPath = [packagePath stringByAppendingPathComponent:@"fx.json"];
    NSString *jsontext = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
    NSData *data =[jsontext dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    for (int i = 0; i < array.count; i++) {
        NSDictionary *dic = array[i];
        if ([fxUUID isEqualToString:dic[@"fxid"]]) {
            return dic[@"color"];
        }
    }
    return @"FCB600";
}

+ (int64_t)getVideoDuration:(NSString *)path {
    NvsStreamingContext *context = [NvsStreamingContext sharedInstance];
    NvsAVFileInfo *fileInfo = [context getAVFileInfo:path];
    return fileInfo.duration;
}

+ (NSString *)getTransitionsCoverName:(NSString *)fxUUID {
    if ([fxUUID isEqualToString:@"Fade"]) {
        return @"fade";
    } else if ([fxUUID isEqualToString:@"Turning"]) {
        return @"turning";
    } else if ([fxUUID isEqualToString:@"Swap"]) {
        return @"swap";
    } else if ([fxUUID isEqualToString:@"Stretch In"]) {
        return @"stretch_in";
    } else if ([fxUUID isEqualToString:@"Page Curl"]) {
        return @"page_curl";
    } else if ([fxUUID isEqualToString:@"Lens Flare"]) {
        return @"lens_flare";
    } else if ([fxUUID isEqualToString:@"Star"]) {
        return @"star";
    } else if ([fxUUID isEqualToString:@"Dip To Black"]) {
        return @"dip_to_black";
    } else if ([fxUUID isEqualToString:@"Dip To White"]) {
        return @"dip_to_white";
    } else if ([fxUUID isEqualToString:@"Push To Right"]) {
        return @"push_to_right";
    } else if ([fxUUID isEqualToString:@"Push To Top"]) {
        return @"push_to_left";
    } else if ([fxUUID isEqualToString:@"Upper Left Into"]) {
        return @"upper_left_into";
    } else if ([fxUUID isEqualToString:@"theme"]) {
        return @"NvEditTheme";
    }
    return @"NvsFilterNone";
}

+ (NvsTimeline *)createTimeline:(NvEditMode)editMode {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    NvsSize size = [NvSDKUtils calculateTimelineSize:editMode];
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
    ///音乐轨道
    ///Musical track
    [timeline appendAudioTrack];
    ///配音轨道
    ///Dubbing track
    [timeline appendAudioTrack];
    return timeline;
}

#pragma mark - 获取timeline要设置的size
/*
 获取timeline要设置的size
 Get the size to be set by the timeline
 
 @param editMode 比例  proportion
 
 */
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
    return size;
}

+ (NvsLiveWindowHDRDisplayMode)liveWindowModelSetting {
    NSNumber *setting = NV_UserInfo(@"NvLiveWindowModel");
    NvsLiveWindowHDRDisplayMode displayMode = NvsLiveWindowHDRDisplayMode_SDR;
    if (setting!=nil){
        switch (setting.intValue) {
            case 1:
                displayMode = NvsLiveWindowHDRDisplayMode_SDR;
                break;
            case 3:
                displayMode = NvsLiveWindowHDRDisplayMode_TONE_MAP_SDR;
                break;
            case 4:
                displayMode = NvsLiveWindowHDRDisplayMode_Device;
                break;
            default:
                break;
        }
    }
    return displayMode;
}

+ (NvsVideoResolutionBitDepth)resolutionModelSetting {
    NSNumber *setting = NV_UserInfo(@"NvResolutionConfiguration");
    NvsVideoResolutionBitDepth depth = NvsVideoResolutionBitDepth_8Bit;
    if (setting!=nil){
        switch (setting.intValue) {
            case 1:
                depth = NvsVideoResolutionBitDepth_8Bit;
                break;
            case 2:
                depth = NvsVideoResolutionBitDepth_16Bit_Float;
                break;
            case 3:
                depth = NvsVideoResolutionBitDepth_Auto;
                break;
                
            default:
                break;
        }
    }
    return depth;
}

+ (NSString *)exportModelSetting {
    NSNumber *setting = NV_UserInfo(@"NvExportConfiguration");
    if (setting.intValue == 1) {
        return @"";
    } else if (setting.intValue == 2){
        return @"st2084";
    } else if(setting.intValue == 3){
        return @"hlg";
    } else if(setting.intValue == 4){
        return @"hlg dolby vision";
    }
    return @"none";
}

+ (NSString *)hevcModelSetting {
    NSNumber *setting = NV_UserInfo(@"NvHEVCModel");
    if (setting.intValue == 1) {
        return @"hevc";
    }
    return @"";
}


+(NSString *)getSdkVersion{
    int large,minor,revision;
    [NvsStreamingContext getSdkVersion:&large minorVersion:&minor revisionNumber:&revision];
    return [NSString stringWithFormat:@"%d.%d.%d",large,minor,revision];
}

+ (NSMutableString *)reInstallAssetPackage:(NSString *)path license:(NSString * __nullable)licensePath assetType:(NvsAssetPackageType)assetType {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    [context.assetPackageManager uninstallAssetPackage:path type:assetType];
    return [NvSDKUtils installAssetPackage:path license:licensePath assetType:assetType];
}

+ (NSMutableString *)installAssetPackage:(NSString *)path license:(NSString *)licensePath assetType:(NvsAssetPackageType)assetType {
    
    if (!path || path.length == 0) {
        return nil;
    }
    if (!licensePath || licensePath.length == 0){
        
        licensePath = [NSString convertFilePathToNewPath:path WithExtension:@"lic"];
    }
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    NSMutableString *sceneId = [[NSMutableString alloc] init];
    NvsAssetPackageManagerError error = [context.assetPackageManager installAssetPackage:path license:licensePath type:assetType sync:YES assetPackageId:sceneId];
    if (error != NvsAssetPackageManagerError_AlreadyInstalled && error != NvsAssetPackageManagerError_NoError) {
        NSLog(@"安装素材失败！！！ Failed to install material!!");
    }else if (error == NvsAssetPackageManagerError_AlreadyInstalled) {
        [context.assetPackageManager upgradeAssetPackage:path license:licensePath type:assetType sync:YES assetPackageId:sceneId];
    }
    return sceneId;
}
@end
