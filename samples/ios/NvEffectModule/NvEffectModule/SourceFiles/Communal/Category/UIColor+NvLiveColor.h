//
//  UIColor+NvLiveColor.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/24.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (NvColor)

+ (UIColor *)nv_colorWithHexString:(NSString *)color;

//Get the color from the hexadecimal string
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)nv_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

+ (instancetype)nv_colorWithHexRGBA:(NSString *)rgba;

+ (instancetype)nv_colorWithHexRGB:(NSString *)rgb;

+ (instancetype)nv_colorWithHexARGB:(NSString *)argb;

+ (UIColor *)nv_randomColor;

+ (UIColor *)nv_randomColorWithAlpha:(CGFloat)alpha;

//@property(nonatomic, assign) NvsColor NvsColor;
//- (NvsColor *)NvsColorWithColor ;
@end
