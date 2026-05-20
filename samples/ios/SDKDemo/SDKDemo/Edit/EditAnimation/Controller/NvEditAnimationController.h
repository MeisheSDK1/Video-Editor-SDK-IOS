//
//  NvEditAnimationController.h
//  SDKDemo
//
//  Created by ms on 2020/8/24.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <NvSDKCommon/NvEditBaseViewController.h>
@class NvEditDataModel;
NS_ASSUME_NONNULL_BEGIN

@interface NvEditAnimationController : NvEditBaseViewController
@property (nonatomic, strong) NSMutableArray<NvEditDataModel *> *editDataArray;
@end

NS_ASSUME_NONNULL_END
