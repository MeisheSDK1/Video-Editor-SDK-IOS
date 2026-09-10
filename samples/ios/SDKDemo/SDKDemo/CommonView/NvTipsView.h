//
//  NvPermissionsView.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/31.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvTipsView : UIView

/// 第一个按钮  First button
@property (nonatomic, strong) UIButton *clickBtn;

/// 第二个按钮 Second button
@property (nonatomic, strong) UIButton *clickBtn1;

/**
 创建一个带底部视图的弹窗
 Create a pop-up window with a bottom view
 
 @param frame 大小 frame
 @param prompt 提示文字 Prompt text
 @param title 描述的标题，不能为空 The title of the description, cannot be empty
 @param content 描述的内容，可以为空 Description content, can be empty
 @param text 按钮文字内容 Button text content
 @return 该对象 The object
 */
- (instancetype)initWithFrame:(CGRect)frame withPrompt:(NSString *)prompt describeTitle:(NSString *)title describeContent:(NSString *)content buttonText:(NSString *)text withCenter:(BOOL)center;

/**
 创建一个带底部视图的弹窗
 Create a pop-up window with a bottom view
 
 @param frame 大小 frame
 @param title 描述的标题，不能为空 The title of the description, cannot be empty
 @param color 背景颜色  background color
 @param center 视图是否在中心 Whether the view is in the center
 @return 该对象 The object
 */
- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withColor:(UIColor *)color withCenter:(BOOL)center;

/**
 创建一个带底部视图的弹窗
 Create a pop-up window with a bottom view
 
 @param frame 大小 frame
 @param prompt 提示文字 Prompt text
 @param title 描述的标题，不能为空 The title of the description, cannot be empty
 @param content 描述的内容，可以为空 Description content, can be empty
 @param text 按钮文字内容 Button text content
 @param center 视图是否在中心 Whether the view is in the center
 @return 该对象 The object
 */
- (instancetype)initWithFrameVirtual:(CGRect)frame withPrompt:(NSString *)prompt describeTitle:(NSString *)title describeContent:(NSString *)content buttonText:(NSString *)text withCenter:(BOOL)center;

- (instancetype)initWithTitle:(NSString *)title buttonText:(NSString *)leftText buttonText:(NSString *)rightText;

@end
