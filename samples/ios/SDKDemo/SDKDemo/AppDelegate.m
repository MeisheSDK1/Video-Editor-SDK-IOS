//
//  AppDelegate.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/24.
//  Copyright © 2018年 刘东旭. All rights reserved.
//
//#define USE_DORAEMON YES
#import "AppDelegate.h"
#import <NvSDKCommon/NvBaseNavigationController.h>
#import "ViewController.h"
#import "NvsStreamingContext.h"
#import <NvAISdk/NvsAISdk.h>
#import <UMCommon/UMCommon.h>
#import <UMCommon/MobClick.h>
#import "NvsEffectSdkContext.h"
#import "NvCaptureController.h"

#if __has_include("DoraemonManager.h")
#import "DoraemonManager.h"
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSFileManager *fm = [NSFileManager defaultManager];
    NSNumber *clearDownloadAsset = [[NSUserDefaults standardUserDefaults] objectForKey:@"clearDownloadAsset"];
    if (!clearDownloadAsset || !clearDownloadAsset.boolValue){
        NSString *string = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSArray *array = [fm contentsOfDirectoryAtPath:string error:nil];
        for (NSString *tempString in array) {
            [fm removeItemAtPath:[string stringByAppendingPathComponent:tempString] error:nil];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"clearDownloadAsset"];
    }
    [NvsStreamingContext setSaveDebugMessagesToFile:YES];
    
#if __has_include("DoraemonManager.h")
    DoraemonManager *doraemonManager = [DoraemonManager shareInstance];
    [doraemonManager install];
#endif

    CGFloat tempHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    if (tempHeight <= 20) {
        [NvsStreamingContext setMaxReaderCount:3];
    }
    
    NSString *licPath = [[[NSBundle mainBundle] pathForResource:@"license" ofType:@"bundle"] stringByAppendingPathComponent:@"license/meishesdk.lic"];
//    NSString *bundleid = [[NSBundle mainBundle] bundleIdentifier];
//    if ([bundleid isEqualToString:@"com.meishe.sdktest"]) {
        NSString *licDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/license"];
        
        if (![fm fileExistsAtPath:licDir]) {
            [fm createDirectoryAtPath:licDir withIntermediateDirectories:true attributes:nil error:nil];
        }
        NSString *tmpLicPath = [licDir stringByAppendingPathComponent:@"meishesdk.lic"];
        if ([fm fileExistsAtPath:tmpLicPath]) {
            licPath = tmpLicPath;
        }
        
//    }
    
    NSNumber * assetLicNum = NV_UserInfo(@"NvEnablingAssetLic");
    BOOL result = false;
    if (assetLicNum!=nil && assetLicNum.intValue == 0) {
        
    }else{
        result = [NvsStreamingContext verifySdkLicenseFile:licPath];
    }
    
    [NvsStreamingContext setSaveDebugMessagesToFile:YES];
    
    if ([NvUtils isUnSupport4KEdit]) {
        [NvsStreamingContext sharedInstanceWithFlags: NvsStreamingContextFlag_InterruptStopForInternalStop | NvsStreamingContextFlag_NeedGifMotion];
    }else{
        [NvsStreamingContext sharedInstanceWithFlags: NvsStreamingContextFlag_Support4KEdit | NvsStreamingContextFlag_InterruptStopForInternalStop | NvsStreamingContextFlag_NeedGifMotion];
    }
    [NvsStreamingContext setMaxReaderCount:8];
    if (!result) {
        NSLog(@"SDK授权失败！SDK authorization failed!");
    }
    
    BOOL success = [NvsAIContext verifySdkLicenseFile:licPath];
    if (!success) {
        NSLog(@"授权失败 Authorization failure");
    }
    
    [NvHDRManager setUpEngineHdrCaps];
    [NvHDRManager setSDRToHDRColorGain];
    NvBaseNavigationController *baseVC = [[NvBaseNavigationController alloc] initWithRootViewController:[ViewController new]];
    self.window.rootViewController = baseVC;
    if (@available(iOS 13.0, *)) {
        //控制器模式设置成固定的浅色模式，不随着系统的变化而变化
        //The controller mode is set to a fixed light color mode, which does not change with the change of the system
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    } else {
        // Fallback on earlier versions
    }
    [self.window makeKeyAndVisible];
#ifndef DEBUG
    [self initUmeng];
#endif
    return YES;
}

- (void)initUmeng {
    [UMConfigure initWithAppkey:@"6323ed6a88ccdf4b7e2f2549" channel:@"App Store"];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
