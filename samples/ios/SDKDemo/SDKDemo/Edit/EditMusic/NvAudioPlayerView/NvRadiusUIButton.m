//
//  NvRadiusUIButton.m
//  NvSellerShow
//
//  Created by Meicam on 2017/1/6.
//  Copyright © 2017年 Meicam. All rights reserved.
//

#import "NvRadiusUIButton.h"

@implementation NvRadiusUIButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.layer.masksToBounds = YES;
    
    if(self.radius != 0)
        self.layer.cornerRadius = self.radius;
    else
        self.layer.cornerRadius = rect.size.height / 2;
    
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:141.0/255.0 green:147.0/255.0 blue:157.0/255.0 alpha:1].CGColor;
}


@end
