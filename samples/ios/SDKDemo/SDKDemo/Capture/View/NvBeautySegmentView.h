//
//  NvBeautySegmentView.h
//  SDKDemo
//
//  Created by MS on 2020/7/23.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^NvBeautySegmentBlock)(NSInteger selectedIndex);

@interface NvBeautySegmentView : UIView

/// 初始化
/// initialization
/// @param titles seg选项title内容   seg option title content
/// @param selectedColor 选中背景颜色(RGBA)  Select the background color (RGBA)
/// @param normalColor 未选中背景颜色(RGBA)   Unchecked background color (RGBA)
/// @param selectedTextColor 选中文字颜色(RGBA)  Selected text color (RGBA)
/// @param normalTextColor 未选中文字颜色(RGBA)   Unselected text color (RGBA)
/// @param fontSize 文字字号  Font size
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles selectedBgColor:(NSString *)selectedColor normalBgColor:(NSString *)normalColor selectedTextColor:(NSString *)selectedTextColor normalTextColor:(NSString *)normalTextColor fontSize:(CGFloat)fontSize;

/// 选中回调  Selected callback
@property (nonatomic, copy) NvBeautySegmentBlock selectBlock;


/// 设置默认选中选项索引
/// Set the default selected option index
/// @param index index
- (void)setDefaultSelectedSegment:(NSInteger)index;

/// 设置CornerRadius
/// Set CornerRadius
/// @param radius radius
- (void)setRectCornerRadius:(CGFloat)radius;

@end

NS_ASSUME_NONNULL_END
