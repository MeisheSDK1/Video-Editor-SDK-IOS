//
//  NvBeautyTypeCViewCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/10/20.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvBeautyTypeCViewCell.h"
#import "NvARSceneMacro.h"
#import "NvARSceneUtils.h"
#import "Masonry.h"
#import "UIColor+NvColor.h"

@interface NvBeautyTypeCViewCell()
/// Display text outside
@property (nonatomic, strong) UILabel *nameLabel;             //外部显示文字
/// Cover image
@property (nonatomic, strong) UIImageView *coverImageView;    //封面图片
/// Background
@property (nonatomic, strong) UIView *bgView;                 //底背景
/// Select the mask
@property (nonatomic, strong) UIImageView *maskView;          //选中蒙层

@end

@implementation NvBeautyTypeCViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

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
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = UIColor.whiteColor;
    self.nameLabel.font = [UIFont systemFontOfSize:10];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.numberOfLines = 3;
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_bottom).offset(8 * SCREENSCALE);
        make.centerX.equalTo(self.bgView.mas_centerX);
        make.left.right.equalTo(self.bgView);
    }];
}

- (void)renderCellWithModel:(NvBeautyTypeModel *)model{
    self.nameLabel.text = model.name;
    self.maskView.hidden = YES;
    self.bgView.backgroundColor = UIColor.clearColor;
    self.coverImageView.image = [NvARSceneUtils imageWithName:model.coverImage];
    if (model.isOperation) {
        self.coverImageView.alpha = 1;
        if (model.selected) {
            self.coverImageView.image = [NvARSceneUtils imageWithName:model.selectedCoverImg];
            self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#CC4A90E2"];
        }else{
            self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#707070"];
        }
    }else{
        self.coverImageView.alpha = 0.2;
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#909293"];
    }
}
@end
