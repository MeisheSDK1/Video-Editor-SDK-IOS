//
//  NvMoreFilterViewController.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvBaseViewController.h"
#import "NvAsset.h"

@interface NvMoreFilterViewController : NvBaseViewController

@property (nonatomic, assign) AssetType type;
@property (nonatomic, assign) NvEditMode editModel;

@property (nonatomic, assign) BOOL isCapture;
@end
