//
//  NvARSceneFxOperator.m
//  NvTest
//
//  Created by ms20180425 on 2022/8/19.
//

#import "NvARSceneFxOperator.h"
#import "YYModel.h"
#import "NvMakeupToolModel.h"
#import "NvMakeupToolMakeupModuler.h"
#import "NvBeautyTypeModel.h"
#import "NvARLocalString.h"

@interface NvARSceneFxOperator ()

@property (nonatomic, assign) NvsEffectRational rational;

@property (nonatomic, strong) NvARSceneAssetManager *assetManager;
@property (nonatomic, strong) NvsVideoEffect *tmpEF;

@property (nonatomic, strong) NvMakeupToolMakeupModuler *makeupModuler;
@property (nonatomic, strong) NvMakeupToolMakeupModuler *makeupModulerForTakePicture;

/// 妆容包会有其他文件，使用相关功能的时候需要加载这些文件，配置一个根目录
/// The makeup package will have other files that you will need to load and configure a root directory to use the related functionality
@property (nonatomic, strong) NSString *packagePath;

@end

@implementation NvARSceneFxOperator

- (void)dealloc{
    NSLog(@"%s",__func__);
}

static NvARSceneFxOperator *sharedInstance = nil;
static dispatch_once_t pred;

+ (NvARSceneFxOperator *)sharedInstance {
    dispatch_once(&pred, ^{
        sharedInstance = [[NvARSceneFxOperator alloc] init];
        sharedInstance.assetManager = [NvARSceneAssetManager sharedInstance];
        sharedInstance.makeupModuler = [[NvMakeupToolMakeupModuler alloc] init];
        sharedInstance.makeupModulerForTakePicture = [[NvMakeupToolMakeupModuler alloc] init];

    });
    
    return sharedInstance;
}

+ (void)dellocInstance{
    [NvARSceneAssetManager dellocInstance];
    
    pred = 0;
    sharedInstance.effectContext = nil;
    sharedInstance = nil;
}

#pragma mark - 验证授权
- (void)verifySdkLicenseFile:(NSString *)lic{
    // 授权sdk
    self.verifySuccessful = [NvsEffectSdkContext verifySdkLicenseFile:lic];
    if (self.verifySuccessful) {
        NSLog(@"========美摄sdk授权成功 sdk authorization succeeded");
    }else{
        NSLog(@"========美摄sdk授权失败 sdk authorization failure");
    }
}

#pragma mark - 验证库是否包含人脸功能
//Verify that the library contains face features
+ (BOOL)hasARModule {
    return [NvsEffectSdkContext hasARModule] > 0;
}

#pragma mark - 验证有人脸初始化是否成功
//Verify that there is a face initialization is successful
+ (BOOL)initARFace
{
    BOOL isInitArFaceSuccess = NO;
    if (ARSCENE_MS240 || ARSCENE_MS106) {
        isInitArFaceSuccess = [self initARFaceMS];
    }else if(ARSCENE_ST240 || ARSCENE_ST106){
        isInitArFaceSuccess = [self initARFaceST];
    }
    
    return isInitArFaceSuccess;
}

#pragma mark - 验证商汤人脸初始化
//Validate Sensetime face initialization
+ (BOOL)initARFaceST{
    BOOL isInitArFaceSuccess = NO;
    return isInitArFaceSuccess;
}

