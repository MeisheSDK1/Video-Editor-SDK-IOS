//
//  NvMakeupToolManager.m
//  SDKDemo
//
//  Created by Meishe on 2022/11/8.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvMakeupToolManager.h"
#import "NvsVideoFx.h"
#import "NvSDKMakeupUtils.h"
#import <YYModel/YYModel.h>
#import "NvMakeupToolBeautyModuler.h"
#import "NvMakeupToolMakeupModuler.h"
#import "NvFilterUsageUtil.h"
#import <NvSDKCommon/NvInitArScence.h>

@interface NvMakeupToolManager ()
@property (nonatomic, strong) NSMutableArray *beautyFxArray;
@property (nonatomic, strong) NSMutableArray *beautyTypeFxArray;
@property (nonatomic, strong) NSMutableArray *microShapeFxArray;
@property (nonatomic, strong) NvMakeupToolBeautyModuler *beautyModuler;
@property (nonatomic, strong) NvMakeupToolMakeupModuler *makeupModuler;
@property (nonatomic, strong) NSString *lastUnzipPath;
@property (nonatomic, strong) NvMakeupToolModel *lastEffectModel;
@property (nonatomic, strong) NvsStreamingContext *context;
@end

@implementation NvMakeupToolManager
- (instancetype)init {
    if (self = [super init]) {
        self.context = [NvsStreamingContext sharedInstance];
        self.beautyFxArray = [NSMutableArray array];
        self.beautyTypeFxArray = [NSMutableArray array];
        self.microShapeFxArray = [NSMutableArray array];
        self.beautyModuler = [[NvMakeupToolBeautyModuler alloc] init];
        self.makeupModuler = [[NvMakeupToolMakeupModuler alloc] init];
    }
    return self;
}

- (void)applyMakeupEffect:(NSString *)assetPath arsceneFx:(NvsFx *)arsceneFx {
    if (self.lastUnzipPath && [assetPath isEqualToString:self.lastUnzipPath]) {
        /*
         再次点击同一个妆容包的时候，把数据恢复默认值
         When you click on the same makeup bag again, restore the data to the default values
         */
        self.lastEffectModel.currentValue = self.lastEffectModel.defaultValue;
        self.lastEffectModel.filterCurrentValue = self.lastEffectModel.filterDefaultValue;
        for (NvMakeupToolEffectModel *model in self.lastEffectModel.effectContent.makeup) {
            model.beReplaced = NO;
            for (NvMakeupToolElementModel *elementModel in model.params) {
                if ([elementModel isKindOfClass:NvMakeupToolElementFloatModel.class] && model.canReplace){
                    NvMakeupToolElementFloatModel *floatModel = (NvMakeupToolElementFloatModel *)elementModel;
                    floatModel.value = floatModel.defaultValue;
                    break;
                }
            }
        }
        for (NvMakeupToolEffectModel *model in self.lastEffectModel.effectContent.filter) {
            model.value = model.defaultValue;
        }
        [self applyVariableCompose:self.lastEffectModel arsceneFx:arsceneFx];
    }else{
        [self processMakeup:assetPath arsceneFx:arsceneFx];
    }
}

- (void)processMakeup:(NSString *)unzipPath arsceneFx:(NvsFx *)arsceneFx {
    __weak typeof(self)weakSelf = self;
    [self getMakeupEffectModel:unzipPath completeBlock:^(NvMakeupToolModel *effectModel) {
        [weakSelf applyVariableCompose:effectModel arsceneFx:arsceneFx];
    }];
}

