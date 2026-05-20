//
//  EMPToast.h
//  MintLive
//
//  Created by yanruichen on 2017/3/13.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^EMPToastProgressBlock)(CGFloat progress);

@interface NvToast : NSObject
//以下方法会拦截用户交互  The following methods will intercept user interaction

/// 显示加载进度视图
/// Show loading progress view
+ (void)showLoading;

/// 显示加载进度视图
/// Show loading progress view
/// @param message 展示信息 Display information
+ (void)showLoadingWithMessage:(NSString *)message;

/// 显示加载进度视图
/// Show loading progress view
/// @param view 展示视图 Show view
+ (void)showLoadingInView:(UIView *)view;

/// 显示加载进度视图
/// Show loading progress view
/// @param view 展示视图 Show view
/// @param message 展示信息 Display information
/// @param interaction 是否可以交互 Can you interact
+ (void)showLoadingInView:(UIView *)view message:(NSString *)message interaction:(BOOL)interaction;

/// 显示生成加载进度视图
/// Display the view of the build loading progress
/// @param message 展示信息 Display information
+ (void)showCompileWithMessage:(NSString *)message;

/// 显示加载进度条视图
/// Show loading progress bar view
/// @param message 展示信息 Display information
/// @param progress  进度值 Progress value
+ (void)showHorizontalProgressWithMessage:(NSString *)message progress:(CGFloat)progress;

/// 显示加载进度条视图
/// @param message 展示信息 Display information
+ (EMPToastProgressBlock)showProgressWithMessage:(NSString *)message;

/// 销毁加载进度视图
/// Destroy the loading progress view
+ (void)dismiss;

/// 销毁加载进度视图
/// Destroy the loading progress view
/// @param view 展示视图 Show view
+ (void)dismissInView:(UIView *)view;

/// 销毁加载进度视图
/// Destroy the loading progress view
/// @param aniamted 是否有动画 Is there an animation
+ (void)dismissAniamted:(BOOL)aniamted;

/// 销毁加载进度视图
/// Destroy the loading progress view
/// @param view 展示视图 Show view
/// @param animated  是否有动画 Is there an animation
+ (void)dismissInView:(UIView *)view animated:(BOOL)animated;

//以下方法不拦截交互 The following methods do not intercept interaction

/// 显示加载进度视图
/// Show loading progress view
/// @param message 展示信息 Display information
+ (void)showInfoWithMessage:(NSString *)message;

/// 显示加载完成视图
/// Show loading completed view
/// @param message 展示信息 Display information
+ (void)showSuccessWithMessage:(NSString *)message;

/// 显示加载失败视图
/// Show loading failure view
/// @param message 展示信息 Display information
+ (void)showErrorWithMessage:(NSString *)message;

/// 显示加载进度视图
/// Show loading progress view
/// @param message 展示信息 Display information
/// @param view 展示视图 Show view
+ (void)showInfoWithMessage:(NSString *)message inView:(UIView *)view;

/// 销毁加载进度视图
/// Destroy the loading progress view
/// @param aniamted 是否有动画 Is there an animation
/// @param view 展示视图 Show view
+ (void)dismissAniamted:(BOOL)aniamted inView:(UIView *)view;

@end
