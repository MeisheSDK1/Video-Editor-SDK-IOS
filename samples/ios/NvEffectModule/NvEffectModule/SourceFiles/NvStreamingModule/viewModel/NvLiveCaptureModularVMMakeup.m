//
//  NvLiveCaptureModularVMMakeup.m
//  NvEffectModule
//
//  Created by ms20221114 on 2024/6/26.
//

#import "NvLiveCaptureModularVMMakeup.h"
#import "NvLiveMakeupItemModel.h"
#import "NvLiveMakeupToolModel.h"
#import <YYModel/YYModel.h>

@interface NvLiveCaptureModularVMMakeup ()

@property (nonatomic, strong) NvLiveMakeupToolModel *currentSetMakeupModel;

@property (nonatomic, strong) NvsCaptureVideoFx *colorCorrectFx;

@property (nonatomic, strong) NSMutableArray *filterMakeupArray;

@end

@implementation NvLiveCaptureModularVMMakeup

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self creatFaceFx];
        self.filterMakeupArray = [NSMutableArray array];
    }
    return self;
}

- (void)applicationMakeup:(NvLiveMakeupItemModel *)model{
    if ([model.packagePath isEqualToString:self.currentSetMakeupModel.packagePath]) {
        return;
    }
    
    if (self.currentSetMakeupModel){
        [self applyMakeupPackage:self.currentSetMakeupModel.effectContent withClear:YES];
        [self applyMakeupFilterEffect:self.currentSetMakeupModel.effectContent withClear:YES];
        [self applyMakeupBeautyShapeEffect:self.currentSetMakeupModel.effectContent withClear:YES];
        [self applyMakeupMicroShapeEffect:self.currentSetMakeupModel.effectContent withClear:YES];
        [self applyMakeupBeautyEffect:self.currentSetMakeupModel.effectContent withClear:YES];
    }
    
    if (model.packagePath.length > 0){
        NSData *data = [NSData dataWithContentsOfFile:[model.packagePath stringByAppendingPathComponent:@"info_new.json"]];
        if (data){
            self.currentSetMakeupModel = [NvLiveMakeupToolModel yy_modelWithJSON:data];
            self.currentSetMakeupModel.packagePath = model.packagePath;
            
            if (self.currentSetMakeupModel.effectContent.makeup.count > 0) {
                for (NvLiveMakeupToolEffectModel *effectM in self.currentSetMakeupModel.effectContent.makeup) {
                    [self installAsset:model.packagePath model:effectM assetType:NvsAssetPackageType_Makeup];
                }
            }
            if (self.currentSetMakeupModel.effectContent.filter.count > 0) {
                for (NvLiveMakeupToolEffectModel *effectM in self.currentSetMakeupModel.effectContent.filter) {
                    [self installAsset:model.packagePath model:effectM assetType:NvsAssetPackageType_VideoFx];
                }
            }
            if (self.currentSetMakeupModel.effectContent.shape.count > 0) {
                for (NvLiveMakeupToolEffectModel *effectM in self.currentSetMakeupModel.effectContent.shape) {
                    [self installAsset:model.packagePath model:effectM assetType:NvsAssetPackageType_FaceMesh];
                }
            }
            if (self.currentSetMakeupModel.effectContent.beauty.count > 0) {
                for (NvLiveMakeupToolEffectModel *effectM in self.currentSetMakeupModel.effectContent.beauty) {
                    if ([effectM.type caseInsensitiveCompare:@"ColorCorrect"] == NSOrderedSame  && effectM.uuid.length > 0) {
                        [self installAsset:model.packagePath model:effectM assetType:NvsAssetPackageType_VideoFx];
                        break;
                    }
                }
            }
            if (self.currentSetMakeupModel.effectContent.microShape.count > 0) {
                for (NvLiveMakeupToolEffectModel *effectM in self.currentSetMakeupModel.effectContent.microShape) {
                    [self installAsset:model.packagePath model:effectM assetType:NvsAssetPackageType_FaceMesh];
                }
            }
        }
        
        [self applyMakeupPackage:self.currentSetMakeupModel.effectContent withClear:NO];
        [self applyMakeupFilterEffect:self.currentSetMakeupModel.effectContent withClear:NO];
        [self applyMakeupBeautyShapeEffect:self.currentSetMakeupModel.effectContent withClear:NO];
        [self applyMakeupMicroShapeEffect:self.currentSetMakeupModel.effectContent withClear:NO];
        [self applyMakeupBeautyEffect:self.currentSetMakeupModel.effectContent withClear:NO];
    }else{
        self.currentSetMakeupModel = nil;
    }
}

