//
//  NvCutVideoViewController.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/21.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvEditBaseViewController.h"
@class NvCutVideoViewController;

@protocol NvCutVideoViewControllerDelegate <NSObject>
@optional
- (void)cutVideoViewController:(NvCutVideoViewController *)cutVideoViewController trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut;

@end

NS_ASSUME_NONNULL_BEGIN

@interface NvCutVideoViewController : NvEditBaseViewController

@property (nonatomic, assign) int64_t trimIn;                       //视频裁剪的trimIn
@property (nonatomic, assign) int64_t trimOut;                      //视频裁剪的trimOut

@property (nonatomic, weak) id delegate;

@end

NS_ASSUME_NONNULL_END
