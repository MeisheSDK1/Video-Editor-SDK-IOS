//
//  NvBaseViewController.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/24.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvBaseViewController.h"
#import <NVDefineConfig.h>
#import <UIColor+NvColor.h>
#import <UIButton+NvButton.h>
#import <NvBaseUtils.h>

@interface NvBaseViewController ()

@end

@implementation NvBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0x242728);
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"], NSForegroundColorAttributeName, [NvBaseUtils fontWithSize:16], NSFontAttributeName, nil]];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self leftNavigationBarItemView]];
    self.navigationItem.leftBarButtonItem = backButtonItem;
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self compatibleWithIOS26Features];
}

- (void)compatibleWithIOS26Features {
    if (@available(iOS 26.0, *)) {
        self.navigationItem.leftBarButtonItem.hidesSharedBackground = YES;
        self.navigationItem.rightBarButtonItem.hidesSharedBackground = YES;
    }
}

- (UIView *)leftNavigationBarItemView {
    UIImage *image = [UIImage imageNamed:@"icon_back" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    if (!image) {
        image = [UIImage imageNamed:@"icon_back"];
    }
    
    self.backButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:image];
    self.backButton.frame = CGRectMake(0, 0, 30, 44);
    self.backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15*SCREENSCALE, 0, 0);
    [self.backButton addTarget:self action:@selector(leftNavButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.exclusiveTouch = YES;
    return self.backButton;
}

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

- (void)leftNavButtonClick:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
