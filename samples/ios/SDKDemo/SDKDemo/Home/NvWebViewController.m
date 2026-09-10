//
//  NvWebViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2019/9/27.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvWebViewController.h"
#import <NvSDKCommon/NvUtils.h>
#import <NvBaseCommon/UIButton+NvButton.h>
@import WebKit;

@interface NvWebViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation NvWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0x242728);
    if (@available(iOS 15.0, *)) {
        self.navigationController.navigationBar.scrollEdgeAppearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor nv_colorWithHexRGB:@"#000000"], NSFontAttributeName:[NvUtils fontWithSize:16]};
        self.navigationController.navigationBar.scrollEdgeAppearance.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.standardAppearance.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.standardAppearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor nv_colorWithHexRGB:@"#000000"], NSFontAttributeName:[NvUtils fontWithSize:16]};
        
    } else {
        // Fallback on earlier versions
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor nv_colorWithHexRGB:@"#000000"], NSForegroundColorAttributeName, [NvUtils fontWithSize:16], NSFontAttributeName, nil]];
    }
//    nv_sub_close
    [self.backButton setImage:NvImageNamed(@"NvBlackBack") forState:UIControlStateNormal];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - NV_STATUSBARHEIGHT - 44)];
    [self.view addSubview:self.webView];
    self.webView.navigationDelegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    [self.webView loadRequest:request];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (@available(iOS 15.0, *)) {
        self.navigationController.navigationBar.scrollEdgeAppearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[NvUtils fontWithSize:16]};
        self.navigationController.navigationBar.scrollEdgeAppearance.backgroundColor = [UIColor blackColor];
        self.navigationController.navigationBar.standardAppearance = [[UINavigationBarAppearance alloc] init];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    self.title = self.webView.title;
}

-(void)setUrlString:(NSString *)urlString {
    _urlString = urlString;
    if (!_webView) {
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    [self.webView loadRequest:request];
}

- (void)leftNavButtonClick:(UIButton *)button {
    
    if ([self.webView canGoBack]) {
        
        [self.webView goBack];
    } else {
        
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)rightNavButtonClick:(UIButton *)button {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    [self.webView loadRequest:request];
}

- (UIView *)rightNavigationBarItemView {
    self.rightButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"NvRefrash")];
    self.rightButton.frame = CGRectMake(0, 0, 30, 44);
    self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15*SCREENSCALE, 0, 0);
    [self.rightButton addTarget:self action:@selector(rightNavButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return self.rightButton;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

@end
