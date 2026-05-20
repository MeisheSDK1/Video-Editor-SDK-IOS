//
//  NvBeautyTemplateTool.m
//  SDKDemo
//
//  Created by ms20221114 on 2023/2/14.
//  Copyright © 2023 meishe. All rights reserved.
//

#import "NvBeautyTemplateTool.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvMakeupToolModel.h"
#import "NvMakeupModel.h"
#import "NvMakeupToolManager.h"
#import "NvMakeupToolBeautyModuler.h"
#import "NvMakeupToolMakeupModuler.h"
#import "NvCaptureModularVM.h"
#import "NvFilterUsageUtil.h"

@interface NvBeautyTemplateTool ()

@property (nonatomic, strong) NvsStreamingContext *streamingContext;

@property (nonatomic, strong) NvMakeupToolManager *makeupToolManager;
@property (nonatomic, strong) NvMakeupToolBeautyModuler *beautyModuler;
@property (nonatomic, strong) NvMakeupToolMakeupModuler *makeupModuler;

@end

@implementation NvBeautyTemplateTool

- (instancetype)init {
    if (self = [super init]) {
        self.makeupToolManager = [[NvMakeupToolManager alloc]init];
        self.beautyModuler = [[NvMakeupToolBeautyModuler alloc]init];
        self.makeupModuler = [[NvMakeupToolMakeupModuler alloc]init];
        self.streamingContext = [NvSDKUtils getSDKContext];
    }
    return self;
}

#pragma mark - 应用美颜模版
/// Apply the beauty template
- (void)applyBeautyTemplateEffect:(NvMakeupToolModel *)model{
    if (self.whiteningFilter){
        if ([self.whiteningFilter isEqual:[self.streamingContext getCaptureVideoFxByIndex:self.whiteningFilter.index]]){
            [self.streamingContext removeCaptureVideoFx:self.whiteningFilter.index];
        }
    }
    if (self.fxSharpen){
        if ([self.fxSharpen isEqual:[self.streamingContext getCaptureVideoFxByIndex:self.fxSharpen.index]]){
            [self.streamingContext removeCaptureVideoFx:self.fxSharpen.index];
        }
        
    }
    if (self.fxDefinition){
        if ([self.fxDefinition isEqual:[self.streamingContext getCaptureVideoFxByIndex:self.fxDefinition.index]]){
            [self.streamingContext removeCaptureVideoFx:self.fxDefinition.index];
        }
    }
    if (self.colorCorrectFilter){
        if ([self.colorCorrectFilter isEqual:[self.streamingContext getCaptureVideoFxByIndex:self.colorCorrectFilter.index]]){
            [self.streamingContext removeCaptureVideoFx:self.colorCorrectFilter.index];
        }
    }
    
    self.whiteningFilter = nil;
    self.fxSharpen = nil;
    self.fxDefinition = nil;
    self.colorCorrectFilter = nil;
    self.whiteningEffectModel = nil;
    
    [self applyMakeup:model.effectContent];
    [self appAllEffect:model];
}

- (void)incrementApplyBeautyTemplateEffect:(NvMakeupToolModel *)model{
    [self appAllEffect:model];
    [self applySingMakeupPackage:model.effectContent];
}

