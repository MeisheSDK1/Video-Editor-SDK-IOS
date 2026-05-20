//
//  NvCaptureModularVM.m
//  SDKDemo
//
//  Created by Meishe on 2022/8/10.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvCaptureModularVM.h"
#import "NvsStreamingContext.h"
#import "NvInitArScence.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import <NvSDKCommon/NvAssetManager.h>
#import "NvCaptureDataUtils.h"
#import "NvMakeupModel.h"
#import "NvAssetCellModel.h"
#import "NvCapturePropsModel.h"
#import "NvCaptionStyleItem.h"
#import "NvCaptureFilterModel.h"
#import "NvBeautyShapeModuler.h"
#import "NvBeautyView.h"
#import "NvCaptureStickerStyleView.h"
#import "NvAjustFxParamModel.h"
#import "NvMakeupToolModel.h"
#import "NvBeautyTemplateTool.h"
#import "NvBeautyTemplateDataManger.h"
#import "NvMakeupToolManager.h"
#import "NvFilterUsageUtil.h"

@interface NvCaptureModularVM ()
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
//贴纸数组
// Sticker array
@property (nonatomic, strong) NSMutableArray *allStickerArray;
//自定义贴纸数组
// Customize sticker array
@property (nonatomic, strong) NSMutableArray *customStickerArray;
@property (nonatomic, strong) NSMutableArray *allCompoundCaptionArray;

@property (nonatomic, strong) NvBeautyTemplateTool *beautyTemplateTool;
@property (nonatomic, strong) NvBeautyTemplateDataManger *beautyTemplateDataManger;


@property (nonatomic, assign) BOOL isDiscardCurrentEffect;

@property (nonatomic, assign) BOOL openFxface;

@end

@implementation NvCaptureModularVM

- (instancetype)init {
    if (self = [super init]) {
        self.allStickerArray = [NSMutableArray array];
        self.customStickerArray = [NSMutableArray array];
        self.allCompoundCaptionArray = [NSMutableArray array];
        self.fontDataSource = [NSMutableArray array];
        
        self.beautyFxArray = [NSMutableArray array];
        self.shapeFxArray = [NSMutableArray array];
        self.microShapingFxArray = [NSMutableArray array];
        self.adjustArray = [NSMutableArray array];
        self.contouringArray = [NSMutableArray array];
        
        self.originalBeautyFxArray = [NSMutableArray array];
        self.originalShapeFxArray = [NSMutableArray array];
        self.originalMicroShapingFxArray = [NSMutableArray array];
        self.originalAdjustArray = [NSMutableArray array];
        self.originalContouringArray = [NSMutableArray array];
        
        self.beautyTemplateTool = [[NvBeautyTemplateTool alloc]init];
        self.beautyTemplateDataManger = [[NvBeautyTemplateDataManger alloc]init];
        
        self.assetManager = [NvAssetManager sharedInstance];
        [self.assetManager.hashTable addObject:self];
    }
    return self;
}

#pragma mark - 初始化人脸授权
/*
 初始化人脸授权
 Initialize face authorization
 */
- (void)initARFace {
    
    if (![NvInitArScence getInitArFace]) {
        if (ARSCENE_MS){
            [NvInitArScence initARFace:NvFaceMode_106];
        }else if (ARSCENE_MS_240){
            [NvInitArScence initARFace:NvFaceMode_240];
        }
    }
    
    if ([NvInitArScence getInitArFace]) {
        self.isContentAI = YES;
        self.fxARFace = [self.streamingContext appendBuiltinCaptureVideoFx:@"AR Scene"];
        BOOL highVersion = [NvInitArScence isHighVersionPhone];
        if(highVersion) {
            [self.fxARFace setBooleanVal:@"AI Face Occlusion Enabled" val:YES];
        }
        [self.fxARFace setBooleanVal:@"Max Faces Respect Min" val:YES];
        NvsARSceneManipulate * manipulate = [self.fxARFace getARSceneManipulate];
//        if (ARSCENE_ST_240 || ARSCENE_MS_240) {
//            // !!!: 设置后就会走检测， 不需要设置 3.12.0+
//            [self.fxARFace setBooleanVal:@"Use Face Extra Info" val:YES];
//        }
        
//        [manipulate setDetectionInterval:100];
//        [manipulate setDetectionForceInterval:100];
        
        self.beautyTemplateTool.fxARFace = self.fxARFace;
    }
}

#pragma mark - 加载滤镜和道具包
/*
 加载滤镜和道具包
 Loading filters and props
 */
- (void)installFilterAndPropsAsset {
    __weak typeof(self)weakSelf = self;
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"filter" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_FILTER bundlePath:itemPath];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"face1sticker" ofType:@"bundle"];
        [weakSelf.assetManager searchReservedAssets:ASSET_ARSCENE bundlePath:itemPath];
        
        [weakSelf.assetManager searchLocalAssets:ASSET_FILTER];
        [weakSelf.assetManager searchLocalAssets:ASSET_ARSCENE];
        [weakSelf.assetManager searchLocalAssets:ASSET_COMPOUND_CAPTION];
        [weakSelf.assetManager searchLocalAssets:ASSET_ANIMATED_STICKER];
    });
}

- (BOOL)isCustomStickerExist:(NSString *)uuid {
    for (NvAssetCellModel *item in self.customStickerArray) {
        if ([item.package isEqualToString:uuid])
            return YES;
    }
    return NO;
}

- (void)getFontDatas {
    
    [self.assetManager searchLocalAssets:ASSET_FONT];
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"fontPackage" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_FONT bundlePath:fontPath];
    
    NSArray *fontArr = [self.assetManager getUsableAssets:ASSET_FONT aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    [self.fontDataSource removeAllObjects];
    for (int j = 0;j < fontArr.count;j++) {
        NvAsset *asset = fontArr[j];
        NSString *fontFamily = [self.streamingContext registerFontByFilePath:asset.bundledLocalDirPath ? asset.bundledLocalDirPath : asset.localDirPath];
        
        if (fontFamily) {
            [self.fontDataSource addObject:fontFamily];
        }
    }
}

- (BOOL)isCompoundCaptionExist:(NSString *)uuid {
    for (NvCaptionStyleItem *item in _allCompoundCaptionArray) {
        if ([item.packageId isEqualToString:uuid])
            return YES;
    }
    return NO;
}

- (void)initReservedStickerAsset:(NvAsset *)asset {
    if ([asset isReserved]) {
        if ([asset.uuid isEqualToString:@"0B2CA496-5DEB-4CAC-B01F-942B2C0B7580"]) {
            asset.category = ANIMATED_STICKER_SILENT;
        }
        if ([asset.uuid isEqualToString:@"39A21E74-00C6-48F9-96B0-485114B6F8F5"]) {
            asset.category = ANIMATED_STICKER_SILENT;
        }
        if ([asset.uuid isEqualToString:@"56A1D1CB-1CCA-40ED-B978-0ABA66021231"]) {
            asset.category = ANIMATED_STICKER_SOUND;
        }
    }
}

