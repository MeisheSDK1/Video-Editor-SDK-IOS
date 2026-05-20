//
//  NvMakeupToolBeautyModuler.m
//  SDKDemo
//
//  Created by Meishe on 2022/11/7.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvMakeupToolBeautyModuler.h"
#import "NvsVideoClip.h"
#import "NvSDKMakeupUtils.h"
#import "NvsStreamingContext.h"
#import "NvFilterUsageUtil.h"
#import <NvSDKCommon/NvInitArScence.h>

@interface NvMakeupToolBeautyModuler()
//默认全部美颜效果未使用对应的参数数组 Default all beauty effects do not use the corresponding parameter array
@property (nonatomic, strong) NSMutableArray *InEffectiveBeautyArr;
//默认全部美型效果未使用对应的参数数组 Default all beauty effects do not use the corresponding parameter array
@property (nonatomic, strong) NSMutableArray *InEffectiveShapeArr;
//默认全部微整形效果未使用对应的参数数组 By default, all microshaping effects do not use the corresponding parameter array
@property (nonatomic, strong) NSMutableArray *InEffectiveMicroShapeArr;
//校色滤镜 Calibrating filter
@property (nonatomic, strong) NvsFx *colorCorrectFx;
@end
@implementation NvMakeupToolBeautyModuler

- (NvsFx *)getAndSetARSceneFx:(NvMakeupToolModel *)model fx:(NvsFx *)fx {
    self.packagePath = model.packagePath;
    if (!fx) {
        if (self.mode == NvMakeupModulerModeEdit) {
            fx = [NvSDKMakeupUtils createClipVideoFx:@"AR Scene" withClip:self.clip];
        }else if (self.mode == NvMakeupModulerModeCapture){
            fx = [[NvsStreamingContext sharedInstance] appendBuiltinCaptureVideoFx:@"AR Scene"];
        }
        [fx setBooleanVal:@"Max Faces Respect Min" val:YES];
        BOOL highVersion = [NvInitArScence isHighVersionPhone];
        if(highVersion) {
            [fx setBooleanVal:@"AI Face Occlusion Enabled" val:YES];
        }
//        if(ARSCENE_MS_240){
//            // !!!: 设置后就会走检测， 不需要设置 3.12.0+
//            [fx setBooleanVal:@"Use Face Extra Info" val:YES];
//        }
    }
    if (![fx isKindOfClass:[NvsCaptureVideoFx class]]){
        if (ARSCENE_MS || ARSCENE_MS_240) {
            [[fx getARSceneManipulate] setDetectionMode:NvsARSceneDetectionMode_SemiImage];
        }
    }
    return fx;
}

