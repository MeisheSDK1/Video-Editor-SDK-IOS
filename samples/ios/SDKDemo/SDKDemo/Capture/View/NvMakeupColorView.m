//
//  NvMakeupColorView.m
//  GradientColorSlider
//
//  Created by MS on 2020/3/3.
//  Copyright © 2020 MS. All rights reserved.
//

#import "NvMakeupColorView.h"
#import "NvColorSelectedControl.h"
#import "NVHeader.h"

@interface NvMakeupColorView ()<NvColorSelectedControlDelegate>
@property (nonatomic, strong) NvColorSelectedControl *colorSlider; //自定义颜色选择器 Custom color picker
@property (nonatomic, strong) NSMutableArray *buttonArrs;
@property (nonatomic, assign) CGPoint endPoint;
@end

@implementation NvMakeupColorView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.buttonArrs = [NSMutableArray array];
        [self addSubviews];
    }
    return self;
}

#pragma mark - 初始化视图
/*
 初始化视图
 Initialize view
 
 */
- (void)addSubviews {
    /*
     添加自定义颜色选择器
     Add a custom color selector
     */
    CGFloat sep = 256*SCREENSCALE/2  - 31*SCREENSCALE/2;
   self.colorSlider = [[NvColorSelectedControl alloc] initWithFrame:CGRectMake(-sep, sep, 256*SCREENSCALE, 31*SCREENSCALE) withColors:@[(id)UIColor.redColor.CGColor,(id)UIColor.magentaColor.CGColor,(id)UIColor.blueColor.CGColor,(id)UIColor.cyanColor.CGColor,(id)UIColor.greenColor.CGColor,(id)UIColor.yellowColor.CGColor,(id)UIColor.redColor.CGColor]]; 
    self.colorSlider.transform = CGAffineTransformMakeRotation(-1.57079633);
    self.colorSlider.delegate = self;
    self.colorSlider.isVertical = YES;
    [self addSubview:self.colorSlider];
    self.colorSlider.hidden = YES;
    
    /*
     添加默认颜色button 及自定义颜色选择button
     Add default color button and custom color selection button
     */
    CGFloat xValue = self.frame.size.width - 30*SCREENSCALE;
    for(int i=0;i<4;i++){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i==0) {
            [button setBackgroundImage:[UIImage imageNamed:@"Nv_custom_colorSelected"] forState:UIControlStateNormal];
        }else{
            button.backgroundColor = [UIColor blackColor];
        }
        button.tag = i;
        button.frame =CGRectMake(xValue, (i+1)*15*SCREENSCALE+i*30*SCREENSCALE+256*SCREENSCALE, 30*SCREENSCALE, 30*SCREENSCALE);
        button.layer.cornerRadius = 15*SCREENSCALE;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.buttonArrs addObject:button];
    }
}

#pragma mark - 按钮点击事件
/*
 按钮点击事件
 Button click event
 
 */
- (void)buttonClicked:(UIButton *)button {
    [self selectButtonWithIndex:button.tag];
    switch (button.tag) {
        case 1:
        {
            
        }
            break;
        case 2:
        {
            
        }
            break;
        case 3:
        {
            
        }
            break;
            
        default:{
            //自定义颜色  Customize the color
            if (self.colorSlider.hidden == YES) {
                self.colorSlider.hidden = NO;
            }
        }
            break;
    }
    if([self.delegate respondsToSelector:@selector(colorView:selectColorButton:)]){
        [self.delegate colorView:self selectColorButton:button.tag];
    }
}

#pragma mark - 更新选中的按钮状态
/*
 更新选中的按钮状态
 Update the status of the selected button
 
 @param index 选中的下标
 Selected index
 
 */
- (void)selectButtonWithIndex:(NSInteger)index {
    for (UIButton *btn in self.buttonArrs) {
        btn.layer.borderWidth = 0;
        btn.layer.borderColor = [UIColor clearColor].CGColor;
    }
    UIButton *button = self.buttonArrs[index];
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 1.5*SCREENSCALE;
}

