//
//  NvAjustFxParamModel.h
//  SDKDemo
//
//  Created by Meishe on 2022/8/17.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, NvAjustFxParamCategory) {
    NvAjustFxParamCategoryInvalid = -1,
    NvAjustFxParamCategoryeFirst = 0,
    NvAjustFxParamCategoryArbitrary = 0,
    NvAjustFxParamCategoryInt,
    NvAjustFxParamCategoryFloat,
    NvAjustFxParamCategoryBoolean,
    NvAjustFxParamCategoryMenu,
    NvAjustFxParamCategoryString,
    NvAjustFxParamCategoryColor,
    NvAjustFxParamCategoryPosition2D,
    NvAjustFxParamCategoryPosition3D,
    NvAjustFxParamCategoryCount,
};

@interface NvAjustFxParamModel : NSObject <NSCopying>
@property (nonatomic, assign) NvAjustFxParamCategory type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *translationName;
@property (nonatomic, assign) double defaultValue;
@property (nonatomic, assign) double minValue;
@property (nonatomic, assign) double maxValue;
@property (nonatomic, assign) double currentValue;
@property (nonatomic, assign) float r;
@property (nonatomic, assign) float g;
@property (nonatomic, assign) float b;
@property (nonatomic, assign) float a;
@end

NS_ASSUME_NONNULL_END
