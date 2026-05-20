//
//  NvColorCorrectMenuCell.m
//  SDKDemo
//
//  Created by ms on 2020/11/30.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvColorCorrectMenuCell.h"

@implementation NvColorCorrectMenuCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.mas_top);
            make.width.offset(45  / 2.0 * SCREENSCALE);
            make.height.offset(45 / 2.0 * SCREENSCALE);
           }];
    }
    return self;
}


@end
