//
//  YWISOSlider.m
//  YaoWang
//
//  Created by 出出 on 2020/1/9.
//  Copyright © 2020 JingLan. All rights reserved.
//

#import "YWISOSlider.h"
#import <NvBaseCommon/NVDefineConfig.h>
#import "UIView+Frame.h"

@interface YWISOSlider()
@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UIImageView *dragView;

@property (nonatomic, weak) id endTarget;
@property (nonatomic) SEL endSel;
@property (nonatomic, weak) id changingTarget;
@property (nonatomic) SEL changingSel;

@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGFloat stepLength;

@end

@implementation YWISOSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _closerIndicator = NO;
        self.dragView = [self createImageViewWithImage:nil];
        self.tagLabel = [[UILabel alloc] init];
        self.tagLabel.hidden = YES;
        self.tagLabel.font = [UIFont systemFontOfSize:10];
        self.tagLabel.textColor = [UIColor whiteColor];
        self.tagLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.tagLabel];
        self.topLineView = [self createViewWithColor:[UIColor whiteColor]];
        self.bottomLineView = [self createViewWithColor:[UIColor whiteColor]];
        self.topLineView.layer.borderWidth = 0.1;
        self.bottomLineView.layer.borderWidth = self.topLineView.layer.borderWidth;
        
        self.topLineView.layer.borderColor = UIColorFromRGB(0x434343).CGColor;
        self.bottomLineView.layer.borderColor = self.topLineView.layer.borderColor;

    }
    return self;
}

- (void)setThumbImage:(UIImage *)thumbImage
{
    self.dragView.image = thumbImage;
    self.dragView.viewSize = thumbImage.size;
    self.dragView.viewCenterX = self.viewWidth/2.;
    self.dragView.viewCenterY = self.viewHeight/2.;
    [self updateLineLenght];
}

#pragma mark - 拖拽中刷新视图
/*
 拖拽中刷新视图
 Refresh the view while dragging
 
 */
