//
//  UIView+Dimension.h
//  JLDoubleSliderDemo
//
//  Created by 刘东旭 on 2018/3/21.
//  Copyright © 2018年 meicam.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Dimension)

@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat centerY;
@property (nonatomic) CGFloat centerX;
- (void)changeTopByAdding:(NSNumber *)number;

@end
