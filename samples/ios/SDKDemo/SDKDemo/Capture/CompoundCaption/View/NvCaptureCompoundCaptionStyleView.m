//
//  NvCompoundCaptionStyleView.m
//  SDKDemo
//
//  Created by ms on 2021/6/29.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvCaptureCompoundCaptionStyleView.h"
#import "NvCompoundCaptionStyleCell.h"
#import "NvCaptureStickerMoreStyleCell.h"
#import "NvAssetCellModel.h"

@interface NvCaptureCompoundCaptionStyleView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, strong) UICollectionView *collectionView;

@end

@implementation NvCaptureCompoundCaptionStyleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#ffffff"];

        [self initSubviews];
        
    }
    return self;
}

- (void)initSubviews {

    [self addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(0.0f);
        make.left.mas_equalTo(self).offset(15.0);
        make.right.mas_equalTo(self).offset(-15.0);
        make.bottom.mas_equalTo(self).offset(0);
    }];
    [self.collectionView registerClass:[NvCompoundCaptionStyleCell class] forCellWithReuseIdentifier:@"NvCompoundCaptionStyleCell"];
    [self.collectionView registerClass:[NvCaptureStickerMoreStyleCell class] forCellWithReuseIdentifier:@"NvCaptureStickerMoreStyleCell"];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    
}

-(void)setItems:(NSArray *)items{
    _items = items;
    [self.collectionView reloadData];
}

-(void)cancleSelectedWithCaption:(NvCompoundCaptionInfoModel *)model{
    for (NvCaptionStyleItem *item in self.items) {
        if ([item.packageId isEqualToString:model.packageId]) {
            item.isSelect = YES;
        }else{
            item.isSelect = NO;
        }
    }
    [self.collectionView reloadData];
}

#pragma mark collectionDelegate & datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        NvCaptureStickerMoreStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvCaptureStickerMoreStyleCell" forIndexPath:indexPath];
        return cell;
    }else{
        NvCompoundCaptionStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvCompoundCaptionStyleCell" forIndexPath:indexPath];
        cell.assetModel = self.items[indexPath.item];
        return cell;
    }
   
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == 0) {
        if (self.selectMoreItemClick) {
            self.selectMoreItemClick();
        }
        return;
    }
    
    for (NvCaptionStyleItem *item in self.items) {
        item.isSelect = NO;
    }

    NvCaptionStyleItem *item = self.items[indexPath.item];
    item.isSelect = YES;

    if (self.selectItemClick) {
        self.selectItemClick(item);
    }
    [self.collectionView reloadData];
}

#pragma mark - lazyload
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.itemSize = CGSizeMake(75*SCREENSCALE, 75*SCREENSCALE);
        flowLayout.minimumLineSpacing = 15*SCREENSCALE;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#ffffff"];
    }
    return  _collectionView;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{

    return UIEdgeInsetsMake(10, 0, 0, 0);
}
@end

