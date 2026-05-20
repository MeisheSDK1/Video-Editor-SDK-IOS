//
//  NvFilterDataSource.m
//  SDKDemo
//
//  Created by 美摄 on 2019/8/29.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvFilterDataSource.h"
#import "NvCaptureFilterModel.h"
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import <NvSDKCommon/NvUtils.h>
#import "NVDefineConfig.h"

@interface NvFilterDataSource ()

@property (nonatomic, assign) AspectRatio ratio;

@property (nonatomic, strong) NvCaptureFilterModel* selectedModel;

@property (nonatomic, strong) NSArray *colorArr;

/// 是否需要带默认内建滤镜数据 Whether the default built-in filter data is required
@property (nonatomic, assign) BOOL builtinFilter;
@end

@implementation NvFilterDataSource

-(instancetype)initWithAspectRatio:(AspectRatio)ratio{
    self = [super init];
    if (self) {
        [self setupFilterDataWithAspectRatio:ratio];
        self.colorArr = @[@"#CFC1FFFF",@"#C1DEFFFF",@"#FFC1C1FF",@"#C1CBFFFF"];
    }
    return self;
}

-(instancetype)initWithBuiltinFilterAndAspectRatio:(AspectRatio)ratio{
    self = [super init];
    if (self) {
        self.builtinFilter = YES;
        [self setupFilterDataWithAspectRatio:ratio];
        self.colorArr = @[@"#CFC1FFFF",@"#C1DEFFFF",@"#FFC1C1FF",@"#C1CBFFFF"];
    }
    return self;
}

#pragma mark - 刷新数据
/*
 刷新数据
 reloadData
 */
-(void)reloadData{
    [self setupFilterDataWithAspectRatio:self.ratio];
}

#pragma mark - 刷新选中的数据
/*
 刷新选中的数据
 Refresh selected data
 
 @param model 选中的数据
 selected data
 */
- (void)refreshSelectedModel:(NvBaseModel *)model {
    for (NvCaptureFilterModel *models in _filterDataSource) {
        models.selected = NO;
    }
    self.selectedModel = (NvCaptureFilterModel *)model;
}

