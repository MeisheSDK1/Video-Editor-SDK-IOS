//
//  NvLiveCaptureModularVM.m
//  NvEffectModule
//
//  Created by ms20221114 on 2024/6/25.
//

#import "NvLiveCaptureModularVM.h"
#import "NvLiveBeautyTypeModel.h"
#import "NvLiveStreamingModule.h"
@interface NvLiveCaptureModularVM ()

@end

@implementation NvLiveCaptureModularVM

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.streamingContext = [NvsStreamingContext sharedInstanceWithFlags:NvsStreamingContextFlag_Support4KEdit];
    }
    return self;
}

- (void)creatFaceFx{
    for (int i = 0; i < self.streamingContext.getCaptureVideoFxCount; i++) {
        NvsCaptureVideoFx *fx = [self.streamingContext getCaptureVideoFxByIndex:i];
        if ([fx.bultinCaptureVideoFxName isEqualToString:@"AR Scene"]){
            self.fxARFace = fx;
            break;
        }
    }
    
    if (!self.fxARFace){
        self.fxARFace = [self.streamingContext appendBuiltinCaptureVideoFx:@"AR Scene"];
        [self.fxARFace setBooleanVal:@"Beauty Effect" val:YES];
        [self.fxARFace setBooleanVal:@"Beauty Shape" val:YES];
        [self.fxARFace setBooleanVal:@"Advanced Beauty Enable" val:YES];
    }
    
    [self.fxARFace setBooleanVal:@"Max Faces Respect Min" val:YES];
    [self.fxARFace setBooleanVal:@"Use Face Extra Info" val:YES];
    [self.fxARFace setBooleanVal:@"Face Mesh Internal Enabled" val:YES];
}

- (void)creatFxSharpen{
    self.fxSharpen = [self.streamingContext appendBuiltinCaptureVideoFx:@"Sharpen"];
}

- (void)creatFxDefinition{
    self.fxDefinition = [self.streamingContext appendBuiltinCaptureVideoFx:@"Definition"];
    [self.fxDefinition setBooleanVal:@"Fast Mode" val:YES];
}

- (void)applyBeautyEffectModel:(NvLiveBeautyTypeModel *)model withOpen:(BOOL)open{
    if (model.subprojectArray.count > 0) {
        NvLiveBeautyTypeModel *item = nil;
        for (NvLiveBeautyTypeModel *tempModel in model.subprojectArray) {
            if (tempModel.value > 0 && tempModel.selected){
                item = tempModel;
                break;
            }
            if (tempModel.value > 0 ){
                item = tempModel;
                break;
            }
        }
        
        if (!item){
            item = model.subprojectArray.count > 1?model.subprojectArray[1]:nil;
        }
        
        model = item;
    }
    CGFloat value = open?model.value:0;
    NveBeautyLiveType type = model.effectType;
    switch (type) {
        case NveBeautyLiveType_whitening:
            [self.fxARFace setStringVal:@"Whitening Lut Enabled" val:@""];
            [self.fxARFace setBooleanVal:@"Whitening Lut Enabled" val:NO];
            [self.fxARFace setFloatVal:@"Beauty Whitening" val:value];
            break;
        case NveBeautyLiveType_whitening_1:{
            NSString *whitenLutPath = [[[NSBundle bundleForClass:[NvLiveStreamingModule class]] bundlePath] stringByAppendingPathComponent:@"whitenLut.bundle"];
            NSString *lutPath = [whitenLutPath stringByAppendingPathComponent:@"WhiteB.mslut"];
            [self.fxARFace setStringVal:@"Whitening Lut Enabled" val:lutPath];
            [self.fxARFace setBooleanVal:@"Whitening Lut Enabled" val:YES];
            [self.fxARFace setFloatVal:@"Beauty Whitening" val:value];
        }
            break;
        case NveBeautyLiveType_reddening:
            [self.fxARFace setFloatVal:@"Beauty Reddening" val:value];
            break;
        case NveBeautyLiveType_strength:
            [self.fxARFace setFloatVal:@"Advanced Beauty Intensity" val:0];
            [self.fxARFace setFloatVal:@"Beauty Strength" val:value];
            break;
        case NveBeautyLiveType_strength_1:
            [self.fxARFace setBooleanVal:@"Advanced Beauty Enable" val:YES];
            [self.fxARFace setIntVal:@"Advanced Beauty Type" val:0];
            [self.fxARFace setFloatVal:@"Advanced Beauty Intensity" val:value];
            [self.fxARFace setFloatVal:@"Beauty Strength" val:0];
            break;
        case NveBeautyLiveType_strength_2:
            [self.fxARFace setBooleanVal:@"Advanced Beauty Enable" val:YES];
            [self.fxARFace setIntVal:@"Advanced Beauty Type" val:1];
            [self.fxARFace setFloatVal:@"Advanced Beauty Intensity" val:value];
            [self.fxARFace setFloatVal:@"Beauty Strength" val:0];
            break;
        case NveBeautyLiveType_strength_3:
            [self.fxARFace setBooleanVal:@"Advanced Beauty Enable" val:YES];
            [self.fxARFace setIntVal:@"Advanced Beauty Type" val:2];
            [self.fxARFace setFloatVal:@"Advanced Beauty Intensity" val:value];
            [self.fxARFace setFloatVal:@"Beauty Strength" val:0];
            break;
        case NveBeautyLiveType_matte:
            [self.fxARFace setFloatVal:@"Advanced Beauty Matte Intensity" val:value];
            break;
        case NveBeautyLiveType_sharpen:
            [self.fxSharpen setFloatVal:model.degreeName val:value];
            break;
        case NveBeautyLiveType_definition:
            [self.fxDefinition setFloatVal:model.degreeName val:value];
            break;
    }
}

