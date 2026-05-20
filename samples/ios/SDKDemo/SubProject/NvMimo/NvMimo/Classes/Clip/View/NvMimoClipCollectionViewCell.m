//
//  NvClipCollectionViewCell.m
//  NvMimoDemo
//
//  Created by MS on 2019/8/12.
//  Copyright © 2019 MS. All rights reserved.
//

#import "NvMimoClipCollectionViewCell.h"
#import "NVMimoDefineConfig.h"
#import <UIColor+NvColor.h>
#import <YYWebImage/YYWebImage.h>
#import "NVHeader.h"
#import <NvBaseCommon/NVDefineConfig.h>

@interface NvMimoClipCollectionViewCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *shotNumLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *confirmLabel;
@property (nonatomic, assign) BOOL isSelected;
@end

@implementation NvMimoClipCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#1A1D24"];
        self.confirmLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.confirmLabel];
        [self.confirmLabel setText:NvLocalStringFromTable([self class], @"Confirm", @"使用")];
        self.confirmLabel.textAlignment = NSTextAlignmentCenter;
        self.confirmLabel.backgroundColor = [UIColor nv_colorWithHexRGB:@"#2A7DFF"];
        self.confirmLabel.textColor = [UIColor whiteColor];
        self.confirmLabel.font = [UIFont boldSystemFontOfSize:12*SCREANSCALE];
        [self.confirmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.left.equalTo(self.contentView.mas_left);
            make.height.mas_equalTo(25*SCREANSCALEHEIGHT);
            make.right.equalTo(self.contentView.mas_right);
        }];
        
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.cornerRadius = 2;
        self.imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(@0);
            make.bottom.equalTo(self.confirmLabel.mas_top);
        }];
        
        self.titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13*SCREANSCALE];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(51*SCREANSCALEHEIGHT);
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.height.mas_equalTo(20*SCREANSCALEHEIGHT);
            make.width.mas_equalTo(self.contentView.mas_width);
        }];
        
        self.shotNumLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.shotNumLabel];
        self.shotNumLabel.textAlignment = NSTextAlignmentLeft;
        self.shotNumLabel.textColor = [UIColor whiteColor];
        self.shotNumLabel.font = [UIFont boldSystemFontOfSize:11*SCREANSCALE];
        [self.shotNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.confirmLabel.mas_top).offset(-8*SCREANSCALEHEIGHT);
            make.left.equalTo(self.contentView.mas_left).offset(8*SCREANSCALE);
            make.height.mas_equalTo(15*SCREANSCALEHEIGHT);
            make.right.equalTo(self.contentView.mas_centerX);
        }];
        
        self.durationLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.durationLabel];
        self.durationLabel.textAlignment = NSTextAlignmentRight;
        self.durationLabel.textColor = [UIColor whiteColor];
        self.durationLabel.font = [UIFont boldSystemFontOfSize:11*SCREANSCALE];
        [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.confirmLabel.mas_top).offset(-8*SCREANSCALEHEIGHT);
            make.right.equalTo(self.contentView.mas_right).offset(-8*SCREANSCALE);
            make.height.mas_equalTo(15*SCREANSCALEHEIGHT);
            make.left.equalTo(self.contentView.mas_centerX);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSArray *imgViewConstraints = self.imageView.constraints;
    [self.imageView removeConstraints:imgViewConstraints];
    NSArray *confirmLabelConstraints = self.confirmLabel.constraints;
    [self.confirmLabel removeConstraints:confirmLabelConstraints];
    NSArray *shotLabelConstraints = self.shotNumLabel.constraints;
    [self.shotNumLabel removeConstraints:shotLabelConstraints];
    NSArray *durationLabelConstraints = self.durationLabel.constraints;
    [self.durationLabel removeConstraints:durationLabelConstraints];
    
    if (self.model.isSelected) {
        self.layer.borderWidth = 3*SCREANSCALE;
        self.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#2A7DFF"].CGColor;
        [self.confirmLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.height.mas_equalTo(25*SCREANSCALEHEIGHT);
        }];
        [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.bottom.equalTo(self.confirmLabel.mas_top);
            make.left.right.equalTo(@0);
        }];
        [self.shotNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(8*SCREANSCALE);
            make.height.mas_equalTo(15*SCREANSCALEHEIGHT);
            make.right.equalTo(self.contentView.mas_centerX); make.bottom.equalTo(self.confirmLabel.mas_top).offset(-8*SCREANSCALEHEIGHT);
        }];
        [self.durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(-8*SCREANSCALE);
            make.height.mas_equalTo(15*SCREANSCALEHEIGHT);
            make.left.equalTo(self.contentView.mas_centerX); make.bottom.equalTo(self.confirmLabel.mas_top).offset(-8*SCREANSCALEHEIGHT);
        }];
        
    }else{
        self.layer.borderWidth = 0;
        [self.confirmLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.height.mas_equalTo(0.f);
        }];
        [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(@0);
            make.bottom.equalTo(self.contentView.mas_bottom);
        }];
        [self.shotNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(8*SCREANSCALE);
            make.height.mas_equalTo(15*SCREANSCALEHEIGHT);
            make.right.equalTo(self.contentView.mas_centerX); make.bottom.equalTo(self.contentView.mas_bottom).offset(-8*SCREANSCALEHEIGHT);
        }];
        [self.durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(-8*SCREANSCALE);
            make.height.mas_equalTo(15*SCREANSCALEHEIGHT);
            make.left.equalTo(self.contentView.mas_centerX); make.bottom.equalTo(self.contentView.mas_bottom).offset(-8*SCREANSCALEHEIGHT);
        }];
    
    }
}

- (void)setModel:(NvMimoListModel *)model {
    _model = model;
    [self clear];
    NvThemeModel *themeModel = model.packageInfo;
    for (NvShotTranslationModel *transModel in themeModel.translation) {
        if ([NvMimoUtils currentLanguagesIsChinese]) {
             self.titleLabel.text = transModel.targetText;
        }else{
            self.titleLabel.text = transModel.originalText;
        }
    }
    if (model.localPath.length > 0) {
        NSString *imagePath = [model.localPath stringByAppendingPathComponent:themeModel.cover];
        self.imageView.image = [UIImage imageWithContentsOfFile:imagePath];
    }else if(model.coverUrl.length > 0) {
        [self.imageView yy_setImageWithURL:[NSURL URLWithString:model.coverUrl] placeholder:nil];
    }
    
    self.shotNumLabel.text = themeModel.shotsNumber ? [NSString stringWithFormat:@"%.f  SHOT",themeModel.shotsNumber] : @"";
    self.durationLabel.text = themeModel.musicDuration ? [NSString stringWithFormat:@"%.1f s",themeModel.musicDuration/1000000] : @"";
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        self.layer.borderWidth = 3*SCREANSCALE;
        self.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#2A7DFF"].CGColor;
    }else{
        self.layer.borderWidth = 0;
    }
}

- (void)clear {
    self.titleLabel.text = @"";
    self.durationLabel.text = @"";
    self.shotNumLabel.text = @"";
    self.imageView.image = nil;
}
@end
