//
//  NveMakeup+LiveEnmu.h
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/16.
//


#import <NveEffectKit/NveEffectKit.h>

#import <UIKit/UIKit.h>

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

@interface NveMakeup (Enmu)

- (void)updateEffect:(NveMakeupLiveType)type value:(double)value;

- (double)effectValue:(NveMakeupLiveType)type;

- (void)updateEffect:(NveMakeupLiveType)type packageId:(NSString *)packageId;

- (NSString *)packageIdForType:(NveMakeupLiveType)type;

- (void)updateEffect:(NveMakeupLiveType)type color:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
