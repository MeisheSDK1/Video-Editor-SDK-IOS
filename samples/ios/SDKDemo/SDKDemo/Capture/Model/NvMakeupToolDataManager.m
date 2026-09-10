//
//  NvMakeupToolDataManager.m
//  SDKDemo
//
//  Created by Meishe on 2022/11/9.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvMakeupToolDataManager.h"
#import "SSZipArchive.h"
#import <NvSDKCommon/NvHttpRequest.h>
#import <NvSDKCommon/NvSDKUtils.h>

@interface NvMakeupToolDataManager ()
@property (nonatomic, assign) BOOL hasQueryKind;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation NvMakeupToolDataManager
- (instancetype)init {
    if(self = [super init]){
        self.labelColorArr = @[@"#CFC1FFFF",@"#C1DEFFFF",@"#FFC1C1FF",@"#C1CBFFFF"];
        self.varialbeMakeupModel = [NvMakeupLevelModel new];
        self.varialbeMakeupModel.contents = [NSMutableArray array];

        self.variableMakeupArr = [NSMutableArray array];
        self.totalEffectContent = [NvMakeupToolModel new];
        self.functionMode = NvMakeupFunctionModeCapture;
        self.kindArr = [NSMutableArray array];
        [self createMakeupDirs];
        
    }
    return self;
}

#pragma mark - 根据sdk 获取对应category值 Obtain the corresponding category value according to the sdk
- (int)getArsceneWholeCategory {
    if (ARSCENE_ST_240 || ARSCENE_MS_240) {
        return 3;
    }else{
        return 1;
    }
}

- (int)getArsceneVariableCategory {
    return 2;
}

- (int)getArsceneKindCategory {
    return 2;
}

#pragma mark - 美妆工程内置路径 Beauty engineering built-in path
- (NSString *)getBaseMakeupPath {
    NSString *basePath = [NvMakeupBundlePath stringByAppendingPathComponent:@"makeup240"];
    return basePath;
}

//获取预留的内置路径 Gets the reserved built-in path
- (NSString *)getEmbeddedBaseMakeupPath {
    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Makeup"];
    return file;
}

