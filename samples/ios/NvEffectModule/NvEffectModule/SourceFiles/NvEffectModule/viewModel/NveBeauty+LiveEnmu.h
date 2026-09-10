//
//  NveBeauty+LiveEnmu.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/11.
//

#import <NveEffectKit/NveEffectKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NveBeautyLiveType) {
    NveBeautyLiveType_strength,
    NveBeautyLiveType_strength_1,
    NveBeautyLiveType_strength_2,
    NveBeautyLiveType_strength_3,
    NveBeautyLiveType_whitening,
    NveBeautyLiveType_whitening_1,
    NveBeautyLiveType_matte,
    NveBeautyLiveType_reddening,
    /// 法令纹
    NveBeautyLiveType_removeNasolabialFolds,
    /// 黑眼圈
    NveBeautyLiveType_removeDarkCircles,
    /// 亮眼
    NveBeautyLiveType_brightenEyes,
    /// 美牙
    NveBeautyLiveType_whitenTeeth,
    NveBeautyLiveType_sharpen,
    NveBeautyLiveType_definition,
    NveBeautyLiveType_strength_4
};

@interface NveBeauty (Enmu)

- (void)updateEffect:(NveBeautyLiveType)type value:(double)value;

- (double)effectValue:(NveBeautyLiveType)type;

@end

NS_ASSUME_NONNULL_END
