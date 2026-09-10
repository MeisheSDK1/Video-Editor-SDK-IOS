//
//  NvDoubleSliderView.m
//  NvDoubleSliderView-OC
//
//  Created by 杜奎 on 2019/1/13.
//  Copyright © 2019 DU. All rights reserved.
//

#import "NvDoubleSliderView.h"
#import "UIView+Dimension.h"

@interface NvDoubleSliderView ()

//手势起手位置类型 0 未在按钮上 not on button ; 1 在左边按钮上 on left button ; 2 在右边按钮上 on right button ; 3 两者重叠 overlap
@property (nonatomic, assign) NSInteger dragType;

@property (nonatomic, assign) CGFloat minIntervalWidth;

//左侧按钮的中心位置 left btn's center
@property (nonatomic, assign) CGPoint minCenter;

//右侧按钮的中心位置 right btn's center
@property (nonatomic, assign) CGPoint maxCenter;

@property (nonatomic, assign) CGFloat marginCenterX;

@property (nonatomic, strong) UIView   *minLineView;

@property (nonatomic, strong) UIView   *maxLineView;

@property (nonatomic, strong) UIView   *midLineView;

@property (nonatomic, strong) UIButton *minSliderBtn;

@property (nonatomic, strong) UIButton *maxSliderBtn;

@end

@implementation NvDoubleSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        if (self.height < 35 + 20) {
            self.height = 40;
        }
        self.marginCenterX = 0 ;
        [self createUI];
    }
    return self;
}

#pragma mark - 初始化界面
/*
 初始化界面
 Initialize the interface
 
 */
- (void)createUI {
    [self addSubview:self.minLineView];
    [self addSubview:self.midLineView];
    [self addSubview:self.maxLineView];
    [self addSubview:self.minSliderBtn];
    [self addSubview:self.maxSliderBtn];
    [self.minSliderBtn addSubview:self.leftLabel];
    [self.maxSliderBtn addSubview:self.rightLabel];
    self.leftLabel.width = 40;
    self.rightLabel.width = 40;
    self.curMinValue = 0;
    self.curMaxValue = 1;
    self.duration = 1;
    
    CGFloat centerY = 25;
    
    self.minSliderBtn.centerY = centerY+8;
    self.maxSliderBtn.centerY = centerY+8;
    self.minSliderBtn.left = 0;
    self.maxSliderBtn.right = self.width;
    
    self.minLineView.centerY = centerY;
    self.midLineView.centerY = centerY;
    self.maxLineView.centerY = centerY;
    
    [self changeLineViewWidth];
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderBtnPanAction:)]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.leftLabel.centerY = self.minSliderBtn.top-20;
    self.leftLabel.text = [NSString stringWithFormat:@"%.1fs",self.curMinValue*self.duration];
    self.rightLabel.centerY = self.maxSliderBtn.top-20;
    self.rightLabel.text = [NSString stringWithFormat:@"%.1fs",(1-self.curMaxValue)*self.duration];
}

#pragma mark - action
/*
 平移触摸事件
 Pan touch event
 
 @param gesture 平移手势
 Pan gesture
 */
