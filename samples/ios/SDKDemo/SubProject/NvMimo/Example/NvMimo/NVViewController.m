//
//  NVViewController.m
//  NvMimo
//
//  Created by chuyang009@163.com on 05/19/2021.
//  Copyright (c) 2021 chuyang009@163.com. All rights reserved.
//

#import "NVViewController.h"
#import "NvMimoListViewController.h"
#import <Masonry/Masonry.h>
#define SCREANSCALE [UIScreen mainScreen].bounds.size.width / 375.0
#define SCREANWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREANHEIGHT [UIScreen mainScreen].bounds.size.height
#define NV_STATUSBARHEIGHT [UIApplication sharedApplication].statusBarFrame.size.height

@interface NVViewController ()

@end

@implementation NVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubviews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)addSubviews {
    UIImageView *bgImageView = [[UIImageView alloc]init];
    bgImageView.image = [UIImage imageNamed:@"NvHomeBg"];
    bgImageView.userInteractionEnabled = YES;
    [self.view addSubview:bgImageView];
    
    UIImageView *logoImageView = [[UIImageView alloc]init];
    logoImageView.image = [UIImage imageNamed:@"NvHomeBgLogo"];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:logoImageView];
    
    UIView *productView = [[UIView alloc] init];
    [self.view addSubview:productView];
    UILabel *productLabel = [[UILabel alloc] init];
    [productView addSubview:productLabel];
    productLabel.font = [UIFont systemFontOfSize:14.f*SCREANSCALE];
    productLabel.textAlignment = NSTextAlignmentCenter;
    productLabel.textColor = [UIColor whiteColor];
    productLabel.text = NSLocalizedString(@"Start making", @"开始制作");
    UIImageView *productImgView = [[UIImageView alloc] init];
    productImgView.userInteractionEnabled = YES;
    [productView addSubview:productImgView];
    productImgView.image = [UIImage imageNamed:@"NvStartProduct"];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startMake)];
    [productView addGestureRecognizer:tapGes];
    
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(34 * SCREANSCALE + NV_STATUSBARHEIGHT);
        make.left.equalTo(self.view.mas_left).offset(13 * SCREANSCALE);
        make.width.offset(105 * SCREANSCALE);
        make.height.offset(44 * SCREANSCALE);
    }];
    
    [productView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.mas_equalTo(77.f);
        make.height.mas_equalTo(110.f);
    }];
    
    [productImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(productView.mas_top);
        make.centerX.equalTo(productView.mas_centerX);
        make.width.mas_equalTo(77.f);
        make.height.mas_equalTo(77.f);
    }];
    
    [productLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(productImgView.mas_bottom).offset(8.f);
        make.left.equalTo(productView.mas_left);
        make.right.equalTo(productView.mas_right);
        make.bottom.equalTo(productView.mas_bottom);
    }];
}

- (void)startMake {
    NvMimoListViewController *vc = [NvMimoListViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
