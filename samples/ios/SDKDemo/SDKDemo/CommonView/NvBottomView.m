//
//  NvBottomView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvBottomView.h"
#import "NVHeader.h"

@interface NvBottomView ()

@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIButton *okButton;

@end

@implementation NvBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.okButton setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
        [self addSubview:self.okButton];
        [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.equalTo(@(25*SCREENSCALEHEIGHT));
            make.height.equalTo(@(20*SCREENSCALEHEIGHT));
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALEHEIGHT);
            } else {
                make.bottom.equalTo(@(-15*SCREENSCALEHEIGHT));
            }
        }];
        __weak typeof(self)weakSelf = self;
        [self.okButton nv_BtnClickHandler:^{
            if ([weakSelf.delegate respondsToSelector:@selector(bottomViewOkClick:)]) {
                [weakSelf.delegate bottomViewOkClick:weakSelf];
            }
        }];
        
        self.line = [UIView new];
        self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
        [self addSubview:self.line];
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.left.right.equalTo(@0);
            make.height.equalTo(@1);
            make.bottom.equalTo(self.okButton.mas_top).offset(-12*SCREENSCALE);
        }];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
