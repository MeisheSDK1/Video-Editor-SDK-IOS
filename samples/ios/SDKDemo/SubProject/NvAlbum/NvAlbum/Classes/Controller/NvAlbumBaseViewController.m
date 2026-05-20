//
//  NvBaseViewController.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/24.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvAlbumBaseViewController.h"
#import "UIColor+NvColor.h"
#import "UIButton+NvButton.h"
#import "NVDefineConfig.h"
#import "NvAlbumUtils.h"

@interface NvAlbumBaseViewController ()

@end

@implementation NvAlbumBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0x242728);
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"], NSForegroundColorAttributeName, [NvAlbumUtils fontWithSize:16], NSFontAttributeName, nil]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self leftNavigationBarItemView]];

}

/**
 需要自定义返回按钮,子类需要重载这个方法
 You need to customize the back button, and subclasses need to override this method
 @return 需要显示的返回按钮
 The back button to display
 */
- (UIView *)leftNavigationBarItemView {
    UIImage *back_image = NvImageNamed(@"icon_back");
    self.backButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:back_image];
    self.backButton.frame = CGRectMake(0, 0, 30, 44);
    self.backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15*SCREENSCALE, 0, 0);
    [self.backButton addTarget:self action:@selector(leftNavButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return self.backButton;
}
/**
 需要自定义返回事件,子类需要重载这个方法
 Custom return events are needed, and subclasses need to override this method
 */
- (void)leftNavButtonClick:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - keep portrait
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return  UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
