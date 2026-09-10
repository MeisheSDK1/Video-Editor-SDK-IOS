//
//  NvLivePushOperatingView.m
//  MeicamLive
//
//  Created by ms20180425 on 2020/3/16.
//  Copyright © 2020 ms20180425. All rights reserved.
//

#import "NvLivePushOperatingView.h"
#import "NvLiveFunctionCollectionCell.h"
#import "NvLiveFunctionModel.h"
#import "Masonry.h"
#import "NvLiveAppEnv.h"

@interface NvLivePushOperatingView()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NvLiveFunctionModel *currentModel;

@end

@implementation NvLivePushOperatingView

-(void)dealloc{
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dataArray = [NSMutableArray array];
        [self addMainView];
    }
    return self;
}

- (void)addMainView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(60*NvScreen(kScale), 60*NvScreen(kScale));
    layout.minimumLineSpacing = 10*NvScreen(kScale);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,0,0) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.collectionView];
    [self.collectionView registerClass:[NvLiveFunctionCollectionCell class] forCellWithReuseIdentifier:@"NvLiveFunctionCollectionCell"];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self);
    }];
}

- (void)configData:(NSMutableArray *)source{
    [self.dataArray addObjectsFromArray:source];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvLiveFunctionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvLiveFunctionCollectionCell" forIndexPath:indexPath];
    [cell renderCellWithModel:self.dataArray[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvLiveFunctionModel *model in self.dataArray) {
        model.selected = NO;
    }
    self.currentModel = self.dataArray[indexPath.item];
    self.currentModel.selected = YES;
    self.functionType = self.currentModel.functionType;
    [collectionView reloadData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pushOperatingView:withFunction:)]) {
        [self.delegate pushOperatingView:self withFunction:self.currentModel];
    }
}

@end
