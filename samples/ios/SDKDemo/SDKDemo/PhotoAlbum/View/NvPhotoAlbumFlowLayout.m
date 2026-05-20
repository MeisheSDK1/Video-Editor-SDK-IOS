//
//  NvPhotoAlbumFlowLayout.m
//  SDKDemo
//
//  Created by MS on 2019/9/24.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvPhotoAlbumFlowLayout.h"
#import "NVDefineConfig.h"
const CGFloat NvPhotoAlbumLineSpacing = 20.f;
const CGFloat NvPhotoAlbumZoomScale = 1.2f;
const CGFloat NvPhotoAlbumMinZoomScale = NvPhotoAlbumZoomScale - 1.0f;

@implementation NvPhotoAlbumFlowLayout
{
    NSInteger _index;
}

- (instancetype)init
{
    if (self == [super init]) {
        _index = 0;
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
}

- (CGSize)collectionViewContentSize
{
    return [super collectionViewContentSize];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    ///1. 获取可见区域
    ///1. Obtain the visible area
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    ///2. 获得这个区域的item
    ///2. Get the item for this area
    NSArray *visibleItemArray = [super layoutAttributesForElementsInRect:visibleRect];
    
    ///3. 遍历，让靠近中心线的item方法，离开的缩小
    ///3. Traversal, let the item method near the center line, leave to shrink
    for (UICollectionViewLayoutAttributes *attributes in visibleItemArray)
    {
        ///1. 获取每个item距离可见区域左侧边框的距离 有正负
        ///1. Get the positive or negative distance between each item and the left border of the visible area
        CGFloat leftMargin = attributes.center.x - self.collectionView.contentOffset.x;
        ///2. 获取边框距离屏幕中心的距离（固定的）
        ///2. Get the border's distance from the center of the screen (fixed)
        CGFloat halfCenterX = self.collectionView.frame.size.width / 2;
        ///3. 获取距离中心的的偏移量，需要绝对值
        ///3. The absolute value is required to obtain the offset from the center
        CGFloat absOffset = fabs(halfCenterX - leftMargin);
        ///4. 获取的实际的缩放比例 距离中心越多，这个值就越小，也就是item的scale越小 中心是方法最大的
        ///4. The more the actual scale obtained from the center, the smaller the value, that is, the smaller the item scale. The center is the largest method
        CGFloat scale = 1 - absOffset / halfCenterX;
        ///5. 缩放
        ///Step 5 Scale
        attributes.transform3D = CATransform3DMakeScale(0.8 + scale * NvPhotoAlbumMinZoomScale, 0.8 + scale * NvPhotoAlbumMinZoomScale, 1);
        
        
        ///是否需要透明
        ///Whether transparency is needed
        if (self.needAlpha)
        {
            if (scale < 0.6)
            {
                attributes.alpha = 0.6;
            }
            else if (scale > 0.99)
            {
                attributes.alpha = 1.0;
            }
            else
            {
                attributes.alpha = scale;
            }
        }
    }
    NSArray *attributesArr = [[NSArray alloc] initWithArray:visibleItemArray copyItems:YES];
    return attributesArr;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    ///把collectionView本身的中心位子（固定的）,转换成collectionView整个内容上的point
    ///Convert the center position of the collectionView itself (fixed) to a point on the entire content of the collectionView
    CGPoint pInView = [self.collectionView.superview convertPoint:self.collectionView.center toView:self.collectionView];
    
    NSIndexPath *indexPathNow = [self.collectionView indexPathForItemAtPoint:pInView];
    
    if (indexPathNow.row == 0)
    {
        if (newBounds.origin.x <  SCREENWIDTH/ 2)
        {
            if (_index != indexPathNow.row)
            {
                _index = 0;
                if (self.delegate && [self.delegate respondsToSelector:@selector(collectioViewScrollToIndex:)])
                {
                    [self.delegate collectioViewScrollToIndex:_index];
                }
                
            }
        }
    }
    else
    {
        if (_index != indexPathNow.row)
        {
            _index = indexPathNow.row;
            if (self.delegate && [self.delegate respondsToSelector:@selector(collectioViewScrollToIndex:)])
            {
                [self.delegate collectioViewScrollToIndex:_index];
            }
        }
    }
    
    
    [super shouldInvalidateLayoutForBoundsChange:newBounds];
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    ///ProposeContentOffset是本来应该停下的位子
    ///ProposeContentOffset is the seat that should have been stopped
    ///1. 先给一个字段存储最小的偏移量 那么默认就是无限大
    ///1. Store the minimum offset for a field so that the default is infinity
    CGFloat minOffset = CGFLOAT_MAX;
    ///2. 获取到可见区域的centerX
    ///2. Obtain the centerX of the visible area
    CGFloat horizontalCenter = proposedContentOffset.x + self.collectionView.bounds.size.width / 2;
    ///3. 拿到可见区域的rect
    ///3. Get the rect of the visible area
    CGRect visibleRec = CGRectMake(proposedContentOffset.x, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    ///4. 获取到所有可见区域内的item数组
    ///4. Get the item array in all visible fields
    NSArray *visibleAttributes = [super layoutAttributesForElementsInRect:visibleRec];
    
    ///遍历数组，找到距离中心最近偏移量是多少
    ///Go through the array and find out what the nearest offset from the center is
    for (UICollectionViewLayoutAttributes *atts in visibleAttributes)
    {
        ///可见区域内每个item对应的中心X坐标
        ///The central X coordinate corresponding to each item in the area is visible
        CGFloat itemCenterX = atts.center.x;
        ///比较是否有更小的，有的话赋值给minOffset
        ///Compare if there is a smaller one, and assign it to minOffset if there is
        if (fabs(itemCenterX - horizontalCenter) <= fabs(minOffset)) {
            minOffset = itemCenterX - horizontalCenter;
        }
        
    }
    /*
     这里需要注意的是  上面获取到的minOffset有可能是负数，那么代表左边的item还没到中心，如果确定这种情况下左边的item是距离最近的，那么需要左边的item居中，意思就是collectionView的偏移量需要比原本更小才是，例如原先是1000的偏移，但是需要展示前一个item，所以需要1000减去某个偏移量，因此不需要更改偏移的正负
     
     但是当propose小于0的时候或者大于contentSize（除掉左侧和右侧偏移以及单个cell宽度）
     防止当第一个或者最后一个的时候不会有居中（偏移量超过了本身的宽度），直接卡在推荐的停留位置
     
     It should be noted that the minOffset obtained above may be negative, which means that the item on the left has not reached the center. If the item on the left is determined to be the closest in this case, the item on the left should be centered, which means that the offset of the collectionView should be smaller than the original one. For example, the original was an offset of 1000, but you need to display the previous item, so you need to subtract some offset from 1000, so you don't need to change the positive or negative of the offset

     But when propose less than 0 or greater than contentSize (excluding left and right offset and individual cell width)
     Prevent the first or last one from being centered (offset beyond its own width) and getting stuck directly in the recommended stop position
     */
    CGFloat centerOffsetX = proposedContentOffset.x + minOffset;
    if (centerOffsetX < 0) {
        centerOffsetX = 0;
    }
    
    if (centerOffsetX > self.collectionView.contentSize.width -(self.sectionInset.left + self.sectionInset.right + self.itemSize.width)) {
        centerOffsetX = floor(centerOffsetX);
    }
    self.targetPoint = CGPointMake(centerOffsetX, proposedContentOffset.y);
    return CGPointMake(centerOffsetX, proposedContentOffset.y);
}
@end
