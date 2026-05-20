//
//  NvGraphicBtn.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/13.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvGraphicBtn : UIButton

/// 按钮的文字 Button text
@property (nonatomic, strong) UILabel *btnLabel;

/// 按钮的图片 Picture of the button
@property (nonatomic, strong) UIImageView *btnImageView;

/// 初始化
/// initialization
/// @param buttonType 按钮类型 buttonType
/// @param title 文字 title
/// @param normal 未点击的图标 Unclicked icon
/// @param selected 点击之后的图标 Click the icon after
+ (instancetype)buttonWithType:(UIButtonType)buttonType withTitle:(NSString *)title withImageNormal:(NSString *)normal withImageSelected:(NSString *)selected;

/// 设置图标的大小和位置
/// Set the size and position of the icon
/// @param imageSize 图标大小 imageSize
/// @param offset 偏移量 offset
- (void)setCustomImageSize:(CGSize)imageSize offset:(CGFloat)offset;

/// 设置字体大小 Set font size
/// @param fontSize 字体大小 font size
- (void)setCustomFontSize:(CGFloat)fontSize;

/// 设置图标和文字颜色
/// Set icon and text color
/// @param image 图标 image
/// @param colorStr 文字颜色 Text color
- (void)setCustomImage:(NSString *)image textColor:(NSString *)colorStr;

/// 设置文本右对齐，向左可延伸
/// Set text rightAligent
- (void)setCustomLabelTextRightAligent;

@end

