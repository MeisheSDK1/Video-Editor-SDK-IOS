//
//  UIAlertController+CustomAlert.h
//  SDKDemo
//
//  Created by meishe01 on 2024/5/9.
//  Copyright © 2024 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (CustomAlert)

/// 显示弹窗
/// - Parameters:
///   - title: 标题
///   - viewController: 弹出控制器
///   - message: 弹窗内容
///   - buttonTitleColors: 按钮颜色数组,取消按钮选择第一个默认为systemBlueColor
///   - cancelButtonTitle: 取消按钮标题
///   - otherButtonTitle: 其他按钮标题
///   - cancelAction: 取消点击回调
///   - otherAction: 其他按钮点击回调
+ (void)presentAlertFromVC:(UIViewController * _Nullable)viewController
                     title:(NSString * _Nullable)title
                   message:(NSString * _Nullable)message
         buttonTitleColors:(NSArray<UIColor *>* _Nullable)buttonTitleColors
         cancelButtonTitle:(NSString * _Nullable)cancelButtonTitle
          otherButtonTitle:(NSString * _Nullable)otherButtonTitle
        cancelButtonAction:(void (^ _Nullable)(UIAlertAction *action))cancelAction
         otherButtonAction:(void (^ _Nullable)(UIAlertAction *action))otherAction;


/// 创建弹窗
/// - Parameters:
///   - title: 标题
///   - message: 弹窗内容
///   - buttonTitleColors: 按钮颜色数组,取消按钮选择第一个默认为systemBlueColor
///   - cancelButtonTitle: 取消按钮标题
///   - otherButtonTitle: 其他按钮标题
///   - cancelAction: 取消点击回调
///   - otherAction: 其他按钮点击回调
+ (UIAlertController * )alertWithTitle:(NSString * _Nullable)title
                               message:(NSString * _Nullable)message
                     buttonTitleColors:(NSArray<UIColor *>* _Nullable)buttonTitleColors
                     cancelButtonTitle:(NSString * _Nullable)cancelButtonTitle
                      otherButtonTitle:(NSString * _Nullable)otherButtonTitle
                    cancelButtonAction:(void (^ _Nullable)(UIAlertAction *action))cancelAction
                     otherButtonAction:(void (^ _Nullable)(UIAlertAction *action))otherAction;
@end

NS_ASSUME_NONNULL_END