-(void)setupFilterDataWithAspectRatio:(AspectRatio)ratio{
    self.ratio = ratio;
    self.cartoonFilterDataSource = [NSMutableArray array];
    
    NSArray *videoFxArray = @[@"NvsFilterNone",@"NvCaptureCartoon1",@"NvCaptureCartoon2",@"NvCaptureCartoon3"];
    NSArray *videoFxDisplayArray = @[NvLocalString(@"None", @"无"), NvLocalString(@"The comic book", @"漫画书"),NvLocalString(@"Ink painting", @"水墨"), NvLocalString(@"Single", @"单色漫画")];
    for (int i = 0; i<videoFxArray.count; i++) {
        NvCaptureFilterModel *model = [[NvCaptureFilterModel alloc]init];
        model.selected = NO;
        model.displayName = videoFxDisplayArray[i];
        if (i == 0) {
            model.bgColorStr = @"#C4C4C4FF";
            model.labelColorStr = @"#FFFFFF32";
            model.coverName = videoFxArray[i];
        }else if(i >= 1 && i <= 3){
            model.value = 1.0;
            model.labelColorStr = [NvUtils randomColorInColorArr:self.colorArr];
            model.builtinName = @"Cartoon";
            model.coverName = [videoFxArray[i] stringByAppendingString:@".jpg"];
            if (i == 1) {
                model.strokeOnly = NO;
                model.grayscale = NO;
            }else if (i == 2){
                model.strokeOnly = YES;
                model.grayscale = NO;
            }else if (i == 3){
                model.strokeOnly = NO;
                model.grayscale = YES;
            }
        }
        if (i == 0 && !self.selectedModel) {
            model.selected = YES;
        }
        if (self.selectedModel && [model.builtinName isEqualToString:self.selectedModel.builtinName]) {
            if (model.grayscale == self.selectedModel.grayscale && model.strokeOnly == self.selectedModel.strokeOnly) {
                model.selected = YES;
            }
        }
        [self.cartoonFilterDataSource addObject:model];
    }
    NvAssetManager *assetManager = [NvAssetManager sharedInstance];
    self.filterDataSource = [NSMutableArray array];
    NSArray *array = [assetManager getUsableAssets:ASSET_FILTER aspectRatio:ratio categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    if (self.builtinFilter) {
        [self addBuiltinAssetNameFilter];
    }
    for (NvAsset *asset in array) {
        if ([self isFilterExist:asset.uuid]){
            continue;
        }
        NvCaptureFilterModel *filter = [[NvCaptureFilterModel alloc]init];
        if ([asset isReserved]) {
            [self initReservedAssetName:asset];
            if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
                filter.displayName = asset.displayNamezhCN;
                    }else{
                        filter.displayName = asset.displayName;
                    }
            filter.labelColorStr = [NvUtils randomColorInColorArr:self.colorArr];
            filter.coverName = asset.coverUrl;
            filter.size = [NvSDKUtils getAssetPackageSizeString:asset.packageSize];
            filter.draw = [NvSDKUtils getAssetAspectRatioString:asset.aspectRatio];
            filter.packageId = asset.uuid;
            filter.kindId = asset.kind;
            filter.packagePath = asset.bundledLocalDirPath ;
            filter.isAdjusted = asset.isAdjusted;
            if (self.selectedModel && [filter.packageId isEqualToString:self.selectedModel.packageId]) {
                filter.selected = YES;
            }
            if ([asset.uuid isEqualToString:DEFAULT_FILTER] && DEFAULT_FILTER.length > 0) {
                filter.value = 0.6;
                [_filterDataSource insertObject:filter atIndex:0];
            }else{
                filter.value = 1.0;
                [_filterDataSource addObject:filter];
            }
            
        }else if(![asset isReserved]){
            filter.value = 1.0;
            if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
                filter.displayName = asset.displayNamezhCN;
                    }else{
                        filter.displayName = asset.displayName;
                    }
            filter.labelColorStr = [NvUtils randomColorInColorArr:self.colorArr];
            filter.coverName = asset.coverUrl;
            filter.size = [NvSDKUtils getAssetPackageSizeString:asset.packageSize];
            filter.draw = [NvSDKUtils getAssetAspectRatioString:asset.aspectRatio];
            filter.packageId = asset.uuid;
            filter.packagePath = asset.localDirPath;
            filter.isAdjusted = asset.isAdjusted;
            filter.categoryId = asset.category;
            filter.kindId = asset.kind;
            if (self.selectedModel && [filter.packageId isEqualToString:self.selectedModel.packageId]) {
                filter.selected = YES;
            }
            [_filterDataSource insertObject:filter atIndex:0];
        }
    }
}

- (void)addBuiltinAssetNameFilter{
    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"builtinFilter"];
    NSArray *array = @[@"Sage",@"Maid",@"Mace",@"Lace",@"Mall",@"Sap",@"Sara",@"Pinky",@"Sweet",@"Fresh"];
    for (int i = 0; i < array.count; i++) {
        NSString *string = array[i];
        NSString *coverName = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",string]];
        if ([self isBuiltinFilterExist:string]){
            continue;
        }
        NvCaptureFilterModel *filter = [[NvCaptureFilterModel alloc]init];
        filter.displayName = [self builtinAssetName:string];
        filter.labelColorStr = [NvUtils randomColorInColorArr:self.colorArr];
        filter.coverName = coverName;
        filter.size = 0;
        filter.draw = @"通用";
        filter.packageId = nil;
        filter.packagePath = nil;
        filter.builtinName = string;
        if (self.selectedModel && [filter.builtinName isEqualToString:self.selectedModel.builtinName]) {
            filter.selected = YES;
        }
        filter.value = 1.0;
        [_filterDataSource addObject:filter];
    }
}

