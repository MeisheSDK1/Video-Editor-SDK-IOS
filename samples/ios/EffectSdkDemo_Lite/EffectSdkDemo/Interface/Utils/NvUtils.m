//
//  NvUtils.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/24.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvUtils.h"
#import <sys/utsname.h>
#import "NvConstant.h"
#define allTrim(object) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
#import "NvsEffectSdkContext.h"

@implementation NvUtils

+ (BOOL)isEn {
    NSString *languageStr = NSLocale.preferredLanguages.firstObject;
    BOOL flags = [languageStr hasPrefix:@"en"];
    return flags;
}

+ (NSString *_Nullable)convertTimecode:(int64_t)time {
    time = (time + 550000) / 1000000;
    int min = (int)time / 60;
    int sec = (int)time % 60;
    if (min >= 10 && sec >= 10)
        return [NSString stringWithFormat:@"%d:%d", min, sec];
    else if (min >= 10)
        return [NSString stringWithFormat:@"%d:0%d", min, sec];
    else if (sec >= 10)
        return [NSString stringWithFormat:@"0%d:%d", min, sec];
    else
        return [NSString stringWithFormat:@"0%d:0%d", min, sec];
}

+ (NSString *_Nullable)convertTimecodePrecision:(int64_t)time {
    time += 50000;
    int min = (int)(time / 60000000);
    int sec = (int)((time % 60000000) / 100000);
    int decimal = sec % 10;
    sec /= 10;
    if (min >= 10 && sec >= 10)
        return [NSString stringWithFormat:@"%d:%d.%d", min, sec, decimal];
    else if (min >= 10)
        return [NSString stringWithFormat:@"%d:0%d.%d", min, sec, decimal];
    else if (sec >= 10)
        return [NSString stringWithFormat:@"0%d:%d.%d", min, sec, decimal];
    else
        return [NSString stringWithFormat:@"0%d:0%d.%d", min, sec, decimal];
}

+ (NSMutableArray *)rgbWithColor:(UIColor *)color {
    NSMutableArray *RGBStrValueArr = [[NSMutableArray alloc] init];
    NSString *RGBStr = nil;
    NSString *RGBValue = [NSString stringWithFormat:@"%@",color];
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];
    int r = (int)([[RGBArr objectAtIndex:1] floatValue] * 255);
    RGBStr = [NSString stringWithFormat:@"%d",r];
    [RGBStrValueArr addObject:RGBStr];
    int g = (int)([[RGBArr objectAtIndex:2] floatValue] * 255);
    RGBStr = [NSString stringWithFormat:@"%d",g];
    [RGBStrValueArr addObject:RGBStr];
    int b = (int)([[RGBArr objectAtIndex:3] floatValue] * 255);
    RGBStr = [NSString stringWithFormat:@"%d",b];
    [RGBStrValueArr addObject:RGBStr];
    
    int a = (int)([[RGBArr objectAtIndex:4] floatValue] * 255);
    RGBStr = [NSString stringWithFormat:@"%d",a];
    [RGBStrValueArr addObject:RGBStr];
    return RGBStrValueArr;
}

+ (NSString *)hexStringWithColor:(UIColor *)color {
    NSMutableArray *RGBStrValueArr = [[NSMutableArray alloc] init];
    NSString *RGBStr = nil;
    NSString *RGBValue = [NSString stringWithFormat:@"%@",color];
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];
    
    int r = (int)([[RGBArr objectAtIndex:1] floatValue] * 255);
    RGBStr = [NSString stringWithFormat:@"%d",r];
    [RGBStrValueArr addObject:RGBStr];
    
    int g = (int)([[RGBArr objectAtIndex:2] floatValue] * 255);
    RGBStr = [NSString stringWithFormat:@"%d",g];
    [RGBStrValueArr addObject:RGBStr];
    
    int b = (int)([[RGBArr objectAtIndex:3] floatValue] * 255);
    RGBStr = [NSString stringWithFormat:@"%d",b];
    [RGBStrValueArr addObject:RGBStr];
    
    int a = (int)([[RGBArr objectAtIndex:4] floatValue] * 255);
    RGBStr = [NSString stringWithFormat:@"%d",a];
    [RGBStrValueArr addObject:RGBStr];
    
    return [NSString stringWithFormat:@"#%02x%02x%02x%02x",a,r,g,b];
}

