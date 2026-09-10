//
//  NvEditSpeedViewController.h
//  SDKDemo
//
//  Created by MS on 2020/11/26.
//  Copyright © 2020 meishe. All rights reserved.
//

//#import <NvAlbum/NvAlbum.h>
#import <NvBaseCommon/NvBaseViewController.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import "NvTimelineDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvEditSpeedViewController : NvBaseViewController
@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, strong) NvEditDataModel *model;
@property (nonatomic, assign) NSInteger currentIndex;
@end

NS_ASSUME_NONNULL_END