- (void)appAllEffect:(NvMakeupToolModel *)model{
    if (!model){
        return;
    }
    [self installationMaterial:model];

    [self.fxARFace setBooleanVal:@"Beauty Effect" val:YES];
    [self.fxARFace setBooleanVal:@"Advanced Beauty Enable" val:YES];
    [self.fxARFace setBooleanVal:@"Beauty Shape" val:YES];
    [self.fxARFace setBooleanVal:@"Face Mesh Internal Enabled" val:YES];
    
    for (NvMakeupToolEffectModel *effectModel in model.effectContent.beauty) {
        if ([effectModel.type isEqualToString:@"SkinColour"]){
            if (effectModel.uuid.length > 0){
                self.whiteningFilter = [NvFilterUsageUtil appendPackagedCaptureVideoFx:effectModel.uuid];
            }
            [self.whiteningFilter setFilterIntensity:effectModel.value];
        }else{
            for (NvMakeupToolElementModel *elementModel in effectModel.params) {
                if ([elementModel.key isEqualToString:@"Beauty Whitening"]){
                    self.whiteningEffectModel = effectModel;
                }
                [self.beautyModuler applyMakeupToolElements:self.fxARFace item:elementModel reset:NO];
            }
        }
    }
    
    for (NvMakeupToolEffectModel *effectModel in model.effectContent.shape) {
        for (NvMakeupToolElementModel *elementModel in effectModel.params) {
            [self.beautyModuler applyMakeupToolElements:self.fxARFace item:elementModel reset:NO];
        }
    }

    for (NvMakeupToolEffectModel *effectModel in model.effectContent.microShape) {
        for (NvMakeupToolElementModel *elementModel in effectModel.params) {
            [self.beautyModuler applyMakeupToolElements:self.fxARFace item:elementModel reset:NO];
        }
    }

    for (NvMakeupToolEffectModel *effectModel in model.effectContent.adjust) {
        if ([effectModel.type isEqualToString:@"ColorCorrect"]){
            if (effectModel.uuid.length > 0){
                self.colorCorrectFilter = [NvFilterUsageUtil appendPackagedCaptureVideoFx:effectModel.uuid];
            }
            [self.colorCorrectFilter setFilterIntensity:effectModel.value];
        }else if ([effectModel.type isEqualToString:@"Sharpen"]){
            self.fxSharpen = [self.streamingContext appendBuiltinCaptureVideoFx:@"Sharpen"];
            [self applyOtherFx:self.fxSharpen with:effectModel];
        }else if ([effectModel.type isEqualToString:@"Definition"]){
            self.fxDefinition = [self.streamingContext appendBuiltinCaptureVideoFx:@"Definition"];
            [self.fxDefinition setBooleanVal:@"Fast Mode" val:YES];
            [self applyOtherFx:self.fxDefinition with:effectModel];
        }
    }
}

- (void)applyMakeup:(NvMakeupToolEffectContentModel *)model{
    NSArray *kindArr =  @[@"Brighten",
                          @"Eyelash",
                          @"Lip",
                          @"Eyebrow",
                          @"Blusher",
                          @"Shadow",
                          @"Eyeliner",
                          @"Eyeshadow",
                          @"Eyeball"];
    self.makeupModuler.fxARFace = self.fxARFace;
    [self.makeupModuler applyMakeupPackage:model makeupKindArr:kindArr];
}

- (void)applySingMakeupPackage:(NvMakeupToolEffectContentModel *)effectModel{
    [self.fxARFace setStringVal:@"Makeup Compound Package Id" val:@""];
    
    for (NvMakeupToolEffectModel *model in effectModel.makeup) {
        if (model.params.count > 0){
            NvMakeupToolElementStringModel *stringModel = (NvMakeupToolElementStringModel *)model.params.firstObject;
            [self.fxARFace setStringVal:stringModel.key val:stringModel.value];
            
            NSString *baseStr = [@"Makeup " stringByAppendingString:model.type];
            NSString *intensityStr = [baseStr stringByAppendingString:@" Intensity"];
            
            if (model.params.count == 2){
                NvMakeupToolElementFloatModel *floatModel = (NvMakeupToolElementFloatModel *)model.params[1];
                [self.fxARFace setFloatVal:intensityStr val:floatModel.value];
            }else{
                [self.fxARFace setFloatVal:intensityStr val:1.0];
            }
        }else{
            //单妆选择无
            //Single makeup option no
            NSString *baseStr = [@"Makeup " stringByAppendingString:model.type];
            NSString *packageId = [baseStr stringByAppendingString:@" Package Id"];
            [self.fxARFace setStringVal:packageId val:@""];
            NSString *intensityStr = [baseStr stringByAppendingString:@" Intensity"];
            [self.fxARFace setFloatVal:intensityStr val:0];
            
            NSString *colorStr = [baseStr stringByAppendingString:@" Color"];
            NvsColor color = [self nvsColorWithValue:@""];
            [self.fxARFace setColorVal:colorStr val:&color];
        }
    }

    [self.fxARFace setFloatVal:@"Makeup Intensity" val:1];
}

