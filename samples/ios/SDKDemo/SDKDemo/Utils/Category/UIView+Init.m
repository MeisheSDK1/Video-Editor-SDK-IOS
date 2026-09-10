//
//  UIView+Init.m
//  wankrzhibo
//
//  Created by Xucheng on 14/3/18.
//  Copyright © 2018年 com.wankr. All rights reserved.
//

#import "UIView+Init.h"
#import <NvSDKCommon/NvUtils.h>
@implementation UIView (Init)

- (UILabel *)createLableWithFrame:(CGRect)frame content:(NSString *)content textColor:(UIColor *)color font:(UIFont *)font textAlignme:(NSTextAlignment)alignment numberOfLines:(NSInteger)numberOfLines
{
    UILabel * lable = [[UILabel alloc] init];
    lable.frame = frame;
    lable.text = content;
    lable.textColor = color;
    lable.font = font;
    lable.textAlignment = alignment;
    lable.numberOfLines = numberOfLines;
    [self addSubview:lable];
    return lable;
}

- (UILabel *)createLableWithContent:(NSString *)content textColor:(UIColor *)color font:(UIFont *)font textAlignme:(NSTextAlignment)alignment numberOfLines:(NSInteger)numberOfLines
{
    return [self createLableWithFrame:CGRectZero content:content textColor:color font:font textAlignme:alignment numberOfLines:numberOfLines];
}

- (UILabel *)createLableWithContent:(NSString *)content textColor:(UIColor *)color font:(UIFont *)font textAlignme:(NSTextAlignment)alignment
{
    return [self createLableWithFrame:CGRectZero content:content textColor:color font:font textAlignme:alignment numberOfLines:1];

}

- (UILabel *)createLableWithContent:(NSString *)content textColor:(UIColor *)color font:(UIFont *)font
{
    
    return [self createLableWithFrame:CGRectZero content:content textColor:color font:font textAlignme:NSTextAlignmentLeft numberOfLines:1];
}

- (UIImageView *)createImageViewWithFrame:(CGRect)frame image:(UIImage *)image contentMode:(UIViewContentMode)mode cornerRadius:(CGFloat)cornerRadius clipsToBounds:(BOOL)clipsToBounds
{
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = frame;
    imageView.contentMode = mode;
    imageView.clipsToBounds = clipsToBounds;
    imageView.layer.cornerRadius = cornerRadius;
    if (image != nil) {
        imageView.image = image;
    }
    [self addSubview:imageView];
    return imageView;
}




- (UIImageView *)createImageViewWithFrame:(CGRect)frame image:(UIImage *)image
{
    return [self createImageViewWithFrame:frame image:image contentMode:0 cornerRadius:0 clipsToBounds:0];
}


- (UIImageView *)createImageViewWithImage:(UIImage *)image
{
    return [self createImageViewWithFrame:CGRectZero image:image contentMode:0 cornerRadius:0 clipsToBounds:0];
}


- (UIImageView *)createImageViewWithFrame:(CGRect)frame imageName:(NSString *)imageName contentMode:(UIViewContentMode)mode cornerRadius:(CGFloat)cornerRadius clipsToBounds:(BOOL)clipsToBounds
{
    return [self createImageViewWithFrame:frame image:NvImageNamed(imageName)  contentMode:mode cornerRadius:cornerRadius clipsToBounds:clipsToBounds];

}



- (UIImageView *)createImageViewWithImageName:(NSString *)imageName
{
    return [self createImageViewWithFrame:CGRectZero image:(imageName ? NvImageNamed(imageName) : nil) contentMode:0 cornerRadius:0 clipsToBounds:0];
}

- (UIButton *)createButtonWithTitle:(NSString *)title titleFont:(UIFont *)font image:(UIImage *)image backgroundImage:(UIImage *)backgroundImage  addTarget:( id)target action:( SEL)action
{
   
    return [self createButtonWithTitle:title titleFont:font titleColor:nil image:image backgroundImage:backgroundImage addTarget:target action:action];
}

- (UIButton *)createButtonWithTitle:(NSString *)title titleFont:(UIFont *)font titleColor:(UIColor *)color image:(UIImage *)image backgroundImage:(UIImage *)backgroundImage  addTarget:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (UITextField *)createTextFieldWithPlacehoder:(NSString *)placeholder textColor:(UIColor *)textColor font:(UIFont *)font backgroundColor:(UIColor *)backgroundColor borderStyle:(UITextBorderStyle)borderStyle
{
    UITextField *tf = [[UITextField alloc] init];
    tf.placeholder = placeholder;
    tf.textColor = textColor;
    tf.backgroundColor = backgroundColor;
    tf.borderStyle = borderStyle;
    tf.font = font;
    [self addSubview:tf];
    return tf;
}

- (UIView *)createViewWithColor:(UIColor *)color
{
   return  [self createViewWithColor:color alpha:1];
}
- (UIView *)createViewWithColor:(UIColor *)color alpha:(CGFloat)alpha
{
    UIView *view = [UIView new];
    view.backgroundColor = color;
    view.alpha = alpha;
    [self addSubview:view];
    return view;
}

- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)sel
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGer = [[UITapGestureRecognizer alloc] initWithTarget:target action:sel];

    [self addGestureRecognizer:tapGer];
}

- (void)addLongPressGestureRecognizerWithTarget:(id)target action:(SEL)sel
{
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *tapGer = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:sel];
    [self addGestureRecognizer:tapGer];
}

- (void)addPanGestureRecognizerWithTarget:(id)target action:(SEL)sel
{
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *tapGer = [[UIPanGestureRecognizer alloc] initWithTarget:target action:sel];
    tapGer.delegate = target;
    [self addGestureRecognizer:tapGer];
}

- (UIView *)findSubview:(NSString *)name resursion:(BOOL)resursion
{
    Class class = NSClassFromString(name);
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:class]) {
            return subview;
        }
    }
    
    if (resursion) {
        for (UIView *subview in self.subviews) {
            
            UIView *tempView = [subview findSubview:name resursion:resursion];
            if (tempView) {
                return tempView;
            }
        }
    }
    
    return nil;
}
@end
