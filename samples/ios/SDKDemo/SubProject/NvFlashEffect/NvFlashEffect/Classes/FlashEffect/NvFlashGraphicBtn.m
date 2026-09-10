//
//  NvFlashGraphicBtn.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/13.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvFlashGraphicBtn.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvBaseCommon/NvBaseUtils.h>
#import <NvBaseCommon/UIColor+NvColor.h>

@interface NvFlashGraphicBtn ()



@property (nonatomic, strong) NSString *normalString;

@property (nonatomic, strong) NSString *selectedString;

@end

@implementation NvFlashGraphicBtn

+ (instancetype)buttonWithType:(UIButtonType)buttonType withTitle:(NSString *)title withImageNormal:(NSString *)normal withImageSelected:(NSString *)selected{
    NvFlashGraphicBtn *btn = [NvFlashGraphicBtn buttonWithType:buttonType];
    if (btn) {
        btn.normalString = normal;
        btn.btnImageView = [[UIImageView alloc]init];
        btn.btnImageView.contentMode = UIViewContentModeScaleAspectFit;
        if (selected) {
            btn.selectedString = selected;
            if (btn.isSelected) {
                btn.btnImageView.image = [NvBaseUtils imageNamed:selected inBundle:NvCurrentBundle];
            }else{
                btn.btnImageView.image = [NvBaseUtils imageNamed:normal inBundle:NvCurrentBundle];
            }
        }else{
            btn.btnImageView.image = [NvBaseUtils imageNamed:normal inBundle:NvCurrentBundle];
        }
        [btn addSubview:btn.btnImageView];
        [btn.btnImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(btn);
            make.centerX.mas_equalTo(btn);
            make.width.mas_equalTo(@(33 * SCREENSCALE));
            make.height.mas_equalTo(@(33 * SCREENSCALE));
        }];
        
        btn.btnLabel = [[UILabel alloc]init];
        btn.btnLabel.text = title;
        btn.btnLabel.textAlignment = NSTextAlignmentCenter;
        btn.btnLabel.font = [NvBaseUtils regularFontWithSize:12];
        btn.btnLabel.textColor = UIColor.whiteColor;
        [btn addSubview:btn.btnLabel];
        [btn.btnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(btn.btnImageView.mas_bottom).offset(0);
            make.left.right.mas_equalTo(btn);
        }];
    }
    return btn;
}

- (void)setCustomImageSize:(CGSize)imageSize offset:(CGFloat)offset {
    if (imageSize.width>0 && imageSize.height>0) {
        [self.btnImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@(imageSize.width));
            make.height.mas_equalTo(@(imageSize.height));
        }];
    }
    if (offset>0) {
        [self.btnLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.btnImageView.mas_bottom).offset(offset);
        }];
    }
}

- (void)setCustomFontSize:(CGFloat)fontSize {
    if (fontSize > 0) {
        self.btnLabel.font = [NvBaseUtils regularFontWithSize:fontSize];
    }
}

- (void)setCustomImage:(NSString *)image textColor:(NSString *)colorStr {
    self.btnImageView.image = [NvBaseUtils imageNamed:image inBundle:NvCurrentBundle];
    self.btnLabel.textColor = [UIColor nv_colorWithHexRGB:colorStr];
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (self.selectedString) {
        if (selected) {
            self.btnImageView.image = [NvBaseUtils imageNamed:self.selectedString inBundle:NvCurrentBundle];
        }else{
            self.btnImageView.image = [NvBaseUtils imageNamed:self.normalString inBundle:NvCurrentBundle];
        }
    }
}

@end