#pragma mark - ****** 配置BeautyView 数据（美颜、美型、微整形）******
//Configure BeautyView data (BeautyView, BeautyView, Microshaping)
#pragma mark  配置美肤数据
//Configure beauty data
- (void)configBeautifulSkinParameter{
    NvsARSceneManipulate * manipulate = [self.fxARFace getARSceneManipulate];
    BOOL matte = [manipulate isFunctionAvailable:NvsToBeCheckedFunctionType_Matte];
    
    NSString *basePath = [[NSBundle mainBundle] pathForResource:@"BeautyInfoData" ofType:@"bundle"];
    NSString *jsonPath = [basePath stringByAppendingPathComponent:@"beauty.json"];
    if([NvBaseUtils enableAIBeauty]) {
        jsonPath = [basePath stringByAppendingPathComponent:@"beauty_gan.json"];
    }
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSArray *array = [NSArray yy_modelArrayWithClass:NvBeautyTypeModel.class json:data];
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
    
    array = [NSArray new];
    for (NvBeautyTypeModel *model in mutableArray) {
        model.name = NvLocalString(model.nameEn, model.name);
        model.isOperation = YES;
        model.type = NvBeautyCategory;
        if (!matte && [model.fxName isEqualToString:@"Shiny"]) {
            array = @[model];
        }
    }
    
    [mutableArray removeObjectsInArray:array];
    
    self.beautyFxArray = [[NSMutableArray alloc]initWithArray:mutableArray copyItems:YES];
    self.originalBeautyFxArray = [[NSMutableArray alloc]initWithArray:mutableArray copyItems:YES];
    
    if (self.uiDelegate.beautyView) {
        [self.uiDelegate.beautyView configBeautyArray:mutableArray];
    }
    
    basePath = [[NSBundle mainBundle] pathForResource:@"BeautyEffectData" ofType:@"bundle"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *contents = [fm contentsOfDirectoryAtPath:basePath error:nil];
    for (NSString *path in contents) {
        
        if ([path.pathExtension isEqualToString:@"videofx"]) {
            
            NSString * fullPath = [basePath stringByAppendingPathComponent:path];
            NSString * licensePath = [NSString convertFilePathToNewPath:fullPath WithExtension:@"lic"];
            [NvSDKUtils installAssetPackage:fullPath license:licensePath assetType:NvsAssetPackageType_VideoFx];
        }
    }
}

#pragma mark  根据不同策略重新设置美型默认值
/*
 重新设置美型默认值
 Reset the default value of beautyShape model
 */
- (void)setBeautyTypeDefaultValues {
    NSArray *beautyByteArray_1 = @[NvLocalString(@"NarrowFace", @"窄脸"),
                                   NvLocalString(@"SmallFace", @"小脸"),
                                   NvLocalString(@"Slim Cheeks", @"瘦脸"),
                                   NvLocalString(@"Forhead", @"额头"),
                                   NvLocalString(@"Jaw", @"下巴"),
                                   NvLocalString(@"Eye-Capture", @"大眼"),
                                   NvLocalString(@"Canthus", @"眼角"),
                                   NvLocalString(@"Slim Nose", @"瘦鼻"),
                                   NvLocalString(@"High Nose", @"长鼻"),
                                   NvLocalString(@"Mouth-Capture", @"嘴型"),
                                   NvLocalString(@"Corners of The Mouth", @"嘴角")];
    
    NSArray *beautyByteArray_2 = @[@"NvCaptureBeautyTypeNarrowFace",
                                   @"NvCaptureBeautyTypeSmallFace",
                                   @"NvCaptureBeautyTypeFace",
                                   @"NvCaptureBeautyTypeForehead",
                                   @"NvCaptureBeautyTypeChin",
                                   @"NvCaptureBeautyTypeEye",
                                   @"NvCaptureBeautyTypeCanthus",
                                   @"NvCaptureBeautyTypeNose",
                                   @"NvCaptureBeautyTypeProboscis",
                                   @"NvCaptureBeautyTypeMouth",
                                   @"NvCaptureBeautyTypeMouthCorner"];
    
    NSArray *beautyTypePackageArray = @[@"96550C89-A5B8-42F0-9865-E07263D0B20C.3.facemesh",@"B85D1520-C60F-4B24-A7B7-6FEB0E737F15.3.facemesh",@"63BD3F32-D01B-4755-92D5-0DE361E4045A.3.facemesh",@"A351D77A-740D-4A39-B0EA-393643159D99.4.facemesh",@"FF2D36C5-6C91-4750-9648-BD119967FE66.3.facemesh",@"71C4CF51-09D7-4CB0-9C24-5DE9375220AE.3.facemesh",@"B0B7A240-48B9-4983-B2C8-690FFA7211EB.2.facemesh",@"8D676A5F-73BD-472B-9312-B6E1EF313A4C.3.facemesh",@"3632E2FF-8760-4D90-A2B6-FFF09C117F5D.3.facemesh",@"A80CC861-A773-4B8F-9CFA-EE63DB23EEC2.3.facemesh",@"CD69D158-9023-4042-AEAD-F8E9602FADE9.3.facemesh"];
    NSArray *beautyByteArray_3;
    if (self.isContentAI) {
        beautyByteArray_3 = @[@"Face Mesh Face Width Custom Package Id",
                              @"Face Mesh Face Length Custom Package Id",
                              @"Face Mesh Face Size Custom Package Id",
                              @"Face Mesh Forehead Height Custom Package Id",
                              @"Face Mesh Chin Length Custom Package Id",
                              @"Face Mesh Eye Size Custom Package Id",
                              @"Face Mesh Eye Corner Stretch Custom Package Id",
                              @"Face Mesh Nose Width Custom Package Id",
                              @"Face Mesh Nose Length Custom Package Id",
                              @"Face Mesh Mouth Size Custom Package Id",
                              @"Face Mesh Mouth Corner Lift Custom Package Id"];
    }else{
        beautyByteArray_1 = @[NvLocalString(@"Slim Cheeks", @"瘦脸"),
                              NvLocalString(@"Eye-Capture", @"大眼"),
                              NvLocalString(@"Jaw", @"下巴"),
                              NvLocalString(@"Forhead", @"额头"),
                              NvLocalString(@"Slim Nose", @"瘦鼻"),
                              NvLocalString(@"Mouth-Capture", @"嘴型")];
        beautyByteArray_2 = @[@"NvCaptureBeautyTypeFace",
                              @"NvCaptureBeautyTypeEye",
                              @"NvCaptureBeautyTypeChin",
                              @"NvCaptureBeautyTypeForehead",
                              @"NvCaptureBeautyTypeNose",
                              @"NvCaptureBeautyTypeMouth"];
        beautyByteArray_3 = @[@"Cheek Thinning",
                              @"Eye Enlarging",
                              @"Intensity Chin",
                              @"Intensity Forhead",
                              @"Intensity Nose",
                              @"Intensity Mouth"];
    }
    
    NSArray *beautyByteSelectedImgArr = @[@"NvCaptureBeautyTypeNarrowFace_s",
                                          @"NvCaptureBeautyTypeSmallFace_s",
                                          @"NvCaptureBeautyTypeFace_s",
                                          @"NvCaptureBeautyTypeForehead_s",
                                          @"NvCaptureBeautyTypeChin_s",
                                          @"NvCaptureBeautyTypeEye_s",
                                          @"NvCaptureBeautyTypeCanthus_s",
                                          @"NvCaptureBeautyTypeNose_s",
                                          @"NvCaptureBeautyTypeProboscis_s",
                                          @"NvCaptureBeautyTypeMouth_s",
                                          @"NvCaptureBeautyTypeMouthCorner_s"];
    NSString *beautyTypePath = [[NSBundle mainBundle] pathForResource:@"beautyShapeData" ofType:@"bundle"];
    
    NSString *testBeauty = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/TestBeauty"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:testBeauty]) {
        [fm createDirectoryAtPath:testBeauty withIntermediateDirectories:true attributes:nil error:nil];
    }
    NSArray *contents = [fm contentsOfDirectoryAtPath:testBeauty error:nil];
    
    for (int i = 0; i < beautyByteArray_1.count; i++) {
        NvBeautyTypeModel *beautyByteModel = [NvBeautyTypeModel new];
        beautyByteModel.name = beautyByteArray_1[i];
        beautyByteModel.coverImage = beautyByteArray_2[i];
        beautyByteModel.selectedCoverImg = beautyByteSelectedImgArr[i];
        beautyByteModel.selected = NO;
        beautyByteModel.isOperation = YES;
        beautyByteModel.isBeauty = NO;
        beautyByteModel.type = NvBeautyTypeCategory;
        beautyByteModel.fxName = beautyByteArray_3[i];
        beautyByteModel.value = 0;
        if (self.isContentAI) {
            NSString *packageName = beautyTypePackageArray[i];
            __block NSString *packageUrl = beautyTypePath;
            __block BOOL isContain = false;
            [contents enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([packageName isEqualToString:obj]) {
                    packageUrl = [testBeauty stringByAppendingPathComponent:packageName];
                    isContain = true;
                    *stop = true;
                }
            }];
            if (!isContain) {
                packageUrl = [beautyTypePath stringByAppendingPathComponent:packageName];
            }
            beautyByteModel.packageUrl = packageUrl;
            
            beautyByteModel.uuid = [self installBeautyTypeAsset:beautyByteModel.packageUrl needReInstall:isContain];
        }
        beautyByteModel.defaultValue = beautyByteModel.value;
        
        [self.shapeFxArray addObject:beautyByteModel];
        
    }
    
    /*
     美型包测试
     Beauty package test
     */
    for (NSMutableDictionary *dict in [NvCaptureDataUtils getShapeTestData]) {
        NvBeautyTypeModel *model = [NvBeautyTypeModel yy_modelWithDictionary:dict];
        if (model) {
            [self installBeautyTypeAsset:model.packageUrl needReInstall:YES];
            [self.shapeFxArray insertObject:model atIndex:0];
        }
    }
    
    self.originalShapeFxArray = [[NSMutableArray alloc]initWithArray:self.shapeFxArray copyItems:YES];
    
    if (self.uiDelegate.beautyView) {
        [self.uiDelegate.beautyView configBeautyByteArray:self.shapeFxArray];
    }
}

- (NSMutableString *)installBeautyTypeAsset:(NSString *)path needReInstall:(BOOL)need {
    NSMutableString *uuid;
    NSString * licensePath = [NSString convertFilePathToNewPath:path WithExtension:@"lic"];
    if ([path.pathExtension containsString:@"warp"]) {
        if (need) {
            uuid = [NvSDKUtils reInstallAssetPackage:path license:licensePath assetType:NvsAssetPackageType_Warp];
        } else {
            uuid = [NvSDKUtils installAssetPackage:path license:licensePath assetType:NvsAssetPackageType_Warp];
        }
    }else if ([path.pathExtension containsString:@"facemesh"]) {
        if (need) {
            uuid = [NvSDKUtils reInstallAssetPackage:path license:licensePath assetType:NvsAssetPackageType_FaceMesh];
        } else {
            uuid = [NvSDKUtils installAssetPackage:path license:licensePath assetType:NvsAssetPackageType_FaceMesh];
        }
    }
    return uuid;
}