#pragma mark - 验证美摄人脸初始化
//Validate the beauty shot face initialization
+ (BOOL)initARFaceMS{
    BOOL isInitArFaceSuccess = NO;
    if ([NvARSceneFxOperator hasARModule]) {
        NSString *msPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"license.bundle"];
        
        //人脸模型
        //Face model
        NSString *faceModel = [msPath stringByAppendingPathComponent:@"ms_face106_v4.0.1.next.model"];
        if (ARSCENE_MS240) {
            faceModel = [msPath stringByAppendingPathComponent:@"ms_face240_v4.0.1.next.model"];
        }
        isInitArFaceSuccess = [NvsEffectSdkContext initHumanDetection:faceModel licenseFilePath:nil features:NvsEffectSdkHumanDetectionFeature_FaceLandmark|NvsEffectSdkHumanDetectionFeature_FaceAction| NvsEffectSdkHumanDetectionFeature_ImageMode|NvsEffectSdkHumanDetectionFeature_VideoMode|NvsEffectSdkHumanDetectionFeature_SemiImageMode];
        NSLog(@"=================初始化人脸模型 Initialize the face model：%@",isInitArFaceSuccess?@"成功 success":@"失败 failure");
        
        NSString *segFilePath = [msPath stringByAppendingPathComponent:@"ms_humansegment_medium_v2.0.0.next.model"];
        BOOL backgroundSuccess = [NvsEffectSdkContext initHumanDetectionExt:segFilePath licenseFilePath:nil features:NvsEffectSdkHumanDetectionFeature_Background];
        NSLog(@"=================初始化背景分割模型 Initialize the background segmentation model：%@",backgroundSuccess?@"成功 success":@"失败 failure");
        
        NSString *handActionPath = [msPath stringByAppendingPathComponent:@"ms_hand_common_v2.0.0.next.model"];
        BOOL handLandmarkSuccess = [NvsEffectSdkContext initHumanDetectionExt:handActionPath licenseFilePath:nil features:NvsEffectSdkHumanDetectionFeature_HandAction|
                                    NvsEffectSdkHumanDetectionFeature_HandLandmark| NvsEffectSdkHumanDetectionFeature_SemiImageMode];
        NSLog(@"=================初始化手势模型 Initialize the gesture model：%@",handLandmarkSuccess?@"成功 success":@"失败 failure");
        
        NSString *fakeface = [msPath stringByAppendingPathComponent:@"fakeface_v1.0.1.dat"];
        BOOL fakeFaceSuccess = [NvsEffectSdkContext setupHumanDetectionData:NvsEffectSdkHumanDetectionDataType_FakeFace dataFilePath:fakeface];
        NSLog(@"=================初始化假脸模型 Initialize the fake face model：%@",fakeFaceSuccess?@"成功 success":@"失败 failure");
        
        NSString *mnnFilePath = [msPath stringByAppendingPathComponent:@"ms_avatar_v2.0.0.next.model"];
        BOOL avatarExpressionSuccess = [NvsEffectSdkContext initHumanDetectionExt:mnnFilePath licenseFilePath:nil features:NvsEffectSdkHumanDetectionFeature_AvatarExpression|NvsEffectSdkHumanDetectionFeature_ImageMode|NvsEffectSdkHumanDetectionFeature_VideoMode|NvsEffectSdkHumanDetectionFeature_SemiImageMode];
        NSLog(@"=================初始化Avatar模型 Initialize the Avatar model：%@",avatarExpressionSuccess?@"成功 success":@"失败 failure");
        
        NSString *eyecontourFilePath = [msPath stringByAppendingPathComponent:@"ms_eyecontour_v2.0.0.next.model"];
        BOOL eyecontourSuccess = [NvsEffectSdkContext initHumanDetectionExt:eyecontourFilePath licenseFilePath:nil features:NvsEffectSdkHumanDetectionFeature_EyeballLandmark | NvsEffectSdkHumanDetectionFeature_SemiImageMode];
        NSLog(@"=================初始化眼球模型 Initialize the eyeball model：%@",eyecontourSuccess?@"成功 success":@"失败 failure");
        
        NSString *faceCommon = [msPath stringByAppendingPathComponent:@"facecommon_v1.0.1.dat"];
        
        BOOL faceCommonSuccess = [NvsEffectSdkContext setupHumanDetectionData:NvsEffectSdkHumanDetectionDataType_FaceCommon dataFilePath:faceCommon];
        NSLog(@"=================初始化Face Common模型 Initiate the beauty model：%@",faceCommonSuccess?@"成功 success":@"失败 failure");
        
        NSString *advancedBeauty = [msPath stringByAppendingPathComponent:@"advancedbeauty_v1.0.1.dat"];
        
        BOOL advancedBeautySuccess = [NvsEffectSdkContext setupHumanDetectionData:NvsEffectSdkHumanDetectionDataType_AdvancedBeauty dataFilePath:advancedBeauty];
        NSLog(@"=================初始化美颜模型 Initiate the beauty model：%@",advancedBeautySuccess?@"成功 success":@"失败 failure");
    }
    return isInitArFaceSuccess;
}