- (void)applyMakeupPackage:(NvLiveMakeupToolEffectContentModel *)effectModel withClear:(BOOL)clear{
    if(effectModel.makeup.count > 0){
        for (NvLiveMakeupToolEffectModel *model in effectModel.makeup) {
            for(NvLiveMakeupToolElementModel *item in model.params) {
                if ([item.type caseInsensitiveCompare:@"string"] == NSOrderedSame) {
                    NvLiveMakeupToolElementStringModel *effect = (NvLiveMakeupToolElementStringModel *)item;
                    [self.fxARFace setStringVal:effect.key val:clear?@"":effect.value];
                }else if ([item.type caseInsensitiveCompare:@"float"] == NSOrderedSame || [item.type caseInsensitiveCompare:@"double"] == NSOrderedSame) {
                    NvLiveMakeupToolElementFloatModel *effect = (NvLiveMakeupToolElementFloatModel *)item;
                    [self.fxARFace setFloatVal:effect.key val:clear?0:effect.value];
                }else if ([item.type caseInsensitiveCompare:@"color"] == NSOrderedSame) {
                    NvLiveMakeupToolElementColorModel *effect = (NvLiveMakeupToolElementColorModel *)item;
                    NvsColor color = {effect.r,effect.g,effect.b,effect.a};
                    
                    if (clear){
                        NvsColor newColor;
                        newColor.r = 0;
                        newColor.g = 0;
                        newColor.b = 0;
                        newColor.a = 0;
                        
                        [self.fxARFace setColorVal:effect.key val:&newColor];
                    }else{
                        [self.fxARFace setColorVal:effect.key val:&color];
                    }
                }
            }
        }
    }
    
    [self.fxARFace setFloatVal:@"Makeup Intensity" val:1];
}

- (void)applyMakeupFilterEffect:(NvLiveMakeupToolEffectContentModel *)effectModel withClear:(BOOL)clear{
    if (clear){
        for (NvsCaptureVideoFx *fx in self.filterMakeupArray) {
            [self.streamingContext removeCaptureVideoFx:fx.index];
        }
        
        [self.filterMakeupArray removeAllObjects];
    }else{
        for (int i=0; i<effectModel.filter.count; i++) {
            NvLiveMakeupToolEffectModel *filterModel = effectModel.filter[i];
            if (filterModel.isBuiltIn) {
                NvsCaptureVideoFx *fx = [self.streamingContext appendBuiltinCaptureVideoFx:filterModel.uuid];
                [fx setFilterIntensity:filterModel.value];
                [self.filterMakeupArray addObject:fx];
            } else if (filterModel.uuid) {
                NvsCaptureVideoFx *fx = [self.streamingContext appendPackagedCaptureVideoFx:filterModel.uuid];
                [fx setFilterIntensity:filterModel.value];
                [self.filterMakeupArray addObject:fx];
            }
        }
    }
}

- (void)applyMakeupBeautyShapeEffect:(NvLiveMakeupToolEffectContentModel *)effectModel withClear:(BOOL)clear{
    if(effectModel.shape.count > 0){
        for (NvLiveMakeupToolEffectModel *model in effectModel.shape) {
            if (model.params.count>0) {
                for(NvLiveMakeupToolElementModel *item in model.params) {
                    [self applyMakeupToolElements:self.fxARFace item:item withClear:clear];
                }
            }
        }
    }
}

- (void)applyMakeupMicroShapeEffect:(NvLiveMakeupToolEffectContentModel *)effectModel withClear:(BOOL)clear{
    if(effectModel.microShape.count > 0){
        for (NvLiveMakeupToolEffectModel *model in effectModel.microShape) {
            if (model.params.count>0) {
                for(NvLiveMakeupToolElementModel *item in model.params) {
                    [self applyMakeupToolElements:self.fxARFace item:item withClear:clear];
                }
            }
        }
    }
}

- (void)applyMakeupBeautyEffect:(NvLiveMakeupToolEffectContentModel *)effectModel withClear:(BOOL)clear{
    if(effectModel.beauty.count > 0){
        for (NvLiveMakeupToolEffectModel *model in effectModel.beauty) {
            if (model.params.count>0) {
                for(NvLiveMakeupToolElementModel *item in model.params) {
                    [self applyMakeupToolElements:self.fxARFace item:item withClear:clear];
                }
            }else if ([model.type caseInsensitiveCompare:@"ColorCorrect"] == NSOrderedSame) {
                if (self.colorCorrectFx) {
                    if (clear){
                        [self.streamingContext removeCaptureVideoFx:self.colorCorrectFx.index];
                        self.colorCorrectFx = nil;
                        continue;
                    }
                    NvsCaptureVideoFx *captureFx = (NvsCaptureVideoFx *)self.colorCorrectFx;
                    if ((captureFx.captureVideoFxPackageId && [captureFx.captureVideoFxPackageId isEqualToString:model.uuid]) || (captureFx.bultinCaptureVideoFxName && [captureFx.bultinCaptureVideoFxName isEqualToString:model.uuid])) {
                        [captureFx setFilterIntensity:model.value];
                        continue;
                    }else if(captureFx.captureVideoFxPackageId.length > 0 || captureFx.bultinCaptureVideoFxName.length > 0){
                        [self.streamingContext removeCaptureVideoFx:captureFx.index];
                    }
                    self.colorCorrectFx = nil;
                }
                
                self.colorCorrectFx = [[NvsStreamingContext sharedInstance] appendPackagedCaptureVideoFx:model.uuid];
                [self.colorCorrectFx setFilterIntensity:model.value];
            }
        }
    }
}

