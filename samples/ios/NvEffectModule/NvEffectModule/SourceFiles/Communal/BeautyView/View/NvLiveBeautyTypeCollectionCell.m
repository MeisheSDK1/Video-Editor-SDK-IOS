//
//  NvLiveBeautyTypeCollectionCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/10/20.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvLiveBeautyTypeCollectionCell.h"
#import "NvLiveARSceneUtils.h"
#import "Masonry.h"
#import "UIColor+NvLiveColor.h"
#import "NvLiveBeautyTypeModel.h"
#import "NvLiveAppEnv.h"

@interface NvLiveBeautyTypeCollectionCell ()
/// Display text outside
@property(nonatomic, strong) UILabel *nameLabel; //外部显示文字
/// Cover image
@property(nonatomic, strong) UIImageView *coverImageView; //封面图片
/// Background
@property(nonatomic, strong) UIView *bgView; //底背景
/// Select the mask
@property(nonatomic, strong) UIImageView *maskView; //选中蒙层

@property (nonatomic, strong) UIView *pointView;

@end

@implementation NvLiveBeautyTypeCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 4;
    [self.contentView addSubview:self.bgView];
    CGFloat scale = NvScreen(kScale);
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self).offset(-30 * scale);
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
    self.nameLabel.numberOfLines = 2;
    self.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.nameLabel.font = [UIFont systemFontOfSize:11];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_bottom).offset(0 * scale);
        make.left.right.equalTo(self.bgView);
    }];
    
    self.pointView = [[UIView alloc] init];
    self.pointView.alpha = 0.5;
    self.pointView.layer.cornerRadius = 2.5*scale;
    [self.contentView addSubview:self.pointView];
    [self.pointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(5 * scale);
        make.centerX.equalTo(self.bgView);
        make.width.offset(5 * scale);
        make.height.offset(5 * scale);
    }];
}

- (void)renderCellWithModel:(NvLiveBeautyTypeModel *)model {
    self.maskView.hidden = YES;
    self.coverImageView.layer.borderWidth = 0;
    
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(0*NvScreen(kScale));
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(self.bgView.mas_width);
    }];
    
    self.nameLabel.text = NvLocalString(model.LocalStringKey, model.name);
    self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#3A3A3A"];
    
    if (model.selected){
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGBA:@"#6EA4EC"];
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:model.coverImage];
    if (!image) {
        if (model.selected) {
            image = [NvLiveARSceneUtils imageNamed:model.selectedCoverImg];
        }else{
            image = [NvLiveARSceneUtils imageNamed:model.coverImage];
        }
    }
    
    self.pointView.hidden = model.value != 0?NO:YES;
    self.pointView.backgroundColor = [UIColor nv_colorWithHexRGBA:@"#6EA4EC"];
    self.coverImageView.image = image;
}
@end
