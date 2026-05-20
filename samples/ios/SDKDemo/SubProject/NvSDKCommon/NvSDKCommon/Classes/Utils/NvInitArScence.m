//
//  NvInitArScence.m
//  SDKDemo
//
//  Created by ms on 2021/12/16.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvInitArScence.h"
//#import <NvBaseCommon/NVDefineConfig.h>
#import <NvStreamingSdkCore/NvsStreamingContext.h>
#import <sys/utsname.h>

@implementation NvInitArScence
+(BOOL)getInitArFace{
    return isInitArFaceSuccess;
}

+ (void)closeDetect {
    isInitArFaceSuccess = false;
    int type = [NvsStreamingContext hasARModule];
    if (type > 0) {
        [NvsStreamingContext closeHumanDetection];
    }
}

+ (void)initARFace:(NvFaceMode)model{
    NSString *bundleid = [[NSBundle mainBundle] bundleIdentifier];
    NSString *licPath = nil;
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"license" ofType:@"bundle"];
    
    NSString *modelPath = [[[bundlePath stringByAppendingPathComponent:@"license"] stringByAppendingPathComponent:@"ms"] stringByAppendingPathComponent:@"ms_face106_v4.0.1.next.model"];
    if (model == NvFaceMode_240){
        modelPath = [[[bundlePath stringByAppendingPathComponent:@"license"] stringByAppendingPathComponent:@"ms"] stringByAppendingPathComponent:@"ms_face240_v4.0.1.next.model"];
    }
    
    int type = [NvsStreamingContext hasARModule];
    if (type > 0) {
        isInitArFaceSuccess = [NvsStreamingContext initHumanDetection:modelPath licenseFilePath:licPath features:NvsHumanDetectionFeature_FaceLandmark|NvsHumanDetectionFeature_FaceAction | NvsHumanDetectionFeature_SemiImageMode];
        if(isInitArFaceSuccess) {
            NSLog(@"初始化人脸成功！！！！！ Initialize face successfully ！！！！！");
        }else{
            NSLog(@"初始化人脸失败！！！！！ Initialize face Failed ！！！！！");
        }
        NSString *segFilePath = [[[bundlePath stringByAppendingPathComponent:@"license"]stringByAppendingPathComponent:@"ms"] stringByAppendingPathComponent:@"ms_humansegment_medium_v2.0.0.next.model"];
        BOOL highVersion = [NvInitArScence isHighVersionPhone];
        if (highVersion == NO) {
            segFilePath = [[[bundlePath stringByAppendingPathComponent:@"license"]stringByAppendingPathComponent:@"ms"] stringByAppendingPathComponent:@"ms_humansegment_small_v2.0.0.next.model"];
        }
        
        [NvsStreamingContext initHumanDetectionExt:segFilePath licenseFilePath:nil features:NvsHumanDetectionFeature_Background];
        
        
        NSString *handActionPath = [[[bundlePath stringByAppendingPathComponent:@"license"]stringByAppendingPathComponent:@"ms"] stringByAppendingPathComponent:@"ms_hand_common_v2.0.0.next.model"];
        [NvsStreamingContext initHumanDetectionExt:handActionPath licenseFilePath:nil features:NvsHumanDetectionFeature_HandAction|NvsHumanDetectionFeature_HandLandmark];
        
        NSString *eyeballPath = [[[bundlePath stringByAppendingPathComponent:@"license"]stringByAppendingPathComponent:@"ms"] stringByAppendingPathComponent:@"ms_eyecontour_v2.0.0.next.model"];
        [NvsStreamingContext initHumanDetectionExt:eyeballPath licenseFilePath:nil features:NvsHumanDetectionFeature_EyeballLandmark|NvsHumanDetectionFeature_SemiImageMode];
        
        NSString *fakefacePath = [[[bundlePath stringByAppendingPathComponent:@"license"]stringByAppendingPathComponent:@"ms"] stringByAppendingPathComponent:@"fakeface_v1.0.1.dat"];
        [NvsStreamingContext setupHumanDetectionData:NvsHumanDetectionDataType_FakeFace dataFilePath:fakefacePath];
        
        NSString *avatarFilePath = [[[bundlePath stringByAppendingPathComponent:@"license"]stringByAppendingPathComponent:@"ms"] stringByAppendingPathComponent:@"ms_avatar_v2.0.0.next.model"];
        [NvsStreamingContext initHumanDetectionExt:avatarFilePath licenseFilePath:nil features:NvsHumanDetectionFeature_AvatarExpression];
        
        /// 人脸通用模型初始化，使用人脸功能的时候需要初始化该模型
        /// Initialize the general face model. This model needs to be initialized when using the face function.
        NSString *facecommonPath = [[[bundlePath stringByAppendingPathComponent:@"license"]stringByAppendingPathComponent:@"ms"] stringByAppendingPathComponent:@"facecommon_v1.0.1.dat"];

        [NvsStreamingContext setupHumanDetectionData:NvsHumanDetectionDataType_FaceCommon dataFilePath:facecommonPath];
        
        /// 高级美颜模型初始化
        /// Advanced Beauty model initialization
        NSString *advancedbeautyPath = [[[bundlePath stringByAppendingPathComponent:@"license"]stringByAppendingPathComponent:@"ms"] stringByAppendingPathComponent:@"advancedbeauty_v1.0.1.dat"];
        [NvsStreamingContext setupHumanDetectionData:NvsHumanDetectionDataType_AdvancedBeauty dataFilePath:advancedbeautyPath];
        
        /// 天空分割模型初始化
        NSString *skysegPath = [[[bundlePath stringByAppendingPathComponent:@"license"]stringByAppendingPathComponent:@"ms"] stringByAppendingPathComponent:@"ms_skysegment_v1.0.5.next.model"];
        [NvsStreamingContext initHumanDetectionExt:skysegPath licenseFilePath:nil features:NvsHumanDetectionFeature_SegmentationSky];
        
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

@end
