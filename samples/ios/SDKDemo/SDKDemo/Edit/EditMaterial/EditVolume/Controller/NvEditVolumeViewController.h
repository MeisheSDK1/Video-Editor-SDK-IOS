//
//  NvEditVolumeViewController.h
//  SDKDemo
//
//  Created by ms on 2021/8/4.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import "NvsVideoClip.h"
#import "NvTimelineUtils.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvEditVolumeViewController : NvBaseViewController
@property (nonatomic, assign) NvEditMode editMode;

@property (nonatomic, strong) NvEditDataModel *model;
@property (nonatomic, assign) NSInteger currentIndex;
@end

NS_ASSUME_NONNULL_END
