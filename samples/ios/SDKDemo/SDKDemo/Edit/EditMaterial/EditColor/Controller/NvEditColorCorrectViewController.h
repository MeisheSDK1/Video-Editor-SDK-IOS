//
//  NvEditColorCorrectViewController.h
//  SDKDemo
//
//  Created by ms on 2020/11/26.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import "NvsVideoClip.h"
#import "NvTimelineUtils.h"

@interface NvEditColorCorrectViewController : NvBaseViewController
@property (nonatomic, assign) NvEditMode editMode;

@property (nonatomic, strong) NvEditDataModel *model;
@property (nonatomic, assign) NSInteger currentIndex;
@end


