//
//  NvAlbumCategoryView.m
//  NvAlbum
//
//  Created by meishe20241218 on 2025/6/25.
//

#import "NvAlbumCategoryView.h"
#import "NvAlbumCategoryCell.h"

@interface NvAlbumCategoryView()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@end
@implementation NvAlbumCategoryView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
    }
    return self;
}

- (void)setAssetDataSource:(NSArray *)assetDataSource {
    _assetDataSource = assetDataSource;
    [self.collectionView reloadData];
}

- (void)addSubviews {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 12;
    flowLayout.itemSize = CGSizeMake(self.frame.size.width, 64);
    flowLayout.sectionInset = UIEdgeInsetsMake(12, 0, 44, 0);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor blackColor];
    [self.collectionView registerClass:[NvAlbumCategoryCell class] forCellWithReuseIdentifier:@"kNvAlumCategoryCellId"];
    self.collectionView.frame = self.bounds;
    [self addSubview:self.collectionView];
}

// MARK: UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetDataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvAlbumCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kNvAlumCategoryCellId" forIndexPath:indexPath];
    [cell renderCellWithAsset:self.assetDataSource[indexPath.item]];
    if (indexPath.item==0 && self.selectCount>0) {
        [cell setSelectCount:self.selectCount];
    } else {
        [cell setSelectCount:0];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if([self.delegate respondsToSelector:@selector(nvAlbumCategoryView:didSelectCellAtIndex:)]) {
        [self.delegate nvAlbumCategoryView:self didSelectCellAtIndex:indexPath.item];
    }
}

- (void)setSelectCount:(NSUInteger)selectCount {
    _selectCount = selectCount;
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.collectionView reloadData];
    });
}
@end
