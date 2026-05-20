//
//  NvPrivateAlertView.m
//  SDKDemo
//
//  Created by chengww on 2020/7/24.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvPrivateAlertView.h"
#import "NvAttributeLabel.h"
#import "UIColor+NvColor.h"
#import "NVDefineConfig.h"
#import <NvSDKCommon/NvUtils.h>

@interface NvPrivateAlertView ()<NvAttributeLabelDelegate>
@property (nonatomic, copy) void(^tapHandle)(Response response);
@property (nonatomic, assign) CGSize screenSize;
@property (nonatomic, assign) BOOL isZh;
@end

@implementation NvPrivateAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexString:@"#000000" alpha:0.5];
        self.isZh = [NvUtils currentLanguagesIsChinese];
        self.screenSize = frame.size;
        [self nv_layoutSubviews];
    }
    return self;
}

+ (void)nv_fadeIn:(UIView *)view eventHandle:(void(^)(Response response))handle {
    NvPrivateAlertView *alert = [[NvPrivateAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    alert.tapHandle = handle;
    [view addSubview:alert];
}

- (void)attributeLabel:(NvAttributeLabel *)label didResponseLink:(NSString *)link {
    [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{

    } completion:^(BOOL finished) {

        if ([link isEqualToString:@"service"]) {
            self.tapHandle(kService);
        }else if ([link isEqualToString:@"private"]) {
            self.tapHandle(kPrivate);
        }
    }];
}
- (void)didClickEvent:(UIButton *)sender {
    [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (sender.tag) {
            self.tapHandle(kAgree);
        }else {
            exit(0);
        }
        [self removeFromSuperview];
    }];
}

- (void)nv_layoutSubviews{
    CGFloat containerW = self.screenSize.width - 80 * SCREENSCALE;
    NSString *title = NvLocalString(@"Service Agreement and Privacy Policy", @"服务协议及隐私政策");
    NSMutableAttributedString *content = [self getAttributeContext];
    CGFloat titleH = [title boundingRectWithSize:CGSizeMake(containerW - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[NvUtils mediumFontWithSize:18 * SCREENSCALE]} context:nil].size.height + 2;
    CGFloat contentH = [content boundingRectWithSize:CGSizeMake(containerW  - 60 * SCREENSCALE, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height + 22.5;
    
    CGFloat containerH = 20 * SCREENSCALE + titleH + 18 * SCREENSCALE + contentH + 48 * SCREENSCALE + 10 *SCREENSCALE;
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake((self.screenSize.width - containerW) * 0.5, (self.screenSize.height - containerH) * 0.5, containerW, containerH)];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 4 * SCREENSCALE;
    [self addSubview:containerView];
    
    CGFloat startY = 20 * SCREENSCALE;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, startY, containerW - 20, titleH)];
    titleLabel.text = NvLocalString(@"Service Agreement and Privacy Policy", @"服务协议及隐私政策");
    titleLabel.font = [NvUtils mediumFontWithSize:18 * SCREENSCALE];
    titleLabel.textColor = [UIColor nv_colorWithHexString:@"#333333"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    [containerView addSubview:titleLabel];
    
    startY += (titleH + 18 * SCREENSCALE);
    NvAttributeLabel *contentLabel = [[NvAttributeLabel alloc] initWithFrame:CGRectMake(30 * SCREENSCALE, startY, containerW - 60 * SCREENSCALE, contentH)];
    contentLabel.attriContent = content;
    contentLabel.links = @[@"service",@"private"];
    contentLabel.delegate = self;
    [containerView addSubview:contentLabel];
    
    startY = containerH - 48 * SCREENSCALE;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, startY, containerW, 0.5*SCREENSCALE)];
    lineView.backgroundColor = [UIColor nv_colorWithHexString:@"#292929"];
    [containerView addSubview:lineView];
    startY += 0.5 * SCREENSCALE;
    UIButton *ignoreBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, startY, containerW * 0.5 - 3, 47.5 * SCREENSCALE)];
    [ignoreBtn setTitle:NvLocalString(@"Don't allow", @"暂不使用") forState:UIControlStateNormal];
    [ignoreBtn setTitleColor:[UIColor nv_colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    ignoreBtn.titleLabel.font = [NvUtils mediumFontWithSize:18 * SCREENSCALE];
    ignoreBtn.showsTouchWhenHighlighted = NO;
    ignoreBtn.tag = 0;
    [ignoreBtn addTarget:self action:@selector(didClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:ignoreBtn];
    UIButton *agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(containerW * 0.5 + 3, startY, containerW * 0.5 - 3, 47.5 * SCREENSCALE)];
    [agreeBtn setTitle:NvLocalString(@"Agree", @"同意") forState:UIControlStateNormal];
    [agreeBtn setTitleColor:[UIColor nv_colorWithHexString:@"#407DF8"] forState:UIControlStateNormal];
    agreeBtn.titleLabel.font = [NvUtils mediumFontWithSize:18 * SCREENSCALE];
    agreeBtn.showsTouchWhenHighlighted = NO;
    agreeBtn.tag = 1;
    [agreeBtn addTarget:self action:@selector(didClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:agreeBtn];
}

- (NSMutableAttributedString *)getAttributeContext{
    NSString *str = NvLocalString(@"Please read carefully and fully understand the terms and descriptions of the “Service Agreement” and “Privacy Policy”,Meishe only provides services such as video editing and shooting, and will not collect your personal information.\nYou can read the “Service Agreement” and “Privacy Policy” for details. If you agree, please click “Agree” to start accepting our service.", @"请您务必审慎阅读并充分理解“服务协议”和“隐私政策”的各项条款及说明，美摄仅提供视频后期编辑及拍摄等服务，不会收集您的个人信息。\n您可阅读《服务协议》和《隐私政策》了解详细信息。如果您同意，请点击“同意”开始接受我们的服务。");
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attriStr addAttribute:NSForegroundColorAttributeName value:[UIColor nv_colorWithHexString:@"#333333"] range:NSMakeRange(0, str.length)];
    [attriStr addAttribute:NSFontAttributeName value:[NvUtils mediumFontWithSize:15 * SCREENSCALE] range:NSMakeRange(0, str.length)];
    [attriStr addAttribute:NSKernAttributeName value:[NSNumber numberWithInt:0] range:NSMakeRange(0, str.length)];
    NSRange serviceRange = NSMakeRange(self.isZh ? 69 : 249, self.isZh ? 6 : 19);
    NSRange privateRange = NSMakeRange(self.isZh ? 76 : 272, self.isZh ? 6 : 17);
    [attriStr addAttribute:NSForegroundColorAttributeName value:[UIColor nv_colorWithHexString:@"#407DF8"] range:serviceRange];
    [attriStr addAttribute:NSForegroundColorAttributeName value:[UIColor nv_colorWithHexString:@"#407DF8"] range:privateRange];
    [attriStr addAttribute:NSLinkAttributeName value:@"service://" range:serviceRange];
    [attriStr addAttribute:NSLinkAttributeName value:@"private://" range:privateRange];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.lineSpacing = 2.5;
    [attriStr addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, str.length)];
    return attriStr;
}

@end



