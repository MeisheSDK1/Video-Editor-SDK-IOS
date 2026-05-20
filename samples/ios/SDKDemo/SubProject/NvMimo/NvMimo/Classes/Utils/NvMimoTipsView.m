//
//  NvPermissionsView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/31.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMimoTipsView.h"
#import <Masonry/Masonry.h>

#import "NvMimoUtils.h"
#import "UIView+Dimension.h"
#import <NvBaseCommon/NVDefineConfig.h>

@interface NvMimoTipsView()

@property (nonatomic, assign) BOOL isVirtual;

@end

@implementation NvMimoTipsView

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
        titleLabel.font = [NvMimoUtils regularFontWithSize:15];
        [backView addSubview:titleLabel];
        
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            if (center) {
                make.centerY.equalTo(self).offset(- 100*SCREANSCALE);
            }else{
                make.top.equalTo(self).offset(124*SCREANSCALE);
            }
            make.left.equalTo(@(55*SCREANSCALE));
            make.right.equalTo(@(-55*SCREANSCALE));
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(backView);
            make.centerY.equalTo(backView);
            make.top.equalTo(@(10*SCREANSCALE));
            make.bottom.equalTo(@(-10*SCREANSCALE));
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
- (void)addSubviews:(NSString *)prompt describeTitle:(NSString *)title describeContent:(NSString *)content buttonText:(NSString *)text center:(BOOL)center{
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.textColor = UIColor.whiteColor;
    contentLabel.text = content;
    contentLabel.font = [NvMimoUtils fontWithSize:12 * SCREANSCALE];
    
    UIView *viewBox = [UIView new];
    viewBox.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4D4F51"];
    viewBox.layer.cornerRadius = 8 * SCREANSCALE;
    
    UILabel *promptLabel = [UILabel new];
    promptLabel.text = prompt;
    promptLabel.textColor = UIColor.whiteColor;
    promptLabel.font = [NvMimoUtils fontWithSize:15 * SCREANSCALE];
    
    UILabel *line = [UILabel new];
    line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#26FFFFFF"];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.text = title;
    titleLabel.font = [NvMimoUtils fontWithSize:17 * SCREANSCALE];
    
    UILabel *line1 = [UILabel new];
    line1.backgroundColor = [UIColor nv_colorWithHexARGB:@"#26FFFFFF"];
    
    self.clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.clickBtn setTitle:text forState:UIControlStateNormal];
    [self.clickBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    self.clickBtn.titleLabel.font = [NvMimoUtils fontWithSize:15 * SCREANSCALE];
    
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
            make.top.equalTo(self).offset(150 * SCREANSCALE + NV_STATUSBARHEIGHT);
        }
        make.centerX.equalTo(self.mas_centerX);
        make.left.equalTo(@(55 * SCREANSCALE));
        make.right.equalTo(@(-55*SCREANSCALE));
    }];
    
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewBox.mas_top).offset(10 * SCREANSCALE);
        make.centerX.equalTo(viewBox.mas_centerX);
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(promptLabel.mas_bottom).offset(10 * SCREANSCALE);
        make.left.equalTo(viewBox.mas_left).offset(7 * SCREANSCALE);
        make.right.equalTo(viewBox.mas_right).offset(-7 * SCREANSCALE);
        make.height.offset(1 * SCREANSCALE);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line.mas_bottom).offset(10 * SCREANSCALE);
        make.left.equalTo(viewBox.mas_left).offset(15 * SCREANSCALE);
        make.right.equalTo(viewBox.mas_right).offset(-15 * SCREANSCALE);
        make.centerX.equalTo(viewBox.mas_centerX);
    }];
    
    if (content) {
        [viewBox addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(5 * SCREANSCALE);
            make.centerX.equalTo(viewBox.mas_centerX);
        }];
    }
    
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        if (content) {
            make.top.equalTo(contentLabel.mas_bottom).offset(10 * SCREANSCALE);
        }else{
            make.top.equalTo(titleLabel.mas_bottom).offset(10 * SCREANSCALE);
        }
        make.left.equalTo(viewBox.mas_left).offset(7 * SCREANSCALE);
        make.right.equalTo(viewBox.mas_right).offset(-7 * SCREANSCALE);
        make.height.offset(1 * SCREANSCALE);
    }];
    
    if (self.isVirtual) {
        self.clickBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.clickBtn1 setTitle:NvLocalStringFromTable([self class], @"Don't Tip", @"不再提醒") forState:UIControlStateNormal];
        [self.clickBtn1 setTitleColor:[UIColor nv_colorWithHexARGB:@"#80FFFFFF"] forState:UIControlStateNormal];
        self.clickBtn1.titleLabel.font = [NvMimoUtils fontWithSize:15 * SCREANSCALE];
        [viewBox addSubview:self.clickBtn1];
        
        [self.clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line1.mas_bottom).offset(5 * SCREANSCALE);
            make.left.equalTo(viewBox.mas_left).offset(30 * SCREANSCALE);
            make.bottom.equalTo(@(-10*SCREANSCALE));
        }];
        
        [self.clickBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line1.mas_bottom).offset(5 * SCREANSCALE);
            make.right.equalTo(viewBox.mas_right).offset(-30 * SCREANSCALE);
            make.bottom.equalTo(@(-10*SCREANSCALE));
        }];
        
    }else{
        [self.clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line1.mas_bottom).offset(5 * SCREANSCALE);
            make.left.equalTo(viewBox.mas_left);
            make.right.equalTo(viewBox.mas_right);
            make.bottom.equalTo(@(-10*SCREANSCALE));
        }];
    }
}

-(CGSize)getContactHeight:(NSString*)contact font:(UIFont *)font;
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    NSDictionary *attrs = @{NSFontAttributeName : font,NSParagraphStyleAttributeName:style};
    CGSize maxSize = CGSizeMake(266 * SCREANSCALE, MAXFLOAT);

    CGSize size = [contact boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size;
    return size;
}

@end
