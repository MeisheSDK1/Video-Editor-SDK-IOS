//
//  NvFxCollectionViewCell.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/9/11.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvFilterFxCollectionViewCell.h"
#import "NVHeader.h"

@interface NvFilterFxCollectionViewCell ()


@end

@implementation NvFilterFxCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(6*SCREENSCALE));
            make.right.equalTo(@(-6*SCREENSCALE));
            make.top.equalTo(@(6*SCREENSCALE));
            make.height.equalTo(@(37*SCREENSCALE));
        }];
        [self.maskView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(6*SCREENSCALE));
            make.right.equalTo(@(-6*SCREENSCALE));
            make.top.equalTo(@(6*SCREENSCALE));
            make.height.equalTo(@(37*SCREENSCALE));
        }];
        [self.downloadMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(6*SCREENSCALE));
            make.right.equalTo(@(-6*SCREENSCALE));
            make.top.equalTo(@(6*SCREENSCALE));
            make.height.equalTo(@(37*SCREENSCALE));
        }];
        CGFloat w = frame.size.width - 12*SCREENSCALE;
        CGFloat h = 37*SCREENSCALE;
        self.coverView.layer.cornerRadius = w>h?h/2:w/2;
        self.downloadMaskView.layer.cornerRadius = self.coverView.layer.cornerRadius;
    }
    return self;
}

- (void)renderCellWithModel:(NvFilterFxModel *)model {
    [super renderCellWithModel:model];
    if ([model.imagePath hasPrefix:@"http"]) {
        [self.coverView yy_setImageWithURL:[NSURL URLWithString:model.imagePath] placeholder:NvImageNamed(model.coverDefault)];
    } else {
        UIImage *image = [UIImage imageWithContentsOfFile:model.imagePath];
        self.coverView.image = image;
    }
}

@end
