//
//  NvEditTailoringViewController.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/13.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import "NvsVideoClip.h"
#import "NvTimelineUtils.h"
///type 0=裁剪 1=分割
///type 0= clipping 1= splitting
typedef void(^EditTailoringBlock)(NvEditDataModel *newModel, BOOL type);
@interface NvEditTailoringViewController : NvBaseViewController

@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, strong) NvsVideoClip *clip;
@property (nonatomic, strong) NvEditDataModel *model;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, copy) EditTailoringBlock editBlock;
@end
