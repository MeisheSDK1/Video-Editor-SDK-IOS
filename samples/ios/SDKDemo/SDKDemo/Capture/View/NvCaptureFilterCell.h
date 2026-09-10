//
//  NvCaptureFilterCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvBaseModel.h"
#import <NvSDKCommon/NvAsset.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvCaptureFilterCell : UICollectionViewCell

/// 资源类型 Resource Type
@property (nonatomic, assign) AssetType type;

/// 绑定数据
/// Bind data
/// @param model 数据模型 Data model 
- (void)renderCellWithModel:(NvBaseModel *)model;

@end

NS_ASSUME_NONNULL_END
