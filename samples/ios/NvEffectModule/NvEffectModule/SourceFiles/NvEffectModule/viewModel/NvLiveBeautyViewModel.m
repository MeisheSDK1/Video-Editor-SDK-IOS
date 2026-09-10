//
//  NvLiveBeautyViewModel.m
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/11.
//

#import "NvLiveBeautyViewModel.h"
#import "NveBeauty+LiveEnmu.h"
#import "NveShape+LiveEnmu.h"
#import "NveMicroShape+LiveEnmu.h"
#import "YYModel.h"
#import "NvLiveBeautyTypeModel.h"
#import "NvLiveSwitchView.h"
#import "NvLiveBeautyTypeCollectionCell.h"
#import "NvLiveARSeceneCaptureFilterCell.h"
#import <NveEffectKit/NveEffectKit.h>
#import "NvLiveEffectModule.h"
#import "NvLiveARSceneUtils.h"

@implementation NvLiveBeautyViewModel

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupData];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationChangeBeauty:) name:@"changeBeauty" object:nil];
    }
    return self;
}

- (NveBeauty *)defaultBeauty {
    NveBeauty *beauty = [[NveBeauty alloc] init];
    for (NvLiveBeautyTypeModel *model in self.beautyEffectArray) {
        [beauty updateEffect:model.effectType value:model.defaultValue];
    }
    return beauty;
}

- (NveShape *)defaultShap {
    NveShape *shape = [[NveShape alloc] init];
    for (NvLiveBeautyTypeModel *model in self.beautyShapeArray) {
        [shape updateEffect:model.effectType value:model.defaultValue];
        [shape updateEffect:model.effectType packageId:model.uuid];
    }
    return shape;
}

