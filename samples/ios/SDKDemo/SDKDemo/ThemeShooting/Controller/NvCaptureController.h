//
//  NvCaptureController.h
//  ThemeShooting
//
//  Created by ms on 2020/7/17.
//  Copyright © 2020 ms. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import "NvThemeShootModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvCaptureController : NvBaseViewController
@property (nonatomic, strong) NvThemeShootModel *model;
@property (nonatomic, assign) NvEditMode editMode;
@end

NS_ASSUME_NONNULL_END
