//
//  NvChangeVoiceBottomCell.m
//  SDKDemo
//
//  Created by ms on 2021/3/10.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvChangeVoiceBottomCell.h"
#import "NVHeader.h"
@interface NvChangeVoiceBottomCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation NvChangeVoiceBottomCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubViews];
    }
    return self;
}

#pragma mark - 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubViews{
    
    self.iconView = [[UIImageView alloc]init];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.contentView addSubview:self.iconView];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.contentView.mas_top).offset(2.5f);
        make.width.offset(50  * SCREENSCALE);
        make.height.offset(50 * SCREENSCALE);
    }];
    self.titleLabel = [[UILabel alloc] init];
    [self.iconView addSubview:self.titleLabel];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.font = [UIFont systemFontOfSize:11.0f];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.iconView.mas_centerY);
        make.left.mas_equalTo(2.0f);
        make.right.mas_equalTo(-2.0f);
    }];
    
}


-(void)setBottomModel:(NvVoiceBottomModel *)bottomModel{
    _bottomModel = bottomModel;
    self.titleLabel.text = bottomModel.title;
    if (bottomModel.isSelected) {
        self.iconView.image = NvImageNamed(bottomModel.selectedImage);
        [self.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.top.equalTo(self.contentView.mas_top).offset(2.5);
            make.width.offset(55  * SCREENSCALE);
            make.height.offset(55 * SCREENSCALE);
        }];
    }else{
        self.iconView.image = NvImageNamed(bottomModel.unselectedImage);
        [self.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.top.equalTo(self.contentView.mas_top).offset(5.0f);
            make.width.offset(50  * SCREENSCALE);
            make.height.offset(50 * SCREENSCALE);
        }];
    }
}
@end
