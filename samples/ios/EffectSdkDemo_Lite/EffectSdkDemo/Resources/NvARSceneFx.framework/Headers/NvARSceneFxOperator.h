//
//  NvARSceneFxOperator.h
//  NvTest
//
//  Created by ms20180425 on 2022/8/19.
//

#import <Foundation/Foundation.h>
#import "NvARSceneAssetManager.h"

@class NvBeautyTypeModel;
@class NvMakeupToolDataModel;

NS_ASSUME_NONNULL_BEGIN

@interface NvARSceneFxOperator : NSObject

@property (nonatomic, assign) BOOL verifySuccessful;

@property (nonatomic, strong) NvsEffectSdkContext *effectContext;

@property (nonatomic, strong) NvsEffectRenderCore *renderCore;

@property (nonatomic, strong) NvsVideoEffect *faceEffect;

@property (nonatomic, strong) NSMutableArray *beautyEffectArray;

@property (nonatomic, strong) NSMutableArray *beautyShapeArray;

@property (nonatomic, strong) NSMutableArray *beautyMicroArray;

@property (nonatomic, strong) NSMutableArray *beautyMakeupArray;

/// 拍照使用，目前存放Scene Id
/// For taking photos, currently store Scene Id
@property (nonatomic, strong) NSMutableDictionary *takePictureInfo;

+ (NvARSceneFxOperator *)sharedInstance;

+ (void)dellocInstance;

/// 验证授权文件
/// Validate the authorization file
/// @param lic 授权文件路径 Authorization file path
- (void)verifySdkLicenseFile:(NSString *)lic;

/// 检测库是否带有人脸功能
/// Check if the library has face functionality
+ (BOOL)hasARModule;

/// 初始化人脸模型
/// Initialize the face model
+ (BOOL)initARFace;

/// 创建人脸特效
/// Creating a face effect
- (void)creatARScene;

/// 初始化数据
/// Initializing data
- (void)setupData;

/// 应用美颜
/// Apply beauty
/// @param model 模型
- (void)applicationBeautyEffect:(NvBeautyTypeModel *)model;

/// 对数组进行遍历，应用美颜的时候，同一类型特效只应用一种
/// Iterate through the array, and when applying beauty, only one effect of the same type will be applied
/// @param model 模型
- (BOOL)applicationDefaultBeautyEffect:(NvBeautyTypeModel*)model;

/// 应用微整形
/// Applying micro-shaping
/// @param model 模型
- (void)applicationBeautyShapeAndMicro:(NvBeautyTypeModel *)model;

/// 应用美妆
/// Apply beauty makeup
/// @param model 模型
/// @param sing 是否是单妆
- (void)applicationMakeup:(NvMakeupToolDataModel *)model withSingleMakeup:(BOOL)sing;

/// 检查手机是否有某种特效的能力，比如去油光，根据能力，再去重新更新数据，这个接口需要依赖外部NvsEffectRenderCore对象的initializeWithFlags方法，要在这个方法之后调用
/// The ability to check whether the phone has a special effect, such as degreying, and then update the data based on that ability relies on the initializeWithFlags method of the external NvsEffectRenderCore object, which is called after this method
- (void)detectionCapability;

/// 创建拍照特效
/// Creating photo effects
/// @param NSMutableDictionary 美妆数据
- (NvsVideoEffect *)createTakePictureARScene:(NSMutableDictionary *)makeUpInfo;
@end

NS_ASSUME_NONNULL_END
