//
//  NvBeautyTemplateTool.h
//  SDKDemo
//
//  Created by ms20221114 on 2023/2/14.
//  Copyright © 2023 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NvMakeupToolModel;
@class NvMakeupToolEffectModel;

@interface NvBeautyTemplateTool : NSObject

/// 人脸特效
/// Facial effects
@property (nonatomic, strong) NvsCaptureVideoFx *fxARFace;
/// 锐度特技
/// Sharpen effects
@property (nonatomic, strong, nullable) NvsCaptureVideoFx *fxSharpen;
/// 淸晰度特效
/// Definition effect
@property (nonatomic, strong, nullable) NvsCaptureVideoFx *fxDefinition;
/// 美白特效
/// Whitening effect
@property (nonatomic, strong, nullable) NvsCaptureVideoFx *whiteningFilter;
/// 校色特效
/// Color correction effect
@property (nonatomic, strong, nullable) NvsCaptureVideoFx *colorCorrectFilter;
/// 校色packageId
/// Color proofer packageId
@property (nonatomic, strong) NSMutableString *colorCorrectId;
@property (nonatomic, strong, nullable) NvMakeupToolEffectModel *whiteningEffectModel;

/// 安装素材
/// Installation material
/// - Parameter model: model
- (void)installationMaterial:(NvMakeupToolModel *)model;

/// 应用美颜模版
/// Apply the beauty template
/// - Parameter model: 美颜模版数据
/// Beauty template data
- (void)applyBeautyTemplateEffect:(NvMakeupToolModel * _Nullable)model;

/// 不清除原有数据，只增量添加效果
///Do not clear the original data, only incrementally add effects
/// - Parameter model: 模版数据
/// template data
- (void)incrementApplyBeautyTemplateEffect:(NvMakeupToolModel *)model;

/// 应用美颜模版的美颜效果，该效果不展示到界面上，所以没有记录数据，有需要的时候单独调用
/// Apply beauty template beauty effect, this effect is not displayed on the interface, so no data is recorded, when the need for a separate call
- (void)applyBeautyTemplateWhitening;

- (void)conversionBeautyTemplateWithBeauty:(NSMutableArray *)mutableArray withModel:(NvMakeupToolModel *)model;
- (void)conversionBeautyTemplateWithShaping:(NSMutableArray *)mutableArray withModel:(NvMakeupToolModel *)model;
- (void)conversionBeautyTemplateWithMicroShaping:(NSMutableArray *)mutableArray withModel:(NvMakeupToolModel *)model;
- (void)conversionBeautyTemplateWithAdjust:(NSMutableArray *)mutableArray withModel:(NvMakeupToolModel *)model;
- (void)conversionBeautyTemplateWithContouring:(NSMutableArray *)mutableArray withModel:(NvMakeupToolModel *)model;

@end

NS_ASSUME_NONNULL_END
