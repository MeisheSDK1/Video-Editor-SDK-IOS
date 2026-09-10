//
//  NvListCategoryModel.h
//  SDKDemo
//
//  Created by ms20180425 on 2022/3/17.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvListCategoryModel : NSObject <NSCoding>

/// 素材一级分类 Primary classification of material
@property (nonatomic, assign) int materialType;
/// 素材二级分类 Secondary classification of material
@property (nonatomic, assign) int category;
/// 素材二级分类数组 Material secondary sorting array
@property (nonatomic, strong) NSString *categoryList;
/// 素材三级分类 Three-level classification of material
@property (nonatomic, assign) int kindID;
/// 英文名称 English name
@property (nonatomic, strong) NSString *displayName;
/// 中文名称 Chinese name
@property (nonatomic, strong) NSString *displayNameZhCn;
/// 未选中图标 Unselected icon
@property (nonatomic, strong) NSString *selectedNoCover;
/// 选中图标 Select icon
@property (nonatomic, strong) NSString *selectedCover;
/// 本地素材文件夹路径 Path to the local material folder
@property (nonatomic, strong) NSString *localMaterialPath;
@end

NS_ASSUME_NONNULL_END
