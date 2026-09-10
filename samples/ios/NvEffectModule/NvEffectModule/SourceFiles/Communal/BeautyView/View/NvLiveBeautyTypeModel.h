//
//  NvLiveBeautyTypeModel.h
//  NvARSceneFxModule
//
//  Created by ms20221114 on 2022/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvLiveBeautyTypeModel : NSObject <NSCopying>

@property(nonatomic, assign) BOOL isBeauty; //判断这个model是否是美颜 // Check if this model is beautiful
//Determine whether this model is beauty 0 1 2 beauty beauty type
@property(nonatomic, assign) NSUInteger type; //判断这个model是否是美颜 0 1 2 美颜 美型 微整形

@property(nonatomic, assign) NSUInteger effectType;
// Display text externally
@property(nonatomic, strong) NSString *name; //外部显示文字
@property(nonatomic, strong) NSString *LocalStringKey;
@property(nonatomic, assign) BOOL selected;
/// Sharpness, color correction switch
@property(nonatomic, assign) BOOL switchSelected; //锐度、校色开关
///Degree of effect
@property(nonatomic, assign) float value; //效果程度
///Effect default degree
@property(nonatomic, assign) float defaultValue; //效果默认程度
///Degreasing light radius
@property(nonatomic, assign) float radiusValue; //去油光半径程度
///Default degreasing light radius
@property(nonatomic, assign) float defaultRadiusValue; //去油光半径默认程度
///Minimum degree of effect
@property(nonatomic, assign) float minValue; //效果程度最小值
///Maximum effect degree
@property(nonatomic, assign) float maxValue; //效果程度最大值
///coverImage
@property(nonatomic, strong) NSString *coverImage; //封面图片
///selected coverImage
@property(nonatomic, strong) NSString *selectedCoverImg; //封面图片
///Whether it is open the United States, beauty
@property(nonatomic, assign) BOOL isOperation; //是否是开启了美型、美颜
///Effect parameter name
@property(nonatomic, strong) NSString *fxName;     //特效参数名
@property(nonatomic, strong) NSString *labelColor; //cell label color（rgba)
@property(nonatomic, strong) NSString *bgColor;    //cell color（rgba)
@property(nonatomic, strong) NSString *textColor;  //cell color（rgba)
@property(nonatomic, strong) NSString *uuid;       //美型packageId makeup packageid
@property(nonatomic, strong) NSString *packageUrl; //美型package 路径 makeup package filePath
@property(nonatomic, strong) NSString *licUrl;     //美型package lic 路径 makeup package lic filePath
@property(nonatomic, strong) NSString *degreeName; //美型程度名字 Beauty degree name
@property(nonatomic, assign) BOOL open;            //校色和锐度开启状态 Color correction and sharpness are enabled
@property(nonatomic, assign) BOOL canReplace;
@property(nonatomic, strong) NSString *defaultShapePackage;

/// 关联的子项目，比如磨皮：有多个子磨皮，但是他们有一个共同的父类
/// Related child items, such as peels: There are multiple child peels, but they share a common parent class
@property (nonatomic, strong) NSArray <NvLiveBeautyTypeModel *>* subprojectArray;
@property (nonatomic, assign) BOOL expansion;
@property (nonatomic, assign) BOOL parentNode;

@end

NS_ASSUME_NONNULL_END
