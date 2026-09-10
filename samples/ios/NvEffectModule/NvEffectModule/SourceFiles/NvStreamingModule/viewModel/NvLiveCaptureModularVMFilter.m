//
//  NvLiveCaptureModularVMFilter.m
//  NvEffectModule
//
//  Created by ms20221114 on 2024/6/26.
//

#import "NvLiveCaptureModularVMFilter.h"
#import "NvLiveCaptureFilterModel.h"

@interface NvLiveCaptureModularVMFilter ()

@property (nonatomic, strong) NvsCaptureVideoFx *fxFilter;

@end

@implementation NvLiveCaptureModularVMFilter

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)applicationFilter:(NvLiveCaptureFilterModel *)model{
    NSMutableString *mutString = [NSMutableString string];
    NvsAssetPackageManagerError error = [self installAssetPackage:model.packagePath license:model.licPath type:NvsAssetPackageType_VideoFx assetPackageId:mutString];
    if (error == NvsAssetPackageManagerError_NoError) {
        model.packageId = mutString;
    }
    
    if (model.packageId.length > 0 || model.builtinName.length > 0) {
        if (self.fxFilter) {
            if ([self.fxFilter.bultinCaptureVideoFxName isEqualToString:model.builtinName] || [self.fxFilter.captureVideoFxPackageId isEqualToString:model.packageId]){
                
                return;
            }else{
                [self.streamingContext removeCaptureVideoFx:self.fxFilter.index];
                self.fxFilter = nil;
            }
        }
        
        if (model.packageId.length > 0){
            self.fxFilter = [self.streamingContext appendPackagedCaptureVideoFx:model.packageId];
        }else if (model.builtinName.length > 0){
            self.fxFilter = [self.streamingContext appendBuiltinCaptureVideoFx:model.builtinName];
        }
        
        [self.fxFilter setFilterIntensity:model.value];
    }else{
        [self.streamingContext removeCaptureVideoFx:self.fxFilter.index];
        self.fxFilter = nil;
    }
}

- (void)changeFilter:(NvLiveCaptureFilterModel *)model{
    [self.fxFilter setFilterIntensity:model.value];
}

@end
