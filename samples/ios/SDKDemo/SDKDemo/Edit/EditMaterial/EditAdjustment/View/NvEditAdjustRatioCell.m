//
//  NvEditAdjustRatioCell.m
//  SDKDemo
//
//  Created by MS on 2020/12/2.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditAdjustRatioCell.h"
#import "NVHeader.h"
@implementation NvEditAdjustRatioModel
- (instancetype)init {
    if (self = [super init]) {
        self.isSelected = NO;
    }
    return self;
}
@end

@interface NvEditAdjustRatioCell ()

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UILabel *titleLabel;

@end
@implementation NvEditAdjustRatioCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews{
    
    self.iconView = [[UIImageView alloc]init];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.alpha = 0.8;
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.font = [NvUtils fontWithSize:10 * SCREENSCALE];
    
    [self addSubview:self.iconView];
    [self addSubview:self.titleLabel];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top);
        make.width.mas_equalTo(25 * SCREENSCALE);
        make.height.mas_equalTo(25 * SCREENSCALE);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.iconView.mas_bottom).offset(6 * SCREENSCALE);
    }];
}

-(void)setModel:(NvEditAdjustRatioModel *)model{
    _model = model;
    self.titleLabel.text = model.name;
    if (model.isSelected) {
        self.iconView.image = NvImageNamed(model.selectedImgName);
        self.titleLabel.textColor = [UIColor nv_colorWithHexString:@"#63ABFF"];
    }else{
        self.iconView.image = NvImageNamed(model.normalImgName);
        self.titleLabel.textColor = [UIColor nv_colorWithHexString:@"#FFFFFF"];
    }
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
}

@end
