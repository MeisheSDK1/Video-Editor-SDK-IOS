//
//  NvShadowListView.h
//  SDKDemo
//
//  Created by Meishe on 2022/9/15.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionColorItem.h"
#import "NVHeader.h"

@protocol NvShadowListViewDelegate <NSObject>
- (void)okClick;
- (void)applyShadowColorToAllCaption:(BOOL)applyToAllCaption;
- (void)selectShadowColor:(NvCaptionColorItem *_Nullable)item;
- (void)alphaShadowChanged:(float)value;

@end

NS_ASSUME_NONNULL_BEGIN
@interface NvShadowListView : UIView

@property (weak, nonatomic) id <NvShadowListViewDelegate>delegate;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *styleApplyLabel;
@property (nonatomic, strong) NvButton *applyButton;
@property (nonatomic, strong, nullable) NvCaptionColorItem *currentItem;
@property (nonatomic, assign) BOOL containFinishButton;

- (void)setDefaultDataSource:(NSMutableArray *)dataSource alpha:(float)value;


@end

NS_ASSUME_NONNULL_END
