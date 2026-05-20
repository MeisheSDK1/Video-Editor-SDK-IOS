//
//  NvThemeCell.m
//  SDKDemo
//
//  Created by Meicam on 2018/6/28.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvThemeCell.h"
#import "NVHeader.h"
#import <UIImageView+YYWebImage.h>

@interface NvThemeCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *noneImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UIImageView *coverImage;

@end

@implementation NvThemeCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        ///要显示的填充图片
        ///The fill picture to display
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = 4.0f;
        self.noneImageView = [UIImageView new];
        self.noneImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.nameLabel = [UILabel nv_labelWithText:@"无" fontSize:15 textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"]];
        self.nameLabel.font = [NvUtils fontWithSize:11];
        self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.selectView = [UIView new];
        self.selectView.backgroundColor = [[UIColor nv_colorWithHexRGB:@"#52D3FF"] colorWithAlphaComponent:.7];
        self.selectView.layer.cornerRadius = 4.0f;
        self.selectView.layer.masksToBounds = YES;
        self.coverImage = [UIImageView new];
        self.coverImage.backgroundColor = [UIColor grayColor];
        self.coverImage.alpha = 0.8;
        
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.noneImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.selectView];
        [self.contentView addSubview:self.coverImage];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(@0);
            make.height.equalTo(@(49*SCREENSCALE));
        }];
        [self.noneImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(@(12*SCREENSCALE));
            make.right.equalTo(@(-12*SCREENSCALE));
            make.height.equalTo(@(25*SCREENSCALE));
        }];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(8*SCREENSCALE);
            make.centerX.equalTo(self.imageView);
            make.left.equalTo(@3);
            make.right.equalTo(@(-3));
        }];
        
        [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.imageView);
        }];
        [self.coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.imageView);
        }];
    }
    return self;
}


- (void)renderCellWithItem:(NvCaptionThemeItem *)item {
    if (item.isSelect) {
        self.selectView.hidden = NO;
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    } else {
        self.selectView.hidden = YES;
        self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    }
    if ([item.imageUrl containsString:@"http"]) {
        [self.imageView yy_setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholder:nil];
        self.imageView.hidden = NO;
        self.noneImageView.hidden = YES;
    } else if ([item.imageUrl containsString:@"Bundle"]) {
        [self.imageView setImage:[UIImage imageWithContentsOfFile:item.imageUrl]];
        self.imageView.hidden = NO;
        self.noneImageView.hidden = YES;
    } else {
        self.imageView.hidden = YES;
        self.noneImageView.hidden = NO;
        self.noneImageView.image = NvImageNamed(item.imageUrl);
    }
    
    ///如果安装不成功点击使其没有UI效果，加蒙层
    ///If the installation is unsuccessful click so that it has no UI effect, add the layer
    if (!item.isInstall) {
        self.coverImage.hidden = NO;
    } else {
        self.coverImage.hidden = YES;
    }
    
    self.nameLabel.text = item.name;
}

@end
