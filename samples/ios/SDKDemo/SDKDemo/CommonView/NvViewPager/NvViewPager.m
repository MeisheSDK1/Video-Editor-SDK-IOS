#import "NvViewPager.h"
#import <Masonry/Masonry.h>


#define kWidth self.frame.size.width

@interface NvViewPager () <UIScrollViewDelegate, UIGestureRecognizerDelegate,NvCategoryViewDelegate>
@property (nonatomic, strong) NvCategoryView *categoryView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *currentPageView;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) NSArray<UIView *> *pageViews;
@end

@implementation NvViewPager

-(void)dealloc {
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame subViews:(NSArray *)subViews subTitles:(NSArray *)titles
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pageViews = subViews;
        self.categoryView.titles = titles;
        self.currentPageView = self.pageViews[self.categoryView.originalIndex];
        self.selectedIndex = self.categoryView.originalIndex;
        
        [self addSubview:self.categoryView];
        [self addSubview:self.scrollView];
        
        [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.mas_equalTo(self->_categoryView.height);
        }];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.categoryView.mas_bottom);
            make.left.right.bottom.mas_equalTo(self);
        }];
        [self.pageViews enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIView *view = obj;
            [self.scrollView addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(idx * kWidth);
                make.top.width.height.equalTo(self.scrollView);
            }];
        }];
        
        self.categoryView.delegate = self;
    }
    return self;
}

- (void)insertFixedItemAtLastIndex:(NSString *)itemName imageName:(NSString *)imageName {
    [self.categoryView insertFixedItemAtLastIndex:itemName imageName:imageName];
}

- (void)didSelectIndex:(NSUInteger)index {
    if (!self.captionInfo && self.isCompoundCaption&&index!=0) {
        [NvToast showInfoWithMessage:@"当前没有可编辑的字幕"];
        return;
    }
    [self.scrollView setContentOffset:CGPointMake(index * kWidth, 0) animated:NO];
    self.currentPageView = self.pageViews[index];
    self.selectedIndex = index;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NvPagerViewSelected" object:@(index)];
}

- (void)fixedItemClicked {
    if ([self.delegate respondsToSelector:@selector(fixedItemClicked)]) {
        [self.delegate fixedItemClicked];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageViewWillBeginDragging)]) {
        [self.delegate pageViewWillBeginDragging];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageViewDidEndDragging)]) {
        [self.delegate pageViewDidEndDragging];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger index = (NSUInteger)(self.scrollView.contentOffset.x / kWidth);
    [self.categoryView changeItemWithTargetIndex:index];
    self.currentPageView = self.pageViews[index];
    self.selectedIndex = index;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageViewDidEndDeceleratingWithPageIndex:)]) {
        [self.delegate pageViewDidEndDeceleratingWithPageIndex:index];
    }
}

#pragma mark - Getters
- (NvCategoryView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[NvCategoryView alloc] init];
    }
    return _categoryView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.contentSize = CGSizeMake(kWidth * self.pageViews.count, 0);
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollEnabled = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.selectedIndex == 0) {
        return YES;
    }
    return NO;
}

@end
