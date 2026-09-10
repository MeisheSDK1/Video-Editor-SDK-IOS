//
//  NvPIPPreviewViewController.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/17.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import "NvsTimeline.h"

@interface NvPIPPreviewViewController : NvBaseViewController

@property (nonatomic, strong) NvsTimeline *timeline;

@property (nonatomic, assign) NvEditMode editMode;

@end