- (void)getMakeupEffectModel:(NSString *)dirPath completeBlock:(void(^)(NvMakeupToolModel *effectModel))completeBlock {
    
    NSString *jsonPath = [dirPath stringByAppendingPathComponent:@"info_new.json"];
    NSData *varialbeData = [[NSData alloc] initWithContentsOfFile:jsonPath];
    
    BOOL isNewInfo = YES;
    if(!varialbeData) {
        jsonPath = [dirPath stringByAppendingPathComponent:@"info.json"];
        varialbeData = [[NSData alloc] initWithContentsOfFile:jsonPath];
        
        if (varialbeData) {
            isNewInfo = NO;
        }
    }
    
    if(varialbeData) {
        
        NSDictionary *infoDic = [NSJSONSerialization JSONObjectWithData:varialbeData options:
                                 NSJSONReadingMutableLeaves|
                                 NSJSONReadingMutableContainers|
                                 NSJSONReadingFragmentsAllowed|
                                 NSJSONReadingAllowFragments error:nil];
        NvMakeupToolModel *contentM = [NvMakeupToolModel yy_modelWithJSON:infoDic];
        if (!contentM) {
            return;
        }
        if (!isNewInfo){
            NvMakeupToolEffectContentModel *newModel = [[NvMakeupToolEffectContentModel alloc] init];
            newModel.filter = contentM.effectContent.filter;
            if (infoDic[@"effectContent"]){
                NvMakeupEffectOldInfoModel *oldModel = [NvMakeupEffectOldInfoModel yy_modelWithJSON:infoDic[@"effectContent"]];
                [self conversionNewData:newModel with:oldModel withPath:dirPath];
            }
            contentM.effectContent = newModel;
        }

        contentM.packagePath = dirPath;
        if (contentM.effectContent.makeup.count > 0) {
            for (NvMakeupToolEffectModel *effectM in contentM.effectContent.makeup) {
                [self installAsset:dirPath model:effectM assetType:NvsAssetPackageType_Makeup];
            }
        }
        if (contentM.effectContent.filter.count > 0) {
            for (NvMakeupToolEffectModel *effectM in contentM.effectContent.filter) {
                [self installAsset:dirPath model:effectM assetType:NvsAssetPackageType_VideoFx];
            }
        }
        if (contentM.effectContent.shape.count > 0) {
            for (NvMakeupToolEffectModel *effectM in contentM.effectContent.shape) {
                [self installAsset:dirPath model:effectM assetType:NvsAssetPackageType_FaceMesh];
            }
        }
        if (contentM.effectContent.beauty.count > 0) {
            for (NvMakeupToolEffectModel *effectM in contentM.effectContent.beauty) {
                if ([effectM.type caseInsensitiveCompare:@"ColorCorrect"] == NSOrderedSame  && effectM.uuid.length > 0) {
                    [self installAsset:dirPath model:effectM assetType:NvsAssetPackageType_VideoFx];
                    break;
                }
            }
        }
        if (contentM.effectContent.microShape.count > 0) {
            for (NvMakeupToolEffectModel *effectM in contentM.effectContent.microShape) {
                [self installAsset:dirPath model:effectM assetType:NvsAssetPackageType_FaceMesh];
            }
        }
        self.lastUnzipPath = dirPath;
        self.lastEffectModel = contentM;
        if (completeBlock) {
            completeBlock(contentM);
        }
    }
}

- (NSArray *)getCurrentExistSingleMakeupElements {
    if (self.lastEffectModel == nil){
        if ([self.delegate respondsToSelector:@selector(getExistSingleMakeupElements:)]) {
            return [self.delegate getExistSingleMakeupElements:self];
        }
    }
    
    return nil;
}

- (void)removeAllMakeupEffects:(NvsFx *)arsceneFx {
    self.lastUnzipPath = nil;
    self.lastEffectModel = nil;
    [self applyVariableCompose:nil arsceneFx:arsceneFx];
}

- (NvMakeupToolModel *)getEffectModel {
    return self.lastEffectModel;
}

