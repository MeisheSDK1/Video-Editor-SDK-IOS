//
//  NvBeautySegmentView.m
//  SDKDemo
//
//  Created by MS on 2020/7/23.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvBeautySegmentView.h"
#import "NVHeader.h"

@interface NvSegmentButton : UIButton

/// 是否左对齐 Whether to align left
@property (nonatomic, assign) BOOL isLeft;

/// 初始化
/// initialization
/// @param isLeftAlignment 是否左对齐 Whether to align left
- (instancetype)initWithType:(BOOL)isLeftAlignment;
@end

@implementation NvSegmentButton

- (instancetype)initWithType:(BOOL)isLeftAlignment {
    if (self = [super init]) {
        self.isLeft = isLeftAlignment;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat itemWH = 22 * SCREENSCALE;
    if (self.isLeft) {
        self.imageView.frame =  CGRectMake(0, (self.bounds.size.height - itemWH) * 0.5, itemWH, itemWH);
        
    }else {
        self.imageView.frame = CGRectMake(self.bounds.size.width - itemWH, (self.bounds.size.height - itemWH) * 0.5, itemWH, itemWH);
    }
    self.titleLabel.frame = self.imageView.frame;
    [self bringSubviewToFront:self.titleLabel];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.imageView.backgroundColor = backgroundColor;
}

@end

@interface NvBeautySegmentView ()
@property (nonatomic, copy) NSArray *titleArr;
@property (nonatomic, copy) NSString *selectedColor;
@property (nonatomic, copy) NSString *normalColor;
@property (nonatomic, copy) NSString *selectedTextColor;
@property (nonatomic, copy) NSString *normalTextColor;
@property (nonatomic, assign) CGFloat fontSize;
@end

@implementation NvBeautySegmentView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles selectedBgColor:(NSString *)selectedColor normalBgColor:(NSString *)normalColor selectedTextColor:(NSString *)selectedTextColor normalTextColor:(NSString *)normalTextColor fontSize:(CGFloat)fontSize {
    if (self = [super initWithFrame:frame]) {
        self.titleArr = [NSArray arrayWithArray:titles];
        self.selectedColor = selectedColor;
        self.normalColor = normalColor;
        self.selectedTextColor = selectedTextColor;
        self.normalTextColor = normalTextColor;
        self.fontSize = fontSize;
        [self addSubviews];
    }
    return self;
}

#pragma mark - 添加视图
/*
 添加视图
 Add view
 */
- (void)addSubviews {
    CGFloat width = (self.frame.size.width - 22 * SCREENSCALE) / self.titleArr.count;
    CGFloat height = self.frame.size.height - 20 * SCREENSCALE;
    for (int i=0; i<self.titleArr.count; i++) {
        NvSegmentButton *button = [[NvSegmentButton alloc] initWithType: i ? YES : NO];
        button.frame = CGRectMake(11 * SCREENSCALE + i*width, 10 * SCREENSCALE, width, height);
        button.contentMode = UIViewContentModeCenter;
        [button setBackgroundColor:[UIColor nv_colorWithHexRGBA:self.normalColor]];
        [button setTitleColor:[UIColor nv_colorWithHexRGBA:self.normalTextColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor nv_colorWithHexRGBA:self.selectedTextColor] forState:UIControlStateSelected];
        [button setTitle:self.titleArr[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.tag = i;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

#pragma mark - 标签按钮点击事件
/*
 标签按钮点击事件
 Label button click event
 
 @param button button
 */
- (void)buttonClicked:(UIButton *)button {
    [self selectButton:button.tag];
}

- (void)setDefaultSelectedSegment:(NSInteger)index {
    [self selectButton:index];
}

- (void)setRectCornerRadius:(CGFloat)radius {
    for (UIButton *button in self.subviews) {
        if (button.tag == 0 || button.tag == self.titleArr.count -1) {
            UIBezierPath *maskPath;
            if (button.tag == 0) {
                maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(radius,radius)];
            }else if (button.tag == self.titleArr.count -1) {
                maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(radius,radius)];
            }
            
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = button.bounds;
            
            maskLayer.path = maskPath.CGPath;
            button.layer.mask = maskLayer;
        }
        
    }
}

#pragma mark - 根据参数，更新按钮状态
/*
 根据参数，更新按钮状态
 According to the parameters, update the button state
 
 @param index index
 */
- (void)selectButton:(NSInteger)index {
    for (UIButton *button in self.subviews) {
        if (button.tag == index) {
            button.selected = YES;
            [button setBackgroundColor:[UIColor nv_colorWithHexRGBA:self.selectedColor]];
            if (self.selectBlock) {
                self.selectBlock(button.tag);
            }
        }else{
            button.selected = NO;
            [button setBackgroundColor:[UIColor nv_colorWithHexRGBA:self.normalColor]];
        }
    }
}

@end
