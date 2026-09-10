//
//  NvFilterUsageUtil.m
//  SDKDemo
//
//  Created by meishe20241218 on 2025/7/1.
//  Copyright © 2025 meishe. All rights reserved.
//

#import "NvFilterUsageUtil.h"
#import <NvStreamingSdkCore/NvStreamingSdkCore.h>
@implementation NvFilterUsageUtil

/// 给定的特效滤镜是否包含背景分割效果
/// Does the given special effects filter include background segmentation effects
/// - Parameter uuid: 滤镜特效的uuid
+ (BOOL)isContainBackgroundSegment:(NSString *)uuid {
    BOOL contain = NO;
    NSString *dectionType = [[NvsStreamingContext sharedInstance].assetPackageManager getDetectionTypeStringInAssetPackage:uuid type:NvsAssetPackageType_VideoFx];
    if (dectionType!=nil && dectionType.length>0) {
        contain = [dectionType containsString:@"backgroundSegmentation"];
    }
    return contain;
}

/// 在拍摄模式中是否有添加AR Scene 特效
/// Is there an AR Scene effect added in shooting mode
+ (BOOL)isContainARSceneOnCaptureMode {
    unsigned int count = [[NvsStreamingContext sharedInstance] getCaptureVideoFxCount];
    BOOL contain = NO;
    for (int i=0; i<count; i++) {
        NvsCaptureVideoFx *fx = [[NvsStreamingContext sharedInstance] getCaptureVideoFxByIndex:i];
        if ([fx.bultinCaptureVideoFxName isEqualToString:@"AR Scene"]) {
            contain = YES;
            break;
        }
    }
    return contain;
}

/// 获取拍摄模式中AR Scene 特效在已添加特效中的顺序index 值
/// Obtain the sequential index value of AR Scene effects in the added effects in shooting mode
+ (int)getARSceneBuiltinFxIndex {
    unsigned int count = [[NvsStreamingContext sharedInstance] getCaptureVideoFxCount];
    int index = -1;
    for (int i=0; i<count; i++) {
        NvsCaptureVideoFx *fx = [[NvsStreamingContext sharedInstance] getCaptureVideoFxByIndex:i];
        if ([fx.bultinCaptureVideoFxName isEqualToString:@"AR Scene"]) {
            index = i;
            break;
        }
    }
    return index;
}

/// 拍摄模式下添加滤镜特效
/// append filter effect in shooting mode
+ (NvsCaptureVideoFx *)appendPackagedCaptureVideoFx:(NSString *)uuid {
    NvsStreamingContext *context = [NvsStreamingContext sharedInstance];
    BOOL containBGSegment = [NvFilterUsageUtil isContainBackgroundSegment:uuid];
    if (containBGSegment) {
        //该特效本身包含分割
        int arsceneIndex = [NvFilterUsageUtil getARSceneBuiltinFxIndex];
        if (arsceneIndex >= 0) {
            //包含ar scene 特效
            NvsCaptureVideoFx *fx = [context insertPackagedCaptureVideoFx:uuid withInsertPosition:arsceneIndex];
            return fx;
        }
    }
    NvsCaptureVideoFx *fx = [context appendPackagedCaptureVideoFx:uuid];
    return fx;
}
@end