//应用特效接口
// Apply special effects interface
- (void)applyVariableCompose:(NvMakeupToolModel *)effectModel arsceneFx:(NvsFx *)arsceneFx {
    [self applyMakeupPackage:effectModel.effectContent arsceneFx:arsceneFx];
    [self applyMakeupFilterEffect:effectModel.effectContent arsceneFx:arsceneFx];
    
    [self.beautyModuler getAndSetARSceneFx:effectModel fx:arsceneFx];
    [self.beautyModuler applyMakeupMicroShapeEffect:effectModel.effectContent arsceneFx:arsceneFx];
    [self.beautyModuler applyMakeupBeautyEffect:effectModel.effectContent arsceneFx:arsceneFx];
    [self.beautyModuler applyMakeupBeautyShapeEffect:effectModel.effectContent arsceneFx:arsceneFx];
    
    
    if([self.delegate respondsToSelector:@selector(didApplyMakeupEffect:)]) {
        [self.delegate didApplyMakeupEffect:self];
    }
}

- (void)changeMakeupEffectArsceneFx:(NvsFx *)arsceneFx{
    if (self.lastEffectModel) {
        for (NvMakeupToolEffectModel *model in self.lastEffectModel.effectContent.makeup) {
            if (!model.beReplaced) {
                for (NvMakeupToolElementModel *elementModel in model.params) {
                    if ([elementModel isKindOfClass:NvMakeupToolElementFloatModel.class] && model.canReplace){
                        NvMakeupToolElementFloatModel *floatModel = (NvMakeupToolElementFloatModel *)elementModel;
                        CGFloat value = self.lastEffectModel.currentValue *floatModel.defaultValue;
                        floatModel.value = value;
                        break;
                    }
                }
            }
        }
        
        [self.makeupModuler changeMakeupPackage:self.lastEffectModel.effectContent];
    }
}

- (void)changeMakeupFilterArsceneFx:(NvsFx *)arsceneFx{
    if (self.lastEffectModel) {
        for (NvMakeupToolEffectModel *model in self.lastEffectModel.effectContent.filter) {
            model.value = self.lastEffectModel.filterCurrentValue*model.defaultValue;
        }
        
        [self changeMakeupFilterEffect:self.lastEffectModel.effectContent];
    }
}

#pragma mark - NvMakeupViewDelegate
- (void)applyMakeupPackage:(NvMakeupToolEffectContentModel *)effectModel arsceneFx:(NvsFx *)fx {
    NSArray *kindArr =  @[@"Brighten",
                          @"Eyelash",
                          @"Lip",
                          @"Eyebrow",
                          @"Blusher",
                          @"Shadow",
                          @"Eyeliner",
                          @"Eyeshadow",
                          @"Eyeball"];
    if (!fx) {
        if (self.mode == NvMakeupModulerModeEdit) {
            fx = [NvSDKMakeupUtils createClipVideoFx:@"AR Scene" withClip:self.clip];
        }else if (self.mode == NvMakeupModulerModeCapture){
            fx = [_context appendBuiltinCaptureVideoFx:@"AR Scene"];
        }
        if (![fx isKindOfClass:[NvsCaptureVideoFx class]]){
            if (ARSCENE_MS || ARSCENE_MS_240) {
                [[fx getARSceneManipulate] setDetectionMode:NvsARSceneDetectionMode_SemiImage];
            }
        }
        [fx setBooleanVal:@"Max Faces Respect Min" val:YES];
        BOOL highVersion = [NvInitArScence isHighVersionPhone];
        if(highVersion) {
            [fx setBooleanVal:@"AI Face Occlusion Enabled" val:YES];
        }
//        if(ARSCENE_MS_240){
//            // !!!: 设置后就会走检测， 不需要设置 3.12.0+
//            [fx setBooleanVal:@"Use Face Extra Info" val:YES];
//        }
    }
    
    self.makeupModuler.fxARFace = fx;
    [self.makeupModuler applyMakeupPackage:effectModel makeupKindArr:kindArr];
}

