//
//  NvsRecordingProgress.m
//  progress
//
//  Created by Meicam on 2018/3/17.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvsRecordingProgress.h"
#import <Masonry/Masonry.h>
#import <NvSDKCommon/NvUtils.h>

@interface NvsRecordingProgress () {
    CABasicAnimation *animation;
}

@property (strong, nonatomic) UIView *redView;
@property (strong, nonatomic) NSTimer *timer;
///存放动态创建的进度条
///Stores the dynamically created progress bar
@property (strong, nonatomic) NSMutableArray *viewsArray;
///存放动态创建的闪烁图标
///Stores dynamically created blinking ICONS
@property (strong, nonatomic) NSMutableArray *flickerArray;
///每段的末尾坐标
///The trailing coordinates of each segment
@property (strong, nonatomic) NSMutableArray *pointxNums;
@property (assign, nonatomic) int64_t value;

@property (assign, nonatomic) NSUInteger getCount;

@end

@implementation NvsRecordingProgress

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexString:NV_CAPTURE_PROGRESS_BACKGROUND alpha:.4];
        
        self.viewsArray = [NSMutableArray new];
        self.flickerArray = [NSMutableArray new];
        self.pointxNums = [NSMutableArray new];
        [self.pointxNums addObject:@(0)];
        self.status = End;
    }
    return self;
}

- (void)beginProgress {
    if ((self.status != End) && (self.status != Prepare)) {
        return;
    }
    ///每次开始移除上一个打点视图的动画
    ///Remove the animation from the previous dot view each start
    UIView *lastflicker = [self.flickerArray lastObject];
    [lastflicker.layer removeAllAnimations];
    UIView *lastView = [self.viewsArray lastObject];
    lastView.backgroundColor =  [UIColor colorWithRed:248/255.0 green:231/255.0 blue:28/255.0 alpha:1/1.0];
    [lastView.layer removeAllAnimations];
    
    ///创建视频进度视图
    ///Create a video progress view
    UIView *view = [UIView new];
    view.backgroundColor =  [UIColor colorWithRed:248/255.0 green:231/255.0 blue:28/255.0 alpha:1/1.0];
    [self addSubview:view];
    [self sendSubviewToBack:view];
    ///创建视图，并加入数组中
    ///Create a view and add it to the array
    [self.viewsArray addObject:view];
    self.getCount = self.viewsArray.count;
    self.status = Start;
    
}
///动态改变view的宽度
///Change the width of the view dynamically
- (void)currentValue:(int64_t)value {
    if (value>TotalTime) {
        value = TotalTime;
    }
    UIView *currentView = [self.viewsArray lastObject];
    int64_t lastPointx = [[self.pointxNums lastObject] longLongValue];
    float currentStart = (double)lastPointx/TotalTime*self.frame.size.width;
    float valueScale = (double)value/TotalTime;
    currentView.frame = CGRectMake(currentStart, 0, self.frame.size.width*valueScale-currentStart, self.frame.size.height);
    self.value = value;
    self.status = Progressing;
}
///把currentStart改为上一次末尾的值，并创建闪动图标
///Change currentStart to the last value and create a flash icon
- (void)endProgress {
    if (self.status != Progressing) {
        return;
    }
    ///记录没次起始位置的坐标
    ///Record the coordinates of each starting position
    [self.pointxNums addObject:@(self.value)];
    ///记录打点起始位置
    ///Record the starting position of the dot
    float currentStart = (double)self.value/TotalTime*self.frame.size.width;
    ///创建闪烁视图
    ///Create a scintillation view
    UIView *view= [UIView new];
    [self addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = CGRectMake(currentStart-1, 0, 2, self.frame.size.height);
    ///开始闪烁
    ///Start flashing
    [self.flickerArray addObject:view];
    [self autoFlickView:view];
    self.status = End;
}

- (void)prepareDelete {
    if (self.status != End) {
        return;
    }
    self.status = Prepare;
    ///打点视图停止闪烁
    ///The dot view stops blinking
    UIView *lastflicker = [self.flickerArray lastObject];
    [lastflicker.layer removeAllAnimations];
    ///视频片段开始闪烁
    ///The video clips started flashing
    UIView *lastView = [self.viewsArray lastObject];
    [self autoFlickView:lastView];
    
}

- (void)deleteProgress {
    if (self.status != Prepare) {
        return;
    }
    
    UIView *lastflicker = [self.flickerArray lastObject];
    UIView *lastView = [self.viewsArray lastObject];
    
    ///移除保存的数据
    ///Remove saved data
    [self.viewsArray removeLastObject];
    self.getCount = self.viewsArray.count;
    [self.flickerArray removeLastObject];
    [self.pointxNums removeLastObject];
    
    ///移除视图
    ///Remove view
    [lastView removeFromSuperview];
    [lastflicker removeFromSuperview];
    
    self.value = [self.pointxNums.lastObject integerValue];
    
    ///让上一个标记点闪动
    ///Let the previous marker flash
    [self autoFlickView:[self.flickerArray lastObject]];
    self.status = End;
    
}

///闪烁view
///Flicker view
- (void)autoFlickView:(UIView *)view {
    ///必须写opacity才行。
    ///opacity must be written.
    animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.autoreverses = YES;
    animation.duration = 0.5;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [view.layer addAnimation:animation forKey:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.redView.frame = CGRectMake(self.frame.size.width/5-1.5, 0, 3, self.frame.size.height);
    [self bringSubviewToFront:self.redView];
}

- (int64_t)getValue {
    int64_t per = [[self.pointxNums lastObject] longLongValue];
    return per;
}

- (BOOL)singleRecordingOverFifteen {
    int64_t per = [[self.pointxNums lastObject] longLongValue];
    if (per == TotalTime && self.pointxNums.count == 2) {
        return YES;
    } else {
        return NO;
    }
}

- (void)dealloc {
    animation = nil;
}

- (int64_t)getMinRecordTime {
    return MinRecordTime;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
