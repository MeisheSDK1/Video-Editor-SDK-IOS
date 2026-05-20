//
//  JYPopView.h
//  jinyun
//
//  Created by 美摄 on 2019/4/1.
//  Copyright © 2019 美摄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 弹窗的位置 The position of the pop-up window
typedef NS_ENUM(NSInteger,NvPopDirection){
    NvPopDirection_Bottom         = 0,    ///< 底部  Bottom
    NvPopDirection_Center         = 1     ///< 中心 Center
};

@interface NvPopView : UIView

/// 内容视图 Content view
@property(nonatomic,weak)UIView* contentView;

/// 背景视图 Background view
@property(nonatomic,strong)UIView* bgView;

/// 设置子视图 Set up the subview
-(void)setupSubviews;

/// 展示弹窗视图
/// Show pop-up view
/// @param direction 方向 direction
/// @param completion 动画结束的回调 Callback for the end of the animation
-(void)showWithDirection:(NvPopDirection)direction completion:(void (^ __nullable)(void))completion;

/// 销毁弹窗视图
/// Destroy the pop-up view
/// @param completion 动画结束的回调 Callback for the end of the animation
-(void)dismissCompletion:(void (^ __nullable)(void))completion;

/// 背景视图点击事件
/// Background view click event
/// @param gesture 手势 gesture
-(void)bgClicked:(UIGestureRecognizer*)gesture;

@end

NS_ASSUME_NONNULL_END
