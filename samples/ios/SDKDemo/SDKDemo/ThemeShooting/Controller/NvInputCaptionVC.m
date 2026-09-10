//
//  NvInputCaptionVC.m
//  SDKDemo
//
//  Created by ms20180425 on 2020/8/5.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvInputCaptionVC.h"
#import "NVHeader.h"

@interface NvInputCaptionVC ()

@property (nonatomic,strong)UITextField* textField;

@end

@implementation NvInputCaptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NvLocalString(@"Edit Text", @"编辑文字");
    [self addExportBtn];
    
    self.textField = [[UITextField alloc] init];
    self.textField.backgroundColor = UIColor.clearColor;
    self.textField.textColor = UIColor.whiteColor;
    self.textField.text = self.text;
    self.textField.font = [UIFont systemFontOfSize:12*SCREENSCALE];
    [self.view addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NV_STATUSBARHEIGHT + NV_NAV_BAR_HEIGHT+30*SCREENSCALE);
        make.left.equalTo(self.view).offset(40 * SCREENSCALE);
        make.right.equalTo(self.view).offset(-40 * SCREENSCALE);
        make.centerX.equalTo(self.view);
        make.height.offset(50*SCREENSCALE);
    }];
}

- (UIView *)leftNavigationBarItemView {
    UIButton *backButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Cancel", @"取消") textColor:[UIColor nv_colorWithHexRGB:@"#8B8B8B"] fontSize:12 image:nil];
    backButton.frame = CGRectMake(0, 0, 30, 44);
    __weak typeof(self)weakSelf = self;
    [backButton nv_BtnClickHandler:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    return backButton;
}

#pragma mark - 添加导入按钮
///Add import button
- (void)addExportBtn{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [rightBtn setTitle:NvLocalString(@"Complete", @"完成") forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#8B8B8B"] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:12*SCREENSCALE];
    [rightBtn addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.exclusiveTouch = YES;
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50*SCREENSCALE, 27*SCREENSCALE)];
    rightView.backgroundColor = UIColor.clearColor;
    rightBtn.frame = CGRectMake(0, 0, 50*SCREENSCALE, 27*SCREENSCALE);
    [rightView addSubview:rightBtn];

    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

#pragma mark - rightBtnClicked
- (void)rightBtnClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputCaptionVC:saveText:)]) {
        [self.delegate inputCaptionVC:self saveText:self.textField.text];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
