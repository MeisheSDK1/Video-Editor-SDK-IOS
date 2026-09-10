//
//  NvTimelineDataModel.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/6/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvTimelineDataModel.h"
#import <NvSDKCommon/NvUtils.h>
#import "YYModel.h"

@implementation NvPropertyBackgroundEffectModel
- (instancetype)init {
    if (self = [super init]) {
        self.colorA = 1.f;
        self.scaleX = 1;
        self.scaleY = 1;
        self.opacity = 1;
        self.isUseBackgroudEffect = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvPropertyBackgroundEffectModel *new = [NvPropertyBackgroundEffectModel new];
    new.isUseBackgroudEffect = self.isUseBackgroudEffect;
    new.colorR = self.colorR;
    new.colorG = self.colorG;
    new.colorB = self.colorB;
    new.colorA = self.colorA;
    new.radius = self.radius;
    new.imageFile = self.imageFile.length>0 ? [NSString stringWithFormat:@"%@",self.imageFile] : nil;
    new.backgroundCategory = self.backgroundCategory;
    new.transformX = self.transformX;
    new.transformY = self.transformY;
    new.scaleX = self.scaleX;
    new.scaleY = self.scaleY;
    new.rotation = self.rotation;
    new.opacity = self.opacity;
    new.anchorX = self.anchorX;
    new.anchorY = self.anchorY;
    new.isSelected = self.isSelected;

    return new;
}
@end

@implementation NvKeyFrameFilterModel

- (instancetype)init {
    self = [super init];
    self.value = 1.0;
    self.time = 0;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvKeyFrameFilterModel *model = [NvKeyFrameFilterModel new];
    if (!self.packageId) {
        model.packageId = nil;
    } else {
        model.packageId = [[NSString alloc] initWithString:self.packageId];
    }
    if (!self.fxParam) {
        model.fxParam = nil;
    } else {
        model.fxParam = [[NSString alloc] initWithString:self.fxParam];
    }
    if (!self.name) {
        model.name = nil;
    } else {
        model.name = [[NSString alloc] initWithString:self.name];
    }
    model.isBuiltIn = self.isBuiltIn;
    model.value = self.value;
    model.time = self.time;
    model.strokeOnly = self.strokeOnly;
    model.grayscale = self.grayscale;
    return model;
}

@end

@implementation NvKeyFrameStickerModel

- (instancetype)init {
    self = [super init];
    self.time = 0;
    self.pos = 0;
    self.anchor = CGPointZero;
    self.rotation = 0;
    self.scale = 1;
    self.translation = CGPointZero;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvKeyFrameStickerModel *model = [NvKeyFrameStickerModel new];
    model.time = self.time;
    model.pos = self.pos;
    model.anchor = self.anchor;
    model.rotation = self.rotation;
    model.scale = self.scale;
    model.translation = self.translation;
    return model;
}

@end

@implementation NvEditDataModel

- (instancetype)init {
    self = [super init];
    self.isBlur = NO;
    self.speed = 1.f;
    self.volume = 1.f;
    self.audioNoiseSuppressionLevel = 0.f;
    self.uuid = [NvUtils uuidString];
    self.rotation = 0;
    self.brightness = 0;
    self.saturation = 0;
    self.contrast = 0;
    
    self.highlight = 0;
    self.shadow = 0;
    self.temperature = 0;
    self.tint = 0;
    self.blackpoint = 0;
    self.intensity = 0.0;
    self.density = 0.0;
    self.grayscale = YES;
    self.Sharpen = 0;
    self.Vignette = 0;
    
    self.scaleX = 1;
    self.scaleY = 1;
    self.pan = 0;
    self.scan = 0;
    self.motionMode = NvsStreamingEngineImageClipMotionMode_ROI;
    self.hasMotion = YES;
    self.isArea = YES;
    self.isDefault = NO;
    self.musicStartPos = 0;
    self.musicEndPos = 0;
    self.asset = [PHAsset new];
    self.filterKeyFrames = [NSMutableArray array];
    self.backgroundEffectModel = [NvPropertyBackgroundEffectModel new];
    self.animationInfoModel = [NvAnimationInfoModel new];
    self.maskInfoModel = [[NvMaskModel alloc] init];
    self.curveSpeeds = [NSMutableArray array];
    self.keyFramesArray = [NSMutableArray array];
    self.captionDataArray = [NSMutableArray array];
    self.stickerDataArray = [NSMutableArray array];
    self.keepAudioPitchNormalChangeSpeed = YES;
    self.sourceInfo = [[NvSourceInfo alloc] init];
    self.cropperModel = [[NvCropperModel alloc] init];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvEditDataModel *new = NvEditDataModel.new;
    new.musicEndPos = self.musicEndPos;
    new.musicStartPos = self.musicStartPos;
    new.asset = self.asset;
    new.videoPath = self.videoPath;
    new.isBlur = self.isBlur;
    new.speed = self.speed;
    new.trimIn = self.trimIn;
    new.trimOut = self.trimOut;
    new.duration = self.duration;
    new.volume = self.volume;
    new.audioNoiseSuppressionLevel = self.audioNoiseSuppressionLevel;
    new.mute = self.mute;
    new.isImage = self.isImage;
    new.localIdentifier = self.localIdentifier;
    new.isPhotoAlbum = self.isPhotoAlbum;
    new.uuid = [NvUtils uuidString];
    new.brightness = self.brightness;
    new.contrast = self.contrast;
    new.saturation = self.saturation;
    new.Sharpen = self.Sharpen;
    new.Vignette = self.Vignette;
    
    new.highlight = self.highlight;
    new.shadow = self.shadow;
    new.temperature = self.temperature;
    new.tint = self.tint;
    new.blackpoint = self.blackpoint;
    new.intensity = self.intensity;
    new.density = self.density;
    new.grayscale = self.grayscale;
    
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
    NSArray *arr = [[NSArray alloc] initWithArray:self.filterKeyFrames copyItems:YES];
    new.filterKeyFrames = [NSMutableArray arrayWithArray:arr];
    NSArray *captionArr = [[NSArray alloc] initWithArray:self.captionDataArray copyItems:YES];
    new.captionDataArray = [NSMutableArray arrayWithArray:captionArr];
    NSArray *stickerArr = [[NSArray alloc] initWithArray:self.stickerDataArray copyItems:YES];
    new.stickerDataArray = [NSMutableArray arrayWithArray:stickerArr];
    NSArray *volumeArr = [[NSArray alloc] initWithArray:self.keyFramesArray copyItems:YES];
    new.keyFramesArray = [NSMutableArray arrayWithArray:volumeArr];
    new.backgroundEffectModel = [self.backgroundEffectModel copy];
    new.animationInfoModel = [self.animationInfoModel copy];
    new.maskInfoModel = [self.maskInfoModel copyModel];
    NSArray *curveSpeeds = [[NSArray alloc] initWithArray:self.curveSpeeds copyItems:YES];
    new.curveSpeeds = [NSMutableArray arrayWithArray:curveSpeeds];
    new.curveSpeedsId = self.curveSpeedsId;
    new.keepAudioPitchNormalChangeSpeed = self.keepAudioPitchNormalChangeSpeed;
    
    new.cropperModel = [self.cropperModel modelCopy];
    new.sourceInfo = [self.sourceInfo copy];
    return new;
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"videoPath" : @[@"videoPath",@"recordingPath"],
        @"rotation" : @[@"rotation",@"rotaion"],
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"filterKeyFrames" : [NvKeyFrameFilterModel class],
    };
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    NSDictionary *startRectDic = @{
        @"top":@(_startRect.top),
        @"left":@(_startRect.left),
        @"bottom":@(_startRect.bottom),
        @"right":@(_startRect.right),
    };
    dic[@"startRect"] = startRectDic;
    
    NSDictionary *endRectDic = @{
        @"top":@(_endRect.top),
        @"left":@(_endRect.left),
        @"bottom":@(_endRect.bottom),
        @"right":@(_endRect.right),
    };
    dic[@"endRect"] = endRectDic;
    return YES;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSDictionary *startRectDic = dic[@"startRect"];
    _startRect.top = [startRectDic[@"top"] floatValue];
    _startRect.left = [startRectDic[@"left"] floatValue];
    _startRect.bottom = [startRectDic[@"bottom"] floatValue];
    _startRect.right = [startRectDic[@"right"] floatValue];
    
    NSDictionary *endRectDic = dic[@"endRect"];
    _endRect.top = [endRectDic[@"top"] floatValue];
    _endRect.left = [endRectDic[@"left"] floatValue];
    _endRect.bottom = [endRectDic[@"bottom"] floatValue];
    _endRect.right = [endRectDic[@"right"] floatValue];
    return YES;
    
}
@end