+ (NSString *_Nullable)randomColor{
    NSInteger i = arc4random_uniform(256)+1;
    NSInteger i1 = arc4random_uniform(256)+1;
    NSInteger i2 = arc4random_uniform(256)+1;
    
    NSString *colorString = [NSString stringWithFormat:@"#%@%@%@",[self getHexByDecimal:i],[self getHexByDecimal:i1],[self getHexByDecimal:i2]];
    
    return colorString;
}

+ (NSString *)getHexByDecimal:(NSInteger)decimal {
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", (long)number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    return hex;
}


+ (NSArray *)captionColors {
    return @[@"#ffffffff", @"#ff000000", @"#ffd0021b",
             @"#ff4169e1", @"#ff05d109", @"#ff02c9ff",
             @"#ff9013fe", @"#ff8b6508", @"#ffff0080",
             @"#ff02f78e", @"#ff00ffff", @"#ffffd709",
             @"#ff4876ff", @"#ff19ff2f", @"#ffda70d6",
             @"#ffff6347", @"#ff5b45ae", @"#ff8b1c62",
             @"#ff8b7500", @"#ff228b22", @"#ffc0ff3e",
             @"#ff00Bfff", @"#ffababab", @"#ff6495ed",
             @"#ff0000E3", @"#ffe066ff", @"#fff08080"];
}

+ (NSArray *)rgbColors {
    return @[@"1,1,1,1", @"0,0,0,1", @"0.816,0.008,0.106,1",
             @"0.255,0.412,0.882,1", @"0.020,0.820,0.035,1", @"0.008,0.788,1,1",
             @"0.565,0.075,0.996,1", @"0.545,0.396,0.031,1", @"1,0,0.502,1",
             @"0.008,0.969,0.557,1", @"0,1,1,1", @"1,0.843,0.035,1",
             @"0.282,0.463,1,1", @"0.098,1,0.184,1", @"0.855,0.439,0.839,1",
             @"1,0.388,0.278,1", @"0.357,0.271,0.682,1", @"0.545,0.110,0.384,1",
             @"0.545,0.459,0,1", @"0.133,0.545,0.133,1", @"0.753,1,0.243,1",
             @"0,0.749,1,1", @"0.671,0.671,0.671,1", @"0.392,0.584,0.929,1",
             @"0,0,0.890,1", @"0.878,0.400,1,1", @"0.941,0.502,0.502,1"];
}

