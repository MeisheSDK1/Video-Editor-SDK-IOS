//
//  CQTabView.h
//  SwipeViewExample
//  菜单选择栏
//  Created by pan drinking on 15/3/24.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, CQTabLayoutStyle) {
    // Full or not, same size controls, no sliding support
    CQTabFillParent,//是否铺满,控件大小相同,不支持滑动
    // Whether to support sliding based on automatic size recognition
    CQTabWrapContent//是否根据自动识别大小,支持滑动
};

typedef NS_ENUM(NSInteger, CQTabCursorStyle) {
    // Click to select the underscore
    CQTabCursorUnderneath,//点击选择下划线
    // State selected, all wrapped
    CQTabCursorWrap//选中状态,全包裹
};

typedef void (^CQTabItemAtIndexBlock)(UIView *view, NSInteger index);
@interface CQMenuTabView : UIView

/**
 *  菜单按钮下方横线背景属性
 *  The horizontal background property below the menu button
 */
@property (nonatomic, strong) UIView *cursorView;
// Whether to show the bottom line
@property (nonatomic, assign) BOOL showCursor;//是否显示下方横线
@property (nonatomic, assign) CGFloat cursorAnimationDuration;
@property (nonatomic, assign) CGFloat cursorHeight;
@property (nonatomic, assign) CGFloat cursorWidth;
@property (nonatomic, assign) CQTabCursorStyle cursorStyle;
@property (nonatomic, assign) CGVector cursorWrapInset;
// which is currently selected
@property (nonatomic, assign) NSInteger cursorIndex;//当前选中第几个
//2 menus directly spaced
@property (nonatomic, assign) CGFloat speaceWidth;//2个菜单直接的间距


@property (nonatomic, assign) UIEdgeInsets tabViewItemMargin;
@property (nonatomic, assign) CQTabLayoutStyle layoutStyle;
@property (nonatomic, strong) NSArray *tabViewItems;


@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UIColor *normaTitleColor;
@property (nonatomic, strong) UIColor *didSelctTitleColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *didSelectTitleFont;
@property (nonatomic, assign) BOOL isSpeaceLine;
@property (nonatomic, strong) UIColor *speaceLineColor;
@property (nonatomic, assign) CGFloat speaceLineHight;

/**
 *  点击完状态
 *  Click finished status
 */
@property(nonatomic, copy) CQTabItemAtIndexBlock hightlightTabItemBlock;

/**
 *  普通状态
 *  Normal state
 */
@property(nonatomic, copy) CQTabItemAtIndexBlock normalizeTabItemBlock;

/**
 *  点击中状态
 *  Click on the state
 */
@property(nonatomic, copy) CQTabItemAtIndexBlock didTapItemAtIndexBlock;


/**
 *  点击中状态包含是否允许点击
 *  The state of a click contains whether the click is allowed or not
 */
@property (nonatomic,copy) BOOL (^didCanSelectIndex)(UIView *view, NSInteger index);

/**
 自定义UI
 Customizing UI

 @param tabViewItems 定义的ui数组
 */
- (void)buildTabViewWithItems:(NSArray *(^)(void))tabViewItems;

/**
 选择第几个
 Select the number
 
 @param index 索引
 */
- (void)selectIndex:(NSInteger)index;


/**
 选择第几个
 Select the number
 @param index 索引
 @param animation 动画
 */
- (void)selectIndex:(NSInteger)index animation:(BOOL)animation;
@end

