//
//  NvListItemCollectionViewCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2022/3/17.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NvSDKCommon/NvAsset.h>
#import "YYWebImage.h"
#import "NvBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvListItemCollectionViewCell : UICollectionViewCell

/// 素材类型 Material type
@property (nonatomic, assign) AssetType type;

/// 封面 Cover
@property (nonatomic, strong) YYAnimatedImageView *coverView;

/// 素材是否可调节标志 Indicates whether the material is adjustable
@property (nonatomic, strong) UIImageView *adjustMarkView;

/// 选中遮罩层 Select the mask layerv
@property (nonatomic, strong) UIView *coverMaskView;

/// 选中遮罩层的图片 Select the image of the mask layer
@property (nonatomic, strong) UIImageView *coverMaskImageView;

/// 选中遮罩层外边距 Select the mask margin
@property (nonatomic, strong) CALayer *coverlayer;

/// 下载状态图标 Download status icon
@property (nonatomic, strong) YYAnimatedImageView *downloadView;

/// 滤镜名称 Filter name
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong, readonly) NvBaseModel *model;
/**
 配置数据
 Configuration data
 @param model 数据模型
 */
-(void)configData:(NvBaseModel *)model;

- (void)setState:(DownloadState)state;

@end

NS_ASSUME_NONNULL_END
