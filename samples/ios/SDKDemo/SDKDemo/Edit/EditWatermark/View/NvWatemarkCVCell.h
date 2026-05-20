//
//  NvWatemarkCVCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/10/18.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvWatemarkItem : NSObject

/// 图片名称 Picture name
@property (nonatomic, strong) NSString *coverString;

/// 是否选中 Whether selected
@property (nonatomic, assign) BOOL selected;

/// 是否是caf文件 Is it a caf file
@property (nonatomic, assign) BOOL isCaf;

/// 是否是缓存的图片 Is it a cached picture
@property (nonatomic, assign) BOOL isCacheImage;

/// 是否是内建特效（如：马赛克、模糊）Whether it is built-in special effects (such as: mosaic, blur)
@property (nonatomic, assign) BOOL isBuiltInEffect;

/// 内建特效名称 Built-in special effect name
@property (nonatomic, strong) NSString *effectName;

/// 内建特效强度 Built-in special effect intensity
@property (nonatomic, assign) float intensity;

/// 马赛克效果单位大小 Mosaic effect unit size
@property (nonatomic, assign) float unitSize;

@end

@interface NvWatemarkCVCell : UICollectionViewCell

/// 绑定数据
/// Bind data
/// @param item 数据模型 Data model
- (void)renderCellWithItem:(NvWatemarkItem *)item;

@end