#pragma mark 配置微整形数据
- (void)configMicroShapingTypeParameter{
    /**
     "Eye Distance" = "眼距";
     "Eye Angle" = "眼角度";
     "Philtrum" = "人中";
     "Wide Nose Bridge" = "宽鼻梁";
     "Eye Arc" = "眼弧度";
     "Eye Width" = "眼宽度";
     "Eye Height" = "眼高度";
     "Eye Y Offset" = "眼上下";
     "Eyebrow Angle" = "眉角度";
     "Eyebrow Thickness" = "眉粗细";
     "Eyebrow X Offset" = "眉间距";
     "Eyebrow Y Offset" = "眉上下";
     "Nose Head Width" = "鼻头";
     */
    NSArray *microShapingArray_1 = @[NvLocalString(@"Small Head", @"缩头"),
                                     NvLocalString(@"Cheekbones", @"颧骨"),
                                     NvLocalString(@"Mandibular-Capture", @"下颌"),
                                     NvLocalString(@"temple", @"太阳穴"),
                                     NvLocalString(@"Nasolabial fold", @"法令纹"),
                                     NvLocalString(@"Dark under-eye circles", @"黑眼圈"),
                                     NvLocalString(@"Bright eye", @"亮眼"),
                                     NvLocalString(@"Beautiful teeth", @"美牙"),
                                     NvLocalString(@"Eye Distance", @"眼距"),
                                     NvLocalString(@"Eye Angle", @"眼角度"),
                                     NvLocalString(@"Eye Arc", @"眼弧度"),
                                     NvLocalString(@"Eye Width", @"眼宽度"),
                                     NvLocalString(@"Eye Height", @"眼高度"),
                                     NvLocalString(@"Eye Y Offset", @"眼上下"),
                                     NvLocalString(@"Philtrum", @"人中"),
                                     NvLocalString(@"Wide Nose Bridge", @"宽鼻梁"),
                                     NvLocalString(@"Nose Head Width", @"鼻头"),
                                     NvLocalString(@"Eyebrow Angle", @"眉角度"),
                                     NvLocalString(@"Eyebrow Thickness", @"眉粗细"),
                                     NvLocalString(@"Eyebrow X Offset", @"眉间距"),
                                     NvLocalString(@"Eyebrow Y Offset", @"眉上下")];
    NSArray *microShapingArray_2 = @[@"NvCaptureBeautyTypeShrinkHead",
                                     @"NvCaptureBeautyTypeZygomatic",
                                     @"NvCaptureBeautyTypeMandibular",
                                     @"NvCaptureBeautyTypeTemple",
                                     @"legal_pattern_unselected",
                                     @"dark_under-eye_circles_unselected" ,
                                     @"bright_eye_unselected" ,
                                     @"beautiful_teeth_unselected",
                                     @"EyeDistanceWarpUnselected",
                                     @"EyeAngleWarpUnselected",
                                     @"eye_arc_unselected",
                                     @"eye_width_unselected",
                                     @"eye_height_unselected",
                                     @"eye_Y_offset_unselected",
                                     @"PhiltrumLengthWarpUnselected",
                                     @"NoseBridgeWidthWarpUnselected",
                                     @"nose_head_width_unselected",
                                     @"eyebrow_angle_unselected",
                                     @"eyebrow_thickness_unselected",
                                     @"eyebrow_X_offset_unselected",
                                     @"eyebrow_Y_offset_unselected"];
    NSArray *microShapingArray_3 = @[@"Warp Head Size Custom Package Id",
                                     @"Face Mesh Malar Width Custom Package Id",
                                     @"Face Mesh Jaw Width Custom Package Id",
                                     @"Face Mesh Temple Width Custom Package Id",
                                     @"Advanced Beauty Remove Nasolabial Folds Intensity",
                                     @"Advanced Beauty Remove Dark Circles Intensity",
                                     @"Advanced Beauty Brighten Eyes Intensity",
                                     @"Advanced Beauty Whiten Teeth Intensity",
                                     @"Face Mesh Eye Distance Custom Package Id",
                                     @"Face Mesh Eye Angle Custom Package Id",
                                     @"Face Mesh Eye Arc Custom Package Id",
                                     @"Face Mesh Eye Width Custom Package Id",
                                     @"Face Mesh Eye Height Custom Package Id",
                                     @"Face Mesh Eye Y Offset Custom Package Id",
                                     @"Face Mesh Philtrum Length Custom Package Id",
                                     @"Face Mesh Nose Bridge Width Custom Package Id",
                                     @"Face Mesh Nose Head Width Custom Package Id",
                                     @"Face Mesh Eyebrow Angle Custom Package Id",
                                     @"Face Mesh Eyebrow Thickness Custom Package Id",
                                     @"Face Mesh Eyebrow X Offset Custom Package Id",
                                     @"Face Mesh Eyebrow Y Offset Custom Package Id"];
    
    NSArray *microShapingSelectedImgArr = @[@"NvCaptureBeautyTypeShrinkHead_s",
                                            @"NvCaptureBeautyTypeZygomatic_s",
                                            @"NvCaptureBeautyTypeMandibular_s",
                                            @"NvCaptureBeautyTypeTemple_s",
                                            @"legal_pattern_selected",
                                            @"dark_under-eye_circles_selected" ,
                                            @"bright_eye_selected" ,
                                            @"beautiful_teeth_selected",
                                            @"EyeDistanceWarpSelected",
                                            @"EyeAngleWarpSelected",
                                            @"eye_arc_selected",
                                            @"eye_width_selected",
                                            @"eye_height_selected",
                                            @"eye_Y_offset_selected",
                                            @"PhiltrumLengthWarpSelected",
                                            @"NoseBridgeWidthWarpSelected",
                                            @"nose_head_width_selected",
                                            @"eyebrow_angle_selected",
                                            @"eyebrow_thickness_selected",
                                            @"eyebrow_X_offset_selected",
                                            @"eyebrow_Y_offset_selected"];
    NSArray *microShapingPackageArray = @
    [@"316E3641-98BA-4E07-958E-9ED7D7F75E97.2.warp",
     @"C1C83B8B-8086-49AC-8462-209E429C9B7A.3.facemesh",
     @"E903C455-8E23-4539-9195-816009AFE06A.3.facemesh",
     @"E4790833-BB9D-4EFC-86DF-D943BDC48FA4.3.facemesh",
     @"",
     @"",
     @"",
     @"",
     @"80329F14-8BDB-48D1-B30B-89A33438C481.4.facemesh",
     @"54B2B9B4-5A7A-484C-B602-39A4730115A0.4.facemesh",
     @"BF71EA3E-E39E-4EFD-A30E-161C3D9E454D.4.facemesh",
     @"0605A846-200E-443F-B2FF-FE8339C9E571.facemesh",
     @"46B1D78F-DF5D-455A-9F97-C01B6405718F.4.facemesh",
     @"57C0BDDF-E08B-48F0-95FF-7F5171A9E6DF.4.facemesh",
     @"37552044-E743-4A60-AC6E-7AADBA1E5B3B.3.facemesh",
     @"23A40970-CE6F-4684-AF57-F78A0CBB53D1.3.facemesh",
     @"44E11F37-A4E5-44B5-8915-CA42B84F9F09.2.facemesh",
     @"CC86C182-62D7-4F1D-AE9D-F5E4E99977A5.2.facemesh",
     @"C2045DCA-D8C5-4C50-B942-69F749E32E93.2.facemesh",
     @"F77B5F0E-AF43-45DB-96BB-62419B9CECA8.2.facemesh",
     @"90C09073-225B-461D-8645-73CE7825BB33.2.facemesh"];
    NSString *beautyTypePath = [[NSBundle mainBundle] pathForResource:@"beautyShapeData" ofType:@"bundle"];
    
    for (int i = 0; i < microShapingArray_1.count; i++) {
        NvBeautyTypeModel *beautyByteModel = [NvBeautyTypeModel new];
        beautyByteModel.name = microShapingArray_1[i];
        beautyByteModel.coverImage = microShapingArray_2[i];
        beautyByteModel.selectedCoverImg = microShapingSelectedImgArr[i];
        beautyByteModel.selected = NO;
        beautyByteModel.isOperation = YES;
        beautyByteModel.isBeauty = NO;
        beautyByteModel.type = NvMicroShapingCategory;
        beautyByteModel.fxName = microShapingArray_3[i];
        beautyByteModel.value = 0;
        beautyByteModel.defaultValue = beautyByteModel.value;
        //----------------------
        NSString *packageName = microShapingPackageArray[i];
        __block NSString *packageUrl = beautyTypePath;
        __block BOOL isContain = false;
        if (!isContain && packageName.length > 0) {
            packageUrl = [beautyTypePath stringByAppendingPathComponent:packageName];
        }
        beautyByteModel.packageUrl = packageUrl;
        //-------------
        beautyByteModel.uuid = [self installBeautyTypeAsset:beautyByteModel.packageUrl needReInstall:isContain];
        [self.microShapingFxArray addObject:beautyByteModel];
    }
    
    /*
     微整形包测试
     MicroShape package test
     */
    for (NSMutableDictionary *dict in [NvCaptureDataUtils getMicroShapeTestData]) {
        NvBeautyTypeModel *model = [NvBeautyTypeModel yy_modelWithDictionary:dict];
        if (model) {
            [self installBeautyTypeAsset:model.packageUrl needReInstall:YES];
            [self.microShapingFxArray insertObject:model atIndex:0];
        }
    }
    
    self.originalMicroShapingFxArray = [[NSMutableArray alloc]initWithArray:self.microShapingFxArray copyItems:YES];
    
    if (self.uiDelegate.beautyView) {
        [self.uiDelegate.beautyView configMicroShapingArray: [[NSMutableArray alloc] initWithArray:self.microShapingFxArray copyItems:YES]];
    }
}

