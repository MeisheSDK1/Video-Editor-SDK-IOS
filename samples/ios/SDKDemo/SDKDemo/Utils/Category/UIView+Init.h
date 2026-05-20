//
//  UIView+Init.h
//  wankrzhibo
//
//  Created by Xucheng on 14/3/18.
//  Copyright © 2018年 com.wankr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Init)

#pragma mark  ---- 创建label Create label

- (UILabel *)createLableWithFrame:(CGRect)frame content:(NSString *)content textColor:(UIColor *)color font:(UIFont *)font textAlignme:(NSTextAlignment)alignment numberOfLines:(NSInteger)numberOfLines;
- (UILabel *)createLableWithContent:(NSString *)content textColor:(UIColor *)color font:(UIFont *)font textAlignme:(NSTextAlignment)alignment numberOfLines:(NSInteger)numberOfLines;
- (UILabel *)createLableWithContent:(NSString *)content textColor:(UIColor *)color font:(UIFont *)font textAlignme:(NSTextAlignment)alignment;
- (UILabel *)createLableWithContent:(NSString *)content textColor:(UIColor *)color font:(UIFont *)font;

#pragma mark  ---- 创建ImageView Create ImageView

- (UIImageView *)createImageViewWithFrame:(CGRect)frame image:(UIImage *)image contentMode:(UIViewContentMode)mode cornerRadius:(CGFloat)cornerRadius clipsToBounds:(BOOL)clipsToBounds;
- (UIImageView *)createImageViewWithFrame:(CGRect)frame imageName:(NSString *)imageName contentMode:(UIViewContentMode)mode cornerRadius:(CGFloat)cornerRadius clipsToBounds:(BOOL)clipsToBounds;
- (UIImageView *)createImageViewWithFrame:(CGRect)frame image:(UIImage *)image;
- (UIImageView *)createImageViewWithImageName:(NSString *)imageName;
- (UIImageView *)createImageViewWithImage:(UIImage *)image;

#pragma mark  ---- 创建button Create button

- (UIButton *)createButtonWithTitle:(NSString *)title titleFont:(UIFont *)font image:(UIImage *)image backgroundImage:(UIImage *)backgroundImage  addTarget:( id)target action:( SEL)action;
- (UIButton *)createButtonWithTitle:(NSString *)title titleFont:(UIFont *)font titleColor:(UIColor *)color image:(UIImage *)image backgroundImage:(UIImage *)backgroundImage  addTarget:( id)target action:( SEL)action;

#pragma mark  ---- textField Create textField

- (UITextField *)createTextFieldWithPlacehoder:(NSString *)placeholder textColor:(UIColor *)textColor font:(UIFont *)font backgroundColor:(UIColor *)backgroundColor borderStyle:(UITextBorderStyle)borderStyle;

#pragma mark  ---- 创建view Create view
- (UIView *)createViewWithColor:(UIColor *)color;
- (UIView *)createViewWithColor:(UIColor *)color alpha:(CGFloat)alpha;


#pragma mark  ---- mark 创建手势 Create gesture
- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)sel;
- (void)addLongPressGestureRecognizerWithTarget:(id)target action:(SEL)sel;
- (void)addPanGestureRecognizerWithTarget:(id)target action:(SEL)sel;

- (UIView *)findSubview:(NSString *)name resursion:(BOOL)resursion;

@end
