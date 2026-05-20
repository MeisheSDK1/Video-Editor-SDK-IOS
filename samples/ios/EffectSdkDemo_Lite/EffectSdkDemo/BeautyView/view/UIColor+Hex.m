//
//  UIColor+Hex.m
//  NvVideoEditor
//
//  Created by chengww on 2021/11/1.
//  Copyright © 2021 MEISHE. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
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
+ (UIColor *)colorWithHexString:(NSString *)color
{
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

+ (NSString *)hexColorString:(NSString *)color {
    NSArray<NSString *> *strs = [color componentsSeparatedByString:@","];
    if (strs.count >= 3) {
        NSString *colorString = @"#";
        NSString *rStr = [self rgb: [[NSDecimalNumber decimalNumberWithString:strs[0]] doubleValue]];
        NSString *gStr = [self rgb: [[NSDecimalNumber decimalNumberWithString:strs[1]] doubleValue]];
        NSString *bStr = [self rgb: [[NSDecimalNumber decimalNumberWithString:strs[2]] doubleValue]];
        colorString = [colorString stringByAppendingString:rStr];
        colorString = [colorString stringByAppendingString:gStr];
        colorString = [colorString stringByAppendingString:bStr];
        return colorString;
    }else {
        return @"#000000";
    }
}
+ (NSString *)rgb:(double)value {
    int ten = 0;
    int sixteen = 0;
    int max = 0;
    int result[20];
    ten = floor(255*value);
    if(ten > 255){
        NSAssert(ten < 255, @"颜色值应在0～1内");
        return nil;
    }
    do{
        sixteen = ten % 16;
        ten = ten / 16;
        
        if(sixteen > 9) {
            sixteen = (sixteen -10)+'A';
            result[max] = sixteen;
            max++;
        }else {
            result[max] = sixteen;
            max++;
        }
    }while (ten != 0);
    
    //显示
    NSMutableString *resultString = [NSMutableString string];
    for(int i=max-1;i>=0;i--) {
        if(result[i] > 9) {
            [resultString appendFormat:@"%c",result[i]];
        }else {
            [resultString appendFormat:@"%d",result[i]];
        }
    }
    if (resultString.length == 1) {
        [resultString insertString:@"0" atIndex:0];
    }
//    NSLog(@"颜色%@+++%f",resultString,value);
    if ([resultString isEqualToString:@"0"]) {
        [resultString appendFormat:@"%@",@"0"];
    }
    return resultString;
}

#pragma mark - 根据字符串创建Color


+ (instancetype)colorWithHexRGBA:(NSString *)rgba {
    NSAssert([rgba hasPrefix:@"#"], @"颜色字符串要以#开头");
    
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
    NSAssert([argb hasPrefix:@"#"], @"颜色字符串要以#开头");
    
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
    NSAssert([rgb hasPrefix:@"#"], @"颜色字符串要以#开头");
    
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
