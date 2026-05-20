//
//  NvMakeupToolMakeupModuler.h
//  SDKDemo
//
//  Created by Meishe on 2022/11/7.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvMakeupToolModel.h"
#import "NvsFx.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvMakeupToolMakeupModuler : NSObject
@property (nonatomic, strong) NvsFx *fxARFace;

/// 应用美妆特效  Apply beauty effects
/// @param effectModel 美妆数据  Beauty data
/// @param makeupKindArr 美妆类型数组  Array of beauty types
- (void)applyMakeupPackage:(NvMakeupToolEffectContentModel *)effectModel makeupKindArr:(NSArray *)makeupKindArr;

/// 调节妆容的整体效果值
/// Adjust the overall effect value of your makeup
/// @param effectModel 美妆数据  Beauty data
- (void)changeMakeupPackage:(NvMakeupToolEffectContentModel *)effectModel;

@end

NS_ASSUME_NONNULL_END
