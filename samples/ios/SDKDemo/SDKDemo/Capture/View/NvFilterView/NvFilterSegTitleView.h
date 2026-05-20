//
//  NvFilterSegTitleView.h
//  SDKDemo
//
//  Created by 美摄 on 2019/8/30.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NvFilterSegTitleViewDelegate <NSObject>

/// 选中的下标回调
/// Selected subscript callback
/// @param index 下标 index
-(void)didselectedIndex:(NSInteger)index;

@end

@interface NvFilterSegTitleView : UIView

/// 初始化
/// initialization
/// @param frame 位置 frame
/// @param titleArray 标签数组 titleArray
/// @param delegate 代理 delegate
-(instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray*)titleArray delegate:(id<NvFilterSegTitleViewDelegate>)delegate;

/// 初始化
/// initialization
/// @param frame 位置 frame
/// @param titleArray 标签数组 titleArray
/// @param height 控件高度
/// @param delegate 代理 delegate
-(instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray*)titleArray customHeight:(CGFloat)height delegate:(id<NvFilterSegTitleViewDelegate>)delegate;

/// 更新选中的下标
/// Update selected index
/// @param index 下标 index
-(void)updateSelectedIndex:(NSInteger)index;

/// 自定义未选中颜色(RGBA)  Custom unselected color (RGBA)
@property (nonatomic, strong) NSString *customUnSelectedColor;
@end

NS_ASSUME_NONNULL_END
