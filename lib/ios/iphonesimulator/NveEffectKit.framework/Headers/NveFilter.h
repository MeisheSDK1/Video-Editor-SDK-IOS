//
//  NveFilter.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/12.
//

#import "NveItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NveFilter : NveItem

// packageId / builtinName
@property(nonatomic, readonly) NSString *effectId;

/// intensity
/// Value range: 0 ~ 1 , Default: 1
/// - Remark:  强度
/// 取值范围：0 ~ 1，默认值：1
@property(nonatomic, assign) double intensity;

+ (instancetype)filterWithEffectId:(NSString *)effectId;

@end

NS_ASSUME_NONNULL_END
