//
//  NvMoreFilterCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvBaseTableViewCell.h"
#import "NvBaseModel.h"
#import "NvDownloadBtn.h"
#import <NvSDKCommon/NvAsset.h>

@class NvMoreFilterCell;
@protocol NvMoreFilterCellDelegate <NSObject>

@optional

/// 下载按钮点击回调
/// Download button click callback
/// @param nvMoreFilterCell 当前对象 Current object
/// @param baseModel 数据模型 Data model
- (void)nvMoreFilterCell:(NvMoreFilterCell *)nvMoreFilterCell nvBaseModel:(NvBaseModel *)baseModel;

@end

@interface NvMoreFilterCell : NvBaseTableViewCell

/// 素材类型 Material type
@property (nonatomic, assign) AssetType type;

/// 封面 Cover
@property (nonatomic, strong) UIImageView *coverView;

/// 滤镜名称 Filter name
@property (nonatomic, strong) UILabel *nameLabel;

/// 尺寸，画幅,类型 Size, frame, type
@property (nonatomic, strong) UILabel *drawLabel;

/// 滤镜大小 Filter size
@property (nonatomic, strong) UILabel *sizeLabel;

/// 模型数据 Model data
@property (nonatomic, strong) NvBaseModel *model;

/// 下载按钮 Download button
@property (nonatomic, strong) NvDownloadBtn *download;

/// 代理 delegate
@property (nonatomic, weak) id<NvMoreFilterCellDelegate> delegate;

/// 选中的下标 Selected subscript
@property (nonatomic, strong) NSIndexPath *indexPath;

@end