@implementation NvCaptionAnimationModel

- (id)copyWithZone:(nullable NSZone *)zone {
    NvCaptionAnimationModel *model = [NvCaptionAnimationModel new];
    model.type = self.type;
    model.inputId = self.inputId;
    model.outputId = self.outputId;
    model.captionId = self.captionId;
    model.inputDuration = self.inputDuration;
    model.outputDuration = self.outputDuration;
    model.captionDuration = self.captionDuration;
    return model;
}

@end

@implementation NvCaptionSpan
- (id)copyWithZone:(nullable NSZone *)zone {
    NvCaptionSpan *model = [NvCaptionSpan new];
    model.type = [[NSString alloc] initWithString:self.type];
    model.start = self.start;
    model.end = self.end;
    model.value = [self.value copy];
    return model;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    NvCaptionSpan *model = [NvCaptionSpan new];
    model.type = [[NSString alloc] initWithString:self.type];
    model.start = self.start;
    model.end = self.end;
    model.value = [self.value mutableCopy];
    return model;
}

@end

@implementation NvCaptionInfoModel
- (instancetype)init {
    self = [super init];
    self.scale = 1.f;
    NvsColor textColor = {-1,-1,-1,-1};
    self.textColor = textColor;
    NvsColor outlineColor = {-1,-1,-1,-1};
    self.outlineColor = outlineColor;
    self.translation = CGPointMake(0, 0);
    self.rotation = 0;
    self.anchorPoint = CGPointMake(0, 0);
    //添加字幕的时候会根据timeline高度/10来设置，初始值是几无所谓
    //When adding subtitles, they are set according to the timeline height /10, regardless of the initial value
    self.fontSize = -1;
    self.isDrawOutline = NO;
    self.uuid = [NvUtils uuidString];
    self.letterSpace = 0;
    self.letterSpaceType = LetterSpaceStandard;
    self.letterLineSpace = 0;
    self.animationModel = [NvCaptionAnimationModel new];
    self.keyArray = @[@"Caption TransX",@"Caption TransY",@"Caption ScaleX",@"Caption ScaleY",@"Caption RotZ", @"Track Opacity"];
    self.keyFramesArray = [NSMutableArray array];
    self.textSpanArray = [NSMutableArray array];
    self.isVerticalKeyFrame = NO;
    return self;
}

