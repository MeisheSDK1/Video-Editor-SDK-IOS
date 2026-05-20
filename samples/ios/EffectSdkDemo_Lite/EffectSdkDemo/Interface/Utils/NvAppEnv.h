//
//  NvAppEnv.h
//  NvVideoEdit
//
//  Created by chengww on 2021/11/1.
//  Copyright © 2021 MEISHE. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NvEnvs) {
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

@interface NvAppEnv : NSObject
+ (BOOL)isARSceneMS240;
+ (BOOL)isIPhoneXSeries;
+ (CGFloat)layout:(NvEnvs)envs;
+ (NSBundle *_Nullable)moduleBundle;
+ (NSString *_Nullable)bundlePath:(NSString *)folderName;
+ (NSString *_Nullable)localizedString:(NSString *_Nullable)key comment:(NSString *_Nullable)comment;
+ (NSString *_Nullable)albumLocalizedString:(NSString *_Nullable)key comment:(NSString *_Nullable)comment;

@end

NS_ASSUME_NONNULL_END
