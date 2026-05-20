//
//  NvDownloadButton.m
//  SDKDemo
//
//  Created by 刘东旭 on 2019/1/3.
//  Copyright © 2019年 meishe. All rights reserved.
//

#import "NvDownloadButton.h"
#import <Masonry/Masonry.h>
#import <NvBaseUtils.h>

#define DownloadViewMargin 0
#define DownloadColor [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]

@interface NvDownloadButton ()

@property (nonatomic, strong) UIImageView *imageView;

@end


@implementation NvDownloadButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:86.0/255 green:140.0/255 blue:225.0/255 alpha:1];
        self.imageView = [UIImageView new];
        self.imageView.image = [NvBaseUtils imageNamed:@"NvNodownloadButton"];
        [self addSubview:self.imageView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }
    
    return self;
}

- (void)setStatus:(NvDownloadStatus)status {
    _status = status;
    if (_status == NvDownloading) {
        self.imageView.hidden = YES;
    } else {
        self.imageView.hidden = NO;
    }
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.status == NvNoDownload) {
        [super drawRect:rect];
    } else if (self.status == NvDownloading) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat xCenter = rect.size.width * 0.5;
        CGFloat yCenter = rect.size.height * 0.5;
        CGFloat radius = MIN(rect.size.width, rect.size.height) * 0.5 - DownloadViewMargin;
        [DownloadColor set];
        CGContextSetLineWidth(context, 1);
        CGContextMoveToPoint(context, xCenter, yCenter);
        CGContextAddLineToPoint(context, xCenter, 0);
        CGFloat endAngle = - M_PI * 0.5 + _progress * M_PI * 2 + 0.001;
        CGContextAddArc(context, xCenter, yCenter, radius, - M_PI * 0.5, endAngle, 1);
        CGContextFillPath(context);
    } else if (self.status == NvFinish){
        
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
