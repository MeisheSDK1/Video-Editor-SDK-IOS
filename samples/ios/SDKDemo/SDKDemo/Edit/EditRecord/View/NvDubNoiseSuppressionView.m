//
//  NvDubNoiseSuppressionView.m
//  SDKDemo
//
//  Created by Meishe on 2022/9/9.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvDubNoiseSuppressionView.h"
#import "NvNoiseSuppressionCell.h"
#import "NvBaseModel.h"
@interface NvDubNoiseSuppressionView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray <NvBaseModel *>*dataArr;
@end
@implementation NvDubNoiseSuppressionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.dataArr = [NSMutableArray array];
        _selectedIndex = 0;
        NSArray *imgArr = @[@"NvNoiseSuppression_none",@"NvNoiseSuppression_1",@"NvNoiseSuppression_2",@"NvNoiseSuppression_3",@"NvNoiseSuppression_4"];
        for (NSString *imageName in imgArr) {
            NvBaseModel *model = [NvBaseModel new];
            model.coverName = imageName;
            if ([imageName isEqualToString:@"NvNoiseSuppression_none"]) {
                model.selected = YES;
            }else {
                model.selected = NO;
            }
            [self.dataArr addObject:model];
        }
        
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];

        self.okButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
        [self addSubview:self.okButton];
        [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(@(-15*SCREENSCALE));
            }
            make.centerX.equalTo(self);
            make.width.equalTo(@(SCREENWIDTH));
            make.height.equalTo(@(20*SCREENSCALE));
        }];
        __weak typeof(self)weakSelf = self;
        [self.okButton nv_BtnClickHandler:^{
            if ([weakSelf.delegate respondsToSelector:@selector(noiseSuppressionViewdidAddOkClick)]) {
                [weakSelf.delegate noiseSuppressionViewdidAddOkClick];
            }
        }];

        self.line = [UIView new];
        self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
        [self addSubview:self.line];
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@1);
            make.bottom.equalTo(self.okButton.mas_top).offset(-12*SCREENSCALE);
        }];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(32*SCREENSCALE, 32*SCREENSCALE);
        layout.minimumInteritemSpacing= 36*SCREENSCALE;
        layout.minimumLineSpacing = (SCREENWIDTH - 130*SCREENSCALE - 32*5*SCREENSCALE)/4 ;
        layout.sectionInset = UIEdgeInsetsMake(0, 65.5*SCREENSCALE, 0, 65.5*SCREENSCALE);
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 175 * SCREENSCALE) collectionViewLayout:layout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.collectionView registerClass:[NvNoiseSuppressionCell class] forCellWithReuseIdentifier:@"NvNoiseSuppressionCell"];
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(40*SCREENSCALE);
            make.bottom.equalTo(self.line.mas_top).offset(-30.f*SCREENSCALE);
        }];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvNoiseSuppressionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvNoiseSuppressionCell" forIndexPath:indexPath];
    [cell renderCellWithModel:self.dataArr[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvBaseModel *model in self.dataArr) {
        model.selected = NO;
    }
    NvBaseModel *model = self.dataArr[indexPath.item];
    model.selected = YES;
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(noiseSuppressionView:selectIndex:)]) {
        [self.delegate noiseSuppressionView:self selectIndex:indexPath.item];
    }
}

#pragma mark - setter
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    if (selectedIndex < self.dataArr.count) {
        for (NvBaseModel *model in self.dataArr) {
            model.selected = NO;
        }
        NvBaseModel *selectedModel = self.dataArr[selectedIndex];
        selectedModel.selected = YES;
        [self.collectionView reloadData];
        if ([self.delegate respondsToSelector:@selector(noiseSuppressionView:selectIndex:)]) {
            [self.delegate noiseSuppressionView:self selectIndex:selectedIndex];
        }
    }
}
@end
