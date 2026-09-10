//
//  NvLiveCaptureModularVMMakeup.h
//  NvEffectModule
//
//  Created by ms20221114 on 2024/6/26.
//

#import "NvLiveCaptureModularVM.h"

@class NvLiveMakeupItemModel;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NveMakeupLiveType) {
    NveMakeupLiveType_lip,
    NveMakeupLiveType_eyeshadow,
    NveMakeupLiveType_eyebrow,
    NveMakeupLiveType_eyelash,
    NveMakeupLiveType_eyeliner,
    NveMakeupLiveType_blusher,
    NveMakeupLiveType_brighten,
    NveMakeupLiveType_shadow,
    NveMakeupLiveType_eyeball
};

@interface NvLiveCaptureModularVMMakeup : NvLiveCaptureModularVM

- (void)applicationMakeup:(NvLiveMakeupItemModel *)model;

- (void)applicationSingleMakeup:(NvLiveMakeupItemModel *)model;

- (void)changeSingleMakeup:(NvLiveMakeupItemModel *)model;

- (NSString *)getCurrentSingleMakeupPackageId:(NvLiveMakeupItemModel *)model;

@end

NS_ASSUME_NONNULL_END
