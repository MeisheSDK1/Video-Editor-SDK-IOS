//
//  NvBaseViewController.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/24.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvBaseViewController : UIViewController

@property (nonatomic, strong) UIButton *backButton;

/**
 需要自定义返回按钮,子类需要重载这个方法
 @return 需要显示的返回按钮
 You need to customize the back button, and subclasses need to override this method
 @return The return button to display
 */
- (UIView *)leftNavigationBarItemView;

/**
 需要自定义返回事件,子类需要重载这个方法
 Custom return events are needed, and subclasses need to override this method
 */
- (void)leftNavButtonClick:(UIButton *)button;

@end