- (void)setModel:(NvMakeupContentModel *)model {
    _model = model;
    [self setColorButtonsStateWithModel:model];
    if (!model.hasSelectedCustomColor) {
        [self setDefaultMode];
    }else{
        self.colorSlider.hidden = NO;
        self.endPoint = CGPointMake(model.xValue, 0);
    }
}

#pragma mark - 设置默认数据
/*
 设置默认数据
 Set default data
 
 */
- (void)setDefaultMode {
    [self.colorSlider setDefaultMode];
    self.colorSlider.hidden = YES;
}

- (void)setEndPoint:(CGPoint)endPoint {
    _endPoint = endPoint;
    self.colorSlider.hidden = NO;
    self.colorSlider.endPoint = endPoint;
}

#pragma mark - 根据参数，修改界面按钮状态
/*
 根据参数，修改界面按钮状态
 According to the parameters, modify the interface button state
 
 @param isSelected 是否选中了自定义颜色，yes表示选中，no表示没有选中
 If custom color is selected, yes means selected, no means not selected
 
 */
- (void)setCustomColorButtonSelected:(BOOL)isSelected {
    for (UIButton *btn in self.buttonArrs) {
        btn.layer.borderWidth = 0;
        btn.layer.borderColor = [UIColor clearColor].CGColor;
    }
    UIButton *button = self.buttonArrs[0];
    if (isSelected) {
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 1.5*SCREENSCALE;
    }else{
        [button setBackgroundImage:[UIImage imageNamed:@"Nv_custom_colorSelected"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        button.layer.borderWidth = 0;
        button.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

#pragma mark - 根据参数，修改界面按钮状态
/*
 根据参数，修改界面按钮状态
 According to the parameters, modify the interface button state
 
 @param model 美妆模型
 Make up model
 
 */
- (void)setColorButtonsStateWithModel:(NvMakeupContentModel *)model {
    [self setCustomColorButtonSelected:model.hasSelectedCustomColor];
    if (model.effectContent.makeup.count <=0 || !model.effectContent.makeup) {
        return;
    }
    for (int i=0; i<model.effectContent.makeup[0].makeupRecommendColors.count; i++) {
        UIButton *button = self.buttonArrs[i+1];
        button.backgroundColor = [self colorWithValue:model.effectContent.makeup[0].makeupRecommendColors[i].makeupColor];
    }
    if (model.selectedButtonIndex > 0) {
        UIButton *button = self.buttonArrs[model.selectedButtonIndex];
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 1.5*SCREENSCALE;
    }
}

#pragma mark - 根据参数，转换成UIColor
/*
 根据参数，转换成UIColor
 According to the parameters, convert to UIColor
 
 @param value 传入的RGBA字符串
 Incoming RGBA string
 
 return UIColor。
 */
- (UIColor *)colorWithValue:(NSString *)value {
    NSArray *arr = [value componentsSeparatedByString:@","];
    UIColor *color;
    if (arr.count == 4) {
        color = [UIColor colorWithRed:[arr[0] floatValue] green:[arr[1] floatValue] blue:[arr[2] floatValue] alpha:[arr[3] floatValue]];
    }
    return color;
}

#pragma mark - colorControl回调
- (void)colorControl:(NvColorSelectedControl *)colorView R:(CGFloat)r G:(CGFloat)g B:(CGFloat)b alpha:(CGFloat)alpha point:(CGPoint)point {
    UIColor *color = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:alpha];
    UIButton *button = self.buttonArrs[0];
    [button setBackgroundImage:nil forState:UIControlStateNormal];
    button.backgroundColor = color;
    if ([self.delegate respondsToSelector:@selector(colorView:R:G:B:alpha:point:)]) {
        [self.delegate colorView:self R:r/255.0 G:g/255.0 B:b/255.0 alpha:alpha point:point];
    }
    
}

@end