- (void)sliderBtnPanAction: (UIPanGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    CGPoint translation = [gesture translationInView:self];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGRect minSliderFrame = CGRectMake(self.minSliderBtn.left - 10, self.minSliderBtn.top - 10, self.minSliderBtn.width + 20, self.minSliderBtn.height + 20);
        CGRect maxSliderFrame = CGRectMake(self.maxSliderBtn.left - 10, self.maxSliderBtn.top - 10, self.maxSliderBtn.width + 20, self.maxSliderBtn.height + 20);
        BOOL inMinSliderBtn = CGRectContainsPoint(minSliderFrame, location);
        BOOL inMaxSliderBtn = CGRectContainsPoint(maxSliderFrame, location);
        
        if (inMinSliderBtn && !inMaxSliderBtn) {

            self.dragType = 1;
        }else if (!inMinSliderBtn && inMaxSliderBtn) {

            self.dragType = 2;
        }else if (!inMaxSliderBtn && !inMinSliderBtn) {

            self.dragType = 0;
        }else {
            CGFloat leftOffset = fabs(location.x - self.minSliderBtn.centerX);
            CGFloat rightOffset = fabs(location.x - self.maxSliderBtn.centerX);
            if (leftOffset > rightOffset) {

                self.dragType = 2;
            }else if (leftOffset < rightOffset) {

                self.dragType = 1;
            }else {
 
                self.dragType = 3;
            }
        }
        if (self.dragType == 1) {
            self.minCenter = self.minSliderBtn.center;
            [self bringSubviewToFront:self.minSliderBtn];
        }else if (self.dragType == 2) {
            self.maxCenter = self.maxSliderBtn.center;
            [self bringSubviewToFront:self.maxSliderBtn];
        }
        if (self.minInterval > 0) {
            self.minIntervalWidth = (self.width - self.marginCenterX * 2) * self.minInterval;
        }
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (self.dragType == 3) {
            if (translation.x > 0) {
                self.dragType = 2;
                self.maxCenter = self.maxSliderBtn.center;
                [self bringSubviewToFront:self.maxSliderBtn];
               
            }else if (translation.x < 0) {
                self.dragType = 1;
                self.minCenter = self.minSliderBtn.center;
                [self bringSubviewToFront:self.minSliderBtn];
                
            }
        }
        if (self.dragType != 0 && self.dragType != 3) {
            if (self.dragType == 1) {
                self.minSliderBtn.center = CGPointMake(self.minCenter.x + translation.x, self.minCenter.y);
                if (self.minSliderBtn.right > self.maxSliderBtn.right - self.minIntervalWidth) {
                    self.minSliderBtn.right = self.maxSliderBtn.right - self.minIntervalWidth;
                }else {
                    if (self.minSliderBtn.centerX < self.marginCenterX) {
                        self.minSliderBtn.centerX = self.marginCenterX;
                    }
                    if (self.minSliderBtn.centerX > self.width - self.marginCenterX) {
                        self.minSliderBtn.centerX = self.width - self.marginCenterX;
                    }
                }
                [self changeLineViewWidth];
                [self changeValueFromLocation];
                if (self.sliderBtnLocationChangeBlock != nil) {
                    self.sliderBtnLocationChangeBlock(true, false);
                }
            }else {
                self.maxSliderBtn.center = CGPointMake(self.maxCenter.x + translation.x, self.maxCenter.y);
                if (self.maxSliderBtn.left < self.minSliderBtn.left + self.minIntervalWidth) {
                    self.maxSliderBtn.left = self.minSliderBtn.left + self.minIntervalWidth;
                }else {
                    if (self.maxSliderBtn.centerX < self.marginCenterX) {
                        self.maxSliderBtn.centerX = self.marginCenterX;
                    }
                    if (self.maxSliderBtn.centerX > self.width - self.marginCenterX) {
                        self.maxSliderBtn.centerX = self.width - self.marginCenterX;
                    }
                }
                [self changeLineViewWidth];
                [self changeValueFromLocation];
                if (self.sliderBtnLocationChangeBlock != nil) {
                    self.sliderBtnLocationChangeBlock(false, false);
                }
            }
        }
     
    }else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.dragType == 1) {
            [self changeValueFromLocation];
            if (self.sliderBtnLocationChangeBlock != nil) {
                self.sliderBtnLocationChangeBlock(true, true);
            }
        }else if (self.dragType == 2) {
            [self changeValueFromLocation];
            if (self.sliderBtnLocationChangeBlock != nil) {
                self.sliderBtnLocationChangeBlock(false, true);
            }
        }
        self.dragType = 0;
    }
}

#pragma mark - 改变值域的线宽
/*
 改变值域的线宽
 Change the line width of the range
 
 */
- (void)changeLineViewWidth {
    self.minLineView.width = self.minSliderBtn.centerX;
    self.minLineView.left = 0;
    
    self.maxLineView.width = self.width - self.maxSliderBtn.centerX;
    self.maxLineView.right = self.width;
    
    self.midLineView.width = self.maxSliderBtn.centerX - self.minSliderBtn.centerX;
    self.midLineView.left = self.minLineView.right;
}

#pragma mark - 根据滑块位置改变当前最小和最大的值
/*
 根据滑块位置改变当前最小和最大的值
 Change the current minimum and maximum values according to the position of the slider
 
 */
- (void)changeValueFromLocation {
    CGFloat contentWidth = self.width - self.marginCenterX * 2;
    self.curMinValue = (self.minSliderBtn.centerX - self.marginCenterX)/contentWidth;
    self.curMaxValue = (self.maxSliderBtn.centerX - self.marginCenterX)/contentWidth;
}

