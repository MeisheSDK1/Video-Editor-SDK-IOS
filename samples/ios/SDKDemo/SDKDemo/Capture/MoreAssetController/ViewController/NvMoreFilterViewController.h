//
//  NvMoreFilterViewController.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import <NvSDKCommon/NvAsset.h>
#import <NvBaseCommon/NVDefineConfig.h>

@interface NvMoreFilterViewController : NvBaseViewController

/// 素材类型 Material type
@property (nonatomic, assign) AssetType type;

/// 素材三级分类 Material type
@property (nonatomic, assign) int kind;

/// 素材比例 Material ratio
@property (nonatomic, assign) NvEditMode editModel;

/// 素材分类 Material classification
@property (nonatomic, assign) int categoryId;

/// 是否是来自拍摄页面 Is it from the shooting page
@property (nonatomic, assign) BOOL isCapture;
@end
