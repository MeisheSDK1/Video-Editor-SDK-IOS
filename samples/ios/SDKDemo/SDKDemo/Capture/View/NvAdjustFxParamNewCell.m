//
//  NvAdjustFxParamNewCell.m
//  SDKDemo
//
//  Created by ms20221114 on 2023/2/28.
//  Copyright © 2023 meishe. All rights reserved.
//

#import "NvAdjustFxParamNewCell.h"

@implementation NvAdjustFxParamNewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.nameLabel removeFromSuperview];
        [self.slider removeFromSuperview];
        [self.colorSlider removeFromSuperview];
        
        CGRect sliderFrame = CGRectMake(SCREENWIDTH - 230*SCREENSCALE - 47*SCREENSCALE, 0, 230*SCREENSCALE, self.bounds.size.height);
        self.slider = [[BLItemSlider alloc] initWithFrame:sliderFrame];
        self.slider.delegate = self;
        self.slider.maximumTrackTintColor = [UIColor whiteColor];
        self.slider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
        self.slider.thumbTintColor = [UIColor whiteColor];
        self.slider.thumbSeletedTintColor = [UIColor whiteColor];
        self.slider.showTwoSidesLimitedValue = YES;
        self.slider.valueLabel.hidden = YES;
        [self addSubview:self.slider];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:11*SCREENSCALE];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.nameLabel];
        if (![NvUtils currentLanguagesIsChinese]) {
            [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(40*SCREENSCALE);
                make.centerY.equalTo(self.slider.mas_centerY);
            }];
        }else{
            [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(30*SCREENSCALE);
                make.centerY.equalTo(self.slider.mas_centerY);
            }];
        }
        

        /*
         颜色slider
         color slider
         */
        CGRect colorSliderFrame = CGRectMake(110*SCREENSCALE, self.bounds.size.height*2/5, SCREENWIDTH - 155*SCREENSCALE, self.bounds.size.height/5);
        self.colorSlider = [[NvCustomColorControl alloc] initWithFrame:colorSliderFrame withColors:@[(id)UIColor.redColor.CGColor,(id)UIColor.magentaColor.CGColor,(id)UIColor.blueColor.CGColor,(id)UIColor.cyanColor.CGColor,(id)UIColor.greenColor.CGColor,(id)UIColor.yellowColor.CGColor,(id)UIColor.redColor.CGColor]];
        self.colorSlider.delegate = self;
        [self.colorSlider cancelSetCornerRadius];
        [self.colorSlider setIndicatorHeight:20*SCREENSCALE];
        [self addSubview:self.colorSlider];
    }
    return self;
}

- (void)resetNameLabelText:(NSString *)displayName value:(double)value {
    self.nameLabel.text = displayName;
}

-(void)itemSlider:(BLItemSlider*)slider valueChanged:(float)value {
    self.changeColor = NO;
    [super itemSlider:slider valueChanged:value];
}

- (void)itemSliderTouchEnd:(BLItemSlider *)slider {
    self.changeColor = NO;
    [super itemSliderTouchEnd:slider];
}

- (void)colorControl:(NvCustomColorControl *)colorView R:(CGFloat)r G:(CGFloat)g B:(CGFloat)b alpha:(CGFloat)alpha point:(CGPoint)point {
    self.changeColor = YES;
    if (colorView.endChange){
        if ([self.delegate respondsToSelector:@selector(nvAdjustFxParamCell:endChange:)]) {
            [self.delegate nvAdjustFxParamCell:self endChange:self.model];
        }
    }else{
        NSString *displayName = [NvUtils currentLanguagesIsChinese] ? self.model.translationName : self.model.name;
        NvsColor color;
        color.r = r/255.0;
        color.g = g/255.0;
        color.b = b/255.0;
        color.a = alpha;
        self.colorStr = [NvUtils colorStringInRGBAModeWithRGB:color];
        self.nameLabel.text = displayName;
        self.model.r = color.r;
        self.model.g = color.g;
        self.model.b = color.b;
        self.model.a = color.a;
        
        if([self.delegate respondsToSelector:@selector(nvAdjustFxParamCell:valueChanged:)]){
            [self.delegate nvAdjustFxParamCell:self valueChanged:self.model];
        }
    }
}

@end
