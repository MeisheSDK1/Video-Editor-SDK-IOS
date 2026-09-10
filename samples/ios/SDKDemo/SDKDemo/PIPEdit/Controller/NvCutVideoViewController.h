//
//  NvCutVideoViewController.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/21.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvSDKCommon/NvEditBaseViewController.h>
NS_ASSUME_NONNULL_BEGIN
@class NvCutVideoViewController;

@protocol NvCutVideoViewControllerDelegate <NSObject>
@optional
- (void)cutVideoViewController:(NvCutVideoViewController *)cutVideoViewController trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut;

@end



@interface NvCutVideoViewController : NvEditBaseViewController
///视频裁剪的trimIn
///Video clipping trimIn
@property (nonatomic, assign) int64_t trimIn;
///视频裁剪的trimOut
///Video clipping trimOut
@property (nonatomic, assign) int64_t trimOut;

@property (nonatomic, weak) id delegate;

@end

NS_ASSUME_NONNULL_END
