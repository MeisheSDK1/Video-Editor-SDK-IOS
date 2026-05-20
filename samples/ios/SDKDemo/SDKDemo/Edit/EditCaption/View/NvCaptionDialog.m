//
//  NvCaptionDialog.m
//  Caption
//
//  Created by 刘东旭 on 2017/8/18.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import "NvCaptionDialog.h"
#import "NvLocalString.h"


@interface NvCaptionDialog ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sureBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelBtn;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *sure;
@property (weak, nonatomic) IBOutlet UIButton *cancle;
///是否是用户输入文字
///Whether the user input text
@property (nonatomic, assign) BOOL userText;
@end

@implementation NvCaptionDialog
- (void)awakeFromNib {
    [super awakeFromNib];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.text = NvLocalString(@"CaptionText",nil);
    [self.sure setTitle:NvLocalString(@"Sure",nil) forState:UIControlStateNormal];
    [self.cancle setTitle:NvLocalString(@"Cancel",nil) forState:UIControlStateNormal];
    self.userText = NO;
    [self.sure addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancle addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearText) name:UIKeyboardWillShowNotification object:nil];
    [self.sure setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.sure.enabled = false;
    self.textView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextViewTextDidChangeNotification object:nil];
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"textLength == %ld",textView.text.length);
    
    if ([self isNineKeyBoard:text]) {
        return YES;
    }
    
    if (_isIgnoreEmoij && ([self stringContainsEmoji:text] == YES || [self hasEmoji:text])) {
        return NO;
    }
    
    return YES;
}

/**
 *  判断字符串中是否存在emoji
 *  Determine if there is an emoji in the string
 * @param string 字符串
 * string
 * @return YES(含有表情)
 * YES(with emoticons)
 */
- (BOOL)hasEmoji:(NSString*)string;
{
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

///是否是系统自带九宫格输入 yes-是 no-不是
///Whether the system comes with the system. Enter yes- Yes no- no
- (BOOL)isNineKeyBoard:(NSString *)string {
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)string.length;
    for(int i=0;i<len;i++){
       if(!([other rangeOfString:string].location != NSNotFound))
          return NO;
    }
    return YES;
}

///过滤所有表情
///Filter all expressions
- (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
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
    if ([self.textView.text isEqualToString:@"请输入字幕"] || [self.textView.text isEqualToString:@"Please enter caption text"]) {
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
