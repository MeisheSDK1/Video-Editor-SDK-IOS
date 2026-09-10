//
//  NvLiveCountDownAnimationView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/16.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvLiveCountDownAnimationView;

NS_ASSUME_NONNULL_BEGIN

@protocol NvLiveCountDownAnimationViewDelegate <NSObject>
@optional
- (void)countDownAnimationStopAnimationView:(NvLiveCountDownAnimationView *)countDownAnimationView;

@end

@interface NvLiveCountDownAnimationView : UIView

@property (nonatomic, weak) id delegate;

- (void)startAnimation;

@end

NS_ASSUME_NONNULL_END
