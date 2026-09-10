//
//  NvLiveAppEnv.m
//  NvVideoEdit
//
//  Created by chengww on 2021/11/1.
//  Copyright © 2021 MEISHE. All rights reserved.
//

#import "NvLiveAppEnv.h"

@implementation NvLiveAppEnv

+ (BOOL)isIPhoneXSeries {
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    return iPhoneXSeries;
}

+ (NSBundle *_Nullable)moduleBundle {
    NSBundle *containnerBundle = [NSBundle bundleForClass:[NvLiveAppEnv class]];
    NSBundle *assetBundle = [NSBundle bundleWithPath:[containnerBundle pathForResource:@"ShortVideo" ofType:@"bundle"]];
    return assetBundle;
}
+ (NSString *_Nullable)bundlePath:(NSString *)folderName {
    NSString *path = [[[NvLiveAppEnv moduleBundle] bundlePath] stringByAppendingPathComponent:folderName];
    return path;
}
+ (NSString *_Nullable)localizedString:(NSString *_Nullable)key comment:(NSString *_Nullable)comment {
    NSString *languageStr = NSLocale.preferredLanguages.firstObject;
    NSString *language = [languageStr hasPrefix:@"en"] ? @"en" : @"zh-Hans";
    NSBundle *languageBundle = [NSBundle bundleWithPath:[[NvLiveAppEnv moduleBundle] pathForResource:language ofType:@"lproj"]];
    NSString *value = [languageBundle localizedStringForKey:key value:comment table:@"ShortVideo"];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:@"ShortVideo"];
}
+ (NSString *_Nullable)albumLocalizedString:(NSString *_Nullable)key comment:(NSString *_Nullable)comment {
    NSString *languageStr = NSLocale.preferredLanguages.firstObject;
    NSString *language = [languageStr hasPrefix:@"en"] ? @"en" : @"zh-Hans";
    NSBundle *languageBundle = [NSBundle bundleWithPath:[[NvLiveAppEnv moduleBundle] pathForResource:language ofType:@"lproj"]];
    NSString *value = [languageBundle localizedStringForKey:key value:comment table:@"NvAlbum"];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:@"NvAlbum"];
}
+ (CGFloat)layout:(NvLiveEnvs)envs {
    CGFloat value = 0;
    CGRect rect = [UIScreen mainScreen].bounds;
    switch (envs) {
        case kWidth:
            value = rect.size.width;
            break;
        case kHeight:
            value = rect.size.height;
            break;
        case kScale:
            value = rect.size.width / 375.0;
            break;
        case kHeightScale:
            value = rect.size.height / 667.0;
            break;
        case kStatusBarHeight:
            value = [NvLiveAppEnv statusBarHeight];
            break;
        case kNavigationBarHeight:
            value = 44.0;
            break;
        case kNavigationHeight:
            value = [NvLiveAppEnv statusBarHeight] + 44.0;
            break;
        case kSafeAreaTopHeight:
            value = [NvLiveAppEnv statusBarHeight] + 44.0;
            break;
        case kSafeAreaBottomHeight:
            value = [NvLiveAppEnv safeAreaBottomHeight];
            break;
        case kTabBarHeight:
            value = [NvLiveAppEnv isIPhoneXSeries] ? 49.0 + [NvLiveAppEnv safeAreaBottomHeight] : 49.0;
            break;
        default:
            break;
    }
    return value;
}

+ (CGFloat)statusBarHeight {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}
+ (CGFloat)safeAreaBottomHeight {
    return [NvLiveAppEnv statusBarHeight] > 20 ? 34.0 : 0.0;
}

+ (void)gradientView:(UIView *)sender withColors:(NSArray *)colors{
    //创建CAGradientLayer 对象
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    //设置CAGradientLayer 对象的位置大小和承接视图等同
    gradientLayer.frame = CGRectMake(0, 0, sender.frame.size.width, sender.frame.size.height);
    //设置渐变色(即颜色数组)
    gradientLayer.colors = colors;
    //变化位置或变化点
    gradientLayer.locations = @[@(0.0f),@(1.0f)];
    //渐变方向
    gradientLayer.startPoint = CGPointMake(0, 0.3);
    gradientLayer.endPoint = CGPointMake(0.9, 0.8);
    gradientLayer.masksToBounds = YES;
    gradientLayer.cornerRadius = 22;
    //添加
    [sender.layer addSublayer:gradientLayer];
}

+ (BOOL)isZh{
    NSString *language = NSLocale.preferredLanguages.firstObject;
    if ([language containsString:@"zh"]) {
        return YES;
    }
    return NO;
}

@end
