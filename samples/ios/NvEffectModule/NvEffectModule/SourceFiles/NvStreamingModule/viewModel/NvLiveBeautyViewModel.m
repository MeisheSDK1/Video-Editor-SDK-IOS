//
//  NvLiveBeautyViewModel.m
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/11.
//

#import "NvLiveBeautyViewModel.h"
#import "YYModel.h"
#import "NvLiveBeautyTypeModel.h"
#import "NvLiveSwitchView.h"
#import "NvLiveBeautyTypeCollectionCell.h"
#import "NvLiveARSeceneCaptureFilterCell.h"
#import "NvLiveCaptureModularVM.h"
#import "NvLiveStreamingModule.h"

@implementation NvLiveBeautyViewModel

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.captureModularVM = [[NvLiveCaptureModularVM alloc]init];
        [self.captureModularVM creatFaceFx];
        [self.captureModularVM creatFxSharpen];
        [self.captureModularVM creatFxDefinition];
        [self setupData];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationChangeBeauty:) name:@"changeBeauty" object:nil];
    }
    return self;
}

- (void)configBeautyView:(NvLiveBeautyView *)beautyView {
    beautyView.delegate = self;
    for (NvLiveBeautyTypeModel *model in self.beautyEffectArray) {
        model.selected = NO;
    }
    for (NvLiveBeautyTypeModel *model in self.beautyShapeArray) {
        model.selected = NO;
    }
    for (NvLiveBeautyTypeModel *model in self.beautyMicroArray) {
        model.selected = NO;
    }

    [beautyView configBeautyArray:self.beautyEffectArray];
    [beautyView configBeautyByteArray:self.beautyShapeArray];
    [beautyView configBeautyTypeMicroArray:self.beautyMicroArray];
    
    [beautyView switchSelectState:beautyView.beautySwitch selected:NO];
    [beautyView switchSelectState:beautyView.beautyTypeSwitch selected:NO];
    [beautyView switchSelectState:beautyView.beautyTypeMicroSwitch selected:NO];

    beautyView.hiddenInteger = 0;
}

#pragma mark - 初始化数据
- (void)setupData {
    [self setupBeautyEffectArrayData];
    [self setupBeautyShapeArrayData];
    [self setupBeautyMicroArrayData];
}

#pragma mark - 初始化美颜数据
//Initialize the beauty data
- (void)setupBeautyEffectArrayData {
    self.beautyEffectArray = [NSMutableArray array];
    NSString *bundlePath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"beautyJson.bundle"];
    NSString *jsonPath = [bundlePath stringByAppendingPathComponent:@"beautyEffect.json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    if (!data) {
        NSLog(@"beautyEffect.json path error");
    }
    NSArray *array = [NSArray yy_modelArrayWithClass:NvLiveBeautyTypeModel.class json:data];
    [self.beautyEffectArray addObjectsFromArray:array];

    for (NvLiveBeautyTypeModel *model in self.beautyEffectArray) {
        model.isBeauty = YES;
        model.isOperation = YES;
    }
}

