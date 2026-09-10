//
//  NvLiveEffectModule.m
//  NvLiveEffectModule
//
//  Created by meishe on 2023/7/12.
//

#import "NvLiveEffectModule.h"
#import <NveEffectKit/NveEffectKit.h>
#import <sys/utsname.h>

@implementation NvLiveEffectModule
+ (void)setupHumanDetection {
    NSString *bundlePath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"model.bundle"];

    NSString *faceModel = [bundlePath stringByAppendingPathComponent:@"ms_face240_v4.0.3.next.model"];
    BOOL ret = [NveEffectKit initHumanDetection:NveDetectionModelType_face modelPath:faceModel licenseFilePath:nil];
    if (!ret) {
        NSLog(@"init human detect error: face");
    }

    NSString *fakeFace = [bundlePath stringByAppendingPathComponent:@"fakeface_v1.0.1.dat"];
    ret = [NveEffectKit initHumanDetection:NveDetectionModelType_fakeFace modelPath:fakeFace licenseFilePath:nil];
    if (!ret) {
        NSLog(@"init human detect error: fakeFace");
    }

    NSString *avatar = [bundlePath stringByAppendingPathComponent:@"ms_avatar_v2.0.0.next.model"];
    ret = [NveEffectKit initHumanDetection:NveDetectionModelType_avatar modelPath:avatar licenseFilePath:nil];
    if (!ret) {
        NSLog(@"init human detect avatar: avatar");
    }

    NSString *eyeball = [bundlePath stringByAppendingPathComponent:@"ms_eyecontour_v2.0.0.next.model"];
    ret = [NveEffectKit initHumanDetection:NveDetectionModelType_eyeball modelPath:eyeball licenseFilePath:nil];
    if (!ret) {
        NSLog(@"init human detect error: eyeball");
    }

    NSString *background = [bundlePath stringByAppendingPathComponent:@"ms_humansegment_medium_v2.0.0.next.model"];
    BOOL highVersion = [NvLiveEffectModule isHighVersionPhone];
    if (!highVersion) {
        background = [bundlePath stringByAppendingPathComponent:@"ms_humansegment_small_v2.0.0.next.model"];
    }
    ret = [NveEffectKit initHumanDetection:NveDetectionModelType_background modelPath:background licenseFilePath:nil];
    if (!ret) {
        NSLog(@"init human detect error: background");
    }
    NSString *hand = [bundlePath stringByAppendingPathComponent:@"ms_hand_common_v2.0.0.next.model"];
    ret = [NveEffectKit initHumanDetection:NveDetectionModelType_hand modelPath:hand licenseFilePath:nil];
    if (!ret) {
        NSLog(@"init human detect error: hand");
    }
    
    NSString *faceCommon = [bundlePath stringByAppendingPathComponent:@"facecommon_v1.0.1.dat"];
    ret = [NveEffectKit initHumanDetection:NveDetectionModelType_faceCommon modelPath:faceCommon licenseFilePath:nil];
    if (!ret) {
        NSLog(@"init human detect error: faceCommon");
    }
    
    NSString *advancedbeauty = [bundlePath stringByAppendingPathComponent:@"advancedbeauty_v1.0.1.dat"];
    ret = [NveEffectKit initHumanDetection:NveDetectionModelType_advancedBeauty modelPath:advancedbeauty licenseFilePath:nil];
    if (!ret) {
        NSLog(@"init human detect error: advancedbeauty");
    }
}

+ (BOOL)isHighVersionPhone {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *phoneInfo = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([phoneInfo containsString:@"iPhone"]) {
        NSArray *components = [phoneInfo componentsSeparatedByString:@","];
        NSMutableString *firstComponent = [NSMutableString stringWithString:components.firstObject];
        NSString *modifiedString = [firstComponent stringByReplacingOccurrencesOfString:@"iPhone" withString:@""];
        return modifiedString.intValue > 9 ? YES : NO;
    }
    return NO;
}

+ (NSString *)getAssetPackageIdFromAssetPackageFilePath:(NSString *)path{
    NvsEffectSdkContext *context = [NvsEffectSdkContext sharedInstance:NvsEffectSdkContextFlag_NoFlag];
    return [context.assetPackageManager getAssetPackageIdFromAssetPackageFilePath:path];
}

@end

