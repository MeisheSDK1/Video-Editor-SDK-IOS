//
//  NvThemeShootingEditVC.h
//  SDKDemo
//
//  Created by ms20180425 on 2020/8/3.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import "NvThemeShootModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvThemeShootingEditVC : NvBaseViewController

@property (nonatomic, assign) NvEditMode editMode;

@property (nonatomic, strong) NvPackageInfoModel *currentModel;

@property (nonatomic, strong) NSString *dirPath;
@property (nonatomic, assign) BOOL needRotate;

@end

NS_ASSUME_NONNULL_END
