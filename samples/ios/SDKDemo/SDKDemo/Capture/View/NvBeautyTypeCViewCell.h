//
//  NvBeautyTypeCViewCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/10/20.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVHeader.h"
#import "NvMakeupModel.h"

@interface NvBeautyTypeCViewCell : UICollectionViewCell

@property (nonatomic, assign) BOOL drawTemplate;
@property (nonatomic, strong) UIColor *tintColor;

/// 绑定数据
/// Bind data
/// @param model 数据模型 Data model 
- (void)renderCellWithModel:(NvBeautyTypeModel *)model;

/// 绑定数据
/// Bind data
/// @param model 数据模型 Data model
- (void)renderCellWithNewModel:(NvBeautyTypeModel *)model;

/// 绑定数据
/// Bind data
/// @param model 数据模型 Data model
- (void)renderCellWithStyleModel:(NvBeautyTypeModel *)model;


@end
