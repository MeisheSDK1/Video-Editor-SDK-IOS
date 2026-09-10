//
//  NveMakeup.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/8.
//

#import "NveItem.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NveMakeup : NveItem <NSCopying>

/// intensity
/// Value range: 0 ~ 1 , Default: 1
/// - Remark:  强度
/// 取值范围：0 ~ 1，默认值：1

/// 口红
@property(nonatomic, assign) double lip;
/// 眼影
@property(nonatomic, assign) double eyeshadow;
/// 眉毛
@property(nonatomic, assign) double eyebrow;
/// 睫毛
@property(nonatomic, assign) double eyelash;
/// 眼线
@property(nonatomic, assign) double eyeliner;
/// 腮红
@property(nonatomic, assign) double blusher;
/// 提亮
@property(nonatomic, assign) double brighten;
/// 阴影
@property(nonatomic, assign) double shadow;
/// 美瞳
@property(nonatomic, assign) double eyeball;

@end

@interface NveMakeup (Package)

/// Custom Package
/// Default: nil
/// - Remark:  自定义效果包
/// 默认值：nil

/// 口红
@property(nonatomic, strong) NSString *lipPackageId;
/// 眼影
@property(nonatomic, strong) NSString *eyeshadowPackageId;
/// 眉毛
@property(nonatomic, strong) NSString *eyebrowPackageId;
/// 睫毛
@property(nonatomic, strong) NSString *eyelashPackageId;
/// 眼线
@property(nonatomic, strong) NSString *eyelinerPackageId;
/// 腮红
@property(nonatomic, strong) NSString *blusherPackageId;
/// 提亮
@property(nonatomic, strong) NSString *brightenPackageId;
/// 阴影
@property(nonatomic, strong) NSString *shadowPackageId;
/// 美瞳
@property(nonatomic, strong) NSString *eyeballPackageId;

@end

@interface NveMakeup (Color)

/// Custom color
/// Default: Color from the custom pack
/// - Remark:  自定义颜色
/// 默认值：效果包中的颜色

/// 口红
@property(nonatomic, strong) UIColor *lipColor;
/// 眼影
@property(nonatomic, strong) UIColor *eyeshadowColor;
/// 眉毛
@property(nonatomic, strong) UIColor *eyebrowColor;
/// 睫毛
@property(nonatomic, strong) UIColor *eyelashColor;
/// 眼线
@property(nonatomic, strong) UIColor *eyelinerColor;
/// 腮红
@property(nonatomic, strong) UIColor *blusherColor;
/// 提亮
@property(nonatomic, strong) UIColor *brightenColor;
/// 阴影
@property(nonatomic, strong) UIColor *shadowColor;
/// 美瞳
@property(nonatomic, strong) UIColor *eyeballColor;

@end

NS_ASSUME_NONNULL_END
