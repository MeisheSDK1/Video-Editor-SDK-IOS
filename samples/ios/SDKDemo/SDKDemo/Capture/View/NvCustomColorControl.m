//
//  NvCustomColorControl.m
//  SDKDemo
//
//  Created by MS on 2020/7/20.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvCustomColorControl.h"
#import "NVHeader.h"

@interface NvCustomColorControl ()
{
    CAGradientLayer *gradientLayer;
}
@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSArray *colorLocationArray;
@property (assign, nonatomic) BOOL canMove;

@end

@implementation NvCustomColorControl

- (instancetype)initWithFrame:(CGRect)frame withColors:(NSArray *)colors {
    self = [super initWithFrame:frame];
    if (self) {
        gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height/2);
        self.colorArray = colors;
        [gradientLayer setColors:self.colorArray];
        [gradientLayer setStartPoint:CGPointMake(0, 0)];
        [gradientLayer setEndPoint:CGPointMake(1, 0)];
        gradientLayer.cornerRadius = 10*SCREENSCALE;
        gradientLayer.type = kCAGradientLayerAxial;
        [self.layer addSublayer:gradientLayer];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)cancelSetCornerRadius {
    gradientLayer.cornerRadius = 0;
}

- (void)setIndicatorHeight:(CGFloat)height {
    CGRect frame = self.imageView.frame;
    CGFloat width = frame.size.width;
    CGFloat y = self.frame.size.height / 2;
    CGFloat centerX = self.imageView.center.x;
    self.imageView.frame = CGRectMake(frame.origin.x, y, width, height);
    self.imageView.center = CGPointMake(centerX, self.imageView.centerY);
    [self setNeedsLayout];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
   
    CGPoint p = [self convertPoint:point toView:self.imageView];
    CGPoint origin = self.imageView.bounds.origin;
    CGSize size = self.imageView.bounds.size;
    CGRect enlargeRect = CGRectMake(origin.x-20, origin.y-20, size.width+40, size.height+40);
    if (CGRectContainsPoint(enlargeRect, p)) {
       _canMove = YES;
    } else {
       _canMove = NO;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    self.endChange = NO;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (_canMove) {
        if (point.x<=0) {
            self.imageView.center = CGPointMake(5, self.imageView.center.y);
            if ([self.delegate respondsToSelector:@selector(colorControl:R:G:B:alpha:point:)]) {
                NSArray *colorArray = [self colorOfPoint:CGPointMake(0, self.imageView.center.y)];
                [self.delegate colorControl:self R:[colorArray[0] floatValue] G:[colorArray[1] floatValue] B:[colorArray[2] floatValue] alpha:1 point:point];
            }
            return;
        }
        CGFloat maxLen = self.isVertical ? self.frame.size.height : self.frame.size.width;
        if (point.x>=maxLen-5) {
            
            self.imageView.center = CGPointMake(maxLen-5, self.imageView.center.y);
            if ([self.delegate respondsToSelector:@selector(colorControl:R:G:B:alpha:point:)]) {
                NSArray *colorArray = [self colorOfPoint:CGPointMake(maxLen-2, self.imageView.center.y)];
                [self.delegate colorControl:self R:[colorArray[0] floatValue] G:[colorArray[1] floatValue] B:[colorArray[2] floatValue] alpha:1 point:point];
            }
            
            return;
        }else{
            self.imageView.center = CGPointMake(point.x, self.imageView.center.y);
            if ([self.delegate respondsToSelector:@selector(colorControl:R:G:B:alpha:point:)]) {
                NSArray *colorArray = [self colorOfPoint:CGPointMake(point.x, self.imageView.center.y)];
                [self.delegate colorControl:self R:[colorArray[0] floatValue] G:[colorArray[1] floatValue] B:[colorArray[2] floatValue] alpha:1 point:point];
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.endChange = YES;
//    if ([self.delegate respondsToSelector:@selector(colorControl:R:G:B:alpha:point:)]) {
//        [self.delegate colorControl:self R:0 G:0 B:0 alpha:0 point:CGPointZero];
//    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL result = [super pointInside:point withEvent:event];
    CGFloat minX = CGRectGetMinX(self.bounds) - 20;
    CGFloat maxX = CGRectGetMaxX(self.bounds) + 20;
    CGFloat minY = CGRectGetMinY(self.bounds);
    CGFloat maxY = CGRectGetMaxY(self.bounds) + self.imageView.frame.size.height - self.imageView.frame.origin.y + 20;
    if (point.y > minY && point.y < maxY && point.x > minX && point.x < maxX) {
        return YES;
    }
    return result;
}

#pragma mark - 避免拖动值超出边界
/*
 避免拖动值超出边界
 Avoid dragging values out of bounds
 
 @param a 传入的边界值
 Incoming boundary value
 */
- (double)check:(double)a {
    return  a > 1 ? 1 : a < 0 ? 0 : a;
}

#pragma mark - 根据点击的位置返回一组颜色数组
/*
 根据点击的位置返回一组颜色数组
 Return a set of color arrays according to the clicked position
 
 @param point 点击的位置
 Where to click
 */
- (NSArray *)colorOfPoint:(CGPoint)point {
    int r,g,b;
    int n = 1530 * [self check: point.x / self.frame.size.width];
    if (self.isVertical) {
        n = 1530 * [self check: point.x / self.frame.size.height];
    }
    switch (n/255) {
        case 0: r = 255; g = 0; b = n; break;
        case 1: r = 255 - (n % 255); g = 0; b = 255; break;
        case 2: r = 0; g = n % 255; b = 255; break;
        case 3: r = 0; g = 255; b = 255 - (n % 255); break;
        case 4: r = n % 255; g = 255; b = 0; break;
        case 5: r = 255; g = 255 - (n % 255); b = 0; break;
        default: r = 255; g = 0; b = 0; break;
    }
    NSArray *array = @[@(r),@(g),@(b),@1];
    return array;
}

- (void)setDefaultMode {
    self.imageView.center = CGPointMake(self.frame.size.width-20, self.imageView.center.y);
}

//MARK: - getter & setter
- (void)setEndPoint:(CGPoint)endPoint {
    _endPoint = endPoint;
    if (endPoint.x<=0) {
        endPoint.x = 5;
    }
    CGFloat maxLen = self.isVertical ? self.frame.size.height : self.frame.size.width;
    if (endPoint.x>=maxLen-5) {
        endPoint.x = maxLen-5;
    }
    self.imageView.center = CGPointMake(endPoint.x, self.imageView.center.y);
    if ([self.delegate respondsToSelector:@selector(colorControl:R:G:B:alpha:point:)]) {
        CGPoint finalPoint = CGPointMake(endPoint.x, endPoint.y);
        if (finalPoint.x>=maxLen-5) {
            finalPoint.x = maxLen-2;
        }
        NSArray *colorArray = [self colorOfPoint:CGPointMake(endPoint.x, self.imageView.center.y)];
        [self.delegate colorControl:self R:[colorArray[0] floatValue] G:[colorArray[1] floatValue] B:[colorArray[2] floatValue] alpha:1 point:finalPoint];
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2, 20, self.frame.size.height/2)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = [UIImage imageNamed:@"Nv_customColor_indicator"];
    }
    return _imageView;
}

@end

