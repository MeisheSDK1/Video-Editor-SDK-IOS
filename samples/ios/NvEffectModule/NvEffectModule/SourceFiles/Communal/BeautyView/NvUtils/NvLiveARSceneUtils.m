//
//  NvLiveARSceneUtils.m
//  NvTest
//
//  Created by ms20180425 on 2022/8/19.
//

#import "NvLiveARSceneUtils.h"
#import <sys/utsname.h>

@implementation NvLiveARSceneUtils

+ (NSString *_Nullable)iphoneType {
    struct utsname systemInfo;

    uname(&systemInfo);

    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];

    if ([platform isEqualToString:@"iPhone4,1"])
        return @"iPhone 4S";

    if ([platform isEqualToString:@"iPhone5,1"])
        return @"iPhone 5";

    if ([platform isEqualToString:@"iPhone5,2"])
        return @"iPhone 5";

    if ([platform isEqualToString:@"iPhone5,3"])
        return @"iPhone 5c";

    if ([platform isEqualToString:@"iPhone5,4"])
        return @"iPhone 5c";

    if ([platform isEqualToString:@"iPhone6,1"])
        return @"iPhone 5s";

    if ([platform isEqualToString:@"iPhone6,2"])
        return @"iPhone 5s";

    if ([platform isEqualToString:@"iPhone7,1"])
        return @"iPhone 6 Plus";

    if ([platform isEqualToString:@"iPhone7,2"])
        return @"iPhone 6";

    if ([platform isEqualToString:@"iPhone8,1"])
        return @"iPhone 6s";

    if ([platform isEqualToString:@"iPhone8,2"])
        return @"iPhone 6s Plus";

    if ([platform isEqualToString:@"iPhone8,4"])
        return @"iPhone SE";

    if ([platform isEqualToString:@"iPhone9,1"])
        return @"iPhone 7";

    if ([platform isEqualToString:@"iPhone9,2"])
        return @"iPhone 7 Plus";

    if ([platform isEqualToString:@"iPhone10,1"])
        return @"iPhone 8";

    if ([platform isEqualToString:@"iPhone10,4"])
        return @"iPhone 8";

    if ([platform isEqualToString:@"iPhone10,2"])
        return @"iPhone 8 Plus";

    if ([platform isEqualToString:@"iPhone10,5"])
        return @"iPhone 8 Plus";

    if ([platform isEqualToString:@"iPhone10,3"])
        return @"iPhone X";

    if ([platform isEqualToString:@"iPhone10,6"])
        return @"iPhone X";

    return platform;
}

+ (UIImage *_Nullable)imageNamed:(NSString *_Nullable)name {
    if (!name)
        return nil;
    return [UIImage imageNamed:name inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

+ (BOOL)currentLanguagesIsChanese {
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"en"]) {
        //英文 english
        return NO;
    } else if ([language hasPrefix:@"zh"]) {
        //中文 chinese
        return YES;
    } else {
        //英文 english
        return NO;
    }
}

+ (BOOL)enableGanBeauty {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSLog(@"Device Model: %@", deviceModel);
    NSString *modelVersion = [deviceModel stringByReplacingOccurrencesOfString:@"iPhone" withString:@""];
    
    if([modelVersion containsString:@","]) {
        NSArray *arr = [modelVersion componentsSeparatedByString:@","];
        if (arr.count>0) {
            modelVersion = arr[0];
        }
    }
    if([modelVersion intValue] > 11) {
        return YES;
    }
    return NO;
}

@end