#pragma mark - 初始化人脸特效
//Initialize the face effect
- (void)creatARScene{
    self.rational = (NvsEffectRational){9,16};
    self.faceEffect = [self.effectContext createVideoEffect:@"AR Scene" aspectRatio:self.rational realTime:NO];
    [self.faceEffect setBooleanVal:@"Beauty Effect" val:YES];
    [self.faceEffect setBooleanVal:@"Beauty Shape" val:YES];
    [self.faceEffect setBooleanVal:@"Face Mesh Internal Enabled" val:YES];
    [self.faceEffect setBooleanVal:@"Advanced Beauty Enable" val:YES];
    [self.faceEffect setBooleanVal:@"Max Faces Respect Min" val:YES];
    
    if (ARSCENE_MS240) {
        [self.faceEffect setBooleanVal:@"Use Face Extra Info" val:YES];
    }
    self.takePictureInfo = [NSMutableDictionary dictionary];

}
- (NvsVideoEffect *)createTakePictureARScene:(NSMutableDictionary *)makeUpInfo{
    NvsVideoEffect * takePictureFaceEffect = [self.effectContext createVideoEffect:@"AR Scene" aspectRatio:self.rational realTime:YES];
    [takePictureFaceEffect setBooleanVal:@"Beauty Effect" val:YES];
    [takePictureFaceEffect setBooleanVal:@"Beauty Shape" val:YES];
    [takePictureFaceEffect setBooleanVal:@"Face Mesh Internal Enabled" val:YES];
    [takePictureFaceEffect setBooleanVal:@"Advanced Beauty Enable" val:YES];
    [takePictureFaceEffect setBooleanVal:@"Max Faces Respect Min" val:YES];
    
    if (ARSCENE_MS240) {
        [takePictureFaceEffect setBooleanVal:@"Use Face Extra Info" val:YES];
    }
    //美颜
    // Beauty
    for (NvBeautyTypeModel *model in self.beautyEffectArray) {
        if (![self isIgnoreFx:model]) {
            [self applicationBeautyEffect:model arScene:takePictureFaceEffect];
        }
    }
    //美型
    //beautyShape
    for (NvBeautyTypeModel *model in self.beautyShapeArray) {
        [self applicationBeautyShapeAndMicro:model arScene:takePictureFaceEffect];
    }
    //微整形
    //beautyMicro
    for (NvBeautyTypeModel *model in self.beautyMicroArray) {
        [self applicationBeautyShapeAndMicro:model arScene:takePictureFaceEffect];
    }
    //美妆
    //makeup
    [makeUpInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSInteger index = [key integerValue];
        NvMakeupToolDataModel * model = (NvMakeupToolDataModel *)obj;
        [self applicationMakeupForTakePicture:model withSingleMakeup:index==0?NO:YES arScene:takePictureFaceEffect];

    }];
    return takePictureFaceEffect;
}

- (void)applicationMakeupForTakePicture:(NvMakeupToolDataModel *)model withSingleMakeup:(BOOL)sing arScene:(NvsVideoEffect *)faceEffect{
    self.makeupModulerForTakePicture.fxARFace = faceEffect;
    
    if (sing) {
        [self.makeupModulerForTakePicture applySingMakeupPackage:model.effectContent];
    }else{
        NSArray *kindArr =  @[@"Brighten",@"Eyelash",@"Lip",@"Eyebrow",@"Blusher",@"Shadow",@"Eyeliner",@"Eyeshadow"];
        [self.makeupModulerForTakePicture applyMakeupPackage:model.effectContent makeupKindArr:kindArr];
        
        [self applyMakeupFilterEffect:model.effectContent];
        [self applyMakeupBeautyEffect:model.effectContent arScene:faceEffect];
        [self applyMakeupBeautyShapeAndMicroEffect:model.effectContent withMicro:NO arScene:faceEffect];
        [self applyMakeupBeautyShapeAndMicroEffect:model.effectContent withMicro:YES arScene:faceEffect];
    }
}

- (BOOL)isIgnoreFx:(NvBeautyTypeModel*)model{
    if ([model.name isEqualToString:@"磨皮1"] ||
        [model.name isEqualToString:@"磨皮2"] ||
        [model.name isEqualToString:@"磨皮3"] ||
        [model.name isEqualToString:@"磨皮4"] ||
        [model.name isEqualToString:@"美白A"] ||
        [model.name isEqualToString:@"美白B"]) {
        return YES;
    }else{
        return NO;
    }
}
#pragma mark - 初始化数据
- (void)setupData{
    [self setupBeautyEffectArrayData];
    [self setupBeautyShapeArrayData];
    [self setupBeautyMicroArrayData];
    [self setupBeautyMakeupArrayData];
}

#pragma mark - 初始化美颜数据
//Initialize the beauty data
- (void)setupBeautyEffectArrayData{
    self.beautyEffectArray = [NSMutableArray array];
    NSString *bundlePath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"beautyJson"];
    NSString *jsonPath = [bundlePath stringByAppendingPathComponent:@"beautyEffect.json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSArray *array = [NSArray yy_modelArrayWithClass:NvBeautyTypeModel.class json:data];
    [self.beautyEffectArray addObjectsFromArray:array];
    
    for (NvBeautyTypeModel *model in self.beautyEffectArray) {
        model.isBeauty = YES;
        model.isOperation = YES;
        model.name = NvBundleLocalString(model.name, nil, [self class]);
        if (model.packageUrl && model.packageUrl.length > 0) {
            model.packageUrl = [bundlePath stringByAppendingPathComponent:model.packageUrl];
            model.uuid = [[NvARSceneAssetManager sharedInstance] installAssetPackage:model.packageUrl licPath:nil assetType:NvsAssetPackageType_VideoFx];
        }
    }
}

