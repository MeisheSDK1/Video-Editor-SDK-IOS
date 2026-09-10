//
//  NvsTimelineTimeSpan.m
//  NvsTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#import "NvsCTimelineTimeSpan.h"
#import "NvsMultiThumbnailSequenceView.h"
#import <NvSDKCommon/NvUtils.h>

@interface NvsCTimelineTimeSpan ()

@end

@implementation NvsCTimelineTimeSpan {
    UIImageView* leftHandle;
    UIImageView* rightHandle;
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

#pragma mark - 初始化
/*
 初始化
 initialization
 
 */
- (void)initInternal {
    _inPoint = 0;
    _outPoint = 0;
    _selected = false;
    _editable = false;
    _padding = 0;
    _pointsPerMicrosecond = 1;
    handleWidth = 13;
    self.frame = CGRectMake(0, 0, 50, 50);
    
    leftHandle = [[UIImageView alloc] initWithFrame:CGRectMake(-handleWidth, 0, handleWidth, self.bounds.size.height)];
    leftHandle.image = NvImageNamed(@"NvTailoringLeft");
    leftHandle.userInteractionEnabled = YES;
    [self addSubview:leftHandle];
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
    [leftHandle addGestureRecognizer:leftPan];
    
    rightHandle = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-1, 0, handleWidth, self.bounds.size.height)];
    rightHandle.userInteractionEnabled = YES;
    rightHandle.image = NvImageNamed(@"NvTailoringRight");
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
        if (selected){
            [self.superview bringSubviewToFront:self];
        }
    }
}

- (void)setEditable:(bool)editable {
    _editable = editable;
    [self setColor];
    if (self.superview != nil)
        [self updateFrame];
}

- (void)setTimeSpanColor:(UIColor *)timeSpanColor {
    _timeSpanColor = timeSpanColor;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_timeSpanColor) {
        self.backgroundColor = _timeSpanColor;
    } else {
        self.backgroundColor = [UIColor nv_colorWithHexARGB:@"#994A90E2"];
    }
}

#pragma mark - 设置背景颜色
/*
 设置背景颜色
 Set background color
 
 */
- (void)setColor {
    if (_selected) {

    } else {
        self.layer.borderWidth = 0;
        self.backgroundColor = [UIColor nv_colorWithHexARGB:@"#994A90E2"];
    }
}

- (void)updateFrame {
    if (_selected && _editable)
        handleWidth = 13;
    else
        handleWidth = 0;
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

#pragma mark - 更新左右控件的状态
/*
 更新左右控件的状态
 Update the status of the left and right controls
 
 */
- (void)updateHandleFrame {
    leftHandle.userInteractionEnabled = NO;
    rightHandle.userInteractionEnabled = NO;
    if (_selected && _editable) {
        leftHandle.userInteractionEnabled = YES;
        rightHandle.userInteractionEnabled = YES;
    }
    CGRect frame = self.bounds;
    leftHandle.frame = CGRectMake(0, -1, handleWidth, frame.size.height+ 2);
    rightHandle.frame = CGRectMake(frame.size.width-handleWidth, -1, handleWidth, frame.size.height +2);
}

#pragma mark - Gestures
/*
 左控件的平移事件
 The pan event of the left control
 */
- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    [self handlePan:gesture isLeftHandle:true];
}

/*
 右控件的平移事件
 The pan event of the right control
 */
- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    [self handlePan:gesture isLeftHandle:false];
}

/*
 控件的平移事件
 The pan event of the control
 
 @param gesture 当前手势 Current gesture
 @param isLeftHandle 是否是左边控件 Whether it is the left control
 */
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

/*
 开始拖拽
 Start dragging
 
 @param isLeftHandle 是否是左边控件 Whether it is the left control
 */
- (void)delegateDragStartNotification:(bool)isLeftHandle
{
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timeSpan:dragHandleStarted:isLeftHandle:)];
    if (isResponds)
        [self.delegate timeSpan:self dragHandleStarted:self isLeftHandle:isLeftHandle];
}

/*
 拖拽中
 Dragging
 
 @param isLeftHandle 是否是左边控件 Whether it is the left control
 @param xOffset 滑动的距离 Sliding distance
 */
- (void)delegateDraggingNotification:(bool)isLeftHandle xOffset:(double)xOffset
{
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timeSpan:draggingHandle:isLeftHandle:xOffset:)];
    if (isResponds)
        [self.delegate timeSpan:self draggingHandle:self isLeftHandle:isLeftHandle xOffset:xOffset];
}

/*
 拖拽结束
 Drag to end
 
 @param isLeftHandle 是否是左边控件 Whether it is the left control
 */
- (void)delegateDragEndNotification:(bool)isLeftHandle
{
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timeSpan:dragHandleEnded:isLeftHandle:)];
    if (isResponds)
        [self.delegate timeSpan:self dragHandleEnded:self isLeftHandle:isLeftHandle];
}

@end
