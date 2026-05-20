//
//  NvHorizontalView.h
//  SDKDemo
//  该控件：左侧图片右侧label
//  The control: left picture right label
//  Created by MS on 2019/6/20.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NvHorizontalViewDelegate <NSObject>

/**
 界面点击方法
 Interface click method
 
 @param isSelected 是否选中 Whether selected
 */
- (void)nvHorizontalViewClickedIsSelected:(BOOL)isSelected;

@end

@interface NvHorizontalView : UIView

/// 两控件之间间隔 Space between two controls
@property(nonatomic, assign)CGFloat horizontalItemSep;

/// label字体大小 label font size
@property(nonatomic, assign)CGFloat fontSize;

/// imageView尺寸 imageView size
@property(nonatomic, assign)CGSize imageSize;

/// label字体颜色 label font color
@property(nonatomic, copy)NSString *colorString;

/// imageView图像 imageView image
@property(nonatomic, copy)NSString *imageName;

/// 是否选中 isSelected
@property(nonatomic, assign)BOOL isSelected;

/// 代理 delegate
@property(nonatomic, weak)id <NvHorizontalViewDelegate>delegate;

/// 初始化
/// initialization
/// @param imageName 显示的图片 Picture shown
/// @param title Displayed text
- (instancetype)initWithImage:(NSString *)imageName title:(NSString *)title ;
@end

NS_ASSUME_NONNULL_END
