//
//  NvCaptureStickerStyleView.m
//  SDKDemo
//
//  Created by ms on 2021/6/25.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvCaptureStickerStyleView.h"
#import "NvCaptureStickerStyleCell.h"
#import "NvCaptureStickerMoreStyleCell.h"
#import "NvAssetCellModel.h"

@interface NvCaptureStickerStyleView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIButton *allBtn;
@property (nonatomic, strong) UIView *allLine;
@property (nonatomic, strong) UIButton *customBtn;
@property (nonatomic, strong) UIView *customLine;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UICollectionView *customCollectionView;

@end

@implementation NvCaptureStickerStyleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];

        [self initSubviews];
        
    }
    return self;
}

- (void)initSubviews {
    self.allBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.allBtn setTitle:NvLocalString(@"All", @"全部") forState:UIControlStateNormal];
    [self.allBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#656565"] forState:UIControlStateNormal];
    self.allBtn.selected = YES;
    [self.allBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#63ABFF"] forState:UIControlStateSelected];
    self.allBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.allBtn addTarget:self action:@selector(allBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.allBtn];
    [self.allBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.0 * SCREENSCALE);
        make.top.mas_equalTo(10.0 *SCREENSCALE);
        make.width.mas_equalTo(30.0 * SCREENSCALE);
        make.height.mas_equalTo(16.0 * SCREENSCALE);
    }];
    self.allLine = [[UIView alloc] init];
    self.allLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"];
    [self addSubview:self.allLine];
    [self.allLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.allBtn.mas_bottom).offset(2.0 * SCREENSCALE);
        make.centerX.mas_equalTo(self.allBtn.mas_centerX);
        make.width.mas_equalTo(20.0 * SCREENSCALE);
        make.height.mas_equalTo(1.0 * SCREENSCALE);
    }];
    
    self.customBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.customBtn setTitle:NvLocalString(@"Custom", @"自定义") forState:UIControlStateNormal];
    [self.customBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#656565"] forState:UIControlStateNormal];
    [self.customBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#63ABFF"] forState:UIControlStateSelected];
    self.customBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.customBtn addTarget:self action:@selector(customBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.customBtn];
    self.customBtn.selected = NO;
    [self.customBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.allBtn).offset(40.0 * SCREENSCALE);
        make.top.mas_equalTo(10.0 *SCREENSCALE);
        make.width.mas_equalTo(45.0 * SCREENSCALE);
        make.height.mas_equalTo(16.0 * SCREENSCALE);
    }];
    self.customLine = [[UIView alloc] init];
    self.customLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"];
    self.customLine.hidden = YES;
    [self addSubview:self.customLine];
    [self.customLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.customBtn.mas_bottom).offset(2.0 * SCREENSCALE);
        make.centerX.mas_equalTo(self.customBtn.mas_centerX);
        make.width.mas_equalTo(20.0 * SCREENSCALE);
        make.height.mas_equalTo(1.0 * SCREENSCALE);
    }];
    
    
    [self addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.allLine).offset(5.0f);
        make.left.mas_equalTo(self).offset(15.0);
        make.right.mas_equalTo(self).offset(-15.0);
        make.bottom.mas_equalTo(self).offset(0);
    }];
    [self.collectionView registerClass:[NvCaptureStickerStyleCell class] forCellWithReuseIdentifier:@"NvStyleCollectionViewCell"];
    [self.collectionView registerClass:[NvCaptureStickerMoreStyleCell class] forCellWithReuseIdentifier:@"NvCaptureStickerMoreStyleCell"];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    
    [self addSubview:self.customCollectionView];
    self.customCollectionView.hidden = YES;
    [_customCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.allLine).offset(5.0f);
        make.left.mas_equalTo(self).offset(15.0);
        make.right.mas_equalTo(self).offset(-15.0);
        make.bottom.mas_equalTo(self).offset(0);
    }];
    [self.customCollectionView registerClass:[NvCaptureStickerStyleCell class] forCellWithReuseIdentifier:@"NvStyleCollectionViewCell"];
    [self.customCollectionView registerClass:[NvCaptureStickerMoreStyleCell class] forCellWithReuseIdentifier:@"NvCaptureStickerMoreStyleCell"];
    [self.customCollectionView setShowsHorizontalScrollIndicator:NO];
    
}