//应用整妆中的滤镜效果
// Apply the filter effect to the whole makeup
- (void)applyMakeupFilterEffect:(NvMakeupToolEffectContentModel *)effectModel arsceneFx:(NvsFx *)fx {
    if (self.mode == NvMakeupModulerModeEdit) {
        for (int i=0; i<self.clip.fxCount; i++) {
            NvsVideoFx *fx = [self.clip getFxWithIndex:i];
            if (!(fx.bultinVideoFxName.length > 0 || fx.videoFxPackageId.length > 0)) {
                continue;
            }
            if ([fx.bultinVideoFxName isEqualToString:@"AR Scene"] || [fx.bultinVideoFxName isEqualToString:@"Segmentation Background Fill"]) {
                continue;
            }else {
                [self.clip removeFx:i];
                i--;
                
            }
        }
        for (int i=0; i<effectModel.filter.count; i++) {
            NvMakeupToolEffectModel *filterModel = effectModel.filter[i];
            if (filterModel.isBuiltIn) {
                NvsVideoFx *fx = [self.clip appendBuiltinFx:filterModel.uuid];
                [fx setFilterIntensity:filterModel.value];
                
            } else if (filterModel.uuid) {
                NvsVideoFx *fx = [self.clip appendPackagedFx:filterModel.uuid];
                [fx setFilterIntensity:filterModel.value];
            }
        }
    }else if (self.mode == NvMakeupModulerModeCapture){
        for (int i=0; i < [_context getCaptureVideoFxCount]; i++) {
            NvsCaptureVideoFx *fx = [_context getCaptureVideoFxByIndex:i];
            if (!(fx.bultinCaptureVideoFxName.length > 0 || fx.captureVideoFxPackageId.length > 0)) {
                continue;
            }
            if (![fx.bultinCaptureVideoFxName isEqualToString:@"AR Scene"] && ![fx.bultinCaptureVideoFxName isEqualToString:@"Segmentation Background Fill"]) {
                [_context removeCaptureVideoFx:i];
                i--;
            }
        }
        for (int i=0; i<effectModel.filter.count; i++) {
            NvMakeupToolEffectModel *filterModel = effectModel.filter[i];
            if (filterModel.isBuiltIn) {
                NvsCaptureVideoFx *fx = [_context appendBuiltinCaptureVideoFx:filterModel.uuid];
                [fx setFilterIntensity:filterModel.value];

            } else if (filterModel.uuid) {
                NvsCaptureVideoFx *fx = [NvFilterUsageUtil appendPackagedCaptureVideoFx:filterModel.uuid];
                [fx setFilterIntensity:filterModel.value];
            }
        }
    }
}

- (void)changeMakeupFilterEffect:(NvMakeupToolEffectContentModel *)effectModel{
    if (self.mode == NvMakeupModulerModeEdit) {
        
    }else if (self.mode == NvMakeupModulerModeCapture){
        for (int i=0; i<effectModel.filter.count; i++) {
            NvMakeupToolEffectModel *filterModel = effectModel.filter[i];
            for (int i=0; i < [_context getCaptureVideoFxCount]; i++) {
                NvsCaptureVideoFx *fx = [_context getCaptureVideoFxByIndex:i];
                if(fx.bultinCaptureVideoFxName.length > 0 && (filterModel.isBuiltIn && filterModel.uuid.length > 0)){
                    if ([filterModel.uuid isEqualToString:fx.bultinCaptureVideoFxName]) {
                        [fx setFilterIntensity:filterModel.value];
                    }
                }else if (fx.captureVideoFxPackageId.length > 0 && (!filterModel.isBuiltIn && filterModel.uuid.length > 0)){
                    if ([filterModel.uuid isEqualToString:fx.captureVideoFxPackageId]) {
                        [fx setFilterIntensity:filterModel.value];
                    }
                }
            }
        }
    }
}

- (void)installAsset:(NSString *)dirPath model:(NvMakeupToolEffectModel *)model assetType:(NvsAssetPackageType)assetType {
    if (model.uuid.length > 0) {
        [self installAsset:dirPath uuid:model.uuid assetType:assetType];
    }else if(model.params.count > 0){
        for (NvMakeupToolElementModel *element in model.params) {
            if ([element.type caseInsensitiveCompare:@"string"] == NSOrderedSame && [element.key containsString:@"Package Id"]) {
                NvMakeupToolElementStringModel *item = (NvMakeupToolElementStringModel *)element;
                [self installAsset:dirPath uuid:item.value assetType:assetType];
                break;
            }
        }
    }
}

