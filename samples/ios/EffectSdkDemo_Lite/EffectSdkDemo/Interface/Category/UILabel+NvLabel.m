//
//  UILabel+NvLabel.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/28.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "UILabel+NvLabel.h"

@implementation UILabel (NvLabel)

+ (instancetype)nv_labelWithText:(NSString *)text fontSize:(float)fontSize textColor:(UIColor *)textColor {
    UILabel *label = [UILabel new];
    label.textColor = textColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
    UIFont *font;
    if (![UIFont fontWithName:@"PingFangSC-Semibold" size:fontSize]) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    } else {
        font = [UIFont fontWithName:@"PingFangSC-Semibold" size:fontSize];
    }
    label.font = font;
    return label;
}

@end
