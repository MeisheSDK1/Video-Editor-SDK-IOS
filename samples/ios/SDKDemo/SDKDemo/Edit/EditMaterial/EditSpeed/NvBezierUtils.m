//
//  NvBezierUtils.m
//  SDKDemo
//
//  Created by MS on 2020/11/25.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvBezierUtils.h"

@implementation NvBezierUtils

+ (NSMutableArray *)fetchDefaultCurvePoints:(NSString *)curveId duration:(int64_t)duration {
    NSMutableArray *curvePoints = [NSMutableArray array];
    if ([curveId isEqualToString:@"Custom"]) {
        CGFloat pointX = (CGFloat)duration/4;
        curvePoints =  [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 1)],[NSValue valueWithCGPoint:CGPointMake(pointX, 1)],[NSValue valueWithCGPoint:CGPointMake(pointX*2, 1)],[NSValue valueWithCGPoint:CGPointMake(pointX*3, 1)],[NSValue valueWithCGPoint:CGPointMake(pointX*4, 1)], nil];
    }else if ([curveId isEqualToString:@"Montage"]) {
        curvePoints =  [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 0.9)],[NSValue valueWithCGPoint:CGPointMake(duration*0.1, 0.9)],[NSValue valueWithCGPoint:CGPointMake(duration*0.5, 7)],[NSValue valueWithCGPoint:CGPointMake(duration*0.7, 0.4)],[NSValue valueWithCGPoint:CGPointMake(duration*0.8, 1)],[NSValue valueWithCGPoint:CGPointMake(duration, 1)], nil];
    }else if ([curveId isEqualToString:@"Hero"]) {
        curvePoints =  [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 1)],[NSValue valueWithCGPoint:CGPointMake(duration*0.05, 1)],[NSValue valueWithCGPoint:CGPointMake(duration*0.35, 5.5)],[NSValue valueWithCGPoint:CGPointMake(duration*0.45, 0.5)],[NSValue valueWithCGPoint:CGPointMake(duration*0.55, 0.5)],[NSValue valueWithCGPoint:CGPointMake(duration*0.65, 5.5)],[NSValue valueWithCGPoint:CGPointMake(duration*0.95, 1)],[NSValue valueWithCGPoint:CGPointMake(duration, 1)], nil];
    }else if ([curveId isEqualToString:@"Bullet"]) {
        curvePoints =  [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 5.3)],[NSValue valueWithCGPoint:CGPointMake(duration*0.4, 5.3)],[NSValue valueWithCGPoint:CGPointMake(duration*0.45, 0.5)],[NSValue valueWithCGPoint:CGPointMake(duration*0.55, 0.5)],[NSValue valueWithCGPoint:CGPointMake(duration*0.6, 5.3)],[NSValue valueWithCGPoint:CGPointMake(duration, 5.3)], nil];
    }else if ([curveId isEqualToString:@"Jump"]) {
        curvePoints =  [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 0.63)],[NSValue valueWithCGPoint:CGPointMake(duration*0.45, 0.63)],[NSValue valueWithCGPoint:CGPointMake(duration*0.5, 5.9)],[NSValue valueWithCGPoint:CGPointMake(duration*0.55, 0.63)],[NSValue valueWithCGPoint:CGPointMake(duration, 0.63)], nil];
    }else if ([curveId isEqualToString:@"FlashIn"]) {
        curvePoints =  [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 5.2)],[NSValue valueWithCGPoint:CGPointMake(duration*0.4, 5.2)],[NSValue valueWithCGPoint:CGPointMake(duration*0.6, 1)],[NSValue valueWithCGPoint:CGPointMake(duration, 1)], nil];
    }else if ([curveId isEqualToString:@"FlashOut"]) {
        curvePoints =  [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 1)],[NSValue valueWithCGPoint:CGPointMake(duration*0.4, 1)],[NSValue valueWithCGPoint:CGPointMake(duration*0.6, 5.2)],[NSValue valueWithCGPoint:CGPointMake(duration, 5.2)], nil];
    }
    return curvePoints;
}

