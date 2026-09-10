//
//  UIColor+NvColor.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/24.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (NvColor)

+ (UIColor *)nv_colorWithHexString:(NSString *)color;
// get a color from a hex string
//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)nv_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

+ (instancetype)nv_colorWithHexRGBA:(NSString *)rgba;

+ (instancetype)nv_colorWithHexRGB:(NSString *)rgb;

+ (instancetype)nv_colorWithHexARGB:(NSString *)argb;

+ (UIColor *)nv_randomColor;

+ (UIColor *)nv_randomColorWithAlpha:(CGFloat)alpha;

@end
