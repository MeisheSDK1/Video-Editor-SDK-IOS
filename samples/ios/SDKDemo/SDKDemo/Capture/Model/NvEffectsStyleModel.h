//
//  NvEffectsStyleModel.h
//  SDKDemo
//
//  Created by ms20180425 on 2022/3/23.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvEffectsStyleModel : NSObject<NSCopying,NSMutableCopying>

/// 选中、未选中 Selected or unselected
@property (nonatomic, assign) BOOL selected;
/// 图片名 Picture name
@property (nonatomic, strong) NSString *coverName;
/// 默认图片名 默认图片名
@property (nonatomic, strong) NSString *coverDefault;
/// 界面显示名 Interface display name
@property (nonatomic, strong) NSString *displayName;
/// 美型数组 Beauty array
@property (nonatomic, strong) NSArray *beautifulTypes;
/// 微整形数组 Microshaping array
@property (nonatomic, strong) NSArray *microPlastics;
/// 滤镜id Filter id
@property (nonatomic, strong) NSString *filterPackageId;
/// 滤镜效果值 Filter effect value
@property (nonatomic, assign) CGFloat filterValue;
/// 美白类型 Whitening type
@property (nonatomic, strong) NSString *whiteningType;
/// 美白效果值 Whitening effect value
@property (nonatomic, assign) CGFloat whiteningValue;
/// 磨皮类型 Dermabrasion type
@property (nonatomic, strong) NSString *strengthType;
/// 磨皮效果值 Peeling effect value
@property (nonatomic, assign) CGFloat strengthValue;
/// 美妆id Makeup id
@property (nonatomic, strong) NSString *makeupPackageId;
/// 美妆素材路径 Beauty material path
@property (nonatomic, strong) NSString *makeupPackagePath;
/// 美妆效果值 Beauty effect value
@property (nonatomic, assign) CGFloat makeupValue;
/// 美妆颜色 Beauty color
@property (nonatomic, strong) NSString *makeupColor;

@end

NS_ASSUME_NONNULL_END
