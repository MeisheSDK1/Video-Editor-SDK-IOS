//
//  NvSearchViewController.m
//  SDKDemo
//
//  Created by chengww on 2020/11/27.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvSearchViewController.h"
#import "NvSearchBar.h"
#import <NvSDKCommon/NvUtils.h>

@interface NvSearchViewController ()<NvSearchBarDelegate>
@property (nonatomic, strong, readwrite) NvSearchBar *searchBar;
@property (nonatomic, strong, readwrite) UIViewController *predicateController;
@property (nonatomic, strong) NvSearchBarOption *configuare;
@end

@implementation NvSearchViewController

- (instancetype)initWithPredicateController:(UIViewController *)controller searchBarConfiguare:(NvSearchBarOption *)options {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.predicateController = controller;
        self.configuare = options;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.configuare.barBackgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [NvUtils fontWithSize:16], NSFontAttributeName, nil]];
    
    [self nv_layoutSubviews];
}

#pragma mark - 点击取消搜索 Click cancel search
- (void)searchBarDidCanceled:(NvSearchBar *)searchBar {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 监听输入的文本 Listen for input text
- (void)searchBarTextInputDidChanged: (NvSearchBar *)searchBar {
    
}

- (void)nv_layoutSubviews{
    self.searchBar = [[NvSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.configuare.barSize.width, self.configuare.barSize.height) options:self.configuare];
    self.searchBar.delegate = self;
    self.searchBar.isEnableSearch = YES;
    [self.view addSubview:self.searchBar];
    
    UIView *nvBackgroundView = [[UIView alloc] init];
    nvBackgroundView.backgroundColor = [UIColor clearColor];
    nvBackgroundView.frame = CGRectMake(0, CGRectGetMaxY(self.searchBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.searchBar.frame));
    [self.view addSubview:nvBackgroundView];
    self.predicateController.view.frame = nvBackgroundView.bounds;
    [nvBackgroundView addSubview:self.predicateController.view];
}
@end
