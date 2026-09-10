//
//  NvStrokeListView.h
//  SDKDemo
//
//  Created by Meicam on 2018/6/6.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionStrokeItem.h"
#import "NVHeader.h"

@protocol NvStrokeListViewDelegate
- (void)okClick;
- (void)applyStrokeToAllCaption:(BOOL)applyToAllCaption;
- (void)selectStroke:(NvCaptionStrokeItem *)item;
- (void)selectStroke:(NvCaptionStrokeItem *)item withWidth:(CGFloat)width;
- (void)selectStroke:(NvCaptionStrokeItem *)item withAlpha:(CGFloat)alpha;

@end

@interface NvStrokeListView : UIView

@property (weak, nonatomic) id delegate;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) BOOL containFinishButton;
@property (nonatomic, strong) UILabel *styleApplyLabel;
@property (nonatomic, strong) NvButton *applyButton;
@property (nonatomic, strong) NvCaptionStrokeItem *currentItem;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UISlider *widthSlider;

- (void)setDefaultDataSource:(NSMutableArray *)dataSource width:(float)width alpha:(float)value;

@end