#pragma mark - 初始化美型数据
//Initialize the beauty data
- (void)setupBeautyShapeArrayData{
    self.beautyShapeArray = [NSMutableArray array];
    NSString *jsonPath = [[[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"beautyJson"] stringByAppendingPathComponent:@"beautyShape.json"];
    NSString *beautyShapeDataPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"beautyShapeData.bundle"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSArray *array = [NSArray yy_modelArrayWithClass:NvBeautyTypeModel.class json:data];
    [self.beautyShapeArray addObjectsFromArray:array];
    for (NvBeautyTypeModel *model in self.beautyShapeArray) {
        if (model.packageUrl && model.packageUrl.length > 0) {
            model.packageUrl = [beautyShapeDataPath stringByAppendingPathComponent:model.packageUrl];
            if ([model.fxName containsString:@"Warp"]) {
                model.uuid = [[NvARSceneAssetManager sharedInstance] installAssetPackage:model.packageUrl licPath:nil assetType:NvsAssetPackageType_Warp];
            }else{
                model.uuid = [[NvARSceneAssetManager sharedInstance] installAssetPackage:model.packageUrl licPath:nil assetType:NvsAssetPackageType_FaceMesh];
            }
        }
        model.name = NvBundleLocalString(model.name, nil, [self class]);
        model.defaultShapePackage = model.uuid;
        model.isBeauty = NO;
        model.isOperation = YES;
    }
}

#pragma mark - 初始化微整形数据
//Initialize the microshaping data
- (void)setupBeautyMicroArrayData{
    self.beautyMicroArray = [NSMutableArray array];
    NSString *jsonPath = [[[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"beautyJson"] stringByAppendingPathComponent:@"beautyMicro.json"];
    NSString *beautyShapeDataPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"beautyShapeData.bundle"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSArray *array = [NSArray yy_modelArrayWithClass:NvBeautyTypeModel.class json:data];
    [self.beautyMicroArray addObjectsFromArray:array];
    for (NvBeautyTypeModel *model in self.beautyMicroArray) {
        if (model.packageUrl && model.packageUrl.length > 0) {
            model.packageUrl = [beautyShapeDataPath stringByAppendingPathComponent:model.packageUrl];
            if ([model.packageUrl hasSuffix:@"warp"]) {
                model.uuid = [[NvARSceneAssetManager sharedInstance] installAssetPackage:model.packageUrl licPath:nil assetType:NvsAssetPackageType_Warp];
            }else{
                model.uuid = [[NvARSceneAssetManager sharedInstance] installAssetPackage:model.packageUrl licPath:nil assetType:NvsAssetPackageType_FaceMesh];
            }
        }
        
        model.name = NvBundleLocalString(model.name, nil, [self class]);
        model.defaultShapePackage = model.uuid;
        model.isBeauty = NO;
        model.isOperation = YES;
    }
}

#pragma mark - 初始化美妆数据
//Initialize the beauty data
- (void)setupBeautyMakeupArrayData{
    self.beautyMakeupArray = [NSMutableArray array];
    NSString *beautyMakeupData = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"beautyMakeupData"];
    NSString *jsonPath = [beautyMakeupData stringByAppendingPathComponent:@"beautyMakeup.json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    
    NSArray *array = [NSArray yy_modelArrayWithClass:NvMakeupToolDataModel.class json:data];
    [self.beautyMakeupArray addObjectsFromArray:array];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *packagePath;
    NSString *tempPackagePath;

    for (NvMakeupToolDataModel *model in self.beautyMakeupArray) {
        jsonPath = [beautyMakeupData stringByAppendingPathComponent:model.infoPath];
        data = [NSData dataWithContentsOfFile:jsonPath];
        array = [NSArray yy_modelArrayWithClass:NvMakeupToolDataModel.class json:data];
        model.contents = [NSMutableArray array];
        [model.contents addObjectsFromArray:array];
        
        for (NvMakeupToolDataModel *contentModel in model.contents) {
            packagePath = [beautyMakeupData stringByAppendingPathComponent:contentModel.packagePath];
            NSArray * tempArray = [fileManager contentsOfDirectoryAtPath:packagePath error:nil];
            for (NSString *tempPath in tempArray) {
                tempPackagePath = [packagePath stringByAppendingPathComponent:tempPath];
                if ([tempPath.pathExtension isEqualToString:@"json"]) {
                    if ([tempPath containsString:@"makeup.json"] || [contentModel.packagePath hasPrefix:@"Eyeball"]) {
                        data = [NSData dataWithContentsOfFile:tempPackagePath];
                        NSDictionary* tempDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        NvMakeupToolModel *makeupEffectContentModel =  [NvMakeupToolModel yy_modelWithJSON:data];
                        if (makeupEffectContentModel) {
                            makeupEffectContentModel.effectContent = NvMakeupToolEffectContentModel.new;
                            makeupEffectContentModel.effectContent.makeup = NSMutableArray.array;
                            
                            NvMakeupToolEffectModel *effectModel = NvMakeupToolEffectModel.new;
                            effectModel.type = tempDictionary[@"makeupId"];
                            effectModel.canReplace = YES;
                            
                            NvMakeupToolElementStringModel *stringModel = NvMakeupToolElementStringModel.new;
                            stringModel.key = tempDictionary[@"className"];
                            stringModel.value = contentModel.uuid;
                            stringModel.type = @"string";
                            
                            effectModel.params = @[stringModel];
                            [makeupEffectContentModel.effectContent.makeup addObject:effectModel];
                            
                            contentModel.translation = makeupEffectContentModel.translation;
                            contentModel.effectContent = makeupEffectContentModel.effectContent;
                        }
                    }else if([tempPath containsString:@"info.json"]){
                        data = [NSData dataWithContentsOfFile:tempPackagePath];
                        NvMakeupToolModel *tempModel = [NvMakeupToolModel yy_modelWithJSON:data];
                        contentModel.translation = tempModel.translation;
                        contentModel.uuid = tempModel.uuid;
                        contentModel.effectContent = tempModel.effectContent;
                    }
                }else if ([tempPath.pathExtension isEqualToString:@"videofx"]){
                    [[NvARSceneAssetManager sharedInstance] installAssetPackage:tempPackagePath licPath:nil assetType:NvsAssetPackageType_VideoFx];
                }else if ([tempPath.pathExtension isEqualToString:@"makeup"]){
                    [[NvARSceneAssetManager sharedInstance] installAssetPackage:tempPackagePath licPath:nil assetType:NvsAssetPackageType_Makeup];
                }else if ([tempPath.pathExtension isEqualToString:@"facemesh"]){
                    [[NvARSceneAssetManager sharedInstance] installAssetPackage:tempPackagePath licPath:nil assetType:NvsAssetPackageType_FaceMesh];
                }else if ([tempPath.pathExtension isEqualToString:@"warp"]){
                    [[NvARSceneAssetManager sharedInstance] installAssetPackage:tempPackagePath licPath:nil assetType:NvsAssetPackageType_Warp];
                }else if(([tempPath.pathExtension isEqualToString:@"png"] || [tempPath.pathExtension isEqualToString:@"jpg"]) && (contentModel.coverImage.length <= 0 || !contentModel.coverImage)){
                    contentModel.coverImage = tempPackagePath;
                }
            }
            
            ///中文对应的displayNameZhCn，英文对应的字段查看displayName
            ///The corresponding displayNameZhCn in Chinese and the corresponding field in English are displayName
            if ([model.displayNameZhCn isEqualToString:@"妆容"]) {
                if ([contentModel.displayNameZhCn isEqualToString:@"原图"] || [contentModel.displayNameZhCn isEqualToString:@"无"]) {

                }else{
                    contentModel.coverImage = [beautyMakeupData stringByAppendingPathComponent:contentModel.coverImage];
                }
            }
        }
    }
    
    for (int i = 1; i < self.beautyMakeupArray.count; i++) {
        NvMakeupToolDataModel *model = self.beautyMakeupArray[i];
        if (model.contents[1]) {
            if (model.contents[1].effectContent.makeup.firstObject){
                model.contents.firstObject.effectContent.makeup = NSMutableArray.array;
                NvMakeupToolEffectModel *effectModel = NvMakeupToolEffectModel.new;
                effectModel.type = model.contents[1].effectContent.makeup.firstObject.type;
                [model.contents.firstObject.effectContent.makeup addObject:effectModel];
            }
        }
    }
}

#pragma mark - 检测手机是否支持某个能力
//Detects whether a capability is supported on the phone
- (void)detectionCapability{
    NvsARSceneManipulate * manipulate = [self.faceEffect getARSceneManipulate];
    BOOL matte = [manipulate isFunctionAvailable:NvsToBeCheckedFunctionType_Matte];
    NSInteger index = 0;
    for (NvBeautyTypeModel *model in self.beautyEffectArray) {
        if (!matte && ([model.name isEqualToString:@"去油光"] || [model.name isEqualToString:@"matte"])) {
            index = [self.beautyEffectArray indexOfObject:model];
        }
    }
    
    if (!matte) {
        [self.beautyEffectArray removeObjectAtIndex:index];
    }
}
#pragma mark - 应用美颜效果
//Apply beauty effects
- (void)applicationBeautyEffect:(NvBeautyTypeModel *)model arScene:(NvsVideoEffect *)faceEffect{
    if ([model.name isEqualToString:@"校色"] || [model.name isEqualToString:@"color correction"]) {
        /*
         校色是用一个滤镜特效实现，滤镜特效由外部自己创建和维护
         Color correction is achieved using a filter effect, which is created and maintained externally
         */
    }else if ([model.name isEqualToString:@"锐度"] || [model.name isEqualToString:@"sharpness"]){
        [faceEffect setBooleanVal:model.fxName val:model.open];
    }else if([model.name isEqualToString:@"美白A"] || [model.name isEqualToString:@"whitening A"]){
        [faceEffect setStringVal:@"Whitening Lut File" val:@""];
        [faceEffect setBooleanVal:@"Whitening Lut Enabled" val:NO];
        [faceEffect setFloatVal:model.fxName val:model.value];
    }else if([model.name isEqualToString:@"美白B"] || [model.name isEqualToString:@"whitening B"]){
        NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"whitenLut.bundle"];
        NSString *lutPath = [path stringByAppendingPathComponent:@"preset.mslut"];
        [faceEffect setStringVal:@"Whitening Lut File" val:lutPath];
        [faceEffect setBooleanVal:@"Whitening Lut Enabled" val:YES];
        [faceEffect setFloatVal:model.fxName val:model.value];
    }else if ([model.name isEqualToString:@"去油光"] || [model.name isEqualToString:@"matte"]){
        [faceEffect setFloatVal:@"Advanced Beauty Matte Intensity" val:model.value];
        [faceEffect setFloatVal:@"Advanced Beauty Matte Fill Radius" val:3+model.radiusValue*27];
    }else if([model.name isEqualToString:@"磨皮1"] || [model.name isEqualToString:@"skinning1"]){
        [faceEffect setFloatVal:@"Advanced Beauty Intensity" val:0];
        [faceEffect setFloatVal:model.fxName val:model.value];
    }else if([model.name isEqualToString:@"磨皮2"] || [model.name isEqualToString:@"skinning2"]){
        [faceEffect setBooleanVal:@"Advanced Beauty Enable" val:YES];
        [faceEffect setIntVal:@"Advanced Beauty Type" val:0];
        [faceEffect setFloatVal:@"Beauty Strength" val:0];
        [faceEffect setFloatVal:@"Advanced Beauty Intensity" val:model.value];
    }else if([model.name isEqualToString:@"磨皮3"] || [model.name isEqualToString:@"skinning3"]){
        [faceEffect setBooleanVal:@"Advanced Beauty Enable" val:YES];
        [faceEffect setIntVal:@"Advanced Beauty Type" val:1];
        [faceEffect setFloatVal:@"Beauty Strength" val:0];
        [faceEffect setFloatVal:@"Advanced Beauty Intensity" val:model.value];
    }else if([model.name isEqualToString:@"磨皮4"] || [model.name isEqualToString:@"skinning4"]){
        [faceEffect setBooleanVal:@"Advanced Beauty Enable" val:YES];
        [faceEffect setIntVal:@"Advanced Beauty Type" val:2];
        [faceEffect setFloatVal:@"Beauty Strength" val:0];
        [faceEffect setFloatVal:@"Advanced Beauty Intensity" val:model.value];
    }else{
        if (model.degreeName.length > 0) {
            [faceEffect setFloatVal:model.degreeName val:model.value];
        }
    }
}

- (void)applicationBeautyEffect:(NvBeautyTypeModel *)model{
    [self applicationBeautyEffect:model arScene:self.faceEffect];
}

#pragma mark - 对数组进行遍历，应用美颜的时候，同一类型特效只应用一种
//Iterate through the array, and when applying beauty, only one effect of the same type will be applied
- (BOOL)applicationDefaultBeautyEffect:(NvBeautyTypeModel*)model{
    if ([model.name isEqualToString:@"磨皮1"] ||
        [model.name isEqualToString:@"磨皮3"] ||
        [model.name isEqualToString:@"磨皮4"] ||
        [model.name isEqualToString:@"美白A"]) {
        return NO;
    }else{
        return YES;
    }
}

#pragma mark - 应用美型、微整形效果
//Apply beauty, micro plastic effect
- (void)applicationBeautyShapeAndMicro:(NvBeautyTypeModel *)model arScene:(NvsVideoEffect *)faceEffect{
    if(model.degreeName && model.degreeName.length > 0) {
        [self setWarpStrategy:model];
        [faceEffect setStringVal:model.fxName val:model.uuid];
        [faceEffect setFloatVal:model.degreeName val:model.value];
    }else{
        [faceEffect setFloatVal:model.fxName val:model.value];
    }
}
- (void)applicationBeautyShapeAndMicro:(NvBeautyTypeModel *)model{
    [self applicationBeautyShapeAndMicro:model arScene:self.faceEffect];
}
- (void)setWarpStrategy:(NvBeautyTypeModel *)model arScene:(NvsVideoEffect *)faceEffect{
    if ([model.fxName isEqualToString:@"Warp Forehead Height Custom Package Id"]) {
        [faceEffect setIntVal:@"Forehead Height Warp Strategy" val:0x7FFFFFFF];
    }
    else if ([model.fxName isEqualToString:@"Warp Head Size Custom Package Id"]) {
        [faceEffect setIntVal:@"Head Size Warp Strategy" val:0x7FFFFFFF];
    }
}
- (void)setWarpStrategy:(NvBeautyTypeModel *)model {
    [self setWarpStrategy:model arScene:self.faceEffect];
}

#pragma mark - 应用美妆
///Apply beauty makeup
- (void)applicationMakeup:(NvMakeupToolDataModel *)model withSingleMakeup:(BOOL)sing{
    self.makeupModuler.fxARFace = self.faceEffect;
    NSString *beautyMakeupData = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"beautyMakeupData"];
    self.packagePath = [beautyMakeupData stringByAppendingPathComponent:model.packagePath];
    
    if (sing) {
        [self.makeupModuler applySingMakeupPackage:model.effectContent];
    }else{
        [self applyMakeupPackage:model.effectContent];
        [self applyMakeupFilterEffect:model.effectContent];
        [self applyMakeupBeautyEffect:model.effectContent arScene:self.faceEffect];
        [self applyMakeupBeautyShapeAndMicroEffect:model.effectContent withMicro:NO arScene:self.faceEffect];
        [self applyMakeupBeautyShapeAndMicroEffect:model.effectContent withMicro:YES arScene:self.faceEffect];
    }
}

