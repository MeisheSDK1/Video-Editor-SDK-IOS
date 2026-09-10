//
//  NvAlbumSizeViewController.m
//  meishe
//
//  Created by 刘东旭 on 2019/5/29.
//  Copyright © 2019 刘东旭. All rights reserved.
//

#import "NvAlbumProgressViewController.h"
#import "NvAlbumCircleView.h"
#import "UIView+Dimension.h"
#import "NvAlbumUtils.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREENSCALE ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? SCREENWIDTH / 768.0 : SCREENWIDTH / 375.0)


@interface NvAlbumProgressViewController ()

@property (nonatomic, strong) NvAlbumCircleView *circleView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, copy) void(^cancelBlock)(void);

@end

@implementation NvAlbumProgressViewController

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    self.circleView = [[NvAlbumCircleView alloc] initWithFrame:CGRectMake(220, 100, 60, 60)];
    [self.view addSubview:self.circleView];
    self.circleView.center = self.view.center;
    self.cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.circleView.centerX-20, self.circleView.bottom + 15, 40, 40)];
    self.cancelBtn.hidden = NO;
    [self.cancelBtn setImage:[UIImage imageNamed:@"NvCancelCompile" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.view addSubview:self.cancelBtn];
    [self.cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)setTitleStr:(NSString *)titleStr {
    _titleStr = titleStr;
    self.numLabel.text = titleStr;
}

- (void)cancelBtnClicked {
    if (self.cancelBlock) {
        self.cancelBlock();        
    }
}

- (void)setCancelBlock:(void(^)(void))block {
    _cancelBlock = block;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    self.circleView.progress = progress;
}

- (UILabel *)numLabel {
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 30*SCREENSCALE)];
        _numLabel.backgroundColor = [UIColor clearColor];
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.centerX = self.view.centerX;
        _numLabel.bottom = self.circleView.top - 15;
        _numLabel.font = [NvAlbumUtils fontWithSize:15.f];
        _numLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_numLabel];
    }
    return _numLabel;
}

@end