//创建美妆路径 Create a beauty path
- (void)createMakeupDirs {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *basePath = [self getEmbeddedBaseMakeupPath];
    NSString *composePath = [basePath stringByAppendingPathComponent:[self getMakeupPath:NvMakeupCategoryCompose]];
    NSString *variableComposePath = [basePath stringByAppendingPathComponent:[self getMakeupPath:NvMakeupCategoryVariableCompose]];
    NSString *customPath = [basePath stringByAppendingPathComponent:[self getMakeupPath:NvMakeupCategoryCustom]];
    
    NSArray *pathArr = @[basePath,composePath,customPath,variableComposePath];
    for (NSString *path in pathArr) {
        if (![manager fileExistsAtPath:path isDirectory:nil]) {
            [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

- (NSString *)getMakeupPath:(int)type {
    NSArray *arr = @[@"compose",@"variableCompose",@"custom"];
    return arr[(NSInteger)type];
}

- (NSString *)getPackagePath:(NSString *)dirPath uuid:(NSString *)uuid {
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:dirPath error:nil];
    NSString *packagePath ;
    for (NSString *path in dirArray) {
        if (([path.pathExtension isEqualToString:@"videofx"] ||
             [path.pathExtension isEqualToString:@"makeup"] ||
             [path.pathExtension isEqualToString:@"beauty"] ||
             [path.pathExtension isEqualToString:@"facemesh"] ||
             [path.pathExtension isEqualToString:@"warp"]) &&
            [path containsString:uuid]) {
            packagePath = [dirPath stringByAppendingPathComponent:path];
            break;
        }
    }
    return packagePath;
}

- (NSString *)getPackageUUIDWithVersionNum:(NSString *)path {
    return [path.lastPathComponent stringByDeletingPathExtension];
}

- (NSString *)getPackageUUID:(NSString *)path {
    NSArray *arr = [path.lastPathComponent componentsSeparatedByString:@"."];
    if (arr.count > 0) {
        return arr[0];
    }
    return [path.lastPathComponent stringByDeletingPathExtension];
}

#pragma mark - 根据参数把随机的颜色值转化成字符串并且赋值
/*
 根据参数把随机的颜色值转化成字符串并且赋值
 According to the parameters, the random color value is converted into a string and assigned
 
 @param model 美妆数据 makeup data
 */
- (void)setRandomLableColor:(NvMakeupCellModel *)model {
    model.labelColorStr = [NvUtils randomColorInColorArr:self.labelColorArr];
}

#pragma mark - 获取分类数据 Get classified data
- (void)getTagData:(void(^)(void))completeBlock {
    self.varialbeMakeupModel.displayName = NvLocalString(@"make up show", @"妆容");
    self.varialbeMakeupModel.displayNameZhCn = @"妆容";
    [self.kindArr addObject:self.varialbeMakeupModel];
    __weak typeof(self)weakSelf = self;
    [self getTagNetworkData:^{
        if (completeBlock) {
            completeBlock();
        }
    } failureBlock:^{
        
        if (weakSelf.kindArr.count == 1) {
            
            NSArray *enArr =  @[
                NvLocalString(@"brighten", @"高光"),
                NvLocalString(@"eyelash", @"睫毛"),
                NvLocalString(@"lip",@"口红"),
                NvLocalString(@"eyebrow",@"眉毛"),
                NvLocalString(@"blusher",@"腮红"),
                NvLocalString(@"shadow",@"修容"),
                NvLocalString(@"eyeliner",@"眼线"),
                NvLocalString(@"eyeshadow",@"眼影"),
                NvLocalString(@"eyeball",@"美瞳")];
            NSArray *zhcnArr =  @[@"高光",
                                  @"睫毛",
                                  @"口红",
                                  @"眉毛",
                                  @"腮红",
                                  @"修容",
                                  @"眼线",
                                  @"眼影",
                                  @"美瞳"];
            NSArray *kindsArr = @[@7,@4,@1,@3,@6,@8,@5,@2,@9];
            for (int i=0; i<enArr.count; i++) {
                NvMakeupLevelModel *model = [NvMakeupLevelModel new];
                model.displayName = enArr[i];
                model.displayNameZhCn = zhcnArr[i];
                model.kind = [kindsArr[i] integerValue];
                model.category = 2;
                model.materialType = 20;
                [weakSelf.kindArr addObject:model];
            }
        }
        if (completeBlock) {
            completeBlock();
        }
    }];
    //    }
}

- (void)getTagNetworkData:(void(^)(void))completeBlock failureBlock:(void(^)(void))failuerBlock {
    __weak typeof(self)weakSelf = self;
    int category = [self getArsceneKindCategory];
    [NvHttpRequest RequestMakeupKindListWithType:20 category:category sdkVersion:[NvSDKUtils getSDKVersion] page:0 pageSize:100 completionBlock:^(id respondData) {
        weakSelf.hasQueryKind = YES;
        NSArray *arr = (NSArray *)respondData;
        for(NSDictionary *item in arr){
            BOOL contain = NO;
            for (NvMakeupLevelModel *model in weakSelf.kindArr) {
                if ([model.displayName caseInsensitiveCompare: item[@"displayName"]] == NSOrderedSame ||
                    [model.displayNameZhCn caseInsensitiveCompare: item[@"displayNameZhCn"]] == NSOrderedSame) {
                    contain = YES;
                    break;
                }
            }
            if (contain) {
                continue;
            }
            
            NvMakeupLevelModel *model = [NvMakeupLevelModel new];
            model.displayName = item[@"displayName"];
            model.displayNameZhCn = item[@"displayNameZhCn"];
            model.materialType = [item[@"materialType"] integerValue];
            model.category = [item[@"category"] integerValue];
            model.kind = [item[@"id"] integerValue];
            [weakSelf.kindArr addObject:model];
        }
        BOOL containEyeBall = NO;
        for (NvMakeupLevelModel *item in weakSelf.kindArr) {
            if ([item.displayNameZhCn isEqualToString:@"美瞳"]) {
                containEyeBall = YES;
                break;
            }
        }
        if (!containEyeBall) {
            NvMakeupLevelModel *model = [NvMakeupLevelModel new];
            model.displayName = NvLocalString(@"eyeball",@"美瞳");
            model.displayNameZhCn = @"美瞳";
            model.materialType = 20;
            model.category = 2;
            model.kind = 9;
            [weakSelf.kindArr addObject:model];
        }
        
        if (completeBlock) {
            completeBlock();
        }
    } failureBlock:^(NSError *error) {
        if (failuerBlock) {
            failuerBlock();
        }
    }];
}

#pragma mark - 获取妆容（可变整妆）数据 Get makeup (variable makeup) data
- (void)getAllVariableMakeupData:(void(^)(void))completeBlock {
    [self addNoneItems:self.varialbeMakeupModel];
//    if (!self.hasNetwork) {
        /*-------------        variable makeup effects datas           -------------*/
        NSString *basePath = [self getBaseMakeupPath];
        [self getVariableMakeupData:basePath];
//    }else{
        [self getVariableMakeupNetworkData:^{
            if (completeBlock) {
                completeBlock();
            }
        }];
//    }

    //添加内置数据 Add built-in data
    NSString *embeddedPath = [self getEmbeddedBaseMakeupPath];
    [self getVariableMakeupData:embeddedPath];
    if (completeBlock) {
        completeBlock();
    }
}

- (void)getVariableMakeupData:(NSString *)basePath {
    /// 妆容测试包放置地址
    /// Location of makeup test pack
    NSString *varialbeMakeupPath = [basePath stringByAppendingPathComponent:@"variableCompose"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *arr = [fileManager contentsOfDirectoryAtPath:varialbeMakeupPath error:nil];
    NSMutableArray *effectDirs = [NSMutableArray array];
    for (NSString *displayName in arr) {
        NSLog(@"=======%@ ===== %@",displayName,varialbeMakeupPath);
        BOOL isDir = NO;
        BOOL isExist = [fileManager fileExistsAtPath:[varialbeMakeupPath stringByAppendingPathComponent:displayName] isDirectory:&isDir];
        if(isExist && isDir) {
            [effectDirs addObject:[varialbeMakeupPath stringByAppendingPathComponent:displayName]];
        }
    }
    for (NSString *dirPath in effectDirs) {
        NSString *jsonPath = [dirPath stringByAppendingPathComponent:@"info_new.json"];
        NSData *varialbeData = [[NSData alloc] initWithContentsOfFile:jsonPath];
        
        if(varialbeData) {
            NSDictionary *infoDic = [NSJSONSerialization JSONObjectWithData:varialbeData options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers|NSJSONReadingFragmentsAllowed|NSJSONReadingAllowFragments error:nil];
            NvMakeupCellModel *cellModel = [self translateCellInfo:infoDic dirPath:dirPath hasBGColor:YES];
            if (cellModel) {
                [self.varialbeMakeupModel.contents addObject:cellModel];
            }
        }else{
            jsonPath = [dirPath stringByAppendingPathComponent:@"info.json"];
            varialbeData = [[NSData alloc] initWithContentsOfFile:jsonPath];
            
            NSDictionary *infoDic = [NSJSONSerialization JSONObjectWithData:varialbeData options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers|NSJSONReadingFragmentsAllowed|NSJSONReadingAllowFragments error:nil];
            if (varialbeData){
                NvMakeupCellModel *cellModel = [self translateOldCellInfo:infoDic dirPath:dirPath hasBGColor:YES];
                if (cellModel) {
                    [self.varialbeMakeupModel.contents addObject:cellModel];
                }
            }
        }
    }

}

- (void)getVariableMakeupNetworkData:(void(^)(void))completeBlock {
    [self getVariableMakeupNetworkData:1 pageSize:10 completeBlock:^(int responsePageSize) {
        if (completeBlock) {
            completeBlock();
        }
    } failureBlock:^{
        [NvToast showInfoWithMessage:NvLocalString(@"CheckNetwork", @"请检查网络是否连接")];
    }];
}

- (void)getVariableMakeupNetworkData:(NSInteger)pageNum pageSize:(NSInteger)pageSize completeBlock:(void(^)(int responsePageSize))completeBlock failureBlock:(void(^)(void))failureBlock {
    __weak typeof(self)weakSelf = self;
    [self getMakeupNetworkAssets:21 category:[self getArsceneVariableCategory] kind:-1 ratioFlag:1 ratio:AspectRatio_All page:pageNum pageSize:pageSize completeBlock:^(NSDictionary *data) {
        NSArray *elements = data[@"elements"];
        for (NSDictionary *item in elements) {
            NvMakeupCellModel *cellModel = [self translateCellInfo:item[@"infoJson"] dirPath:item[@"zipUrl"] hasBGColor:YES];
            if (cellModel) {
                [weakSelf.varialbeMakeupModel.contents addObject:cellModel];
            }
            
        }
        if (elements.count > 0) {
            if (completeBlock) {
                completeBlock((int)elements.count);
            }
        }else{
            if (failureBlock) {
                failureBlock();
            }
        }
    } failureBlock:^(NSError *error) {
        if (failureBlock) {
            failureBlock();
        }
    }];
}

#pragma mark - 转换美妆妆容界面所需cellmodel，根据info_new.json转换
/// Convert beauty makeup interface required cellmodel, according to info_new.json conversion
- (NvMakeupCellModel *)translateCellInfo:(NSDictionary *)info dirPath:(NSString *)dirPath hasBGColor:(BOOL)hasBGColor {
    NvMakeupToolModel *effectModel = [NvMakeupToolModel yy_modelWithJSON:info];
    if (!effectModel) {
        return nil;
    }
    effectModel.packagePath = dirPath;
    effectModel.zipUrl = dirPath;
    NvMakeupCellModel *cellModel = [NvMakeupCellModel new];
    cellModel.coverImage = [dirPath containsString:@"http"] ? effectModel.cover : [dirPath stringByAppendingPathComponent:effectModel.cover];
    cellModel.hasBgColor = hasBGColor;
    cellModel.displayName = effectModel.translation[0].originalText;
    cellModel.displayNameZhCn = effectModel.translation[0].targetText;
    cellModel.makeup = effectModel;
    if (hasBGColor) {
        [self setRandomLableColor:cellModel];
    }
    NSString *downloadPath = [NvSDKUtils getAssetDownloadPath:ASSET_MAKEUP];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *assetPath = [downloadPath stringByAppendingPathComponent:[self getPackageUUIDWithVersionNum:dirPath]];
    if ([fileManager fileExistsAtPath:assetPath]) {
        cellModel.state = Finish;
    }
    return cellModel;
}

#pragma mark - 转换美妆妆容界面所需cellmodel，根据info.json转换
/// Convert beauty makeup interface required cellmodel, according to info.json conversion
- (NvMakeupCellModel *)translateOldCellInfo:(NSDictionary *)info dirPath:(NSString *)dirPath hasBGColor:(BOOL)hasBGColor {
    NvMakeupToolModel *effectModel = [NvMakeupToolModel yy_modelWithJSON:info];
    if (!effectModel) {
        return nil;
    }
    effectModel.packagePath = dirPath;
    
    NvMakeupToolEffectContentModel *newModel = [[NvMakeupToolEffectContentModel alloc] init];
    newModel.filter = effectModel.effectContent.filter;
    if (info[@"effectContent"]){
        NvMakeupEffectOldInfoModel *oldModel = [NvMakeupEffectOldInfoModel yy_modelWithJSON:info[@"effectContent"]];
        [self conversionNewData:newModel with:oldModel withPath:dirPath];
    }
    effectModel.effectContent = newModel;
    
    NvMakeupCellModel *cellModel = [NvMakeupCellModel new];
    cellModel.coverImage = [dirPath containsString:@"http"] ? effectModel.cover : [dirPath stringByAppendingPathComponent:effectModel.cover];
    cellModel.hasBgColor = hasBGColor;
    cellModel.displayName = effectModel.translation[0].originalText;
    cellModel.displayNameZhCn = effectModel.translation[0].targetText;
    cellModel.makeup = effectModel;
    if (hasBGColor) {
        [self setRandomLableColor:cellModel];
    }
    NSString *downloadPath = [NvSDKUtils getAssetDownloadPath:ASSET_MAKEUP];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *assetPath = [downloadPath stringByAppendingPathComponent:[self getPackageUUIDWithVersionNum:dirPath]];
    if ([fileManager fileExistsAtPath:assetPath]) {
        cellModel.state = Finish;
    }
    return cellModel;
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
                    NSLog(@"%@，%d",[dirPath stringByAppendingPathComponent:@"WhiteB.mslut"],filesPresent);
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

- (void)getMakeupNetworkAssets:(NSInteger)type category:(NSInteger)category kind:(NSInteger)kind ratioFlag:(NSInteger)ratioFlag ratio:(NSInteger)ratio page:(NSInteger)page pageSize:(NSInteger)pageSize completeBlock:(void(^)(NSDictionary *data))completeBlock failureBlock:(void(^)(NSError *error))failureBlock {
    [NvHttpRequest RequestVariableMakeupListWithType:type category:category kind:kind ratioFlag:ratioFlag ratio:ratio sdkVersion:[NvSDKUtils getSDKVersion] page:page pageSize:pageSize completionBlock:^(id respondData) {
        NSDictionary *dict = (NSDictionary *)respondData;
        NSDictionary *dataDic = dict[@"data"];
        if (completeBlock) {
            completeBlock(dataDic);
        }

    } failureBlock:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];

}

#pragma mark - 获取具体某一类单妆数据（如：口红） Obtain specific data of a single type of makeup (e.g., lipstick)
- (void)getDetailMakeupKindData:(NvMakeupLevelModel *)model completeBlock:(void(^)(void))completeBlock {
    NSString *customPath = [self getMakeupPath:NvMakeupCategoryCustom];
    [self getDetailMakeupKindNetworkData:model.materialType kind:model.kind page:1 pageSize:10 completeBlock:^(int responsePageSize) {
        if (completeBlock) {
            completeBlock();
        }
    } failureBlock:^{
        [NvToast showInfoWithMessage:NvLocalString(@"CheckNetwork", @"请检查网络是否连接")];
    }];
    
    NSString *embeddedBasePath = [self getEmbeddedBaseMakeupPath];
    NSString *path1 = [[embeddedBasePath stringByAppendingPathComponent:customPath] stringByAppendingPathComponent:model.displayName];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path1 isDirectory:nil]) {
        [manager createDirectoryAtPath:path1 withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        [self getDetailKindMakeupLocalData:model basePath:path1];
    }
    if (completeBlock) {
        completeBlock();
    }
}

#pragma mark - 获取本地沙盒下的单妆，放置单妆的时候，需要先创建单妆的文件夹（点击界面上具体的单妆分类，就会自动创建）
/// Obtain the single makeup under the local sandbox. When placing the single makeup, you need to create a folder of single makeup first (click the specific category of single makeup on the interface, it will be automatically created).
- (void)getDetailKindMakeupLocalData:(NvMakeupLevelModel *)model basePath:(NSString *)basePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *arr = [fileManager contentsOfDirectoryAtPath:basePath error:nil];
    NSMutableArray *effectDirs = [NSMutableArray array];
    for (NSString *displayName in arr) {
        BOOL isDir = NO;
        BOOL isExist = [fileManager fileExistsAtPath:[basePath stringByAppendingPathComponent:displayName] isDirectory:&isDir];
        if(isExist && isDir) {
            [effectDirs addObject:[basePath stringByAppendingPathComponent:displayName]];
        }
    }
     
    for (NSString *dirPath in effectDirs) {
        NSString *jsonFile = [dirPath stringByAppendingPathComponent:@"info.json"];
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:jsonFile]) {
            NSLog(@"%@ file is not exist!",jsonFile);
            return;
        }
        NvMakeupCellModel *cellModel = [NvMakeupCellModel new];
        NSData *data = [[NSData alloc] initWithContentsOfFile:jsonFile];
        NSDictionary *makeupDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers|NSJSONReadingFragmentsAllowed|NSJSONReadingAllowFragments error:nil];
        
        
        
        NvMakeupContentModel *contentModel = [NvMakeupContentModel yy_modelWithJSON:makeupDic];
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:dirPath error:nil];
        for (NSString *content in contents) {
            NSLog(@"=======%@ ",content);
            if ([content.pathExtension isEqualToString:@"makeup"]) {
                NSString *makeupFile = [dirPath stringByAppendingPathComponent:content];
                contentModel.uuid = [self getPackageUUID:makeupFile];
                NSString * licensePath = [NSString convertFilePathToNewPath:makeupFile WithExtension:@"lic"];
                [NvSDKUtils installAssetPackage:makeupFile license:licensePath assetType:NvsAssetPackageType_Makeup];
                
            }else if([content.pathExtension isEqualToString:@"png"] || [content.pathExtension isEqualToString:@"PNG"] || [content.pathExtension isEqualToString:@"JPG"] || [content.pathExtension isEqualToString:@"jpg"]) {
                cellModel.coverImage = [dirPath stringByAppendingPathComponent:content];
            }
        }
        
        NvMakeupTranslationModel *translation = contentModel.translation[0];
        cellModel.displayName = translation.originalText;
        cellModel.displayNameZhCn = translation.targetText;
        
        NvMakeupEffectContentModel *makeupM = [NvMakeupEffectContentModel yy_modelWithDictionary:makeupDic];
        makeupM.uuid = contentModel.uuid;
        makeupM.packagePath = contentModel.zipUrl;
        [contentModel.effectContent.makeup addObject:makeupM];
       
        cellModel.makeup = contentModel;
        cellModel.level = 1;
        cellModel.selected = NO;
        cellModel.state = Finish;
        [model.contents addObject:cellModel];
    }
    [self addNoneItems:model];
    
    
}

