//
//  NvMimoAlbumCustomBottomView.m
//  AFNetworking
//
//  Created by meishe20241218 on 2025/6/27.
//

#import "NvMimoAlbumCustomBottomView.h"
#import "NVMimoDefineConfig.h"
#import "NvMimoUtils.h"
#import "NvPreviewCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/NVDefineConfig.h>

@interface NvMimoAlbumCustomBottomView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *bottomCollectionView;
@property (nonatomic, strong) UIButton *nextButton;
@end

@implementation NvMimoAlbumCustomBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.bottomCollectionView registerClass:[NvPreviewCollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
        [self addSubview:self.bottomCollectionView];
        self.bottomCollectionView.frame = CGRectMake(12*SCREANSCALE,0, SCREANWIDTH-69*SCREANSCALE, 64*SCREANSCALE + INDICATOR);
        
        self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.nextButton.backgroundColor = [UIColor nv_colorWithHexRGB:@"#2A7DFF"];
        self.nextButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
        [self.nextButton setTitle:NvLocalStringFromTableInBundle( @"Next", @"Localizable", [NSBundle bundleForClass:self.class], @"下一步") forState:UIControlStateNormal];
        [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.nextButton.titleLabel.numberOfLines = 2;
        self.nextButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.nextButton.contentEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 3);
        [self addSubview:self.nextButton];
        [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(19/2*SCREANSCALE + INDICATOR/2);
            make.height.mas_equalTo(45*SCREANSCALE);
            make.width.mas_equalTo(45*SCREANSCALE);
            make.right.equalTo(self.mas_right).offset(-12*SCREANSCALE);
        }];
        [self.nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#1A1D24"];
    }
    return self;
}

- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bottomCollectionView reloadData];
    });
    
}

- (void)nextButtonClicked:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(nvMimoAlbumCustomBottomViewClickFinishButton:)]) {
        [self.delegate nvMimoAlbumCustomBottomViewClickFinishButton:self];
    }
}

// MARK: UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    NvPreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A4A4A"];
    cell.model = self.videoArr[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(nvMimoAlbumCustomBottomView:selectItemIndex:)]) {
        [self.delegate nvMimoAlbumCustomBottomView:self selectItemIndex:indexPath.item];
    }
}

#pragma mark - setter
- (void)setTargetIndex:(NSInteger)targetIndex {
    _targetIndex = targetIndex;

    NvPreviewCollectionViewCell *cell = (NvPreviewCollectionViewCell *)[self.bottomCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0]];
    BOOL scrollIndicator = [self.bottomCollectionView.visibleCells containsObject:cell];
    if (!scrollIndicator) {
        [self.bottomCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

#pragma mark - lazyload
- (UICollectionView *)bottomCollectionView {
    if (!_bottomCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(45*SCREANSCALE, 45*SCREANSCALE);
        flowLayout.minimumLineSpacing = 14*SCREANSCALE;
        _bottomCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _bottomCollectionView.delegate = self;
        _bottomCollectionView.dataSource = self;
        _bottomCollectionView.contentInset = UIEdgeInsetsMake(0, 12*SCREANSCALE, 0, 0);
        _bottomCollectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#1A1D24"];
    }
    return  _bottomCollectionView;
}

@end
