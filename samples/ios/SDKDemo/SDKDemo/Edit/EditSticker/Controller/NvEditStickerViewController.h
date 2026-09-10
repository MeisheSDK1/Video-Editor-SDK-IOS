//
//  NvEditStickerViewController.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/6/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NvSDKCommon/NvUtils.h>
#import <NvBaseCommon/NvBaseViewController.h>
#import "NvsTimeline.h"

@interface NvEditStickerViewController : NvBaseViewController

@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, assign) NvEditMode editMode;
@end
