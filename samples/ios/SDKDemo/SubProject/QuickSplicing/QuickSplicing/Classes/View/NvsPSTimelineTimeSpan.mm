//
//  NvsPSTimelineTimeSpan.m
//  NvsTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#import "NvsPSTimelineTimeSpan.h"
#import "NvsMultiThumbnailSequenceView.h"
#import "NvUtils.h"
#import "NvPSTimelineImageView.h"

@interface NvsPSTimelineTimeSpan ()

@end

@implementation NvsPSTimelineTimeSpan {
    NvPSTimelineImageView* leftHandle;
    NvPSTimelineImageView* rightHandle;
    UIImageView *leftArrow;
    UIImageView *rightArrow;
    int handleWidth;
}

- (instancetype)init
{
    self = [super init];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
        [self initInternal];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
        [self initInternal];
    
    return self;
}

- (void)initInternal {
    _inPoint = 0;
    _outPoint = 0;
    _selected = false;
    _editable = false;
    _padding = 0;
    _pointsPerMicrosecond = 1;
    _pitchMoved = 2;
    handleWidth = 15 * SCREENSCALE;
    self.frame = CGRectMake(0, 0, 50, 50);
    leftHandle = [[NvPSTimelineImageView alloc] initWithFrame:CGRectMake(-handleWidth, -2, handleWidth, self.bounds.size.height + 4)];
    leftHandle.userInteractionEnabled = YES;
    leftHandle.image = NvImageNamed(@"NvTailoringLeft");
    [self addSubview:leftHandle];
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
    [leftHandle addGestureRecognizer:leftPan];
    
    ///点击左侧滑动条选中
    ///Click the left slider to select
    UITapGestureRecognizer *leftTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLeftHandler:)];
    [leftHandle addGestureRecognizer:leftTapGesture];
    
    rightHandle = [[NvPSTimelineImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-1, -2, handleWidth, self.bounds.size.height + 4)];
    rightHandle.userInteractionEnabled = YES;
    rightHandle.image = NvImageNamed(@"NvTailoringRight");
    [self addSubview:rightHandle];
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
    [rightHandle addGestureRecognizer:rightPan];
    
    ///点击右侧滑动条选中
    ///Click the right slider to select
    UITapGestureRecognizer *rightTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRightHandler:)];
    [rightHandle addGestureRecognizer:rightTapGesture];
    
    leftArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-1, 0, handleWidth, self.bounds.size.height)];
    leftArrow.userInteractionEnabled = YES;
    leftArrow.image = NvImageNamed(@"NvTailoring_on1");
    leftArrow.hidden = YES;
    [self addSubview:leftArrow];
    UITapGestureRecognizer *leftTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftTap:)];
    [leftArrow addGestureRecognizer:leftTap];
    
    rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-1, 0, handleWidth, self.bounds.size.height)];
    rightArrow.userInteractionEnabled = YES;
    rightArrow.hidden = YES;
    rightArrow.image = NvImageNamed(@"NvTailoring_on1");
    [self addSubview:rightArrow];
    UITapGestureRecognizer *rightTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightTap:)];
    [rightArrow addGestureRecognizer:rightTap];
}

- (void)setInPoint:(int64_t)inPoint {
    _inPoint = inPoint;
    if (self.superview != nil)
        [self updateFrame];
}

- (void)setOutPoint:(int64_t)outPoint {
    _outPoint = outPoint;
    if (self.superview != nil)
        [self updateFrame];
}

- (void)setPadding:(double)padding {
    _padding = padding;
    if (self.superview != nil)
        [self updateFrame];
}

- (void)setPointsPerMicrosecond:(double)pointsPerMicrosecond {
    _pointsPerMicrosecond = pointsPerMicrosecond;
    _pitchMoved = 100000 * pointsPerMicrosecond;
    if (self.superview != nil){
        [self updateFrame];
    }
}

- (void)setSelected:(bool)selected {
    _selected = selected;
    [self setColor];
    if (self.superview != nil) {
        [self updateFrame];
        if (selected)
            [self.superview bringSubviewToFront:self];
    }
}

- (void)setEditable:(bool)editable {
    _editable = editable;
    [self setColor];
    if (self.superview != nil)
        [self updateFrame];
}

- (void)setColor {
    if (_selected) {

    } else {
        self.layer.borderWidth = 0;
    }
}

- (void)updateFrame {
    if (_selected && _editable)
        handleWidth = 15 * SCREENSCALE;
    else
        handleWidth = 15 * SCREENSCALE;
    CGRect frame = self.frame;
    CGFloat h = frame.size.height;
    if (self.superview != nil){
        h = self.superview.bounds.size.height;
    }
    CGFloat x = _padding+_inPoint*_pointsPerMicrosecond;
    CGFloat width = (_outPoint-_inPoint)*_pointsPerMicrosecond;
    if (self.superview != nil) {
        int64_t newIn = _inPoint;
        int64_t newOut = _outPoint;
        
        for (UIView *view1 in self.superview.subviews) {
            if ([view1 isKindOfClass:NvsMultiThumbnailSequenceView.class]) {
                int64_t left = [(NvsMultiThumbnailSequenceView*)view1 mapTimelinePosFromX:0];
                if (_inPoint < left)
                    newIn = left;
                int64_t right = [(NvsMultiThumbnailSequenceView*)view1 mapTimelinePosFromX:((NvsMultiThumbnailSequenceView*)self.superview).bounds.size.width];
                if (_outPoint > right)
                    newOut = right;
            }
        }
        x = _padding+newIn*_pointsPerMicrosecond;
        width = (newOut-newIn)*_pointsPerMicrosecond;
    }
    self.frame = CGRectMake(x, 0, width, h);
    [self updateHandleFrame];
}

