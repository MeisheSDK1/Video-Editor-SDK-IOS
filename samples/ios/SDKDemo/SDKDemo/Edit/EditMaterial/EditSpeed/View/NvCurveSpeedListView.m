//
//  NvCurveSpeedListView.m
//  SDKDemo
//
//  Created by MS on 2020/11/26.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvCurveSpeedListView.h"
#import "NvCaptureFilterCell.h"
#import "NVHeader.h"

@interface NvCurveSpeedListView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray <NvCurveSpeedModel *>*dataSource;
@property (nonatomic, strong) UICollectionView *collectionView;
@end
@implementation NvCurveSpeedListView

- (instancetype)init {
    if (self = [super init]) {
        self.dataSource = [NSMutableArray array];
        self.backgroundColor = UIColorFromRGB(0x242728);
        [self initCollectionViewDatasource];
        [self addSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.dataSource = [NSMutableArray array];
        [self initCollectionViewDatasource];
        [self addSubviews];
    }
    return self;
}

- (void)initCollectionViewDatasource {
    NSArray *titleArr = @[
        NvLocalString(@"None", @"无"),
        NvLocalString(@"Custom", @"自定义"),
        NvLocalString(@"Montage" , @"蒙太奇"),
        NvLocalString(@"Hero", @"英雄时刻"),
        NvLocalString(@"Bullet", @"子弹时间"),
        NvLocalString(@"Jump", @"跳接"),
        NvLocalString(@"FlashIn" ,@"闪进"),
        NvLocalString(@"FlashOut", @"闪出")];
    NSArray *imageArr = @[@"videoClip_curve_none",
                          @"videoClip_curve_custom",
                          @"videoClip_curve_montage",
                          @"videoClip_curve_hero",
                          @"videoClip_curve_bullet",
                          @"videoClip_curve_jump",
                          @"videoClip_curve_flashIn",
                          @"videoClip_curve_flashOut"];
    NSArray *curveIdArr = @[@"none",
                            @"Custom",
                            @"Montage",
                            @"Hero",
                            @"Bullet",
                            @"Jump",
                            @"FlashIn",
                            @"FlashOut"];
    for (int i=0; i<titleArr.count; i++) {
        NvCurveSpeedModel *model = [NvCurveSpeedModel new];
        model.coverName = imageArr[i];
        model.displayName = titleArr[i];
        model.packageId = curveIdArr[i];
        if (i>0) {
            model.toEditImg = @"nv_edit_curveSpeed_custom";
            model.toEditInfo = NvLocalString(@"Click Edit", @"点击编辑");
        }
        [self.dataSource addObject:model];
    }
}

- (void)addSubviews {
    UIButton *finsh = [UIButton buttonWithType:UIButtonTypeCustom];
    [finsh setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [finsh addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:finsh];
    [finsh mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(20*SCREENSCALE));
        make.bottom.equalTo(@(-15*SCREENSCALE));
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(finsh.mas_top).offset(-12*SCREENSCALE);
    }];
    
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(line.mas_top).offset(-26 * SCREENSCALE);
        make.left.right.equalTo(self);
        make.height.offset(75 * SCREENSCALE);
        make.top.equalTo(@0);
    }];
}

- (void)finshClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(nvFinishCurveSpeedListView:)]) {
        [self.delegate nvFinishCurveSpeedListView:self];
    }
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvCaptureFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvSpeedListID" forIndexPath:indexPath];
    NvBaseModel* model = self.dataSource[indexPath.item];
    [cell renderCellWithModel:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NvBaseModel* model = self.dataSource[indexPath.item];
    ///开始编辑
    ///Start editing
    if (model.selected && model.toEdit) {
        if([self.delegate respondsToSelector:@selector(nvCurveSpeedListView:didBeginEditing:)]){
            [self.delegate nvCurveSpeedListView:self didBeginEditing:(NvCurveSpeedModel *)model];
        }
        return;
    }
    
    for (NvBaseModel* models in self.dataSource) {
        models.selected = NO;
        models.toEdit = NO;
    }
    
    model.selected = YES;
    if (indexPath.item > 0) {
        model.toEdit = YES;
    }
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(nvCurveSpeedListView:didSelectItem:)]) {
        [self.delegate nvCurveSpeedListView:self didSelectItem:(NvCurveSpeedModel *)model];
    }
}

#pragma mark - setter & getter
- (void)setSelectedCurveId:(NSString *)selectedCurveId {
    _selectedCurveId = selectedCurveId;
    if (![selectedCurveId isEqualToString:@"none"]) {
        for (NvCurveSpeedModel *model in self.dataSource) {
            if ([model.packageId isEqualToString:selectedCurveId]) {
                model.selected = YES;
                model.toEdit = YES;
            }else{
                model.selected = NO;
                model.toEdit = NO;
            }
        }
    }else{
        for (NvCurveSpeedModel *model in self.dataSource) {
            
            if ([model.packageId isEqualToString:@"none"]) {
                model.selected = YES;
                model.toEdit = NO;
            }else{
                model.selected = NO;
                model.toEdit = NO;
            }
        }
    }
    [self.collectionView reloadData];
}

#pragma mark - lazyload
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(49*SCREENSCALE, 75*SCREENSCALE);
        layout.minimumLineSpacing = 14.f*SCREENSCALE;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 12*SCREENSCALE, 0, 12*SCREENSCALE);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,SCREENWIDTH, 0) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[NvCaptureFilterCell class] forCellWithReuseIdentifier:@"NvSpeedListID"];
    }
    return _collectionView;
}
@end
