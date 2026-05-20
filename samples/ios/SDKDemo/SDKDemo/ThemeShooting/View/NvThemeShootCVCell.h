//
//  NvThemeShootCVCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2020/8/4.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NvThemeShootItemModel;
NS_ASSUME_NONNULL_BEGIN

@interface NvThemeShootCVCell : UICollectionViewCell

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIImageView *coverView;

@property (nonatomic, strong) UILabel *nameLabel;

- (void)renderCellWithModel:(NvThemeShootItemModel *)model;

@end

NS_ASSUME_NONNULL_END
