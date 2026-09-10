//
//  NVPIPViewController.m
//  NvPIPEdit
//
//  Created by chuyang009@163.com on 05/28/2021.
//  Copyright (c) 2021 chuyang009@163.com. All rights reserved.
//

#import "NVPIPViewController.h"
#import <NvPIPEdit/NvPIPThemeItem.h>
#import <NvPIPEdit/NvPIPEditViewController.h>
#import <NvAlbum/NvAlbum.h>

@interface NVPIPViewController ()

@end

@implementation NVPIPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)pipClick:(UIButton *)sender {
    NvPIPEditViewController *pipVC = [NvPIPEditViewController new];
    [self.navigationController pushViewController:pipVC animated:true];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