- (NveMicroShape *)defaultMicroShap {
    NveMicroShape *microShape = [[NveMicroShape alloc] init];
    for (NvLiveBeautyTypeModel *model in self.beautyMicroArray) {
        [microShape updateEffect:model.effectType value:model.defaultValue];
        [microShape updateEffect:model.effectType packageId:model.uuid];
    }
    return microShape;
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

    beautyView.beautySwitch.selected = NO;
    beautyView.beautyTypeSwitch.selected = NO;
    beautyView.beautyTypeMicroSwitch.selected = NO;

    NveEffectKit *effectKit = [NveEffectKit shareInstance];
    [beautyView switchSelectState:beautyView.beautySwitch selected:!effectKit.beauty.enable];
    [beautyView switchSelectState:beautyView.beautyTypeSwitch selected:!effectKit.shape.enable];
    [beautyView switchSelectState:beautyView.beautyTypeMicroSwitch selected:!effectKit.microShape.enable];

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
    if([NvLiveARSceneUtils enableGanBeauty]) {
        jsonPath = [bundlePath stringByAppendingPathComponent:@"beautyEffect_gan.json"];
    }
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
            NSString *packageId = [NvLiveEffectModule getAssetPackageIdFromAssetPackageFilePath:model.packageUrl];
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
                NvsAssetPackageManagerError error = [[NveEffectKit shareInstance] installAssetPackage:model.packageUrl license:model.licUrl type:NvsAssetPackageType_Warp assetPackageId:mutString];
                if (error == NvsAssetPackageManagerError_NoError) {
                    model.uuid = mutString;
                }
            } else {
                NSMutableString *mutString = [NSMutableString string];
                NvsAssetPackageManagerError error = [[NveEffectKit shareInstance] installAssetPackage:model.packageUrl license:model.licUrl type:NvsAssetPackageType_FaceMesh assetPackageId:mutString];
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
            NSString *packageId = [NvLiveEffectModule getAssetPackageIdFromAssetPackageFilePath:model.packageUrl];
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
                NvsAssetPackageManagerError error = [[NveEffectKit shareInstance] installAssetPackage:model.packageUrl license:model.licUrl type:NvsAssetPackageType_Warp assetPackageId:mutString];
                if (error == NvsAssetPackageManagerError_NoError) {
                    model.uuid = mutString;
                }
            } else {
                NSMutableString *mutString = [NSMutableString string];
                NvsAssetPackageManagerError error = [[NveEffectKit shareInstance] installAssetPackage:model.packageUrl license:model.licUrl type:NvsAssetPackageType_FaceMesh assetPackageId:mutString];
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
    BOOL state =  [[[NveEffectKit shareInstance].beauty getEffectParam:@"Whitening Lut Enabled" type:NveParamType_bool] boolValue];
    int index = [[[NveEffectKit shareInstance].beauty getEffectParam:@"Advanced Beauty Type" type:NveParamType_int] intValue];
    
    BOOL advancedBeauty = [[NveEffectKit shareInstance].beauty getEffectParam:@"Advanced Beauty Enable" type:NveParamType_bool];
    
    for (NvLiveBeautyTypeModel *model in self.beautyEffectArray) {
        if (model.subprojectArray.count > 0){
            for (NvLiveBeautyTypeModel *subModel in model.subprojectArray) {
                if (subModel.effectType >= 0){
                    float value = [[NveEffectKit shareInstance].beauty effectValue:subModel.effectType];
                    if ([NveEffectKit shareInstance].beauty) {
                        subModel.value = value;
                    } else {
                        subModel.value = [[self defaultBeauty] effectValue:subModel.effectType];
                    }
                    switch (subModel.effectType) {
                        case NveBeautyLiveType_whitening:{
                            if (state){
                                subModel.selected = NO;
                            }else{
                                subModel.selected = YES;
                            }
                        }
                            break;
                        case NveBeautyLiveType_whitening_1:{
                            if (state){
                                subModel.selected = YES;
                            }else{
                                subModel.selected = NO;
                            }
                        }
                            break;
                        case NveBeautyLiveType_strength:{
                            if (advancedBeauty){
                                subModel.selected = NO;
                            }else{
                                subModel.selected = YES;
                            }
                        }
                            break;
                        case NveBeautyLiveType_strength_1:{
                            if (advancedBeauty){
                                if (index == 0){
                                    subModel.selected = YES;
                                }else{
                                    subModel.selected = NO;
                                }
                            }else{
                                subModel.selected = NO;
                            }
                        }
                            break;
                        case NveBeautyLiveType_strength_2:{
                            if (advancedBeauty){
                                if (index == 1){
                                    subModel.selected = YES;
                                }else{
                                    subModel.selected = NO;
                                }
                            }else{
                                subModel.selected = NO;
                            }
                        }
                            break;
                        case NveBeautyLiveType_strength_3:{
                            if (advancedBeauty){
                                if (index == 2){
                                    subModel.selected = YES;
                                }else{
                                    subModel.selected = NO;
                                }
                            }else{
                                subModel.selected = NO;
                            }
                        }
                            break;
                    }
                }
            }
        }else{
            model.value = [[self defaultBeauty] effectValue:model.effectType];
        }
    }
    for (NvLiveBeautyTypeModel *model in self.beautyShapeArray) {
        model.value = [[self defaultShap] effectValue:model.effectType];
    }
    for (NvLiveBeautyTypeModel *model in self.beautyMicroArray) {
        model.value = [[self defaultShap] effectValue:model.effectType];
    }
    
    self.activeRefresh = YES;
}

//MARK: -- NvLiveBeautyViewDelegate

- (double)NvLiveBeautyView:(NvLiveBeautyView *)beautyView valueWithModel:(NvLiveBeautyTypeModel *)model {
    if (model.type == 0) {
        return [[NveEffectKit shareInstance].beauty effectValue:model.effectType];
    } else if (model.type == 1) {
        return [[NveEffectKit shareInstance].shape effectValue:model.effectType];
    } else if (beautyView.hiddenInteger == 2) {
        return [[NveEffectKit shareInstance].microShape effectValue:model.effectType];
    }
    return 0;
}