- (void)installAsset:(NSString *)dirPath uuid:(NSString *)uuid assetType:(NvsAssetPackageType)assetType {
    NSString *assetFilePath = [self getPackagePath:dirPath uuid:uuid];
    NSString *licFilePath = [self getLicPath:dirPath uuid:uuid];
    //美型新旧两种包，确保素材类型是否传正确
    // New and old packages to ensure that the material type is passed correctly
    if (assetType == NvsAssetPackageType_Warp ||
        assetType == NvsAssetPackageType_FaceMesh) {
        if ([assetFilePath.pathExtension isEqualToString:@"facemesh"]) {
            assetType = NvsAssetPackageType_FaceMesh;
        }else if([assetFilePath.pathExtension isEqualToString:@"warp"]) {
            assetType = NvsAssetPackageType_Warp;
        }
    }
#ifdef DEBUG
    if(licFilePath.nv_isNotEmpty){
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:licFilePath];
        // 使用NSAssert来确保文件必须存在
        NSAssert(fileExists, @"lic文件不存在: %@", licFilePath);
    }else{
        
        DebugLog(@"lic文件路径为空");
    }
#endif
    [NvSDKMakeupUtils installAssetPackage:assetFilePath licPath:licFilePath assetType:assetType];
}

- (NSString *)getPackagePath:(NSString *)dirPath uuid:(NSString *)uuid {
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:dirPath error:nil];
    NSString *packagePath ;
    if (uuid && uuid.length > 0) {
        for (NSString *path in dirArray) {
            //It is assumed that there are only these five situations at present
            if (([path.pathExtension isEqualToString:@"videofx"] || [path.pathExtension isEqualToString:@"makeup"] || [path.pathExtension isEqualToString:@"beauty"] || [path.pathExtension isEqualToString:@"facemesh"] || [path.pathExtension isEqualToString:@"warp"]) && [path containsString:uuid]) {
                packagePath = [dirPath stringByAppendingPathComponent:path];
                break;
            }
        }
    }
    return packagePath;
}

- (NSString *)getLicPath:(NSString *)dirPath uuid:(NSString *)uuid {
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:dirPath error:nil];
    NSString *packagePath ;
    for (NSString *path in dirArray) {
        if ([path.pathExtension isEqualToString:@"lic"] && [path containsString:uuid]) {
            packagePath = [dirPath stringByAppendingPathComponent:path];
            break;
        }
    }
    return packagePath;
}

