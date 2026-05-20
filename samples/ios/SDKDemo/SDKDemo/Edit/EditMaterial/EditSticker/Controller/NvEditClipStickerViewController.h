//
//  NvEditClipStickerViewController.h
//  SDKDemo
//
//  Created by ms on 2021/8/26.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NvSDKCommon/NvUtils.h>
#import <NvBaseCommon/NvBaseViewController.h>
#import "NvTimelineUtils.h"

@interface NvEditClipStickerViewController : NvBaseViewController

//@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, strong) NvEditDataModel *model;
@property (nonatomic, assign) NSInteger currentIndex;
@end