#pragma mark - 网络请求每个分类下的单妆
/// The network requests single makeup under each category
- (void)getDetailMakeupKindNetworkData:(NSInteger)type kind:(NSInteger)kind page:(NSInteger)page pageSize:(NSInteger)pageSize completeBlock:(void(^)(int responsePageSize))completeBlock failureBlock:(void(^)(void))failureBlock {
    __weak typeof(self)weakSelf = self;
    [self getMakeupNetworkAssets:20 category:[self getArsceneKindCategory] kind:kind ratioFlag:1 ratio:AspectRatio_All page:page pageSize:pageSize completeBlock:^(NSDictionary *data) {
        //具体的单妆 Specific single makeup
        NSArray *elements = data[@"elements"];
        NvMakeupLevelModel *model;
        for (NvMakeupLevelModel *tmpModel in self.kindArr) {
            if (tmpModel.kind == kind) {
                model = tmpModel;
                break;
            }
        }
        if (!model.contents) {
            model.contents = [NSMutableArray array];
        }
        for (NSDictionary *item in elements) {
            
            NvMakeupCellModel *cellModel = [NvMakeupCellModel new];
            NvMakeupContentModel *contentModel = [NvMakeupContentModel yy_modelWithDictionary:item];
            NSDictionary *infoDic = [item ex_dictionaryForKey:@"infoJson"];
            NvMakeupEffectContentModel *makeupM = [NvMakeupEffectContentModel yy_modelWithDictionary:infoDic];
            makeupM.uuid = contentModel.uuid;
            makeupM.packagePath = contentModel.zipUrl;
            [contentModel.effectContent.makeup addObject:makeupM];
            
            cellModel.coverImage = contentModel.coverImage;
            cellModel.displayName = contentModel.displayName;
            cellModel.displayNameZhCn = contentModel.displayNameZhCn;
            cellModel.level = 1;
            cellModel.selected = NO;
            cellModel.makeup = contentModel;
            
            NSString *downloadPath = [NvSDKUtils getAssetDownloadPath:ASSET_MAKEUP];
            NSString *assetPath = [downloadPath stringByAppendingPathComponent:contentModel.zipUrl.lastPathComponent.stringByDeletingPathExtension];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:assetPath] && contentModel.zipUrl.length > 0) {
                cellModel.state = Finish;
            }
            [model.contents addObject:cellModel];
        }
        [weakSelf addNoneItems:model];
        if(elements.count > 0) {
            if (completeBlock) {
                completeBlock((int)elements.count);
            }
        }else {
            if (failureBlock) {
                failureBlock();
            }
        }
        
    } failureBlock:^(NSError *error) {
        if (failureBlock) {
            failureBlock();
        }
    }];
}

