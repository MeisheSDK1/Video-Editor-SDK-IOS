//
//  NvTransitionCollectionViewCell.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/6/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvTransitionCollectionViewCell.h"
#import "NVHeader.h"
#import <UIImageView+YYWebImage.h>
#import <YYImage/YYAnimatedImageView.h>
#import <YYImage/YYImage.h>
//#import "UIImageView+YYWebImage.h"
@interface NvTransitionCollectionViewCell()

@property (nonatomic, strong) UIImageView *noImageView;
@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIImageView *editImageView;

@end

@implementation NvTransitionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.noImageView = [[UIImageView alloc]init];
        self.noImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.imageView = [[YYAnimatedImageView alloc]init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = 4;
        self.imageView.layer.borderWidth = 1.f;
        UIColor *imgLayerColor =[UIColor nv_colorWithHexARGB:@"#30FFFFFF"];
        self.imageView.layer.borderColor = imgLayerColor.CGColor;
        
        self.maskView = [[UIImageView alloc]init];
        self.maskView.backgroundColor = [UIColor nv_colorWithHexString:@"#4A90E2"];
        self.maskView.contentMode = UIViewContentModeScaleAspectFit;
        self.maskView.layer.masksToBounds = YES;
        self.maskView.layer.cornerRadius = 4;
        
        self.nameLabel = [[UILabel alloc]init];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [NvUtils fontWithSize:10*SCREENSCALE];
        self.nameLabel.alpha = 0.8;
        
        [self.contentView addSubview:self.noImageView];
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.maskView];
        [self.contentView addSubview:self.nameLabel];
        self.editImageView = [[UIImageView alloc] initWithImage:NvImageNamed(@"NvHomeFeedback")];
        [self.maskView addSubview:self.editImageView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.left.equalTo(self.contentView.mas_left);
            make.width.mas_equalTo(44*SCREENSCALE);
            make.height.mas_equalTo(44*SCREENSCALE);
        }];
        
        [self.noImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.imageView);
            make.centerX.equalTo(self.imageView);
            make.right.equalTo(self.contentView);
            make.height.offset(44 * SCREENSCALE);
        }];
        
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.left.equalTo(self.contentView.mas_left);
            make.width.mas_equalTo(44*SCREENSCALE);
            make.height.mas_equalTo(44*SCREENSCALE);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(6 * SCREENSCALE);
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
        }];
        
        [self.editImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.offset(12 * SCREENSCALE);
            make.height.offset(12 * SCREENSCALE);
            make.center.equalTo(self.maskView);
        }];
        
    }
    return self;
}

- (void)renderCellWithModel:(NvThransitionModel *)model{
    self.noImageView.hidden = YES;
    self.imageView.hidden = YES;
    self.maskView.hidden = YES;
    if (model.selected) {
        self.maskView.hidden = NO;
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    } else {
        self.maskView.hidden = YES;
        self.nameLabel.textColor = UIColor.whiteColor;
    }
    if ([model.coverName isEqualToString:@"NvsFilterNone"]) {
        self.noImageView.hidden = NO;
        self.noImageView.image = NvImageNamed(model.coverName);
    }else if ([model.coverName containsString:@"https"]||[model.coverName containsString:@"http"]) {
        self.imageView.hidden = NO;
        [self.imageView yy_setImageWithURL:[NSURL URLWithString:model.coverName] options:2];
    }else {
        self.imageView.hidden = NO;
        NSFileManager * fm = [NSFileManager defaultManager];
        UIImage * localImage;
        if ([fm fileExistsAtPath:model.coverName]) {
            
            if ([model.coverName hasSuffix:@".webp"] ||
                [model.coverName hasSuffix:@".gif"]) {
                
                NSData *imageData = [NSData dataWithContentsOfFile:model.coverName];
                YYImage *image = [YYImage imageWithData:imageData];
                localImage = image;
            }else{
                localImage = [UIImage imageWithContentsOfFile:model.coverName];
            }
        }
        self.imageView.image = localImage ? localImage : NvImageNamed(model.coverName);
    }
    self.nameLabel.text = NvLocalString(model.displayName, model.displayName);
}

@end
