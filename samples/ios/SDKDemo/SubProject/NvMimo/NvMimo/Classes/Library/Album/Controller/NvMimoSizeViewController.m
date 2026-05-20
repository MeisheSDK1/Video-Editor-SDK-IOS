//
//  NvSizeViewController.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMimoSizeViewController.h"
#import <Masonry/Masonry.h>
#import "NvMimoToast.h"

@interface NvMimoSizeViewController ()<NvMimoSizeViewDelegate>

@property (nonatomic, copy) void(^type)(NvMimoEditMode type);


@end

@implementation NvMimoSizeViewController {
    UILabel *label;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
    self.sizeView = [[NvMimoSizeView alloc] init];
    self.sizeView.delegate = self;
    [self.view addSubview:self.sizeView];
    [self.sizeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(148*SCREANSCALEHEIGHT));
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(266*SCREANSCALE));
        make.height.equalTo(@(296*SCREANSCALE));
    }];
    self.sizeView.layer.cornerRadius = 8*SCREANSCALE;
    self.sizeView.layer.masksToBounds = YES;
    self.sizeView.supportedAspectRatio = self.supportedAspectRatio;
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self dismissViewControllerAnimated:NO completion:NULL];
}

- (void)selectSizeTypeBlock:(void(^)(NvMimoEditMode type))block {
    self.type = block;
}

- (void)nvSizeView:(NvMimoSizeView *)nvSizeView selectType:(NvMimoEditMode)type {
    [NvMimoToast showLoading];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.type) {
            self.type(type);
            [NvMimoToast dismiss];
        }
        [self dismissViewControllerAnimated:NO completion:NULL];
    });    
}

- (void)setSupportedAspectRatio:(NSString *)supportedAspectRatio {
    _supportedAspectRatio = supportedAspectRatio;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
