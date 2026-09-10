//
//  NvMimoTimelineDataModel.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/6/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMimoTimelineDataModel.h"
#import "NvMimoUtils.h"

@implementation NvMimoEditDataModel

- (instancetype)init {
    self = [super init];
    self.isBlur = NO;
    self.speed = 1.f;
    self.volume = 1.f;
    self.uuid = [NvMimoUtils uuidString];
    self.rotation = 0;
    self.brightness = 1;
    self.saturation = 1;
    self.contrast = 1;
    self.scaleX = 1;
    self.scaleY = 1;
    self.pan = 0;
    self.scan = 0;
    self.motionMode = NvsStreamingEngineImageClipMotionMode_ROI;
    self.hasMotion = YES;
    self.isArea = YES;
    self.isDefault = NO;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvMimoEditDataModel *new = NvMimoEditDataModel.new;
    new.videoPath = self.videoPath;
    new.isBlur = self.isBlur;
    new.speed = self.speed;
    new.trimIn = self.trimIn;
    new.trimOut = self.trimOut;
    new.duration = self.duration;
    new.volume = self.volume;
    new.mute = self.mute;
    new.isImage = self.isImage;
    new.localIdentifier = self.localIdentifier;
    new.isPhotoAlbum = self.isPhotoAlbum;
    new.uuid = [NvMimoUtils uuidString];
    new.brightness = self.brightness;
    new.contrast = self.contrast;
    new.saturation = self.saturation;
    new.Sharpen = self.Sharpen;
    new.Vignette = self.Vignette;
    new.rotation = self.rotation;
    new.scaleX = self.scaleX;
    new.scaleY = self.scaleY;
    new.pan = self.pan;
    new.scan = self.scan;
    new.hasMotion = self.hasMotion;
    new.isArea = self.isArea;
    new.isDefault = self.isDefault;
    new.startRect = self.startRect;
    new.endRect = self.endRect;
    self.isLoading = self.isLoading;
    self.thumImage = self.thumImage;
    new.motionMode = self.motionMode;
    return new;
}

@end

@implementation NvMimoCaptionInfoModel
- (instancetype)init {
    self = [super init];
    self.scale = 1.f;
    self.alpha = 1;
    self.outlineAlpha = 1;
    self.translation = CGPointMake(0, 0);
    self.rotation = 0;
    self.anchorPoint = CGPointMake(0, 0);
    self.isDrawOutline = NO;
    self.uuid = [NvMimoUtils uuidString];
    return self;
}

