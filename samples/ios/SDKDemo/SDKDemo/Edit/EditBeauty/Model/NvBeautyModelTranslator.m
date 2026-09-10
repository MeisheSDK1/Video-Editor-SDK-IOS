//
//  NvBeautyModelTranslator.m
//  SDKDemo
//
//  Created by Meishe on 2022/11/28.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvBeautyModelTranslator.h"
#import "NvMakeupModel.h"
#import "NvMakeupToolModel.h"

@implementation NvBeautyModelTranslator


//根据应用的整妆数据来处理其中包含的美颜相关的界面
//Process the beauty related interfaces contained within the application based on its makeup data
- (NSMutableArray *)translateBeautyModelWithMakeupEffect:(NvMakeupToolModel *)model referenceArr:(NSArray *)beautyArr {
    NSMutableArray *temp1 = [[NSMutableArray alloc] initWithArray:beautyArr copyItems:YES];
    NSMutableArray *applyEffects = [NSMutableArray array];
    NSArray *advancedTypes = @[@"Advanced Beauty Type Zero",@"Advanced Beauty Type One",@"Advanced Beauty Type Two"];
    if([NvBaseUtils enableAIBeauty]) {
        advancedTypes = @[@"Advanced Beauty Type Zero",@"Advanced Beauty Type One",@"Advanced Beauty Type Two",@"Advanced Beauty Type Three"];
    }
    NvMakeupToolEffectContentModel *effectContent = model.effectContent;
    for(NvMakeupToolEffectModel *effectModel in effectContent.beauty) {
        if ([effectModel.type isEqualToString:@"ColorCorrect"]) {
            //"校色" "Color correction"
            for(NvBeautyTypeModel *item in temp1) {
                if ([item.fxName containsString:@"ColorCorrect"]) {
                    item.value = effectModel.value;
                    item.canReplace = effectModel.canReplace;
                    [applyEffects addObject:item];
                    break;
                }
            }
        }else if(effectModel.params.count > 0) {
            
            for(NvMakeupToolElementModel *element in effectModel.params) {
                if ([element isKindOfClass:[NvMakeupToolElementFloatModel class]]) {
                    for(NvBeautyTypeModel *item in temp1) {
                        if ([item.fxName containsString:element.key]) {
                            NvMakeupToolElementFloatModel *elementFloat = (NvMakeupToolElementFloatModel *)element;
                            item.value = elementFloat.value;
                            item.canReplace = effectModel.canReplace;
                            [applyEffects addObject:item];
                            break;
                        }
                    }
                }else if ([element isKindOfClass:[NvMakeupToolElementBOOLModel class]]) {
                    for(NvBeautyTypeModel *item in temp1) {
                        if ([item.fxName containsString:element.key]) {
                            NvMakeupToolElementBOOLModel *elementBool = (NvMakeupToolElementBOOLModel *)element;
                            item.value = elementBool.value;
                            item.canReplace = effectModel.canReplace;
                            [applyEffects addObject:item];
                            break;
                        }
                    }
                }else if ([element isKindOfClass:[NvMakeupToolElementIntModel class]]) {
                    //"磨皮" "Skin grinding"
                    for(NvBeautyTypeModel *item in temp1) {
                        if ([item.fxName containsString:element.key]) {
                            NvMakeupToolElementIntModel *elementInt = (NvMakeupToolElementIntModel *)element;
                            if([element.key containsString:@"Advanced Beauty Type"]) {
                                int index = elementInt.value;
                                if ([item.fxName containsString:advancedTypes[index]]) {
                                    for(NvMakeupToolElementFloatModel *elementFloat in effectModel.params) {
                                        if ([elementFloat.key containsString:@"Advanced Beauty Intensity"]) {
                                            item.value = elementFloat.value;
                                            item.canReplace = effectModel.canReplace;
                                            break;
                                        }
                                    }
                                    [applyEffects addObject:item];
                                    break;
                                }
                                
                            }
                            
                        }
                    }
                }
                    
            }
        }
    }
    
    for (NvBeautyTypeModel *model in temp1) {
        BOOL checked = NO;
        for (NvBeautyTypeModel *model1 in applyEffects) {
            if ([model.fxName isEqualToString:model1.fxName]) {
                checked = YES;
                break;
            }else if([model.fxName containsString:@"Beauty Whitening"] && [model1.fxName containsString:@"Beauty Whitening"]){
                checked = YES;
                break;
            }
        }
        if (!checked && model.fxName.length > 0 && ![model.fxName isEqualToString:@"none"]) {
            NvBeautyTypeModel * model1 = [NvBeautyTypeModel new];
            model1.fxName = model.fxName;
            model1.value = 0;
            model1.extValue = 0;
            model.value = 0;
            [applyEffects addObject:model1];
        }
    }
    return applyEffects;
}