- (NSMutableArray *) changeUIColorToRGB:(UIColor *)color
{
    NSMutableArray *RGBStrValueArr = [[NSMutableArray alloc] init];
    NSString *RGBStr = nil;
    //获得RGB值描述 Get the RGB value description
    NSString *RGBValue = [NSString stringWithFormat:@"%@",color];
    //将RGB值描述分隔成字符串 Separate RGB value descriptions into strings
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];
    //获取红色值 Get the red value
    int r = [[RGBArr objectAtIndex:1] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",r];
    [RGBStrValueArr addObject:RGBStr];
    //获取绿色值 Get the green value
    int g = [[RGBArr objectAtIndex:2] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",g];
    [RGBStrValueArr addObject:RGBStr];
    //获取蓝色值 Get blue value
    int b = [[RGBArr objectAtIndex:3] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",b];
    [RGBStrValueArr addObject:RGBStr];
    
    int a = [[RGBArr objectAtIndex:4] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",a];
    [RGBStrValueArr addObject:RGBStr];
    //返回保存RGB值的数组 Returns an array holding RGB values
    return RGBStrValueArr;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    NvCaptionInfoModel *model = [NvCaptionInfoModel new];
    model.type = self.type;
    model.animationModel = self.animationModel.copy;
    model.renderId = self.renderId;
    model.contextId = self.contextId;
    model.text = [[NSString alloc] initWithString:self.text];
    model.textColor = self.textColor;
    model.textBgRadius = self.textBgRadius;
    model.textBgColor = self.textBgColor;
    model.boundaryMargin = self.boundaryMargin;
    model.anchorPoint = self.anchorPoint;
    model.isUserRotation = self.isUserRotation;
    model.rotation = self.rotation;
    model.isUserScale = self.isUserScale;
    model.scale = self.scale;
    model.fontSize = self.fontSize;
    model.isUserTranslation = self.isUserTranslation;
    model.translation = self.translation;
    model.uuid = [NvUtils uuidString];
    model.category = self.category;
    model.isModifyTextColor = self.isModifyTextColor;
    model.isModifyTextBgColor = self.isModifyTextBgColor;
    model.isModifyTextBgRadius = self.isModifyTextBgRadius;
    if (!self.styleId) {
        model.styleId = nil;
    } else {
        model.styleId = [[NSString alloc] initWithString:self.styleId];
    }
    model.inPoint = self.inPoint;
    model.outPoint = self.outPoint;
    model.isUserDrawOutline = self.isUserDrawOutline;
    model.isDrawOutline = self.isDrawOutline;
    model.outlineColor = self.outlineColor;
    model.outlineWidth = self.outlineWidth;
    if (!self.fontFilePath) {
        model.fontFilePath = nil;
    } else {
        model.fontFilePath = self.fontFilePath?[[NSString alloc] initWithString:self.fontFilePath]:nil;
    }
    model.isUserAlignment = self.isUserAlignment;
    model.alignment = self.alignment;
    model.isUserBold = self.isUserBold;
    model.isUserItalic = self.isUserItalic;
    model.isUserUnderLine = self.isUserUnderLine;
    model.isUserDrawShadow = self.isUserDrawShadow;
    model.isUserOpacity = self.isUserOpacity;
    model.opacity = self.opacity;
    model.isBold = self.isBold;
    model.isItalic = self.isItalic;
    model.isDrawShadow = self.isDrawShadow;
    model.isUnderLine = self.isUnderLine;
    model.shadowColor = self.shadowColor;
    model.shadowOffset = self.shadowOffset;
    model.letterSpace = self.letterSpace;
    model.isModifyLetterSpace = self.isModifyLetterSpace;
    model.letterSpaceType = self.letterSpaceType;
    model.letterLineSpace = self.letterLineSpace;
    model.isVerticalLayout = self.isVerticalLayout;
    model.keyArray = self.keyArray;
    NSArray *arr = [[NSArray alloc] initWithArray:self.keyFramesArray copyItems:YES];
    model.keyFramesArray = [NSMutableArray arrayWithArray:arr];
    
    NSArray *arr1 = [[NSArray alloc] initWithArray:self.textSpanArray copyItems:YES];
    model.textSpanArray = [NSMutableArray arrayWithArray:arr1];
    return model;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    NSDictionary *textColorDic = @{
        @"r":@(_textColor.r),
        @"g":@(_textColor.g),
        @"b":@(_textColor.b),
        @"a":@(_textColor.a),
    };
    dic[@"textColor"] = textColorDic;
    
    NSDictionary *outlineColorDic = @{
        @"r":@(_outlineColor.r),
        @"g":@(_outlineColor.g),
        @"b":@(_outlineColor.b),
        @"a":@(_outlineColor.a),
    };
    dic[@"outlineColor"] = outlineColorDic;
    
    NSDictionary *shadowColorDic = @{
        @"r":@(_shadowColor.r),
        @"g":@(_shadowColor.g),
        @"b":@(_shadowColor.b),
        @"a":@(_shadowColor.a),
    };
    dic[@"shadowColor"] = shadowColorDic;
    
    NSDictionary *anchorPointDic = @{
        @"x":@(_anchorPoint.x),
        @"y":@(_anchorPoint.y),
    };
    dic[@"anchorPoint"] = anchorPointDic;
    
    NSDictionary *translationDic = @{
        @"x":@(_translation.x),
        @"y":@(_translation.y),
    };
    dic[@"translation"] = translationDic;
    
    NSDictionary *shadowOffsetDic = @{
        @"x":@(_shadowOffset.x),
        @"y":@(_shadowOffset.y),
    };
    dic[@"shadowOffset"] = shadowOffsetDic;
    return YES;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSDictionary *textColorData = dic[@"textColor"];
    _textColor.r = [textColorData[@"r"] floatValue];
    _textColor.g = [textColorData[@"g"] floatValue];
    _textColor.b = [textColorData[@"b"] floatValue];
    _textColor.a = [textColorData[@"a"] floatValue];
    
    NSDictionary *outlineColorData = dic[@"outlineColor"];
    _outlineColor.r = [outlineColorData[@"r"] floatValue];
    _outlineColor.g = [outlineColorData[@"g"] floatValue];
    _outlineColor.b = [outlineColorData[@"b"] floatValue];
    _outlineColor.a = [outlineColorData[@"a"] floatValue];
    
    NSDictionary *shadowColorData = dic[@"shadowColor"];
    _shadowColor.r = [shadowColorData[@"r"] floatValue];
    _shadowColor.g = [shadowColorData[@"g"] floatValue];
    _shadowColor.b = [shadowColorData[@"b"] floatValue];
    _shadowColor.a = [shadowColorData[@"a"] floatValue];
    
    NSDictionary *anchorPointData = dic[@"anchorPoint"];
    _anchorPoint.x = [anchorPointData[@"x"] floatValue];
    _anchorPoint.y = [anchorPointData[@"y"] floatValue];
    
    NSDictionary *translationData = dic[@"translation"];
    _translation.x = [translationData[@"x"] floatValue];
    _translation.y = [translationData[@"y"] floatValue];
    
    NSDictionary *shadowOffsetData = dic[@"shadowOffset"];
    _shadowOffset.x = [shadowOffsetData[@"x"] floatValue];
    _shadowOffset.y = [shadowOffsetData[@"y"] floatValue];
    
    return YES;
}

@end

@implementation NvInnerCompoundCaptionModel
- (instancetype)init {
    self = [super init];
    self.index = 0;
    self.isItalic = NO;
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    NvInnerCompoundCaptionModel *model = [NvInnerCompoundCaptionModel new];
    model.text = [[NSString alloc] initWithString:self.text];
    model.colorString = self.colorString?[NSString stringWithFormat:@"%@",self.colorString]:nil;
    model.fontFamily = self.fontFamily?[NSString stringWithFormat:@"%@",self.fontFamily]:nil;
    model.index = self.index;
    model.textBgColor = self.textBgColor;
    model.hasTextBgColor = self.hasTextBgColor;
    model.outlineColor = self.outlineColor;
    model.outlineWidth = self.outlineWidth;
    model.isUserDrawOutline = self.isUserDrawOutline;
    model.isItalic = self.isItalic;
    return model;
}
@end

@implementation NvCompoundCaptionInfoModel
- (instancetype)init {
    self = [super init];
    self.captionCount = 0;
    self.scale = 1.f;
    self.translationOffset = CGPointMake(0, 0);
    self.rotation = 0;
    self.anchorPoint = CGPointMake(0, 0);
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    
    NvCompoundCaptionInfoModel *model = [NvCompoundCaptionInfoModel new];
    model.captionCount = self.captionCount;
    model.clipAffinityEnabled = self.clipAffinityEnabled;
    model.inPoint = self.inPoint;
    model.outPoint = self.outPoint;
    model.translationOffset = self.translationOffset;
    model.anchorPoint = self.anchorPoint;
    model.rotation = self.rotation;
    model.scale = self.scale;
    NSArray *arr = [[NSArray alloc] initWithArray:self.captionArr copyItems:YES];
    model.captionArr = [NSMutableArray arrayWithArray:arr] ;
    model.packageId = self.packageId;
    return model;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"captionArr" : [NvInnerCompoundCaptionModel class],
    };
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    NSDictionary *translationOffsetDic = @{
        @"x":@(_translationOffset.x),
        @"y":@(_translationOffset.y),
    };
    dic[@"translationOffset"] = translationOffsetDic;
    
    NSDictionary *anchorPointDic = @{
        @"x":@(_anchorPoint.x),
        @"y":@(_anchorPoint.y),
    };
    dic[@"anchorPoint"] = anchorPointDic;
    return YES;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSDictionary *translationOffsetDic = dic[@"translationOffset"];
    _translationOffset.x = [translationOffsetDic[@"x"] floatValue];
    _translationOffset.y = [translationOffsetDic[@"y"] floatValue];
    
    NSDictionary *anchorPointDic = dic[@"anchorPoint"];
    _anchorPoint.x = [anchorPointDic[@"x"] floatValue];
    _anchorPoint.y = [anchorPointDic[@"y"] floatValue];
    return YES;
    
}
@end

@implementation NvStickerAnimationInfo

- (id)copyWithZone:(nullable NSZone *)zone {
    NvStickerAnimationInfo *model = [NvStickerAnimationInfo new];
    model.type = self.type;
    model.inputId = self.inputId;
    model.outputId = self.outputId;
    model.stickerId = self.stickerId;
    model.inputDuration = self.inputDuration;
    model.outputDuration = self.outputDuration;
    model.stickerDuration = self.stickerDuration;
    return model;
}

@end


@implementation NvStickerInfoModel

- (instancetype)init {
    self = [super init];
    self.scale = 1.f;
    self.rotation = 0;
    self.volume = 1;
    self.translation = CGPointMake(0, 0);
    self.stickerAnimationInfo = [NvStickerAnimationInfo new];
    self.anchor = CGPointMake(0, 0);
    self.uuid = [NvUtils uuidString];
    self.keyArray = @[@"Sticker TransX",@"Sticker TransY",@"Sticker Scale",@"Sticker RotZ"];
    self.keyFramesArray = [NSMutableArray array];
    self.isSlient = YES;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvStickerInfoModel *new = NvStickerInfoModel.new;
    new.scale = self.scale;
    new.rotation = self.rotation;
    new.stickerAnimationInfo = self.stickerAnimationInfo.copy;
    new.uuid = [NvUtils uuidString];
    new.translation = self.translation;
    new.anchor = self.anchor;
    new.packageId = self.packageId;
    new.inPoint = self.inPoint;
    new.outPoint = self.outPoint;
    new.isCustomSticer = self.isCustomSticer;
    new.customImagePath = self.customImagePath;
    new.isSlient = self.isSlient;
    new.volume = self.volume;
    new.keyArray = self.keyArray;
    NSArray *arr = [[NSArray alloc] initWithArray:self.keyFramesArray copyItems:YES];
    new.keyFramesArray = [NSMutableArray arrayWithArray:arr];
    
    new.isHorizontalFlip = self.isHorizontalFlip;
    return new;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    NSDictionary *anchorDic = @{
        @"x":@(_anchor.x),
        @"y":@(_anchor.y),
    };
    dic[@"anchor"] = anchorDic;
    
    NSDictionary *translationDic = @{
        @"x":@(_translation.x),
        @"y":@(_translation.y),
    };
    dic[@"translation"] = translationDic;
    return YES;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSDictionary *translationDic = dic[@"translation"];
    _translation.x = [translationDic[@"x"] floatValue];
    _translation.y = [translationDic[@"y"] floatValue];
    
    NSDictionary *anchorDic = dic[@"anchor"];
    _anchor.x = [anchorDic[@"x"] floatValue];
    _anchor.y = [anchorDic[@"y"] floatValue];
    return YES;
}
@end

@implementation NvParticleInfoModel
- (instancetype)init {
    self = [super init];
    self.particleRateValue = 1.f;
    self.particleSizeValue = 1.f;
    self.particleLocation = [[NSMutableArray alloc] init];
    self.emitterName = [[NSMutableArray alloc] init];
    self.uuid = [NvUtils uuidString];
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"particleLocation" : [NSString class],
        @"emitterName" : [NSString class],
    };
}
@end

@implementation NvTimeFilterInfoModel
- (instancetype)init {
    self = [super init];
    self.addInReverseMode = NO;
    self.isShortVideo = NO;
    self.uuid = [NvUtils uuidString];
    self.strength = 1;
    self.expModels = [NSMutableArray array];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvTimeFilterInfoModel *new = NvTimeFilterInfoModel.new;
    new.addInReverseMode = self.addInReverseMode;
    new.isShortVideo = self.isShortVideo;
    new.uuid = [NvUtils uuidString];
    new.inPoint = self.inPoint;
    new.outPoint = self.outPoint;
    new.name = [NSString stringWithFormat:@"%@",self.name];
    new.strength = self.strength;
    new.strokeOnly = self.strokeOnly;
    new.grayscale = self.grayscale;
    new.expModels = [[NSMutableArray alloc] initWithArray:self.expModels copyItems:YES];
    new.categoryId = self.categoryId;
    new.kindId = self.kindId;
    return new;
}
@end

@implementation NvBuiltInWatermarkEffectModel
- (instancetype)init {
    self = [super init];
    self.intensity = 0.5;
    self.unitSize = 0.5;
    return self;
}

@end

@implementation NvWatermarkInfoModel
- (instancetype)init {
    self = [super init];
    self.opacity = 1;
    self.position = 0;
    self.isBuiltInEffect = NO;
    return self;
}
@end

@implementation NvTransitionInfoModel
- (instancetype)init {
    self = [super init];
    self.uuid = [NvUtils uuidString];
    self.builtinName = @"Fade";
    self.duration = NV_TIME_BASE;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvTransitionInfoModel *model = [NvTransitionInfoModel new];
    model.builtinName = self.builtinName;
    model.packageId = self.packageId;
    model.uuid = self.uuid;
    model.imageUrl = self.imageUrl;
    model.duration = self.duration;
    return model;
}

@end

@implementation NvDubbingInfoModel
- (instancetype)init {
    self = [super init];
    self.volume = 1;
    self.audioNoiseSuppressionLevel = 0;
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    NvDubbingInfoModel *model = [NvDubbingInfoModel new];
    model.dubbingFilePath = [[NSString alloc] initWithString:self.dubbingFilePath];
    model.inPoint = self.inPoint;
    model.trimIn = self.trimIn;
    model.duration = self.duration;
    model.speed = self.speed;
    model.volume = self.volume;
    model.builtInFxName = self.builtInFxName;
    model.audioNoiseSuppressionLevel = self.audioNoiseSuppressionLevel;
    return model;
}

@end

@implementation NvDubbingModel

- (instancetype)init {
    self = [super init];
    self.volume = 1;
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    NvDubbingModel *model = [NvDubbingModel new];
    model.volume = self.volume;
    model.dubbingInfoModels = [[NSMutableArray alloc] initWithArray:self.dubbingInfoModels copyItems:YES];
    return model;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"dubbingInfoModels" : [NvDubbingInfoModel class],
    };
}

