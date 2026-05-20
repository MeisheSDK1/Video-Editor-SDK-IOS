//
//  NVViewController.m
//  NvFlashEffect
//
//  Created by chuyang009@163.com on 05/25/2021.
//  Copyright (c) 2021 chuyang009@163.com. All rights reserved.
//

#import "NVViewController.h"
#import <NvFlashEffect/NvFlashEffectViewController.h>

@interface NVViewController ()

@end

@implementation NVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)click:(UIButton *)sender {
    NvFlashEffectViewController *flash = [NvFlashEffectViewController new];
    [self.navigationController pushViewController:flash animated:true];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
