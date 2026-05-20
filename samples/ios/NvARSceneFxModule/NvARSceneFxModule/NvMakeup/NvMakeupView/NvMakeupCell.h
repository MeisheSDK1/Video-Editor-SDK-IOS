//
//  NvMakeupCell.h
//  SDKDemo
//
//  Created by MS on 2020/7/16.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvMakeupToolModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvMakeupCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *nameLabel;

/// 绑定数据
/// Bind data
/// @param model 美妆数据 Beauty data
- (void)renderCellWithToolDataModel:(NvMakeupToolDataModel *)model;

@end

NS_ASSUME_NONNULL_END