#pragma mark - 初始化美型数据
//Initialize the beauty data
- (void)setupBeautyShapeArrayData {
    self.beautyShapeArray = [NSMutableArray array];
    NSString *jsonPath = [[[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"beautyJson.bundle"] stringByAppendingPathComponent:@"beautyShape.json"];
    NSString *beautyShapeDataPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"beautyShapeData.bundle"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    if (!data) {
        NSLog(@"beautyShapeData.json path error");
    }
    NSArray *array = [NSArray yy_modelArrayWithClass:NvLiveBeautyTypeModel.class json:data];
    [self.beautyShapeArray addObjectsFromArray:array];
    for (NvLiveBeautyTypeModel *model in self.beautyShapeArray) {
        model.type = 1;
        if (model.packageUrl && model.packageUrl.length > 0) {
            model.packageUrl = [beautyShapeDataPath stringByAppendingPathComponent:model.packageUrl];
            NSString *packageId = [NvLiveStreamingModule getAssetPackageIdFromAssetPackageFilePath:model.packageUrl];
            if (model.licUrl.length > 0) {
                model.licUrl = [beautyShapeDataPath stringByAppendingPathComponent:model.licUrl];
            } else {
                if (packageId.length > 0) {
                    NSString *licPath = [[beautyShapeDataPath stringByAppendingPathComponent:packageId] stringByAppendingString:@".lic"];
                    model.licUrl = licPath;
                }
            }

            if ([model.packageUrl containsString:@"warp"]) {
                NSMutableString *mutString = [NSMutableString string];
                NvsAssetPackageManagerError error = [self.captureModularVM installAssetPackage:model.packageUrl license:model.licUrl type:NvsAssetPackageType_Warp assetPackageId:mutString];
                if (error == NvsAssetPackageManagerError_NoError) {
                    model.uuid = mutString;
                }
            } else {
                NSMutableString *mutString = [NSMutableString string];
                NvsAssetPackageManagerError error = [self.captureModularVM installAssetPackage:model.packageUrl license:model.licUrl type:NvsAssetPackageType_FaceMesh assetPackageId:mutString];
                if (error == NvsAssetPackageManagerError_NoError) {
                    model.uuid = mutString;
                }
            }
        }
        model.defaultShapePackage = model.uuid;
        model.isBeauty = NO;
        model.isOperation = YES;
    }
}

#pragma mark - 初始化微整形数据
//Initialize the microshaping data
- (void)setupBeautyMicroArrayData {
    self.beautyMicroArray = [NSMutableArray array];
    NSString *jsonPath = [[[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"beautyJson.bundle"] stringByAppendingPathComponent:@"beautyMicro.json"];
    NSString *beautyShapeDataPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"beautyShapeData.bundle"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    if (!data) {
        NSLog(@"beautyShapeData.json path error");
    }
    NSArray *array = [NSArray yy_modelArrayWithClass:NvLiveBeautyTypeModel.class json:data];
    [self.beautyMicroArray addObjectsFromArray:array];
    for (NvLiveBeautyTypeModel *model in self.beautyMicroArray) {
        model.type = 2;
        if (model.packageUrl && model.packageUrl.length > 0) {
            model.packageUrl = [beautyShapeDataPath stringByAppendingPathComponent:model.packageUrl];
            NSString *packageId = [NvLiveStreamingModule getAssetPackageIdFromAssetPackageFilePath:model.packageUrl];
            if (model.licUrl.length > 0) {
                model.licUrl = [beautyShapeDataPath stringByAppendingPathComponent:model.licUrl];
            } else {
                if (packageId.length > 0) {
                    NSString *licPath = [[beautyShapeDataPath stringByAppendingPathComponent:packageId] stringByAppendingString:@".lic"];
                    model.licUrl = licPath;
                }
            }

            if ([model.packageUrl hasSuffix:@"warp"]) {
                NSMutableString *mutString = [NSMutableString string];
                NvsAssetPackageManagerError error = [self.captureModularVM installAssetPackage:model.packageUrl license:model.licUrl type:NvsAssetPackageType_Warp assetPackageId:mutString];
                if (error == NvsAssetPackageManagerError_NoError) {
                    model.uuid = mutString;
                }
            } else {
                NSMutableString *mutString = [NSMutableString string];
                NvsAssetPackageManagerError error = [self.captureModularVM installAssetPackage:model.packageUrl license:model.licUrl type:NvsAssetPackageType_FaceMesh assetPackageId:mutString];
                if (error == NvsAssetPackageManagerError_NoError) {
                    model.uuid = mutString;
                }
            }
        }

        model.defaultShapePackage = model.uuid;
        model.isBeauty = NO;
        model.isOperation = YES;
    }
}

- (void)notificationChangeBeauty:(NSNotification *)notification{
    for (NvLiveBeautyTypeModel *model in self.beautyEffectArray) {
        if (model.subprojectArray.count > 0){
            for (NvLiveBeautyTypeModel *subModel in model.subprojectArray) {
                if (subModel.effectType >= 0){
                    subModel.value = [self.captureModularVM getFxCurrentValue:subModel];
                }
            }
        }else{
            model.value = [self.captureModularVM getFxCurrentValue:model];
        }
    }
    for (NvLiveBeautyTypeModel *model in self.beautyShapeArray) {
        model.value = [self.captureModularVM.fxARFace getFloatVal:model.degreeName];
    }
    for (NvLiveBeautyTypeModel *model in self.beautyMicroArray) {
        model.value = [self.captureModularVM.fxARFace getFloatVal:model.degreeName];
    }
    
    self.activeRefresh = YES;
}

//MARK: -- NvLiveBeautyViewDelegate

- (double)NvLiveBeautyView:(NvLiveBeautyView *)beautyView valueWithModel:(NvLiveBeautyTypeModel *)model {
    return model.value;
}

- (void)NvLiveBeautyView:(NvLiveBeautyView *)beautyView withModel:(NvLiveBeautyTypeModel *)model withState:(BOOL)state {
    if (model.type == 0) {
        [self.captureModularVM applyBeautyEffectModel:model withOpen:YES];
    } else if (model.type == 1) {
        [self.captureModularVM applyBeautyShapeModel:model withOpen:YES];
    } else if (beautyView.hiddenInteger == 2) {
        [self.captureModularVM applyBeautyMicroshapingModel:model withOpen:YES];
    }
}

- (void)NvLiveBeautyView:(NvLiveBeautyView *)beautyView withModelArray:(NSMutableArray *)array {
    [self NvLiveBeautyView:beautyView withModelArray:array withOpen:YES];
}

- (void)NvLiveBeautyView:(NvLiveBeautyView *)beautyView withModelArray:(NSMutableArray *)array withOpen:(BOOL)open {
    if (beautyView.hiddenInteger == 0) {
        for (NvLiveBeautyTypeModel *model in array) {
            [self.captureModularVM applyBeautyEffectModel:model withOpen:open];
        }
    } else if (beautyView.hiddenInteger == 1) {
        for (NvLiveBeautyTypeModel *model in array) {
            [self.captureModularVM applyBeautyShapeModel:model withOpen:open];
        }
    } else if (beautyView.hiddenInteger == 2) {
        for (NvLiveBeautyTypeModel *model in array) {
            [self.captureModularVM applyBeautyMicroshapingModel:model withOpen:open];
        }
    }
}

@end
