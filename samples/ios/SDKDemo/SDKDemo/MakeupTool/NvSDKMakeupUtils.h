//
//  NvSDKMakeupUtils.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsStreamingContext.h"
#import "NvStreamingSdkCore.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvSDKMakeupUtils : NSObject

/// 初始化sdk  Initialize SDK
+ (NvsStreamingContext *)getSDKContext;

/// 获取片段上的某个特效
/// @param string 特效名称或者特效包裹
/// @param clip 片段
+ (NvsVideoFx *)getClipVideoFx:(NSString *)string withClip:(NvsVideoClip *)clip;

/// 创建一个clip特效
/// @param string 特效名称或者特效包裹
/// @param clip 片段
+ (NvsVideoFx *)createClipVideoFx:(NSString *)string withClip:(NvsVideoClip *)clip;


+ (NSMutableString *)installAssetPackage:(NSString *)path licPath:(NSString *)licPath assetType:(NvsAssetPackageType)assetType;
@end

NS_ASSUME_NONNULL_END
