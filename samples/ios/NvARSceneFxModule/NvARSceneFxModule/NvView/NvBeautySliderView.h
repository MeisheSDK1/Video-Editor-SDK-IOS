//
//  NvBeautySlider.h
//  NvBeautySliderDemo
//
//  Created by 董凌晓 on 2019/10/30.
//  Copyright © 2019 董凌晓. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NvBeautySliderViewDelegate <NSObject>

-(void)sliderValueChanged:(UISlider *)paramSender;
-(void)sliderValueEnd:(UISlider *)paramSender;
@end

@interface NvBeautySliderView : UIView
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, strong) UISlider *slider;

@property(nonatomic, weak) id<NvBeautySliderViewDelegate> delegate;

- (void)refreshView ;

- (void)setupTextLabel:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