#pragma mark - 应用整妆中的美颜效果
//Apply the beauty effect to the whole makeup
- (void)applyMakeupBeautyEffect:(NvMakeupToolEffectContentModel *)effectModel arsceneFx:(NvsFx *)fx {
    //注：为了保证应用整妆的效果，需要将美妆包里没有使用的美颜特效项的程度值强制设为0.
    // Note: In order to ensure the application of the full makeup effect, the degree value of the beauty effect item that is not used in the makeup bag should be set to 0.
    BOOL containColorCorrect = NO;
    NSMutableArray *containKindArr = [NSMutableArray array];
    if(effectModel.beauty.count > 0){
        for (NvMakeupToolEffectModel *model in effectModel.beauty) {
            if (model.params.count>0) {
                for(NvMakeupToolElementModel *item in model.params) {
                    NSString *appliedItem = [self applyMakeupToolElements:fx item:item reset:NO];
                    if (appliedItem) {
                        [containKindArr addObject:appliedItem];
                    }
                }
            }else if ([model.type caseInsensitiveCompare:@"ColorCorrect"] == NSOrderedSame) {
                containColorCorrect = YES;
                //校色 Color correction
                if (self.mode == NvMakeupModulerModeEdit) {
                    if (self.colorCorrectFx) {
                        NvsVideoFx *videoFx = (NvsVideoFx *)self.colorCorrectFx;
                        if ((videoFx.videoFxPackageId && [videoFx.videoFxPackageId isEqualToString:model.uuid]) || (videoFx.bultinVideoFxName && [videoFx.bultinVideoFxName isEqualToString:model.uuid])) {
                            [videoFx setFilterIntensity:model.value];
                            continue;
                        }else if (videoFx.videoFxPackageId.length > 0 || videoFx.bultinVideoFxName.length > 0){
                            [self.clip removeFx:videoFx.index];
                        }
                        self.colorCorrectFx = nil;
                    }
                    self.colorCorrectFx = [self.clip appendPackagedFx:model.uuid];
                    [self.colorCorrectFx setFilterIntensity:model.value];
                }else if (self.mode == NvMakeupModulerModeCapture){
                    if (self.colorCorrectFx) {
                        NvsCaptureVideoFx *captureFx = (NvsCaptureVideoFx *)self.colorCorrectFx;
                        if ((captureFx.captureVideoFxPackageId && [captureFx.captureVideoFxPackageId isEqualToString:model.uuid]) || (captureFx.bultinCaptureVideoFxName && [captureFx.bultinCaptureVideoFxName isEqualToString:model.uuid])) {
                            [captureFx setFilterIntensity:model.value];
                            continue;
                        }else if(captureFx.captureVideoFxPackageId.length > 0 || captureFx.bultinCaptureVideoFxName.length > 0){
                            [[NvsStreamingContext sharedInstance] removeCaptureVideoFx:captureFx.index];
                        }
                        self.colorCorrectFx = nil;
                    }
                    
                    
                    self.colorCorrectFx = [NvFilterUsageUtil appendPackagedCaptureVideoFx:model.uuid];
                    [self.colorCorrectFx setFilterIntensity:model.value];
                }
                if (model.type.length > 0) {
                    [containKindArr addObject:model.type];
                }
                
            }
            
        }
    }
    
    //将未应用的美颜特效删除或者程度值设为0
    // Delete unapplied beauty effects or set the level value to 0
    if (!containColorCorrect) {
        if (self.colorCorrectFx) {
            if (self.mode == NvMakeupModulerModeEdit) {
                NvsVideoFx *videoFx = (NvsVideoFx *)self.colorCorrectFx;
                if (!(videoFx.bultinVideoFxName.length > 0 || videoFx.videoFxPackageId.length > 0)) {
                    self.colorCorrectFx = nil;
                    return;
                }
                [self.clip removeFx:videoFx.index];
            }else {
                NvsCaptureVideoFx *captureFx = (NvsCaptureVideoFx *)self.colorCorrectFx;
                if (!(captureFx.bultinCaptureVideoFxName.length > 0 || captureFx.captureVideoFxPackageId.length > 0)) {
                    self.colorCorrectFx = nil;
                    return;
                }
                [[NvsStreamingContext sharedInstance] removeCaptureVideoFx:captureFx.index];
            }
            self.colorCorrectFx = nil;
        }
    }
    for(NvMakeupToolElementModel *model in self.InEffectiveBeautyArr) {
        BOOL hasApplied = NO;
        for(NSString *item in containKindArr) {
            if ([item caseInsensitiveCompare:model.key] == NSOrderedSame) {
                hasApplied = YES;
                break;
            }
        }
        if (hasApplied) {
            continue;
        }
        
        [self applyMakeupToolElements:fx item:model reset:YES];
        
    }
    
}

