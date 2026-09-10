//
//  NvTabScrollView.m
//  TapScrollView
//
//  Created by mac on 2018/4/3.
//  Copyright © 2018年 Joker. All rights reserved.
//

#import "NvTabScrollView.h"
#import "NVDefineConfig.h"
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define RGB(R,G,B)        [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]

/*
 主题橙色
 Theme orange
 */
#define Base_Orange RGB(237,120,14)
@interface NvTabScrollView()<UIScrollViewDelegate>

@end


@implementation NvTabScrollView
{
    
    
    NSMutableArray *_buttonViewArr;

    CGFloat _width;
    
    UIView *_lineView;
    
    /*
     当前选中
     Currently selected
     */
    NSInteger  _currentSelectIndex;
    
    NSInteger _pageCount;
    
    BOOL hiddenHeader;

}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.frame = frame;

        self.backgroundColor = RGB(36,39,40);
        /*
         顶部按钮的标题颜色  外部填入，若没有则有默认值
         The title color of the top button is filled in outside, if not, there is a default value
         */
        self.titileColror = self.titileColror ? self.titileColror:RGB(102,102,102);
        /*
         顶部标题的标题字体大小  外部传入  若没有有默认值
         The title font size of the top title Externally passed in If there is no default value
         */
        self.titlleFont = self.titlleFont ? self.titlleFont : [UIFont systemFontOfSize:15];
        /*
         底部滑块的颜色，外部传入，没有存在默认值
         The color of the bottom slider, passed in from outside, there is no default value
         */
        self.sliderViewColor = self.sliderViewColor ? self.sliderViewColor : Base_Orange;
        /*
         button选中的颜色
         button selected color
         */
        self.selectedColor = self.selectedColor? self.selectedColor : Base_Orange;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _pageScrollView.contentSize = CGSizeMake(_pageCount*ScreenWidth, self.frame.size.height);
    if (hiddenHeader) {
        _pageScrollView.frame = CGRectMake(0, 0, ScreenWidth, self.frame.size.height+NV_STATUSBARHEIGHT+NV_NAV_BAR_HEIGHT);
    }else{
        _pageScrollView.frame = CGRectMake(0, 43, ScreenWidth, self.frame.size.height+NV_STATUSBARHEIGHT+NV_NAV_BAR_HEIGHT);
    }
    
}

