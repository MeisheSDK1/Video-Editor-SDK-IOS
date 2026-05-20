//
//  NvVideoSlider.m
//  NvCheez
//
//  Created by 刘东旭 on 2017/12/5.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import "NvVideoSlider.h"
#import "NvsMultiThumbnailSequenceView.h"
#import <math.h>

#define NV_TIME_BASE 1000000

#define SliderWidth 15

typedef enum {
    UNKOWN,
    LEFTSLIDER,
    RIGHTSLIDER,
}SliderDir;

@interface NvVideoSliderInfo()



@end

@implementation NvVideoSliderInfo
@end


@interface NvVideoSlider () <UIScrollViewDelegate>{
    UIView *topLine;
    UIView *bottomLine;
    UIView *leftLayerView;
    UIView *rightLayerView;
}
@property (nonatomic, strong) UIImageView *leftSliderView;
@property (nonatomic, strong) UIImageView *rightSliderView;
@property (nonatomic,assign) int padding;
@property (nonatomic, assign) int64_t minDuration;
@property (nonatomic, assign) SliderDir sliderDir;
@property (nonatomic, strong) NvsMultiThumbnailSequenceView* sequenceView;
@end


@implementation NvVideoSlider {
    UIView* timeAxis;
    NSMutableArray* timeSpanItemArray;
    double pointsPerMicrosecond;
    int64_t minDraggedTimeSpanDuration;
    bool changingTimelinePosFromScrollingClipReel;
    int _offset;
}

- (instancetype)initWithFrame:(CGRect)frame withOffset:(CGFloat)offset {
    if (self = [super initWithFrame:frame]){
        _offset = offset;
        [self setupWithFrame:frame];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWithFrame:frame];
    }
    return self;
}

- (void)setupWithFrame:(CGRect)frame {
    self.minDuration = 3000000;
    [self setBackgroundColor:[UIColor blackColor]];
    CGFloat width = frame.size.width;
    pointsPerMicrosecond = width/35/NV_TIME_BASE;
    self.sequenceView = [[NvsMultiThumbnailSequenceView alloc] initWithFrame:frame];
    self.sequenceView.delegate = self;
    self.sequenceView.thumbnailImageFillMode = NvsThumbnailFillModeAspectCrop;
    self.sequenceView.thumbnailAspectRatio = 0.5;
    self.sequenceView.pointsPerMicrosecond = pointsPerMicrosecond;
    self.sequenceView.startPadding = 30;
    self.sequenceView.endPadding = self.sequenceView.startPadding;
    self.sequenceView.bounces = NO;
    [self.sequenceView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.sequenceView];
    timeAxis = [[UIView alloc] initWithFrame:CGRectMake(35, -3, 2, frame.size.height+6)];
    [timeAxis setBackgroundColor:[UIColor clearColor]];
    [self addSubview:timeAxis];
    
    ///默认设置距离左边15
    ///The default setting is 15 to the left
    if (_offset < 0) {
        self.padding = 15;
    } else {
        self.padding = _offset;
        self.sequenceView.startPadding = _offset + SliderWidth;
        self.sequenceView.endPadding = _offset + SliderWidth;
    }
    ///添加左滑块
    ///Add the left slider
    self.leftSliderView = [[UIImageView alloc] initWithFrame:CGRectMake(self.padding, -2, SliderWidth, frame.size.height+4)];
    self.leftSliderView.image = [UIImage imageNamed:@"NvTailoringLeft_on"];
    self.leftSliderView.userInteractionEnabled = YES;
    [self addSubview:self.leftSliderView];
    ///添加右滑块
    ///Add the right slider
    self.rightSliderView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-SliderWidth-self.padding-110, -2, SliderWidth, frame.size.height+4)];
    self.rightSliderView.image = [UIImage imageNamed:@"NvTailoringRight_on"];
    self.rightSliderView.userInteractionEnabled = YES;
    [self addSubview:self.rightSliderView];
    ///上边黄色条
    ///Upper yellow bar
    topLine = [[UIView alloc] initWithFrame:CGRectMake(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width, 0, self.rightSliderView.frame.origin.x-(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width), 2)];
    topLine.backgroundColor = [UIColor clearColor];
    [self addSubview:topLine];
    [self insertSubview:topLine belowSubview:self.leftSliderView];
    ///下边黄色条
    ///Bottom yellow bar
    bottomLine = [[UIView alloc] initWithFrame:CGRectMake(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width, self.frame.size.height-2, self.rightSliderView.frame.origin.x-(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width), 2)];
    bottomLine.backgroundColor = [UIColor clearColor];
    [self addSubview:bottomLine];
    [self insertSubview:bottomLine belowSubview:self.leftSliderView];
    [self bringSubviewToFront:timeAxis];
    
    ///添加蒙层
    ///Adding mask
    leftLayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.leftSliderView.left, self.leftSliderView.frame.size.height)];
    leftLayerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    [self.sequenceView addSubview:leftLayerView];
    rightLayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.leftSliderView.frame.size.height)];
    rightLayerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    [self.sequenceView addSubview:rightLayerView];
}