#pragma mark - 配置调节数据
/// Configuration adjustment data
- (void)configAdjustArray{
    NSArray *array = @[NvLocalString(@"Color correction", @"校色"),
                       NvLocalString(@"Amount", @"锐度"),
                       NvLocalString(@"clarity", @"清晰度")];
    NSArray *array1 = @[@"NvCaptureBeautyFilter1",
                        @"NvCaptureBeautySharpen1",
                        @"NvCaptureBeautyClarity"];
    NSArray *array2 = @[@"NvCaptureBeautyFilter1_s",
                        @"NvCaptureBeautySharpen1_s",
                        @"NvCaptureBeautyClarity_s"];
    NSArray *array3 = @[@"ColorCorrect",
                        @"Sharpen",
                        @"Definition"];
    NSArray *array4 = @[@"",
                        @"Amount",
                        @"Intensity"];
    NSArray *array5 = @[@"65521195-92A4-41CA-9DB5-6AB19C9321B5",
                        @"",
                        @""];
    
    for (int i = 0; i < array.count; i++) {
        NvBeautyTypeModel *beautyByteModel = [NvBeautyTypeModel new];
        beautyByteModel.name = array[i];
        beautyByteModel.coverImage = array1[i];
        beautyByteModel.selectedCoverImg = array2[i];
        beautyByteModel.selected = NO;
        beautyByteModel.fxName = array3[i];
        beautyByteModel.degreeName = array4[i];
        beautyByteModel.defaultValue = 0;
        beautyByteModel.value = beautyByteModel.defaultValue;
        beautyByteModel.isOperation = YES;
        beautyByteModel.type = NvBeautyAdjustCategory;
        beautyByteModel.uuid = array5[i];
        
        [self.adjustArray addObject:beautyByteModel];
    }
    
    self.originalAdjustArray = [[NSMutableArray alloc]initWithArray:self.adjustArray copyItems:YES];
    
    if (self.uiDelegate.beautyView) {
        [self.uiDelegate.beautyView configAdjustArray:self.adjustArray];
    }
    
    [self installColorCorrectFilter];
}

#pragma mark - 配置修容数据
/// Configure capacity modification data
- (void)configContouringArray{
    /*
     修容目前没有内置数据，数据从美颜模版里实时获取
     There is no built-in data for contouring at present. The data is obtained from the beauty template in real time
     */
}

#pragma mark - 配置美颜模版数据
/// CConfigure Beauty template data
- (void)configBeautyTemplateArray{
    /*
     1、读取沙盒内置模版并组装数据
     2、读取工程内置模版并组装数据
     3、读取网络模版并组装数据
     
     1. Read the built-in template of the sandbox and assemble data
     2. Read the built-in template of the project and assemble the data
     3. Read the network template and assemble the data
     */
    
    //1、
    [self.beautyTemplateDataManger configureSandboxData];
    
    //2、
    [self.beautyTemplateDataManger configureProducData];
    
    __weak typeof(self) weakSelf = self;
    
    if (self.uiDelegate.beautyView) {
        __block BOOL first = YES;
        //3、
        [self.beautyTemplateDataManger refreshRequestData:self.uiDelegate.beautyView.getBeautyTemplateCollectionView withSuccess:^(id  _Nonnull respondData) {
            
            if (first){
                if (weakSelf.openFxface){
                    for (NvBeautyTemplateModel *model in weakSelf.beautyTemplateDataManger.dataArray) {
                        
                        if(model.selected) weakSelf.currentTemplatemodel = model;
                    }
                    [weakSelf applyBeautyTemplateData];
                }else{
                    weakSelf.currentTemplatemodel.selected = NO;
                    weakSelf.currentTemplatemodel = nil;
                }
            }
            
            NSArray *tempArray = (NSArray *)respondData;
            if (tempArray.count > 0){
                if (weakSelf.uiDelegate.beautyView) {
                    [weakSelf.uiDelegate.beautyView configBeautyTemplateArray:weakSelf.beautyTemplateDataManger.dataArray];
                }
            }
            
            first = NO;
        } withFailure:^(NSError * _Nonnull error) {
            if (first){
                if (weakSelf.openFxface){
                    for (NvBeautyTemplateModel *model in weakSelf.beautyTemplateDataManger.dataArray) {
                        if(model.selected){
                            weakSelf.currentTemplatemodel = model;
                        }
                    }
                    [weakSelf applyBeautyTemplateData];
                }else{
                    weakSelf.currentTemplatemodel.selected = NO;
                    weakSelf.currentTemplatemodel = nil;
                }
            }
            
            if (weakSelf.uiDelegate.beautyView) {
                [weakSelf.uiDelegate.beautyView configBeautyTemplateArray:weakSelf.beautyTemplateDataManger.dataArray];
            }
            
            first = NO;
        }];
        
        [self.beautyTemplateDataManger startRequestData];
    }
}

#pragma mark - 是否开启人脸特效应用
/// Whether to open the face effects application
- (void)applyBeautyEffectsStyleWith:(BOOL)open{
    self.openFxface = open;
    if (open) {
        if (self.isContentAI) {
            [self.fxARFace setBooleanVal:@"Beauty Effect" val:YES];
            [self.fxARFace setBooleanVal:@"Advanced Beauty Enable" val:YES];
            [self.fxARFace setBooleanVal:@"Beauty Shape" val:YES];
            [self.fxARFace setBooleanVal:@"Face Mesh Internal Enabled" val:YES];
        }else{
            if (!self.fxARFace) {
                self.fxARFace = [self.streamingContext appendBeautyCaptureVideoFx];
            }
        }
    }else{
        [self.fxARFace setBooleanVal:@"Beauty Effect" val:NO];
        [self.fxARFace setBooleanVal:@"Advanced Beauty Enable" val:NO];
        [self.fxARFace setBooleanVal:@"Beauty Shape" val:NO];
        [self.fxARFace setBooleanVal:@"Face Mesh Internal Enabled" val:NO];
    }
    
    self.beautyTemplateTool.fxARFace = self.fxARFace;
}

#pragma mark - 应用美颜模版数据
/// Apply the beauty template data
- (void)applyBeautyTemplateData{
    if ([self.currentTemplatemodel.packageUrl hasPrefix:@"http"] || [self.currentTemplatemodel.packageUrl hasPrefix:@"https"]){
        
        __weak typeof(self) weakSelf = self;
        [self.beautyTemplateDataManger downloadData:self.currentTemplatemodel WithProgress:^(CGFloat progress) {
            
        } WithSuccess:^(id  _Nonnull respondData) {
            if ([respondData isKindOfClass:NvBeautyTemplateModel.class]){
                NvBeautyTemplateModel *model = (NvBeautyTemplateModel *)respondData;
                model.beautyTemplate = [weakSelf.beautyTemplateDataManger analyticalTemplatePath:model.packageUrl];
                [weakSelf applyBeautyTemplate];
                
                [weakSelf.uiDelegate.beautyView.getBeautyTemplateCollectionView reloadData];
            }
        } withFailure:^(NSError * _Nonnull error) {
            [weakSelf.uiDelegate.beautyView.getBeautyTemplateCollectionView reloadData];
        }];
    }else{
        if (!self.currentTemplatemodel.beautyTemplate && self.currentTemplatemodel.packageUrl.length > 0){
            self.currentTemplatemodel.beautyTemplate = [self.beautyTemplateDataManger analyticalTemplatePath:self.currentTemplatemodel.packageUrl];
        }
        [self applyBeautyTemplate];
    }
}

