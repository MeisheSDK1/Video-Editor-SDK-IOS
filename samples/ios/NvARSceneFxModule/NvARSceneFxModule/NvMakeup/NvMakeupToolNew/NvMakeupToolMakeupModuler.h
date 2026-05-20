//
//  NvMakeupToolMakeupModuler.h
//  SDKDemo
//
//  Created by Meishe on 2022/11/7.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvMakeupToolModel.h"
#import "NvARSceneFxOperator.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvMakeupToolMakeupModuler : NSObject
@property (nonatomic, strong) NvsVideoEffect *fxARFace;

/// 应用美妆特效
/// Apply beauty effects
/// @param effectModel 美妆数据
/// @param makeupKindArr 美妆类型数组
- (void)applyMakeupPackage:(NvMakeupToolEffectContentModel *)effectModel makeupKindArr:(NSArray *)makeupKindArr;

/// 应用美妆单妆特效
/// Apply beauty single makeup effect
/// @param effectModel 美妆数据
- (void)applySingMakeupPackage:(NvMakeupToolEffectContentModel *)effectModel;
@end

NS_ASSUME_NONNULL_END
