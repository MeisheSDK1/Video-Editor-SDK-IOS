//
//  NvLiveAppEnv.h
//  NvVideoEdit
//
//  Created by chengww on 2021/11/1.
//  Copyright © 2021 MEISHE. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NvLiveEnvs) {
    kWidth,
    kHeight,
    kScale,
    kHeightScale,
    kStatusBarHeight,
    kNavigationBarHeight,
    kNavigationHeight,
    kSafeAreaTopHeight,
    kSafeAreaBottomHeight,
    kTabBarHeight
};

@interface NvLiveAppEnv : NSObject

+ (BOOL)isIPhoneXSeries;
+ (CGFloat)layout:(NvLiveEnvs)envs;
+ (NSBundle *_Nullable)moduleBundle;
+ (NSString *_Nullable)bundlePath:(NSString *)folderName;
+ (NSString *_Nullable)localizedString:(NSString *_Nullable)key comment:(NSString *_Nullable)comment;
+ (NSString *_Nullable)albumLocalizedString:(NSString *_Nullable)key comment:(NSString *_Nullable)comment;
+ (void)gradientView:(UIView *)sender withColors:(NSArray *)colors;
+ (BOOL)isZh;

@end


static inline NSString *_Nullable NvLocalString(NSString *_Nullable key, NSString *_Nullable comment) {
    NSBundle *bundle = [NSBundle bundleForClass:NvLiveAppEnv.class];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *resourcePath = [bundle.bundlePath stringByAppendingPathComponent:@"en.lproj"];
    if ([language containsString:@"zh"]) {
        resourcePath = [bundle.bundlePath stringByAppendingPathComponent:@"zh-Hans.lproj"];
    }
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourcePath];
    NSString *ret = [resourceBundle localizedStringForKey:key value:@"" table:@"EffectModule"];
    return ret ?: comment;
}

static inline CGFloat NvScreen(NvLiveEnvs envs) { return [NvLiveAppEnv layout:envs]; }

NS_ASSUME_NONNULL_END
