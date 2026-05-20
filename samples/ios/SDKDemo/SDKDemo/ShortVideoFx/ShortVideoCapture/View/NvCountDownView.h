//
//  NvCountDownView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/15.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@class NvCountDownView;

@protocol NvCountDownViewDelegate <NSObject>
@optional

/// 点击倒计时按钮回调方法
/// the call back of click the count down button
/// @param countDownView countDownView
/// @param value multiply coefficient value
- (void)countDownView:(NvCountDownView *_Nullable)countDownView didClickCountDownValue:(float)value;

@end

@interface NvProgressView : UIView

@property (nonatomic, strong)UIView *backView;
@property (nonatomic, strong)UIView *coverView;
//0-1
@property (nonatomic, assign) float progress;

@end



@interface NvCountDownView : UIView

@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UILabel *fromLable;
@property (nonatomic, strong) UILabel *toLable;
@property (nonatomic, strong) UIView *handleView;
@property (nonatomic, strong) UILabel *currentlabel;
@property (nonatomic, strong) NvProgressView *countDown;
@property (nonatomic, strong) UIButton *countDownButton;

@property (nonatomic, assign) float progress;

@property (nonatomic, assign) float currentValue;

@end

NS_ASSUME_NONNULL_END
