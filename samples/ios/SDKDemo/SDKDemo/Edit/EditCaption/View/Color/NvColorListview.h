//
//  NvColorListview.h
//  SDKDemo
//
//  Created by Meicam on 2018/6/6.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionColorItem.h"
#import "NVHeader.h"

@protocol NvColorListviewDelegate
@optional
- (void)okClick;
- (void)applyColorToAllCaption:(BOOL)applyToAllCaption;
- (void)selectColor:(NvCaptionColorItem *)item;
- (void)alphaChanged:(float)value;

@end

@interface NvColorListview : UIView

@property (weak, nonatomic) id delegate;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *styleApplyLabel;
@property (nonatomic, strong) NvButton *applyButton;
@property (nonatomic, strong) NvCaptionColorItem *currentItem;
@property (nonatomic, assign) BOOL containFinishButton;

- (void)setDefaultDataSource:(NSMutableArray *)dataSource alpha:(float)value;

@end
