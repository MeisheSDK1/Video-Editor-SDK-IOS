//
//  LDXScrollLabel.m
//  ScrollLabel
//
//  Created by 刘东旭 on 2017/12/19.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import "NvScrollLabel.h"
#import "NvWeakTimer.h"

@interface NvScrollLabel () {
    int spase;     //两个文字的间距 The space between two words
    int num;       //能显示多少遍文字 How many times can the text be displayed
    BOOL isScroll; //是否需要滚动 is Need to scroll
    int stayTime;
}

@property(nonatomic, strong) NvWeakTimer *timer;
@property(nonatomic, assign) int offsetX;
@property(nonatomic, assign) CGRect textRect;
@property(nonatomic, strong) NSMutableDictionary *attributesDict;

@end

@implementation NvScrollLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        spase = 25;
        stayTime = 25;
        isScroll = NO;
        self.attributesDict = [NSMutableDictionary dictionary];
        UIFont *font;
        if (![UIFont fontWithName:@"PingFangSC-Regular" size:17]) {
            font = [UIFont systemFontOfSize:17];
        } else {
            font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
        }
        self.attributesDict[NSFontAttributeName] = font;
        self.attributesDict[NSForegroundColorAttributeName] = [UIColor blackColor];

        self.offsetX = self.frame.size.width;
        self.timer = [NvWeakTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(scrollText)
                                                        userInfo:nil
                                                         repeats:YES
                                                   dispatchQueue:dispatch_get_global_queue(0, 0)];
        //        self.timer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(scrollText) userInfo:nil repeats:YES];
        //        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer fire];
    }
    return self;
}

- (void)setScrollType:(LDXScrollType)scrollType {
    _scrollType = scrollType;
    if (scrollType == LDXManualScroll) {
        [self stopAnimate];
    } else {
        [self startAnimate];
    }
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];

    self.attributesDict[NSFontAttributeName] = font;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];

    self.attributesDict[NSForegroundColorAttributeName] = textColor;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text {
    [super setText:text];

    [self setNeedsLayout];
    [self setNeedsDisplay];
}
- (void)scrollText {
    if (self.offsetX == 0) {
        if (stayTime > 0) {
            stayTime = stayTime - 1;
            return;
        }

        stayTime = 25;
    }

    self.offsetX--;
    if (self.offsetX <= -(self.textRect.size.width + spase)) {
        //当第一个划出去把offset设置为第二个位置
        //When the first is crossed out, the offset is set to the second position
        self.offsetX += self.textRect.size.width + spase;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

//停止滚动效果
//Stop scrolling effect
- (void)stopAnimate {
    [self.timer invalidate];
    self.timer = nil;
    _scrollType = LDXManualScroll;
    self.offsetX = 0;
    //设置偏移量重新绘制
    //Set an offset to redraw
    [self setNeedsDisplay];
}
//开始滚动效果
// start scroll
- (void)startAnimate {
    if (self.timer) {
        [self.timer fire];
    } else {
        self.timer = nil;
        _scrollType = LDXAutoScroll;
        self.timer = [NvWeakTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(scrollText)
                                                        userInfo:nil
                                                         repeats:YES
                                                   dispatchQueue:dispatch_get_global_queue(0, 0)];
        //        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer fire];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //每次设置文本将偏移量初始化重新开始滚动吧
    //每次设置文本将偏移量初始化重新开始滚动吧
    //Initialize the offset each time you set the text and start scrolling again
    if (self.scrollDirection == LDXFromLeft) {
        self.offsetX = 0;
    } else {
        self.offsetX = self.frame.size.width;
    }

    //计算文本的rect
    //Computes the text's rect
    self.textRect = [self.text boundingRectWithSize:CGSizeMake(1000, self.frame.size.height)
                                            options:NSStringDrawingUsesFontLeading
                                         attributes:self.attributesDict
                                            context:[[NSStringDrawingContext alloc] init]];

    isScroll = (self.textRect.size.width > self.frame.size.width);
    //为了显示的连贯性，最少显示两遍文字
    //For consistency, display the text at least twice
    num = self.frame.size.width / (self.textRect.size.width + spase) + 2;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    CGFloat textX = 0;
    if (rect.size.width > self.textRect.size.width) {
        textX = (rect.size.width - self.textRect.size.width) * 0.5;
    }
    CGFloat textY = (rect.size.height - self.textRect.size.height) * 0.5 + rect.origin.y;
    // Drawing code
    //如果是手动滚动类型则不滚动直接绘制文字长度过长则...
    if (self.scrollType == LDXManualScroll) {
        //文本超出控件则加上...
        //If the text is outside the control, add...
        if (isScroll) {
            [super drawRect:rect];
        } else {
            //不超出直接绘制
            //No more than direct drawing
            [self.text drawAtPoint:CGPointMake(textX, textY) withAttributes:self.attributesDict];
        }
    } else {
        
        //自动滚动类型则开始绘制滚动文本
        //如果需要滚动则绘制滚动文字
        // Auto scroll starts drawing scrolling text
        // Draw scroll text if scrolling is required
        if (isScroll) {
            for (int i = 0; i < num; i++) {
                [self.text drawAtPoint:CGPointMake(self.offsetX + i * (self.textRect.size.width + spase), textY)
                        withAttributes:self.attributesDict];
            }
        } else {
            //如果不需要滚动则直接绘制文本
            //Draw text directly if no scrolling is required
            [self.text drawAtPoint:CGPointMake(textX, textY) withAttributes:self.attributesDict];
        }
    }
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

@end
