//
//  NvTimelineImageView.m
//  SDKDemo
//
//  Created by MS on 2019/6/19.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvTimelineImageView.h"

@implementation NvTimelineImageView

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