- (void)updateLineLenght
{
    self.topLineView.viewWidth = 1.3;
    self.topLineView.viewCenterX = self.dragView.viewCenterX;
    self.topLineView.viewY = 0;
    self.topLineView.viewHeight = self.dragView.viewY;
    self.bottomLineView.viewWidth = self.topLineView.viewWidth;
    self.bottomLineView.viewCenterX = self.topLineView.viewCenterX;
    self.bottomLineView.viewY = self.dragView.viewBottom;
    self.bottomLineView.viewHeight = self.viewHeight - self.dragView.viewBottom;
    self.tagLabel.viewSize = CGSizeMake(30, 15);
    if(self.closerIndicator) {
        self.tagLabel.viewCenterX = 24*SCREENSCALE;
    }else{
        self.tagLabel.viewCenterX = 40*SCREENSCALE;
    }
    
    self.tagLabel.viewCenterY = self.dragView.viewCenterY;
    if (self.maximumTrackTintColor) {
        self.topLineView.backgroundColor = self.maximumTrackTintColor;
    }
    if (self.minimumTrackTintColor) {
        self.bottomLineView.backgroundColor = self.minimumTrackTintColor;
    }
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor
{
    _minimumTrackTintColor = minimumTrackTintColor;
    self.bottomLineView.backgroundColor = minimumTrackTintColor;
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor
{
    _maximumTrackTintColor = maximumTrackTintColor;
    self.topLineView.backgroundColor = maximumTrackTintColor;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{

    CGPoint point = [touch locationInView:self];
    NSLog(@"beginTrackingWithTouch:%f",point.x);
    self.startPoint = point;
    
    if ([self.delegate respondsToSelector:@selector(YWISOSliderValueStarted:)]) {
        [self.delegate YWISOSliderValueStarted:self];
    }
    return YES;
}


- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint point = [touch locationInView:self];
    NSLog(@"continueTrackingWithTouch:%f",point.x);
    [self handleChangedValue:point];
    SuppressPerformSelectorLeakWarning([self.changingTarget performSelector:self.changingSel withObject:self]);
    
    return YES;

}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint point = [touch locationInView:self];
    NSLog(@"endTrackingWithTouch:%f",point.x);
    [self handleChangedValue:point];
    self.endPoint = point;
    SuppressPerformSelectorLeakWarning([self.endTarget performSelector:self.endSel withObject:self]);
    [self endSlideResetState];
    if ([self.delegate respondsToSelector:@selector(YWISOSliderValueEnded:)]) {
        [self.delegate YWISOSliderValueEnded:self];
    }
}

#pragma mark - 滑动中计算当前效果值
/*
 滑动中计算当前效果值
 Calculate the current effect value while sliding
 
 @param point 当前位置
 current position
 
 */
- (void)handleChangedValue:(CGPoint)point
{
    
    if (point.y > (self.viewHeight - self.dragView.viewHeight/2.)) {
        self.dragView.viewCenterY = self.viewHeight - self.dragView.viewHeight/2.;
        point.y = self.dragView.viewCenterY;
    } else if (point.y < self.dragView.viewHeight/2.) {
        self.dragView.viewCenterY = self.dragView.viewHeight/2.;
        point.y = self.dragView.viewCenterY;
    } else {
        
        
        CGFloat distance = point.y - self.viewHeight/2.;
        

        if (fabs(distance) <= 4) {
            self.dragView.viewCenterY = self.viewHeight/2.;
            point.y = self.dragView.viewCenterY;
            [self slideToMiddleResetState];
        } else {
            self.dragView.viewCenterY = point.y;
            [self slidingResetState];
        }
        NSLog(@"point.y :%f-----distance:%f-----self.viewHeight:%f-----self.dragView.viewCenterY:%f",point.y, distance,self.viewHeight/2.,self.dragView.viewCenterY);
    }
    
    
    [self updateLineLenght];
    CGFloat value = (self.viewHeight - point.y - self.dragView.viewHeight/2) * self.stepLength + self.minimumValue;
    if (value < self.minimumValue) {
        value = self.minimumValue;
    }
    
    if (value > self.maximumValue) {
        value = self.maximumValue;
    }
    _value = [NSString stringWithFormat:@"%.1f",1.f*value].floatValue;
    if ([self.delegate respondsToSelector:@selector(YWISOSliderValueChanged:)]) {
        [self.delegate YWISOSliderValueChanged:self];
    }
    NSLog(@"elf.va：%f",self.value);
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{

    if (controlEvents == UIControlEventValueChanged) {
        
        _changingTarget = target;
        _changingSel = action;

    } else if (controlEvents == UIControlEventTouchUpInside) {
        _endTarget = target;
        _endSel = action;
    }
}

#pragma mark - 拖拽结束调用
/*
 拖拽结束调用
 Drag to end the call
 
 */
- (void)slideToMiddleResetState
{
    self.tagLabel.hidden = NO;
}

#pragma mark - 刷新页面状态
/*
 刷新页面状态
 Refresh page status
 
 */
- (void)slidingResetState
{
    self.bottomLineView.backgroundColor = [UIColor whiteColor];
    self.topLineView.backgroundColor = self.bottomLineView.backgroundColor;
    self.tagLabel.hidden = NO;
}

#pragma mark - 拖拽结束
/*
 拖拽结束
 Drag to end
 
 */
- (void)endSlideResetState
{
    if (!self.maximumTrackTintColor) {
        self.topLineView.backgroundColor = [UIColor whiteColor];
    }
    if (!self.minimumTrackTintColor) {
        self.bottomLineView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setValue:(CGFloat)value {
    if (value < self.minimumValue) {
        value = self.minimumValue;
    }
    if (value > self.maximumValue) {
        value = self.maximumValue;
    }
    _value = value;
    self.dragView.viewCenterY = self.viewHeight - self.dragView.viewHeight/2  - (value - self.minimumValue) / self.stepLength;
    [self updateLineLenght];
}

#pragma mark - 滑杆上的比例值
/*
 滑杆上的比例值
 Scale value on the slider
 
 return 返回CGFloat值。
 Return CGFloat value
 */
- (CGFloat)stepLength {
    if (!_stepLength) {
        CGFloat total =  self.maximumValue - self.minimumValue;
        CGFloat distance = self.viewHeight - self.dragView.viewHeight;
        _stepLength = total/distance;
    }
    return _stepLength;
}

- (UIImageView *)createImageViewWithImage:(UIImage *)image
{
    return [self createImageViewWithFrame:CGRectZero image:image contentMode:0 cornerRadius:0 clipsToBounds:0];
}


- (UIImageView *)createImageViewWithFrame:(CGRect)frame imageName:(NSString *)imageName contentMode:(UIViewContentMode)mode cornerRadius:(CGFloat)cornerRadius clipsToBounds:(BOOL)clipsToBounds
{
    return [self createImageViewWithFrame:frame image:NvImageNamedForBundle(imageName,NvCurrentBundle)  contentMode:mode cornerRadius:cornerRadius clipsToBounds:clipsToBounds];

}

- (UIImageView *)createImageViewWithFrame:(CGRect)frame image:(UIImage *)image contentMode:(UIViewContentMode)mode cornerRadius:(CGFloat)cornerRadius clipsToBounds:(BOOL)clipsToBounds
{
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = frame;
    imageView.contentMode = mode;
    imageView.clipsToBounds = clipsToBounds;
    imageView.layer.cornerRadius = cornerRadius;
    if (image != nil) {
        imageView.image = image;
    }
    [self addSubview:imageView];
    return imageView;
}

- (UIView *)createViewWithColor:(UIColor *)color
{
   return  [self createViewWithColor:color alpha:1];
}

- (UIView *)createViewWithColor:(UIColor *)color alpha:(CGFloat)alpha
{
    UIView *view = [UIView new];
    view.backgroundColor = color;
    view.alpha = alpha;
    [self addSubview:view];
    return view;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end
