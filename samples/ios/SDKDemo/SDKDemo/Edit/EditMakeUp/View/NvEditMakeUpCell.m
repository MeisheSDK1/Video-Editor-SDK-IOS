//
//  NvEditMakeUpCell.m
//  SDKDemo
//
//  Created by ms on 2021/12/1.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvEditMakeUpCell.h"
#import "NVHeader.h"
#import <YYWebImage/UIImageView+YYWebImage.h>

@interface NvEditMakeUpCell ()

@property (nonatomic, strong) UIImageView *coverView;

@property (nonatomic, assign) CGFloat sizeFloat;
@property (nonatomic, assign) CGFloat sepHeight;
@end

@implementation NvEditMakeUpCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.sizeFloat = frame.size.width;
        self.sepHeight = 7.5*SCREENSCALE;
        
        self.coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.width)];
        self.coverView.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:self.coverView];
        
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.contentView.frame.size.height-self.sepHeight-15 * SCREENSCALE, self.contentView.frame.size.width, 15 * SCREENSCALE)];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.numberOfLines = 2;
        self.nameLabel.textColor = [UIColor nv_colorWithHexString:@"#DDDDDD"];
        self.nameLabel.font = [NvUtils regularFontWithSize:11*SCREENSCALE];
        [self.contentView addSubview:self.nameLabel];
        
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(0);
            make.centerX.mas_equalTo(self.contentView);
            make.width.mas_equalTo(55.0 * SCREENSCALE);
            make.height.mas_equalTo(55.0 * SCREENSCALE);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.coverView.mas_bottom).offset(18.0 * SCREENSCALE);
            make.centerX.mas_equalTo(self.coverView);
            make.width.lessThanOrEqualTo(self.contentView.mas_width);
            
        }];
        [self.contentView layoutIfNeeded];
        self.coverView.layer.cornerRadius = 2.0 * SCREENSCALE;
        self.coverView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)renderCellWithModel:(NvMakeupCellModel *)model{
    self.coverView.image = nil;
    if (model.selected) {
        self.coverView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.coverView.layer.borderWidth = 1.f;
    }else{
        self.coverView.layer.borderColor = [UIColor clearColor].CGColor;
        self.coverView.layer.borderWidth = 0;
    }
    
    if (model.coverImage != nil && ![model.coverImage isEqualToString:@""]) {
        if ([model.coverImage hasPrefix:@"http"]) {
            [self.coverView yy_setImageWithURL:[NSURL URLWithString:model.coverImage] placeholder:NvImageNamed(@"NvDefaultProps")];
        } else {
            UIImage *image = [UIImage imageWithContentsOfFile:model.coverImage];
            if (!image) {
                image = NvImageNamed(model.coverImage);
            }
            if (!image) {
                image = [UIImage imageNamed:model.coverImage];
            }
            self.coverView.image = image;
        }
    }
    self.nameLabel.text = @"";
    if ([NvUtils currentLanguagesIsChinese]){
        self.nameLabel.text = model.displayNameZhCn > 0 ? model.displayNameZhCn : model.displayName;
    }else {
        self.nameLabel.text = model.displayName;
    }
}

-(void)setTextColor:(UIColor *)color{
    self.nameLabel.textColor = color;
}

@end

