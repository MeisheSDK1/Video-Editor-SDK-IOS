//
//  NvEditMakeUpCell.h
//  SDKDemo
//
//  Created by ms on 2021/12/1.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvMakeupCellModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvEditMakeUpCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *nameLabel;

/// 绑定数据
/// Bind data
/// @param model 美妆数据 Beauty data
- (void)renderCellWithModel:(NvMakeupCellModel *)model;
-(void)setTextColor:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END

