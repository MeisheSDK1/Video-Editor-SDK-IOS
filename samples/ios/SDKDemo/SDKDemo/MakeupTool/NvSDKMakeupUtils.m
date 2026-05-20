//
//  NvSDKMakeupUtils.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvSDKMakeupUtils.h"
#import <NvSDKCommon/NvInitArScence.h>
@implementation NvSDKMakeupUtils

+ (NvsStreamingContext *)getSDKContext {
    return [NvsStreamingContext sharedInstanceWithFlags:NvsStreamingContextFlag_Support4KEdit | NvsStreamingContextFlag_InterruptStopForInternalStop | NvsStreamingContextFlag_NeedGifMotion];
}

#pragma mark 获取片段上的某个特效
+ (NvsVideoFx *)getClipVideoFx:(NSString *)string withClip:(NvsVideoClip *)clip{
    if ([self checkString:string] && clip) {
        NvsVideoFx *fx;
        if ([string isEqualToString:@"AR Scene"]){
            for (int i = 0; i < clip.getRawFxCount; i++) {
                NvsVideoFx *tempFx = [clip getRawFxByIndex:i];
                if ([tempFx.bultinVideoFxName isEqualToString:string] || [tempFx.videoFxPackageId isEqualToString:string]) {
                    fx = tempFx;
                    break;
                }
            }
        }else{
            for (int i = 0; i < clip.fxCount; i++) {
                NvsVideoFx *tempFx = [clip getFxWithIndex:i];
                if ([tempFx.bultinVideoFxName isEqualToString:string] || [tempFx.videoFxPackageId isEqualToString:string]) {
                    fx = tempFx;
                    break;
                }
            }
        }
        return fx;
    }
    return nil;
}

#pragma mark 创建一个clip特效
+ (NvsVideoFx *)createClipVideoFx:(NSString *)string withClip:(NvsVideoClip *)clip{
    if ([self checkString:string] && clip) {
        if ([string isEqualToString:@"AR Scene"]){
            NvsVideoFx *fx = [clip insertRawBuiltinFx:string fxIndex:0];
            BOOL highVersion = [NvInitArScence isHighVersionPhone];
            if(highVersion) {
                [fx setBooleanVal:@"AI Face Occlusion Enabled" val:YES];
            }
            [fx setAbsoluteTimeUsed:true];
            return fx;
        }
        NvsVideoFx *fx = [clip insertBuiltinFx:string fxIndex:0];
        if (!fx) {
            fx = [clip appendPackagedFx:string];
        }
        [fx setAbsoluteTimeUsed:true];
        return fx;
    }
    return nil;
}

#pragma mark 检查字符串的有效性
+ (BOOL)checkString:(NSString *)string{
    if (string && string.length != 0) {
        return YES;
    }
    return NO;
}

#pragma mark 安装素材
+ (NSMutableString *)installAssetPackage:(NSString *)path licPath:(NSString *)licPath assetType:(NvsAssetPackageType)assetType {
    if (!path || path.length == 0) {
        return nil;
    }
    if (!licPath || licPath.length == 0){
        
        licPath = [NSString convertFilePathToNewPath:path WithExtension:@"lic"];
    }
    NvsStreamingContext *context = [NvSDKMakeupUtils getSDKContext];
    NSMutableString *sceneId = [[NSMutableString alloc] init];
    NvsAssetPackageManagerError error = [context.assetPackageManager installAssetPackage:path license:licPath type:assetType sync:YES assetPackageId:sceneId];
    if (error != NvsAssetPackageManagerError_AlreadyInstalled && error != NvsAssetPackageManagerError_NoError) {
        NSLog(@"安装素材失败！！！ Material installation failure");
    }else if (error == NvsAssetPackageManagerError_AlreadyInstalled) {
        NSLog(@"安装素材成功！！！Installing materials successfully %@  ====== %@",path,licPath);
        [context.assetPackageManager upgradeAssetPackage:path license:licPath type:assetType sync:YES assetPackageId:sceneId];
    }
    return sceneId;
}
@end