#pragma mark - 根据旧版妆容的json内容转成新版json
//Convert the json content of the old version of makeup into the new version of json
- (void)conversionNewData:(NvMakeupToolEffectContentModel *)newModel with:(NvMakeupEffectOldInfoModel *)oldModel withPath:(NSString *)dirPath{
    //解析旧版本美妆结构，转化成新版本美妆结构
    // Analyze the old makeup structure and transform it into the new makeup structure
    newModel.makeup = [NSMutableArray array];
    
    for (NvMakeupEffectBeautyContentOldInfoModel *model in oldModel.makeup) {
        NvMakeupToolEffectModel *toolEffectModel = [[NvMakeupToolEffectModel alloc]init];
        toolEffectModel.type = model.type;
        toolEffectModel.canReplace = model.canReplace;
        NSMutableArray *makeupparams = [NSMutableArray array];
        
        if (model.className && model.className.length > 0) {
            NvMakeupToolElementStringModel *stringModel = [[NvMakeupToolElementStringModel alloc] init];
            stringModel.key = model.className;
            stringModel.type = @"string";
            if (model.uuid && model.uuid.length > 0) {
                stringModel.value = model.uuid;
            }
            
            [makeupparams addObject:stringModel];
        }
        
        if (toolEffectModel.type && toolEffectModel.type.length > 0) {
            NvMakeupToolElementFloatModel *floatModel = [[NvMakeupToolElementFloatModel alloc] init];
            floatModel.key = [[@"Makeup " stringByAppendingString:model.type] stringByAppendingString:@" Intensity"];
            floatModel.type = @"float";
            floatModel.value = model.value;
            
            [makeupparams addObject:floatModel];
        }
        
        toolEffectModel.params = makeupparams;
        
        [newModel.makeup addObject:toolEffectModel];
    }
    
    //解析旧版本美颜结构，转化成新版本美颜结构
    // Analyze the old version beauty structure and convert it into the new version beauty structure
    newModel.beauty = [NSMutableArray array];
    if (oldModel.beauty.count > 0) {
        NvMakeupToolEffectModel *toolEffectModel = [[NvMakeupToolEffectModel alloc]init];
        NSMutableArray *mutableArray = [NSMutableArray array];
        
        NvMakeupToolElementBOOLModel *boolModel = [[NvMakeupToolElementBOOLModel alloc] init];
        boolModel.key = @"Beauty Effect";
        boolModel.value = true;
        boolModel.type = @"boolean";
        [mutableArray addObject:boolModel];
        
        toolEffectModel.params = mutableArray;
        
        [newModel.beauty addObject:toolEffectModel];
    }
    for (NvMakeupEffectBeautyContentOldInfoModel *model in oldModel.beauty) {
        NvMakeupToolEffectModel *toolEffectModel = [[NvMakeupToolEffectModel alloc]init];
        toolEffectModel.canReplace = model.canReplace;
        
        NSMutableArray *mutableArray = [NSMutableArray array];
        if (model.advancedBeautyEnable) {
            NvMakeupToolElementBOOLModel *boolModel = [[NvMakeupToolElementBOOLModel alloc] init];
            boolModel.key = @"Advanced Beauty Enable";
            boolModel.value = true;
            boolModel.type = @"boolean";
            [mutableArray addObject:boolModel];
            
            toolEffectModel.params = mutableArray;
            
            NvMakeupToolElementIntModel *intModel = [[NvMakeupToolElementIntModel alloc] init];
            intModel.key = @"Advanced Beauty Type";
            intModel.value = (int)model.advancedBeautyType;
            intModel.type = @"int";
            [mutableArray addObject:intModel];
            
            NvMakeupToolElementFloatModel *floatModel = [[NvMakeupToolElementFloatModel alloc] init];
            floatModel.key = @"Advanced Beauty Intensity";
            floatModel.value = model.value;
            floatModel.type = @"float";
            [mutableArray addObject:floatModel];
            
            [newModel.beauty addObject:toolEffectModel];
        }else if (model.className && model.className.length > 0){
            if (model.whiteningLutEnabled){
                NvMakeupToolElementBOOLModel *boolModel = [[NvMakeupToolElementBOOLModel alloc] init];
                boolModel.key = @"Whitening Lut Enabled";
                boolModel.value = true;
                boolModel.type = @"boolean";
                [mutableArray addObject:boolModel];
                
                toolEffectModel.params = mutableArray;
                
                NvMakeupToolElementStringModel *stringModel = [[NvMakeupToolElementStringModel alloc] init];
                stringModel.key = @"Whitening Lut File";
                stringModel.value = @"WhiteB.mslut";
                stringModel.type = @"path";
                [mutableArray addObject:stringModel];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:[dirPath stringByAppendingPathComponent:@"WhiteB.mslut"]]) {
                    NSString *path = [[NSBundle mainBundle] pathForResource:@"whitenLut" ofType:@"bundle"];
                    path = [path stringByAppendingPathComponent:@"WhiteB.mslut"];
                    
                    BOOL filesPresent = [[NSFileManager defaultManager] copyItemAtPath:path toPath:[dirPath stringByAppendingPathComponent:@"WhiteB.mslut"] error:NULL];
                    NSLog(@"拷贝文件啊 Copy file%@，%d",[dirPath stringByAppendingPathComponent:@"WhiteB.mslut"],filesPresent);
                }
                
                NvMakeupToolElementFloatModel *floatModel = [[NvMakeupToolElementFloatModel alloc] init];
                floatModel.key = model.className;
                floatModel.value = model.value;
                floatModel.type = @"float";
                [mutableArray addObject:floatModel];
                
                [newModel.beauty addObject:toolEffectModel];
            }else if ([model.className isEqualToString:@"Beauty Whitening"]){
                NvMakeupToolElementBOOLModel *boolModel = [[NvMakeupToolElementBOOLModel alloc] init];
                boolModel.key = @"Whitening Lut Enabled";
                boolModel.value = false;
                boolModel.type = @"boolean";
                [mutableArray addObject:boolModel];
                
                toolEffectModel.params = mutableArray;
                
                NvMakeupToolElementStringModel *stringModel = [[NvMakeupToolElementStringModel alloc] init];
                stringModel.key = @"Whitening Lut File";
                stringModel.value = @"";
                stringModel.type = @"path";
                [mutableArray addObject:stringModel];
                
                NvMakeupToolElementFloatModel *floatModel = [[NvMakeupToolElementFloatModel alloc] init];
                floatModel.key = model.className;
                floatModel.value = model.value;
                floatModel.type = @"float";
                [mutableArray addObject:floatModel];
                
                [newModel.beauty addObject:toolEffectModel];
            }else if([model.className isEqualToString:@"Default Beauty Enabled"]){
                
                toolEffectModel.type = @"ColorCorrect";
                toolEffectModel.uuid = @"65521195-92A4-41CA-9DB5-6AB19C9321B5";
                toolEffectModel.value = model.value;
                NSString *path = [[NSBundle mainBundle] pathForResource:@"65521195-92A4-41CA-9DB5-6AB19C9321B5.1.videofx" ofType:@""];
                NSString *uuid = [[NvsStreamingContext sharedInstance].assetPackageManager getAssetPackageIdFromAssetPackageFilePath:path];
                NvsAssetPackageStatus status = [[NvsStreamingContext sharedInstance].assetPackageManager getAssetPackageStatus:uuid type:NvsAssetPackageType_VideoFx];
                if (status == NvsAssetPackageStatus_NotInstalled) {
                    
                    NSString * licensePath = [NSString convertFilePathToNewPath:path WithExtension:@"lic"];
                    [[NvsStreamingContext sharedInstance].assetPackageManager installAssetPackage:path license:licensePath type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:nil];
                }
            }else if ([model.className isEqualToString:@"Default Sharpen Enabled"]){
                NvMakeupToolElementBOOLModel *boolModel = [[NvMakeupToolElementBOOLModel alloc] init];
                boolModel.key = @"Default Sharpen Enabled";
                boolModel.value = model.value==0?false:true;
                boolModel.type = @"boolean";
                [mutableArray addObject:boolModel];
                
                toolEffectModel.params = mutableArray;
            }else{
                NvMakeupToolElementFloatModel *floatModel = [[NvMakeupToolElementFloatModel alloc] init];
                floatModel.key = model.className;
                floatModel.value = model.value;
                floatModel.type = @"float";
                [mutableArray addObject:floatModel];
                
                [newModel.beauty addObject:toolEffectModel];
            }
        }
    }
    
    //解析旧版本美型结构，转化成新版本美型结构
    // Parse the old version of beauty structure and transform it into the new version of beauty structure
    newModel.shape = [NSMutableArray array];
    if (oldModel.shape.count > 0) {
        NvMakeupToolEffectModel *toolEffectModel = [[NvMakeupToolEffectModel alloc]init];
        NSMutableArray *mutableArray = [NSMutableArray array];
        
        NvMakeupToolElementBOOLModel *boolModel = [[NvMakeupToolElementBOOLModel alloc] init];
        boolModel.key = @"Face Mesh Internal Enabled";
        boolModel.value = true;
        boolModel.type = @"boolean";
        [mutableArray addObject:boolModel];
        
        toolEffectModel.params = mutableArray;
        
        [newModel.shape addObject:toolEffectModel];
    }
    for (NvMakeupEffectBeautyContentOldInfoModel *model in oldModel.shape) {
        NvMakeupToolEffectModel *toolEffectModel = [[NvMakeupToolEffectModel alloc]init];
        toolEffectModel.type = model.type;
        toolEffectModel.canReplace = model.canReplace;
        NSMutableArray *mutableArray = [NSMutableArray array];
        
        if (model.className && model.className.length > 0) {
            NvMakeupToolElementStringModel *stringModel = [[NvMakeupToolElementStringModel alloc] init];
            stringModel.key = model.className;
            stringModel.type = @"string";
            if (model.uuid && model.uuid.length > 0) {
                stringModel.value = model.uuid;
            }
            
            [mutableArray addObject:stringModel];
        }
        
        if (model.degreeName && model.degreeName.length > 0) {
            NvMakeupToolElementFloatModel *floatModel = [[NvMakeupToolElementFloatModel alloc] init];
            floatModel.key = model.degreeName;
            floatModel.type = @"float";
            floatModel.value = model.value;
            
            [mutableArray addObject:floatModel];
        }
        
        toolEffectModel.params = mutableArray;
        
        [newModel.shape addObject:toolEffectModel];
    }
    
    //解析旧版本微整形结构，转化成新版本微整形结构
    // Parse the old microshaping structure and convert it into the new microshaping structure
    newModel.microShape = [NSMutableArray array];
    if (oldModel.microShape.count > 0) {
        NSArray *stringArray = @[@"Face Mesh Internal Enabled",@"Advanced Beauty Enable"];
        for (NSString *string in stringArray) {
            NvMakeupToolEffectModel *toolEffectModel = [[NvMakeupToolEffectModel alloc]init];
            NSMutableArray *mutableArray = [NSMutableArray array];
            
            NvMakeupToolElementBOOLModel *boolModel = [[NvMakeupToolElementBOOLModel alloc] init];
            boolModel.key = string;
            boolModel.value = true;
            boolModel.type = @"boolean";
            [mutableArray addObject:boolModel];
            
            toolEffectModel.params = mutableArray;
            
            [newModel.microShape addObject:toolEffectModel];
        }
    }
    for (NvMakeupEffectBeautyContentOldInfoModel *model in oldModel.microShape) {
        NvMakeupToolEffectModel *toolEffectModel = [[NvMakeupToolEffectModel alloc]init];
        toolEffectModel.type = model.type;
        toolEffectModel.canReplace = model.canReplace;
        NSMutableArray *mutableArray = [NSMutableArray array];
        
        if (model.className && model.className.length > 0) {
            NvMakeupToolElementStringModel *stringModel = [[NvMakeupToolElementStringModel alloc] init];
            stringModel.key = model.className;
            stringModel.type = @"string";
            if (model.uuid && model.uuid.length > 0) {
                stringModel.value = model.uuid;
                [mutableArray addObject:stringModel];
            }else{
                NvMakeupToolElementFloatModel *floatModel = [[NvMakeupToolElementFloatModel alloc] init];
                floatModel.key = model.className;
                floatModel.type = @"float";
                floatModel.value = model.value;
                [mutableArray addObject:floatModel];
            }
        }
        
        if (model.degreeName && model.degreeName.length > 0) {
            NvMakeupToolElementFloatModel *floatModel = [[NvMakeupToolElementFloatModel alloc] init];
            floatModel.key = model.degreeName;
            floatModel.type = @"float";
            floatModel.value = model.value;
            
            [mutableArray addObject:floatModel];
        }
        
        toolEffectModel.params = mutableArray;
        
        [newModel.microShape addObject:toolEffectModel];
    }
}

#pragma mark - setter
- (void)setMode:(NvMakeupModulerMode)mode {
    _mode = mode;
    self.beautyModuler.mode = mode;
}

- (void)setClip:(NvsVideoClip *)clip {
    _clip = clip;
    self.beautyModuler.clip = clip;
}
@end
