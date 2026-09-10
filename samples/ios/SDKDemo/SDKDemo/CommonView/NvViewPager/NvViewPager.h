#import <UIKit/UIKit.h>
#import "NvCategoryView.h"
#import "NvTimelineDataModel.h"

@protocol NvPageViewDelegate <NSObject>
@optional

/// 开始滚动 Start scrolling
- (void)pageViewWillBeginDragging;

/// 结束滚动 End scroll
- (void)pageViewDidEndDragging;

/// 停止减速回调
/// Stop deceleration callback
/// @param index 当前的下标 Current index
- (void)pageViewDidEndDeceleratingWithPageIndex:(NSInteger)index;

- (void)fixedItemClicked;

@end

@interface NvViewPager : UIView
@property (nonatomic, strong) NvCompoundCaptionInfoModel *captionInfo;
@property (nonatomic, assign) BOOL isCompoundCaption;

/// 标签视图 Tab view
@property (nonatomic, strong, readonly) NvCategoryView *categoryView;

/// 当前标签对应的视图 The view corresponding to the current label
@property (nonatomic, strong, readonly) UIView *currentPageView;

/// 选中的下标 Selected Index
@property (nonatomic, readonly) NSInteger selectedIndex;

/// 代理 delegate
@property (nonatomic, weak) id<NvPageViewDelegate> delegate;

/// 标签对应的内容视图数组 The content view array corresponding to the label
@property (nonatomic, strong, readonly) NSArray<UIView *> *pageViews;

/// 初始化
/// initialization
/// @param frame 位置  frame
/// @param subViews 标签对应的内容视图数组 The content view array corresponding to the label
/// @param titles 标签数组 Label array
- (instancetype)initWithFrame:(CGRect)frame subViews:(NSArray *)subViews subTitles:(NSArray *)titles;

- (void)insertFixedItemAtLastIndex:(NSString *)itemName imageName:(NSString *)imageName;
@end

