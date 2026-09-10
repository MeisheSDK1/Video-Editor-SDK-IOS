//
//  NvCanvasView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/9/27.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCanvasView.h"
#import <NvSDKCommon/NvWeakTimer.h>

@interface NvCanvasView ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) int64_t startTime;
@property (nonatomic, assign) int64_t durationTime;
@property (nonatomic, strong) NvWeakTimer *timer;
///平移手势——当前点
///Pan gesture -- current point
@property (nonatomic, assign) CGPoint panPoint;
///长按手势——当前点
///Hold the gesture -- current point
@property (nonatomic, assign) CGPoint longPoint;
///累计每次加多少微秒
///Add up the number of microseconds each time
@property (nonatomic, assign) int64_t timeCumulative;

@end


@implementation NvCanvasView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        _timeCumulative = 40000;
        UIPanGestureRecognizer *panP = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizer:)];
        [self addGestureRecognizer:panP];
        
        UILongPressGestureRecognizer *longP = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognizer:)];
        [self addGestureRecognizer:longP];
        
        panP.delegate = self;
        longP.delegate = self;
    }
    return self;
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)pan{
    if (pan.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [pan locationInView:self];
        _panPoint = point;
        if ([self.delegate respondsToSelector:@selector(canvasViewState:)]) {
            [self.delegate canvasViewState:point];
        }
        self.durationTime = 0;
        _timer = [NvWeakTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(timerDurationd:) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        
    }else if (pan.state == UIGestureRecognizerStateChanged){
        CGPoint point = [pan locationInView:self];
        _panPoint = point;
    }else if (pan.state == UIGestureRecognizerStateEnded){
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        if ([self.delegate respondsToSelector:@selector(canvasViewEnd:)]) {
            [self.delegate canvasViewEnd:self.durationTime];
        }
    }
}

- (void)longPressGestureRecognizer:(UIPanGestureRecognizer *)longP{
    if (longP.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [longP locationInView:self];
        _longPoint = point;
        if ([self.delegate respondsToSelector:@selector(canvasViewState:)]) {
            [self.delegate canvasViewState:point];
        }
        self.durationTime = 0;
        _timer = [NvWeakTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(timerDuration:) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    }else if (longP.state == UIGestureRecognizerStateChanged){
        CGPoint point = [longP locationInView:self];
        _longPoint = point;
    }else if (longP.state == UIGestureRecognizerStateEnded){
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        if ([self.delegate respondsToSelector:@selector(canvasViewEnd:)]) {
            [self.delegate canvasViewEnd:self.durationTime];
        }
    }
}

- (void)timerDuration:(NvWeakTimer *)timer{
    self.durationTime += _timeCumulative;
    if ([self.delegate respondsToSelector:@selector(canvasViewDuration:withPosition:)]) {
        [self.delegate canvasViewDuration:_durationTime withPosition:_longPoint];
    }
}

- (void)timerDurationd:(NvWeakTimer *)timer{
    self.durationTime += _timeCumulative;
    if ([self.delegate respondsToSelector:@selector(canvasViewDuration:withPosition:)]) {
        [self.delegate canvasViewDuration:_durationTime withPosition:_panPoint];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
