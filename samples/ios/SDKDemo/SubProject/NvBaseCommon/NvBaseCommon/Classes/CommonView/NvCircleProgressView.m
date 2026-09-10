//
//  NvCircleProgressView.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/12/20.
//  Copyright © 2018 meishe. All rights reserved.
//

#import "NvCircleProgressView.h"
#import "NVDefineConfig.h"
#import <Masonry/Masonry.h>
#import "UIColor+NvColor.h"

@interface NvCircleProgressView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation NvCircleProgressView {
    CGFloat startAngle;
    CGFloat endAngle;
    UIImageView *image;
    NvViewType viewType;
}

- (instancetype)initWithFrame:(CGRect)frame type:(NvViewType)type{
    self = [super initWithFrame:frame];
    
    startAngle = -M_PI_2;
    endAngle = -M_PI_2 + 2*M_PI;
    self.backgroundColor = [UIColor clearColor];
    self.progress = 0;
    viewType = type;
    
    UIView *view = UIView.new;
    view.backgroundColor = [UIColor nv_colorWithHexString:@"#FC3E3E"];
    view.layer.cornerRadius = 26*SCREENSCALE;
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(52*SCREENSCALE));
        make.height.equalTo(@(52*SCREENSCALE));
        make.center.equalTo(self);
    }];
    
    image = [UIImageView new];
    NSString *imageName = viewType == kViewBoomrange ? @"NvBoomerang" : @"nv_superzoom";
    [image setImage:NvImageNamedForBundle(imageName, NvCurrentBundle)];
    [view addSubview:image];
    if (viewType == kViewBoomrange) {
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(36*SCREENSCALE));
            make.height.equalTo(@(14*SCREENSCALE));
            make.center.equalTo(view);
        }];
    } else {
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(25*SCREENSCALE));
            make.height.equalTo(@(25*SCREENSCALE));
            make.center.equalTo(view);
        }];
    }
    
    return self;
}

- (void)setProgress:(int)progress{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = 5;
    [[UIColor colorWithRed:252/255.0 green:62/255.0 blue:62/255.0 alpha:0.5] set];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    [path addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:rect.size.width/2-3*SCREENSCALE startAngle:M_PI * 1.5 endAngle:M_PI * 1.5 + M_PI * 2 * _progress/100.0 clockwise:YES];
    [path stroke];
}

@end
