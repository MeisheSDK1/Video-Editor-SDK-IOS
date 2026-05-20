//
//  NvCompoundCaptionStyleView.m
//  SDKDemo
//
//  Created by MS on 2019/5/16.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvCompoundCaptionStyleView.h"
#import "NvCompoundCaptionCell.h"

@interface NvCompoundCaptionStyleView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIButton *moreButton;
@property(nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation NvCompoundCaptionStyleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.dataSource = [NSMutableArray array];
        [self initSubviews];
        
    }
    return self;
}

- (void)initSubviews {
    __weak typeof(self)weakSelf = self;
    self.moreButton = [UIButton nv_buttonWithTitle:@"" textColor:nil fontSize:-1 image:nil];
    [self.moreButton setBackgroundImage:NvImageNamed(@"NvsFilterMore") forState:UIControlStateNormal];
    [self addSubview:self.moreButton];
    [self.moreButton nv_BtnClickHandler:^{
        if ([weakSelf.delegate respondsToSelector:@selector(moreStyleClick)]) {
            [weakSelf.delegate moreStyleClick];
        }
    }];
    
    [self addSubview:self.collectionView];
    [self.collectionView registerClass:[NvCompoundCaptionCell class] forCellWithReuseIdentifier:@"NvStyleCollectionViewCell"];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    
    UIView *bottomLine = [UIView new];
    bottomLine.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-70*SCREENSCALEHEIGHT);
        } else {
            make.bottom.equalTo(@(-70*SCREENSCALEHEIGHT));
        }
    }];
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(13*SCREENSCALE));
        make.bottom.equalTo(bottomLine.mas_top).offset(-60*SCREENSCALE);
        make.width.equalTo(@(35*SCREENSCALE));
        make.height.equalTo(@(25*SCREENSCALE));
    }];
    
    UILabel *moreLabel = [[UILabel alloc] init];
    [self addSubview:moreLabel];
    moreLabel.font = [UIFont systemFontOfSize:12*SCREENSCALE];
    moreLabel.textColor = [UIColor whiteColor];
    moreLabel.numberOfLines = 2;
    moreLabel.text = NvLocalString(@"More", @"更多");
    moreLabel.textAlignment = NSTextAlignmentCenter;
    
    [moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.collectionView.mas_bottom).offset(-5*SCREENSCALE);
        make.left.right.equalTo(self.moreButton);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.moreButton.mas_right).offset(18*SCREENSCALE);
        make.right.equalTo(@(0));
        make.height.equalTo(@(88*SCREENSCALE));
        make.bottom.equalTo(bottomLine.mas_top).offset(-13*SCREENSCALE);
    }];
}
- (void)reloadData{
    [self.collectionView reloadData];
}
///刷新列表用于外界设置默认数据
///The refresh list is used to set default data for the outside world
- (void)renderListWithItems:(NSMutableArray <NvCaptionStyleItem *>*)dataSource {
    self.dataSource = dataSource;
    [self.collectionView reloadData];
    self.currentItem = nil;
    for (int i = 0; i < dataSource.count; i++) {
        NvCaptionStyleItem *item = self.dataSource[i];
        if (item.isSelect) {
            self.currentItem = item;
        }
    }
}

#pragma mark collectionDelegate & datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvCompoundCaptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvStyleCollectionViewCell" forIndexPath:indexPath];
    [cell renderCellWithItem:self.dataSource[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvCaptionStyleItem *item in self.dataSource) {
        item.isSelect = NO;
    }

    NvCaptionStyleItem *item = self.dataSource[indexPath.item];
    item.isSelect = YES;

    self.currentItem = item;
    if ([self.delegate respondsToSelector:@selector(selectStyle:isApplyToAllCaption:)]) {
        [self.delegate selectStyle:self.currentItem isApplyToAllCaption:NO];
    }
    [self.collectionView reloadData];
}

#pragma mark - lazyload
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(77*SCREENSCALE, 86*SCREENSCALE);
        flowLayout.minimumLineSpacing = 8*SCREENSCALE;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
       
    }
    return  _collectionView;
}


@end