#pragma mark - 应用美颜模版
/// Apply the beauty template
- (void)applyBeautyTemplate{
    /*
     1、先把数据还原成原始内置数据，然后应用一遍效果
     2、有选中的美颜模版，就应用美颜模版数据，并且把美颜模版的数据结构映射到，界面所需要的数据
         当beautyTemplateData对象存在的时候，使用记录的临时数据恢复当前模版
         当beautyTemplateData对象不存在的时候，使用模版的原始数据恢复数据
     3、更新ui
     
     1, restore the data to the original built-in data, and then apply the effect again
     2. If the selected beauty template is selected, the data of beauty template is applied, and the data structure of beauty template is mapped to the data required by the interface
     When the beautyTemplateData object exists, use the recorded temporary data to restore the current template
     When the beautyTemplateData object does not exist, use the template's original data to restore data
     3. Update the ui
     */
    
    //1、
    self.beautyFxArray = [[NSMutableArray alloc]initWithArray:self.originalBeautyFxArray copyItems:YES];
    self.shapeFxArray = [[NSMutableArray alloc]initWithArray:self.originalShapeFxArray copyItems:YES];
    self.microShapingFxArray = [[NSMutableArray alloc]initWithArray:self.originalMicroShapingFxArray copyItems:YES];
    self.adjustArray = [[NSMutableArray alloc]initWithArray:self.originalAdjustArray copyItems:YES];
    self.contouringArray = [[NSMutableArray alloc]initWithArray:self.originalContouringArray copyItems:YES];
    
    self.beautyTemplateTool.whiteningEffectModel = nil;
    
    [self applyBeautyEffectInCondition:self.beautyFxArray];
    [self applyBeautyTypeEffectInCondition:self.shapeFxArray];
    [self applyMicroShapingEffectInCondition:self.microShapingFxArray];
    [self applyAdjust:self.adjustArray];
    
    //2、
    if (self.currentTemplatemodel){
        [self.beautyTemplateTool applyBeautyTemplateEffect:self.currentTemplatemodel.beautyTemplate];
        
        if (self.currentTemplatemodel.beautyTemplateData){
            for (NSDictionary *dict in self.currentTemplatemodel.beautyTemplateData) {
                NSNumber *number = dict.allKeys.firstObject;
                NSMutableArray *mutableArray = dict.allValues.firstObject;
                if ([number integerValue] == NvBeautyCategory){
                    self.beautyFxArray = mutableArray;
                }else if ([number integerValue] == NvBeautyTypeCategory){
                    self.shapeFxArray = mutableArray;
                }else if ([number integerValue] == NvMicroShapingCategory){
                    self.microShapingFxArray = mutableArray;
                }else if ([number integerValue] == NvBeautyAdjustCategory){
                    self.adjustArray = mutableArray;
                }else if ([number integerValue] == NvBeautyShadowCategory){
                    self.contouringArray = mutableArray;
                }
            }
            
            [self applyBeautyEffectInCondition:self.beautyFxArray];
            [self applyBeautyTypeEffectInCondition:self.shapeFxArray];
            [self applyMicroShapingEffectInCondition:self.microShapingFxArray];
            [self applyAdjust:self.adjustArray];
            [self applyContouring:self.contouringArray];
        }else{
            [self.beautyTemplateTool conversionBeautyTemplateWithBeauty:self.beautyFxArray withModel:self.currentTemplatemodel.beautyTemplate];
            [self.beautyTemplateTool conversionBeautyTemplateWithShaping:self.shapeFxArray withModel:self.currentTemplatemodel.beautyTemplate];
            [self.beautyTemplateTool conversionBeautyTemplateWithMicroShaping:self.microShapingFxArray withModel:self.currentTemplatemodel.beautyTemplate];
            [self.beautyTemplateTool conversionBeautyTemplateWithAdjust:self.adjustArray withModel:self.currentTemplatemodel.beautyTemplate];
            [self.beautyTemplateTool conversionBeautyTemplateWithContouring:self.contouringArray withModel:self.currentTemplatemodel.beautyTemplate];
            
            self.currentTemplatemodel.beautyTemplateData = [NSMutableArray array];
            
            if (self.beautyFxArray){
                [self.currentTemplatemodel.beautyTemplateData addObject:@{@(NvBeautyCategory):self.beautyFxArray}];
            }
            if (self.shapeFxArray){
                [self.currentTemplatemodel.beautyTemplateData addObject:@{@(NvBeautyTypeCategory):self.shapeFxArray}];
            }
            if (self.microShapingFxArray){
                [self.currentTemplatemodel.beautyTemplateData addObject:@{@(NvMicroShapingCategory):self.microShapingFxArray}];
            }
            if (self.adjustArray){
                [self.currentTemplatemodel.beautyTemplateData addObject:@{@(NvBeautyAdjustCategory):self.adjustArray}];
            }
            if (self.contouringArray){
                [self.currentTemplatemodel.beautyTemplateData addObject:@{@(NvBeautyShadowCategory):self.contouringArray}];
            }
        }
    } else {
        [self.beautyTemplateTool applyBeautyTemplateEffect:nil];
    }
    
    //3、
    if (self.uiDelegate.beautyView) {
        [self.uiDelegate.beautyView configBeautyArray:self.beautyFxArray];
        [self.uiDelegate.beautyView configBeautyByteArray:self.shapeFxArray];
        [self.uiDelegate.beautyView configMicroShapingArray:self.microShapingFxArray];
        [self.uiDelegate.beautyView configAdjustArray:self.adjustArray];
        [self.uiDelegate.beautyView configContouringArray:self.contouringArray];
    }
    
    if (self.makeupManager.getEffectModel){
        [self applyMakeupAndBeautyTemplate:YES];
    } else if (!self.currentTemplatemodel) {
        [self recoverExistsSingleMakeupElements];
    }
}

- (void)recoverExistsSingleMakeupElements {

    NSArray *singleMakeupElements = [self.makeupManager getCurrentExistSingleMakeupElements];
    for (int i=0; i<singleMakeupElements.count; i++) {
        NvMakeupContentModel *contentModel = (NvMakeupContentModel *)singleMakeupElements[i];
        for (NvMakeupEffectContentModel *model in contentModel.effectContent.makeup) {

            if (model.makeupId) {
                
                NSString *baseStr = [@"Makeup " stringByAppendingString:model.makeupId];
                NSString *packageId = [baseStr stringByAppendingString:@" Package Id"];
                if ([packageId caseInsensitiveCompare:model.className] == NSOrderedSame && ![model.className isEqualToString:@"Makeup Compound Package Id"]) {
                    [self.fxARFace setStringVal:model.className val:model.uuid];
                    NSString *colorStr = [baseStr stringByAppendingString:@" Color"];
                    NSString *intensityStr = [baseStr stringByAppendingString:@" Intensity"];
                    [self.fxARFace setFloatVal:intensityStr val:model.intensity];
                    
                    if(model.color.length > 0){
                        NvsColor color = [self nvsColorWithValue:model.color];
                        [self.fxARFace setColorVal:colorStr val:&color];
                    }else {
                        NvsColor color;
                        color.r = 0;
                        color.g = 0;
                        color.b = 0;
                        color.a = 0;
                        [self.fxARFace setColorVal:colorStr val:&color];
                    }
                }
            }
            else{
                [self.fxARFace setStringVal:model.className val:model.uuid];
            }
            [self.fxARFace setFloatVal:@"Makeup Intensity" val:1];
        }
    }
}

