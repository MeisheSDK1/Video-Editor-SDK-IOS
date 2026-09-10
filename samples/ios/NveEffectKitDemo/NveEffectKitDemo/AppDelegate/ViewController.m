//
//  ViewController.m
//  NvCompositionDemo
//
//  Created by 美摄 on 2021/11/26.
//

#import "ViewController.h"
#import "NvCaptureViewController.h"

@interface ViewController ()

@property(weak, nonatomic) IBOutlet UIView *captureView;
@property(weak, nonatomic) IBOutlet UIButton *captureBt;

@property(weak, nonatomic) IBOutlet UIButton *settingBt;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = self.view.bounds;
    gl.startPoint = CGPointMake(0.5, 0);
    gl.endPoint = CGPointMake(0.5, 1);
    gl.colors = @[
        (__bridge id)[UIColor colorWithRed:28 / 255.0 green:28 / 255.0 blue:28 / 255.0 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:28 / 255.0 green:20 / 255.0 blue:71 / 255.0 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:28 / 255.0 green:54 / 255.0 blue:88 / 255.0 alpha:1.0].CGColor
    ];
    gl.locations = @[@(0), @(0.6f), @(1.0f)];
    [self.view.layer insertSublayer:gl atIndex:0];

    [self.captureBt setTitle:@"" forState:(UIControlStateNormal)];
    self.captureView.layer.cornerRadius = 10;

    self.settingBt.hidden = YES;
}

- (IBAction)captureBtClicked:(UIButton *)sender {
    NvCaptureViewController *captureVc = [[NvCaptureViewController alloc] init];
    [self.navigationController pushViewController:captureVc animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)settingBtClicked:(UIButton *)bt {
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
