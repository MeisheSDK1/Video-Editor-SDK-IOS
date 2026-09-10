//
//  NvVoiceTypeCollectionViewCell.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/8/7.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvVoiceTypeCollectionViewCell.h"
#import "NVHeader.h"

@interface NvVoiceTypeCollectionViewCell ()

@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UIImageView *coverImageView;
@property (nonatomic, strong)UILabel *nameLabel;

@end

@implementation NvVoiceTypeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [UIImageView new];
        [self.contentView addSubview:self.imageView];
        self.imageView.layer.cornerRadius = 2*SCREENSCALE;
        self.imageView.layer.masksToBounds = YES;
        
        self.coverImageView = [UIImageView new];
        self.coverImageView.alpha = 0.6;
        [self.contentView addSubview:self.coverImageView];
        self.coverImageView.layer.cornerRadius = 2*SCREENSCALE;
        self.coverImageView.layer.masksToBounds = YES;
        
        self.nameLabel = [UILabel nv_labelWithText:@"" fontSize:12 textColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.nameLabel];
        [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(@0);
            make.height.equalTo(@(49*SCREENSCALE));
        }];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(@(0));
            make.right.equalTo(@(0));
            make.height.equalTo(@(49*SCREENSCALE));
        }];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@0);
            make.top.equalTo(self.coverImageView.mas_bottom).offset(3*SCREENSCALE);
            make.left.right.equalTo(@0);
            make.height.equalTo(@(24*SCREENSCALE));
        }];
    }
    return self;
}


- (void)renderCellWithItem:(NvVoiceItem *)item {
    if (item.isSelect) {
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        self.coverImageView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        self.coverImageView.hidden = NO;
    } else {
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
        self.imageView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4D4F51"];
        self.coverImageView.hidden = YES;
    }
    self.imageView.image = NvImageNamed(item.imagePath);
    self.nameLabel.text = item.name;
}

@end
