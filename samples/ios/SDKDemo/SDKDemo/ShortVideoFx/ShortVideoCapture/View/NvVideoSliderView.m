//
//  NvVideoSliderView.m
//  NvCheez
//
//  Created by 刘东旭 on 2017/12/5.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import "NvVideoSliderView.h"
#import "NvsMultiThumbnailSequenceView.h"

#define NV_SEQUENCE_MIDDLE_HANDLE_WIDTH     18
#define NV_SEQUENCE_SELECTED_HANDLE_WIDTH   20
#define NV_SEQUENCE_UNSELECTED_HANDLE_WIDTH 6

@implementation NvVideoSliderView {
    
    int handleWidth;
    UIImageView *handleCover;
    BOOL _isInpointReset;
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
    _middlePoint = 0;
    _selected = true;
    _editable = true;
    _padding = 0;
    _pointsPerMicrosecond = 1;
    _isInpointReset = true;
    handleWidth = 6;
    self.frame = CGRectMake(0, 0, 50, 50);
    
    _leftHandle = [[UIImageView alloc] initWithFrame:CGRectMake(-handleWidth, 0, handleWidth, self.bounds.size.height)];
    _leftHandle.userInteractionEnabled = YES;
    [_leftHandle setImage:[UIImage imageNamed:@"nvcheez_edit_clip_trim_left"]];
    [self addSubview:_leftHandle];
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
    [_leftHandle addGestureRecognizer:leftPan];
    
    _rightHandle = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-1, 0, handleWidth, self.bounds.size.height)];
    _rightHandle.userInteractionEnabled = YES;
    [_rightHandle setImage:[UIImage imageNamed:@"nvcheez_edit_clip_trim_right"]];
    [self addSubview:_rightHandle];
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
    [_rightHandle addGestureRecognizer:rightPan];
    
    
    _middleHandle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, NV_SEQUENCE_MIDDLE_HANDLE_WIDTH, self.bounds.size.height)];
    [_middleHandle setImage:[UIImage imageNamed:@"nvcheez_edit_clip_trim_middle"]];
    _middleHandle.userInteractionEnabled = YES;
    [self addSubview:_middleHandle];
    UIPanGestureRecognizer *middlePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMiddlePan:)];
    [_middleHandle addGestureRecognizer:middlePan];
}

- (void)setInPoint:(int64_t)inPoint {
    _inPoint = inPoint;
    _isInpointReset = true;
    if (self.superview != nil) {
        [self updateFrame];
    }
    
}

- (void)setOutPoint:(int64_t)outPoint {
    _outPoint = outPoint;
    _isInpointReset = false;
    if (self.superview != nil) {
        [self updateFrame];
    }
}

- (void)setPadding:(double)padding {
    _padding = padding;
    if (self.superview != nil) {
        [self updateFrame];
    }
}

- (void)setPointsPerMicrosecond:(double)pointsPerMicrosecond {
    _pointsPerMicrosecond = pointsPerMicrosecond;
    if (self.superview != nil) {
        [self updateFrame];
    }
}

- (void)setSelected:(bool)selected {
    _selected = selected;
    [self setColor];
    if (self.superview != nil) {
        [self updateFrame];
        if (selected) {
            [self.superview bringSubviewToFront:self];
        }
    }
}

- (void)setEditable:(bool)editable {
    _editable = editable;
    [self setColor];
    if (self.superview != nil) {
        [self updateFrame];
    }
}

- (void)setColor {
    if (_selected) {
        if (_editable) {
            self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        } else {
            self.backgroundColor = [UIColor colorWithRed:0.212 green:0.82 blue:0.796 alpha:0.5];
        }
        self.layer.borderWidth = 2;
    } else {
        self.layer.borderWidth = 0;
        self.backgroundColor = [UIColor colorWithRed:0.09 green:0.5 blue:0.835 alpha:0.5];
        _leftHandle.backgroundColor = [self.backgroundColor colorWithAlphaComponent:1];
        _rightHandle.backgroundColor = _leftHandle.backgroundColor;
    }
}

- (void)updateFrame {
    if (_selected && _editable) {
        handleWidth = NV_SEQUENCE_SELECTED_HANDLE_WIDTH;
    } else {
        handleWidth = NV_SEQUENCE_UNSELECTED_HANDLE_WIDTH;
    }
    CGRect frame = self.frame;
    CGFloat h = frame.size.height;
    if (self.superview != nil) {
        h = self.superview.bounds.size.height;
    }
    CGFloat x = _padding+_inPoint*_pointsPerMicrosecond;
    CGFloat width = (_outPoint-_inPoint)*_pointsPerMicrosecond;
    if (self.superview != nil) {
        int64_t newIn = _inPoint;
        int64_t newOut = _outPoint;
        int64_t left = [(NvsMultiThumbnailSequenceView*)self.superview mapTimelinePosFromX:0];
        if (_inPoint < left) {
//            newIn = left;
        }
        int64_t right = [(NvsMultiThumbnailSequenceView*)self.superview mapTimelinePosFromX:((NvsMultiThumbnailSequenceView*)self.superview).bounds.size.width];
        if (_outPoint > right) {
            newOut = right;
        }
        x = _padding+newIn*_pointsPerMicrosecond;
        width = (newOut-newIn)*_pointsPerMicrosecond;
    }
    x -= handleWidth;
    width += 2*handleWidth;
    self.frame = CGRectMake(x, 0, width, h);
    [self updateHandleFrame];
}