#pragma mark - 应用整妆中的美妆效果
///Apply the beauty effect in makeup
- (void)applyMakeupPackage:(NvMakeupToolEffectContentModel *)effectModel{
    NSArray *kindArr =  @[@"Brighten",@"Eyelash",@"Lip",@"Eyebrow",@"Blusher",@"Shadow",@"Eyeliner",@"Eyeshadow"];
    
    [self.makeupModuler applyMakeupPackage:effectModel makeupKindArr:kindArr];
}

#pragma mark - 应用整妆中的滤镜效果
///Apply a filter effect from makeup
- (void)applyMakeupFilterEffect:(NvMakeupToolEffectContentModel *)effectModel{
    /*
     滤镜特效由外部自己创建和维护
     Filter effects are created and maintained externally
     */
}

#pragma mark - 应用美妆中的美颜
///Apply beauty in makeup
- (void)applyMakeupBeautyEffect:(NvMakeupToolEffectContentModel *)effectModel arScene:(NvsVideoEffect *)faceEffect{
    if (effectModel) {
        for (NvBeautyTypeModel *model in self.beautyEffectArray) {
            model.value = 0;
            model.radiusValue = 0;
            model.open = NO;
            [self applicationBeautyEffect:model arScene:faceEffect];
        }
        
        for (NvMakeupToolEffectModel *beautyModel in effectModel.beauty) {
            [self findTheMatching:beautyModel arScene:faceEffect];
        }
        
        //获取美颜效果的具体参数，更新到数据模型里
        ///Get the specific parameters of the beauty effect and update them to the data model
        for (NvBeautyTypeModel *model in self.beautyEffectArray) {
            if ([model.name isEqualToString:@"锐度"] || [model.name isEqualToString:@"sharpness"]){
                model.open = [faceEffect getBooleanVal:model.fxName];
            }else if ([model.name isEqualToString:@"去油光"] || [model.name isEqualToString:@"matte"]){
                model.value = [faceEffect getFloatVal:@"Advanced Beauty Matte Intensity"];
                model.radiusValue = [faceEffect getFloatVal:@"Advanced Beauty Matte Fill Radius"];
                model.radiusValue = (model.radiusValue - 3)/27.0;
            }else if(([model.name isEqualToString:@"磨皮2"] || [model.name isEqualToString:@"skinning2"]) || ([model.name isEqualToString:@"磨皮3"] || [model.name isEqualToString:@"skinning3"]) || ([model.name isEqualToString:@"磨皮4"] || [model.name isEqualToString:@"skinning4"])){
                model.value = [faceEffect getFloatVal:@"Advanced Beauty Intensity"];
            }else{
                model.value = [faceEffect getFloatVal:model.fxName];
            }
        }
    }else{
        for (NvBeautyTypeModel *model in self.beautyEffectArray) {
            model.value = model.defaultValue;
            model.radiusValue = model.defaultRadiusValue;
            model.open = NO;
            model.canReplace = YES;
            if ([model.name isEqualToString:@"磨皮1"] ||
                [model.name isEqualToString:@"磨皮3"] ||
                [model.name isEqualToString:@"磨皮4"] ||
                [model.name isEqualToString:@"美白A"]) {
                
            }else{
                [self applicationBeautyEffect:model];
            }
        }
    }
}

