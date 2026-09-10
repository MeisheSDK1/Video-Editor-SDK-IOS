//
//  NveShape.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/8.
//

#import "NveItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NveShape : NveItem

/// intensity
/// Value range: -1 ~ 1 , Default: 0
/// - Remark:  强度
/// 取值范围：-1 ~ 1，默认值：0

/// 窄脸
@property(nonatomic, assign) double faceWidth;

/// 小脸
@property(nonatomic, assign) double faceLength;

/// 瘦脸
@property(nonatomic, assign) double faceSize;

/// 额头
@property(nonatomic, assign) double foreheadHeight;

/// 下巴
@property(nonatomic, assign) double chinLength;

/// 大眼
@property(nonatomic, assign) double eyeSize;

/// 眼角
@property(nonatomic, assign) double eyeCornerStretch;

/// 瘦鼻
@property(nonatomic, assign) double noseWidth;

/// 长鼻
@property(nonatomic, assign) double noseLength;

/// 嘴型
@property(nonatomic, assign) double mouthSize;

/// 嘴角
@property(nonatomic, assign) double mouthCornerLift;

@end

@interface NveShape (Package)

/// Custom Package
/// Default: nil
/// - Remark:  自定义效果包
/// 默认值：nil

/// 窄脸
@property(nonatomic, strong) NSString *faceWidthPackageId;

/// 小脸
@property(nonatomic, strong) NSString *faceLengthPackageId;

/// 瘦脸
@property(nonatomic, strong) NSString *faceSizePackageId;

/// 额头
@property(nonatomic, strong) NSString *foreheadHeightPackageId;

/// 下巴
@property(nonatomic, strong) NSString *chinLengthPackageId;

/// 大眼
@property(nonatomic, strong) NSString *eyeSizePackageId;

/// 眼角
@property(nonatomic, strong) NSString *eyeCornerStretchPackageId;

/// 瘦鼻
@property(nonatomic, strong) NSString *noseWidthPackageId;

/// 长鼻
@property(nonatomic, strong) NSString *noseLengthPackageId;

/// 嘴型
@property(nonatomic, strong) NSString *mouthSizePackageId;

/// 嘴角
@property(nonatomic, strong) NSString *mouthCornerLiftPackageId;

@end

NS_ASSUME_NONNULL_END
