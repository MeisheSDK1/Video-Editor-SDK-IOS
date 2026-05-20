//
//  REDRangeSlider.m
//
//
//  Created by Red Davis on 24/10/2012.
//  Copyright (c) 2013 Red Davis. All rights reserved.
//

#import "REDRangeSlider.h"
#import <QuartzCore/QuartzCore.h>

@interface REDRangeSlider () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImageView *sliderBackground;
@property (strong, nonatomic) UIImageView *sliderFillBackground;

@property (assign, nonatomic) CGFloat leftHandleStartXCoor;
@property (assign, nonatomic) CGFloat rightHandleStartXCoor;

@property (readonly, nonatomic) CGFloat trackWidth;

- (void)setupUI;
- (void)leftHandlePanEngadged:(UIGestureRecognizer *)gesture;
- (void)rightHandlePanEngadged:(UIGestureRecognizer *)gesture;

@end


static CGFloat const kREDHandleTapTargetRadius = 20.0;


@implementation REDRangeSlider

#pragma mark -

- (void)setLeftValue:(CGFloat)leftValue {
    
    if (leftValue <= self.minValue) {
        _leftValue = self.minValue;
    }
    else if (leftValue >= self.minValue && leftValue <= self.rightValue - self.minimumSpacing) {
        _leftValue = leftValue;
    }
    
    [self setNeedsLayout];
}

- (void)setRightValue:(CGFloat)rightValue {
    if (rightValue >= self.maxValue) {
        _rightValue = self.maxValue;
    }
    else if (rightValue <= self.maxValue && rightValue > self.leftValue + self.minimumSpacing) {
        _rightValue = rightValue;
    }
 
    
    [self setNeedsLayout];
}

- (void)setMaxValue:(CGFloat)maxValue {
    
    _maxValue = maxValue;
    [self setNeedsLayout];
}

- (void)setMinValue:(CGFloat)minValue {
    
    _minValue = minValue;
    [self setNeedsLayout];
}

#pragma mark - View Setup
- (void)layoutSubviews {
    
    if (!self.didSetupUI) {
        [self setupUI];
        
    }
    
    self.sliderBackground.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.sliderBackground.frame));
    self.sliderBackground.center = CGPointMake(floorf(CGRectGetWidth(self.bounds)/2), floorf(CGRectGetHeight(self.bounds)/2));
    
    CGFloat oneHundredPercent = self.maxValue - self.minValue;
    
    CGFloat leftValuePercentage = self.leftValue/oneHundredPercent;
    
    CGFloat leftXCoor = floorf((self.trackWidth-self.handleImage.size.width) * leftValuePercentage);
    
    self.leftHandle.frame = CGRectMake(0, 0, CGRectGetWidth(self.leftHandle.frame), CGRectGetHeight(self.leftHandle.frame));
    
    if (!isnan([[NSNumber numberWithFloat:leftXCoor] floatValue])) {
        self.leftHandle.center = CGPointMake(leftXCoor, self.sliderBackground.center.y);
        self.trimInLabel.center = CGPointMake(leftXCoor, self.sliderBackground.center.y + 20);
    }
    
    CGFloat rightValuePercentage = self.rightValue/oneHundredPercent;
    CGFloat rightXCoor = floorf((self.trackWidth-self.handleImage.size.width) * rightValuePercentage) + self.handleImage.size.width;
    
    self.rightHandle.frame = CGRectMake(0, 0, CGRectGetWidth(self.rightHandle.frame), CGRectGetHeight(self.rightHandle.frame));
    if (!isnan(([[NSNumber numberWithFloat:rightXCoor] floatValue]))) {
        self.rightHandle.center = CGPointMake(rightXCoor, self.sliderBackground.center.y);
        self.trimOutLabel.center = CGPointMake(rightXCoor-10, self.sliderBackground.center.y + 20);
    } else {
        
    }
    
    CGFloat fillBackgroundWidth = self.rightHandle.center.x-self.leftHandle.center.x;
    self.sliderFillBackground.frame = CGRectMake(self.leftHandle.center.x, 0, fillBackgroundWidth, CGRectGetHeight(self.sliderFillBackground.frame));
    self.sliderFillBackground.center = CGPointMake(self.sliderFillBackground.center.x, self.sliderBackground.center.y);
}