#pragma mark - 匹配并且应用美妆中的美颜
//Match and apply the beauty in your makeup
- (void)findTheMatching:(NvMakeupToolEffectModel *)beautyModel arScene:(NvsVideoEffect *)faceEffect{
    NSMutableArray *containKindArr = [NSMutableArray array];
    if(beautyModel.params.count > 0){
        //美颜效果应用
        ///Beauty effect application
        for (NvMakeupToolElementModel *item in beautyModel.params) {
            [self applyMakeupToolElements:faceEffect item:item reset:NO];
        }
    }else if ([beautyModel.type caseInsensitiveCompare:@"ColorCorrect"] == NSOrderedSame){
        for (NvBeautyTypeModel *model in self.beautyEffectArray) {
            if ([model.name isEqualToString:@"校色"] || [model.name isEqualToString:@"color correction"]){
                model.value = beautyModel.value;
                model.canReplace = beautyModel.canReplace;
                model.open = YES;
                [self applicationBeautyEffect:model arScene:faceEffect];
                break;
            }
        }
    }
}

#pragma mark - 应用美妆中的美型、微整形
///Application of beauty makeup in the beauty, micro plastic
- (void)applyMakeupBeautyShapeAndMicroEffect:(NvMakeupToolEffectContentModel *)effectModel withMicro:(BOOL)micro arScene:(NvsVideoEffect *)faceEffect{
    NSMutableArray *mutableArray;
    NSMutableArray *mutableArray1;
    if (micro) {
        mutableArray = self.beautyMicroArray;
        mutableArray1 = effectModel.microShape;
    }else{
        mutableArray = self.beautyShapeArray;
        mutableArray1 = effectModel.shape;
    }
    
    if (effectModel) {
        for (NvBeautyTypeModel *model in mutableArray) {
            model.value = 0;
            [self applicationBeautyShapeAndMicro:model arScene:faceEffect];
        }
        
        for (NvMakeupToolEffectModel *model in mutableArray1) {
            if (model.params.count>0) {
                for(NvMakeupToolElementModel *item in model.params) {
                    [self applyMakeupToolElements:faceEffect item:item reset:NO];
                }
            }
        }
        
        for (NvBeautyTypeModel *model in mutableArray) {
            if(model.degreeName && model.degreeName.length > 0) {
                model.value = [faceEffect getFloatVal:model.degreeName];
            }else{
                model.value = [faceEffect getFloatVal:model.fxName];
            }
        }
    }else{
        for (NvBeautyTypeModel *model in mutableArray) {
            model.value = model.defaultValue;
            model.uuid = model.defaultShapePackage;
            model.canReplace = YES;
            [self applicationBeautyShapeAndMicro:model arScene:faceEffect];
        }
    }
}