- (void)addNoneItems:(NvMakeupLevelModel *)makeupModel {
    BOOL hasNone = NO;
    for (NvMakeupCellModel *model in makeupModel.contents) {
        if ([model.displayName containsString:NvLocalString(@"None", @"无")]) {
            hasNone = YES;
            break;
        }
    }
    
    if (!hasNone) {
        if (makeupModel == self.varialbeMakeupModel) {
            NvMakeupCellModel *noneModel = [NvMakeupCellModel new];
            noneModel.displayName = NvLocalString(@"None", @"无");
            noneModel.displayNameZhCn = self.functionMode == NvMakeupFunctionModeEdit ? @"原图" : @"无";
            NSString *coverImg = self.functionMode == NvMakeupFunctionModeEdit ? @"edit_makeup_none" : @"capture_beauty_none";
            noneModel.coverImage = coverImg;
            noneModel.labelColorStr = @"#DBD8DAFF";
            noneModel.selected = YES;
            noneModel.state = Finish;
            [makeupModel.contents insertObject:noneModel atIndex:0];
        } else {
            //单妆 monomakeup
            if (makeupModel.contents.count > 0) {
                NvMakeupContentModel *lastModel = (NvMakeupContentModel *)makeupModel.contents.lastObject.makeup;
                NvMakeupCellModel *noneModel = [NvMakeupCellModel new];
                noneModel.displayName = NvLocalString(@"None", @"无");
                noneModel.displayNameZhCn = @"无";
                noneModel.level = 1;
                noneModel.state = Finish;
                NSString *coverImg = self.functionMode == NvMakeupFunctionModeEdit ? @"edit_makeup_none" : @"capture_beauty_none";
                noneModel.coverImage = coverImg;
                noneModel.selected = YES;
                NSMutableArray <NvMakeupEffectContentModel *>*makeupArr = lastModel.effectContent.makeup;
                if (makeupArr.count > 0 && makeupArr[0].makeupId.length > 0) {
                    NvMakeupEffectModel *effectContent = [NvMakeupEffectModel new];
                    effectContent.makeupId = makeupArr[0].makeupId;
                    NvMakeupContentModel *contentModel = [NvMakeupContentModel new];
                    contentModel.effectContent = effectContent;
                    noneModel.makeup = contentModel;
                }
                [makeupModel.contents insertObject:noneModel atIndex:0];
            }
        }
    }
}