- (void)applyBeautyShapeModel:(NvLiveBeautyTypeModel *)model withOpen:(BOOL)open{
    CGFloat value = open?model.value:0;
    [self setWarpStrategy:model];
    if (model.fxName.length > 0) {
        [self.fxARFace setStringVal:model.fxName val:model.uuid];
    }
    if (model.degreeName > 0) {
        [self.fxARFace setFloatVal:model.degreeName val:value];
    }
}

- (void)setWarpStrategy:(NvLiveBeautyTypeModel *)model {
    
    if ([model.fxName isEqualToString:@"Warp Forehead Height Custom Package Id"]) {
        [self.fxARFace setIntVal:@"Forehead Height Warp Strategy" val:0x7FFFFFFF];
    }
    else if ([model.fxName isEqualToString:@"Warp Head Size Custom Package Id"]) {
        [self.fxARFace setIntVal:@"Head Size Warp Strategy" val:0x7FFFFFFF];
    }
}

- (void)applyBeautyMicroshapingModel:(NvLiveBeautyTypeModel *)model withOpen:(BOOL)open{
    [self applyBeautyShapeModel:model withOpen:open];
}

- (CGFloat)getFxCurrentValue:(NvLiveBeautyTypeModel *)model{
    NveBeautyLiveType type = model.effectType;
    CGFloat value = 0;
    
    BOOL state = [self.fxARFace getBooleanVal:@"Whitening Lut Enabled"];
    int index = [self.fxARFace getIntVal:@"Advanced Beauty Type"];
    BOOL advancedBeauty = [self.fxARFace getBooleanVal:@"Advanced Beauty Enable"];
    
    switch (type) {
        case NveBeautyLiveType_whitening:{
            if (state){
                model.selected = NO;
            }else{
                model.selected = YES;
                value = [self.fxARFace getFloatVal:@"Beauty Whitening"];
            }
        }
            break;
        case NveBeautyLiveType_whitening_1:{
            if (state){
                model.selected = YES;
                value = [self.fxARFace getFloatVal:@"Beauty Whitening"];
            }else{
                model.selected = NO;
            }
        }
            break;
        case NveBeautyLiveType_reddening:
            value = [self.fxARFace getFloatVal:@"Beauty Reddening"];
            break;
        case NveBeautyLiveType_strength:{
            if (advancedBeauty){
                model.selected = NO;
            }else{
                model.selected = YES;
                value = [self.fxARFace getFloatVal:@"Beauty Strength"];
            }
        }
            break;
        case NveBeautyLiveType_strength_1:{
            if (advancedBeauty){
                if (index == 0){
                    model.selected = YES;
                    value = [self.fxARFace getFloatVal:@"Advanced Beauty Intensity"];
                }else{
                    model.selected = NO;
                }
            }else{
                model.selected = NO;
            }
        }
            break;
        case NveBeautyLiveType_strength_2:{
            if (advancedBeauty){
                if (index == 1){
                    model.selected = YES;
                    value = [self.fxARFace getFloatVal:@"Advanced Beauty Intensity"];
                }else{
                    model.selected = NO;
                }
            }else{
                model.selected = NO;
            }
        }
            break;
        case NveBeautyLiveType_strength_3:{
            if (advancedBeauty){
                if (index == 2){
                    model.selected = YES;
                    value = [self.fxARFace getFloatVal:@"Advanced Beauty Intensity"];
                }else{
                    model.selected = NO;
                }
            }else{
                model.selected = NO;
            }
        }
            break;
        case NveBeautyLiveType_matte:
            value = [self.fxARFace getFloatVal:@"Advanced Beauty Matte Intensity"];
            break;
        case NveBeautyLiveType_sharpen:
            value = [self.fxSharpen getFloatVal:model.degreeName];
            break;
        case NveBeautyLiveType_definition:
            value = [self.fxDefinition getFloatVal:model.degreeName];
            break;
    }
    return 0;
}

- (NvsAssetPackageManagerError)installAssetPackage:(NSString *)assetPackageFilePath
                                           license:(NSString *)licenseFilePath
                                              type:(NvsAssetPackageType)type
                                    assetPackageId:(NSMutableString *)assetPackageId {
    NvsAssetPackageManager *assetPackageManager = self.streamingContext.assetPackageManager;
    NvsAssetPackageManagerError error = [assetPackageManager installAssetPackage:assetPackageFilePath
                                                                         license:licenseFilePath
                                                                            type:type
                                                                            sync:YES
                                                                  assetPackageId:assetPackageId];
    if (error == NvsAssetPackageManagerError_AlreadyInstalled) {
        int lastVersion = [assetPackageManager getAssetPackageVersion:assetPackageId type:type];
        int newViersion = [assetPackageManager getAssetPackageVersionFromAssetPackageFilePath:assetPackageFilePath];
        if (newViersion > lastVersion) {
            error = [assetPackageManager upgradeAssetPackage:assetPackageFilePath
                                                     license:licenseFilePath
                                                        type:type
                                                        sync:YES
                                              assetPackageId:assetPackageId];
        } else {
            return NvsAssetPackageManagerError_NoError;
        }
    }
    return error;
}

@end
