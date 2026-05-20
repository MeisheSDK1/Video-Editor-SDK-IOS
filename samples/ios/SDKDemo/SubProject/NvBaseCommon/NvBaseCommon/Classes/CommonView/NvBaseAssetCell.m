//
//  NvBaseAssetCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2019/1/3.
//  Copyright © 2019年 meishe. All rights reserved.
//

#import "NvBaseAssetCell.h"
#import <Masonry/Masonry.h>
#import <NVDefineConfig.h>
#import <UIColor+NvColor.h>
#import <NvBaseUtils.h>
@interface NvBaseAssetCell()


@end

@implementation NvBaseAssetCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.coverView = [[UIImageView alloc]init];
        self.coverView.contentMode = UIViewContentModeScaleToFill;
        self.coverView.layer.cornerRadius = 4 * SCREENSCALE;
        self.coverView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.coverView];
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(6*SCREENSCALE));
            make.right.equalTo(@(-6*SCREENSCALE));
            make.top.equalTo(@(6*SCREENSCALE));
            make.height.equalTo(self.coverView.mas_width);
        }];
        
        self.downloadMaskView = [[UIView alloc]init];
        self.downloadMaskView.backgroundColor = UIColor.blackColor;
        self.downloadMaskView.alpha = 0.4;
        self.downloadMaskView.layer.cornerRadius = 4 * SCREENSCALE;
        self.downloadMaskView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.downloadMaskView];
        [self.downloadMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(6*SCREENSCALE));
            make.right.equalTo(@(-6*SCREENSCALE));
            make.top.equalTo(@(6*SCREENSCALE));
            make.bottom.equalTo(@(-23*SCREENSCALE));
        }];
        
        self.maskView = [[UIImageView alloc]init];
        self.maskView.contentMode = UIViewContentModeScaleAspectFit;
        self.maskView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
        self.maskView.layer.masksToBounds = YES;
        self.maskView.layer.cornerRadius = 4 * SCREENSCALE;
        [self.contentView addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.coverView).insets(UIEdgeInsetsZero);
        }];
        
        self.downloadButton = [[NvDownloadButton alloc] init];
        [self.contentView addSubview:self.downloadButton];
        self.downloadButton.layer.cornerRadius = 7*SCREENSCALE;
        self.downloadButton.layer.masksToBounds = YES;
        [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(@0);
            make.width.height.equalTo(@(14*SCREENSCALE));
        }];
        
        self.nameLabel = [[UILabel alloc]init];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = UIColor.whiteColor;
        self.nameLabel.alpha = 0.8;
        self.nameLabel.numberOfLines = 2;
        self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.nameLabel.font = [NvBaseUtils fontWithSize:12];
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.coverView);
            make.right.equalTo(self.coverView);
            make.centerY.equalTo(self.maskView.mas_bottom).offset(18*SCREENSCALE);
        }];
    }
    return self;
}

- (void)renderCellWithModel:(NvBaseModel *)model{
    self.coverView.image = nil;
    if ([model.coverName hasPrefix:@"http"]) {
        [self.coverView yy_setImageWithURL:[NSURL URLWithString:model.coverName] placeholder:NvImageNamed(model.coverDefault)];
    } else {
        self.coverView.image = NvImageNamed(model.coverName);
    }
    if (model.state == Finish) {
        self.downloadButton.hidden = YES;
        self.downloadButton.status = NvFinish;
        self.downloadMaskView.hidden = YES;
    } else if (model.state == NODownload) {
        self.downloadButton.hidden = NO;
        self.downloadMaskView.hidden = NO;
        self.downloadButton.status = NvNoDownload;
    } else if (model.state == Downloading) {
        self.downloadButton.hidden = NO;
        self.downloadMaskView.hidden = NO;
        self.downloadButton.status = NvDownloading;
    } else {
        self.downloadButton.hidden = NO;
        self.downloadMaskView.hidden = NO;
        self.downloadButton.status = NvNoDownload;
    }
    self.nameLabel.text = model.displayName;
    if (model.selected) {
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        self.maskView.hidden = NO;
    }else{
        self.nameLabel.textColor = UIColor.whiteColor;
        self.maskView.hidden = YES;
    }
}

@end
