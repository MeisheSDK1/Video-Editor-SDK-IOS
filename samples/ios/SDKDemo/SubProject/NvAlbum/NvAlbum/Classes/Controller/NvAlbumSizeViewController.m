//
//  NvSizeViewController.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvAlbumSizeViewController.h"
#import "NvAlbumSizeView.h"
#import <Masonry/Masonry.h>
#import "NvAlbumToast.h"
#import <NvBaseCommon/NVDefineConfig.h>
@interface NvAlbumSizeViewController ()<NvAlbumSizeViewDelegate>

@property (nonatomic, copy) void(^type)(NvEditMode type);
@property (nonatomic, strong) NvAlbumSizeView *sizeView;

@end

@implementation NvAlbumSizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
    self.sizeView = [[NvAlbumSizeView alloc] init];
    self.sizeView.delegate = self;
    [self.view addSubview:self.sizeView];
    [self.sizeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(148*SCREENSCALEHEIGHT));
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(266*SCREENSCALE));
        make.height.equalTo(@(345*SCREENSCALE));
    }];
    self.sizeView.layer.cornerRadius = 8*SCREENSCALE;
    self.sizeView.layer.masksToBounds = YES;
    
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self dismissViewControllerAnimated:NO completion:NULL];
}

- (void)selectSizeTypeBlock:(void(^)(NvEditMode type))block {
    self.type = block;
}

- (void)nvSizeView:(NvAlbumSizeView *)nvSizeView selectType:(NvEditMode)type {
    
    if (self.type) {
        self.type(type);
    }
    [self dismissViewControllerAnimated:NO completion:NULL];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
