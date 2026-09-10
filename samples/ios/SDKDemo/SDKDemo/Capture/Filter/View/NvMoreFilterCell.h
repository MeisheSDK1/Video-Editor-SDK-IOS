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
#import "NvAsset.h"

@class NvMoreFilterCell;
@protocol NvMoreFilterCellDelegate <NSObject>

@optional
- (void)nvMoreFilterCell:(NvMoreFilterCell *)nvMoreFilterCell nvBaseModel:(NvBaseModel *)baseModel;

@end

@interface NvMoreFilterCell : NvBaseTableViewCell

@property (nonatomic, assign) AssetType type;

@property (nonatomic, strong) UIImageView *coverView; //封面

@property (nonatomic, strong) UILabel *nameLabel;      //滤镜名称

@property (nonatomic, strong) UILabel *drawLabel;      //尺寸，画幅,类型

@property (nonatomic, strong) UILabel *sizeLabel;      //滤镜大小

@property (nonatomic, strong) NvBaseModel *model;

@property (nonatomic, strong) NvDownloadBtn *download;

@property (nonatomic, weak) id<NvMoreFilterCellDelegate> delegate;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end
