//
//  NvEditMaterialLayout.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/11.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvEditMaterialLayout.h"
#import "NVDefineConfig.h"

@implementation NvEditMaterialLayout

/**
 1.cell的放大和缩小
 1. Zoom in and out of the cell
 2.停止滚动时：cell居中
 2. Stop scrolling: The cell is centered
 */

#pragma mark- 布局的初始化操作
///The initialization of the layout
///特别注意 布局的初始化操作 不要在init方法中 做布局的初始化操作
///Pay special attention to the initialization of the layout. Do not initialize the layout in the init method
-(void)prepareLayout{
    [super prepareLayout];
    /**
     1.一个cell对应一个UICollectionViewLayoutAttributes对象
     1. A cell corresponds to a UICollectionViewLayoutAttributes object
     2.UICollectionViewLayoutAttributes对象决定了cell的摆设位置（frame）
     2. UICollectionViewLayoutAttributes object determines the decoration of the cell location (frame)
     */
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat insert =(self.collectionView.frame.size.width-self.itemSize.width)/2;
    self.sectionInset =UIEdgeInsetsMake(0, insert, 0, insert);
}

/**
 *  这个方法的返回值是一个数组(数组里存放在rect范围内所有元素的布局属性)
 *  The return value of this method is an array containing the layout properties of all elements in the rect range.
 *  这个方法的返回值  决定了rect范围内所有元素的排布（frame）
 *  The return value of this method determines the frame of all elements in the rect range.
 */
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    
    ///获得super已经计算好的布局属性 只有线性布局才能使用
    ///Get super's calculated layout properties only linear layouts can be used
    NSArray * array = [super layoutAttributesForElementsInRect:rect];
    
    ///计算CollectionView最中心的x值
    ///Compute the x value at the very center of the CollectionView
    CGFloat centetX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width/2;
    for (UICollectionViewLayoutAttributes * attrs in array) {
        ///attrs.indexPath.item 表示 这个attrs对应的cell的位置
        ///Attrs.indexpa. item Indicates the location of the cell corresponding to the attrs
        ///cell的中心点x 和CollectionView最中心点的x值
        ///The center point x of the cell and the x value of the most center point of the CollectionView
        CGFloat delta = ABS(attrs.center.x - centetX);
        ///根据间距值  计算cell的缩放的比例
        ///Calculate the scale of the cell based on the spacing value
        ///这里scale 必须要 小于1
        ///The scale here has to be less than 1
        CGFloat scale = 15 * SCREENSCALE * delta/self.collectionView.frame.size.width;
        ///设置缩放比例
        ///Set the scale
        attrs.size = CGSizeMake(180 * SCREENSCALE - scale, 320 * SCREENSCALE - 26 * SCREENSCALE * scale / 15 * SCREENSCALE);
        attrs.alpha = 1 - ABS(delta/self.collectionView.frame.size.width);
        attrs.center = CGPointMake(attrs.center.x, attrs.center.y + (26 * SCREENSCALE * scale / 15 * SCREENSCALE)/2);
        [_delegate nvEditMaterialLayout:self uiCollectionViewLayoutAttributes:attrs];
    }
    return array;
}

/*!
 *  多次调用 只要滑出范围就会 调用
 *  当CollectionView的显示范围发生改变的时候，是否重新发生布局
 *  一旦重新刷新 布局，就会重新调用
 *  1.layoutAttributesForElementsInRect：方法
 *  2.preparelayout方法
 *
 * Call multiple times as soon as you slide out of scope
 * Whether the layout is reconfigured when the display range of the CollectionView changes
 * is called again as soon as the layout is refreshed
 * 1. LayoutAttributesForElementsInRect: method
 * 2.preparelayout method
 */
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

/**
 *  只要手一松开就会调用
 *  这个方法的返回值，就决定了CollectionView停止滚动时的偏移量
 *  proposedContentOffset这个是最终的 偏移量的值 但是实际的情况还是要根据返回值来定
 *  velocity  是滚动速率  有个x和y 如果x有值 说明x上有速度
 *  如果y有值 说明y上又速度 还可以通过x或者y的正负来判断是左还是右（上还是下滑动）  有时候会有用
 *
 *  It's called as soon as you release your hand
 *  The value returned by this method determines the offset when the CollectionView stops scrolling
 *  proposedContentOffset This is the value of the final offset but the actual case depends on the return value
 *  velocity is the rolling rate and it has an x and a y and if x has a value it means there is a velocity on x
 *  If y has a value, it means that y has a velocity. It can also be used to determine whether x or y is moving left or right (up or down)
 */
-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    ///计算出最终显示的矩形框
    ///Calculate the final rectangular box
    CGRect rect;
    rect.origin.x =proposedContentOffset.x;
    rect.origin.y=0;
    rect.size=self.collectionView.frame.size;

    NSArray * array = [super layoutAttributesForElementsInRect:rect];
    ///这里的计算和上面的计算不一样的
    ///The calculation here is not the same as the calculation above
    ///计算CollectionView最中心点的x值 这里要求 最终的 要考虑惯性
    ///We're going to compute the x value at the very center of the CollectionView and we're going to have to take into account the inertia
    CGFloat centerX = self.collectionView.frame.size.width /2+ proposedContentOffset.x;
    ///存放的最小间距
    ///Minimum space for storage
    CGFloat minDelta = MAXFLOAT;
    for (UICollectionViewLayoutAttributes * attrs in array) {
        if (ABS(minDelta)>ABS(attrs.center.x-centerX)) {
            minDelta=attrs.center.x-centerX;
        }
    }
    ///修改原有的偏移量
    ///Modify the original offset
    proposedContentOffset.x+=minDelta;
    ///如果返回的时zero 那个滑动停止后 就会立刻回到原地
    ///If you go back to zero, the slide stops and it goes right back to where it was
    return proposedContentOffset;
}


@end
