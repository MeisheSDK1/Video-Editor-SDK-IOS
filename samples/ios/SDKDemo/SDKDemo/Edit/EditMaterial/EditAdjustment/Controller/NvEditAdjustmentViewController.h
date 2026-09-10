//
//  NvEditAdjustmentViewController.h
//  SDKDemo
//
//  Created by MS on 2020/12/2.
//  Copyright © 2020 meishe. All rights reserved.
//

//#import <NvAlbum/NvAlbum.h>
#import <NvBaseCommon/NvBaseViewController.h>
#import "NvTimelineDataModel.h"
#import <NvBaseCommon/NVDefineConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvEditAdjustmentViewController : NvBaseViewController
@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, strong) NvEditDataModel *model;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@property (nonatomic, assign) CGFloat timelineRatio;
@end

NS_ASSUME_NONNULL_END
