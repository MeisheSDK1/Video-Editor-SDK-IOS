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
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvBaseCommon/UIColor+NvColor.h>
#import <NvBaseCommon/NvBaseUtils.h>

@interface NvPIPThemeView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *pipCollectionView;

@end

@implementation NvPIPThemeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = ((300*SCREENSCALE - 22 * SCREENSCALE)-3*49*SCREENSCALE)/2;
        layout.itemSize = CGSizeMake(49*SCREENSCALE, 78*SCREENSCALE);
        self.pipCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake((SCREENWIDTH-300*SCREENSCALE)/2, 0, 300*SCREENSCALE, frame.size.height-15*SCREENSCALE) collectionViewLayout:layout];
        self.pipCollectionView.contentInset = UIEdgeInsetsMake(0, 11*SCREENSCALE, 0, 11*SCREENSCALE);
        self.pipCollectionView.delegate = self;
        self.pipCollectionView.dataSource = self;
        [self addSubview:self.pipCollectionView];
        self.pipCollectionView.backgroundColor = [UIColor clearColor];
        [self.pipCollectionView registerClass:[NvPIPThemeCell class] forCellWithReuseIdentifier:@"NvPIPThemeCell"];
        
        UIButton *finshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [finshBtn setImage:[NvBaseUtils imageNamed:@"Nvcheck - material" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
        finshBtn.frame = CGRectMake((frame.size.width - 25 * SCREENSCALE)/2, frame.size.height-35*SCREENSCALE, 25 * SCREENSCALE, 20 * SCREENSCALE);
        [finshBtn addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:finshBtn];
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
