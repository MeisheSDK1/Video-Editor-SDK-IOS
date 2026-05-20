//
//  NvLivePhotoViewController.h
//  SDKDemo
//
//  Created by Mac-Mini on 2025/5/7.
//  Copyright © 2025 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import <NvBaseCommon/NVDefineConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvLivePhotoViewController : NvBaseViewController

@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, strong) NvsTimeline *timeline;

@end

NS_ASSUME_NONNULL_END