#pragma mark - 下载美妆包，美妆的单妆和妆容都是走这里
/// Download the Beauty Pack. Beauty's single makeup and makeup go here
- (void)downloadMakeupPackage:(NvMakeupToolModel *)contentModel variable:(BOOL)isVariable completeBlock:(void(^)(NvMakeupToolModel *contentModel, NSString * __nullable downloadPath, BOOL isVariable))completeBlock {
    /*
     下载过的素材不再进行下载
     可变整妆所有素材以及该效果对应json 文件等都在一个zip 包里，需要下载下来进行解压操作
     
     The downloaded material will not be downloaded
     All the material and the corresponding json file of the effect are in a zip package, which needs to be downloaded and decompressed
     */
    
    //可变整妆 Variable makeup
    
    NSString *downloadPath = [NvSDKUtils getAssetDownloadPath:ASSET_MAKEUP];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *assetPath = [downloadPath stringByAppendingPathComponent:[self getPackageUUIDWithVersionNum:contentModel.zipUrl]];
    NSString * packageFileName = contentModel.packageFileName.lastPathComponent;
    NSString * packagePath = assetPath;
    if(packageFileName.nv_isNotEmpty && ![packageFileName.pathExtension isEqualToString:@"zip"]){
        
        packagePath = [assetPath stringByAppendingPathComponent:packageFileName];
    }
    
    if(!isVariable){
        
        contentModel.packagePath = packagePath;
    }
    if ([contentModel.zipUrl containsString:@"http"]) {
        
        if (![fileManager fileExistsAtPath:assetPath]) {
            
            dispatch_async(self.queue, ^{
                NvHttpRequest *request = [NvHttpRequest sharedInstance];
                [request downloadAsset:contentModel.zipUrl destFileDir:downloadPath downloadID:contentModel.zipUrl.lastPathComponent progressBlock:^(int32_t progress) {
                    
                } completeBlock:^(NSString *downloadFilePath) {
                    NSError *err = NSError.new;
                    NSString *downloadPath = [downloadFilePath stringByReplacingOccurrencesOfString:@"file:" withString:@""];
                    NSString *unzipPath = [downloadPath stringByDeletingPathExtension];
                    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:unzipPath isDirectory:nil];
                    if (!exist) {
                        [[NSFileManager defaultManager] createDirectoryAtPath:unzipPath withIntermediateDirectories:YES attributes:nil error:nil];
                    }
                    
                    [SSZipArchive unzipFileAtPath:downloadPath
                                    toDestination:unzipPath
                               preserveAttributes:NO
                                        overwrite:YES
                                   nestedZipLevel:1
                                         password:nil
                                            error:&err
                                         delegate:nil
                                  progressHandler:nil
                                completionHandler:nil];
                    if (err.code == 0) {
                        [[NSFileManager defaultManager] removeItemAtPath:downloadPath error:nil];
                        NSLog(@"unzip files success！！！");
                        if(isVariable){
                            
                            contentModel.packagePath = unzipPath;
                            completeBlock(contentModel,nil,isVariable);
                        }else{
                            
                            completeBlock(contentModel,packagePath,isVariable);
                        }
                    } else {
                        NSLog(@"unzip files failed！！！");
                    }
                } failureBlock:^(NSError *error, NSString *downloadFilePath) {
                    [NvToast showInfoWithMessage:NvLocalString(@"CheckNetwork", @"请检查网络是否连接")];
                }];
            });
        }else{
            
            if (completeBlock) {
                
                if(isVariable){
                    
                    contentModel.packagePath = assetPath;
                    completeBlock(contentModel,nil,isVariable);
                }else{
                    
                    completeBlock(contentModel,packagePath,isVariable);
                }
            }
        }
    }else{
        
        if (completeBlock) {
            
            if(isVariable){
                
                completeBlock(contentModel,nil,isVariable);
            }else{
                
                completeBlock(contentModel,packagePath,isVariable);
            }
        }
    }
}

