//
//  NvPropViewCell.h
//  SDKDemo
//
//  Created by MS on 2020/7/25.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvPropViewCell : UICollectionViewCell

/// 绑定数据
/// Bind data
/// @param model 数据模型 Data model
- (void)renderCellWithModel:(NvBaseModel *)model;

@end

NS_ASSUME_NONNULL_END
