//
//  NvSearchBar.h
//  SDKDemo
//
//  Created by chengww on 2020/11/27.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - NvSearchBarOption

/// 搜索图标的位置 Search for the location of the icon
typedef NS_ENUM(NSInteger,NvSearchBarPosition){
    NvSearchBarPosition_Left    = 0,   ///<左
    NvSearchBarPosition_Center  = 1    ///<中心
};
@interface NvSearchBarOption : NSObject

/// 搜索框的位置 The location of the search box
@property (nonatomic, assign) UIEdgeInsets barInsets;

/// 搜索框的大小 The size of the search box
@property (nonatomic, assign) CGSize barSize;

/// 搜索框的颜色 Search box color
@property (nonatomic, strong) UIColor *barTintColor;

/// 搜索框的背景颜色 The background color of the search box
@property (nonatomic, strong) UIColor *barBackgroundColor;

/// 搜索图标的位置 Location of search icon
@property (nonatomic, assign) NvSearchBarPosition searchImagePositon;

/// 搜索图标  search Image
@property (nonatomic, strong) UIImage *searchImage;

/// 搜索占位文字偏移量 Search placeholder text offset
@property (nonatomic, assign) CGFloat placeHolderOffset;

/// 搜索占位文字大小 Search placeholder text size
@property (nonatomic, strong) UIFont *placeHolderFont;

/// 搜索占位文字颜色 Search placeholder text color
@property (nonatomic, strong) UIColor *placeHolderColor;

/// 搜索占位文字 Search placeholder text
@property (nonatomic, copy)   NSString *placeHolderText;

/// 搜索文字大小 Search text size
@property (nonatomic, strong) UIFont *textFont;

/// 搜索文字颜色 Search text color
@property (nonatomic, strong) UIColor *textColor;

/// 搜索取消文字  Search cancel text
@property (nonatomic, copy) NSString *cancelText;

/// 搜索取消文字大小  Search cancel text size
@property (nonatomic, strong) UIFont *cancelTextFont;

/// 搜索取消文字颜色Search cancel text color
@property (nonatomic, strong) UIColor *cancelTextColor;

/// 搜索取消宽度 Search cancel width
@property (nonatomic, assign) CGFloat cancelWidth;
@end

#pragma mark - NvMoreFilterSearchBar
@class NvSearchBar;
@protocol NvSearchBarDelegate <NSObject>
@optional

/// 开始编辑
/// Start editing
/// @param searchBar 搜索按钮 Search button
- (void)searchBarBeginEditing:(NvSearchBar *)searchBar;

/// 监听输入的文本
/// Listen to the entered text
/// @param searchBar 搜索按钮 Search button
- (void)searchBarTextInputDidChanged: (NvSearchBar *)searchBar;

/// 点击取消搜索
/// Click to cancel search
/// @param searchBar 搜索按钮 Search button
- (void)searchBarDidCanceled:(NvSearchBar *)searchBar;

/// 开始搜索
/// Start search
/// @param searchBar 搜索按钮 Search button
- (void)searchBarBeginSearch:(NvSearchBar *)searchBar;
@end

@interface NvSearchBar : UIView

/// 实例化 Instantiate
- (instancetype)init NS_UNAVAILABLE;

/// 实例化
/// Instantiate
/// @param frame 位置 frame
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/// 实例化
/// Instantiate
/// @param frame 位置 frame
/// @param opt 配置选项 Configuration options
- (instancetype)initWithFrame:(CGRect)frame
                      options: (NvSearchBarOption *)opt;

/// 代理 delegate
@property (nonatomic, weak) id<NvSearchBarDelegate> delegate;

/// 输入的文字 Input text
@property (nonatomic, copy, readonly) NSString *inputText;

/// 搜索框的实际高度 The actual height of the search box
@property (nonatomic, assign, readonly) CGFloat searchBarHeight;

/// 搜索键盘是否响应 Whether the search keyboard responds
@property (nonatomic, assign) BOOL firstResponder;

/// 搜索是否开启 Whether search is on
@property (nonatomic, assign) BOOL isEnableSearch;

@end

NS_ASSUME_NONNULL_END
