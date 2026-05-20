//
//  NvEditClipCaptionViewController.h
//  SDKDemo
//
//  Created by ms on 2021/8/25.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <NvSDKCommon/NvEditBaseViewController.h>
#import "NvsVideoClip.h"
#import "NvTimelineUtils.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvEditClipCaptionViewController : NvEditBaseViewController
//@property (nonatomic, assign) NvEditMode editMode;

@property (nonatomic, strong) NvEditDataModel *model;
@property (nonatomic, assign) NSInteger currentIndex;
@end

NS_ASSUME_NONNULL_END
