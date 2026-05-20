//
//  NvButton.m
//  wangyi
//
//  Created by dx on 2018/3/28.
//  Copyright © 2018年 meicam.com. All rights reserved.
//

#import "NvButton.h"

@implementation NvButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.expandCofficient = .8;
    return self;
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -self.expandCofficient*bounds.size.width, -self.expandCofficient*bounds.size.height);
    return CGRectContainsPoint(bounds, point);
}

@end
