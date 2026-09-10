//
//  NvEditMaterialViewController.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/11.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import "NvEditThemeViewController.h"
#import "NvsTimeline.h"

@interface NvEditMaterialViewController : NvBaseViewController

@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, weak) id<NvEditThemeViewControllerDelegate> delegate;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@end
