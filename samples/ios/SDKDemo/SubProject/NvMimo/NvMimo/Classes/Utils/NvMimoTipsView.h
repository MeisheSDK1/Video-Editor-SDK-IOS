//
//  NvPermissionsView.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/31.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvMimoTipsView : UIView

@property (nonatomic, strong) UIButton *clickBtn;

@property (nonatomic, strong) UIButton *clickBtn1;

/**
 创建一个带底部视图的弹窗
 Create a popover with a bottom view
 @param frame 大小
 @param prompt 提示文字
 @param title 描述的标题，不能为空
 @param content 描述的内容，可以为空
 @param text 按钮文字内容
 @return 该对象
 */
- (instancetype)initWithFrame:(CGRect)frame withPrompt:(NSString *)prompt describeTitle:(NSString *)title describeContent:(NSString *)content buttonText:(NSString *)text withCenter:(BOOL)center;

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withColor:(UIColor *)color withCenter:(BOOL)center;

- (instancetype)initWithFrameVirtual:(CGRect)frame withPrompt:(NSString *)prompt describeTitle:(NSString *)title describeContent:(NSString *)content buttonText:(NSString *)text withCenter:(BOOL)center;

@end
