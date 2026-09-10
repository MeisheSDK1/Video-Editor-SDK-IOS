//
//  NveBeautySlider.h
//  NveBeautySliderDemo
//
//  Created by 董凌晓 on 2019/10/30.
//  Copyright © 2019 董凌晓. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NvLiveBeautySliderView;

@protocol NvLiveBeautySliderViewDelegate <NSObject>
-(void)itemSliderChangeStart:(NvLiveBeautySliderView*)slider;
-(void)itemSlider:(NvLiveBeautySliderView*)slider valueChanged:(float)value;
-(void)itemSliderTouchEnd:(NvLiveBeautySliderView*)slider;
@optional
-(void)itemSliderDisabled:(NvLiveBeautySliderView*)slider;
@end

@interface NvLiveBeautySliderView : UIView
@property(nonatomic,weak)id<NvLiveBeautySliderViewDelegate> delegate;

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
@property (nonatomic, assign) BOOL enable;
//在label 上显示真实数据
// Display the real data on the label
@property (nonatomic, assign) BOOL showRealValue;
//在label 上显示取值范围在【0， 100】映射后的数据
// Display the mapped data in the [0, 100] range on the label
@property (nonatomic, assign) BOOL showTwoSidesLimitedValue;
-(void)adsorb:(BOOL)enable adsorbValue:(float)value;
@end

NS_ASSUME_NONNULL_END