- (void)setupUI {
    
    if (self.maxValue == 0) {
        self.maxValue = 1.0;
    }
    
    if (self.rightValue == 0) {
        self.rightValue = self.maxValue;
    }
    
    CGRect paddedFrame = self.frame;
    paddedFrame.size.height = kREDHandleTapTargetRadius*2;
    self.frame = paddedFrame;
    UIImage *emptySliderImage = self.trackBackgroundImage;
    self.sliderBackground = [[UIImageView alloc] initWithImage:emptySliderImage];
    [self addSubview:self.sliderBackground];

    UIImage *sliderFillImage = self.trackFillImage;
    self.sliderFillBackground = [[UIImageView alloc] initWithImage:sliderFillImage];

    [self addSubview:self.sliderFillBackground];
    
    self.leftHandle = [[UIImageView alloc] init];
    self.leftHandle.image = self.leftHandleImage;
    self.leftHandle.highlightedImage = self.leftHandleHighlightedImage;
    self.leftHandle.frame = CGRectMake(0, 0, self.rightHandleImage.size.width+kREDHandleTapTargetRadius, self.rightHandleImage.size.height+kREDHandleTapTargetRadius);
    self.leftHandle.contentMode = UIViewContentModeCenter;
    self.leftHandle.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *leftPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftHandlePanEngadged:)];
    leftPanGesture.delegate = self;
    [self.leftHandle addGestureRecognizer:leftPanGesture];
    
    [self addSubview:self.leftHandle];
    
    self.rightHandle = [[UIImageView alloc] init];
    self.rightHandle.image = self.rightHandleImage;
    self.rightHandle.highlightedImage = self.rightHandleHighlightedImage;
    self.rightHandle.frame = CGRectMake(0, 0, self.rightHandleImage.size.width+kREDHandleTapTargetRadius, self.rightHandleImage.size.height+kREDHandleTapTargetRadius);
    self.rightHandle.contentMode = UIViewContentModeCenter;
    self.rightHandle.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *rightPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightHandlePanEngadged:)];
    rightPanGesture.delegate = self;
    [self.rightHandle addGestureRecognizer:rightPanGesture];
    
    [self addSubview:self.rightHandle];
    
    self.trimInLabel = [[UILabel alloc]init];
    self.trimInLabel.textColor = UIColor.whiteColor;
    self.trimInLabel.font = [UIFont systemFontOfSize:11];
    self.trimInLabel.frame = CGRectMake(0, 0, 40, 10);
    [self addSubview:self.trimInLabel];
    
    self.trimOutLabel = [[UILabel alloc]init];
    self.trimOutLabel.textColor = UIColor.whiteColor;
    self.trimOutLabel.font = [UIFont systemFontOfSize:11];
    self.trimOutLabel.frame = CGRectMake(0, 0, 40, 10);
    [self addSubview:self.trimOutLabel];
    
    self.didSetupUI = YES;
}

#pragma mark - Image properties

- (UIImage *)handleImage {
    if(!_handleImage) {
        UIImage *image = [UIImage imageNamed:@"NvCutMusicHandle"];
        _handleImage = image;
    }
    return _handleImage;
}

- (UIImage *)leftHandleImage {
    if (!_leftHandleImage) {
        return [self handleImage];
    }
    return _leftHandleImage;
}

- (UIImage *)rightHandleImage {
    if (!_rightHandleImage) {
        return [self handleImage];
    }
    return _rightHandleImage;
}

- (UIImage *)handleHighlightedImage {
    if(!_handleHighlightedImage) {
        UIImage *image = [UIImage imageNamed:@"NvCutMusicHandle"];
        _handleHighlightedImage = image;
    }
    return _handleHighlightedImage;
}

- (UIImage *)leftHandleHighlightedImage {
    if (!_leftHandleHighlightedImage) {
        return [self handleHighlightedImage];
    }
    return _leftHandleHighlightedImage;
}

- (UIImage *)rightHandleHighlightedImage {
    if (!_rightHandleHighlightedImage) {
        return [self handleHighlightedImage];
    }
    return _rightHandleHighlightedImage;
}

- (UIImage *)trackBackgroundImage {
    if(!_trackBackgroundImage) {
         UIImage *image = [self createImageWithColor:[REDRangeSlider nv_colorWithHexARGB:@"#33FFFFFF"] withSize:CGSizeMake(100, 5)];
        _trackBackgroundImage = image;
    }
    return _trackBackgroundImage;
}

- (UIImage *)trackFillImage {
    if(!_trackFillImage) {
         UIImage *image = [self createImageWithColor:[REDRangeSlider nv_colorWithHexRGB:@"#4A90E2"] withSize:CGSizeMake(100, 5)];
        _trackFillImage = image;
    }
    return _trackFillImage;
}

