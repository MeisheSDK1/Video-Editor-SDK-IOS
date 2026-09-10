//
//  SAVideoRangeSlider.m
//
// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2013 Andrei Solovjev - http://solovjev.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SAVideoRangeSlider.h"
#import "UIView+Frame.h"

#define NS_TIME_BASE 1000000

@interface SAVideoRangeSlider () {
    int thumbWidth;
}

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) SASliderLeft *leftThumb;
@property (nonatomic, strong) SASliderRight *rightThumb;
@property (nonatomic) CGFloat frame_width;
@property (nonatomic, assign) BOOL leftCanMove;
@property (nonatomic, assign) BOOL rightCanMove;

@end

@implementation SAVideoRangeSlider


#define SLIDER_BORDERS_SIZE 2.0f
#define BG_VIEW_BORDERS_SIZE 1.0f

- (void)awakeFromNib {
    [super awakeFromNib];
    self.width = [UIScreen mainScreen].bounds.size.width-40;
    [self initFrame:self.frame];
}

- (void)initFrame:(CGRect)frame{
    _frame_width = frame.size.width;
    NSLog(@"-\n-\n-\n-\n-\n-\n-\n-\n%@",NSStringFromCGRect(frame));
//    thumbWidth = ceil(frame.size.width*0.03);
    thumbWidth = 20;
    
    _bgView = [[UIControl alloc] initWithFrame:CGRectMake(thumbWidth-BG_VIEW_BORDERS_SIZE, 0, frame.size.width-(thumbWidth*2)+BG_VIEW_BORDERS_SIZE*2, frame.size.height)];
    _bgView.layer.borderColor = [UIColor clearColor].CGColor;
    _bgView.layer.borderWidth = BG_VIEW_BORDERS_SIZE;
    [self addSubview:_bgView];
    
    _leftThumb = [[SASliderLeft alloc] initWithFrame:CGRectMake(0, 0, thumbWidth, frame.size.height)];
    _leftThumb.userInteractionEnabled = YES;
    _leftThumb.clipsToBounds = YES;
    _leftThumb.backgroundColor = [UIColor clearColor];
    _leftThumb.layer.borderWidth = 0;
    [self addSubview:_leftThumb];
        
        
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
    [_leftThumb addGestureRecognizer:leftPan];
    
        
    _rightThumb = [[SASliderRight alloc] initWithFrame:CGRectMake(frame.size.width-thumbWidth,0, thumbWidth, frame.size.height)];
    _rightThumb.userInteractionEnabled = YES;
    _rightThumb.clipsToBounds = YES;
    _rightThumb.backgroundColor = [UIColor clearColor];
    _rightThumb.layer.borderWidth = 0;
    [self addSubview:_rightThumb];
        
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
    [_rightThumb addGestureRecognizer:rightPan];
    
    _topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, SLIDER_BORDERS_SIZE)];
    _topBorder.backgroundColor = [UIColor colorWithRed: 103.0/225.0 green: 193.0/225.0 blue: 228.0/225.0 alpha: 1];
    [self addSubview:_topBorder];
    
    
    _bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-SLIDER_BORDERS_SIZE, frame.size.width, SLIDER_BORDERS_SIZE)];
    _bottomBorder.backgroundColor = [UIColor colorWithRed: 103.0/225.0 green: 193.0/225.0 blue: 228.0/225.0 alpha: 1];
    [self addSubview:_bottomBorder];
    
    _rightPosition = _frame_width-thumbWidth;
    _leftPosition = thumbWidth;
    _minSectionTime = 0.5;

}

-(void)setMaxGap:(NSNumber *)maxGap{
    _maxGap = maxGap;
    _rightPosition = thumbWidth + (_frame_width- 2*thumbWidth)*_maxGap.longLongValue/_durationSeconds;
    [self setNeedsLayout];
}

-(void)setMinGap:(NSNumber *)minGap{
    _minGap = minGap;
    _leftPosition = thumbWidth + (_frame_width- 2*thumbWidth)*_minGap.longLongValue/_durationSeconds;
    [self setNeedsLayout];
}


- (void)delegateNotification
{
    BOOL isResponds = [self.delegate respondsToSelector:@selector(videoRange:didChangeLeftPosition:rightPosition:)];
    if (isResponds){
        [self.delegate videoRange:self didChangeLeftPosition:self.leftPosition rightPosition:self.rightPosition];
    }
}

- (void)delegateGestureStateEndedNotification
{
    BOOL isResponds = [self.delegate respondsToSelector:@selector(videoRange:didGestureStateEndedLeftPosition:rightPosition:)];
    if (isResponds){
        [self.delegate videoRange:self didGestureStateEndedLeftPosition:self.leftPosition rightPosition:self.rightPosition];
    }
}

