//
//  NvAnimationSlider.h
//  SDKDemo
//
//  Created by ms on 2020/8/27.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NvAnimationSlider;

@protocol NvAnimationSliderDelegate <NSObject>

-(void)itemSlider:(NvAnimationSlider*)slider valueChanged:(float)value;
-(void)itemSliderTouchEnd:(NvAnimationSlider*)slider;

@end

@interface NvAnimationSlider : UIView

@property(nonatomic,weak)id<NvAnimationSliderDelegate> delegate;

@property(nonatomic,strong)UILabel*     valueLabel;
@property(nonatomic,strong)NSString*    valueFormat;

@property(nonatomic,strong) UIColor*    minimumTrackTintColor;
@property(nonatomic,strong) UIColor*    maximumTrackTintColor;
@property(nonatomic,strong) UIColor*    thumbTintColor;
@property(nonatomic,strong) UIColor*    thumbSeletedTintColor;

@property(nonatomic,strong) UIImageView* thumbImageView;

@property(nonatomic,strong) UIColor*    adsorbPointColor;
@property(nonatomic,assign) float       adsorbPointWidth;
@property(nonatomic,assign) float       adsorbWidth;

@property(nonatomic,assign) float       lineHeight;

@property(nonatomic,assign)float        value;
@property(nonatomic,assign)float        minValue;
@property(nonatomic,assign)float        maxValue;

-(void)adsorb:(BOOL)enable adsorbValue:(float)value;

@end

NS_ASSUME_NONNULL_END

