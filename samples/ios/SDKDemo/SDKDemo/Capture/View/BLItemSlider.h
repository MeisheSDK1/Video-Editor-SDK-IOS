//
//  BLItemSlider.h
//  BLVideo
//
//  Created by 美摄 on 2020/6/1.
//  Copyright © 2020 美摄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BLItemSlider;

@protocol BLItemSliderDelegate <NSObject>

@optional
-(void)itemSlider:(BLItemSlider*)slider valueChanged:(float)value;
-(void)itemSliderTouchEnd:(BLItemSlider*)slider;
-(void)itemSliderChangeStart:(BLItemSlider*)slider;
-(void)itemSliderDisabled:(BLItemSlider*)slider;
@end

@interface BLItemSlider : UIView

@property(nonatomic,weak)id<BLItemSliderDelegate> delegate;

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

- (void)modifyStylevalueLabel;

- (void)cancelAnimation;

@end

NS_ASSUME_NONNULL_END
