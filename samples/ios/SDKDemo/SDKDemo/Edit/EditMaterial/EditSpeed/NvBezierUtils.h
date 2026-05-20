//
//  NvBezierUtils.h
//  SDKDemo
//
//  Created by MS on 2020/11/25.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface NvBezierUtils : NSObject

+ (NSMutableArray *)fetchDefaultCurvePoints:(NSString *)curveId duration:(int64_t)duration;

///通过视图坐标x 获取贝塞尔曲线对应Y值
///Obtain the corresponding Y value of Bessel curve by view coordinate x
+ (CGFloat)calculateBezierPointY:(CGFloat)chartX startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint controlP1:(CGPoint)p1 controlP2:(CGPoint)p2;

+ (NSString *)bezierPointsConvertToString:(NSArray *)points;

+ (NSMutableArray *)convertToCurvePoints:(NSArray *)pointArr;

@end

NS_ASSUME_NONNULL_END