- (void)setMinimumDuration:(double)minDuration {
    self.minDuration = minDuration;
}

/// timeline时间转偏移量
/// convert the time in timeline to offset in view
/// @param time time
- (float)offsetXFromTimeline:(int64_t)time {
    return [self.sequenceView mapXFromTimelinePos:time];
}

/// 将偏移量转timeline上的时间
/// convert the offset in view to time in timeline
/// @param offsetX offsetX
- (int64_t)timelineFromOffset:(float)offsetX {
    return [self.sequenceView mapTimelinePosFromX:offsetX];
}


/// 设置界面宽度和时间关系，每秒对应多长距离
/// Set the relationship between the view width and duration,the corresponding distance per second
/// @param duration duration of timeline
- (void)setSequencePointsPerMicrosecond:(int)duration {
    CGFloat width = self.frame.size.width;
    self.sequenceView.pointsPerMicrosecond = width/duration/NV_TIME_BASE;
}


/// 初始化timelineEditor
/// initial timelineEditor
/// @param timelineEditorInfos timelineEditorInfos
/// @param timelineDuration timelineDuration
- (void)initTimelineEditor:(NSArray*) timelineEditorInfos timelineDuration:(int64_t)timelineDuration {
    if (timelineEditorInfos == nil)
        return;
    NSMutableArray* descArray = [NSMutableArray array];
    for (int i=0; i<timelineEditorInfos.count; i++) {
        NvVideoSliderInfo* info = (NvVideoSliderInfo*)timelineEditorInfos[i];
        NvsThumbnailSequenceDesc* desc = [[NvsThumbnailSequenceDesc alloc] init];
        desc.mediaFilePath = info.mediaFilePath;
        desc.inPoint = info.inPoint;
        desc.outPoint = info.outPoint;
        desc.trimIn = info.trimIn;
        desc.trimOut = info.trimOut;
        desc.stillImageHint = info.stillImageHint;
        [descArray addObject:desc];
    }
    self.sequenceView.descArray = descArray;
    
    self.timelineDuration = timelineDuration;
    //判断时间是否超过最大时长秒数
    //check whether the timelineDuration over the maximumDuration
    if (self.timelineDuration >= self.maximumDuration) {
        float x = [self offsetXFromTimeline:self.maximumDuration];
        self.rightSliderView.frame = CGRectMake(x, -2, SliderWidth, self.frame.size.height+4);
        self.sequenceView.endPadding = self.frame.size.width-self.rightSliderView.frame.origin.x;
        topLine.frame = CGRectMake(self.leftSliderView.frame.origin.x+SliderWidth/2, 0, self.rightSliderView.frame.origin.x-self.leftSliderView.frame.origin.x, 2);
        bottomLine.frame = CGRectMake(self.leftSliderView.frame.origin.x+SliderWidth/2, self.leftSliderView.frame.size.height-2, self.rightSliderView.frame.origin.x-self.leftSliderView.frame.origin.x, 2);
    } else {
        float x = [self offsetXFromTimeline:self.timelineDuration];
        self.rightSliderView.frame = CGRectMake(x, -2, SliderWidth, self.frame.size.height+4);
        topLine.frame = CGRectMake(self.leftSliderView.frame.origin.x+SliderWidth/2, 0, self.rightSliderView.frame.origin.x-self.leftSliderView.frame.origin.x, 2);
        bottomLine.frame = CGRectMake(self.leftSliderView.frame.origin.x+SliderWidth/2, self.leftSliderView.frame.size.height-2, self.rightSliderView.frame.origin.x-self.leftSliderView.frame.origin.x, 2);
    }
    
    rightLayerView.frame = CGRectMake(self.rightSliderView.frame.origin.x+SliderWidth, 0, self.frame.size.width-(self.rightSliderView.frame.origin.x+SliderWidth), self.leftSliderView.frame.size.height);
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    //获取手指位置判断在哪个滑块上
    //judge the touch point in which slider
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    //按住了左滑块
    //the touch point in the left slider
    if (CGRectContainsPoint(self.leftSliderView.frame, touchPoint)) {
        _sliderDir = LEFTSLIDER;
        int64_t time = [self timelineFromOffset:self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width];
        int64_t timeout = [self timelineFromOffset:self.rightSliderView.frame.origin.x];
        if (time < 0) {
            //浮点型运算有偏差做容错处理
            //Fault tolerant processing for floating point operation with deviation
            time = 0;
        }
        if ([self.delegate respondsToSelector:@selector(timelineEditor:dragHandleStarted:trimOut:)]) {
            [self.delegate timelineEditor:self.leftSliderView dragHandleStarted:time trimOut:timeout];
        }
        return;
    }
    //按住了右滑块
    //the touch point in the right slider
    if (CGRectContainsPoint(self.rightSliderView.frame, touchPoint)) {
        _sliderDir = RIGHTSLIDER;
        int64_t timeOut = [self timelineFromOffset:self.rightSliderView.frame.origin.x];
        int64_t timetrimin = [self timelineFromOffset:self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width];
        if (timetrimin < 0) {
            //浮点型运算有偏差做容错处理
            //Fault tolerant processing for floating point operation with deviation
            timetrimin = 0;
        }
        if ([self.delegate respondsToSelector:@selector(timelineEditor:dragHandleStarted:trimOut:)]) {
            [self.delegate timelineEditor:self.leftSliderView dragHandleStarted:timetrimin trimOut:timeOut];
        }
        return;
    }
    _sliderDir = UNKOWN;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    //判断手指是否划出去
    //check whether the touch point out the slider view
    if (touchPoint.x<=SliderWidth/2+self.padding) {
        touchPoint.x = SliderWidth/2+self.padding;
    }
    if (touchPoint.x>=self.frame.size.width-SliderWidth/2-self.padding) {
        touchPoint.x = self.frame.size.width-SliderWidth/2-self.padding;
    }
    touchPoint.y = self.frame.size.height/2;
    
    //左右滑块放到对应手指位置
    //move the left and right slider to corresponding finger touch points
    if (_sliderDir == LEFTSLIDER) {
        CGPoint removePoint = touchPoint;
        float maxOffsetx = [self offsetXFromTimeline:self.maximumDuration]+self.sequenceView.contentOffset.x-self.sequenceView.startPadding;
        float minOffsetx = [self offsetXFromTimeline:self.minDuration]+self.sequenceView.contentOffset.x-self.sequenceView.startPadding;
        if ((self.rightSliderView.center.x - touchPoint.x - SliderWidth) >= maxOffsetx) {
            removePoint = CGPointMake(self.rightSliderView.center.x - maxOffsetx - SliderWidth, touchPoint.y);
        }
        if ((self.rightSliderView.center.x-SliderWidth - touchPoint.x) <= minOffsetx) {
            removePoint = CGPointMake(self.rightSliderView.center.x - minOffsetx - SliderWidth, touchPoint.y);
        }
        
        self.leftSliderView.center = removePoint;
        CGPoint pL = [self convertPoint:CGPointMake(self.leftSliderView.frame.origin.x, 0) toView:self.sequenceView];
        leftLayerView.frame = CGRectMake(0, 0, pL.x, self.leftSliderView.frame.size.height);
        timeAxis.frame = CGRectMake(self.leftSliderView.center.x+self.leftSliderView.frame.size.width/2, -3, 2, self.leftSliderView.frame.size.height+6);
        int64_t time = [self timelineFromOffset:self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width];
        int64_t timeout = [self timelineFromOffset:self.rightSliderView.frame.origin.x];
        NSLog(@"------>timeOut:%lld, timeIn:%lld",timeout,time);
        if (time < 0) {
            //浮点型运算有偏差做容错处理
            //Fault tolerant processing for floating point operation with deviation
            time = 0;
        }
        if ([self.delegate respondsToSelector:@selector(timelineEditor:draggingHandle:trimOut:)]) {
            [self.delegate timelineEditor:self.leftSliderView draggingHandle:time trimOut:timeout];
        }
    } else if (self.sliderDir == RIGHTSLIDER) {
        CGPoint removePoint = touchPoint;
        //大于最大值
        //more than the max value
        float maxOffsetx = [self offsetXFromTimeline:self.maximumDuration]+self.sequenceView.contentOffset.x-self.sequenceView.startPadding;
        float minOffsetx = [self offsetXFromTimeline:self.minDuration]+self.sequenceView.contentOffset.x-self.sequenceView.startPadding;
        if ((touchPoint.x-SliderWidth - self.leftSliderView.center.x) >= maxOffsetx) {
            removePoint = CGPointMake(SliderWidth + self.leftSliderView.center.x + maxOffsetx, touchPoint.y);
        }
        //小于1秒
        //less than 1 sec
        if ((touchPoint.x-SliderWidth - self.leftSliderView.center.x) <= minOffsetx) {
            removePoint = CGPointMake(SliderWidth + self.leftSliderView.center.x + minOffsetx, touchPoint.y);
        }
        //超出总时间
        //over the tiemlineDuration
        if ([self timelineFromOffset:removePoint.x-SliderWidth/2]>=self.timelineDuration) {
            self.rightSliderView.center = CGPointMake([self offsetXFromTimeline:self.timelineDuration]+SliderWidth/2, self.rightSliderView.center.y);
        } else {
            self.rightSliderView.center = removePoint;
        }
        
        self.sequenceView.endPadding = self.frame.size.width-self.rightSliderView.frame.origin.x;
        CGPoint pR = [self convertPoint:CGPointMake(self.rightSliderView.frame.origin.x+SliderWidth, 0) toView:self.sequenceView];
        rightLayerView.frame = CGRectMake(pR.x, 0, self.frame.size.width-(self.rightSliderView.frame.origin.x+SliderWidth), self.leftSliderView.frame.size.height);
        timeAxis.frame = CGRectMake(self.leftSliderView.center.x+self.leftSliderView.frame.size.width/2, -3, 2, self.leftSliderView.frame.size.height+6);
        
        int64_t timeOut = [self timelineFromOffset:self.rightSliderView.frame.origin.x];
        int64_t timeIn = [self timelineFromOffset:self.leftSliderView.frame.origin.x+SliderWidth];
        NSLog(@"====>timeOut:%lld, timeIn:%lld",timeOut,timeIn);
        if (timeIn < 0) {
            //浮点型运算有偏差做容错处理
            //Fault tolerant processing for floating point operation with deviation
            timeIn = 0;
        }
        if ([self.delegate respondsToSelector:@selector(timelineEditor:draggingHandle:trimOut:)]) {
            [self.delegate timelineEditor:self.rightSliderView draggingHandle:timeIn trimOut:timeOut];
        }
    } else {
        return;
    }
    //设置上下两条线的frame
    //set the up and down line view's frame
    topLine.frame = CGRectMake(self.leftSliderView.frame.origin.x+SliderWidth/2, 0, self.rightSliderView.frame.origin.x-self.leftSliderView.frame.origin.x, 2);
    bottomLine.frame = CGRectMake(self.leftSliderView.frame.origin.x+SliderWidth/2, self.leftSliderView.frame.size.height-2, self.rightSliderView.frame.origin.x-self.leftSliderView.frame.origin.x, 2);
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (_sliderDir == LEFTSLIDER) {
        int64_t timeIn = [self timelineFromOffset:self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width];
        int64_t timeOut = [self timelineFromOffset:self.rightSliderView.frame.origin.x];
        if (timeIn < 0) {
            //浮点型运算有偏差做容错处理
            //Fault tolerant processing for floating point operation with deviation
            timeIn = 0;
        }
        if ([self.delegate respondsToSelector:@selector(timelineEditor:dragHandleEnded:trimOut:)]) {
            [self.delegate timelineEditor:self.leftSliderView dragHandleEnded:timeIn trimOut:timeOut];
        }
    } else if (_sliderDir == RIGHTSLIDER) {
        int64_t timeIn = [self timelineFromOffset:self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width];
        int64_t timeOut = [self timelineFromOffset:self.rightSliderView.frame.origin.x];
        if (timeIn < 0) {
            //浮点型运算有偏差做容错处理
            //Fault tolerant processing for floating point operation with deviation
            timeIn = 0;
        }
        if ([self.delegate respondsToSelector:@selector(timelineEditor:dragHandleEnded:trimOut:)]) {
            [self.delegate timelineEditor:self.rightSliderView dragHandleEnded:timeIn trimOut:timeOut];
        }
    }
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (_sliderDir == LEFTSLIDER) {
        int64_t timeIn = [self timelineFromOffset:self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width];
        int64_t timeOut = [self timelineFromOffset:self.rightSliderView.frame.origin.x];
        if (timeIn < 0) {
            //浮点型运算有偏差做容错处理
            //Fault tolerant processing for floating point operation with deviation
            timeIn = 0;
        }
        if ([self.delegate respondsToSelector:@selector(timelineEditor:dragHandleEnded:trimOut:)]) {
            [self.delegate timelineEditor:self.leftSliderView dragHandleEnded:timeIn trimOut:timeOut];
        }
    } else if (_sliderDir == RIGHTSLIDER) {
        int64_t timeIn = [self timelineFromOffset:self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width];
        int64_t timeOut = [self timelineFromOffset:self.rightSliderView.frame.origin.x];
        if (timeIn < 0) {
            //浮点型运算有偏差做容错处理
            //Fault tolerant processing for floating point operation with deviation
            timeIn = 0;
        }
        if ([self.delegate respondsToSelector:@selector(timelineEditor:dragHandleEnded:trimOut:)]) {
            [self.delegate timelineEditor:self.rightSliderView dragHandleEnded:timeIn trimOut:timeOut];
        }
    }
}

