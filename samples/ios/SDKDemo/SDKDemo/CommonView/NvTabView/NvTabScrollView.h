//
//  NvTabScrollView.h
//  TapScrollView
//
//  Created by 刘东旭 on 2018/4/3.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  NvTabScrollViewDelegate <NSObject>

/// 滑动刷新
/// Swipe to refresh
/// @param index 下标 index
-(void)sliderViewAndReloadData:(NSInteger)index;

@end

@interface NvTabScrollView : UIView

/// 标签滚动视图 Tab scroll view
@property (nonatomic,strong) UIScrollView *pageScrollView;

/// 代理 delegate
@property (nonatomic,weak)id delegate;

/// 字体颜色 font color
@property (nonatomic,copy)UIColor  *titileColror;

/// 按钮的字体大小 Button font size
@property (nonatomic,copy)UIFont   *titlleFont;

/// 滑动条颜色 Slider color
@property (nonatomic,copy)UIColor  *sliderViewColor;

/// button选中的颜色 button selected color
@property (nonatomic,copy)UIColor  *selectedColor;

/**
 初始化创建方法
 Initial creation method

 @param titleArr 标题 title
 @param viewArr 视图数组 传入 视图控制器 View array passed in view controller
 @param rootVC 当前的视图 一般为self The current view is generally self
 */
-(void)createView:(NSArray *)titleArr andViewArr:(NSArray *)viewArr andRootVc:(UIViewController *)rootVC hiddenHeader:(BOOL)header;

/**
 手动  或者 外部滑动的方法
 Manual or external sliding method

 @param index 下标 index
 */
-(void)sliderToViewIndex:(NSInteger)index;

@end
