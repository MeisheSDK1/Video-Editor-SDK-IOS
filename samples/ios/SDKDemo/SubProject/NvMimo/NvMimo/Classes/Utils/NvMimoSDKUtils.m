//
//  NvMimoSDKUtils.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMimoSDKUtils.h"
#import "NVMimoDefineConfig.h"
#import "NvMimoUtils.h"
#import <NvBaseCommon/NVDefineConfig.h>

@implementation NvMimoSDKUtils

+ (NvsStreamingContext *)getSDKContext {
    return [NvsStreamingContext sharedInstanceWithFlags:NvsStreamingContextFlag_Support4KEdit | NvsStreamingContextFlag_InterruptStopForInternalStop ];
}

+ (NSString *)getMoreTitleName:(AssetType )type {
    NSString *string = @"";
    switch (type) {
        case ASSET_THEME:
            string = NvLocalStringFromTable([self class], @"MoreTheme", @"更多主题");
            break;
        case ASSET_FILTER:
            string = NvLocalStringFromTable([self class], @"MoreFilter", @"更多滤镜");
            break;
        case ASSET_CAPTION_STYLE:
            string = NvLocalStringFromTable([self class], @"MoreCaptionStyle", @"更多字幕样式");
            break;
        case ASSET_COMPOUND_CAPTION:
            string = NvLocalStringFromTable([self class], @"MoreCompoundCaptionStyle", @"更多组合字幕样式");
            break;
        case ASSET_ANIMATED_STICKER:
            string = NvLocalStringFromTable([self class], @"MoreSticker", @"更多贴纸");
            break;
        case ASSET_CUSTOM_ANIMATED_STICKER:
            string = NvLocalStringFromTable([self class], @"MoreCustomStickerEffect", @"更多自定义效果");
            break;
        case ASSET_VIDEO_TRANSITION:
            string = NvLocalStringFromTable([self class], @"MoreTransition", @"更多转场");
            break;
        case ASSET_CAPTURE_SCENE:
            string = NvLocalStringFromTable([self class], @"MoreCaptionScence", @"更多拍摄场景");
            break;
        case ASSET_PARTICLE:
            string = NvLocalStringFromTable([self class], @"MoreParticle", @"更多粒子");
            break;
        case ASSET_FACE_STICKER:
            string = NvLocalStringFromTable([self class], @"MoreFaceSticker", @"更多人脸道具");
            break;
        case ASSET_FACE1_STICKER:
            string = NvLocalStringFromTable([self class], @"MoreFaceSticker", @"更多人脸道具");
            break;
        case ASSET_SUPERZOOM:
            string = NvLocalStringFromTable([self class], @"MoreSuperzoom", @"更多推镜特效");
            break;
        case ASSET_ARSCENE:
            string = NvLocalStringFromTable([self class], @"MoreFaceSticker", @"更多人脸道具");
            break;
        default:
            break;
    }
    return string;
}

+ (NSString *)getAssetAspectRatioString:(int)aspectRatio {
    if (aspectRatio == 127) {
        return @"通用";
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
        default:
            break;
    }
    return file;
}

+ (BOOL)isBuiltinFilter:(NSString *)filterName {
    if (!filterName) {
        DLog(@"滤镜名字为空%@",filterName);
    }
    NvsStreamingContext *context = [NvsStreamingContext sharedInstance];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[context getAllBuiltinVideoFxNames]];
    [array addObject:@"Video Echo"];
    [array addObject:@"Cartoon"];
    
    for (NSString *_Nullable str in array) {
        if (filterName == nil) {
            continue;
        }
        if ([str isEqualToString:filterName]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isBuiltinVideoTransition:(NSString *)videoTransition {
    if (videoTransition.length <= 0) {
        DLog(@"判断视频转场为空");
        return NO;
    }
    NvsStreamingContext *context = [NvsStreamingContext sharedInstance];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[context getAllBuiltinVideoTransitionNames]];
    
    for (NSString *_Nullable str in array) {
        if ([str isEqualToString:videoTransition]) {
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
    }
    return @"NvsFilterNone";
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
        return @"none";
    }else if (setting.intValue == 2){
        return @"st2084";
    }else if(setting.intValue == 3){
        return @"hlg";
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

@end
