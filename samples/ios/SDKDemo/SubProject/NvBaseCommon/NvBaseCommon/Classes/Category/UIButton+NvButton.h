//
//  UIButton+NvButton.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/25.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (NvButton)

+ (instancetype)nv_buttonWithTitle:(NSString *)title textColor:(UIColor *)textColor;

+ (instancetype)nv_buttonWithTitle:(NSString *)title textColor:(UIColor *)textColor fontSize:(float)fontSize;

+ (instancetype)nv_buttonWithTitle:(NSString *)title textColor:(UIColor *)textColor fontSize:(float)fontSize image:(UIImage *)image;

-(void)nv_BtnClickHandler:(void(^)(void))clickHandler;

@end
