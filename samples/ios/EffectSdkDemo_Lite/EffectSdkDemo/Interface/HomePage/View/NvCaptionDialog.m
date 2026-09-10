//
//  NvCaptionDialog.m
//  Caption
//
//  Created by 刘东旭 on 2017/8/18.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import "NvCaptionDialog.h"
#import "NvConstant.h"

#import "NVDefineConfig.h"

@interface NvCaptionDialog ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sureBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelBtn;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *sure;
@property (weak, nonatomic) IBOutlet UIButton *cancle;
//是否是用户输入文字
// User input
@property (nonatomic, assign) BOOL userText;
@end

@implementation NvCaptionDialog
- (void)awakeFromNib {
    [super awakeFromNib];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.text = NvLocalString(@"CaptionText",nil);
    [self.sure setTitle:NvLocalString(@"Sure",nil) forState:UIControlStateNormal];
    [self.cancle setTitle:NvLocalString(@"cancel",nil) forState:UIControlStateNormal];
    self.userText = NO;
    [self.sure addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancle addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearText) name:UIKeyboardWillShowNotification object:nil];
    [self.sure setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.sure.enabled = false;
    self.textView.delegate = self;
//    [self.textView becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextViewTextDidChangeNotification object:nil];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self.sure setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.sure.enabled = true;
    if (!self.userText) {
        textView.text = @"";
    }
    textView.textColor = [UIColor blackColor];
    return true;
}

- (void)textChange:(NSNotification *)noti {
    if (noti.object == self.textView) {
        NSString* text = self.textView.text;
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(text.length == 0) {
            [self.sure setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.sure.enabled = NO;
        } else {
            [self.sure setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.sure.enabled = YES;
        }
    }
}

- (void)clearText {
    
    if ([self.textView.text isEqualToString:NvLocalString(@"CaptionText", @"请输入字幕")]) {
        self.textView.text = @"";
    }
}

- (void)sureClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(captionDialog:clickButtonIndex:)]) {
        [self.delegate captionDialog:self clickButtonIndex:0];
    }
}

- (void)cancelClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(captionDialog:clickButtonIndex:)]) {
        [self.delegate captionDialog:self clickButtonIndex:1];
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    self.captionTop.constant = 33*SCREENSCALE;
    self.captionLeft.constant = 23*SCREENSCALE;
    self.captionRight.constant = 23*SCREENSCALE;
    self.sureBtn.constant = 44*SCREENSCALE;
    self.cancelBtn.constant = 44*SCREENSCALE;
}

- (NSString *)getCaptionText {
    return self.textView.text;
}

- (void)setCaptionText:(NSString *)text {
    self.userText = YES;
    self.textView.text = text;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
