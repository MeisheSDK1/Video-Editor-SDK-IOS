//
//  NvSearchBar.m
//  SDKDemo
//
//  Created by chengww on 2020/11/27.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvSearchBar.h"
#import "NVDefineConfig.h"


#define Max_Value 40

struct NVTitleInfo {
    NSInteger length;
    NSInteger number;
};
@interface NvSearchBarInputView : UITextField
@property (nonatomic, assign) BOOL enableTouch;
@end

@interface NvSearchBar ()<UITextFieldDelegate>
@property (nonatomic, strong) NvSearchBarOption *config;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) NvSearchBarInputView *searchTextField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, copy, readwrite) NSString *inputText;
@property (nonatomic, assign, readwrite) CGFloat searchBarHeight;
@end

@implementation NvSearchBar

- (instancetype)initWithFrame:(CGRect)frame options:(NvSearchBarOption *)opt {
    if (self = [super initWithFrame:frame]) {
        self.config = opt;
        self.searchBarHeight = opt.barSize.height;
        self.backgroundColor = opt.barBackgroundColor;
        [self nv_layoutSubviews];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nv_didTapSearchBarEvent)]];
    }
    return self;
}

#pragma mark - 初始化界面
/*
 初始化界面
 Initialize the interface
 
 */
- (void)nv_layoutSubviews {
    [self insertSubview:self.bgImageView atIndex:0];
    self.bgImageView.frame = CGRectMake(self.config.barInsets.left, self.config.barInsets.top, self.frame.size.width - self.config.barInsets.left - self.config.barInsets.right, self.frame.size.height - self.config.barInsets.top - self.config.barInsets.bottom);
    
    [self.bgImageView addSubview:self.searchTextField];
    self.searchTextField.frame = self.bgImageView.bounds;
    if (self.config.searchImage != nil) {
        UIView *leftView = [[UIView alloc] init];
        leftView.frame = CGRectMake(0, 0, self.config.searchImage.size.width + 2 + self.config.placeHolderOffset, self.frame.size.height);
        UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.config.searchImage.size.width + 2, self.frame.size.height)];
        searchIcon.image = self.config.searchImage;
        searchIcon.contentMode = UIViewContentModeScaleAspectFit;
        [leftView addSubview:searchIcon];
        self.searchTextField.leftView = leftView;
        self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    NSMutableAttributedString *placeHolder = [[NSMutableAttributedString alloc] initWithString:self.config.placeHolderText];
    [placeHolder addAttribute:NSForegroundColorAttributeName value:self.config.placeHolderColor range:NSMakeRange(0, self.config.placeHolderText.length)];
    [placeHolder addAttribute:NSFontAttributeName value:self.config.placeHolderFont range:NSMakeRange(0, self.config.placeHolderText.length)];
    self.searchTextField.attributedPlaceholder = placeHolder;
    self.searchTextField.enableTouch = self.isEnableSearch;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.textColor = self.config.textColor;
    self.searchTextField.tintColor = self.config.textColor;
    self.searchTextField.font = self.config.textFont;
    self.searchTextField.clearButtonMode = UITextFieldViewModeAlways;
    
    /*
     textField变化时事件
     Event when textField changes
     */
    [_searchTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    self.searchTextField.delegate = self;
    /*
     取消按钮
     Cancel button
     */
    [self addSubview:self.cancelButton];
    self.cancelButton.frame = CGRectMake(self.frame.size.width - self.config.cancelWidth - self.config.barInsets.right, self.config.barInsets.top, 0, self.bgImageView.frame.size.height);
    [self.cancelButton setTitle:self.config.cancelText forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:self.config.cancelTextColor forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = self.config.cancelTextFont;
    self.cancelButton.backgroundColor = self.config.barBackgroundColor;
    [self.cancelButton addTarget:self action:@selector(nv_didTapCancelEvent) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        self.bgImageView.frame = CGRectMake(self.config.barInsets.left, self.config.barInsets.top, self.frame.size.width - self.config.barInsets.left - self.config.barInsets.right - self.config.cancelWidth, self.frame.size.height - self.config.barInsets.top - self.config.barInsets.bottom);
        self.searchTextField.frame = self.bgImageView.bounds;
        self.cancelButton.frame = CGRectMake(self.frame.size.width - self.config.cancelWidth - self.config.barInsets.right, self.config.barInsets.top, self.config.cancelWidth + self.config.barInsets.right, self.bgImageView.frame.size.height);
    } completion:^(BOOL finished) {
        self.cancelButton.hidden = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarBeginEditing:)]) {
            [self.delegate searchBarBeginEditing:self];
        }
    }];
    return  YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        self.bgImageView.frame = CGRectMake(self.config.barInsets.left, self.config.barInsets.top, self.frame.size.width - self.config.barInsets.left - self.config.barInsets.right, self.frame.size.height - self.config.barInsets.top - self.config.barInsets.bottom);
        self.searchTextField.frame = self.bgImageView.bounds;
        self.cancelButton.hidden = YES;
    } completion:^(BOOL finished) {
        self.cancelButton.frame = CGRectMake(self.frame.size.width - self.config.cancelWidth - self.config.barInsets.right, self.config.barInsets.top, 0, self.bgImageView.frame.size.height);
    }];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString * changedString=[[NSMutableString alloc]initWithString:textField.text];
        
    [changedString replaceCharactersInRange:range withString:string];
    self.inputText = changedString;
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarTextInputDidChanged:)]) {
        [self.delegate searchBarTextInputDidChanged:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.inputText = textField.text;
}

#pragma mark - 限制标题长度，数字及英文1，中文及中文符号2
/*
 限制标题长度，数字及英文1，中文及中文符号2
 Limit title length, numbers and English 1, Chinese and Chinese symbols 2
 
 @param textField 输入框 textField
 
 */
- (void)textFieldEditingChanged:(UITextField *)textField{
    struct NVTitleInfo title = [self getInfoWithText:textField.text maxLength:Max_Value];
    if (title.length > Max_Value) {
        textField.text = [textField.text substringToIndex:title.number];
    }
}


- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.inputText = @"";
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarTextInputDidChanged:)]) {
        [self.delegate searchBarTextInputDidChanged:self];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarBeginSearch:)]) {
        [self.delegate searchBarBeginSearch: self];
    }
    return YES;
}