#pragma mark - scroll delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self setTimespanMiddleHandlePosition:[self timelineFromOffset:self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    int64_t time = [self timelineFromOffset:self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width];
    if (time < 0) {
        //浮点型运算有偏差做容错处理
        //Fault tolerant processing for floating point operation with deviation
        time = 0;
    }
    [self setTimespanMiddleHandlePosition:time];
    
    CGPoint pL = [self convertPoint:CGPointMake(self.leftSliderView.frame.origin.x, 0) toView:self.sequenceView];
    CGPoint pR = [self convertPoint:CGPointMake(self.rightSliderView.frame.origin.x+SliderWidth, 0) toView:self.sequenceView];
    leftLayerView.frame = CGRectMake(0, 0, pL.x, self.leftSliderView.frame.size.height);
    rightLayerView.frame = CGRectMake(pR.x, 0, self.frame.size.width-(self.rightSliderView.frame.origin.x+SliderWidth), self.leftSliderView.frame.size.height);
    
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor: dragScrollingTimeline:)];
    if (isResponds) {
        [self.delegate timelineEditor:self dragScrollingTimeline:time];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate)
        return;
    int64_t time = [self timelineFromOffset:self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width];
    if (time < 0) {
        //浮点型运算有偏差做容错处理
        //Fault tolerant processing for floating point operation with deviation
        time = 0;
    }
    [self setTimespanMiddleHandlePosition:time];
    
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor: dragScrollTimelineEnded:)];
    if (isResponds)
        [self.delegate timelineEditor:self dragScrollTimelineEnded:time];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    int64_t time = [self timelineFromOffset:self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width];
    if (time < 0) {
        //浮点型运算有偏差做容错处理
        //Fault tolerant processing for floating point operation with deviation
        time = 0;
    }
    [self setTimespanMiddleHandlePosition:time];
    
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor: dragScrollTimelineEnded:)];
    if (isResponds)
        [self.delegate timelineEditor:self dragScrollTimelineEnded:time];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.sequenceView.frame = self.bounds;

}

///设置中间白线的位置
///set the middle white line position
///@param position position
- (void)setTimespanMiddleHandlePosition:(int64_t)position {

    float x = [self offsetXFromTimeline:position];
    timeAxis.frame = CGRectMake(x, -3, 2, self.leftSliderView.frame.size.height+6);
    
}

- (CGFloat)getTimelineEditorWidth{
    return self.sequenceView.contentSize.width;
}
@end