+ (UIImage *_Nullable)imageWithName:(NSString *_Nullable)name {
    if (!name)
        return nil;
    return [UIImage imageNamed:name inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

+ (NSString *)getImagePath:(NSString *)name scale:(NSInteger)scale{
    // They get a null value here, so I have to give it a placeholder, we don't have a placeholder, so I just found one
    //他们时候这里会取到空值，那我只能给它一个占位图，我们没有占位图，所以我随便找了一张
    if (name.length == 0 ||scale == 0) {
        name = @"NvsSliderHandle";
    };
    
//    NSURL *bundleUrl = [[NSBundle bundleForClass:self.class] URLForResource:@"ImageBundle" withExtension:@"bundle"];
    NSURL *bundleUrl = [[NSBundle mainBundle] bundleURL];
    if (bundleUrl == nil) {
        return @"";
    }
    NSBundle *customBundle = [NSBundle bundleWithURL:bundleUrl];
    NSString *bundlePath = [customBundle bundlePath];
    NSString *imgPath = [bundlePath stringByAppendingPathComponent:name];
    NSString *pathExtension = [imgPath pathExtension];
    // 没有后缀加上PNG后缀
    // no suffix plus PNG suffix
    if (!pathExtension || pathExtension.length == 0) {
        pathExtension = @"png";
    }
    //Scale是根据屏幕不同选择使用@2x还是@3x的图片
    //Scale uses @2x or @3x images depending on the screen
    NSString *imageName = nil;
    if (scale == 1) {
        imageName = [NSString stringWithFormat:@"%@.%@", [[imgPath lastPathComponent] stringByDeletingPathExtension], pathExtension];
    }
    else {
        imageName = [NSString stringWithFormat:@"%@@%ldx.%@", [[imgPath lastPathComponent] stringByDeletingPathExtension], (long)scale, pathExtension];
    }
    
    //返回删掉旧名称加上新名称的路径
    //Returns the path with the old name deleted and the new name added
    return [[imgPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:imageName];
}

+ (UIFont*)fontWithSize:(float)size {
    UIFont *font;
    if (![UIFont fontWithName:@"PingFangSC-Semibold" size:size]) {
        font = [UIFont systemFontOfSize:size];
    } else {
        font = [UIFont fontWithName:@"PingFangSC-Semibold" size:size];
    }
    return font;
}

+ (UIFont*)regularFontWithSize:(float)size {
    UIFont *font;
    if (![UIFont fontWithName:@"PingFangSC-Regular" size:size]) {
        font = [UIFont systemFontOfSize:size];
    } else {
        font = [UIFont fontWithName:@"PingFangSC-Regular" size:size];
    }
    return font;
}

+ (UIFont*)boldFontWithSize:(float)size {
    UIFont *font;
    if (![UIFont fontWithName:@"PingFangSC-Bold" size:size]) {
        font = [UIFont boldSystemFontOfSize:size];
    } else {
        font = [UIFont fontWithName:@"PingFangSC-Bold" size:size];
    }
    return font;
}

+ (UIFont*)mediumFontWithSize:(float)size {
    UIFont *font;
    if (![UIFont fontWithName:@"PingFang-SC" size:size]) {
        font = [UIFont systemFontOfSize:size];
    } else {
        font = [UIFont fontWithName:@"PingFang-SC" size:size];
    }
    return font;
}

+ (NSString *)currentDateAndTime {
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddHHmmssSSS"];
    [dateFormatter setTimeZone:zone];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (int)recordResolutionSetting {
    NSNumber *setting = NV_UserInfo(@"NvRecordResolution");
    if (setting!=nil)
        return setting.intValue;
    return 720;
}

+ (int)compileResolutionSetting {
    NSNumber *setting = NV_UserInfo(@"NvCompileResolution");
    if (setting!=nil)
        return setting.intValue;
    return 720;
}

+ (BOOL)useHardwareCodecSetting {
    NSNumber *setting = NV_UserInfo(@"NvUseHardwareCodec");
    if (setting!=nil)
        return setting.intValue;
    return YES;
}

+ (BOOL)backgroudBlurFilledSetting {
    NSNumber *setting = NV_UserInfo(@"NvBackgroudBlurFilled");
    if (setting!=nil)
        return setting.intValue;
    return NO;
}

+ (int64_t)compileBitrateSetting {
    NSNumber *setting = NV_UserInfo(@"NvCompileBitrate");
    if (setting!=nil)
        return setting.longLongValue;
    return 0;
}

+ (BOOL)isStringEmpty:(NSString *)string {
    return [allTrim(string) length] == 0;
}

+ (UIViewController *)findViewController:(UIView *)sourceView
{
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

+ (NSString *)getTempPath {
    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:NV_PATH_TEMP];
    if (![[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:file withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return file;
}

+ (NSString *)getCustomAnimatedStickerPicPath {
    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:NV_CUSTOM_ANIMATED_STICKER_PIC];
    if (![[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:file withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return file;
}

+ (NSString *)getWatermarkPath {
    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_WATERMARK];
    if (![[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:file withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return file;
}

+ (NSString *)uuidString {
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // release the UUID
    CFRelease(uuid);
    
    // transfer ownership of the string
    // to the autorelease pool
    NSString *uuidStr = [[NSString alloc] initWithString:(__bridge NSString *)uuidString];
    CFRelease(uuidString);
    return uuidStr;
}

+ (nullable NSString *)getFormattedTime:(int64_t)time {
    if (time < 0) {
        return nil;
    } else if (time >=0 && time < 60*NV_TIME_BASE) {
        return [NSString stringWithFormat:@"00:%04.1f", time/(float)NV_TIME_BASE];
    } else if (time >= 60*NV_TIME_BASE && time < (int64_t)60*60*NV_TIME_BASE) {
        return [NSString stringWithFormat:@"%2lld:%04.1f", time/(60*NV_TIME_BASE), (time%(60*NV_TIME_BASE))/(float)NV_TIME_BASE];
    } else {
        return @"> 1 day";
    }
}

+ (void)alertMessage:(nullable UIViewController *)viewController
               title:(nullable NSString*)title
             message:(nullable NSString*)message
     firstButtonText:(nullable NSString*)firstButtonText
        firstHandler:(void (^ __nonnull)(UIAlertAction *_Nonnull action))firstHandler
    secondButtonText:(nullable NSString*)secondButtonText
       secondHandler:(void (^ __nullable)(UIAlertAction *_Nullable action))secondHandler
{
    if(!viewController)
        return;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    if (secondButtonText != nil) {
        UIAlertAction* secondAction = [UIAlertAction actionWithTitle:secondButtonText style:UIAlertActionStyleDefault
                                                             handler:secondHandler];
        [alert addAction:secondAction];
    }
    
    if (firstButtonText != nil) {
        UIAlertAction* firstAction = [UIAlertAction actionWithTitle:firstButtonText style:UIAlertActionStyleDefault
                                                            handler:firstHandler];
        [alert addAction:firstAction];
    }
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

+ (NSString*_Nullable)iphoneType {
    
    //需要导入头文件：#import <sys/utsname.h>
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone4,1"]) return@"iPhone 4S";
    
    if([platform isEqualToString:@"iPhone5,1"]) return@"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,2"]) return@"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,3"]) return@"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone5,4"]) return@"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone6,1"]) return@"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone6,2"]) return@"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone7,1"]) return@"iPhone 6 Plus";
    
    if([platform isEqualToString:@"iPhone7,2"]) return@"iPhone 6";
    
    if([platform isEqualToString:@"iPhone8,1"]) return@"iPhone 6s";
    
    if([platform isEqualToString:@"iPhone8,2"]) return@"iPhone 6s Plus";
    
    if([platform isEqualToString:@"iPhone8,4"]) return@"iPhone SE";
    
    if([platform isEqualToString:@"iPhone9,1"]) return@"iPhone 7";
    
    if([platform isEqualToString:@"iPhone9,2"]) return@"iPhone 7 Plus";
    
    if([platform isEqualToString:@"iPhone10,1"]) return@"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,4"]) return@"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,2"]) return@"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,5"]) return@"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,3"]) return@"iPhone X";
    
    if([platform isEqualToString:@"iPhone10,6"]) return@"iPhone X";
    
    return platform;
    
}