#pragma mark - 美颜模版、妆容同时应用，
/// Apply makeup  and  Beauty template
- (void)applyMakeupAndBeautyTemplate:(BOOL)isBeautyTemplate{
    if (self.currentTemplatemodel && self.makeupManager.getEffectModel) {
        /*
         当前应用了美颜模版和妆容，需要对比两个数据，找出不相同的项，组合成一个新的数据
         
         isBeautyTemplate = YES
         先选择妆容，再选择美颜模版，保留美颜模版中的所有项，美颜模版中没有的项，妆容补全
         
         isBeautyTemplate = NO
         先选择美颜模版，再选择妆容，保留妆容中的所有项，妆容中没有的项，美颜模版补全
         
         1、组合对比美妆、美型、微整形、滤镜、调节、美颜数据
         2、因为美颜模版和妆容中都有校色这一项，但是他们所在的数组发生了变化，所以最后要对比一下，把相同的删掉
         3、应用新的效果
         
         At present, the beauty template and makeup are applied. We need to compare the two data, find out the different items and combine them into a new data

         isBeautyTemplate = YES
         Select the makeup first, then select the beauty template, keep all the items in the beauty template, beauty template is not in the item, complete the makeup

         isBeautyTemplate = NO
         First select the beauty template, then select the makeup, keep all the items in the makeup, the makeup is not completed

         1. Combine and compare beauty makeup, beauty type, micro-shaping, filter, adjustment and beauty data
         2, because the beauty template and makeup have the color check item, but they are in the array changed, so the last to compare, delete the same
         3. Apply new effects
         */
        
        NvMakeupToolEffectContentModel *newModel = [[NvMakeupToolEffectContentModel alloc]init];
        newModel.makeup = [NSMutableArray array];
        newModel.shape = [NSMutableArray array];
        newModel.microShape = [NSMutableArray array];
        newModel.adjust = [NSMutableArray array];
        newModel.filter = [NSMutableArray array];
        newModel.beauty = [NSMutableArray array];
        
        //1、
        NvMakeupToolEffectContentModel *firstModel;
        NvMakeupToolEffectContentModel *secondModel;
        
        if (isBeautyTemplate){
            firstModel = self.currentTemplatemodel.beautyTemplate.effectContent;
            secondModel = self.makeupManager.getEffectModel.effectContent;
        }else{
            firstModel = self.makeupManager.getEffectModel.effectContent;
            secondModel = self.currentTemplatemodel.beautyTemplate.effectContent;
        }
        
        [self contrastFirst:firstModel.makeup withSecond:secondModel.makeup with:newModel.makeup];
        [self contrastFirst:firstModel.shape withSecond:secondModel.shape with:newModel.shape];
        [self contrastFirst:firstModel.microShape withSecond:secondModel.microShape with:newModel.microShape];
        [self contrastBeautyFirst:secondModel.beauty withSecond:secondModel.beauty with:newModel.beauty];
        
        if (isBeautyTemplate){
            [self contrastFirst:nil withSecond:secondModel.filter with:newModel.filter];
            [self contrastFirst:secondModel.adjust withSecond:nil with:newModel.adjust];
        }else{
            [self contrastFirst:firstModel.filter withSecond:secondModel.filter with:newModel.filter];
            [self contrastFirst:nil withSecond:secondModel.adjust with:newModel.adjust];
        }
        
        //2、
        if (isBeautyTemplate){
            [self specialTreatment:newModel.beauty withSecond:newModel.adjust];
        }else{
            [self specialTreatment:newModel.adjust withSecond:newModel.beauty];
        }
        
        //3、
        NvMakeupToolModel *newToolModel = [[NvMakeupToolModel alloc]init];
        if (isBeautyTemplate){
            newToolModel.packagePath = self.makeupManager.getEffectModel.packagePath;
        }else{
            newToolModel.packagePath = self.currentTemplatemodel.beautyTemplate.packagePath;
        }
        newToolModel.effectContent = newModel;
        [self.beautyTemplateTool incrementApplyBeautyTemplateEffect:newToolModel];
    }else if (self.makeupManager.getEffectModel){
        [self.makeupManager applyMakeupEffect:self.makeupManager.getEffectModel.packagePath arsceneFx:self.fxARFace];
    }else if (self.currentTemplatemodel){
        [self applyBeautyTemplate];
    }
}

#pragma mark - 对比查找两组数据中，不相同的子项，把不相同的子项合成一个新的数据
/// Compare and find the different subitems in the two groups of data and synthesize the different subitems into a new data
- (void)contrastFirst:(NSMutableArray *)first withSecond:(NSMutableArray *)second with:(NSMutableArray *)newArray{
    /*
     对比first数组和second数组，找到second数组中不包含，first数组的数据，重新添加到一个新数组中
     Compare the first array with the second array, find the data in the second array that does not contain the first array, and add it back to a new array
     
     美型、微整形、美妆、滤镜、调节数据都可以使用这个方法做对比,把最后不相同的数据添加到新的数组中
     Beauty, micro-shaping, makeup, filters, and adjustment data can all be compared using this method, and the final different data can be added to the new array
     */
    
    NSMutableArray *array = [NSMutableArray array];
    for (NvMakeupToolEffectModel *model in first) {
        if (model.type.length > 0) {
            [array addObject:model];
        }
    }
    
    for (NvMakeupToolEffectModel *model in second) {
        BOOL include = NO;
        for (NvMakeupToolEffectModel *tempModel in array) {
            if (model.type.length > 0){
                if ([tempModel.type isEqualToString:model.type]) {
                    include = YES;
                    break;
                }
            }else if (model.uuid.length > 0){
                if ([tempModel.uuid isEqualToString:model.uuid]) {
                    include = YES;
                    break;
                }
            }else{
                include = YES;
            }
        }
        
        if (!include){
            [newArray addObject:model];
        }
    }
}

#pragma mark - 对比查找两组数据中，不相同的子项，把不相同的子项合成一个新的数据
/// Compare and find the different subitems in the two groups of data and synthesize the different subitems into a new data
- (void)contrastBeautyFirst:(NSMutableArray *)first withSecond:(NSMutableArray *)second with:(NSMutableArray *)newArray{
    /*
     美颜用这个方法做对比,把最后不相同的数据添加到新的数组中
     Beauty uses this method to compare and add the last different data to the new array
     */
    NSMutableArray *array = [NSMutableArray array];
    for (NvMakeupToolEffectModel *model in first) {
        [array addObject:model];
    }
    
    for (NvMakeupToolEffectModel *model in second) {
        BOOL include = NO;
        for (NvMakeupToolEffectModel *tempModel in array) {
            if (model.type.length > 0){
                if ([tempModel.type isEqualToString:model.type]) {
                    include = YES;
                    break;
                }
            }else if (model.params.count > 0){
                for (NvMakeupToolElementModel *elementModel in model.params) {
                    include = NO;
                    for (NvMakeupToolElementModel *tempElementModel in tempModel.params) {
                        if ([elementModel.key isEqualToString:tempElementModel.key]){
                            include = YES;
                        }
                    }
                }
                
                if (include){
                    break;
                }
            }
        }
        
        if (!include){
            [newArray addObject:model];
        }
    }
}

#pragma mark - 对已经过滤之后的数据进行特殊处理
/// Special processing of the filtered data
- (void)specialTreatment:(NSMutableArray *)first withSecond:(NSMutableArray *)second{
    BOOL include = NO;
    for (NvMakeupToolEffectModel *model in first) {
        if ([model.type isEqualToString:@"ColorCorrect"]){
            include = YES;
            break;
        }
    }

    if (include) {
        include = NO;
        NvMakeupToolEffectModel *tempModel;
        for (NvMakeupToolEffectModel *model in second) {
            if ([model.type isEqualToString:@"ColorCorrect"]){
                tempModel = model;
                break;
            }
        }

        if (tempModel){
            [second removeObject:tempModel];
        }
    }
}

#pragma mark - 重置美颜模版数据
/// Reset the beauty template data
- (void)resetBeautyTemplateData{
    if (self.currentTemplatemodel) {
        self.currentTemplatemodel.beautyTemplateData = nil;
        [self applyBeautyTemplate];
    }
}

#pragma mark - 应用美颜数组中的效果
/// Apply the effect in beauty array
- (void)applyBeautyEffectInCondition:(NSMutableArray *)array{
    /*
     美白使用滤镜实现，所以这里要还原一下美白的默认效果
     Whitening is achieved using filters, so I want to restore the default whitening effect here
     */
    if (!self.isDiscardCurrentEffect){
        [self.fxARFace setBooleanVal:@"Whitening Lut Enabled" val:NO];
        [self.fxARFace setStringVal:@"Whitening Lut File" val:@""];
    }
    [self.fxARFace setFloatVal:@"Beauty Whitening" val:0];
    
    [self.beautyTemplateTool applyBeautyTemplateWhitening];
    
    for (NvBeautyTypeModel *model in array) {
        if (model.subprojectArray.count > 0) {
            for (NvBeautyTypeModel *sonModel in model.subprojectArray) {
                if (sonModel.selected) {
                    [self applyBeautyEffectModel:sonModel withChange:NO];
                    break;
                }
                
                if (![model.fxName isEqualToString:@"SkinColor"]) {
                    [self applyBeautyEffectModel:sonModel withChange:NO];
                }
            }
        }else{
            [self applyBeautyEffectModel:model withChange:NO];
        }
    }
}

#pragma mark - 应用美型数组中的效果
/// Application of the effect of beauty array
- (void)applyBeautyTypeEffectInCondition:(NSMutableArray *)typeArr {
    for (NvBeautyTypeModel *model in typeArr) {
        [self applyBeautyShapeModel:model withChange:NO];
    }
}

#pragma mark - 应用微整形数组中的效果 Apply the effects in the microshaping array
- (void)applyMicroShapingEffectInCondition:(NSMutableArray *)typeArr {
    for (NvBeautyTypeModel *model in typeArr) {
        [self applyBeautyMicroshapingModel:model withChange:NO];
    }
}

#pragma mark - 应用调节数组中的数据
/// Apply the adjust array to the data
- (void)applyAdjust:(NSMutableArray *)typeArr{
    for (NvBeautyTypeModel *model in typeArr) {
        [self applyAdjustModel:model withChange:NO];
    }
}

#pragma mark - 应用修容数组中的数据
/// Apply the contouring array to the data
- (void)applyContouring:(NSMutableArray *)typeArr{
    for (NvBeautyTypeModel *model in typeArr) {
        [self applyContouringModel:model withChange:NO];
    }
}

#pragma mark - 应用美颜、美型、微整形、调节、修容效果
/// Application of beauty, beauty, micro shaping, adjustment, contouring effect
- (void)applyBeautyModel:(NvBeautyTypeModel *)model withChange:(BOOL)change{
    if (model == nil){
        return;
    }
    
    if (model.type == NvBeautyCategory){
        [self applyBeautyEffectModel:model withChange:change];
    }else if (model.type == NvBeautyTypeCategory){
        [self applyBeautyShapeModel:model withChange:change];
    }else if (model.type == NvMicroShapingCategory){
        [self applyBeautyMicroshapingModel:model withChange:change];
    }else if (model.type == NvBeautyAdjustCategory){
        [self applyAdjustModel:model withChange:change];
    }else if (model.type == NvBeautyShadowCategory){
        [self applyContouringModel:model withChange:change];
    }
}