- (void)processMakeupPackage:(NvMakeupToolModel *)makeupModel downloadPath:(NSString *)downloadPath variable:(BOOL)isVariable completeBlock:(void(^)(void))completeBlock {
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(self.queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([makeupModel.packagePath.lastPathComponent containsString:@"."] && makeupModel.packagePath.length > 0 && downloadPath.length > 0 && !isVariable){
                
                NSString * fullPath = [downloadPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                NSString * licensePath = [NSString convertFilePathToNewPath:fullPath WithExtension:@"lic"];
                [NvSDKUtils installAssetPackage:fullPath license:licensePath assetType:NvsAssetPackageType_Makeup];
            }
            if (!isVariable) {
                [weakSelf applyMakeupPackage:makeupModel completeBlock:^{
                    if (completeBlock) {
                        completeBlock();
                    }
                }];
            }
            
        });
    });
}

- (void)applyMakeupPackage:(NvMakeupToolModel *)effectModel {
//    [self processTotalEffectContentWithModel:effectModel];
}

- (void)applyMakeupPackage:(NvMakeupToolModel *)effectModel completeBlock:(void(^)(void))completeBlock {
//    [self processTotalEffectContentWithModel:effectModel];
    if (completeBlock) {
        completeBlock();
    }
}

- (void)downloadAndProcessMakeupPackage:(NvMakeupToolModel *)contentModel variable:(BOOL)isVariable completeBlock:(void(^)(void))completeBlock {
    __weak typeof(self)weakSelf = self;
    [self downloadMakeupPackage:contentModel variable:isVariable completeBlock:^(NvMakeupToolModel * _Nonnull contentModel, NSString * __nullable downloadPath, BOOL isVariable) {
        //整包
        if(isVariable){
            
            if (completeBlock) completeBlock();
        }else{
            
            [weakSelf processMakeupPackage:contentModel downloadPath:downloadPath variable:isVariable completeBlock:^{
                
                if (completeBlock) completeBlock();
            }];
        }
    }];
}

#pragma mark - lazyload
- (dispatch_queue_t)queue
{
    if (_queue == nil) {
        _queue = dispatch_queue_create("dispatch_queue_makeup", DISPATCH_QUEUE_CONCURRENT);
    }
    return _queue;
}
@end