#pragma mark - 点击取消按钮
/*
 点击取消按钮
 Click the cancel button
 
 */
- (void)nv_didTapCancelEvent {
    [self.searchTextField resignFirstResponder];
    if (self.searchTextField.text.length > 0) {
        self.searchTextField.text = @"";
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarDidCanceled:)]) {
        [self.delegate searchBarDidCanceled:self];
    }
}

#pragma mark - 开始编辑
/*
 开始编辑
 Start editing
 
 */
- (void)nv_didTapSearchBarEvent {
    if (!self.isEnableSearch) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarBeginEditing:)]) {
            [self.delegate searchBarBeginEditing: self];
        }
    }
}
#pragma mark - Set & Get
- (void)setIsEnableSearch:(BOOL)isEnableSearch {
    _isEnableSearch = isEnableSearch;
    self.searchTextField.enableTouch = isEnableSearch;
}

- (void)setFirstResponder:(BOOL)firstResponder {
    _firstResponder = firstResponder;
    if (firstResponder) {
        [self.searchTextField becomeFirstResponder];
    }else {
        [self.searchTextField resignFirstResponder];
    }
}

#pragma mark - LAZY
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.backgroundColor = self.config.barTintColor;
        _bgImageView.layer.cornerRadius = 3 * SCREENSCALE;
        _bgImageView.layer.masksToBounds = YES;
        _bgImageView.userInteractionEnabled = YES;
    }
    return _bgImageView;
}
- (NvSearchBarInputView *)searchTextField {
    if (!_searchTextField) {
        _searchTextField = [[NvSearchBarInputView alloc] init];
    }
    return _searchTextField;
}
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        _cancelButton.hidden = YES;
    }
    return _cancelButton;
}

#pragma mark - 判断中英混合的的字符串长度及字符个数
/*
 判断中英混合的的字符串长度及字符个数
 Determine the length and number of characters in a mixed Chinese-English string
 
 @param text 文字 text
 @param maxLength 字符串长度 String length
 
 */
- (struct NVTitleInfo)getInfoWithText:(NSString *)text maxLength:(NSInteger)maxLength{
    struct NVTitleInfo title;
    int length = 0;
    int singleNum = 0;
    int totalNum = 0;
    char *p = (char *)[text cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0; i < [text lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            length++;
            if (length <= maxLength) {
                totalNum++;
            }
        }else {
            if (length <= maxLength) {
                singleNum++;
            }
        }
        p++;
    }
    title.length = length;
    title.number = (totalNum - singleNum) / 2 + singleNum;
    return title;
}


@end

@implementation NvSearchBarInputView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.enableTouch = YES;
    }
    return self;
}
- (instancetype)init {
    if (self = [super init]) {
        self.enableTouch = YES;
    }
    return self;
}

#pragma mark - 修改leftView左边距 Change the left margin of the leftView
- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += 13.5 * SCREENSCALE;
    return iconRect;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL flags = [super pointInside:point withEvent:event];
    return  self.enableTouch ? flags : false;
}

@end

@implementation NvSearchBarOption

- (instancetype)init {
    if (self = [super init]) {
        self.barInsets = UIEdgeInsetsZero;
        self.searchImagePositon = NvSearchBarPosition_Left;
    }
    return self;
}

@end