#pragma mark - 应用美颜效果
/// Application of beauty effect
- (void)applyBeautyEffectModel:(NvBeautyTypeModel *)model withChange:(BOOL)change{
    CGFloat value = self.isDiscardCurrentEffect?0:model.value;
    if ([model.fxName isEqualToString:@"Advanced Beauty Type Zero"]) {
        [self.fxARFace setBooleanVal:@"Advanced Beauty Enable" val:YES];
        [self.fxARFace setIntVal:@"Advanced Beauty Type" val:0];
        [self.fxARFace setFloatVal:@"Beauty Strength" val:0];
        [self.fxARFace setFloatVal:@"Advanced Beauty Intensity" val:value];
        self.uiDelegate.isFirstAdvancedBeautyType = YES;
    }else if ([model.fxName isEqualToString:@"Advanced Beauty Type One"]) {
        [self.fxARFace setBooleanVal:@"Advanced Beauty Enable" val:YES];
        [self.fxARFace setIntVal:@"Advanced Beauty Type" val:1];
        [self.fxARFace setFloatVal:@"Beauty Strength" val:0];
        [self.fxARFace setFloatVal:@"Advanced Beauty Intensity" val:value];
        self.uiDelegate.isFirstAdvancedBeautyType = NO;
    }else if ([model.fxName isEqualToString:@"Advanced Beauty Type Two"]) {
        [self.fxARFace setBooleanVal:@"Advanced Beauty Enable" val:YES];
        [self.fxARFace setIntVal:@"Advanced Beauty Type" val:2];
        [self.fxARFace setFloatVal:@"Beauty Strength" val:0];
        [self.fxARFace setFloatVal:@"Advanced Beauty Intensity" val:value];
        self.uiDelegate.isFirstAdvancedBeautyType = NO;
    }else if ([model.fxName isEqualToString:@"Advanced Beauty Type Three"]) {
        [self.fxARFace setBooleanVal:@"Advanced Beauty Enable" val:YES];
        [self.fxARFace setIntVal:@"Advanced Beauty Type" val:3];
        [self.fxARFace setFloatVal:@"Beauty Strength" val:0];
        [self.fxARFace setFloatVal:@"Advanced Beauty Intensity" val:value];
        self.uiDelegate.isFirstAdvancedBeautyType = NO;
        if(![NvBaseUtils enableAIBeauty]) {
            if([self.uiDelegate respondsToSelector:@selector(showAdvacedBeautyThreeOverWeightNegativeToast)]) {
                [self.uiDelegate showAdvacedBeautyThreeOverWeightNegativeToast];
            }
        }
        
    }else if ([model.fxName isEqualToString:@"Beauty Strength"]){
        [self.fxARFace setFloatVal:@"Advanced Beauty Intensity" val:0];
        [self.fxARFace setFloatVal:model.fxName val:value];
    }else if ([model.fxName isEqualToString:@"Shiny"]){
        [self.fxARFace setFloatVal:@"Advanced Beauty Matte Intensity" val:value];
        [self.fxARFace setFloatVal:@"Advanced Beauty Matte Fill Radius" val:3+model.extValue*27];
    } else if([model.fxName containsString:@"Skin Color"]){
        if (model.uuid.length > 0 && model.selected){
            if (self.beautyTemplateTool.whiteningFilter){
                if (![self.beautyTemplateTool.whiteningFilter.captureVideoFxPackageId isEqualToString:model.uuid]){
                    [self.streamingContext removeCaptureVideoFx:self.beautyTemplateTool.whiteningFilter.index];
                    self.beautyTemplateTool.whiteningFilter = [NvFilterUsageUtil appendPackagedCaptureVideoFx:model.uuid];
                }
            }else{
                self.beautyTemplateTool.whiteningFilter = [NvFilterUsageUtil appendPackagedCaptureVideoFx:model.uuid];
            }
        }
        [self.beautyTemplateTool.whiteningFilter setFilterIntensity:value];
    }else if([model.fxName containsString:@"Beauty Whitening"]){
        if ([model.fxName isEqualToString:@"Beauty Whitening A"]){
            [self.fxARFace setStringVal:@"Whitening Lut File" val:@""];
            [self.fxARFace setBooleanVal:@"Whitening Lut Enabled" val:NO];
            [self.fxARFace setFloatVal:@"Beauty Whitening" val:model.value];
        }else{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"whitenLut" ofType:@"bundle"];
            NSString *imagePath = [path stringByAppendingPathComponent:@"WhiteB.mslut"];
            if (model.packageUrl.length > 0){
                if ([[NSFileManager defaultManager] fileExistsAtPath:model.packageUrl]){
                    [self.fxARFace setStringVal:@"Whitening Lut File" val:model.packageUrl];
                }else{
                    [self.fxARFace setStringVal:@"Whitening Lut File" val:imagePath];
                }
            }else{
                [self.fxARFace setStringVal:@"Whitening Lut File" val:imagePath];
            }
            [self.fxARFace setBooleanVal:@"Whitening Lut Enabled" val:YES];
            [self.fxARFace setFloatVal:@"Beauty Whitening" val:model.value];
        }
    }else if(model.fxName.length > 0 && (model.subprojectArray.count == 0 || model.subprojectArray)){
        [self.fxARFace setFloatVal:model.fxName val:value];
    }
}

#pragma mark - 应用美型效果
/// Application of shaping  effect
- (void)applyBeautyShapeModel:(NvBeautyTypeModel *)model withChange:(BOOL)change{
    CGFloat value = self.isDiscardCurrentEffect?0:model.value;
    if (self.isContentAI) {
        if (model.degreeName.length == 0 || model.degreeName == nil) {
            model.degreeName = [[NvBeautyShapeModuler sharedInstance] getDegreeNameOfFxName:model.fxName];
        }
        NSString *degreeName = model.degreeName;
        [self setWarpStrategy:model];
        if (model.fxName.length > 0) {
            [self.fxARFace setStringVal:model.fxName val:model.uuid];
        }
        if (degreeName > 0) {
            [self.fxARFace setFloatVal:degreeName val:value];
        }
        
    }else if(model.fxName.length > 0){
        [self.fxARFace setFloatVal:model.fxName val:value];
    }
}

#pragma mark - 应用微整形效果
/// Application of  micro shaping effect
- (void)applyBeautyMicroshapingModel:(NvBeautyTypeModel *)model withChange:(BOOL)change{
    CGFloat value = self.isDiscardCurrentEffect?0:model.value;
    if (model.degreeName.length == 0 || !model.degreeName) {
        model.degreeName = [[NvBeautyShapeModuler sharedInstance] getDegreeNameOfFxName:model.fxName];
    }
    NSString *degreeName = model.degreeName;
    if(degreeName.length > 0) {
        /*
         warp or facemesh
         */
        [self setWarpStrategy:model];
        if (model.fxName.length > 0){
            [self.fxARFace setStringVal:model.fxName val:model.uuid];
        }
        
        [self.fxARFace setFloatVal:degreeName val:value];
    }else if (model.fxName.length > 0){
        /*
         advaced beauty
         */
        [self.fxARFace setFloatVal:model.fxName val:value];
    }
}

#pragma mark - 应用调节效果
/// Application of  adjustment effect
- (void)applyAdjustModel:(NvBeautyTypeModel *)model withChange:(BOOL)change{
    CGFloat value = self.isDiscardCurrentEffect?0:model.value;
    
    if ([model.fxName isEqualToString:@"Sharpen"]) {
        if (model.selected){
            if (!self.beautyTemplateTool.fxSharpen) {
                self.beautyTemplateTool.fxSharpen = [self.streamingContext appendBuiltinCaptureVideoFx:@"Sharpen"];
            }
        }
        [self.beautyTemplateTool.fxSharpen setFloatVal:model.degreeName val:value];
    }else if ([model.fxName isEqualToString:@"Definition"]){
        if (model.selected){
            if (!self.beautyTemplateTool.fxDefinition) {
                self.beautyTemplateTool.fxDefinition = [self.streamingContext appendBuiltinCaptureVideoFx:@"Definition"];
            }
        }
        
        [self.beautyTemplateTool.fxDefinition setFloatVal:model.degreeName val:value];
    }else if ([model.fxName isEqualToString:@"ColorCorrect"]){
        if (model.uuid.length > 0 && model.selected){
            if (self.beautyTemplateTool.colorCorrectFilter){
                if (![self.beautyTemplateTool.colorCorrectFilter.captureVideoFxPackageId isEqualToString:model.uuid]){
                    [self.streamingContext removeCaptureVideoFx:self.beautyTemplateTool.colorCorrectFilter.index];
                    self.beautyTemplateTool.colorCorrectFilter = [NvFilterUsageUtil appendPackagedCaptureVideoFx:model.uuid];
                }
            }else{
                self.beautyTemplateTool.colorCorrectFilter = [NvFilterUsageUtil appendPackagedCaptureVideoFx:model.uuid];
            }
        }
        
        [self.beautyTemplateTool.colorCorrectFilter setFilterIntensity:value];
    }
}

