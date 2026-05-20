//
//  NvMakeupToolModel.h
//  SDKDemo
//
//  Created by Meishe on 2022/11/7.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, NvMakeupModulerMode) {
    NvMakeupModulerModeCapture,
    NvMakeupModulerModeEdit,
};

@interface NvMakeupToolElementModel : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *type;
@end

@interface NvMakeupToolElementStringModel : NvMakeupToolElementModel
@property (nonatomic, strong) NSString *value;
@end

@interface NvMakeupToolElementBOOLModel : NvMakeupToolElementModel
@property (nonatomic, assign) BOOL value;
@end

@interface NvMakeupToolElementIntModel : NvMakeupToolElementModel
@property (nonatomic, assign) int value;
@end

@interface NvMakeupToolElementFloatModel : NvMakeupToolElementModel
@property (nonatomic, assign) float value;
@end

@interface NvMakeupToolElementDoubleModel : NvMakeupToolElementModel
@property (nonatomic, assign) double value;
@end

@interface NvMakeupToolElementColorModel : NvMakeupToolElementModel
@property (nonatomic, assign) float r;
@property (nonatomic, assign) float g;
@property (nonatomic, assign) float b;
@property (nonatomic, assign) float a;
@end

@interface NvMakeupToolEffectModel : NSObject
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) BOOL canReplace;
@property (nonatomic, strong) NSArray <NvMakeupToolElementModel *>*params;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) double value;
@property (nonatomic, assign) BOOL isBuiltIn;
@end

@interface NvMakeupToolEffectContentModel : NSObject
@property (nonatomic, strong) NSMutableArray <NvMakeupToolEffectModel *>*makeup;
@property (nonatomic, strong) NSMutableArray <NvMakeupToolEffectModel *>*beauty;
@property (nonatomic, strong) NSMutableArray <NvMakeupToolEffectModel *>*shape;
@property (nonatomic, strong) NSMutableArray <NvMakeupToolEffectModel *>*microShape;
@property (nonatomic, strong) NSMutableArray <NvMakeupToolEffectModel *>*filter;
@end

@interface NvMakeupToolTranslationModel : NSObject
@property (nonatomic, strong) NSString *originalText;
@property (nonatomic, strong) NSString *targetLanguage;
@property (nonatomic, strong) NSString *targetText;
@end

@interface NvMakeupToolModel : NSObject
@property (nonatomic, copy) NSString *packagePath;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, strong) NSString *minSdkVersion;
@property (nonatomic, strong) NSString *supportedAspectRatio;
@property (nonatomic, strong) NSArray <NvMakeupToolTranslationModel *>*translation;
@property (nonatomic, strong) NvMakeupToolEffectContentModel *effectContent;
@end

@interface NvMakeupToolDataModel : NvMakeupToolModel
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *displayNameZhCn;
@property (nonatomic, strong) NSString *infoPath;
@property (nonatomic, strong) NSString *bgColorStr;     //cell 背景颜色（rgba） Background color
@property (nonatomic, strong) NSString *labelColorStr;  //cell label背景颜色（rgba） Background color
@property (nonatomic, strong) NSString *textColorStr;   //cell label文字颜色（rgba）Background color
@property (nonatomic, assign) BOOL hasBgColor;
@property (nonatomic, strong) NSMutableArray <NvMakeupToolDataModel *>*contents;
@property (nonatomic, strong) NSString *coverImage;   //封面图片 Cover image
@property (nonatomic, assign) NSInteger conLevel; //数据处于第几层级（整妆0，分类1，单妆2） What level is the data at (makeup 0, classification 1, single makeup 2)
@property (nonatomic, assign) BOOL selected;          //是否选中 Whether selected

@end
NS_ASSUME_NONNULL_END
