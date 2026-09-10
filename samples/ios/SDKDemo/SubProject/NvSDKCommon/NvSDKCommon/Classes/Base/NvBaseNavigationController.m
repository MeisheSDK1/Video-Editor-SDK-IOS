//
//  NvBaseNavigationController.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/24.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvBaseNavigationController.h"
#import <NvSDKCommon/NvUtils.h>
@interface NvBaseNavigationController ()

@end

@implementation NvBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.enabled = NO;
    self.navigationBar.translucent = NO;
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appear = [[UINavigationBarAppearance alloc] init];
        appear.titleTextAttributes = @{NSForegroundColorAttributeName:UIColor.whiteColor, NSFontAttributeName:[NvUtils fontWithSize:16]};
        appear.backgroundColor = [UIColor blackColor];
        appear.backgroundEffect = nil;
        appear.shadowColor = [UIColor clearColor];
        self.navigationBar.scrollEdgeAppearance = appear;
    }else{
        [self.navigationBar setBarTintColor:[UIColor blackColor]];
        [self.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.whiteColor, NSFontAttributeName:[NvUtils fontWithSize:16]}];
    }
}

- (BOOL)shouldAutorotate{
    
    return [self.viewControllers.lastObject shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return  [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController* topVC = self.topViewController;
    return [topVC preferredStatusBarStyle];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
