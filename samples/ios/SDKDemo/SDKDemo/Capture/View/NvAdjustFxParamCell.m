//
//  NvAdjustFxParamCell.m
//  SDKDemo
//
//  Created by Meishe on 2022/8/17.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvAdjustFxParamCell.h"
#import "BLItemSlider.h"
#import "NvCustomColorControl.h"
@interface NvAdjustFxParamCell ()<BLItemSliderDelegate,NvCustomColorControlDelegate>

@end

@implementation NvAdjustFxParamCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*SCREENSCALE, 0, 75*SCREENSCALE, self.bounds.size.height)];
        if (![NvUtils currentLanguagesIsChinese]) {
            self.nameLabel.frame = CGRectMake(5*SCREENSCALE, 0, 85*SCREENSCALE, self.bounds.size.height);
        }
        self.nameLabel.font = [UIFont systemFontOfSize:11*SCREENSCALE];
        self.nameLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.nameLabel];
        
        CGRect sliderFrame = CGRectMake(110*SCREENSCALE, 0, SCREENWIDTH - 155*SCREENSCALE, self.bounds.size.height);
        self.slider = [[BLItemSlider alloc] initWithFrame:sliderFrame];
        self.slider.delegate = self;
        self.slider.maximumTrackTintColor = [UIColor whiteColor];
        self.slider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
        self.slider.thumbTintColor = [UIColor whiteColor];
        self.slider.thumbSeletedTintColor = [UIColor whiteColor];
        self.slider.showTwoSidesLimitedValue = YES;
        self.slider.valueLabel.hidden = YES;
        [self addSubview:self.slider];
        
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

- (void)renderCellWithModel:(NvAjustFxParamModel *)model {
    self.model = model;
    if (model.type == NvAjustFxParamCategoryColor) {
        self.slider.hidden = YES;
        self.colorSlider.hidden = NO;
        self.nameLabel.text = [NvUtils currentLanguagesIsChinese] ? self.model.translationName : self.model.name;
    }else if (model.type == NvAjustFxParamCategoryInt || model.type == NvAjustFxParamCategoryFloat) {
        self.colorSlider.hidden = YES;
        self.slider.hidden = NO;
        self.slider.minValue = model.minValue;
        self.slider.maxValue = model.maxValue;
        self.slider.value = model.currentValue;
        [self.slider adsorb:YES adsorbValue:model.defaultValue];
        [self sliderChangedValue:model.currentValue];
    }
}

- (void)resetNameLabelText:(NSString *)displayName value:(double)value {
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",displayName,self.slider.valueLabel.text];
}

- (void)sliderChangedValue:(double)value {
    NSString *displayName = [NvUtils currentLanguagesIsChinese] ? self.model.translationName : self.model.name;
    [self resetNameLabelText:displayName value:value];

}

- (void)itemSliderTouchEnd:(BLItemSlider *)slider {
    self.model.currentValue = slider.value;
    [self sliderChangedValue:slider.value];
    if ([self.delegate respondsToSelector:@selector(nvAdjustFxParamCell:endChange:)]) {
        [self.delegate nvAdjustFxParamCell:self endChange:self.model];
    }
}

-(void)itemSlider:(BLItemSlider*)slider valueChanged:(float)value {
    self.model.currentValue = value;
    [self sliderChangedValue:value];
    if([self.delegate respondsToSelector:@selector(nvAdjustFxParamCell:valueChanged:)]){
        [self.delegate nvAdjustFxParamCell:self valueChanged:self.model];
    }
}

#pragma mark NvCustomColorControlDelegate
- (void)colorControl:(NvCustomColorControl *)colorView R:(CGFloat)r G:(CGFloat)g B:(CGFloat)b alpha:(CGFloat)alpha point:(CGPoint)point {
    NSString *displayName = [NvUtils currentLanguagesIsChinese] ? self.model.translationName : self.model.name;
    NvsColor color;
    color.r = r/255.0;
    color.g = g/255.0;
    color.b = b/255.0;
    color.a = alpha;
    NSString *colorStr = [NvUtils colorStringInRGBAModeWithRGB:color];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",displayName,colorStr];
    self.model.r = color.r;
    self.model.g = color.g;
    self.model.b = color.b;
    self.model.a = color.a;
    if([self.delegate respondsToSelector:@selector(nvAdjustFxParamCell:valueChanged:)]){
        [self.delegate nvAdjustFxParamCell:self valueChanged:self.model];
    }
}
@end