- (void)changeLocationFromValue {
    CGFloat contentWidth = self.width - self.marginCenterX * 2;
    if (self.needAnimation) {
        [UIView animateWithDuration:0.2 animations:^{
            self.minSliderBtn.centerX = self.marginCenterX + self.curMinValue * contentWidth;
            self.maxSliderBtn.centerX = self.marginCenterX + self.curMaxValue * contentWidth;
            [self changeLineViewWidth];
        }];
    }else {
        self.minSliderBtn.centerX = self.marginCenterX + self.curMinValue * contentWidth;
        self.maxSliderBtn.centerX = self.marginCenterX + self.curMaxValue * contentWidth;
        [self changeLineViewWidth];
    }
    if (self.curMinValue == self.curMaxValue) {
        if (self.curMaxValue == 0) {
            [self bringSubviewToFront:self.maxSliderBtn];
        }else {
            [self bringSubviewToFront:self.minSliderBtn];
        }
    }
}
#pragma mark - setter & getter

- (void)setMinTintColor:(UIColor *)minTintColor {
    _minTintColor = minTintColor;
    self.minLineView.backgroundColor = minTintColor;
}

- (void)setMidTintColor:(UIColor *)midTintColor {
    _midTintColor = midTintColor;
    self.midLineView.backgroundColor = midTintColor;
}

- (void)setMaxTintColor:(UIColor *)maxTintColor {
    _maxTintColor = maxTintColor;
    self.maxLineView.backgroundColor = maxTintColor;
}

- (void)setHiddenLeftIcon:(BOOL)hiddenLeftIcon {
    _hiddenLeftIcon = hiddenLeftIcon;
    self.minSliderBtn.hidden = hiddenLeftIcon;
    self.leftLabel.hidden = hiddenLeftIcon;
}

- (void)setHiddenRightIcon:(BOOL)hiddenRightIcon {
    _hiddenRightIcon = hiddenRightIcon;
    self.maxSliderBtn.hidden = hiddenRightIcon;
    self.rightLabel.hidden = hiddenRightIcon;
}

- (UIView *)minLineView {
    if (!_minLineView) {
        _minLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
        _minLineView.backgroundColor = [[UIColor alloc] initWithRed:124.0/255.0 green:224.0/255.0 blue:195.0/255.0 alpha:1];
        _minLineView.userInteractionEnabled = NO;
    }
    return _minLineView;
}

- (UIView *)midLineView {
    if (!_midLineView) {
        _midLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
        _midLineView.backgroundColor = [UIColor whiteColor];
        _midLineView.userInteractionEnabled = NO;
    }
    return _midLineView;
}

- (UIView *)maxLineView {
    if (!_maxLineView) {
        _maxLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
        _maxLineView.backgroundColor = [[UIColor alloc] initWithRed:228.0/255.0 green:66.0/255.0 blue:89.0/255.0 alpha:1];
        _maxLineView.userInteractionEnabled = NO;
    }
    return _maxLineView;
}

- (UIButton *)minSliderBtn {
    if (!_minSliderBtn) {
        _minSliderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _minSliderBtn.size = CGSizeMake(35, 35);
        [_minSliderBtn setImage:NvImageNamed(@"leftimage") forState:UIControlStateNormal];
        [_minSliderBtn setImage:NvImageNamed(@"leftimage") forState:UIControlStateHighlighted];
        _minSliderBtn.layer.cornerRadius = 17.5;
        _minSliderBtn.userInteractionEnabled = false;
    }
    return _minSliderBtn;
}

- (UIButton *)maxSliderBtn {
    if (!_maxSliderBtn) {
        _maxSliderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _maxSliderBtn.size = CGSizeMake(35, 35);
        _maxSliderBtn.layer.cornerRadius = 17.5;
        [_maxSliderBtn setImage:NvImageNamed(@"rightimage") forState:UIControlStateNormal];
        [_maxSliderBtn setImage:NvImageNamed(@"rightimage") forState:UIControlStateHighlighted];
        _maxSliderBtn.userInteractionEnabled = false;
    }
    return _maxSliderBtn;
}

#pragma mark - setter & getter
- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        if (@available(iOS 8.2, *)) {
            _leftLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
        } else {
            _leftLabel.font = [UIFont systemFontOfSize:10];
        }
        _leftLabel.textColor = [UIColor whiteColor];
        _leftLabel.alpha = 0.8;
        _leftLabel.text = @"0.0s";
        _leftLabel.textAlignment = NSTextAlignmentCenter;
        [_leftLabel sizeToFit];
    }
    return _leftLabel;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        if (@available(iOS 8.2, *)) {
            _rightLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
        } else {
            _rightLabel.font = [UIFont systemFontOfSize:10];
        }
        _rightLabel.textColor = [UIColor whiteColor];
        _rightLabel.alpha = 0.8;
        _rightLabel.text = @"0.0s";
        _rightLabel.textAlignment = NSTextAlignmentCenter;
        [_rightLabel sizeToFit];
    }
    return _rightLabel;
}

@end