@end

@implementation NvMusicInfoModel

- (instancetype)init {
    self = [super init];
    self.isBGM = false;
    self.inPoint = 0;
    self.isFade = NO;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvMusicInfoModel *new = NvMusicInfoModel.new;
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

@implementation NvThemeInfoModel
- (instancetype)init {
    self = [super init];
    self.volume = 1;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvThemeInfoModel *new = NvThemeInfoModel.new;
    new.volume = self.volume;
    new.themeName = [NSString stringWithFormat:@"%@",self.themeName];
    new.themeString = [NSString stringWithFormat:@"%@",self.themeString];
    new.thenmeRoleInTheme = self.thenmeRoleInTheme;
    return new;
}
@end

@implementation NvAnimationInfoModel
- (instancetype)init {
    self = [super init];
    self.isUsePropertyEffect = NO;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvAnimationInfoModel *new = NvAnimationInfoModel.new;
    new.animationStart = self.animationStart;
    new.animationEnd = self.animationEnd;
    new.name = [NSString stringWithFormat:@"%@",self.name];
    new.packageId = [NSString stringWithFormat:@"%@",self.packageId];
    new.index = self.index;
    new.asset = self.asset;
    new.isSelected = self.isSelected;
    new.isUsePropertyEffect = self.isUsePropertyEffect;
    new.animationCategory = self.animationCategory;
    new.packageId2 = [NSString stringWithFormat:@"%@",self.packageId2];
    new.animationStart2 = self.animationStart2;
    new.animationEnd2 = self.animationEnd2;
    new.isPostPackage2 = self.isPostPackage2;
    return new;
}
@end