/**
 设置view指定位置的边框
 @param originalView   原view
 @param color          边框颜色
 @param borderWidth    边框宽度
 @param borderType     边框类型 例子: UIBorderSideTypeTop|UIBorderSideTypeBottom
 @return  view
 */
+ (UIView *)borderForView:(UIView *)originalView color:(UIColor *)color borderWidth:(CGFloat)borderWidth borderType:(UIBorderSideType)borderType {
    
    if (borderType == UIBorderSideTypeAll) {
        originalView.layer.borderWidth = borderWidth;
        originalView.layer.borderColor = color.CGColor;
        return originalView;
    }
    
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    
    if (borderType & UIBorderSideTypeLeft) {
        [bezierPath moveToPoint:CGPointMake(0.0f, originalView.frame.size.height)];
        [bezierPath addLineToPoint:CGPointMake(0.0f, 0.0f)];
    }
    
    if (borderType & UIBorderSideTypeRight) {
        [bezierPath moveToPoint:CGPointMake(originalView.frame.size.width, 0.0f)];
        [bezierPath addLineToPoint:CGPointMake( originalView.frame.size.width, originalView.frame.size.height)];
    }
    
    /// top
    if (borderType & UIBorderSideTypeTop) {
        /// top
        [bezierPath moveToPoint:CGPointMake(0.0f, 0.0f)];
        [bezierPath addLineToPoint:CGPointMake(originalView.frame.size.width, 0.0f)];
    }
    
    /// bottom
    if (borderType & UIBorderSideTypeBottom) {
        /// bottom
        [bezierPath moveToPoint:CGPointMake(0.0f, originalView.frame.size.height)];
        [bezierPath addLineToPoint:CGPointMake( originalView.frame.size.width, originalView.frame.size.height)];
    }
    
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.fillColor  = [UIColor clearColor].CGColor;
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.lineWidth = borderWidth;
    
    [originalView.layer addSublayer:shapeLayer];
    
    return originalView;
}

