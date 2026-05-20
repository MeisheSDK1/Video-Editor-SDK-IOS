//
//  NvAlbumCircleView.m
//  HWProgress
//
//  Created by sxmaps_w on 2017/3/3.
//  Copyright © 2017年 hero_wqb. All rights reserved.
//

#import "NvAlbumCircleView.h"

@interface NvAlbumCircleView () {
    float circleLineWidth;
    UIFont *circleFont;
    UIColor *circleColor;
}

@property (nonatomic, weak) UILabel *cLabel;

@end

@implementation NvAlbumCircleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        circleLineWidth = 2.0f;
        circleFont = [UIFont boldSystemFontOfSize:15.0f];
        circleColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
        UILabel *cLabel = [[UILabel alloc] initWithFrame:self.bounds];
        cLabel.font = circleFont;
        cLabel.textColor = circleColor;
        cLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:cLabel];
        self.cLabel = cLabel;
    }
    
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    _cLabel.text = [NSString stringWithFormat:@"%d%%", (int)floor(progress * 100)];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = circleLineWidth;
    [circleColor set];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    CGFloat radius = (MIN(rect.size.width, rect.size.height) - circleLineWidth) * 0.5;
    [path addArcWithCenter:(CGPoint){rect.size.width * 0.5, rect.size.height * 0.5} radius:radius startAngle:M_PI * 1.5 endAngle:M_PI * 1.5 + M_PI * 2 * _progress clockwise:YES];
    [path stroke];
}

@end

