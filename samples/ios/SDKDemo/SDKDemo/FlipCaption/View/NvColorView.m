//
//  NvColorView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvColorView.h"
#import "NvColorCollectionViewCell.h"
#import "NVHeader.h"

@interface NvColorView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray <NvCaptionColorItem *>*dataSource;

@end

@implementation NvColorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(25*SCREENSCALE, 25*SCREENSCALE);
        flowLayout.minimumLineSpacing = 29*SCREENSCALE;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        [self addSubview:self.collectionView];
        [self.collectionView registerClass:[NvColorCollectionViewCell class] forCellWithReuseIdentifier:@"NvColorCollectionViewCell"];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(13*SCREENSCALE);
            make.bottom.equalTo(self.mas_bottom).offset(0*SCREENSCALE);
            make.top.equalTo(self).offset(0*SCREENSCALE);
            make.right.equalTo(@(-13*SCREENSCALE));
            make.height.equalTo(@(25*SCREENSCALE));
        }];
        
        self.dataSource = [NSMutableArray new];
        [[NvUtils captionColors] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NvCaptionColorItem *item = [NvCaptionColorItem new];
            item.isSelect = NO;
            item.colorString = obj;
            [self.dataSource addObject:item];
        }];
        [self.collectionView reloadData];
    }
    return self;
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvColorCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvColorCollectionViewCell" forIndexPath:indexPath];
    NvCaptionColorItem *item = self.dataSource[indexPath.item];
    [cell renderCellWithItem:item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvCaptionColorItem *item in self.dataSource) {
        item.isSelect = NO;
    }
    NvCaptionColorItem *item = self.dataSource[indexPath.item];
    item.isSelect = YES;
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(colorView:didSelectItem:)]) {
        [self.delegate colorView:self didSelectItem:item];
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
