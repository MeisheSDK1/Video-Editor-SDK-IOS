//
//  NvsTimelineTimeSpan.m
//  NvsTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#import "NvsTimelineTimeSpan.h"
#import "NvsMultiThumbnailSequenceView.h"

@interface NvsTimelineTimeSpan ()

@end

@implementation NvsTimelineTimeSpan {
    UIView* leftHandle;
    UIView* rightHandle;
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
    handleWidth = 6;
    self.frame = CGRectMake(0, 0, 50, 50);
    
    leftHandle = [[UIView alloc] initWithFrame:CGRectMake(-handleWidth, 0, handleWidth, self.bounds.size.height)];
    leftHandle.backgroundColor = [UIColor colorWithRed:0.09 green:0.5 blue:0.835 alpha:1];
    [self addSubview:leftHandle];
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
    [leftHandle addGestureRecognizer:leftPan];
    
    rightHandle = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-1, 0, handleWidth, self.bounds.size.height)];
    rightHandle.backgroundColor = [UIColor colorWithRed:0.09 green:0.5 blue:0.835 alpha:1];
    [self addSubview:rightHandle];
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
    [rightHandle addGestureRecognizer:rightPan];
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
    if (self.superview != nil)
        [self updateFrame];
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
        if (_editable)
            self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        else
            self.backgroundColor = [UIColor colorWithRed:0.212 green:0.82 blue:0.796 alpha:0.5];
        leftHandle.backgroundColor = [UIColor colorWithRed:0.212 green:0.82 blue:0.796 alpha:1];
        rightHandle.backgroundColor = leftHandle.backgroundColor;
        self.layer.borderColor = leftHandle.backgroundColor.CGColor;
        self.layer.borderWidth = 2;
    } else {
        self.layer.borderWidth = 0;
        self.backgroundColor = [UIColor colorWithRed:0.09 green:0.5 blue:0.835 alpha:0.5];
        leftHandle.backgroundColor = [self.backgroundColor colorWithAlphaComponent:1];
        rightHandle.backgroundColor = leftHandle.backgroundColor;
    }
}

- (void)updateFrame {
    if (_selected && _editable)
        handleWidth = 20;
    else
        handleWidth = 6;
    CGRect frame = self.frame;
    CGFloat h = frame.size.height;
    if (self.superview != nil)
        h = self.superview.bounds.size.height;
    CGFloat x = _padding+_inPoint*_pointsPerMicrosecond;
    CGFloat width = (_outPoint-_inPoint)*_pointsPerMicrosecond;
    if (self.superview != nil) {
        int64_t newIn = _inPoint;
        int64_t newOut = _outPoint;
        int64_t left = [(NvsMultiThumbnailSequenceView*)self.superview mapTimelinePosFromX:0];
        if (_inPoint < left)
            newIn = left;
        int64_t right = [(NvsMultiThumbnailSequenceView*)self.superview mapTimelinePosFromX:((NvsMultiThumbnailSequenceView*)self.superview).bounds.size.width];
        if (_outPoint > right)
            newOut = right;
        x = _padding+newIn*_pointsPerMicrosecond;
        width = (newOut-newIn)*_pointsPerMicrosecond;
    }
    x -= handleWidth;
    width += 2*handleWidth;
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
    leftHandle.frame = CGRectMake(0, 0, handleWidth, frame.size.height);
    rightHandle.frame = CGRectMake(frame.size.width-handleWidth, 0, handleWidth, frame.size.height);
}

#pragma mark - Gestures

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    [self handlePan:gesture isLeftHandle:true];
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    [self handlePan:gesture isLeftHandle:false];
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

@end
