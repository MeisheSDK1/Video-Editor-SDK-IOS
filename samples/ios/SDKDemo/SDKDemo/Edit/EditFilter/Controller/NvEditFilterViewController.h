//
//  NvEditFilterViewController.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/12.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import "NvsTimeline.h"

@interface NvEditFilterViewController : NvBaseViewController

@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, assign) NvEditMode editMode;

@end
