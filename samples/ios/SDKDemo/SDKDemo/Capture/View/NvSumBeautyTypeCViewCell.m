//
//  NvSumBeautyTypeCViewCell.m
//  SDKDemo
//
//  Created by MS on 2020/6/20.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvSumBeautyTypeCViewCell.h"
@interface NvSumBeautyTypeCViewCell ()
@property (nonatomic, strong) UILabel *nameLabel;             //外部显示文字 External display text
@property (nonatomic, strong) UIImageView *coverImageView;    //封面图片 Cover picture
@property (nonatomic, strong) UIView *bgView;                 //底背景 background
@property (nonatomic, strong) UIImageView *maskView;          //选中蒙层 Selective mask
@property (nonatomic, strong) UIImageView *maskEditView;      //选中编辑蒙层 Select the Edit mask
@end

@implementation NvSumBeautyTypeCViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

#pragma mark - 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubviews{
    self.bgView = [[UIView alloc]init];
    self.bgView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 4;
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self).offset(-30 * SCREENSCALE);
    }];
    
    self.coverImageView = [[UIImageView alloc] init];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.bgView addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.bgView.mas_width);
        make.height.equalTo(self.bgView.mas_height);
        make.centerX.equalTo(self.bgView);
        make.centerY.equalTo(self.bgView);
    }];
    
    self.maskView = [[UIImageView alloc] init];
    self.maskView.contentMode = UIViewContentModeScaleAspectFit;
    self.maskView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
    [self.bgView addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView);
        make.left.equalTo(self.bgView);
        make.right.equalTo(self.bgView);
        make.bottom.equalTo(self.bgView);
    }];
    
    self.maskEditView = [[UIImageView alloc] init];
    self.maskEditView.contentMode = UIViewContentModeScaleAspectFit;
    [self.bgView addSubview:self.maskEditView];
    [self.maskEditView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView.mas_centerX);
        make.centerY.equalTo(self.bgView.mas_centerY);
        make.width.mas_equalTo(18*SCREENSCALE);
        make.height.mas_equalTo(18*SCREENSCALE);
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = UIColor.whiteColor;
    self.nameLabel.font = [UIFont systemFontOfSize:11*SCREENSCALE];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_bottom).offset(8 * SCREENSCALE);
        make.centerX.equalTo(self.bgView.mas_centerX);
        make.bottom.equalTo(self);
    }];
}

- (void)renderCellWithModel:(NvBeautyTypeModel *)model{
    self.nameLabel.text = NvLocalString(model.name, @"") ;
    UIImage *image = [UIImage imageWithContentsOfFile:model.coverImage];
    if (!image) {
        image = NvImageNamed(model.coverImage);
    }
    self.coverImageView.image = image;
    
    if (model.isOperation) {
        self.coverImageView.alpha = 1;
        if (model.selected) {
            self.maskView.hidden = NO;
            self.maskEditView.image = [UIImage imageNamed:@"nv_beautyType_edit"];
            self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#CC4A90E2"];
        }else{
            self.maskView.hidden = YES;
            self.maskEditView.image = nil;
            self.nameLabel.textColor = [UIColor blackColor];
        }
    }else{
        self.coverImageView.alpha = 0.2;
        self.maskEditView.image = nil;
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#909293"];
        self.bgView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
        self.maskView.hidden = YES;
    }
}



@end
