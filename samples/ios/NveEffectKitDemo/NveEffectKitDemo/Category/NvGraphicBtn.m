//
//  NvGraphicBtn.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/13.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvGraphicBtn.h"
#import "Masonry.h"
#import "NvLiveAppEnv.h"

@interface NvGraphicBtn ()

@property(nonatomic, strong) NSString *normalString;

@property(nonatomic, strong, readwrite) UIImageView *btnImageView;

@end

@implementation NvGraphicBtn

+ (instancetype)buttonWithTag:(NSInteger)buttonTag withTitle:(NSString *)title withImageNormal:(NSString *)normal withImageSelected:(NSString *)selected {
    NvGraphicBtn *btn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom];
    btn.exclusiveTouch = YES;
    if (btn) {
        btn.tag = buttonTag;
        btn.normalString = normal;
        btn.btnImageView = [[UIImageView alloc] init];
        btn.btnImageView.tintColor = [UIColor whiteColor];
        btn.btnImageView.contentMode = UIViewContentModeCenter; //UIViewContentModeScaleAspectFit;
        if (selected) {
            btn.selectedString = selected;
            if (btn.isSelected) {
                btn.btnImageView.image = [UIImage imageNamed:selected];
            } else {
                btn.btnImageView.image = [UIImage imageNamed:normal];
            }
        } else {
            btn.btnImageView.image = [UIImage imageNamed:normal];
        }
        [btn addSubview:btn.btnImageView];
        [btn.btnImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btn);
            make.centerX.equalTo(btn);
            make.width.offset(30 * NvScreen(kScale));
            make.height.offset(30 * NvScreen(kScale));
        }];

        btn.btnLabel = [[UILabel alloc] init];
        btn.btnLabel.text = title;
        btn.btnLabel.textAlignment = NSTextAlignmentCenter;
        btn.btnLabel.font = [UIFont systemFontOfSize:11];
        btn.btnLabel.textColor = UIColor.whiteColor;
        [btn addSubview:btn.btnLabel];
        [btn.btnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btn.btnImageView.mas_bottom);
            make.left.right.offset(0);
            make.centerX.equalTo(btn);
            make.bottom.equalTo(btn);
        }];
    }
    return btn;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.selectedString) {
        if (selected) {
            self.btnImageView.image = [UIImage imageNamed:self.selectedString];
        } else {
            self.btnImageView.image = [UIImage imageNamed:self.normalString];
        }
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    //    self.btnImageView.tintColor = enabled?[UIColor whiteColor]:[UIColor lightGrayColor];
    //    self.btnLabel.textColor = enabled?[UIColor whiteColor]:[UIColor lightGrayColor];
}

@end