#pragma mark 创建视图  Create view
-(void)createView:(NSArray *)titleArr andViewArr:(NSArray *)viewArr andRootVc:(UIViewController *)rootVC hiddenHeader:(BOOL)header
{
    hiddenHeader = header;
    _pageCount = viewArr.count;
    /*
     当前的选中下标
     Current selected subscript
     */
    _currentSelectIndex = 0;
    /*
     滑动的底部视图
     Sliding bottom view
     */
    _pageScrollView = ({
        UIScrollView *view = [UIScrollView new];
        view.pagingEnabled = YES;
        view.contentSize = CGSizeMake(titleArr.count*ScreenWidth, ScreenHeight);
        if (header) {
            view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        }else{
            view.frame = CGRectMake(0, 43, ScreenWidth, ScreenHeight);
        }
        
        view.showsVerticalScrollIndicator = NO;
        view.showsHorizontalScrollIndicator = NO;
        view.bounces = NO;
        view.delegate = self;
        view;
    });
    
    [self addSubview:_pageScrollView];

    /*
     存放按钮的数组 --  方便在滑动时修改他的选中颜色
     Store the array of buttons-it is convenient to modify his selected color when sliding
     */
    _buttonViewArr = [NSMutableArray array];
    
    /*
     滑块的宽度
     The width of the slider
     */
    _width = ScreenWidth/titleArr.count;
    
    /*
     遍历外部传入的标题数组  创建顶部button
     Traverse the header array passed in from outside to create the top button
     */
    for (int i = 0; i<titleArr.count; i++) {
        
        UIButton *funcBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [funcBtn setTitle:titleArr[i] forState:UIControlStateNormal];
        
        [funcBtn setTitleColor:self.selectedColor forState:UIControlStateSelected];
        
        [funcBtn setTitleColor:self.titileColror forState:UIControlStateNormal];
        
        funcBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [funcBtn addTarget:self action:@selector(changeAnimation:) forControlEvents:UIControlEventTouchUpInside];
        
        funcBtn.tag = i;
        
        funcBtn.frame = CGRectMake(i*_width, 0, _width, 40);
        
        [self addSubview:funcBtn];
        
        UIViewController *contr=viewArr[i];
        
        UIView *childDrenView =contr.view;
        
        if (header) {
           childDrenView.frame = CGRectMake(i*ScreenWidth, 0, ScreenWidth, self.frame.size.height);
        }else{
            childDrenView.frame = CGRectMake(i*ScreenWidth, 0, ScreenWidth, self.frame.size.height-43);
        }
        
        childDrenView.tag =  i;
        
        [rootVC addChildViewController:contr];
        
        [contr didMoveToParentViewController:rootVC];
        
        [_pageScrollView addSubview:childDrenView];
        
        [_buttonViewArr addObject:funcBtn];
        
        if (header) {
            funcBtn.hidden = YES;
        }
    }
    
    _lineView = [UIView new];
    UIButton *firstBtn = _buttonViewArr.firstObject;
    
    firstBtn.selected = YES;
    
    _currentSelectIndex = 0;
    
    _lineView.frame = CGRectMake(0, 40, _width, 2);

    _lineView.center = CGPointMake(firstBtn.center.x, 40);
    
    _lineView.backgroundColor = self.sliderViewColor;
    if (header) {
        _lineView.hidden = YES;
    }
    [self addSubview:_lineView];
        
}

#pragma mark SCrollViewDelegate
/*
 滑动代理事件，滑动时修改按钮的选中位置 和  修改滑块的位置  和 修改页面
 Sliding proxy event, modify the selected position of the button when sliding and modify the position of the slider and modify the page
 */
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger currentAdPage;
    
    currentAdPage= (*targetContentOffset).x/_pageScrollView.bounds.size.width;
    
    [self scrollToIndex:currentAdPage];
}

#pragma mark - TapAction
/*
 手动点击滑块时执行的方法  包括页面、滑动条、顶部按钮的切换
 The method to be executed when the slider is manually clicked, including the switching of pages, sliders, and top buttons
 */
-(void)changeAnimation:(UIButton *)sender
{
    
    NSInteger index = (NSInteger)sender.tag;
        
    self->_pageScrollView.contentOffset = CGPointMake(index * self->_pageScrollView.frame.size.width, 0);
 
    [self scrollToIndex:index];

}

/*
 统一方法  滑动到指定页面
 Unified method Swipe to the specified page
 */
-(void)scrollToIndex:(NSInteger)index {
    UIButton *selectBtn = _buttonViewArr[index];
    
    UIButton *lastSelectBtn = _buttonViewArr[_currentSelectIndex];
    
    
    lastSelectBtn.selected = NO;
    
    _currentSelectIndex = index;
    selectBtn.selected = YES;
    
    [UIView animateWithDuration:0.15 animations:^{
        
        CGPoint center = self->_lineView.center;
        
        center.x = selectBtn.center.x;
        
        self->_lineView.center = center;

    } completion:^(BOOL finished) {
        if ([self->_delegate respondsToSelector:@selector(sliderViewAndReloadData:)]) {
            [self->_delegate sliderViewAndReloadData:index];
        }

    }];
}
#pragma mark - 外部滑动的方法 主动调用 Active method invocation of external sliding
-(void)sliderToViewIndex:(NSInteger)index {
    self->_pageScrollView.contentOffset = CGPointMake(index * self->_pageScrollView.frame.size.width, 0);
    [self scrollToIndex:index];
}

@end
