//
//  NvLiveCaptureModularVM.h
//  NvEffectModule
//
//  Created by ms20221114 on 2024/6/25.
//

#import <Foundation/Foundation.h>
#import <NvStreamingSdkCore/NvstreamingSdkCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NveBeautyLiveType) {
    NveBeautyLiveType_strength,
    NveBeautyLiveType_strength_1,
    NveBeautyLiveType_strength_2,
    NveBeautyLiveType_strength_3,
    NveBeautyLiveType_whitening,
    NveBeautyLiveType_whitening_1,
    NveBeautyLiveType_matte,
    NveBeautyLiveType_reddening,
    NveBeautyLiveType_sharpen,
    NveBeautyLiveType_definition
};

typedef NS_ENUM(NSInteger, NveShapeLiveType) {
    NveShapeLiveType_faceWidth,
    NveShapeLiveType_faceLength,
    NveShapeLiveType_faceSize,
    NveShapeLiveType_foreheadHeight,
    NveShapeLiveType_chinLength,
    NveShapeLiveType_eyeSize,
    NveShapeLiveType_eyeCornerStretch,
    NveShapeLiveType_noseWidth,
    NveShapeLiveType_noseLength,
    NveShapeLiveType_mouthSize,
    NveShapeLiveType_mouthCornerLift
};

typedef NS_ENUM(NSInteger, NveMicroShapeLiveType) {
    /// 缩头
    NveMicroShapeLiveType_headSize,
    /// 颧骨
    NveMicroShapeLiveType_malarWidth,
    /// 下颌
    NveMicroShapeLiveType_jawWidth,
    /// 太阳穴
    NveMicroShapeLiveType_templeWidth,
    /// 法令纹
    NveMicroShapeLiveType_removeNasolabialFolds,
    /// 黑眼圈
    NveMicroShapeLiveType_removeDarkCircles,
    /// 亮眼
    NveMicroShapeLiveType_brightenEyes,
    /// 美牙
    NveMicroShapeLiveType_whitenTeeth,
    /// 眼距
    NveMicroShapeLiveType_eyeDistance,
    /// 眼角度
    NveMicroShapeLiveType_eyeAngle,
    /// 人中
    NveMicroShapeLiveType_philtrumLength,
    /// 宽鼻梁
    NveMicroShapeLiveType_noseBridgeWidth,
    /// 鼻头
    NveMicroShapeLiveType_noseHeadWidth,
    /// 眉毛粗细
    NveMicroShapeLiveType_eyebrowThickness,
    /// 眉毛角度
    NveMicroShapeLiveType_eyebrowAngle,
    /// 眉毛左右
    NveMicroShapeLiveType_eyebrowXOffset,
    /// 眉毛上下
    NveMicroShapeLiveType_eyebrowYOffset,
    /// 眼睛宽度
    NveMicroShapeLiveType_eyeWidth,
    /// 眼睛高度
    NveMicroShapeLiveType_eyeHeight,
    /// 眼睛弧度
    NveMicroShapeLiveType_eyeArc,
    /// 眼睛上下
    NveMicroShapeLiveType_eyeYOffset
};

@class NvLiveBeautyTypeModel;
@interface NvLiveCaptureModularVM : NSObject

@property (nonatomic, strong) NvsStreamingContext *streamingContext;

@property (nonatomic, strong) NvsCaptureVideoFx *fxARFace;

@property (nonatomic, strong, nullable) NvsCaptureVideoFx *fxSharpen;

@property (nonatomic, strong, nullable) NvsCaptureVideoFx *fxDefinition;

- (void)applyBeautyEffectModel:(NvLiveBeautyTypeModel *)model withOpen:(BOOL)open;
- (void)applyBeautyShapeModel:(NvLiveBeautyTypeModel *)model withOpen:(BOOL)open;
- (void)applyBeautyMicroshapingModel:(NvLiveBeautyTypeModel *)model withOpen:(BOOL)open;

- (NvsAssetPackageManagerError)installAssetPackage:(NSString *)assetPackageFilePath
                                           license:(NSString *)licenseFilePath
                                              type:(NvsAssetPackageType)type
                                    assetPackageId:(NSMutableString *)assetPackageId;

- (void)creatFaceFx;

- (void)creatFxSharpen;

- (void)creatFxDefinition;

- (CGFloat)getFxCurrentValue:(NvLiveBeautyTypeModel *)model;

@end

NS_ASSUME_NONNULL_END