-(void)allBtnClick{
    self.allBtn.selected = YES;
    self.customBtn.selected = NO;
    self.allLine.hidden = NO;
    self.customLine.hidden = YES;
    
    self.collectionView.hidden = NO;
    self.customCollectionView.hidden = YES;
}

-(void)customBtnClick{
    self.customBtn.selected = YES;
    self.customLine.hidden = NO;
    self.allBtn.selected = NO;
    self.allLine.hidden = YES;
    
    self.collectionView.hidden = YES;
    self.customCollectionView.hidden = NO;
}

-(void)setItems:(NSArray *)items{
    _items = items;
    [self.collectionView reloadData];
}

-(void)setCustomItems:(NSArray *)customItems{
    _customItems = customItems;
    [self.customCollectionView reloadData];
}


-(void)cancleSelectedWithSticker:(NvStickerInfoModel *)model{
    for (NvAssetCellModel *item in self.items) {
        if ([item.package isEqualToString:model.packageId]) {
            item.selected = YES;
        }else{
            item.selected = NO;
        }
    }
    [self.collectionView reloadData];
}

#pragma mark collectionDelegate & datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.collectionView) {
        return self.items.count ;
    }else{
        return self.customItems.count ;
    }
    
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionView) {
        if (indexPath.item == 0) {
            NvCaptureStickerMoreStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvCaptureStickerMoreStyleCell" forIndexPath:indexPath];
            cell.assetModel = self.items[indexPath.row];
            return cell;
        }else{
            NvCaptureStickerStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvStyleCollectionViewCell" forIndexPath:indexPath];
            cell.assetModel = self.items[indexPath.row];
            return cell;
        }
    }else{
        if (indexPath.item == 0) {
            NvCaptureStickerMoreStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvCaptureStickerMoreStyleCell" forIndexPath:indexPath];
            cell.assetModel = self.customItems[indexPath.row];
            return cell;
        }else{
            NvCaptureStickerStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvStyleCollectionViewCell" forIndexPath:indexPath];
            cell.assetModel = self.customItems[indexPath.row];
            return cell;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.collectionView) {
        if (indexPath.item == 0) {
            if (self.selectMoreItemClick) {
                self.selectMoreItemClick();
            }
            return;
        }
        
        for (NvAssetCellModel *item in self.items) {
            item.selected = NO;
        }

        NvAssetCellModel *item = self.items[indexPath.item];
        item.selected = YES;

        if (self.selectItemClick) {
            self.selectItemClick(item);
        }
        [self.collectionView reloadData];
    }else{
        if (indexPath.item == 0) {
            if (self.addCustomSticker) {
                self.addCustomSticker();
            }
            return;
        }
        
        for (NvAssetCellModel *item in self.customItems) {
            item.selected = NO;
        }

        NvAssetCellModel *item = self.customItems[indexPath.item];
        item.selected = YES;

        if (self.selectItemClick) {
            self.selectItemClick(item);
        }
        [self.customCollectionView reloadData];
    }
}

#pragma mark - lazyload
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.itemSize = CGSizeMake(75*SCREENSCALE, 75*SCREENSCALE);
        flowLayout.minimumLineSpacing = 15*SCREENSCALE;
        flowLayout.minimumInteritemSpacing = 8*SCREENSCALE;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#ffffff"];
    }
    return  _collectionView;
}

- (UICollectionView *)customCollectionView {
    if (!_customCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.itemSize = CGSizeMake(75*SCREENSCALE, 75*SCREENSCALE);
        flowLayout.minimumLineSpacing = 15*SCREENSCALE;
        flowLayout.minimumInteritemSpacing = 8*SCREENSCALE;
        _customCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        
        _customCollectionView.delegate = self;
        _customCollectionView.dataSource = self;
        _customCollectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#ffffff"];
    }
    return  _customCollectionView;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 0, 0, 0);
}

@end
