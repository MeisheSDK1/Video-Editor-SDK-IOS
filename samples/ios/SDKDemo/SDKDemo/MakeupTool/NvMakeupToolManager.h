//
//  NvMakeupToolManager.h
//  SDKDemo
//
//  Created by Meishe on 2022/11/8.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvMakeupToolModel.h"
#import "NvsVideoClip.h"
@class NvMakeupToolManager;
@class NvMakeupContentModel;
NS_ASSUME_NONNULL_BEGIN
@protocol NvMakeupToolManagerDelegate <NSObject>
@optional
//应用妆容效果完成 Apply makeup effect finished
- (void)didApplyMakeupEffect:(NvMakeupToolManager *)manager ;

//获取当前存在的单妆元素信息
//get applied and still existed single makeup elements
- (NSArray <NvMakeupContentModel *> *)getExistSingleMakeupElements:(NvMakeupToolManager *)manager;

@end
@interface NvMakeupToolManager : NSObject
@property (nonatomic, assign) id <NvMakeupToolManagerDelegate>delegate;
@property (nonatomic, assign) NvMakeupModulerMode mode;
@property (nonatomic, strong) NvsVideoClip *clip;

/// 应用指定路径下的妆容特效 Apply makeup effects in the specified path
/// @param assetPath 资源路径 Resource path
/// @param arsceneFx arscene特效 arscene special effects
- (void)applyMakeupEffect:(NSString *)assetPath arsceneFx:(NvsFx *)arsceneFx;

/// 删除所有妆容特效 Remove all makeup effects
/// @param arsceneFx arscene特效 arscene special effects
- (void)removeAllMakeupEffects:(NvsFx *)arsceneFx;

/// 获取应用的特效模型 Get the effects model of the application
- (NvMakeupToolModel *)getEffectModel;

/// 调节妆容的整体效果值
/// Adjust the overall effect value of your makeup
/// @param arsceneFx arscene特效 arscene special effects
- (void)changeMakeupEffectArsceneFx:(NvsFx *)arsceneFx;

/// 调节妆容的整体滤镜效果值
/// Adjust the overall filter value of your makeup
/// @param arsceneFx arscene特效 arscene special effects
- (void)changeMakeupFilterArsceneFx:(NvsFx *)arsceneFx;

- (void)installAsset:(NSString *)dirPath model:(NvMakeupToolEffectModel *)model assetType:(NvsAssetPackageType)assetType;

- (void)applyVariableCompose:(NvMakeupToolModel * __nullable)effectModel arsceneFx:(NvsFx *)arsceneFx;

//获取当前存在的单妆元素信息
//get applied and still existed single makeup elements
- (NSArray *)getCurrentExistSingleMakeupElements;
@end

NS_ASSUME_NONNULL_END
