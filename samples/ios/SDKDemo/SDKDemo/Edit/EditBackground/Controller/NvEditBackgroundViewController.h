//
//  NvEditBackgroundViewController.h
//  SDKDemo
//
//  Created by MS on 2020/10/21.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <NvSDKCommon/NvEditBaseViewController.h>
@class NvEditDataModel;
NS_ASSUME_NONNULL_BEGIN

@interface NvEditBackgroundViewController : NvEditBaseViewController
@property (nonatomic, strong) NSMutableArray<NvEditDataModel *> *editDataArray;
@end

NS_ASSUME_NONNULL_END
