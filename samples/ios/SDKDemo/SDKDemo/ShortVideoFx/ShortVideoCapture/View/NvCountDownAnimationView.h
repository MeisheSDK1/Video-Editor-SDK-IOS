//
//  NvCountDownAnimationView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/16.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@class NvCountDownAnimationView;

@protocol NvCountDownAnimationViewDelegate <NSObject>
@optional

/// 倒计时动画结束后的回调方法
/// the call back after countDown animation ending
/// @param countDownAnimationView countDownAnimationView
- (void)countDownAnimationStopAnimationView:(NvCountDownAnimationView *)countDownAnimationView;

@end


@interface NvCountDownAnimationView : UIView

@property (nonatomic, weak) id delegate;

- (void)startAnimation;

@end

NS_ASSUME_NONNULL_END
