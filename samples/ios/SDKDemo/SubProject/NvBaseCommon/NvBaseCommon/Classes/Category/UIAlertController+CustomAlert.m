//
//  UIAlertController+CustomAlert.m
//  SDKDemo
//
//  Created by meishe01 on 2024/5/9.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "UIAlertController+CustomAlert.h"
#import <NvBaseCommon/NvBaseUtils.h>

@implementation UIAlertController (CustomAlert)

+ (void)presentAlertFromVC:(UIViewController * _Nullable)viewController
                     title:(NSString * _Nullable)title
                   message:(NSString * _Nullable)message
         buttonTitleColors:(NSArray<UIColor *>* _Nullable)buttonTitleColors
         cancelButtonTitle:(NSString * _Nullable)cancelButtonTitle
          otherButtonTitle:(NSString * _Nullable)otherButtonTitle
        cancelButtonAction:(void (^ _Nullable)(UIAlertAction *action))cancelAction
         otherButtonAction:(void (^ _Nullable)(UIAlertAction *action))otherAction{
    
    UIAlertController * alert = [UIAlertController alertWithTitle:title
                                                          message:message
                                                buttonTitleColors:buttonTitleColors
                                                cancelButtonTitle:cancelButtonTitle
                                                 otherButtonTitle:otherButtonTitle
                                               cancelButtonAction:cancelAction
                                                otherButtonAction:otherAction];
    if (viewController == nil) {
        
        viewController = [NvBaseUtils getCurrentVC];
    }
    // 显示弹窗
    [viewController presentViewController:alert animated:YES completion:nil];
}

+ (UIAlertController * )alertWithTitle:(NSString * _Nullable)title
                               message:(NSString * _Nullable)message
                     buttonTitleColors:(NSArray<UIColor *>* _Nullable)buttonTitleColors
                     cancelButtonTitle:(NSString * _Nullable)cancelButtonTitle
                      otherButtonTitle:(NSString * _Nullable)otherButtonTitle
                    cancelButtonAction:(void (^ _Nullable)(UIAlertAction *action))cancelAction
                     otherButtonAction:(void (^ _Nullable)(UIAlertAction *action))otherAction{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    if(cancelButtonTitle && cancelButtonTitle.length > 0) {
        // 取消按钮
        UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:cancelButtonTitle
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:cancelAction];
        [alert addAction:cancelAlertAction];
        if (buttonTitleColors && buttonTitleColors.firstObject) {
            
            [cancelAlertAction setValue:buttonTitleColors.firstObject forKey:@"titleTextColor"];
        }
    }
    if (otherButtonTitle && otherButtonTitle.length > 0) {
        // 其他按钮
        UIAlertAction *otherAlertAction = [UIAlertAction actionWithTitle:otherButtonTitle
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:otherAction];
        [alert addAction:otherAlertAction];
        if (buttonTitleColors && buttonTitleColors.lastObject) {
            
            [otherAlertAction setValue:buttonTitleColors.lastObject forKey:@"titleTextColor"];
        }
    }
    return alert;
}
@end
