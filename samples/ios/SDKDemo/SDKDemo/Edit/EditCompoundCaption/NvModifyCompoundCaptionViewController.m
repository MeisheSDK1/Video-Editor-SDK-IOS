//
//  NvModifyCompoundCaptionViewController.m
//  SDKDemo
//  复合字幕编辑修改界面 Composite subtitle editing and modification interface
//  Created by MS on 2019/5/20.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvModifyCompoundCaptionViewController.h"
#import "NvModifyCompoundCaptionView.h"
#import "NvEditCompoundCaptionViewController.h"
#import <NvBaseCommon/UIColor+NvColor.h>

@interface NvModifyCompoundCaptionViewController ()<NvModifyCompoundCaptionViewDelegate>
@property(nonatomic, strong) NvModifyCompoundCaptionView *compoundCaptioView;
@end

@implementation NvModifyCompoundCaptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    self.title = NvLocalString(@"CompoundCaption", @"组合字幕");
    [self.view addSubview:self.compoundCaptioView];
    self.compoundCaptioView.caption = self.caption;
    self.compoundCaptioView.fontDataArr = self.fontDataArr;
    self.compoundCaptioView.selectedIndex = self.selectedIndex;
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInView)];
    [self.navigationController.navigationBar addGestureRecognizer:recog];
}

- (void)viewDidAppear:(BOOL)animated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.compoundCaptioView.textView becomeFirstResponder];
    });
}

///取消键盘
///Cancel keyboard
- (void)tapInView {
    [self.compoundCaptioView.textView resignFirstResponder];
}

#pragma mark - NvModifyCompoundCaptionViewDelegate
- (void)confirmButtonClicked:(UIButton *)button model:(NvCompoundCaptionModel *)model {
    NSArray *controllerArr = self.navigationController.viewControllers;
    for(UIViewController *controller in controllerArr) {
        if ([controller isMemberOfClass:[NvEditCompoundCaptionViewController class]]) {
            NvEditCompoundCaptionViewController *vc = (NvEditCompoundCaptionViewController *)controller;
            vc.compoundCaptionModel = model;
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

- (void)cancelButtonClicked:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - lazyload
- (NvModifyCompoundCaptionView *)compoundCaptioView {
    if (!_compoundCaptioView) {
        _compoundCaptioView = [[NvModifyCompoundCaptionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _compoundCaptioView.delegate = self;
    }
    return _compoundCaptioView;
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