- (NvsColor)nvsColorWithValue:(NSString *)value {
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

- (void)applyOtherFx:(NvsCaptureVideoFx *)fx with:(NvMakeupToolEffectModel *)effectModel{
    for (NvMakeupToolElementModel *elementModel in effectModel.params) {
        if ([elementModel isKindOfClass:NvMakeupToolElementFloatModel.class]){
            NvMakeupToolElementFloatModel *floatModel = (NvMakeupToolElementFloatModel *)elementModel;
            [fx setFloatVal:floatModel.key val:floatModel.value];
        }
    }
}

- (void)applyBeautyTemplateWhitening{
    for (NvMakeupToolElementModel *elementModel in self.whiteningEffectModel.params) {
        [self.beautyModuler applyMakeupToolElements:self.fxARFace item:elementModel reset:NO];
    }
}

- (void)conversionBeautyTemplateWithBeauty:(NSMutableArray *)mutableArray withModel:(NvMakeupToolModel *)model{
    /*
     磨皮、肤色、美白，需要根据当前效果，在界面上正确选中ui和更新数值
     Strength, skin colour, whitening, you need to select the ui and update the value correctly on the interface according to the current effect
     */
    for (NvBeautyTypeModel *beautyTypeModel in mutableArray) {
        if (beautyTypeModel.subprojectArray.count > 0) {
            if ([beautyTypeModel.fxName isEqualToString:@"Strength"]) {
                NSString *string = nil;
                CGFloat value = 0;
                if ([self.fxARFace getFloatVal:@"Beauty Strength"] > 0) {
                    if ([self.fxARFace getIntVal:@"Advanced Beauty Type"] == 0){
                        string = @"Beauty Strength";
                    }
                    value = [self.fxARFace getFloatVal:@"Beauty Strength"];
                }else {
                    if ([self.fxARFace getIntVal:@"Advanced Beauty Type"] == 0){
                        string = @"Advanced Beauty Type Zero";
                    }else if ([self.fxARFace getIntVal:@"Advanced Beauty Type"] == 1){
                        string = @"Advanced Beauty Type One";
                    }else if ([self.fxARFace getIntVal:@"Advanced Beauty Type"] == 2){
                        string = @"Advanced Beauty Type Two";
                    }else if ([self.fxARFace getIntVal:@"Advanced Beauty Type"] == 3){
                        string = @"Advanced Beauty Type Three";
                    }
                    value = [self.fxARFace getFloatVal:@"Advanced Beauty Intensity"];
                }
                
                for (NvBeautyTypeModel *sonModel in beautyTypeModel.subprojectArray) {
                    if ([sonModel.fxName isEqualToString:string]) {
                        sonModel.selected = YES;
                        sonModel.value = value;
                        sonModel.defaultValue = value;
                    }else{
                        sonModel.selected = NO;
                    }
                }
            }else if ([beautyTypeModel.fxName isEqualToString:@"SkinColor"]){
                int type = 0;
                CGFloat value = 0;
                NSString *string;
                for (NvMakeupToolEffectModel *effectModel in model.effectContent.beauty) {
                    if ([effectModel.type isEqualToString:@"SkinColour"]) {
                        value = effectModel.value;
                        string = effectModel.uuid;
                        for (NvMakeupToolElementModel *elementModel in effectModel.params) {
                            if ([elementModel isKindOfClass:NvMakeupToolElementIntModel.class]){
                                NvMakeupToolElementIntModel *newElementModel = (NvMakeupToolElementIntModel *)elementModel;
                                type = newElementModel.value + 1;
                            }
                        }
                    }
                }
                
                if (type > 0 && string.length > 0){
                    for (NvBeautyTypeModel *sonModel in beautyTypeModel.subprojectArray) {
                        if ([sonModel.fxName isEqualToString:[NSString stringWithFormat:@"Skin Color %d",type]]) {
                            sonModel.selected = YES;
                            sonModel.value = value;
                            sonModel.uuid = string;
                            sonModel.defaultValue = value;
                        }else{
                            sonModel.selected = NO;
                        }
                    }
                }
            }else if ([beautyTypeModel.fxName isEqualToString:@"Beauty Whitening"]){
                int type = 0;
                CGFloat value = 0;
                NSString *pathString;
                
                BOOL find = NO;
                for (NvMakeupToolEffectModel *effectModel in model.effectContent.beauty) {
                    for (NvMakeupToolElementModel *elementModel in effectModel.params) {
                        if ([elementModel.key isEqualToString:@"Beauty Whitening"]){
                            find = YES;
                            if ([elementModel isKindOfClass:NvMakeupToolElementFloatModel.class]){
                                NvMakeupToolElementFloatModel *newElementModel = (NvMakeupToolElementFloatModel *)elementModel;
                                value = newElementModel.value;
                            }
                        }else if ([elementModel.key isEqualToString:@"Whitening Lut Enabled"]){
                            if ([elementModel isKindOfClass:NvMakeupToolElementBOOLModel.class]){
                                NvMakeupToolElementBOOLModel *newElementModel = (NvMakeupToolElementBOOLModel *)elementModel;
                                type = newElementModel.value?1:0;
                            }
                        }else if ([elementModel.key isEqualToString:@"Whitening Lut File"]){
                            if ([elementModel isKindOfClass:NvMakeupToolElementStringModel.class]){
                                NvMakeupToolElementStringModel *newElementModel = (NvMakeupToolElementStringModel *)elementModel;
                                pathString = newElementModel.value;
                            }
                        }
                    }
                    if (find){
                        break;
                    }
                }
                
                for (NvBeautyTypeModel *sonModel in beautyTypeModel.subprojectArray) {
                    sonModel.selected = NO;
                    sonModel.packageUrl = @"";
                }
                
                for (NvBeautyTypeModel *sonModel in beautyTypeModel.subprojectArray) {
                    if (type == 0 && [sonModel.fxName isEqualToString:@"Beauty Whitening A"]){
                        sonModel.value = value;
                        sonModel.selected = YES;
                        sonModel.defaultValue = value;
                    }else if (type == 1 && [sonModel.fxName isEqualToString:@"Beauty Whitening B"]){
                        sonModel.value = value;
                        sonModel.selected = YES;
                        sonModel.defaultValue = value;
                        sonModel.packageUrl = pathString;
                    }
                }
            }
        }else{
            if ([beautyTypeModel.fxName isEqualToString:@"Shiny"]){
                beautyTypeModel.value = [self.fxARFace getFloatVal:@"Advanced Beauty Matte Intensity"];
            }else{
                beautyTypeModel.value = [self.fxARFace getFloatVal:beautyTypeModel.fxName];
            }
            beautyTypeModel.defaultValue = beautyTypeModel.value;
        }
    }
}

- (void)conversionBeautyTemplateWithShaping:(NSMutableArray *)mutableArray withModel:(NvMakeupToolModel *)model{
    for (NvBeautyTypeModel *beautyTypeModel in mutableArray) {
        beautyTypeModel.uuid = [self.fxARFace getStringVal:beautyTypeModel.fxName];
        beautyTypeModel.value = [self.fxARFace getFloatVal:beautyTypeModel.degreeName];
        beautyTypeModel.defaultValue = beautyTypeModel.value;
    }
}

- (void)conversionBeautyTemplateWithMicroShaping:(NSMutableArray *)mutableArray withModel:(NvMakeupToolModel *)model{
    for (NvBeautyTypeModel *beautyTypeModel in mutableArray) {
        if (beautyTypeModel.degreeName.length > 0) {
            beautyTypeModel.uuid = [self.fxARFace getStringVal:beautyTypeModel.fxName];
            beautyTypeModel.value = [self.fxARFace getFloatVal:beautyTypeModel.degreeName];
        }else{
            beautyTypeModel.value = [self.fxARFace getFloatVal:beautyTypeModel.fxName];
        }
        
        beautyTypeModel.defaultValue = beautyTypeModel.value;
    }
}

- (void)conversionBeautyTemplateWithAdjust:(NSMutableArray *)mutableArray withModel:(NvMakeupToolModel *)model{
    for (NvMakeupToolEffectModel *effectModel in model.effectContent.adjust) {
        for (NvBeautyTypeModel *beautyTypeModel in mutableArray) {
            if ([effectModel.type isEqualToString:beautyTypeModel.fxName]){
                beautyTypeModel.uuid = effectModel.uuid;
                beautyTypeModel.value = effectModel.value;
                beautyTypeModel.defaultValue = beautyTypeModel.value;
                
                for (NvMakeupToolElementModel *elementModel in effectModel.params) {
                    if ([elementModel isKindOfClass:NvMakeupToolElementFloatModel.class]){
                        NvMakeupToolElementFloatModel *newElementModel = (NvMakeupToolElementFloatModel *)elementModel;
                        
                        beautyTypeModel.value = newElementModel.value;
                        beautyTypeModel.defaultValue = beautyTypeModel.value;
                    }
                }
            }
        }
    }
}

- (void)conversionBeautyTemplateWithContouring:(NSMutableArray *)mutableArray withModel:(NvMakeupToolModel *)model{
    NSArray *kindArr =  @[@"Brighten",
                          @"Eyelash",
                          @"Lip",
                          @"Eyebrow",
                          @"Blusher",
                          @"Shadow",
                          @"Eyeliner",
                          @"Eyeshadow",
                          @"Eyeball"];
    NSArray *nameArr =  @[@"brighten",
                          @"eyelash",
                          @"lip",
                          @"eyebrow",
                          @"blusher",
                          @"shadow",
                          @"eyeliner",
                          @"eyeshadow",
                          @"eyeball"];
    NSArray *coverArr =  @[@"capture_brighten",
                           @"capture_eyelash",
                           @"capture_lip",
                           @"capture_eyebrow",
                           @"capture_blusher",
                           @"capture_shadow",
                           @"capture_eyeliner",
                           @"capture_eyeshadow",
                           @"capture_eyeball"];
    
    for (int i = 0; i < kindArr.count; i++) {
        NSString *stirng = kindArr[i];
        NSString *name = nameArr[i];
        NSString *cover = coverArr[i];
        
        NSString *packageId = [NSString stringWithFormat:@"Makeup %@ Package Id",stirng];
        NSString *intensity = [NSString stringWithFormat:@"Makeup %@ Intensity",stirng];
        
        NSString *uuid = @"";
        CGFloat value = 0;
        
        uuid = [self.fxARFace getStringVal:packageId];
        value = [self.fxARFace getFloatVal:intensity];
        
        if (uuid.length > 0) {
            NvBeautyTypeModel *newModel = [NvBeautyTypeModel new];
            newModel.name = NvLocalString(name, nil);
            newModel.coverImage = cover;
            newModel.selectedCoverImg = cover;
            newModel.uuid = uuid;
            newModel.fxName = packageId;
            newModel.degreeName = intensity;
            newModel.value = value;
            newModel.defaultValue = value;
            newModel.type = NvBeautyShadowCategory;
            
            [mutableArray addObject:newModel];
        }
    }
}

- (void)installationMaterial:(NvMakeupToolModel *)model{
    if (model.effectContent.makeup.count > 0) {
        for (NvMakeupToolEffectModel *effectM in model.effectContent.makeup) {
            [self.makeupToolManager installAsset:model.packagePath model:effectM assetType:NvsAssetPackageType_Makeup];
        }
    }
    if (model.effectContent.shape.count > 0) {
        for (NvMakeupToolEffectModel *effectM in model.effectContent.shape) {
            [self.makeupToolManager installAsset:model.packagePath model:effectM assetType:NvsAssetPackageType_FaceMesh];
        }
    }
    if (model.effectContent.beauty.count > 0) {
        for (NvMakeupToolEffectModel *effectM in model.effectContent.beauty) {
            if ([effectM.type caseInsensitiveCompare:@"SkinColour"] == NSOrderedSame  && effectM.uuid.length > 0) {
                [self.makeupToolManager installAsset:model.packagePath model:effectM assetType:NvsAssetPackageType_VideoFx];
                break;
            }
        }
    }
    if (model.effectContent.microShape.count > 0) {
        for (NvMakeupToolEffectModel *effectM in model.effectContent.microShape) {
            [self.makeupToolManager installAsset:model.packagePath model:effectM assetType:NvsAssetPackageType_FaceMesh];
        }
    }
    if (model.effectContent.adjust.count > 0) {
        for (NvMakeupToolEffectModel *effectM in model.effectContent.adjust) {
            if ([effectM.type caseInsensitiveCompare:@"ColorCorrect"] == NSOrderedSame  && effectM.uuid.length > 0) {
                [self.makeupToolManager installAsset:model.packagePath model:effectM assetType:NvsAssetPackageType_VideoFx];
                break;
            }
        }
    }
}

@end
