//
//  NvStyleCollectionViewCell.m
//  SDKDemo
//
//  Created by Meicam on 2018/6/5.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvStyleCollectionViewCell.h"
#import "NVHeader.h"
#import <UIImageView+YYWebImage.h>


@implementation NvStyleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.imageView = [YYAnimatedImageView new];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.noneImageView = [UIImageView new];
        self.noneImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.nameLabel = [UILabel nv_labelWithText:@"无" fontSize:11 textColor:[UIColor nv_colorWithHexRGB:@"#CCFFFFFF"]];
        self.nameLabel.alpha = 0.8;
        self.nameLabel.numberOfLines = 2;
        self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.noneImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(3*SCREENSCALE));
            make.left.right.equalTo(@0);
            make.height.equalTo(@(49*SCREENSCALE));
        }];
        [self.noneImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(3*SCREENSCALE));
            make.left.right.equalTo(@0);
            make.height.equalTo(@(49*SCREENSCALE));
        }];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.imageView.mas_bottom).offset(18*SCREENSCALE);
            make.centerX.equalTo(self.imageView);
            make.width.mas_lessThanOrEqualTo(self.imageView.mas_width);
        }];
        self.coverView = [UIImageView new];
        [self.contentView addSubview:self.coverView];
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.imageView);
        }];
        
    }
    return self;
}

- (void)renderCellWithItem:(NvCaptionStyleItem *)item {
    if (item.isSelect) {
        self.coverView.layer.cornerRadius = 2;
        self.coverView.layer.masksToBounds = YES;
        self.coverView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    } else {
        self.coverView.layer.cornerRadius = 2;
        self.coverView.layer.masksToBounds = YES;
        self.coverView.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    }
    if ([item.imageUrl containsString:@"http"]) {
        
        if ([item.imageUrl hasSuffix:@".webp"] ||
            [item.imageUrl hasSuffix:@".gif"]) {
            [self.imageView yy_setImageWithURL:[NSURL URLWithString:item.imageUrl] options:YYWebImageOptionProgressive];
        }
        else {
            [self.imageView yy_setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholder:nil];
        }
        
        self.noneImageView.hidden = YES;
    } else {
        if ([item.imageUrl isEqualToString:@"NvsFilterNone"]) {
            self.imageView.image = [UIImage new];
            self.noneImageView.hidden = NO;
            self.noneImageView.image = NvImageNamed(item.imageUrl);
        } else if ([item.imageUrl hasSuffix:@".webp"] || [item.imageUrl hasSuffix:@".gif"]) {
            self.noneImageView.hidden = YES;
            [self.imageView yy_setImageWithURL:[NSURL fileURLWithPath:item.imageUrl] options:YYWebImageOptionProgressive];
        }
        else{
            self.noneImageView.hidden = YES;
            self.imageView.image = NvImageNamed(item.imageUrl);
        }
    }
    
    self.nameLabel.text = item.name;
}

@end
