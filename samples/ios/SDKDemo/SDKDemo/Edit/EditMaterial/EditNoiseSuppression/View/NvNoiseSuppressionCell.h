//
//  NvNoiseSuppressionCell.h
//  SDKDemo
//
//  Created by Meishe on 2022/9/9.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvNoiseSuppressionCell : UICollectionViewCell
/// 绑定数据（编辑页面）
/// Bind data
/// @param model 数据模型 Data model
- (void)renderCellWithModel:(NvBaseModel *)model;

/// 绑定数据（拍摄页面）
/// Bind data
/// @param model 数据模型 Data model
- (void)renderCaptureCellWithModel:(NvBaseModel *)model;
@end

NS_ASSUME_NONNULL_END
