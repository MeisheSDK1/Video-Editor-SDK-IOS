//
//  NvEditMakeUpController.h
//  SDKDemo
//
//  Created by ms on 2021/10/13.
//  Copyright © 2021 meishe. All rights reserved.
//
#import <NvBaseCommon/NvBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvEditMakeUpController : NvBaseViewController
@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, strong) NvsTimeline *timeline;
@end

NS_ASSUME_NONNULL_END
