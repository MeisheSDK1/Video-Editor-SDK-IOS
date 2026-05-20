//
//  NvPermissionsView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/31.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvTipsView.h"

#import <Masonry/Masonry.h>

#import <NvSDKCommon/NvUtils.h>
#import "UIView+Dimension.h"

@interface NvTipsView()

@property (nonatomic, assign) BOOL isVirtual;

@end

@implementation NvTipsView

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withColor:(UIColor *)color withCenter:(BOOL)center{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.userInteractionEnabled = NO;
        UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        backView.backgroundColor = color;
        backView.layer.cornerRadius = 8;
        [self addSubview:backView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        titleLabel.text = title;
        titleLabel.numberOfLines = 0;
        titleLabel.textColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
        titleLabel.font = [NvUtils regularFontWithSize:15];
        [backView addSubview:titleLabel];
        
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            if (center) {
                make.centerY.equalTo(self).offset(- 100*SCREENSCALE);
            }else{
                make.top.equalTo(self).offset(124*SCREENSCALE);
            }
            make.left.equalTo(@(55*SCREENSCALE));
            make.right.equalTo(@(-55*SCREENSCALE));
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(backView);
            make.centerY.equalTo(backView);
            make.top.equalTo(@(10*SCREENSCALE));
            make.bottom.equalTo(@(-10*SCREENSCALE));
        }];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withPrompt:(NSString *)prompt describeTitle:(NSString *)title describeContent:(NSString *)content buttonText:(NSString *)text withCenter:(BOOL)center{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor nv_colorWithHexRGB:@"#000000"] colorWithAlphaComponent:.6];
        [self addSubviews:prompt describeTitle:title describeContent:content buttonText:text center:center];
    }
    return self;
}

- (instancetype)initWithFrameVirtual:(CGRect)frame withPrompt:(NSString *)prompt describeTitle:(NSString *)title describeContent:(NSString *)content buttonText:(NSString *)text withCenter:(BOOL)center{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor nv_colorWithHexRGB:@"#000000"] colorWithAlphaComponent:.6];
        self.isVirtual = YES;
        [self addSubviews:prompt describeTitle:title describeContent:content buttonText:text center:center];
        
    }
    return self;
}

#pragma mark - 初始化视图
/*
 初始化视图
 Initialize the view
 
 @param prompt 提示文字 Prompt text
 @param title 描述的标题，不能为空 The title of the description, cannot be empty
 @param content 描述的内容，可以为空 Description content, can be empty
 @param text 按钮文字内容 Button text content
 @param center 视图是否在中心 Whether the view is in the center
 
 */

- (void)addSubviews:(NSString *)prompt describeTitle:(NSString *)title describeContent:(NSString *)content buttonText:(NSString *)text center:(BOOL)center{
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.textColor = UIColor.whiteColor;
    contentLabel.text = content;
    contentLabel.font = [NvUtils fontWithSize:12 * SCREENSCALE];
    
    UIView *viewBox = [UIView new];
    viewBox.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4D4F51"];
    viewBox.layer.cornerRadius = 8 * SCREENSCALE;
    
    UILabel *promptLabel = [UILabel new];
    promptLabel.text = prompt;
    promptLabel.textColor = UIColor.whiteColor;
    promptLabel.font = [NvUtils fontWithSize:15 * SCREENSCALE];
    
    UILabel *line = [UILabel new];
    line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#26FFFFFF"];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.text = title;
    titleLabel.font = [NvUtils fontWithSize:17 * SCREENSCALE];
    
    UILabel *line1 = [UILabel new];
    line1.backgroundColor = [UIColor nv_colorWithHexARGB:@"#26FFFFFF"];
    
    self.clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.clickBtn setTitle:text forState:UIControlStateNormal];
    [self.clickBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    self.clickBtn.titleLabel.font = [NvUtils fontWithSize:15 * SCREENSCALE];
    
    [self addSubview:viewBox];
    [viewBox addSubview:promptLabel];
    [viewBox addSubview:line];
    [viewBox addSubview:titleLabel];
    [viewBox addSubview:line1];
    [viewBox addSubview:self.clickBtn];
    
    [viewBox mas_makeConstraints:^(MASConstraintMaker *make) {
        if (center) {
            make.centerY.equalTo(self);
        }else{
            make.top.equalTo(self).offset(150 * SCREENSCALE + NV_STATUSBARHEIGHT);
        }
        make.centerX.equalTo(self.mas_centerX);
        make.left.equalTo(@(55 * SCREENSCALE));
        make.right.equalTo(@(-55*SCREENSCALE));
    }];
    
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewBox.mas_top).offset(10 * SCREENSCALE);
        make.centerX.equalTo(viewBox.mas_centerX);
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(promptLabel.mas_bottom).offset(10 * SCREENSCALE);
        make.left.equalTo(viewBox.mas_left).offset(7 * SCREENSCALE);
        make.right.equalTo(viewBox.mas_right).offset(-7 * SCREENSCALE);
        make.height.offset(1 * SCREENSCALE);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line.mas_bottom).offset(10 * SCREENSCALE);
        make.left.equalTo(viewBox.mas_left).offset(15 * SCREENSCALE);
        make.right.equalTo(viewBox.mas_right).offset(-15 * SCREENSCALE);
        make.centerX.equalTo(viewBox.mas_centerX);
    }];
    
    if (content) {
        [viewBox addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(5 * SCREENSCALE);
            make.centerX.equalTo(viewBox.mas_centerX);
        }];
    }
    
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        if (content) {
            make.top.equalTo(contentLabel.mas_bottom).offset(10 * SCREENSCALE);
        }else{
            make.top.equalTo(titleLabel.mas_bottom).offset(10 * SCREENSCALE);
        }
        make.left.equalTo(viewBox.mas_left).offset(7 * SCREENSCALE);
        make.right.equalTo(viewBox.mas_right).offset(-7 * SCREENSCALE);
        make.height.offset(1 * SCREENSCALE);
    }];
    
    if (self.isVirtual) {
        self.clickBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.clickBtn1 setTitle:NvLocalString(@"Don't Tip",NvLocalString(@"Don't Tip", @"不再提醒")) forState:UIControlStateNormal];
        [self.clickBtn1 setTitleColor:[UIColor nv_colorWithHexARGB:@"#80FFFFFF"] forState:UIControlStateNormal];
        self.clickBtn1.titleLabel.font = [NvUtils fontWithSize:15 * SCREENSCALE];
        [viewBox addSubview:self.clickBtn1];
        
        [self.clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line1.mas_bottom).offset(5 * SCREENSCALE);
            make.left.equalTo(viewBox.mas_left).offset(30 * SCREENSCALE);
            make.bottom.equalTo(@(-10*SCREENSCALE));
        }];
        
        [self.clickBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line1.mas_bottom).offset(5 * SCREENSCALE);
            make.right.equalTo(viewBox.mas_right).offset(-30 * SCREENSCALE);
            make.bottom.equalTo(@(-10*SCREENSCALE));
        }];
        
    }else{
        [self.clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line1.mas_bottom).offset(5 * SCREENSCALE);
            make.left.equalTo(viewBox.mas_left);
            make.right.equalTo(viewBox.mas_right);
            make.bottom.equalTo(@(-10*SCREENSCALE));
        }];
    }
}