- (NSMutableArray *)InEffectiveBeautyArr {
    if (!_InEffectiveBeautyArr) {
        _InEffectiveBeautyArr = [NSMutableArray array];
        //普通磨皮 Ordinary dermabrasion
        NvMakeupToolElementFloatModel *effect = [NvMakeupToolElementFloatModel new];
        effect.key = @"Beauty Strength";
        effect.value = 0.f;
        effect.type = @"float";
        [_InEffectiveBeautyArr addObject:effect];
        
        //高级磨皮 Advanced dermabrasion
        NvMakeupToolElementFloatModel *effect1 = [NvMakeupToolElementFloatModel new];
        effect1.key = @"Advanced Beauty Intensity";
        effect1.value = 0.f;
        effect1.type = @"float";
        [_InEffectiveBeautyArr addObject:effect1];
        
        //美白 whitening
        NvMakeupToolElementFloatModel *effect2 = [NvMakeupToolElementFloatModel new];
        effect2.key = @"Beauty Whitening";
        effect2.value = 0.f;
        effect2.type = @"float";
        [_InEffectiveBeautyArr addObject:effect2];
        
        //去油光 degreasing
        NvMakeupToolElementFloatModel *effect3 = [NvMakeupToolElementFloatModel new];
        effect3.key = @"Advanced Beauty Matte Intensity";
        effect2.value = 0.f;
        effect3.type = @"float";
        [_InEffectiveBeautyArr addObject:effect3];
        
        //红润 ruddy
        NvMakeupToolElementFloatModel *effect4 = [NvMakeupToolElementFloatModel new];
        effect4.key = @"Beauty Reddening";
        effect4.value = 0.f;
        effect4.type = @"float";
        [_InEffectiveBeautyArr addObject:effect4];
        
        //锐度 sharpness
        NvMakeupToolElementBOOLModel *effect5 = [NvMakeupToolElementBOOLModel new];
        effect5.key = @"Default Sharpen Enabled";
        effect5.value = NO;
        effect5.type = @"boolean";
        [_InEffectiveBeautyArr addObject:effect5];
        
        //lut 美白强度值
        //lut whitening intensity
        NvMakeupToolElementFloatModel *effect6 = [NvMakeupToolElementFloatModel new];
        effect6.key = @"Advanced Beauty Face Lut Intensity";
        effect6.value = 0.f;
        effect6.type = @"float";
        [_InEffectiveBeautyArr addObject:effect6];
    }
    return _InEffectiveBeautyArr;
}

#pragma mark - 应用整妆中的美型效果
//Apply the beauty effect in your makeup
- (void)applyMakeupBeautyShapeEffect:(NvMakeupToolEffectContentModel *)effectModel arsceneFx:(NvsFx *)fx {
    //注：为了保证应用整妆的效果，需要将美妆包里没有使用的美型特效项的程度值强制设为0.
    // Note: In order to ensure the effect of applying makeup, it is necessary to force the degree value of beauty effect items not used in the beauty bag to be set to 0.
    NSMutableArray *containKindArr = [NSMutableArray array];
    if(effectModel.shape.count > 0){
        for (NvMakeupToolEffectModel *model in effectModel.shape) {
            if (model.params.count>0) {
                for(NvMakeupToolElementModel *item in model.params) {
                    NSString *appliedItem = [self applyMakeupToolElements:fx item:item reset:NO];
                    if (appliedItem) {
                        [containKindArr addObject:appliedItem];
                    }
                }
            }
        }
    }
    
    //将未应用的美型特效程度值设为0
    // Set the unapplied beauty effect level to 0
    for(NvMakeupToolElementModel *model in self.InEffectiveShapeArr) {
        BOOL hasApplied = NO;
        for(NSString *item in containKindArr) {
            if ([item caseInsensitiveCompare:model.key] == NSOrderedSame) {
                hasApplied = YES;
                break;
            }
        }
        if (hasApplied) {
            continue;
        }
        [self applyMakeupToolElements:fx item:model reset:YES];
        
    }
    
}

- (NSMutableArray *)InEffectiveShapeArr {
    if (!_InEffectiveShapeArr) {
        _InEffectiveShapeArr = [NSMutableArray array];
        NSArray *shapeDegrees = [self getShapeDegrees];
        for(NSString *item in shapeDegrees) {
            NvMakeupToolElementFloatModel *effect = [NvMakeupToolElementFloatModel new];
            effect.key = item;
            effect.value = 0.f;
            effect.type = @"float";
            [_InEffectiveShapeArr addObject:effect];
        }
    }
    return _InEffectiveShapeArr;
}

