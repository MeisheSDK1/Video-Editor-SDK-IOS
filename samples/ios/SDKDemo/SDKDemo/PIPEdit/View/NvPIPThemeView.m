//
//  NvPIPThemeView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/16.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvPIPThemeView.h"
#import "NvPIPThemeCell.h"
#import "NvPIPThemeItem.h"
#import "NVHeader.h"

@interface NvPIPThemeView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *pipCollectionView;

@end

@implementation NvPIPThemeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = KScale6s(50);
        layout.itemSize = CGSizeMake(70*SCREENSCALE, 90*SCREENSCALE);
        self.pipCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.pipCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.pipCollectionView.delegate = self;
        self.pipCollectionView.dataSource = self;
        self.pipCollectionView.backgroundColor = [UIColor clearColor];
        [self.pipCollectionView registerClass:[NvPIPThemeCell class] forCellWithReuseIdentifier:@"NvPIPThemeCell"];
        [self addSubview:self.pipCollectionView];
        
        [self.pipCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(KScale6s(310));
            make.height.mas_equalTo(KScale6s(90));
        }];
        
        UIButton *finshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [finshBtn setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
        [finshBtn addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:finshBtn];
        [finshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
              
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(KScale6s(30));
            make.height.mas_equalTo(KScale6s(30));
            make.bottom.equalTo(self.mas_bottom).offset(-KScale6s(10));
        }];
    }
    return self;
}

- (void)setDataSource:(NSMutableArray *)dataSource {
    _dataSource = dataSource;
    [self.pipCollectionView reloadData];
}

- (void)finshClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(nvPIPThemeViewOkClick:)]) {
        [self.delegate nvPIPThemeViewOkClick:self];
    }
}

- (void)applyTemplate:(NvPIPThemeItem *)item {
    if ([self.delegate respondsToSelector:@selector(nvPIPThemeView:applyTemplate:)]) {
        [self.delegate nvPIPThemeView:self applyTemplate:item];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvPIPThemeCell *cell = [self.pipCollectionView dequeueReusableCellWithReuseIdentifier:@"NvPIPThemeCell" forIndexPath:indexPath];
    NvPIPThemeItem *item = self.dataSource[indexPath.item];
    [cell renderCellWithItem:item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvPIPThemeItem *item in self.dataSource) {
        item.isSelect = NO;
    }
    NvPIPThemeItem *item = self.dataSource[indexPath.item];
    item.isSelect = YES;
    [self applyTemplate:item];
    [self.pipCollectionView reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
