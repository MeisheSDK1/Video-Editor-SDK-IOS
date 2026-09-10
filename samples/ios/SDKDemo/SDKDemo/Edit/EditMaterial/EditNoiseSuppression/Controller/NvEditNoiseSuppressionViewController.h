//
//  NvEditNoiseSuppressionViewController.h
//  SDKDemo
//
//  Created by Meishe on 2022/9/9.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import "NvsVideoClip.h"
#import "NvTimelineUtils.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvEditNoiseSuppressionViewController : NvBaseViewController
@property (nonatomic, assign) NvEditMode editMode;

@property (nonatomic, strong) NvEditDataModel *model;
@property (nonatomic, assign) NSInteger currentIndex;
@end

NS_ASSUME_NONNULL_END
