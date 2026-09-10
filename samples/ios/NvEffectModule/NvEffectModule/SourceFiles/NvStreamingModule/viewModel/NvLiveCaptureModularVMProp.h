//
//  NvLiveCaptureModularVMProp.h
//  NvEffectModule
//
//  Created by ms20221114 on 2024/6/26.
//

#import "NvLiveCaptureModularVM.h"

NS_ASSUME_NONNULL_BEGIN

@class NvLiveCaptureFilterModel;
@interface NvLiveCaptureModularVMProp : NvLiveCaptureModularVM

- (void)applicationProp:(NvLiveCaptureFilterModel *)model;

@end

NS_ASSUME_NONNULL_END