-(void)updateSelectedModelWithModel:(NvBaseModel*)model{
    if ([model isKindOfClass:[NvTimeFilterInfoModel class]]) {
           NvTimeFilterInfoModel* filterInfo = (NvTimeFilterInfoModel*)model;
        for (NvCaptureFilterModel *filterModel in self.filterDataSource) {
            filterModel.selected = NO;
        }
        for (NvCaptureFilterModel *filterModel in self.cartoonFilterDataSource) {
            filterModel.selected = NO;
        }
           for (NvCaptureFilterModel *filterModel in self.filterDataSource) {
               if ([filterInfo.name isEqualToString:filterModel.packageId]) {
                   if (filterModel.grayscale == filterInfo.grayscale && filterModel.strokeOnly == filterInfo.strokeOnly) {
                       filterModel.selected = YES;
                       self.selectedModel = filterModel;
                       break;
                   }
               }else{
                   if ([filterInfo.name isEqualToString:filterModel.packageId]) {
                       filterModel.selected = YES;
                       self.selectedModel = filterModel;
                       break;
                   }
               }
           }
        for (NvCaptureFilterModel *filterModel in self.cartoonFilterDataSource) {
            if ([filterInfo.name isEqualToString:filterModel.builtinName]) {
                if (filterModel.grayscale == filterInfo.grayscale && filterModel.strokeOnly == filterInfo.strokeOnly) {
                    filterModel.selected = YES;
                    self.selectedModel = filterModel;
                    break;
                }
            }else{
                if ([filterInfo.name isEqualToString:filterModel.packageId]) {
                    filterModel.selected = YES;
                    self.selectedModel = filterModel;
                    break;
                }
            }
        }
    }
}

#pragma mark - 判断素材PackageId是否相等
/*
 判断素材PackageId是否相等
 Determine whether the material PackageId are equal
 
 @param uuid 素材PackageId
 source material PackageId
 
 return 返回BOOL值。YES表示相同，NO表示不同。
 Returns the bool value. Yes means the same, no means different.。
 */
- (BOOL)isFilterExist:(NSString *)uuid {
    for (NvCaptureFilterModel *item in _filterDataSource) {
        if ([item.packageId isEqualToString:uuid])
            return YES;
    }
    return NO;
}

- (BOOL)isBuiltinFilterExist:(NSString *)builtin {
    for (NvCaptureFilterModel *item in _filterDataSource) {
        if ([item.builtinName isEqualToString:builtin])
            return YES;
    }
    return NO;
}

- (NSInteger)numberOfSections{
    return 2;
}
-(NSArray*)titlesForSections{
    return @[NvLocalString(@"Cartoon Filter", @"漫画滤镜"),NvLocalString(@"Filter", @"滤镜")];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return self.cartoonFilterDataSource.count;
    }
    return self.filterDataSource.count;
}
-(NvBaseModel*)modelForIndexPath:(NSIndexPath *)indexPath{
    NSArray* dataArray = self.filterDataSource;
    if (indexPath.section == 0) {
        dataArray = self.cartoonFilterDataSource;
    }
    if (indexPath.row<dataArray.count) {
        return [dataArray objectAtIndex:indexPath.row];
    }
    return nil;
}

-(void)didselectModelAtIndexPath:(NSIndexPath *)indexPath{
    for (NvBaseModel* bModel in self.filterDataSource) {
        bModel.selected = NO;
    }
    for (NvBaseModel* bModel in self.cartoonFilterDataSource) {
        bModel.selected = NO;
    }
    NvCaptureFilterModel* model = (NvCaptureFilterModel*)[self modelForIndexPath:indexPath];
    model.selected = YES;
    self.selectedModel = model;
}

#pragma mark - 给素材配置显示的名称
/*
 给素材配置显示的名称
 Configure the name of the display for the material
 
 @param asset 素材
 source material
 */
