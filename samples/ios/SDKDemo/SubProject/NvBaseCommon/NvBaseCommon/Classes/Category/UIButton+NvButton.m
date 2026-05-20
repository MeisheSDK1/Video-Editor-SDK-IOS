//
//  UIButton+NvButton.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/25.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "UIButton+NvButton.h"
#import <objc/runtime.h>

static const void *NvButtonBlockKey = &NvButtonBlockKey;

@implementation UIButton (NvButton)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect bounds = self.bounds;
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}

+ (instancetype)nv_buttonWithTitle:(NSString *)title textColor:(UIColor *)textColor {
    return [[self class]  nv_buttonWithTitle:title textColor:textColor fontSize:-1];
}

+ (instancetype)nv_buttonWithTitle:(NSString *)title textColor:(UIColor *)textColor fontSize:(float)fontSize {
    return [[self class]  nv_buttonWithTitle:title textColor:textColor fontSize:fontSize image:nil];
}

+ (instancetype)nv_buttonWithTitle:(NSString *)title textColor:(UIColor *)textColor fontSize:(float)fontSize image:(UIImage *)image {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    if (image) {
        [button setImage:image forState:UIControlStateNormal];
    }
    if (fontSize != -1) {
        UIFont *font = [UIFont fontWithName:@"PingFangSC-Semibold" size:fontSize];
        if (font) {
            button.titleLabel.font = font;
        } else {
            UIFont *font = [UIFont systemFontOfSize:fontSize];
            button.titleLabel.font = font;
        }
        
    }
    return button;
}

#pragma mark  buttonClickBlock
-(void)nv_BtnClickHandler:(void(^)(void))clickHandler{
    objc_setAssociatedObject(self, NvButtonBlockKey, clickHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(nv_actionTouched:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)nv_actionTouched:(UIButton *)btn{
    void(^block)(void) = objc_getAssociatedObject(self, NvButtonBlockKey);
    if (block) {
        block();
    }
}

@end