- (void)updateHandleFrame {
    _leftHandle.userInteractionEnabled = NO;
    _rightHandle.userInteractionEnabled = NO;
    if (_selected && _editable) {
        _leftHandle.userInteractionEnabled = YES;
        _rightHandle.userInteractionEnabled = YES;
    }
    CGRect frame = self.bounds;
    _leftHandle.frame = CGRectMake(0, 0, handleWidth, frame.size.height);
    _rightHandle.frame = CGRectMake(frame.size.width - handleWidth, 0, handleWidth, frame.size.height);
    _middleHandle.frame = CGRectMake(handleWidth, 0, NV_SEQUENCE_MIDDLE_HANDLE_WIDTH, frame.size.height);
    if (_isInpointReset) {
        _middleHandle.frame = CGRectMake(handleWidth - NV_SEQUENCE_MIDDLE_HANDLE_WIDTH/3, 0, NV_SEQUENCE_MIDDLE_HANDLE_WIDTH, frame.size.height);
    } else {
        _middleHandle.frame = CGRectMake(frame.size.width - handleWidth-NV_SEQUENCE_MIDDLE_HANDLE_WIDTH + NV_SEQUENCE_MIDDLE_HANDLE_WIDTH/3, 0, NV_SEQUENCE_MIDDLE_HANDLE_WIDTH, frame.size.height);
    }
    [self bringSubviewToFront:_middleHandle];
}

#pragma mark - Gestures

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    [self handlePan:gesture handleIndex:0];
    _middleHandle.transform = CGAffineTransformMakeTranslation(0, 0);
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    [self handlePan:gesture handleIndex:1];
    _middleHandle.transform = CGAffineTransformMakeTranslation(0, 0);
}

- (void)handleMiddlePan:(UIPanGestureRecognizer *)gesture {
    [self handlePan:gesture handleIndex:2];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture handleIndex:(int)handleIndex
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self delegateDragStartNotification:handleIndex];
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [gesture translationInView:self];
            [self delegateDraggingNotification:handleIndex xOffset:translation.x];
            [gesture setTranslation:CGPointZero inView:self];

            if (handleIndex == 2) {
                float position = _middleHandle.frame.origin.x + translation.x;
                if (position < NV_SEQUENCE_SELECTED_HANDLE_WIDTH - NV_SEQUENCE_MIDDLE_HANDLE_WIDTH/3) {
                    position = NV_SEQUENCE_SELECTED_HANDLE_WIDTH - NV_SEQUENCE_MIDDLE_HANDLE_WIDTH/3;
                }
                if (position > self.frame.size.width - NV_SEQUENCE_SELECTED_HANDLE_WIDTH-NV_SEQUENCE_MIDDLE_HANDLE_WIDTH + NV_SEQUENCE_MIDDLE_HANDLE_WIDTH/3) {
                    position = self.frame.size.width - NV_SEQUENCE_SELECTED_HANDLE_WIDTH-NV_SEQUENCE_MIDDLE_HANDLE_WIDTH + NV_SEQUENCE_MIDDLE_HANDLE_WIDTH/3;
                }
                _middleHandle.frame = CGRectMake(position, 0, NV_SEQUENCE_MIDDLE_HANDLE_WIDTH, _middleHandle.frame.size.height);
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
            [self delegateDragEndNotification:handleIndex];
            break;
        default: break;
    }
}

- (void)delegateDragStartNotification:(int)handleIndex
{
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timeSpan:dragHandleStarted:handleIndex:)];
    if (isResponds) {
        [self.delegate timeSpan:self dragHandleStarted:self handleIndex:handleIndex];
    }
}

- (void)delegateDraggingNotification:(int)handleIndex xOffset:(double)xOffset
{
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timeSpan:draggingHandle:handleIndex:xOffset:)];
    if (isResponds) {
        [self.delegate timeSpan:self draggingHandle:self handleIndex:handleIndex  xOffset:xOffset];
    }
}

- (void)delegateDragEndNotification:(int)handleIndex
{
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timeSpan:dragHandleEnded:handleIndex:)];
    if (isResponds) {
        [self.delegate timeSpan:self dragHandleEnded:self handleIndex:handleIndex];
    }
}


@end
