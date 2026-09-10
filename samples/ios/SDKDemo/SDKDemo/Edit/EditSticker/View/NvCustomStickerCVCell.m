//
//  NvCustomStickerCVCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/12/12.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCustomStickerCVCell.h"
#import "NVHeader.h"
#import <UIImageView+YYWebImage.h>

@interface NvCustomStickerCVCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIImageView *coverView;

@end

@implementation NvCustomStickerCVCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.coverView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.coverView.contentMode = UIViewContentModeScaleAspectFit;
        self.coverView.layer.cornerRadius = 4 * SCREENSCALE;
        [self.contentView addSubview:self.coverView];
        
        self.maskView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.maskView.contentMode = UIViewContentModeScaleAspectFit;
        self.maskView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
        self.maskView.layer.masksToBounds = YES;
        self.maskView.layer.cornerRadius = 4 * SCREENSCALE;
        [self.contentView addSubview:self.maskView];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.maskView.frame.size.height + 8 * SCREENSCALE, frame.size.width, 15 * SCREENSCALE)];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = UIColor.whiteColor;
        self.nameLabel.alpha = 0.8;
        self.nameLabel.font = [NvUtils regularFontWithSize:11];
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

- (void)renderCellWithItem:(NvAssetCellModel *)item {
    self.coverView.layer.masksToBounds = YES;
    if ([item.cover hasPrefix:@"http"]) {
        [self.coverView yy_setImageWithURL:[NSURL URLWithString:item.cover] placeholder:nil];
    } else {
        self.coverView.image = NvImageNamed(item.cover);
    }
    self.nameLabel.text = item.displayName;
    if (item.selected) {
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        self.maskView.hidden = NO;
    }else{
        self.nameLabel.textColor = UIColor.whiteColor;
        self.maskView.hidden = YES;
    }
}
@end