- (UIImage *)createImageWithColor:(NSString *)string {
    return [self createImageWithColor:[REDRangeSlider nv_colorWithHexRGB:string] withSize:CGSizeMake(100, 5)];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    for (UIView *subView in self.subviews) {
        
        UIView *hitView = [subView hitTest:[self convertPoint:point toView:subView] withEvent:event];
        if (hitView) {
            NSLog(@"hitview === %@",NSStringFromClass([hitView class]));
            return hitView;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

#pragma mark - Gestures

- (CGFloat)roundValueToStepValue:(CGFloat)value {
    if (self.stepValue == 0.0) {
        return value;
    }
    return self.stepValue * floor((value/self.stepValue)+0.5);
}

- (void)leftHandlePanEngadged:(UIGestureRecognizer *)gesture {
    if (_rightValue < 1.0) {
//        _rightValue = 1.0;
        return;
    }
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.leftHandle.highlighted = YES;
        
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint pointInView = [panGesture translationInView:self];
        CGFloat oneHundredPercentOfValues = self.maxValue - self.minValue;
        CGFloat trackOneHundredPercent = self.trackWidth-self.handleImage.size.width;
        CGFloat trackPercentageChange = (pointInView.x / trackOneHundredPercent)*100;
        self.leftValue += (trackPercentageChange/100.0) * oneHundredPercentOfValues;
        
        [panGesture setTranslation:CGPointZero inView:self];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    else if (panGesture.state == UIGestureRecognizerStateCancelled ||
             panGesture.state == UIGestureRecognizerStateEnded ||
             panGesture.state == UIGestureRecognizerStateCancelled) {
        self.leftHandle.highlighted = NO;
        self.leftValue = [self roundValueToStepValue:self.leftValue];
        if ([self.delegate respondsToSelector:@selector(leftPan:)]) {
            [self.delegate leftPan:self.leftValue/self.maxValue];
        }
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)rightHandlePanEngadged:(UIGestureRecognizer *)gesture {
    if (_rightValue < 1.0f) {
        return;
    }
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;

    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.rightHandle.highlighted = YES;
    }
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint pointInView = [panGesture translationInView:self];
        CGFloat oneHundredPercentOfValues = self.maxValue - self.minValue;
        
        CGFloat trackOneHundredPercent = self.trackWidth-self.handleImage.size.width;
        CGFloat trackPercentageChange = (pointInView.x / trackOneHundredPercent)*100;
        
        self.rightValue += (trackPercentageChange/100.0) * oneHundredPercentOfValues;
        
        [panGesture setTranslation:CGPointZero inView:self];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    else if (panGesture.state == UIGestureRecognizerStateCancelled ||
             panGesture.state == UIGestureRecognizerStateEnded ||
             panGesture.state == UIGestureRecognizerStateCancelled) {
        self.rightHandle.highlighted = NO;
        self.rightValue = [self roundValueToStepValue:self.rightValue];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        if ([self.delegate respondsToSelector:@selector(rightPan:)]) {
            [self.delegate rightPan:self.rightValue/self.maxValue];
        }
    }
}

-(UIImage*)createImageWithColor:(UIColor*) color withSize:(CGSize)size {
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - 
- (void)setFrame:(CGRect)frame {
    
    frame.size.height = self.handleImage.size.height+kREDHandleTapTargetRadius;
    [super setFrame:frame];
}

#pragma mark - Helpers

- (CGFloat)trackWidth {
    return self.frame.size.width;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return NO;
}

+ (UIColor*)nv_colorWithHexARGB:(NSString *)argb {
    NSAssert([argb hasPrefix:@"#"], @"颜色字符串要以#开头");
    
    NSString *hexString = [argb substringFromIndex:1];
    unsigned int hexInt;
    BOOL result = [[NSScanner scannerWithString:hexString] scanHexInt:&hexInt];
    if (!result) {
        return nil;
    }
    
    CGFloat divisor = 255.0;
    CGFloat alpha = ((hexInt & 0xFF000000) >> 24) / divisor;
    CGFloat red   = ((hexInt & 0x00FF0000) >> 16) / divisor;
    CGFloat green    = ((hexInt & 0x0000FF00) >>  8) / divisor;
    CGFloat blue   = ( hexInt & 0x000000FF       ) / divisor;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
}

+ (UIColor*)nv_colorWithHexRGB:(NSString *)rgb {
    NSAssert([rgb hasPrefix:@"#"], @"颜色字符串要以#开头");
    
    NSString *hexString = [rgb substringFromIndex:1];
    unsigned int hexInt;
    BOOL result = [[NSScanner scannerWithString:hexString] scanHexInt:&hexInt];
    if (!result) {
        return nil;
    }
    
    CGFloat divisor = 255.0;
    CGFloat red   = ((hexInt & 0x00FF0000) >> 16) / divisor;
    CGFloat green    = ((hexInt & 0x0000FF00) >>  8) / divisor;
    CGFloat blue   = ( hexInt & 0x000000FF       ) / divisor;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
}

@end
