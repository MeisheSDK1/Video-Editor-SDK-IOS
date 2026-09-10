//
//  NveBeauty.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/8.
//

#import "NveItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NveBeauty : NveItem <NSCopying>

/// Value range: 0 ~ 1 , Default: 0
/// - Remark: 取值范围：0 ~ 1，默认值：0

/// 磨皮
@property(nonatomic, assign) double strength;

/// 美白
@property(nonatomic, assign) double whitening;

/// 红润
@property(nonatomic, assign) double reddening;

/// 去油光
@property(nonatomic, assign) double matte;

/// 法令纹
@property(nonatomic, assign) double removeNasolabialFolds;

/// 黑眼圈
@property(nonatomic, assign) double removeDarkCircles;

/// 亮眼
@property(nonatomic, assign) double brightenEyes;

/// 美牙
@property(nonatomic, assign) double whitenTeeth;

/// 锐化
@property(nonatomic, assign) double sharpen;

/// 清晰度
@property(nonatomic, assign) double definition;

@end

NS_ASSUME_NONNULL_END
