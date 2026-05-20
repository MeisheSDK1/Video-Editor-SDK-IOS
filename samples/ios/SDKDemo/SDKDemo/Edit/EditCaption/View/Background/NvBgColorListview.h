//
//  NvBgColorListview.h
//  SDKDemo
//
//  Created by Meicam on 2018/6/6.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionColorItem.h"
#import "NVHeader.h"

@protocol NvBgColorListviewDelegate
@optional
- (void)okClick;
- (void)applyBgColorToAllCaption:(BOOL)applyToAllCaption;
- (void)selectBgColor:(NvCaptionColorItem *)item;
- (void)alphaBgChanged:(float)value;
- (void)bgRadiusChanged:(float)value;
- (void)marginBgChanged:(float)value;

@end

@interface NvBgColorListview : UIView

@property (weak, nonatomic) id delegate;
@property (nonatomic, assign) BOOL containFinishButton;
@property (nonatomic, assign) BOOL isCompoundCaption;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) NvButton *applyButton;
@property (nonatomic, strong) UILabel *styleApplyLabel;
@property (nonatomic, strong) NvCaptionColorItem *currentItem;

@property (nonatomic, strong) UILabel *radiusLabel;
@property (nonatomic, strong) UILabel *radiusNumLabel;
@property (nonatomic, strong) UISlider *radiusslider;

@property (nonatomic, strong) UILabel *marginLabel;
@property (nonatomic, strong) UILabel *marginNumLabel;
@property (nonatomic, strong) UISlider *marginslider;

- (void)setDefaultDataSource:(NSMutableArray *)dataSource alpha:(float)value;

- (void)setDefaultTextBgRadius:(float)radius maxValue:(float)maxValue;

- (void)setDefaultTextBgMargin:(float)margin maxValue:(float)maxValue;

@end
