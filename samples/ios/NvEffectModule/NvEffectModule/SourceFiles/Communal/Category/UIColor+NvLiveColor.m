//
//  UIColor+NvLiveColor.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/24.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "UIColor+NvLiveColor.h"

@implementation UIColor (NvColor)

+ (UIColor *)nv_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha {
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6) {
        return [UIColor clearColor];
    }

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

//默认alpha值为1
+ (UIColor *)nv_colorWithHexString:(NSString *)color {
    return [self nv_colorWithHexString:color alpha:1.0f];
}

+ (UIColor *)nv_randomColor {
    CGFloat red = arc4random_uniform(256) / 255.0;
    CGFloat green = arc4random_uniform(256) / 255.0;
    CGFloat blue = arc4random_uniform(256) / 255.0;

    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIColor *)nv_randomColorWithAlpha:(CGFloat)alpha {
    CGFloat red = arc4random_uniform(256) / 255.0;
    CGFloat green = arc4random_uniform(256) / 255.0;
    CGFloat blue = arc4random_uniform(256) / 255.0;

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - Create a Color from the string

+ (instancetype)nv_colorWithHexRGBA:(NSString *)rgba {
    NSAssert([rgba hasPrefix:@"#"], @"The color string should start with #");

    NSString *hexString = [rgba substringFromIndex:1];
    unsigned int hexInt;
    BOOL result = [[NSScanner scannerWithString:hexString] scanHexInt:&hexInt];
    if (!result)
        return nil;

    CGFloat divisor = 255.0;
    CGFloat red = ((hexInt & 0xFF000000) >> 24) / divisor;
    CGFloat green = ((hexInt & 0x00FF0000) >> 16) / divisor;
    CGFloat blue = ((hexInt & 0x0000FF00) >> 8) / divisor;
    CGFloat alpha = (hexInt & 0x000000FF) / divisor;

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (instancetype)nv_colorWithHexARGB:(NSString *)argb {
    NSAssert([argb hasPrefix:@"#"], @"The color string should start with #");

    NSString *hexString = [argb substringFromIndex:1];
    unsigned int hexInt;
    BOOL result = [[NSScanner scannerWithString:hexString] scanHexInt:&hexInt];
    if (!result) {
        return nil;
    }

    CGFloat divisor = 255.0;
    CGFloat alpha = ((hexInt & 0xFF000000) >> 24) / divisor;
    CGFloat red = ((hexInt & 0x00FF0000) >> 16) / divisor;
    CGFloat green = ((hexInt & 0x0000FF00) >> 8) / divisor;
    CGFloat blue = (hexInt & 0x000000FF) / divisor;

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (instancetype)nv_colorWithHexRGB:(NSString *)rgb {
    NSAssert([rgb hasPrefix:@"#"], @"The color string should start with #");

    NSString *hexString = [rgb substringFromIndex:1];
    unsigned int hexInt;
    BOOL result = [[NSScanner scannerWithString:hexString] scanHexInt:&hexInt];
    if (!result) {
        return nil;
    }

    CGFloat divisor = 255.0;
    CGFloat red = ((hexInt & 0x00FF0000) >> 16) / divisor;
    CGFloat green = ((hexInt & 0x0000FF00) >> 8) / divisor;
    CGFloat blue = (hexInt & 0x000000FF) / divisor;

    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

//- (NvsColor )NvsColor {
////    __weak typeof(self) weakSelf = self;
////    CGColorRef color = self.CGColor;
//    CGFloat r,g,b,a;
//    [self getRed:&r green:&g blue:&b alpha:&a];
////    NSLog(@"aaaa%f+++%f++++%f",r,g,b);
//
//    NvsColor color ;
//    color.r = r;
//    color.g = g;
//    color.b = b;
//    color.a = a;
//    return color;
//
//}
@end