- (instancetype)initWithTitle:(NSString *)title buttonText:(NSString *)leftText buttonText:(NSString *)rightText{
    self = [super initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self addSubviewsTitle:title buttonText:leftText buttonText:rightText];
        
    }
    return self;
}

- (void)addSubviewsTitle:(NSString *)title buttonText:(NSString *)leftText buttonText:(NSString *)rightText{
    UIView *viewBox = [UIView new];
    viewBox.backgroundColor = UIColor.whiteColor;
    viewBox.layer.cornerRadius = 8 * SCREENSCALE;
    [self addSubview:viewBox];
    [viewBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(267*SCREENSCALE);
        make.center.equalTo(self);
    }];
    
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.textColor = [UIColor nv_colorWithHexRGB:@"#888888"];
    contentLabel.text = title;
    contentLabel.font = [NvUtils fontWithSize:14];
    [viewBox addSubview:contentLabel];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewBox).offset(25*SCREENSCALE);
        make.right.equalTo(viewBox).offset(-25*SCREENSCALE);
        make.top.equalTo(viewBox).offset(25*SCREENSCALE);
    }];
    
    UILabel *lineLabel = [UILabel new];
    lineLabel.alpha = 0.1;
    lineLabel.backgroundColor = [UIColor nv_colorWithHexRGB:@"#888888"];
    [viewBox addSubview:lineLabel];
    [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewBox);
        make.right.equalTo(viewBox);
        make.top.equalTo(contentLabel.mas_bottom).offset(30*SCREENSCALE);
        make.height.offset(0.5);
    }];
    
    UILabel *lineLabel1 = [UILabel new];
    lineLabel1.alpha = 0.1;
    lineLabel1.backgroundColor = [UIColor nv_colorWithHexRGB:@"#888888"];
    [viewBox addSubview:lineLabel1];
    [lineLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(lineLabel.mas_bottom);
        make.width.offset(0.5);
        make.height.offset(42*SCREENSCALE);
        make.bottom.equalTo(viewBox.mas_bottom);
    }];
    
    self.clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.clickBtn setTitle:leftText forState:UIControlStateNormal];
    [self.clickBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#888888"] forState:UIControlStateNormal];
    self.clickBtn.titleLabel.font = [NvUtils fontWithSize:14];
    [viewBox addSubview:self.clickBtn];
    [self.clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineLabel1);
        make.left.equalTo(viewBox);
        make.right.equalTo(lineLabel1.mas_left);
        make.bottom.equalTo(viewBox.mas_bottom);
    }];
    
    self.clickBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.clickBtn1 setTitle:rightText forState:UIControlStateNormal];
    [self.clickBtn1 setTitleColor:[UIColor nv_colorWithHexRGB:@"#63ABFF"] forState:UIControlStateNormal];
    self.clickBtn1.titleLabel.font = [NvUtils fontWithSize:14];
    [viewBox addSubview:self.clickBtn1];
    [self.clickBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineLabel1);
        make.left.equalTo(lineLabel1.mas_right);
        make.right.equalTo(viewBox);
        make.bottom.equalTo(viewBox.mas_bottom);
    }];
}


@end
