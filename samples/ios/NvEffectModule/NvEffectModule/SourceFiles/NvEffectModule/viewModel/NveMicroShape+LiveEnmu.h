//
//  NveMicroShape+LiveEnmu.h
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/12.
//

#import <NveEffectKit/NveEffectKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NveMicroShapeLiveType) {
    /// 缩头
    NveMicroShapeLiveType_headSize,
    /// 颧骨
    NveMicroShapeLiveType_malarWidth,
    /// 下颌
    NveMicroShapeLiveType_jawWidth,
    /// 太阳穴
    NveMicroShapeLiveType_templeWidth,
    /// 眼距
    NveMicroShapeLiveType_eyeDistance,
    /// 眼角度
    NveMicroShapeLiveType_eyeAngle,
    /// 人中
    NveMicroShapeLiveType_philtrumLength,
    /// 宽鼻梁
    NveMicroShapeLiveType_noseBridgeWidth,
    /// 鼻头
    NveMicroShapeLiveType_noseHeadWidth,
    /// 眉毛粗细
    NveMicroShapeLiveType_eyebrowThickness,
    /// 眉毛角度
    NveMicroShapeLiveType_eyebrowAngle,
    /// 眉毛左右
    NveMicroShapeLiveType_eyebrowXOffset,
    /// 眉毛上下
    NveMicroShapeLiveType_eyebrowYOffset,
    /// 眼睛宽度
    NveMicroShapeLiveType_eyeWidth,
    /// 眼睛高度
    NveMicroShapeLiveType_eyeHeight,
    /// 眼睛弧度
    NveMicroShapeLiveType_eyeArc,
    /// 眼睛上下
    NveMicroShapeLiveType_eyeYOffset
};

@interface NveMicroShape (Enmu)

- (void)updateEffect:(NveMicroShapeLiveType)type value:(double)value;

- (double)effectValue:(NveMicroShapeLiveType)type;

- (void)updateEffect:(NveMicroShapeLiveType)type packageId:(NSString *)packageId;

@end

NS_ASSUME_NONNULL_END