- (void)applyMakeupToolElements:(NvsFx *)fx item:(NvLiveMakeupToolElementModel *)item withClear:(BOOL)clear{
    if ([item.type caseInsensitiveCompare:@"string"] == NSOrderedSame) {
        NvLiveMakeupToolElementStringModel *effect = (NvLiveMakeupToolElementStringModel *)item;
        [fx setStringVal:effect.key val:clear?@"":effect.value];
        NSLog(@"NvMakeupToolElementStringModel=%@,%@,%@",effect.key,effect.type,effect.value);
    }else if ([item.type caseInsensitiveCompare:@"float"] == NSOrderedSame || [item.type caseInsensitiveCompare:@"double"] == NSOrderedSame) {
        NvLiveMakeupToolElementFloatModel *effect = (NvLiveMakeupToolElementFloatModel *)item;
        [fx setFloatVal:effect.key val:clear?0:effect.value];
        NSLog(@"NvMakeupToolElementFloatModel=%@,%@,%f",item.key,item.type,effect.value);
    }else if ([item.type caseInsensitiveCompare:@"path"] == NSOrderedSame) {
        NvLiveMakeupToolElementStringModel *effect = (NvLiveMakeupToolElementStringModel *)item;
        [fx setStringVal:effect.key val:clear?@"":[self.currentSetMakeupModel.packagePath stringByAppendingPathComponent:effect.value]];
        NSLog(@"NvMakeupToolElementStringModel=%@,%@,%@",effect.key,effect.type,effect.value);
    }else if ([item.type caseInsensitiveCompare:@"boolean"] == NSOrderedSame) {
        NvLiveMakeupToolElementBOOLModel *effect = (NvLiveMakeupToolElementBOOLModel *)item;
        [fx setBooleanVal:effect.key val:effect.value];
        NSLog(@"NvMakeupToolElementBOOLModel=%@,%@,%d",item.key,item.type,effect.value);
    }else if ([item.type caseInsensitiveCompare:@"int"] == NSOrderedSame) {
        NvLiveMakeupToolElementIntModel *effect = (NvLiveMakeupToolElementIntModel *)item;
        [fx setIntVal:effect.key val:effect.value];
        NSLog(@"NvMakeupToolElementIntModel=%@,%@,%d",item.key,item.type,effect.value);
    }else if ([item.type caseInsensitiveCompare:@"color"] == NSOrderedSame) {
        NvLiveMakeupToolElementColorModel *effect = (NvLiveMakeupToolElementColorModel *)item;
        NvsColor color = {effect.r,effect.g,effect.b,effect.a};
        if (clear){
            NvsColor newColor;
            newColor.r = 0;
            newColor.g = 0;
            newColor.b = 0;
            newColor.a = 0;
            
            [fx setColorVal:effect.key val:&newColor];
        }else{
            [fx setColorVal:effect.key val:&color];
        }
        NSLog(@"NvMakeupToolElementColorModel=%@,%@",item.key,item.type);
    }
}

- (void)applicationSingleMakeup:(NvLiveMakeupItemModel *)model{
    [self.fxARFace setStringVal:@"Makeup Compound Package Id" val:@""];
    [self.fxARFace setFloatVal:@"Makeup Intensity" val:1];
    if (model.packagePath.length > 0){
        NSMutableString *mutString = [NSMutableString string];
        NvsAssetPackageManagerError error = [self installAssetPackage:model.packagePath
                                                              license:model.licPath
                                                                 type:NvsAssetPackageType_Makeup
                                                       assetPackageId:mutString];
        if (error == NvsAssetPackageManagerError_NoError) {
            model.uuid = mutString;
        }
    }
    
    if (model.packageName.length == 0 || !model.packageName){
        [self getFxRelatedName:model];
    }
    
    if (model.packageName.length > 0) {
        [self.fxARFace setStringVal:model.packageName val:model.uuid];
        [self.fxARFace setFloatVal:model.intensityName val:model.value];
    }
}

