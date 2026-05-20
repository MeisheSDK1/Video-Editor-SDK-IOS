//
//  NvFlipCaptionColorViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvFlipCaptionColorViewController.h"
#import "NVHeader.h"
#import "NvFlipCaptionColor.h"
#import "NvFlipCaptionModel.h"

@interface NvFlipCaptionColorViewController ()

@property (nonatomic, strong) NvFlipCaptionColor *colorView;

@end

@implementation NvFlipCaptionColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    self.colorView = [NvFlipCaptionColor new];
    self.colorView.colorViewToParentSpacing = 20;
    self.colorView.delegate = self;
    [self.view addSubview:self.colorView];
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

#pragma mark - ColorViewDelegate
- (void)flipCaptionColor:(NvFlipCaptionColor *)colorView didSelectItem:(NvCaptionColorItem *)item {
    if ([self.delegate respondsToSelector:@selector(flipCaptionColorViewController:didSelectItem:)]) {
        [self.delegate flipCaptionColorViewController:self didSelectItem:item];
    }
}

- (void)flipCaptionColor:(NvFlipCaptionColor *)colorView okClickItem:(NvCaptionColorItem *)item {
    if ([self.delegate respondsToSelector:@selector(flipCaptionColorViewController:okClickItem:)]) {
        [self.delegate flipCaptionColorViewController:self okClickItem:item];
    }
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
