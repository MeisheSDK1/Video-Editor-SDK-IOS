//
//  NvSwitchView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/25.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvSwitchView.h"
#import "UIColor+NvColor.h"

@interface NvSwitchView ()

@property (nonatomic, assign) BOOL stateType;

@end

@implementation NvSwitchView

- (instancetype)initWithFrame:(CGRect)frame withType:(NSInteger)type withState:(BOOL)state{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = UIColorWithRGBA(216, 216, 216);
        self.layer.masksToBounds = YES;
        if (type == 1) {
            self.layer.cornerRadius = frame.size.width / 5;
        }else{
            self.layer.cornerRadius = frame.size.height / 2;
        }
        self.layer.borderWidth = 0;
        self.layer.borderColor = UIColorWithRGBA(84, 89, 95).CGColor;
        self.stateType = state;
        [self addSubviews:frame withType:type];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = UIColorWithRGBA(216, 216, 216);
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4;
        self.layer.borderWidth = 1;
        self.layer.borderColor = UIColorWithRGBA(84, 89, 95).CGColor;
        [self addSubviews:frame withType:0];
    }
    return self;
}

- (void)addSubviews:(CGRect )rect withType:(NSInteger)type{
    if (type == 1) {
        UILabel *onLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 2, (62 * SCREENSCALE - 10 * SCREENSCALE)/2, 27 * SCREENSCALE - 4)];
        onLabel.text = @"ON";
        onLabel.textColor = UIColor.whiteColor;
        onLabel.font = [UIFont systemFontOfSize:11 * SCREENSCALE];
        [self addSubview:onLabel];
        
        UILabel *offLabel = [[UILabel alloc]initWithFrame:CGRectMake(10 * SCREENSCALE + (62 * SCREENSCALE - 10)/2, 2, (54 * SCREENSCALE - 10 * SCREENSCALE)/2, 27 * SCREENSCALE - 4)];
        offLabel.text = @"OFF";
        offLabel.textColor = UIColor.whiteColor;
        offLabel.font = [UIFont systemFontOfSize:11 * SCREENSCALE];
        [self addSubview:offLabel];
        
        if (self.stateType) {
            self.sliderView = [[UIView alloc]initWithFrame:CGRectMake(2 + (62 * SCREENSCALE - 4)/2, 2,(62 * SCREENSCALE - 4)/2, 27 * SCREENSCALE - 4)];
            self.sliderView.backgroundColor = UIColorWithRGBA(61, 138, 233);
        }else{
            self.sliderView = [[UIView alloc]initWithFrame:CGRectMake(2, 2, (62 * SCREENSCALE - 4 * SCREENSCALE)/2, 27 * SCREENSCALE - 4)];
            self.sliderView.backgroundColor =UIColorWithRGBA(163, 163, 163);
        }
        
        self.sliderView.tag = 2000;
        self.sliderView.layer.masksToBounds = YES;
        self.sliderView.layer.cornerRadius = (62 * SCREENSCALE - 4 * SCREENSCALE)/5;
        self.sliderView.userInteractionEnabled = NO;
        [self addSubview:_sliderView];
    }else if (type == 2){
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4E5253"];
        self.sliderView = [[UIView alloc]initWithFrame:CGRectMake(2, 2, rect.size.height - 4, rect.size.height - 4)];
        self.sliderView.tag = 2000;
        self.sliderView.layer.masksToBounds = YES;
        self.sliderView.layer.cornerRadius = (rect.size.height - 4)/2;
        self.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#DBDCDC"];
        self.sliderView.userInteractionEnabled = NO;
        [self addSubview:_sliderView];
    }else{
        self.sliderView = [[UIView alloc]initWithFrame:CGRectMake(2, 2, (54 * SCREENSCALE - 4)/2, 21 * SCREENSCALE - 4)];
        self.sliderView.tag = 2000;
        self.sliderView.layer.masksToBounds = YES;
        self.sliderView.layer.cornerRadius = 5;
        self.sliderView.backgroundColor = UIColorWithRGBA(84, 89, 95);
        self.sliderView.userInteractionEnabled = NO;
        [self addSubview:_sliderView];
    }
}

- (void)switchSelected:(BOOL)selected{
    if (selected) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        self.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#D9E8FB"];
        [UIView animateWithDuration:0.1 animations:^{
            self.sliderView.frame = CGRectMake(2 + (62 * SCREENSCALE - 4)/2, 2,(62 * SCREENSCALE - 4)/2, 27 * SCREENSCALE - 4);
        }];
    }else{
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4E5253"];
        self.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#DBDCDC"];
        [UIView animateWithDuration:0.1 animations:^{
            self.sliderView.frame = CGRectMake(2, 2, (62 * SCREENSCALE - 4)/2, 27 * SCREENSCALE - 4);
        }];
    }
}

@end