- (void)initReservedAssetName:(NvAsset *)asset {
    if ([asset isReserved]) {
        if ([asset.uuid isEqualToString:@"0FBCC8A1-C16E-4FEB-BBDE-D04B91D98A40"]) {
            asset.displayName = NvLocalString(@"Fair",@"白皙");
        }
        if ([asset.uuid isEqualToString:@"6439CF7E-42D5-4239-8187-358323292FF4"]) {
            asset.displayName = NvLocalString(@"Ice Cream",@"冰激凌");
        }
        if ([asset.uuid isEqualToString:@"FAE50247-F14C-40CE-AD43-29CA3E604838"]) {
            asset.displayName = NvLocalString(@"Morning Sunlight LUT",@"晨曦");
        }
        if ([asset.uuid isEqualToString:@"BD9D5DA9-581E-4B80-95D4-218D95FC78F2"]) {
            asset.displayName = NvLocalString(@"Wind Whispers",@"风语");
        }
        if ([asset.uuid isEqualToString:@"394EB525-1B7A-4AA1-BBAD-3FD75527A60C"]) {
            asset.displayName = NvLocalString(@"B&W 2",@"黑白");
        }
        if ([asset.uuid isEqualToString:@"D1C01CF7-CA73-4CB7-A6B7-630B5FF9EC74"]) {
            asset.displayName = NvLocalString(@"ziran",@"自然");
        }
        if ([asset.uuid isEqualToString:@"12FCD2E7-1F80-4DFC-A8FD-C820CF754855"]) {
            asset.displayName = NvLocalString(@"ins Reyes LUT",@"雷耶斯");
        }
        if ([asset.uuid isEqualToString:@"D65436B7-D19F-47E0-9A2A-28CECC73D4F2"]) {
            asset.displayName = NvLocalString(@"Honey peach",@"蜜桃");
        }
        if ([asset.uuid isEqualToString:@"B7F1F498-B310-4E2D-9A75-7D8AFBBC71D8"]) {
            asset.displayName = NvLocalString(@"Chelsea LUT",@"切尔西");
        }
        if ([asset.uuid isEqualToString:@"C9CE10F1-7C77-423C-BB7F-7F090C33D5C5"]) {
            asset.displayName = NvLocalString(@"Youth",@"青春");
        }
        if ([asset.uuid isEqualToString:@"F7204261-41D8-454A-99DC-3522444739EB"]) {
            asset.displayName = NvLocalString(@"ins Jaipur",@"斋普尔");
        }
        if ([asset.uuid isEqualToString:@"E1202F90-F2C8-4A14-BFCB-8F62BBD72F56"]) {
            asset.displayName = NvLocalString(@"Tsukiji",@"筑地");
        }
    }
}

- (NSString *)builtinAssetName:(NSString *)string{
    NSString *name = @"";
    if ([string isEqualToString:@"Sage"]) {
        name = NSLocalizedStringFromTableInBundle(@"Sage",@"明快",[NSBundle bundleForClass:self.class],nil);
    }else if ([string isEqualToString:@"Maid"]) {
        name = NSLocalizedStringFromTableInBundle(@"Maid",@"少女时代",[NSBundle bundleForClass:self.class],nil);
    }else if ([string isEqualToString:@"Mace"]) {
        name = NSLocalizedStringFromTableInBundle(@"Mace",@"锐利",[NSBundle bundleForClass:self.class],nil);
    }else if ([string isEqualToString:@"Lace"]) {
        name = NSLocalizedStringFromTableInBundle(@"Lace",@"蕾丝",[NSBundle bundleForClass:self.class],nil);
    }else if ([string isEqualToString:@"Mall"]) {
        name = NSLocalizedStringFromTableInBundle(@"Mall",@"时尚",[NSBundle bundleForClass:self.class],nil);
    }else if ([string isEqualToString:@"Sap"]) {
        name = NSLocalizedStringFromTableInBundle(@"Sap",@"元气",[NSBundle bundleForClass:self.class],nil);
    }else if ([string isEqualToString:@"Sara"]) {
        name = NSLocalizedStringFromTableInBundle(@"Sara",@"调皮",[NSBundle bundleForClass:self.class],nil);
    }else if ([string isEqualToString:@"Pinky"]) {
        name = NSLocalizedStringFromTableInBundle(@"Pinky",@"草莓薄荷",[NSBundle bundleForClass:self.class],nil);
    }else if ([string isEqualToString:@"Sweet"]) {
        name = NSLocalizedStringFromTableInBundle(@"Sweet",@"粉嫩",[NSBundle bundleForClass:self.class],nil);
    }else if ([string isEqualToString:@"Fresh"]) {
        name = NSLocalizedStringFromTableInBundle(@"Fresh",@"清爽",[NSBundle bundleForClass:self.class],nil);
    }
    
    return name;
}

@end
