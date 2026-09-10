//
//  NvLiveCaptureModularVMProp.m
//  NvEffectModule
//
//  Created by ms20221114 on 2024/6/26.
//

#import "NvLiveCaptureModularVMProp.h"
#import "NvLiveCaptureFilterModel.h"

@implementation NvLiveCaptureModularVMProp

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self creatFaceFx];
    }
    return self;
}

- (void)applicationProp:(NvLiveCaptureFilterModel *)model{
    NSMutableString *mutString = [NSMutableString string];
    NvsAssetPackageManagerError error = [self installAssetPackage:model.packagePath license:model.licPath type:NvsAssetPackageType_ARScene assetPackageId:mutString];
    if (error == NvsAssetPackageManagerError_NoError) {
        model.packageId = mutString;
    }
    NvsARSceneCameraPreset preset;
    BOOL cameraPreset = [self.streamingContext.assetPackageManager getARSceneAssetPackage:model.packageId cameraPreset:&preset];
    if (cameraPreset) {
        [self.fxARFace setFloatVal:@"Face Camera Fovy" val:preset.fovy];
    }
    [self.fxARFace setStringVal:@"Scene Id" val:model.packageId];
}

@end
