//
//  UIColor+Hex.m
//  NvSellerShow
//
//  Created by Meicam on 2017/1/10.
//  Copyright © 2017年 Meicam. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha {
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    
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
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)color {
    return [self colorWithHexString:color alpha:1.0f];
}

+ (UIColor *)randomColor {
    CGFloat red = arc4random_uniform(256) / 255.0;
    CGFloat green = arc4random_uniform(256) / 255.0;
    CGFloat blue = arc4random_uniform(256) / 255.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIColor *)randomColorWithAlpha:(CGFloat)alpha {
    CGFloat red = arc4random_uniform(256) / 255.0;
    CGFloat green = arc4random_uniform(256) / 255.0;
    CGFloat blue = arc4random_uniform(256) / 255.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (instancetype)colorWithHexRGBA:(NSString *)rgba {
    
    NSString *hexString = [rgba substringFromIndex:1];
    unsigned int hexInt;
    BOOL result = [[NSScanner scannerWithString:hexString] scanHexInt:&hexInt];
    if (!result)
        return nil;
    
    CGFloat divisor = 255.0;
    CGFloat red = ((hexInt & 0xFF000000) >> 24) / divisor;
    CGFloat green   = ((hexInt & 0x00FF0000) >> 16) / divisor;
    CGFloat blue    = ((hexInt & 0x0000FF00) >>  8) / divisor;
    CGFloat alpha   = ( hexInt & 0x000000FF       ) / divisor;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
}

+ (instancetype)colorWithHexARGB:(NSString *)argb {
    
    NSString *hexString = [argb substringFromIndex:1];
    unsigned int hexInt;
    BOOL result = [[NSScanner scannerWithString:hexString] scanHexInt:&hexInt];
    if (!result) {
        return nil;
    }
    
    CGFloat divisor = 255.0;
    CGFloat alpha = ((hexInt & 0xFF000000) >> 24) / divisor;
    CGFloat red   = ((hexInt & 0x00FF0000) >> 16) / divisor;
    CGFloat green    = ((hexInt & 0x0000FF00) >>  8) / divisor;
    CGFloat blue   = ( hexInt & 0x000000FF       ) / divisor;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
}

+ (instancetype)colorWithHexRGB:(NSString *)rgb {
    
    NSString *hexString = [rgb substringFromIndex:1];
    unsigned int hexInt;
    BOOL result = [[NSScanner scannerWithString:hexString] scanHexInt:&hexInt];
    if (!result) {
        return nil;
    }
    
    CGFloat divisor = 255.0;
    CGFloat red   = ((hexInt & 0x00FF0000) >> 16) / divisor;
    CGFloat green    = ((hexInt & 0x0000FF00) >>  8) / divisor;
    CGFloat blue   = ( hexInt & 0x000000FF       ) / divisor;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
}


@end
