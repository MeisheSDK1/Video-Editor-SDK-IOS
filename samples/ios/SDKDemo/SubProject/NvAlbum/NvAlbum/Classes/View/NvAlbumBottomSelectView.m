//
//  NvAlbumBottomSelectView.m
//  NvAlbum
//
//  Created by meishe20241218 on 2025/6/26.
//

#import "NvAlbumBottomSelectView.h"
#import "NvAlbumBottomSelectedCell.h"
#import "NVDefineConfig.h"
@interface NvAlbumBottomSelectView()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation NvAlbumBottomSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 8*SCREENSCALE;
    flowLayout.minimumInteritemSpacing = 12*SCREENSCALE;
    flowLayout.itemSize = CGSizeMake(54*SCREENSCALE, 54*SCREENSCALE);
    flowLayout.sectionInset = UIEdgeInsetsMake(20*SCREENSCALE, 12, 20*SCREENSCALE, 12);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[NvAlbumBottomSelectedCell class] forCellWithReuseIdentifier:@"kNvAlbumBottomSelectedCellId"];
    self.collectionView.frame = self.bounds;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.collectionView];
}

- (void)reloadData {
    [self.collectionView reloadData];
}

// MARK: UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetDataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvAlbumBottomSelectedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kNvAlbumBottomSelectedCellId" forIndexPath:indexPath];
    [cell renderCellWithAsset:self.assetDataSource[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(nvAlbumBottomSelectView:selectItem:)]) {
        [self.delegate nvAlbumBottomSelectView:self selectItem:indexPath.item];
    }
}
@end