- (NSArray *)getShapeDegrees {
    return @[@"Eye Size Warp Degree",
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
    
}

#pragma mark - 应用整妆中的微美型效果
//Apply the micro-beauty effect in the whole makeup
- (void)applyMakeupMicroShapeEffect:(NvMakeupToolEffectContentModel *)effectModel arsceneFx:(NvsFx *)fx {
    //注：为了保证应用整妆的效果，需要将美妆包里没有使用的微美型特效项的程度值强制设为0.
    // Note: In order to ensure the full makeup effect, the degree value of the micro beauty effect item that is not used in the beauty bag should be set to 0.
    NSMutableArray *containKindArr = [NSMutableArray array];
    if(effectModel.microShape.count > 0){
        for (NvMakeupToolEffectModel *model in effectModel.microShape) {
            if (model.params.count>0) {
                for(NvMakeupToolElementModel *item in model.params) {
                    NSString *appliedItem = [self applyMakeupToolElements:fx item:item reset:NO];
                    if (appliedItem) {
                        [containKindArr addObject:appliedItem];
                    }
                }
            }
        }
    }
    
    //将未应用的微美型特效程度值设为0
    // Set the unapplied Micro beauty effect level value to 0
    for(NvMakeupToolElementModel *model in self.InEffectiveMicroShapeArr) {
        BOOL hasApplied = NO;
        for(NSString *item in containKindArr) {
            if ([item caseInsensitiveCompare:model.key] == NSOrderedSame) {
                hasApplied = YES;
                break;
            }
        }
        if (hasApplied) {
            continue;
        }
        [self applyMakeupToolElements:fx item:model reset:YES];
        
    }
}

- (NSMutableArray *)InEffectiveMicroShapeArr {
    if (!_InEffectiveMicroShapeArr) {
        _InEffectiveMicroShapeArr = [NSMutableArray array];
        NSArray *microShapeDegrees = [self getMicroShapeDegrees];
        for(NSString *item in microShapeDegrees) {
            NvMakeupToolElementFloatModel *effect = [NvMakeupToolElementFloatModel new];
            effect.key = item;
            effect.value = 0.f;
            effect.type = @"float";
            [_InEffectiveMicroShapeArr addObject:effect];
        }
    }
    return _InEffectiveMicroShapeArr;
}

- (NSArray *)getMicroShapeDegrees {
    return @[
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
    
}

#pragma mark - 应用具体特效
//Apply specific effects
- (NSString *)applyMakeupToolElements:(NvsFx *)fx item:(NvMakeupToolElementModel *)item reset:(BOOL)reset {
    NSString *appliedItem;
    if ([item.type caseInsensitiveCompare:@"string"] == NSOrderedSame) {
        NvMakeupToolElementStringModel *effect = (NvMakeupToolElementStringModel *)item;
        [fx setStringVal:effect.key val:effect.value];
        NSLog(@"NvMakeupToolElementStringModel=%@,%@,%@",effect.key,effect.type,effect.value);
    }else if ([item.type caseInsensitiveCompare:@"float"] == NSOrderedSame || [item.type caseInsensitiveCompare:@"double"] == NSOrderedSame) {
        NvMakeupToolElementFloatModel *effect = (NvMakeupToolElementFloatModel *)item;
        [fx setFloatVal:effect.key val:effect.value];
        appliedItem = effect.key;
        NSLog(@"NvMakeupToolElementFloatModel=%@,%@,%f",item.key,item.type,effect.value);
    }else if ([item.type caseInsensitiveCompare:@"path"] == NSOrderedSame) {
        NvMakeupToolElementStringModel *effect = (NvMakeupToolElementStringModel *)item;
        [fx setStringVal:effect.key val:[self.packagePath stringByAppendingPathComponent:effect.value]];
        NSLog(@"NvMakeupToolElementStringModel=%@,%@,%@",effect.key,effect.type,effect.value);
    }else if ([item.type caseInsensitiveCompare:@"boolean"] == NSOrderedSame) {
        NvMakeupToolElementBOOLModel *effect = (NvMakeupToolElementBOOLModel *)item;
        [fx setBooleanVal:effect.key val:effect.value];
        appliedItem = effect.key;
        NSLog(@"NvMakeupToolElementBOOLModel=%@,%@,%d",item.key,item.type,effect.value);
    }else if ([item.type caseInsensitiveCompare:@"int"] == NSOrderedSame) {
        NvMakeupToolElementIntModel *effect = (NvMakeupToolElementIntModel *)item;
        [fx setIntVal:effect.key val:effect.value];
        NSLog(@"NvMakeupToolElementIntModel=%@,%@,%d",item.key,item.type,effect.value);
    }else if ([item.type caseInsensitiveCompare:@"color"] == NSOrderedSame) {
        NvMakeupToolElementColorModel *effect = (NvMakeupToolElementColorModel *)item;
        NvsColor color = {effect.r,effect.g,effect.b,effect.a};
        [fx setColorVal:effect.key val:&color];
        NSLog(@"NvMakeupToolElementColorModel=%@,%@",item.key,item.type);
    }
   
    if (reset) {
        return nil;
    }
    return appliedItem;
}
@end