- (NSMutableArray *)translateShapeModelWithMakeupEffect:(NvMakeupToolModel *)model referenceArr:(NSArray *)shapeArr {
    NSMutableArray * resultArr = [[NSMutableArray alloc] initWithArray:shapeArr copyItems:YES];
    NvMakeupToolEffectContentModel *effectContent = model.effectContent;
    
    /*
     以该应用美妆内美型为准,不在其中的美型不再应用
     The inner beauty type of this application shall prevail
     Beauty patterns that are not in them no longer apply
     */
    for (int k=0; k<resultArr.count; k++) {
        BOOL checked = NO;
        NvBeautyTypeModel *beautyM = resultArr[k];
        for(NvMakeupToolEffectModel *effectModel in effectContent.shape) {
            if (effectModel.type && [beautyM.fxName containsString:effectModel.type]) {
                checked = YES;
                for(NvMakeupToolElementModel *element in effectModel.params) {
                    if ([element.key containsString:@"Package Id"] && [element isKindOfClass:[NvMakeupToolElementStringModel class]]) {
                        NvMakeupToolElementStringModel *elementString = (NvMakeupToolElementStringModel *)element;
                        beautyM.uuid = elementString.value;
                    }else if ([element.key containsString:@"Degree"] && [element isKindOfClass:[NvMakeupToolElementFloatModel class]]) {
                        NvMakeupToolElementFloatModel *elementFloat = (NvMakeupToolElementFloatModel *)element;
                        beautyM.value= elementFloat.value;
                    }
                }
                beautyM.canReplace = effectModel.canReplace;
                break;
            }
        }
        
        if (!checked) {
            beautyM.value = 0;
        }
    }
    return resultArr;
}

- (NSMutableArray *)translateMicroShapeModelWithMakeupEffect:(NvMakeupToolModel *)model referenceArr:(NSArray *)microShapeArr {
    NSMutableArray * resultArr = [[NSMutableArray alloc] initWithArray:microShapeArr copyItems:YES];
    NvMakeupToolEffectContentModel *effectContent = model.effectContent;
    for (int k=0; k<resultArr.count; k++) {
        BOOL checked = NO;
        NvBeautyTypeModel *beautyM = resultArr[k];
        for(NvMakeupToolEffectModel *effectModel in effectContent.shape) {
            if (effectModel.type && [beautyM.fxName containsString:effectModel.type]) {
                checked = YES;
                for(NvMakeupToolElementModel *element in effectModel.params) {
                    if ([element.key containsString:@"Package Id"] && [element isKindOfClass:[NvMakeupToolElementStringModel class]]) {
                        NvMakeupToolElementStringModel *elementString = (NvMakeupToolElementStringModel *)element;
                        beautyM.uuid = elementString.value;
                    }else if (([element.key containsString:@"Degree"] || [element.key containsString:@"Intensity"]) && [element isKindOfClass:[NvMakeupToolElementFloatModel class]]) {
                        NvMakeupToolElementFloatModel *elementFloat = (NvMakeupToolElementFloatModel *)element;
                        beautyM.value= elementFloat.value;
                    }
                }
                beautyM.canReplace = effectModel.canReplace;
                break;
            }
        }
        
        if (!checked) {
            beautyM.value = 0;
        }
    }
    return resultArr;
}
@end