#pragma mark  默认添加一个校色滤镜
/// A calibration filter is added by default
- (void)installColorCorrectFilter {
    NSString *basePath = [[NSBundle mainBundle] pathForResource:@"colorCorrection" ofType:@"bundle"];
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:basePath error:nil];
    NSString *fullPath;
    NSString *licensePath;
    for (NSString *path in dirArray) {
        if ([path.pathExtension isEqualToString:@"videofx"]) {
            fullPath = [basePath stringByAppendingPathComponent:path];
            licensePath = [NSString convertFilePathToNewPath:fullPath WithExtension:@"lic"];
            break;
        }
    }
    if (!fullPath) {
        return;
    }
    [NvSDKUtils installAssetPackage:fullPath license:licensePath assetType:NvsAssetPackageType_VideoFx];
}

#pragma mark - 应用修容效果
/// Application of  contouring effect
- (void)applyContouringModel:(NvBeautyTypeModel *)model withChange:(BOOL)change{
    CGFloat value = self.isDiscardCurrentEffect?0:model.value;
    if (model.uuid.length > 0 && model.degreeName.length > 0) {
        [self.fxARFace setStringVal:model.fxName val:model.uuid];
        [self.fxARFace setFloatVal:model.degreeName val:value];
    }
}

- (void)discardCurrentEffect:(BOOL)discard{
    self.isDiscardCurrentEffect = discard;
    
    if (_fxFilter) {
        [_fxFilter setFilterIntensity:discard?0:1];
    }
    
    [self applyBeautyEffectInCondition:self.beautyFxArray];
    if (!discard){
        [self.beautyTemplateTool applyBeautyTemplateWhitening];
    }
    [self applyBeautyTypeEffectInCondition:self.shapeFxArray];
    [self applyMicroShapingEffectInCondition:self.microShapingFxArray];
    [self applyAdjust:self.adjustArray];
    [self applyContouring:self.contouringArray];
    
    ///对比按钮，按下抬起恢复，如果当前只有妆容，没有美颜模版，则重新应用一下妆容
    ///Contrast button, press Lift recovery, if the current only makeup, no beauty template, reapply the makeup
    if ((self.makeupManager.getEffectModel && !self.currentTemplatemodel) && !discard){
        [self.makeupManager applyMakeupEffect:self.makeupManager.getEffectModel.packagePath arsceneFx:self.fxARFace];
    }
}

- (void)applyBeautyWithNoPermissionAlert {
    if ([self.uiDelegate respondsToSelector:@selector(showNoARScenePermissionAlert)]) {
        [self.uiDelegate showNoARScenePermissionAlert];
    }
}

- (NvsColor)nvsColorWithValue:(NSString *)value {
    NSArray *arr = [value componentsSeparatedByString:@","];
    NvsColor color;
    color.r = 0;
    color.g = 0;
    color.b = 0;
    color.a = 0;
    if (arr.count == 4) {
        color.r = [arr[0] floatValue];
        color.g = [arr[1] floatValue];
        color.b = [arr[2] floatValue];
        color.a = [arr[3] floatValue];
    }
    return color;
}

- (void)applyBeautyWithForbiddenReplaceEffect:(NvBeautyTypeModel *_Nullable)model {
    if([self.uiDelegate respondsToSelector:@selector(showUnReplaceableEffectTips)]) {
        [self.uiDelegate showUnReplaceableEffectTips];
    }
}

- (void)forbiddenApplyBeautyTypeEffectWithProps:(NvBeautyTypeModel *_Nullable)model {
    if ([self.uiDelegate respondsToSelector:@selector(showForbiddenBeautyTypeEffectTips)]) {
        [self.uiDelegate showForbiddenBeautyTypeEffectTips];
    }
}


#pragma mark - 应用滤镜 Application filter
- (void)applyFilter:(NvBaseModel *_Nullable)model {
    self.currentFilterModel = (NvCaptureFilterModel *)model;
    if (_fxFilter.bultinCaptureVideoFxName.length > 0 || _fxFilter.captureVideoFxPackageId.length > 0) {
        [_streamingContext removeCaptureVideoFx:_fxFilter.index];
        _fxFilter = nil;
    }
    if (!model) {
        for (int i=0; i < [_streamingContext getCaptureVideoFxCount]; i++) {
            NvsCaptureVideoFx *fx = [_streamingContext getCaptureVideoFxByIndex:i];
            NSString *stringPackageId = fx.captureVideoFxPackageId;
            if (stringPackageId.length > 0) {
                if ([self.beautyTemplateTool.whiteningFilter.captureVideoFxPackageId isEqualToString:stringPackageId]) {
                    [_streamingContext removeCaptureVideoFx:i];
                    self.beautyTemplateTool.whiteningFilter = nil;
                }else if ([self.beautyTemplateTool.colorCorrectFilter.captureVideoFxPackageId isEqualToString:stringPackageId]) {
                    [_streamingContext removeCaptureVideoFx:i];
                    self.beautyTemplateTool.colorCorrectFilter = nil;
                }else{
                    [_streamingContext removeCaptureVideoFx:i];
                }
                i--;
            }
        }
        return;
    }
    if (![model.displayName isEqualToString:NvLocalString(@"None", @"无")]) {
        if (model.builtinName) {
            _fxFilter = [_streamingContext appendBuiltinCaptureVideoFx:model.builtinName];
            if ([model.builtinName isEqualToString:@"Cartoon"]) {
                [_fxFilter setBooleanVal:@"Stroke Only" val:self.currentFilterModel.strokeOnly];
                [_fxFilter setBooleanVal:@"Grayscale" val:self.currentFilterModel.grayscale];
            }
        } else if (model.packageId) {
            _fxFilter = [NvFilterUsageUtil appendPackagedCaptureVideoFx:model.packageId];
            if ([self containExpParam:model]) {
                [self setMaxFilterStrength];
            }else {
                if (model.categoryId == 2 && (model.kindId == 8||model.kindId == 9)){
                    
                }else{
                    [_fxFilter setFilterIntensity:model.value];
                }
            }
        }
        
    }
    if([self.uiDelegate respondsToSelector:@selector(updateFilterElementsInBeautyView:)]) {
        [self.uiDelegate updateFilterElementsInBeautyView:self.currentFilterModel];
    }
}

//应用默认滤镜 Apply the default filter
- (void)applyDefaultFilter {
    if (DEFAULT_FILTER.length > 0){
        self.fxFilter = [NvFilterUsageUtil appendPackagedCaptureVideoFx:DEFAULT_FILTER];
        [self.fxFilter setFilterIntensity:0.8];
    }
}

- (void)setMaxFilterStrength {
    [self.fxFilter setFilterIntensity:1.f];
}

//素材是否包含可调节表达式 Whether the material contains tunable expressions
- (BOOL)containExpParam:(NvBaseModel *)model {
    NSArray <NvsExpressionParam *>* expArr = [_streamingContext.assetPackageManager getExpValueList:model.packageId type:NvsAssetPackageType_VideoFx];
    return expArr.count > 0 ? YES : NO;
}

- (void)setFilterExpValue:(NSArray <NvAjustFxParamModel *> *)models {
    for (NvAjustFxParamModel *model in models) {
        if (model.type == NvAjustFxParamCategoryColor) {
            NvsColor color;
            color.r = model.r;
            color.g = model.g;
            color.b = model.b;
            color.a = model.a;
            [self.fxFilter setColorExprVar:model.name varValue:&color];
        }
        else if (model.type == NvAjustFxParamCategoryInt || model.type == NvAjustFxParamCategoryFloat) {
            [self.fxFilter setExprVar:model.name varValue:model.currentValue];
        }
    }
}

- (void)applyFilterAndSetExpValue:(NSArray <NvAjustFxParamModel *> *)models {
    [self.fxFilter resetStartTime];
}

- (void)setWarpStrategy:(NvBeautyTypeModel *)model {
    if ([model.fxName isEqualToString:@"Warp Forehead Height Custom Package Id"]) {
        [self.fxARFace setIntVal:@"Forehead Height Warp Strategy" val:0x7FFFFFFF];
    }
    else if ([model.fxName isEqualToString:@"Warp Head Size Custom Package Id"]) {
        [self.fxARFace setIntVal:@"Head Size Warp Strategy" val:0x7FFFFFFF];
    }
}

- (void)switchAction:(NvSwitchView* )sender{
    
    
}
#pragma mark - lazyload
- (NvsStreamingContext *)streamingContext {
    if (!_streamingContext) {
        _streamingContext = [NvSDKUtils getSDKContext];
    }
    return _streamingContext;
}
@end