- (void)NvLiveBeautyView:(NvLiveBeautyView *)beautyView withModel:(NvLiveBeautyTypeModel *)model withState:(BOOL)state {
    if (!model){
        return;
    }
    if (model.type == 0) {
        [[NveEffectKit shareInstance].beauty updateEffect:model.effectType value:model.value];
    } else if (model.type == 1) {
        if (!state) {
            [self installAssetPackage:model];
            [[NveEffectKit shareInstance].shape updateEffect:model.effectType packageId:model.uuid];
        }
        [[NveEffectKit shareInstance].shape updateEffect:model.effectType value:model.value];
    } else if (beautyView.hiddenInteger == 2) {
        if (!state) {
            [self installAssetPackage:model];
            [[NveEffectKit shareInstance].microShape updateEffect:model.effectType packageId:model.uuid];
        }
        [[NveEffectKit shareInstance].microShape updateEffect:model.effectType value:model.value];
    }
}

- (void)installAssetPackage:(NvLiveBeautyTypeModel *)model{
    if (model.packageUrl.length == 0 || !model.packageUrl) {
        return;
    }
    if ([model.packageUrl containsString:@"warp"]) {
        NSMutableString *mutString = [NSMutableString string];
        NvsAssetPackageManagerError error = [[NveEffectKit shareInstance] installAssetPackage:model.packageUrl license:model.licUrl type:NvsAssetPackageType_Warp assetPackageId:mutString];
        if (error == NvsAssetPackageManagerError_NoError) {
            model.uuid = mutString;
        }
    } else if ([model.packageUrl containsString:@"facemesh"]) {
        NSMutableString *mutString = [NSMutableString string];
        NvsAssetPackageManagerError error = [[NveEffectKit shareInstance] installAssetPackage:model.packageUrl license:model.licUrl type:NvsAssetPackageType_FaceMesh assetPackageId:mutString];
        if (error == NvsAssetPackageManagerError_NoError) {
            model.uuid = mutString;
        }
    }
}

- (void)NvLiveBeautyView:(NvLiveBeautyView *)beautyView withModelArray:(NSMutableArray *)array {
    if (beautyView.hiddenInteger == 0) {
        for (NvLiveBeautyTypeModel *model in array) {
            if (model.subprojectArray.count > 0) {
                BOOL isReset = false;
                for (NvLiveBeautyTypeModel *subprojectModel in model.subprojectArray) {
                    if (subprojectModel.selected) {
                        isReset = true;
                        [[NveEffectKit shareInstance].beauty updateEffect:subprojectModel.effectType value:subprojectModel.value];
                    }
                }
                ///如果没有被恢复，就全部设置为0
                ///If not restored, all are set to 0
                if (!isReset) {
                    for (NvLiveBeautyTypeModel *subprojectModel in model.subprojectArray) {
                        [[NveEffectKit shareInstance].beauty updateEffect:subprojectModel.effectType value:0];
                    }
                }
            } else {
                [[NveEffectKit shareInstance].beauty updateEffect:model.effectType value:model.value];
            }
        }
    } else if (beautyView.hiddenInteger == 1) {
        for (NvLiveBeautyTypeModel *model in array) {
            [[NveEffectKit shareInstance].shape updateEffect:model.effectType value:model.value];
        }
    } else if (beautyView.hiddenInteger == 2) {
        for (NvLiveBeautyTypeModel *model in array) {
            [[NveEffectKit shareInstance].microShape updateEffect:model.effectType value:model.value];
        }
    }
}

- (void)NvLiveBeautyView:(NvLiveBeautyView *)beautyView withModelArray:(NSMutableArray *)array withOpen:(BOOL)open {
    if (beautyView.hiddenInteger == 0) {
        [NveEffectKit shareInstance].beauty.enable = open;
    } else if (beautyView.hiddenInteger == 1) {
        [NveEffectKit shareInstance].shape.enable = open;
//        [NveEffectKit shareInstance].microShape.enable = open;
    } else if (beautyView.hiddenInteger == 2) {
        [NveEffectKit shareInstance].shape.enable = open;
//        [NveEffectKit shareInstance].microShape.enable = open;
    }
}

@end
