//
//  NvEditPictureViewController.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/7/21.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import "NvTimelineUtils.h"

@interface NvEditPictureViewController : NvBaseViewController

@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, strong) NvEditDataModel *model;

@end
