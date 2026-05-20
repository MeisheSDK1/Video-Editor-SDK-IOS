//
//  NvMusiclyricViewController.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/12/24.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import <NvBaseCommon/NVDefineConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvMusiclyricViewController : NvBaseViewController

@property (nonatomic, strong) NSMutableArray *selectAssets;
@property (nonatomic, assign) NvEditMode editMode;

@end

NS_ASSUME_NONNULL_END
