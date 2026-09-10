//
//  ViewController.m
//  NvARSceneFxModule
//
//  Created by ms20180425 on 2022/8/23.
//

#import "ViewController.h"
#import "NvARSceneViewController.h"
#import "NvARLocalString.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:NvBundleLocalString(@"预览", @"preview", [self class]) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = UIColor.orangeColor;
    [self.view addSubview:btn];
    btn.frame = CGRectMake(0, 0, 100, 100);
    btn.center = self.view.center;
}

- (void)btnClick{
    NvARSceneViewController *vc = [[NvARSceneViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
