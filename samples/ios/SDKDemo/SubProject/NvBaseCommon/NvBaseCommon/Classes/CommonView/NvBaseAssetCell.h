//
//  NvBaseAssetCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2019/1/3.
//  Copyright © 2019年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "NvBaseModel.h"
#import "NvDownloadButton.h"

@interface NvBaseAssetCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UIView *downloadMaskView;

@property (nonatomic, strong) NvDownloadButton *downloadButton;


- (void)renderCellWithModel:(NvBaseModel *)model;

@end