//+ (NSString *)colorStringInARGBModeWithRGB:(NvsColor )color {
//    NSString *colorString = @"#";
//    NSString *aStr = [self rgb:color.a];
//    NSString *rStr = [self rgb:color.r];
//    NSString *gStr = [self rgb:color.g];
//    NSString *bStr = [self rgb:color.b];
//    colorString = [colorString stringByAppendingString:aStr];
//    colorString = [colorString stringByAppendingString:rStr];
//    colorString = [colorString stringByAppendingString:gStr];
//    colorString = [colorString stringByAppendingString:bStr];
//    return colorString;
//}

+ (NSString *)rgb:(CGFloat)value {
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
    
    NSMutableString *resultString = [NSMutableString string];
    for(int i=max-1;i>=0;i--) {
        if(result[i] > 9) {
            [resultString appendFormat:@"%c",result[i]];
        }else {
            [resultString appendFormat:@"%d",result[i]];
        }
    }
    if ([resultString isEqualToString:@"0"]) {
        [resultString appendFormat:@"%@",@"0"];
    }
    return resultString;
}

+ (BOOL)currentLanguagesIsChanese {
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"en"]) {
        return NO;
    } else if ([language hasPrefix:@"zh"]) {
        return YES;
    } else {
        return NO;
    }
}
+ (NSMutableArray *)getMusicList{
    NSMutableArray * list = [NSMutableArray array];
    
    
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    NSString * path = [[NSBundle mainBundle]pathForResource:@"Little Birdy-Dark Of Night" ofType:@"mp3"];
    
    [info setObject:path forKey:@"local_path"];
    [info setObject:@"Little Birdy-Dark Of Night" forKey:@"name"];
    [list addObject:info];
    
    info = [NSMutableDictionary dictionary];
    path = [[NSBundle mainBundle]pathForResource:@"Lovestoned-Thursdays" ofType:@"mp3"];
    [info setObject:path forKey:@"local_path"];
    [info setObject:@"Lovestoned-Thursdays" forKey:@"name"];
    [list addObject:info];
    
    info = [NSMutableDictionary dictionary];
    path = [[NSBundle mainBundle]pathForResource:@"Mindy Gledhill-All The Pennies" ofType:@"mp3"];
    [info setObject:path forKey:@"local_path"];
    [info setObject:@"Mindy Gledhill-All The Pennies" forKey:@"name"];
    [list addObject:info];
    return list;
}

@end
