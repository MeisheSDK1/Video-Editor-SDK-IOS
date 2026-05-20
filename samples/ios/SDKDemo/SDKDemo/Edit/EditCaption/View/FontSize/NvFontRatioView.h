//
//  NvFontRatioView.h
//  SDKDemo
//
//  Created by Meishe on 2022/9/14.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLItemSlider.h"
NS_ASSUME_NONNULL_BEGIN
@protocol NvFontRatioViewDelegate <NSObject>
- (void)okClick;

- (void)applyFontRatioToAllCaption:(BOOL)applyToAllCaption;

- (void)fontRatioChanged:(float)value;

- (void)disableFontRatio:(BOOL)disable;
@end

@interface NvFontRatioView : UIView
@property (nonatomic, assign) id <NvFontRatioViewDelegate>delegate;
@property (nonatomic, strong) BLItemSlider *slider;
@property (nonatomic, strong) UILabel *styleApplyLabel;
@property (nonatomic, strong) NvButton *applyButton;

- (void)setDefaultFontRatio:(float)value;

- (void)enableFontRatio:(BOOL)enable;
@end

NS_ASSUME_NONNULL_END