- (void)updateHandleFrame {
    leftHandle.userInteractionEnabled = NO;
    rightHandle.userInteractionEnabled = NO;
    if (_selected && _editable) {
        leftHandle.userInteractionEnabled = YES;
        rightHandle.userInteractionEnabled = YES;
    }
    CGRect frame = self.bounds;
    CGFloat height = self.viewHeight ? self.viewHeight : (frame.size.height - 22 * SCREENSCALE);
    leftHandle.frame = CGRectMake(0, 0, handleWidth, height);
    rightHandle.frame = CGRectMake(frame.size.width- handleWidth, 0, handleWidth, height);
    leftArrow.frame = CGRectMake(0, 0, 80 * SCREENSCALE, 20 * SCREENSCALE);
    rightArrow.frame = CGRectMake(0, 0, 80 * SCREENSCALE, 20 * SCREENSCALE);
    leftArrow.center = CGPointMake(leftHandle.center.x, leftHandle.frame.size.height + 18 * SCREENSCALE);
    rightArrow.center = CGPointMake(rightHandle.center.x, leftHandle.frame.size.height + 18 * SCREENSCALE);
}

#pragma mark - Gestures

- (void)handleLeftTap:(UITapGestureRecognizer *)gesture{
     [self handleTap:gesture isLeftHandle:true];
}

- (void)handleRightTap:(UITapGestureRecognizer *)gesture{
    [self handleTap:gesture isLeftHandle:false];
}

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    leftHandle.image = NvImageNamed(@"NvTailoringLeft_on");
    rightHandle.image = NvImageNamed(@"NvTailoringRight");
    leftArrow.hidden = NO;
    rightArrow.hidden = YES;
    [self handlePan:gesture isLeftHandle:true];
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    leftArrow.hidden = YES;
    rightArrow.hidden = NO;
    leftHandle.image = NvImageNamed(@"NvTailoringLeft");
    rightHandle.image = NvImageNamed(@"NvTailoringRight_on");
    [self handlePan:gesture isLeftHandle:false];
}

///点击左侧滑动条选中该滑动条
///Click the left slider to select it
- (void)tapLeftHandler:(UITapGestureRecognizer *)gesture {
    leftHandle.image = NvImageNamed(@"NvTailoringLeft_on");
    rightHandle.image = NvImageNamed(@"NvTailoringRight");
    leftArrow.hidden = NO;
    rightArrow.hidden = YES;
    [self delegateDragStartNotification:YES];
}

///点击右侧滑动条选中该滑动条
///Click the right slider to select it
- (void)tapRightHandler:(UITapGestureRecognizer *)gesture {
    leftArrow.hidden = YES;
    rightArrow.hidden = NO;
    leftHandle.image = NvImageNamed(@"NvTailoringLeft");
    rightHandle.image = NvImageNamed(@"NvTailoringRight_on");
    [self delegateDragStartNotification:NO];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture isLeftHandle:(bool)isLeftHandle{
    UIImageView *arrow = isLeftHandle?leftArrow:rightArrow;
    CGPoint point = [gesture locationInView:arrow];
    if (point.x > 0 && point.x < arrow.bounds.size.width/2) {
        [self delegateDragStartNotification:isLeftHandle];
        [self delegateDraggingNotification:isLeftHandle xOffset:-1*_pitchMoved];
        [self delegateDragEndNotification:isLeftHandle];
    }else if(point.x > arrow.bounds.size.width/2 && point.x < arrow.bounds.size.width){
        [self delegateDragStartNotification:isLeftHandle];
        [self delegateDraggingNotification:isLeftHandle xOffset:1*_pitchMoved];
        [self delegateDragEndNotification:isLeftHandle];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture isLeftHandle:(bool)isLeftHandle
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self delegateDragStartNotification:isLeftHandle];
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [gesture translationInView:self];
            [self delegateDraggingNotification:isLeftHandle xOffset:translation.x];
            [gesture setTranslation:CGPointZero inView:self];
            break;
        }
        case UIGestureRecognizerStateEnded:
            [self delegateDragEndNotification:isLeftHandle];
            break;
        default: break;
    }
}

- (void)delegateDragStartNotification:(bool)isLeftHandle
{
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timeSpan:dragHandleStarted:isLeftHandle:)];
    if (isResponds)
        [self.delegate timeSpan:self dragHandleStarted:self isLeftHandle:isLeftHandle];
}

- (void)delegateDraggingNotification:(bool)isLeftHandle xOffset:(double)xOffset
{
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timeSpan:draggingHandle:isLeftHandle:xOffset:)];
    if (isResponds)
        [self.delegate timeSpan:self draggingHandle:self isLeftHandle:isLeftHandle xOffset:xOffset];
}

- (void)delegateDragEndNotification:(bool)isLeftHandle
{
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timeSpan:dragHandleEnded:isLeftHandle:)];
    if (isResponds)
        [self.delegate timeSpan:self dragHandleEnded:self isLeftHandle:isLeftHandle];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                view = subView;
            }
        }
    }
    return view;
}

@end
