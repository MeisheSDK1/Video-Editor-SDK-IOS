//
//  NvFlipCaptionFontView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvFlipCaptionFontView.h"
#import "NvBottomView.h"
#import "NVHeader.h"
#import "NvBaseAssetCell.h"
#import "NvFontCollectionViewCell.h"

@interface NvFlipCaptionFontView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NvBottomView *bottomView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NvCaptionFontItem *item;

@end

@implementation NvFlipCaptionFontView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.bottomView = [NvBottomView new];
        self.bottomView.delegate = self;
        [self addSubview:self.bottomView];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.equalTo(@(SCREENWIDTH));
            make.bottom.equalTo(self);
        }];
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(89*SCREENSCALE, 58*SCREENSCALE);
        flowLayout.minimumInteritemSpacing = 8*SCREENSCALE;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        [self addSubview:self.collectionView];
        [self.collectionView registerClass:[NvFontCollectionViewCell class] forCellWithReuseIdentifier:@"NvFontCollectionViewCell"];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(8*SCREENSCALE));
            make.bottom.equalTo(self.bottomView.mas_top).offset(-31*SCREENSCALE);
            make.right.equalTo(@(-8*SCREENSCALE));
            make.height.equalTo(@(58*SCREENSCALE));
            make.top.equalTo(@(32*SCREENSCALE));
        }];
        
        self.dataSource = [NSMutableArray new];
    }
    return self;
}

- (void)setDataSource:(NSMutableArray *)dataSource {
    _dataSource = dataSource;
    [self.collectionView reloadData];
}

- (void)updateProgress:(float)progress uuid:(NSString *)uuid {
    [self.dataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.packageId isEqualToString:uuid]) {
            obj.state = Downloading;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexpath = [NSIndexPath indexPathForItem:idx inSection:0];
                NvFontCollectionViewCell *cell = (NvFontCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexpath];
                [cell renderCellWithItem:obj];
                cell.downloadButton.status = NvDownloading;
                cell.downloadButton.progress = progress;
            });
        }
    }];
}

- (void)downloadFailduuid:(NSString *)uuid {
    [self.dataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.packageId isEqualToString:uuid]) {
            obj.state = DownloadError;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexpath = [NSIndexPath indexPathForItem:idx inSection:0];
                NvFontCollectionViewCell *cell = (NvFontCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexpath];
                [cell renderCellWithItem:obj];
                cell.downloadButton.status = NvNoDownload;
                cell.downloadButton.progress = 0;
            });
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvFontCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvFontCollectionViewCell" forIndexPath:indexPath];
    NvCaptionFontItem *item = self.dataSource[indexPath.item];
    [cell renderCellWithItem:item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NvCaptionFontItem *item = self.dataSource[indexPath.item];
    NvFontCollectionViewCell *cell = (NvFontCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell renderCellWithItem:self.dataSource[indexPath.item]];
    self.item = item;
    if ([self.delegate respondsToSelector:@selector(flipCaptionFont:didSelectItem:)]) {
        [self.delegate flipCaptionFont:self didSelectItem:self.item];
    }
}

- (void)bottomViewOkClick:(NvBottomView *)bottomView {
    if ([self.delegate respondsToSelector:@selector(flipCaptionFont:okClickItem:)]) {
        [self.delegate flipCaptionFont:self okClickItem:self.item];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