- (void)setMinSectionTime:(CGFloat)minSectionTime {
    _minSectionTime = minSectionTime;
}



#pragma mark - Gestures

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
//    UITouch* touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//    if (CGRectContainsPoint(CGRectMake(self.leftThumb.x-5, 0, self.leftThumb.width+10, self.leftThumb.height), point)) {
//        self.leftCanMove = YES;
//    } else {
//        self.leftCanMove = NO;
//    }
//    if (CGRectContainsPoint(CGRectMake(self.rightThumb.x-5, 0, self.rightThumb.width+10, self.rightThumb.height), point)) {
//        self.rightCanMove = YES;
//    } else {
//        self.rightCanMove = NO;
//    }
//}
//
//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesMoved:touches withEvent:event];
//    UITouch* touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//    if (self.leftCanMove) {
//        _leftPosition = point.x;
//        if (_leftPosition < thumbWidth) {
//            _leftPosition = thumbWidth;
//        }
//        
////        if (_rightPosition-_leftPosition <= (_frame_width-2*thumbWidth)*_minSectionTime*NS_TIME_BASE/_durationSeconds)
////        {
////            _leftPosition -= point.x;
////        }
//        
////        [gesture setTranslation:CGPointZero inView:self];
//        
//        [self setNeedsLayout];
//        self.isLeft = YES;
//        [self delegateNotification];
//    }
//    
//    if (self.rightCanMove) {
//        _rightPosition = point.x;
//        if (_rightPosition < thumbWidth) {
//            _rightPosition = thumbWidth;
//        }
//        
//        if (_rightPosition > _frame_width-thumbWidth){
//            _rightPosition = _frame_width-thumbWidth;
//        }
//        
////        if (_rightPosition-_leftPosition <= (_frame_width-2*thumbWidth)*_minSectionTime*NS_TIME_BASE/_durationSeconds){
////            _rightPosition -= translation.x;
////        }
//        
//        [self setNeedsLayout];
//        self.isLeft = NO;
//        [self delegateNotification];
//        
//    }
//    
//    
//}

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:self];
        
        _leftPosition += translation.x;
        if (_leftPosition < thumbWidth) {
            _leftPosition = thumbWidth;
        }
        
        if (_rightPosition-_leftPosition <= (_frame_width-2*thumbWidth)*_minSectionTime*NS_TIME_BASE/_durationSeconds)
            {
            _leftPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        
        [self setNeedsLayout];
        self.isLeft = YES;
        [self delegateNotification];
        
    }
    if(gesture.state == UIGestureRecognizerStateEnded) {
        [self delegateGestureStateEndedNotification];
    }

}


- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        
        
        CGPoint translation = [gesture translationInView:self];
        _rightPosition += translation.x;
        if (_rightPosition < thumbWidth) {
            _rightPosition = thumbWidth;
        }
        
        if (_rightPosition > _frame_width-thumbWidth){
            _rightPosition = _frame_width-thumbWidth;
        }
        
        if (_rightPosition-_leftPosition <= (_frame_width-2*thumbWidth)*_minSectionTime*NS_TIME_BASE/_durationSeconds){
            _rightPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        
        [self setNeedsLayout];
        self.isLeft = NO;
        [self delegateNotification];
        
    }
    
    if(gesture.state == UIGestureRecognizerStateEnded) {
        [self delegateGestureStateEndedNotification];
    }
}

- (void)layoutSubviews
{
    _rightThumb.x = _rightPosition;
    _leftThumb.x = _leftPosition-thumbWidth;
    
    _topBorder.frame = CGRectMake(_leftThumb.frame.origin.x + _leftThumb.frame.size.width, 0, _rightThumb.frame.origin.x - _leftThumb.frame.origin.x - _leftThumb.frame.size.width/2, SLIDER_BORDERS_SIZE);
    
    _bottomBorder.frame = CGRectMake(_leftThumb.frame.origin.x + _leftThumb.frame.size.width, _bgView.frame.size.height-SLIDER_BORDERS_SIZE, _rightThumb.frame.origin.x - _leftThumb.frame.origin.x - _leftThumb.frame.size.width/2, SLIDER_BORDERS_SIZE);
    
}


#pragma mark - Properties

- (CGFloat)leftPosition
{
    return (_leftPosition-thumbWidth) * _durationSeconds / (_frame_width-2*thumbWidth);
}


- (CGFloat)rightPosition
{
    return (_rightPosition-thumbWidth) * _durationSeconds / (_frame_width-2*thumbWidth);
}

@end
