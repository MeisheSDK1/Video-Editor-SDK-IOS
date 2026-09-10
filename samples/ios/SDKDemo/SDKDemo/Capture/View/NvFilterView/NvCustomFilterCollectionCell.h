//
//  NvCustomFilterCollectionCell.h
//  SDKDemo
//
//  Created by MS on 2020/7/24.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvCustomFilterCollectionCell : UICollectionViewCell

/// 绑定数据
/// Binding data
/// @param model 数据模型  data model
- (void)renderCellWithModel:(NvBaseModel *)model;
@end

NS_ASSUME_NONNULL_END
