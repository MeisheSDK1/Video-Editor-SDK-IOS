//
//  NvTipTransitionViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/19.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvTipTransitionViewController.h"
#import "NvTipsView.h"
#import <NvBaseCommon/NvLocalString.h>
#import <NvBaseCommon/UIColor+NvColor.h>

@interface NvTipTransitionViewController ()

@property (nonatomic, strong) UIView *compileView;

@end

@implementation NvTipTransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    self.compileView = [[UIView alloc] initWithFrame:self.view.frame];
    self.compileView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
    [self.view addSubview:self.compileView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NVWeakSelf
    [UIAlertController presentAlertFromVC:self
                                    title:NvLocalString(@"Tips", @"提示")
                                  message:NvLocalString(@"TransitionTip", @"2个以上素材可添加转场")
                        buttonTitleColors:nil
                        cancelButtonTitle:nil
                         otherButtonTitle:NvLocalString(@"Know", @"知道了")
                       cancelButtonAction:nil
                        otherButtonAction:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf dismissViewControllerAnimated:NO completion:NULL];
    }];
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

- (void)clickBtnClicked {
    [self dismissViewControllerAnimated:NO completion:NULL];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
