//
//  NvCustomButton.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/12.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCustomButton.h"
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvBaseCommon/UIView+Dimension.h>

@interface NvCustomButton()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation NvCustomButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        [self addSubview:self.imgView];
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(-5*SCREENSCALE, frame.size.width + 5*SCREENSCALE, frame.size.width + 10*SCREENSCALE, 21*SCREENSCALE)];
        self.nameLabel.font = [UIFont fontWithName:@"PingFangSC" size:12];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imgView.image = _image;
}

- (void)setName:(NSString *)name {
    _name = name;
    self.nameLabel.text = name;
}

- (void)setFontSize:(float)fontSize {
    _fontSize = fontSize;
    self.nameLabel.font = [UIFont systemFontOfSize:12];
}

- (void)setVerticalSpace:(float)verticalSpace {
    _verticalSpace = verticalSpace;
    if (verticalSpace == 0) {
        self.nameLabel.top = self.imgView.bottom - 3*SCREENSCALE;
    } else {
        self.nameLabel.top = self.imgView.bottom + verticalSpace;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
