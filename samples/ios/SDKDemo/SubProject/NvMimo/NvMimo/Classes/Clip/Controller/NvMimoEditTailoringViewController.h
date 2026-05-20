//
//  NvEditTailoringViewController.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/13.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsVideoClip.h"
#import "NVMimoDefineConfig.h"
#import "NvMimoTimelineUtils.h"
#import "NvMimoTimelineDataModel.h"
#import "NvThemeModel.h"
#import <NvBaseCommon/NvBaseViewController.h>
//type 0=裁剪 1=分割
//type 0= crop 1= split
typedef void(^EditTailoringBlock)(NvMimoEditDataModel *newModel, BOOL type);
typedef void(^EditTailorReplaceBlock)(NvShotModel *replaceModel);
@interface NvMimoEditTailoringViewController : NvBaseViewController

@property (nonatomic, assign) NvMimoEditMode editMode;
@property (nonatomic, strong) NvsVideoClip *clip;
@property (nonatomic, strong) NvShotModel *model;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, copy) EditTailoringBlock editBlock;
@property (nonatomic, copy) EditTailorReplaceBlock replaceBlock;
@end
