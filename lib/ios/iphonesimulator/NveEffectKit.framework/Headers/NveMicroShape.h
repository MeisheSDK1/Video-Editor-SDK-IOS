//
//  NveMicroShape.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/8.
//

#import "NveItem.h"

NS_ASSUME_NONNULL_BEGIN

/// Value range: -1 ~ 1, Default: 0
/// - Remark: 取值范围：-1 ~ 1，默认值：0
@interface NveMicroShape : NveItem <NSCopying>

/// 缩头
@property(nonatomic, assign) double headSize;

/// 颧骨
@property(nonatomic, assign) double malarWidth;

/// 下颌
@property(nonatomic, assign) double jawWidth;

/// 太阳穴
@property(nonatomic, assign) double templeWidth;

/// 眼距
@property(nonatomic, assign) double eyeDistance;

/// 眼角度
@property(nonatomic, assign) double eyeAngle;

/// 人中
@property(nonatomic, assign) double philtrumLength;

/// 宽鼻梁
@property(nonatomic, assign) double noseBridgeWidth;

/// 鼻头
@property(nonatomic, assign) double noseHeadWidth;

/// 眉毛粗细
@property(nonatomic, assign) double eyebrowThickness;

/// 眉毛角度
@property(nonatomic, assign) double eyebrowAngle;

/// 眉毛左右
@property(nonatomic, assign) double eyebrowXOffset;

/// 眉毛上下
@property(nonatomic, assign) double eyebrowYOffset;

/// 眼睛宽度
@property(nonatomic, assign) double eyeWidth;

/// 眼睛高度
@property(nonatomic, assign) double eyeHeight;

/// 眼睛弧度
@property(nonatomic, assign) double eyeArc;

/// 眼睛上下
@property(nonatomic, assign) double eyeYOffset;

@end

@interface NveMicroShape (Package)

/// Custom Package
/// Default: nil
/// - Remark:  自定义效果包
/// 默认值：nil

/// 缩头
@property(nonatomic, strong) NSString *headSizePackageId;

/// 颧骨
@property(nonatomic, strong) NSString *malarWidthPackageId;

/// 下颌
@property(nonatomic, strong) NSString *jawWidthPackageId;

/// 太阳穴
@property(nonatomic, strong) NSString *templeWidthPackageId;

/// 眼距
@property(nonatomic, strong) NSString *eyeDistancePackageId;

/// 眼角度
@property(nonatomic, strong) NSString *eyeAnglePackageId;

/// 人中
@property(nonatomic, strong) NSString *philtrumLengthPackageId;

/// 宽鼻梁
@property(nonatomic, strong) NSString *noseBridgeWidthPackageId;

/// 鼻头
@property(nonatomic, strong) NSString *noseHeadWidthPackageId;

/// 眉毛粗细
@property(nonatomic, strong) NSString *eyebrowThicknessPackageId;

/// 眉毛角度
@property(nonatomic, strong) NSString *eyebrowAnglePackageId;

/// 眉毛左右
@property(nonatomic, strong) NSString *eyebrowXOffsetPackageId;

/// 眉毛上下
@property(nonatomic, strong) NSString *eyebrowYOffsetPackageId;

/// 眼睛宽度
@property(nonatomic, strong) NSString *eyeWidthPackageId;

/// 眼睛高度
@property(nonatomic, strong) NSString *eyeHeightPackageId;

/// 眼睛弧度
@property(nonatomic, strong) NSString *eyeArcPackageId;

/// 眼睛上下
@property(nonatomic, strong) NSString *eyeYOffsetPackageId;

@end

NS_ASSUME_NONNULL_END
