//
//  NvMaskViewController.h
//  SDKDemo
//
//  Created by ms on 2021/3/4.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <NvSDKCommon/NvEditBaseViewController.h>
@class NvEditDataModel;
NS_ASSUME_NONNULL_BEGIN

@interface NvMaskViewController : NvEditBaseViewController
@property (nonatomic, strong) NSMutableArray<NvEditDataModel *> *editDataArray;
@end

NS_ASSUME_NONNULL_END
