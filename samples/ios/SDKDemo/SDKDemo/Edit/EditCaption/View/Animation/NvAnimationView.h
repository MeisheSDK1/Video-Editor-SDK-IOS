//
//  NvAnimationView.h
//  SDKDemo
//
//  Created by ms on 2020/7/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NvCaptionAnimationItem.h"
#import "NVHeader.h"
#import "NvDoubleSliderView.h"

/**
 功能类型
 Functional type
*/
typedef enum{
    NvInAnimationType = 0,       ///< 入场动画 InAnimation
    NvOutAnimationType,          ///<出场动画 OutAnimation
    NvComAnimationType,         ///< 组合动画 ComAnimation
}NvAnimationType;

@protocol NvAnimationViewDelegate
@optional
- (void)okClick;
- (void)selectAnimation:(NvCaptionAnimationItem *)item withAnimationType:(NvAnimationType)type;
- (void)applyAnimationAllCaption:(BOOL)applyToAllCaption withAnimationType:(NvAnimationType)type;
- (void)moreAnimationClickWithAnimationType:(NvAnimationType)type;
- (void)changeAnimationType:(NvAnimationType)type data:(NvCaptionAnimationItem *)item;

@end

@interface NvAnimationView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL containFinishButton;
@property (nonatomic, strong) NvCaptionAnimationItem *currentItem;
@property (nonatomic, strong) NvButton *applyButton;
@property (nonatomic, strong) NvDoubleSliderView *doubleSlider;
@property (nonatomic, strong) UISlider *comSlider;
@property (nonatomic, strong) UIView *sliderView;
@property (nonatomic, strong) UILabel *comLabel;

- (NvAnimationType)getCurrenntType;
/// 设置动画数组
/// Set animation array
/// @param dataSource 开场动画数组
/// Opening animation array
/// @param type 动画类型
/// Animation type
- (void)renderListWithOpenItems:(NSMutableArray <NvCaptionAnimationItem *>*)dataSource withType:(NvAnimationType)type;

/// 刷新数据
/// Refresh data
- (void)reloadData;
@end