- (void)changeSingleMakeup:(NvLiveMakeupItemModel *)model{
    if (model.packageName.length == 0 || !model.packageName){
        [self getFxRelatedName:model];
    }
    if (model.intensityName.length > 0) {
        [self.fxARFace setFloatVal:model.intensityName val:model.value];
    }
}

- (void)getFxRelatedName:(NvLiveMakeupItemModel *)model{
    if (model.effectType == -1) {
        return;
    }
    
    NveMakeupLiveType type = model.effectType;
    NSString *string = @"";
    switch (type) {
        case NveMakeupLiveType_lip:
            string = @"Lip";
            break;
        case NveMakeupLiveType_eyeshadow:{
            string = @"Eyeshadow";
        }
            break;
        case NveMakeupLiveType_eyebrow:
            string = @"Eyebrow";
            break;
        case NveMakeupLiveType_eyelash:
            string = @"Eyelash";
            break;
        case NveMakeupLiveType_eyeliner:
            string = @"Eyeliner";
            break;
        case NveMakeupLiveType_blusher:
            string = @"Blusher";
            break;
        case NveMakeupLiveType_brighten:
            string = @"Brighten";
            break;
        case NveMakeupLiveType_shadow:
            string = @"Shadow";
            break;
        case NveMakeupLiveType_eyeball:
            string = @"Eyeball";
            break;
    }
    
    if (string.length > 0){
        model.packageName = [NSString stringWithFormat:@"Makeup %@ Package Id",string];
        model.colorName = [NSString stringWithFormat:@"Makeup %@ Color",string];
        model.intensityName = [NSString stringWithFormat:@"Makeup %@ Intensity",string];
    }
}

- (NSString *)getCurrentSingleMakeupPackageId:(NvLiveMakeupItemModel *)model{
    return [self.fxARFace getStringVal:model.packageName];
}

- (void)installAsset:(NSString *)dirPath model:(NvLiveMakeupToolEffectModel *)model assetType:(NvsAssetPackageType)assetType {
    if (model.uuid.length > 0) {
        [self installAsset:dirPath uuid:model.uuid assetType:assetType];
    }else if(model.params.count > 0){
        for (NvLiveMakeupToolElementModel *element in model.params) {
            if ([element.type caseInsensitiveCompare:@"string"] == NSOrderedSame && [element.key containsString:@"Package Id"]) {
                NvLiveMakeupToolElementStringModel *item = (NvLiveMakeupToolElementStringModel *)element;
                [self installAsset:dirPath uuid:item.value assetType:assetType];
                break;
            }
        }
    }
}

- (void)installAsset:(NSString *)dirPath uuid:(NSString *)uuid assetType:(NvsAssetPackageType)assetType {
    NSString *assetFilePath = [self getPackagePath:dirPath uuid:uuid];
    NSString *licFilePath = [self getLicPath:dirPath uuid:uuid];
    //美型新旧两种包，确保素材类型是否传正确
    // New and old packages to ensure that the material type is passed correctly
    if (assetType == NvsAssetPackageType_Warp ||
        assetType == NvsAssetPackageType_FaceMesh) {
        if ([assetFilePath.pathExtension isEqualToString:@"facemesh"]) {
            assetType = NvsAssetPackageType_FaceMesh;
        }else if([assetFilePath.pathExtension isEqualToString:@"warp"]) {
            assetType = NvsAssetPackageType_Warp;
        }
    }
    
    NvsAssetPackageManagerError error = [self installAssetPackage:assetFilePath license:licFilePath type:assetType assetPackageId:NSMutableString.new];
}

- (NSString *)getPackagePath:(NSString *)dirPath uuid:(NSString *)uuid {
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:dirPath error:nil];
    NSString *packagePath ;
    if (uuid && uuid.length > 0) {
        for (NSString *path in dirArray) {
            //It is assumed that there are only these five situations at present
            if (([path.pathExtension isEqualToString:@"videofx"] || [path.pathExtension isEqualToString:@"makeup"] || [path.pathExtension isEqualToString:@"beauty"] || [path.pathExtension isEqualToString:@"facemesh"] || [path.pathExtension isEqualToString:@"warp"]) && [path containsString:uuid]) {
                packagePath = [dirPath stringByAppendingPathComponent:path];
                break;
            }
        }
    }
    return packagePath;
}

- (NSString *)getLicPath:(NSString *)dirPath uuid:(NSString *)uuid {
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:dirPath error:nil];
    NSString *packagePath ;
    for (NSString *path in dirArray) {
        if ([path.pathExtension isEqualToString:@"lic"] && [path containsString:uuid]) {
            packagePath = [dirPath stringByAppendingPathComponent:path];
            break;
        }
    }
    return packagePath;
}


@end
