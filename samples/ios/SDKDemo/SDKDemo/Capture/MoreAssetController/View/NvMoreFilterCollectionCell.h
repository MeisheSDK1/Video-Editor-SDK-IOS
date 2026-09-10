//
//  NvMoreFilterCollectionCell.h
//  SDKDemo
//
//  Created by MS on 2020/7/27.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvBaseModel.h"
#import "NvDownloadBtn.h"
#import <NvSDKCommon/NvAsset.h>
#import "YYWebImage.h"
NS_ASSUME_NONNULL_BEGIN

@class NvMoreFilterCollectionCell;
@protocol NvMoreFilterCollectionCellDelegate <NSObject>

@optional

/// 下载按钮点击回调
/// Download button click callback
/// @param nvMoreFilterCell 当前对象 Current object
/// @param baseModel 数据模型 Data model
- (void)nvMoreFilterCollectionCell:(NvMoreFilterCollectionCell *)nvMoreFilterCell nvBaseModel:(NvBaseModel *)baseModel;

@end
@interface NvMoreFilterCollectionCell : UICollectionViewCell

/// 素材类型 Material type
@property (nonatomic, assign) AssetType type;

/// 封面 Cover
@property (nonatomic, strong) YYAnimatedImageView *coverView;

/// 滤镜名称 Filter name
@property (nonatomic, strong) UILabel *nameLabel;

/// 滤镜大小 Filter size
@property (nonatomic, strong) UILabel *sizeLabel;

/// 素材的详细划分 2d, 3d等 Detailed division of materials 2d, 3d, etc.
@property (nonatomic, strong) UILabel *categoryLabel;

/// 不适配时阴影view Shadow view when not fit
@property (nonatomic, strong) UIView *unSuitMaskView;

/// 下载失败时阴影view Shadow view when download fails
@property (nonatomic, strong) UIView *errMaskView;

/// 模型数据 Model data
@property (nonatomic, strong) NvBaseModel *model;

/// 下载按钮 Download button
@property (nonatomic, strong) NvDownloadBtn *download;

/// 代理 delegate
@property (nonatomic, weak) id<NvMoreFilterCollectionCellDelegate> delegate;

/// 选中的下标 Selected subscript
@property (nonatomic, strong) NSIndexPath *indexPath;
@end

NS_ASSUME_NONNULL_END
