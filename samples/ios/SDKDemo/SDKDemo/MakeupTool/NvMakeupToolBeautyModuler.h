//
//  NvMakeupToolBeautyModuler.h
//  SDKDemo
//
//  Created by Meishe on 2022/11/7.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvMakeupToolModel.h"
#import "NvsVideoClip.h"
#import "NvsFx.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvMakeupToolBeautyModuler : NSObject
/// makeup使用模式(拍摄 ｜ 编辑)   Makeup usage patterns (shoot | edit)
@property (nonatomic, assign) NvMakeupModulerMode mode;
/// 美妆包解压文件夹路径   Beauty package decompression folder path
@property (nonatomic, strong) NSString *packagePath;

@property (nonatomic, strong) NvsVideoClip *clip;

/// 设置fx相关特性   Set FX-related features
/// @param model 特效包数据  Special effects pack data
/// @param fx arscene特效  arscene special effects
- (NvsFx *)getAndSetARSceneFx:(NvMakeupToolModel *)model fx:(NvsFx *)fx;

/// 应用妆容中美颜特效  Apply beauty effects in makeup
/// @param effectModel 特效数据  Special effect data
/// @param fx arscene特效  arscene special effects
- (void)applyMakeupBeautyEffect:(NvMakeupToolEffectContentModel *)effectModel arsceneFx:(NvsFx *)fx;

/// 应用妆容中美型特效  Apply makeup and beauty effects
/// @param effectModel 特效数据  Special effect data
/// @param fx arscene特效  arscene special effects
- (void)applyMakeupBeautyShapeEffect:(NvMakeupToolEffectContentModel *)effectModel arsceneFx:(NvsFx *)fx;

/// 应用妆容中微整形特效 Apply micro-plastic effects in makeup
/// @param effectModel 特效数据 Special effect data
/// @param fx arscene特效 arscene special effects
- (void)applyMakeupMicroShapeEffect:(NvMakeupToolEffectContentModel *)effectModel arsceneFx:(NvsFx *)fx;

- (NSString *)applyMakeupToolElements:(NvsFx *)fx item:(NvMakeupToolElementModel *)item reset:(BOOL)reset;
@end

NS_ASSUME_NONNULL_END
