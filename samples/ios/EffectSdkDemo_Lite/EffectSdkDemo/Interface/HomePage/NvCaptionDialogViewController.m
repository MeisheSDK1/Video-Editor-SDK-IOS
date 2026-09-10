//
//  NvCaptionDialogViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2019/3/28.
//  Copyright © 2019年 meishe. All rights reserved.
//

#import "NvCaptionDialogViewController.h"
#import "Masonry.h"
#import "NvUtils.h"

@interface NvCaptionDialogViewController ()

@property (nonatomic, strong) NvCaptionDialog *changeDialog;
@property (nonatomic, strong) NSString *captionText;

@end

@implementation NvCaptionDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.changeDialog = [[[NSBundle mainBundle] loadNibNamed:@"CaptionDialog" owner:self options:nil] firstObject];
    [self.view addSubview:self.changeDialog];
    self.changeDialog.delegate = self;
    [self.changeDialog mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(@(80*SCREENSCALE));
        make.width.equalTo(@(320*SCREENSCALE));
        make.height.equalTo(@(180*SCREENSCALE));
    }];
    if (self.captionText.length>0) {
        [self.changeDialog setCaptionText:self.captionText];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}
    
- (NSString *)getCaptionText {
    return [self.changeDialog getCaptionText];
}
    
- (void)setCaptionText:(NSString *)text {
    _captionText = text;
    [self.changeDialog setCaptionText:text];
}

- (void)captionDialog:(NvCaptionDialog *)captionDialog clickButtonIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(captionDialog:clickButtonIndex:)]) {
        [self.delegate captionDialog:self clickButtonIndex:index];
    }
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
