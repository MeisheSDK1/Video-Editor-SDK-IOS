#import <UIKit/UIKit.h>

@interface NvCategoryViewCollectionViewCell : UICollectionViewCell

/// 文本控件 Text control
@property (nonatomic, readonly, strong) UILabel *titleLabel;

@end;

@protocol NvCategoryViewDelegate <NSObject>
@optional

/// 点击选中回调
/// Click to select callback
/// @param index 下标 index
- (void)didSelectIndex:(NSUInteger)index;

- (void)fixedItemClicked;

@end

@interface NvCategoryView : UIView

/// 滑动视图 Sliding view
@property (nonatomic, strong, readonly) UICollectionView *collectionView;

/// 标签的下划线 Label underscore
@property (nonatomic, strong, readonly) UIView *underline;

@property (nonatomic, assign) BOOL shortUnderline;

/// 标签的分隔符 Label separator
@property (nonatomic, strong, readonly) UIView *separator;

/// 文字大小 font size
@property (nonatomic, strong) UIFont *titleNomalFont;

/// 选中的文字大小 Selected text size
@property (nonatomic, strong) UIFont *titleSelectedFont;

/// 文字的颜色 Text color
@property (nonatomic, strong) UIColor *titleNormalColor;

/// 选中的文字的颜色 The color of the selected text
@property (nonatomic, strong) UIColor *titleSelectedColor;

/// 原始的下标 Original subscript
@property (nonatomic) NSInteger originalIndex;

/// 选中的下标 Selected subscript
@property (nonatomic, readonly) NSInteger selectedIndex;

/// 标签数组 Label array
@property (nonatomic, strong) NSArray<NSString *> *titles;

/// 标签高度 Label height
@property (nonatomic) CGFloat height;

/// 下划线高度 Underline height
@property (nonatomic) CGFloat underlineHeight;

/// cell的间距 cell spacing
@property (nonatomic) CGFloat cellSpacing;

/// cell的间距 cell spacing
@property (nonatomic) CGFloat leftAndRightMargin;

/// 代理 delegate
@property (nonatomic, weak) id delegate;

/// 根据选中的下标，更新状态
/// Update the status according to the selected subscript
/// @param targetIndex 下标  targetIndex
- (void)changeItemWithTargetIndex:(NSUInteger)targetIndex;

/// 在末尾添加不随滑动而滑动的item Add an item at the end that does not slide along
/// @param itemName 名字
- (void)insertFixedItemAtLastIndex:(NSString *)itemName imageName:(NSString *)imageName;

@end