- (NSMutableArray *) changeUIColorToRGB:(UIColor *)color
{
    NSMutableArray *RGBStrValueArr = [[NSMutableArray alloc] init];
    NSString *RGBStr = nil;
    NSString *RGBValue = [NSString stringWithFormat:@"%@",color];
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];
    int r = [[RGBArr objectAtIndex:1] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",r];
    [RGBStrValueArr addObject:RGBStr];
    int g = [[RGBArr objectAtIndex:2] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",g];
    [RGBStrValueArr addObject:RGBStr];
    int b = [[RGBArr objectAtIndex:3] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",b];
    [RGBStrValueArr addObject:RGBStr];
    
    int a = [[RGBArr objectAtIndex:4] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",a];
    [RGBStrValueArr addObject:RGBStr];
    return RGBStrValueArr;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    NvMimoCaptionInfoModel *model = [NvMimoCaptionInfoModel new];
    model.text = [[NSString alloc] initWithString:self.text];
    model.colorString = self.colorString?[NSString stringWithFormat:@"%@",self.colorString]:nil;
    model.alpha = self.alpha;
    model.anchorPoint = self.anchorPoint;
    model.rotation = self.rotation;
    model.scale = self.scale;
    model.translation = self.translation;
    model.uuid = [NvMimoUtils uuidString];
    model.category = self.category;
    if (!self.styleId) {
        model.styleId = nil;
    } else {
        model.styleId = [[NSString alloc] initWithString:self.styleId];
    }
    model.inPoint = self.inPoint;
    model.outPoint = self.outPoint;
    model.isDrawOutline = self.isDrawOutline;
    model.outlineColorString = self.outlineColorString?[[NSString alloc] initWithString:self.outlineColorString]:nil;
    model.outlineAlpha = self.outlineAlpha;
    model.outlineWidth = self.outlineWidth;
    if (!self.fontFilePath) {
        model.fontFilePath = nil;
    } else {
        model.fontFilePath = self.fontFilePath?[[NSString alloc] initWithString:self.fontFilePath]:nil;
    }
    model.alignment = self.alignment;
    model.isBold = self.isBold;
    model.isItalic = self.isItalic;
    model.isDrawShadow = self.isDrawShadow;
    return model;
}

@end

@implementation NvMimoStickerInfoModel

- (instancetype)init {
    self = [super init];
    self.scale = 1.f;
    self.rotation = 0;
    self.volume = 1;
    self.translation = CGPointMake(0, 0);
    self.anchor = CGPointMake(0, 0);
    self.uuid = [NvMimoUtils uuidString];
    self.isSlient = YES;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvMimoStickerInfoModel *new = NvMimoStickerInfoModel.new;
    new.scale = self.scale;
    new.rotation = self.rotation;
    new.uuid = [NvMimoUtils uuidString];
    new.translation = self.translation;
    new.anchor = self.anchor;
    new.packageId = self.packageId;
    new.inPoint = self.inPoint;
    new.outPoint = self.outPoint;
    new.isCustomSticer = self.isCustomSticer;
    new.customImagePath = self.customImagePath;
    new.isSlient = self.isSlient;
    new.volume = self.volume;
    
    return new;
}

@end

@implementation NvMimoParticleInfoModel
- (instancetype)init {
    self = [super init];
    self.particleRateValue = 1.f;
    self.particleSizeValue = 1.f;
    self.particleLocation = [[NSMutableArray alloc] init];
    self.emitterName = [[NSMutableArray alloc] init];
    self.uuid = [NvMimoUtils uuidString];
    return self;
}
@end

@implementation NvMimoTimeFilterInfoModel
- (instancetype)init {
    self = [super init];
    self.addInReverseMode = NO;
    self.isShortVideo = NO;
    self.uuid = [NvMimoUtils uuidString];
    self.strength = 1;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvMimoTimeFilterInfoModel *new = NvMimoTimeFilterInfoModel.new;
    new.addInReverseMode = self.addInReverseMode;
    new.isShortVideo = self.isShortVideo;
    new.uuid = [NvMimoUtils uuidString];
    new.inPoint = self.inPoint;
    new.outPoint = self.outPoint;
    new.name = [NSString stringWithFormat:@"%@",self.name];
    new.strength = self.strength;
    
    return new;
}
@end

@implementation NvMimoWatermarkInfoModel
- (instancetype)init {
    self = [super init];
    self.opacity = 1;
    self.position = 0;
    return self;
}
@end

@implementation NvMimoTransitionInfoModel
- (instancetype)init {
    self = [super init];
    self.uuid = [NvMimoUtils uuidString];
    self.builtinName = @"Fade";
    return self;
}
@end

@implementation NvMimoDubbingInfoModel
- (instancetype)init {
    self = [super init];
    self.volume = 1;
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    NvMimoDubbingInfoModel *model = [NvMimoDubbingInfoModel new];
    model.dubbingFilePath = [[NSString alloc] initWithString:self.dubbingFilePath];
    model.inPoint = self.inPoint;
    model.trimIn = self.trimIn;
    model.duration = self.duration;
    model.speed = self.speed;
    model.volume = self.volume;
    model.builtInFxName = self.builtInFxName;
    return model;
}

@end

@implementation NvMimoDubbingModel

- (instancetype)init {
    self = [super init];
    self.volume = 1;
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    NvMimoDubbingModel *model = [NvMimoDubbingModel new];
    model.volume = self.volume;
    model.dubbingInfoModels = [[NSMutableArray alloc] initWithArray:self.dubbingInfoModels copyItems:YES];
    return model;
}

@end

@implementation NvMimoMusicInfoModel

- (instancetype)init {
    self = [super init];
    self.isBGM = false;
    self.inPoint = 0;
    self.isFade = NO;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvMimoMusicInfoModel *new = NvMimoMusicInfoModel.new;
    new.musicPath = [NSString stringWithFormat:@"%@",self.musicPath];
    new.trimIn = self.trimIn;
    new.trimOut = self.trimOut;
    new.duration = self.duration;
    new.volume = self.volume;
    new.musicName = [NSString stringWithFormat:@"%@",self.musicName];
    new.musicAuthorName = [NSString stringWithFormat:@"%@",self.musicAuthorName];
    new.musicCoverImage = [UIImage imageWithCGImage:self.musicCoverImage.CGImage];
    new.isBGM = self.isBGM;
    new.isFade = self.isFade;
    return new;
}

@end

@implementation NvMimoThemeInfoModel
- (instancetype)init {
    self = [super init];
    self.volume = 1;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvMimoThemeInfoModel *new = NvMimoThemeInfoModel.new;
    new.volume = self.volume;
    new.themeName = [NSString stringWithFormat:@"%@",self.themeName];
    new.themeString = [NSString stringWithFormat:@"%@",self.themeString];
    new.thenmeRoleInTheme = self.thenmeRoleInTheme;
    return new;
}
@end