#pragma mark - 应用具体特效
///Applying specific effects
- (NSString *)applyMakeupToolElements:(NvsVideoEffect *)fx item:(NvMakeupToolElementModel *)item reset:(BOOL)reset {
    NSString *appliedItem;
    if ([item.type caseInsensitiveCompare:@"string"] == NSOrderedSame) {
        NvMakeupToolElementStringModel *effect = (NvMakeupToolElementStringModel *)item;
        [fx setStringVal:effect.key val:effect.value];
    }else if ([item.type caseInsensitiveCompare:@"float"] == NSOrderedSame || [item.type caseInsensitiveCompare:@"double"] == NSOrderedSame) {
        NvMakeupToolElementFloatModel *effect = (NvMakeupToolElementFloatModel *)item;
        [fx setFloatVal:effect.key val:effect.value];
        appliedItem = effect.key;
    }else if ([item.type caseInsensitiveCompare:@"path"] == NSOrderedSame) {
        NvMakeupToolElementStringModel *effect = (NvMakeupToolElementStringModel *)item;
        [fx setStringVal:effect.key val:[self.packagePath stringByAppendingPathComponent:effect.value]];
    }else if ([item.type caseInsensitiveCompare:@"boolean"] == NSOrderedSame) {
        NvMakeupToolElementBOOLModel *effect = (NvMakeupToolElementBOOLModel *)item;
        [fx setBooleanVal:effect.key val:effect.value];
        appliedItem = effect.key;
    }else if ([item.type caseInsensitiveCompare:@"int"] == NSOrderedSame) {
        NvMakeupToolElementIntModel *effect = (NvMakeupToolElementIntModel *)item;
        [fx setIntVal:effect.key val:effect.value];
    }else if ([item.type caseInsensitiveCompare:@"color"] == NSOrderedSame) {
        NvMakeupToolElementColorModel *effect = (NvMakeupToolElementColorModel *)item;
        NvsColor color = {effect.r,effect.g,effect.b,effect.a};
        [fx setColorVal:effect.key val:&color];
    }
    if (reset) {
        return nil;
    }
    return appliedItem;
}

@end
