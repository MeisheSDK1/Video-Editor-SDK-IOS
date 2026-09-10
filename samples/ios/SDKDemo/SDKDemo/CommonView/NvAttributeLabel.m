//
//  NvAttributeLabel.m
//  SDKDemo
//
//  Created by chengww on 2020/7/29.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvAttributeLabel.h"
@interface NvTextView : UITextView
@end

@interface NvAttributeLabel ()<UITextViewDelegate>

@property (nonatomic, weak) NvTextView *textView;

@end

@implementation NvAttributeLabel

- (instancetype)init {
    if (self = [super initWithFrame:CGRectZero]) {
        self.textView.delegate = self;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.textView.delegate = self;
        self.textView.frame = self.bounds;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setAttriContent:(NSMutableAttributedString *)attriContent {
    _attriContent = attriContent;
    self.textView.attributedText = attriContent;
}

- (void)setLinkTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)linkTextAttributes {
    _linkTextAttributes = linkTextAttributes;
    self.textView.linkTextAttributes = linkTextAttributes;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.textView.frame = self.bounds;
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsZero);
    }];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction{
    
    for (NSString *scheme in self.links) {
        if ([URL.scheme isEqualToString:scheme]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(attributeLabel:didResponseLink:)]) {
                [self.delegate attributeLabel:self didResponseLink:scheme];
                return NO;
            }
        }
    }
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return NO;
}
- (void)setAlignment:(NSTextAlignment)alignment {
    _alignment = alignment;
    self.textView.textAlignment = alignment;
}
- (NvTextView *)textView {
    if (!_textView) {
        NvTextView *view = [[NvTextView alloc] init];
        view.backgroundColor = self.backgroundColor;
        view.textColor = self.textColor;
        view.font = self.font;
        view.scrollEnabled = NO;
        view.editable = NO;
        view.textAlignment = NSTextAlignmentLeft;
        [self addSubview:view];
        _textView = view;
    }
    return _textView;
}
@end


@implementation NvTextView
- (BOOL)canBecomeFirstResponder {
    return NO;
}
- (UITextRange *)selectedTextRange {
    return nil;
}
- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && gestureRecognizer.numberOfTouches == 1) {
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && ((UILongPressGestureRecognizer *)gestureRecognizer).minimumPressDuration < 0.005) {
       return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
    gestureRecognizer.enabled = NO;
    return NO;
}
@end
