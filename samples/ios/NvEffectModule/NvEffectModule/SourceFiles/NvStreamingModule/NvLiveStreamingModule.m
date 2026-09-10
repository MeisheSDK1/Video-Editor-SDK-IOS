//
//  NvLiveStreamingModule.m
//  NvEffectModule
//
//  Created by ms20221114 on 2024/6/25.
//

#import "NvLiveStreamingModule.h"
#import <NvStreamingSdkCore/NvstreamingSdkCore.h>
#import <sys/utsname.h>

@implementation NvLiveStreamingModule

+ (void)setupHumanDetection {
    NSString *bundlePath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"model.bundle"];

    NSString *faceModel = [bundlePath stringByAppendingPathComponent:@"ms_face240_v4.0.1.next.model"];
    BOOL ret = [NvsStreamingContext initHumanDetection:faceModel licenseFilePath:nil features:NvsHumanDetectionFeature_FaceLandmark|NvsHumanDetectionFeature_FaceAction | NvsHumanDetectionFeature_SemiImageMode];
    if (!ret) {
        NSLog(@"init human detect error: face");
    }

    NSString *fakeFace = [bundlePath stringByAppendingPathComponent:@"fakeface_v1.0.1.dat"];
    ret = [NvsStreamingContext setupHumanDetectionData:NvsHumanDetectionDataType_FakeFace dataFilePath:fakeFace];
    if (!ret) {
        NSLog(@"init human detect error: fakeFace");
    }

    NSString *avatar = [bundlePath stringByAppendingPathComponent:@"ms_avatar_v2.0.0.next.model"];
    ret = [NvsStreamingContext initHumanDetectionExt:avatar licenseFilePath:nil features:NvsHumanDetectionFeature_AvatarExpression];
    if (!ret) {
        NSLog(@"init human detect avatar: fakeFace");
    }

    NSString *eyeball = [bundlePath stringByAppendingPathComponent:@"ms_eyecontour_v2.0.0.next.model"];
    ret = [NvsStreamingContext initHumanDetectionExt:eyeball licenseFilePath:nil features:NvsHumanDetectionFeature_EyeballLandmark|NvsHumanDetectionFeature_SemiImageMode];
    if (!ret) {
        NSLog(@"init human detect error: eyeball");
    }

    NSString *facecommon = [bundlePath stringByAppendingPathComponent:@"facecommon_v1.0.1.dat"];
    ret = [NvsStreamingContext setupHumanDetectionData:NvsHumanDetectionDataType_FaceCommon dataFilePath:facecommon];
    if (!ret) {
        NSLog(@"init human detect error: facecommon");
    }

    NSString *background = [bundlePath stringByAppendingPathComponent:@"ms_humansegment_medium_v2.0.0.next.model"];
    BOOL highVersion = [NvLiveStreamingModule isHighVersionPhone];
    if (highVersion == NO) {
        background = [bundlePath stringByAppendingPathComponent:@"ms_humansegment_small_v2.0.0.next.model"];
    }
    ret = [NvsStreamingContext initHumanDetectionExt:background licenseFilePath:nil features:NvsHumanDetectionFeature_Background];
    if (!ret) {
        NSLog(@"init human detect error: background");
    }
    NSString *hand = [bundlePath stringByAppendingPathComponent:@"ms_hand_common_v2.0.0.next.model"];
    ret = [NvsStreamingContext initHumanDetectionExt:hand licenseFilePath:nil features:NvsHumanDetectionFeature_HandAction|NvsHumanDetectionFeature_HandLandmark];
    if (!ret) {
        NSLog(@"init human detect error: hand");
    }
    
    NSString *advancedbeauty = [bundlePath stringByAppendingPathComponent:@"advancedbeauty_v1.0.1.dat"];
    ret = [NvsStreamingContext setupHumanDetectionData:NvsHumanDetectionDataType_AdvancedBeauty dataFilePath:advancedbeauty];
    if (!ret) {
        NSLog(@"init human detect error: advancedbeauty");
    }

    /// 天空分割模型初始化
    NSString *skysegPath = [bundlePath stringByAppendingPathComponent:@"ms_skysegment_v1.0.5.next.model"];
    [NvsStreamingContext initHumanDetectionExt:skysegPath licenseFilePath:nil features:NvsHumanDetectionFeature_SegmentationSky];
}

+ (NSString *)getAssetPackageIdFromAssetPackageFilePath:(NSString *)path{
    NvsStreamingContext *context = [NvsStreamingContext sharedInstanceWithFlags:NvsStreamingContextFlag_Support4KEdit];
    return [context.assetPackageManager getAssetPackageIdFromAssetPackageFilePath:path];
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

@end
