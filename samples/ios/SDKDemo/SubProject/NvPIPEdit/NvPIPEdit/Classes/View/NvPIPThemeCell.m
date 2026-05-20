//
//  NvPIPThemeCell.m
//  SDKDemo
//
//  Created by Meicam on 2018/6/28.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvPIPThemeCell.h"
#import <NvBaseCommon/UIColor+NvColor.h>
#import <NvBaseCommon/UILabel+NvLabel.h>
#import <NvBaseCommon/UIView+Dimension.h>
#import <NvBaseCommon/NVDefineConfig.h>

@interface NvPIPThemeCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *selectView;
//@property (nonatomic, strong) UIImageView *coverImage;

@end

@implementation NvPIPThemeCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        //要显示的填充图片
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = 4.0f;
        
        self.nameLabel = [UILabel nv_labelWithText:@"无" fontSize:15 textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"]];
//        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.selectView = [UIView new];
        self.selectView.backgroundColor = [[UIColor nv_colorWithHexRGB:@"#52D3FF"] colorWithAlphaComponent:.7];
        self.selectView.layer.cornerRadius = 4.0f;
        self.selectView.layer.masksToBounds = YES;
//        self.coverImage = [UIImageView new];
//        self.coverImage.backgroundColor = [UIColor grayColor];
//        self.coverImage.alpha = 0.8;
        
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.selectView];
//        [self.contentView addSubview:self.coverImage];
        
        self.imageView.frame = CGRectMake(0, 0, 49*SCREENSCALE, 49*SCREENSCALE);
        self.nameLabel.frame = CGRectMake(-20*SCREENSCALE, self.imageView.bottom+8*SCREENSCALE, frame.size.width+40*SCREENSCALE, 21*SCREENSCALE);
//        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.imageView.mas_bottom).offset(8*SCREENSCALE);
//            make.centerX.equalTo(self.imageView);
//            make.left.equalTo(@3);
//            make.right.equalTo(@(-3));
//        }];
        
        self.selectView.frame = self.imageView.frame;
//        [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.imageView);
//        }];
//        self.coverImage.frame = self.imageView.frame;
//        [self.coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.imageView);
//        }];
    }
    return self;
}


- (void)renderCellWithItem:(NvPIPThemeItem *)item {
    if (item.isSelect) {
        self.selectView.hidden = NO;
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    } else {
        self.selectView.hidden = YES;
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
    }
    if (item.imageUrl && ![item.imageUrl isEqualToString:@""]) {
        if ([item.imageUrl containsString:@"/"]) {
            [self.imageView setImage:[UIImage imageWithContentsOfFile:item.imageUrl]];
        } else {
            [self.imageView setImage:NvImageNamed(item.imageUrl)];
        }
    } else {
        [self.imageView setImage:[UIImage imageWithContentsOfFile:item.bundleImagePath]];
    }
    
    //如果安装不成功点击使其没有UI效果，加蒙层
//    if (!item.isInstall) {
//        self.coverImage.hidden = NO;
//    } else {
//        self.coverImage.hidden = YES;
//    }
    
    self.nameLabel.text = item.name;
}

@end
