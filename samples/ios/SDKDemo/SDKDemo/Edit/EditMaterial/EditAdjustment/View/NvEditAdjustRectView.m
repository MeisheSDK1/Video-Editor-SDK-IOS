//
//  NvEditAdjustRectView.m
//  SDKDemo
//
//  Created by MS on 2020/12/3.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditAdjustRectView.h"
#import "NVHeader.h"

@interface NvEditAdjustRectView ()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@end

@implementation NvEditAdjustRectView

- (instancetype)init {
    if (self = [super init]) {

    }
    return self;
}

- (void)addSubviews {
    
}

#pragma mark - ShapeLayer
- (void)drawChartsWithPoints:(NSArray *)points scale:(double)scale {
    scale = 1.0;
    [self.shapeLayer removeFromSuperlayer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i=0; i<points.count; i++) {
        CGPoint point = [points[i] CGPointValue];
        if (i==0) {
            [path moveToPoint:point];
        }else{
            [path addLineToPoint:point];
        }
    }
    [path closePath];
    
    ///添加垂直分割线
    ///Add a vertical divider
    [self addVerticalSepLines:points lineNumber:2 path:path];
    ///添加水平分割线
    ///Add a horizontal divider
    [self addHorizontalSepLines:points lineNumber:2 path:path];
    self.shapeLayer.lineWidth = 1.0/scale;
    self.shapeLayer.path = path.CGPath;
    [self.layer addSublayer:self.shapeLayer];
}

- (void)addVerticalSepLines:(NSArray *)points lineNumber:(NSInteger)lineNumber path:(UIBezierPath *)path {
    if (points.count < 4) {
        return;
    }
    NSInteger sepCount = lineNumber + 1;
    CGPoint leftTopPoint = [points[0] CGPointValue];
    CGPoint rightBottomPoint = [points[2] CGPointValue];
    CGFloat top = leftTopPoint.y;
    CGFloat left = leftTopPoint.x;
    CGFloat bottom = rightBottomPoint.y;
    CGFloat right = rightBottomPoint.x;
    
    CGFloat xSep = (right - left)/sepCount;
    for (int i=1; i<=lineNumber; i++) {
        CGFloat xValue = left + xSep*i;
        CGPoint upperPoint = CGPointMake(xValue, top);
        CGPoint bottomPoint = CGPointMake(xValue, bottom);
        [path moveToPoint:upperPoint];
        [path addLineToPoint:bottomPoint];
    }
}

- (void)addHorizontalSepLines:(NSArray *)points lineNumber:(NSInteger)lineNumber path:(UIBezierPath *)path {
    if (points.count < 4) {
        return;
    }
    NSInteger sepCount = lineNumber + 1;
    CGPoint leftTopPoint = [points[0] CGPointValue];
    CGPoint rightBottomPoint = [points[2] CGPointValue];
    CGFloat top = leftTopPoint.y;
    CGFloat left = leftTopPoint.x;
    CGFloat bottom = rightBottomPoint.y;
    CGFloat right = rightBottomPoint.x;
    
    CGFloat ySep = (bottom - top)/sepCount;
    for (int i=1; i<=lineNumber; i++) {
        CGFloat yValue = top + ySep*i;
        CGPoint leftPoint = CGPointMake(left, yValue);
        CGPoint rightPoint = CGPointMake(right, yValue);
        [path moveToPoint:leftPoint];
        [path addLineToPoint:rightPoint];
    }
}

- (void)setLineScale:(double)scale {
    scale = 1.0;
    CGPathRef path = self.shapeLayer.path;
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer.lineWidth = 1.0/scale;
    self.shapeLayer.path = path;
    [self.layer addSublayer:self.shapeLayer];
}

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.strokeColor = [UIColor nv_colorWithHexString:@"#00FFFF"].CGColor;
    }
    return _shapeLayer;
}

@end
