//
//  NvAppEnv.m
//  NvVideoEdit
//
//  Created by chengww on 2021/11/1.
//  Copyright © 2021 MEISHE. All rights reserved.
//

#import "NvAppEnv.h"

@implementation NvAppEnv
+ (BOOL)isARSceneMS240 {
    return true;
}
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

+ (NSBundle * _Nullable)moduleBundle {
    NSBundle *containnerBundle = [NSBundle bundleForClass:[NvAppEnv class]];
    NSBundle *assetBundle = [NSBundle bundleWithPath:[containnerBundle pathForResource:@"ShortVideo" ofType:@"bundle"]];
    return  assetBundle;
}
+ (NSString *_Nullable)bundlePath:(NSString *)folderName {
    NSString *path = [[[NvAppEnv moduleBundle] bundlePath] stringByAppendingPathComponent:folderName];
    return path;
}
+ (NSString *_Nullable)localizedString:(NSString *_Nullable)key comment:(NSString *_Nullable)comment{
    NSString *languageStr = NSLocale.preferredLanguages.firstObject;
    NSString *language = [languageStr hasPrefix:@"en"] ? @"en" : @"zh-Hans";
    NSBundle *languageBundle = [NSBundle bundleWithPath:[[NvAppEnv moduleBundle] pathForResource:language ofType:@"lproj"]];
    NSString *value = [languageBundle localizedStringForKey:key value:comment table:@"ShortVideo"];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:@"ShortVideo"];
}
+ (NSString *_Nullable)albumLocalizedString:(NSString *_Nullable)key comment:(NSString *_Nullable)comment {
    NSString *languageStr = NSLocale.preferredLanguages.firstObject;
    NSString *language = [languageStr hasPrefix:@"en"] ? @"en" : @"zh-Hans";
    NSBundle *languageBundle = [NSBundle bundleWithPath:[[NvAppEnv moduleBundle] pathForResource:language ofType:@"lproj"]];
    NSString *value = [languageBundle localizedStringForKey:key value:comment table:@"NvAlbum"];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:@"NvAlbum"];
}
+ (CGFloat)layout:(NvEnvs)envs {
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
            value = [NvAppEnv statusBarHeight];
            break;
        case kNavigationBarHeight:
            value = 44.0;
            break;
        case kNavigationHeight:
            value = [NvAppEnv statusBarHeight] + 44.0;
            break;
        case kSafeAreaBottomHeight:
            value = [NvAppEnv safeAreaBottomHeight];
            break;
        case kTabBarHeight:
            value = [NvAppEnv isIPhoneXSeries] ? 49.0 + [NvAppEnv safeAreaBottomHeight] : 49.0;
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
    return [NvAppEnv statusBarHeight] > 20 ? 34.0 : 0.0;
}

@end
