//
//  NvFontColloCollectionViewCell.m
//  SDKDemo
//
//  Created by Meicam on 2018/6/7.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvFontCollectionViewCell.h"
#import "NVHeader.h"
#import <UIImageView+YYWebImage.h>

@interface NvFontCollectionViewCell()

@end

@implementation NvFontCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.coverView.contentMode = UIViewContentModeScaleAspectFit;
        self.nameLabel.hidden = YES;
        [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(6*SCREENSCALE));
            make.right.equalTo(@(-6*SCREENSCALE));
            make.top.equalTo(@(6*SCREENSCALE));
            make.bottom.equalTo(@(0*SCREENSCALE));
        }];
        
        [self.maskView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(6*SCREENSCALE));
            make.right.equalTo(@(-6*SCREENSCALE));
            make.top.equalTo(@(6*SCREENSCALE));
            make.bottom.equalTo(@(0*SCREENSCALE));
        }];
        [self.downloadMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(6*SCREENSCALE));
            make.right.equalTo(@(-6*SCREENSCALE));
            make.top.equalTo(@(6*SCREENSCALE));
            make.bottom.equalTo(@(0*SCREENSCALE));
        }];
    }
    return self;
}

- (void)renderCellWithItem:(NvCaptionFontItem *)item {
    [super renderCellWithModel:item];
    if (self.selectColor) {
        self.maskView.backgroundColor = self.selectColor;
    }
}

@end
