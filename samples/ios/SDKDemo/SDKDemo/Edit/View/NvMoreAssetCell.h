//
//  NvMoreAssetCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvBaseTableViewCell.h"
#import "NvAssetCellModel.h"
#import "NvDownloadBtn.h"

@class NvMoreAssetCell;
@protocol NvMoreAssetCellDelegate <NSObject>

- (void)nvMoreAssetCell:(NvMoreAssetCell *)nvMoreAssetCell nvAssetItem:(NvAssetCellModel *)nvAssetItem;

@end

@interface NvMoreAssetCell : NvBaseTableViewCell

@property (nonatomic, assign) AssetType type;

@property (nonatomic, strong) UIImageView *coverView;

@property (nonatomic, strong) UILabel *nameLabel;
///尺寸，画幅,类型
///Size, frame, type
@property (nonatomic, strong) UILabel *drawLabel;

@property (nonatomic, strong) UILabel *sizeLabel;     

@property (nonatomic, strong) NvAssetCellModel *model;

@property (nonatomic, strong) NvDownloadBtn *download;

@property (nonatomic, weak) id<NvMoreAssetCellDelegate> delegate;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end
