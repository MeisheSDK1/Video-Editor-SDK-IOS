//
//  NvBoomrangeGraphicBtn.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/13.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvBoomrangeGraphicBtn : UIButton
@property (nonatomic, strong) UILabel *btnLabel;
@property (nonatomic, strong) UIImageView *btnImageView;
+ (instancetype)buttonWithType:(UIButtonType)buttonType withTitle:(NSString *)title withImageNormal:(NSString *)normal withImageSelected:(NSString *)selected;

- (void)setCustomImageSize:(CGSize)imageSize offset:(CGFloat)offset;
- (void)setCustomFontSize:(CGFloat)fontSize;

- (void)setCustomImage:(NSString *)image textColor:(NSString *)colorStr;
@end

