//
//  NvNavigationController.m
//  NvCompositionDemo
//
//  Created by 美摄 on 2022/1/19.
//

#import "NvNavigationController.h"

@interface NvNavigationController ()

@end

@implementation NvNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

@end
