//
//  NvSumBeautyTypeCViewCell.h
//  SDKDemo
//
//  Created by MS on 2020/6/20.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvBeautyTypeCViewCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvSumBeautyTypeCViewCell : UICollectionViewCell

/// 绑定数据
/// Bind data
/// @param model 数据模型 Data model 
- (void)renderCellWithModel:(NvBeautyTypeModel *)model;
@end

NS_ASSUME_NONNULL_END
