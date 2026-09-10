//
//  NvThemeShootCVCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2020/8/4.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvThemeShootCVCell.h"
#import "NvThemeShootItemModel.h"
#import "NVHeader.h"
#import "UIImage+YYWebImage.h"

@interface NvThemeShootCVCell()

@end

@implementation NvThemeShootCVCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.coverView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.coverView.contentMode = UIViewContentModeScaleAspectFill;
        self.coverView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.coverView];
        
        self.maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.maskView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#CC4A90E2"];
        [self.contentView addSubview:self.maskView];
        
        UIImageView *maskCover = [[UIImageView alloc]init];
        maskCover.image = [UIImage imageNamed:@"nv_beautyType_edit"];
        maskCover.contentMode = UIViewContentModeScaleAspectFit;
        [self.maskView addSubview:maskCover];
        [maskCover mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.maskView);
            make.top.equalTo(self.maskView).offset(13 * SCREENSCALE);
        }];
        
        UILabel *titleLal = [UILabel new];
        titleLal.textColor = UIColor.whiteColor;
        titleLal.text = NvLocalString(@"Click to edit", @"点击编辑");
        titleLal.font = [NvUtils fontWithSize:10 * SCREENSCALE];
        [self.maskView addSubview:titleLal];
        [titleLal mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.maskView);
            make.top.equalTo(maskCover.mas_bottom).offset(10 * SCREENSCALE);
        }];
        
        self.nameLabel = [UILabel new];
        self.nameLabel.textColor = UIColor.whiteColor;
        self.nameLabel.font = [NvUtils fontWithSize:11 * SCREENSCALE];
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)renderCellWithModel:(NvThemeShootItemModel *)model{
    if (model.coverImage) {
        self.coverView.image = model.coverImage;
    }else{
        self.coverView.image = [UIImage yy_imageWithColor:UIColor.blackColor];
    }
    self.nameLabel.text = model.displayName;
    self.maskView.hidden = !model.selected;
}


@end