+ (NSMutableArray *)convertToCurvePoints:(NSArray *)pointArr {
    NSMutableArray *curvePoints = [NSMutableArray array];
    if (pointArr.count >1) {
        for (int i=0; i<pointArr.count; i++) {
            CGPoint point = [pointArr[i] CGPointValue];
            CGFloat speed = point.y;
            CGPoint curPoint = CGPointMake(point.x, speed);
            CGPoint prePoint = CGPointMake(0, speed);
            CGPoint nexPoint = CGPointMake(0, speed);
            if (i==pointArr.count -1) {
                CGPoint previousPoint = [pointArr[i-1] CGPointValue];
                CGFloat delta = (curPoint.x - previousPoint.x) * (1/3.0);
                prePoint.x = curPoint.x - delta;
                nexPoint.x = curPoint.x + delta;
            }else if (i==0){
                CGPoint nextPoint = [pointArr[i+1] CGPointValue];
                CGFloat delta = (nextPoint.x - curPoint.x) * (1/3.0);
                prePoint.x = -delta;
                nexPoint.x =  delta;
            }else{
                CGPoint previousPoint = [pointArr[i-1] CGPointValue];
                CGPoint nextPoint = [pointArr[i+1] CGPointValue];
                prePoint.x = curPoint.x - (curPoint.x - previousPoint.x) * (1/3.0);
                nexPoint.x = curPoint.x + (nextPoint.x - curPoint.x) * (1/3.0);
            }
            [curvePoints addObject:[NSValue valueWithCGPoint:curPoint]];
            [curvePoints addObject:[NSValue valueWithCGPoint:prePoint]];
            [curvePoints addObject:[NSValue valueWithCGPoint:nexPoint]];
        }
    }
    return curvePoints;
}

+ (CGFloat)calculateBezierPointY:(CGFloat)chartX startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint controlP1:(CGPoint)p1 controlP2:(CGPoint)p2 {
    CGFloat t = 0.5;
    for (int i=0; i<1000; i++) {
        CGFloat deltaX1 = [self bezierPointXFunc:t target:chartX startPoint:startPoint endPoint:endPoint controlP1:p1 controlP2:p2];
        CGFloat deltaX2 = [self bezierDeltaFunc:t target:chartX startPoint:startPoint endPoint:endPoint controlP1:p1 controlP2:p2];
        t -= deltaX1/deltaX2;
        if (deltaX1 == 0) {
            break;
        }
    }
    CGFloat chartY = [self bezierPointYFunc:t startPoint:startPoint endPoint:endPoint controlP1:p1 controlP2:p2];
    return chartY;
}

+ (CGFloat)bezierPointYFunc:(CGFloat)t startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint controlP1:(CGPoint)p1 controlP2:(CGPoint)p2 {
    CGFloat calcY = startPoint.y * pow(1-t, 3) + 3 * p1.y * t * pow(1-t, 2) + 3 * p2.y * (1-t) * pow(t, 2) + endPoint.y * pow(t, 3);
    return calcY;
}

+ (CGFloat)bezierPointXFunc:(CGFloat)t target:(CGFloat)target startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint controlP1:(CGPoint)p1 controlP2:(CGPoint)p2 {
    CGFloat calcX = startPoint.x * pow(1-t, 3) + 3 * p1.x * t * pow(1-t, 2) + 3 * p2.x * (1-t) * pow(t, 2) + endPoint.x * pow(t, 3);
    return calcX - target;
}

+ (CGFloat)bezierDeltaFunc:(CGFloat)t target:(CGFloat)target startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint controlP1:(CGPoint)p1 controlP2:(CGPoint)p2 {
    CGFloat dt = 0.00000001;
    CGFloat delta1 = [self bezierPointXFunc:t target:target startPoint:startPoint endPoint:endPoint controlP1:p1 controlP2:p2];
    CGFloat delta2 = [self bezierPointXFunc:t-dt target:target startPoint:startPoint endPoint:endPoint controlP1:p1 controlP2:p2];
    return (delta1 - delta2)/dt;
}

+ (NSString *)bezierPointsConvertToString:(NSArray *)points {
    NSMutableString *str = [NSMutableString string];
    for (int i=0; i<points.count; i++) {
        CGPoint point = [points[i] CGPointValue];
        [str appendFormat:@"(%.10f,%.10f)",point.x,point.y];
    }
    return str;
}
@end
