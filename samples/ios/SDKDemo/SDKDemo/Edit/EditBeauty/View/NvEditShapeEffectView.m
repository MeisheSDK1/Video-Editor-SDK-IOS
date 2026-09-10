//
//  NvEditShapeEffectView.m
//  SDKDemo
//
//  Created by Meishe on 2022/11/21.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvEditShapeEffectView.h"
#import "NvBeautyTypeCViewCell.h"
#import "NvBeautyIntervalCell.h"
#import "NvSwitchView.h"

@interface NvEditShapeEffectView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *resetBtn;
@property (nonatomic, strong) NvSwitchView *beautySwitch;
@property (nonatomic, strong) UILabel *beautyLabel;
@property (nonatomic, strong) NSMutableArray *originalDataSource;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NvBeautyTypeModel *currentModel;

@property (nonatomic, strong) UIView *overlayView;
@end

@implementation NvEditShapeEffectView
- (instancetype)init {
    if (self = [super init]) {
        self.dataSource = [NSMutableArray array];
        self.originalDataSource = [NSMutableArray array];
        [self addSubviews];
    }
    return self;
}

#pragma mark - 数据 data
- (void)updateData:(NSArray <NvBeautyTypeModel *>*)dataSource showTemporaryData:(BOOL)temporary {
    if (temporary) {
        //临时数据 Temporary data
        for(NvBeautyTypeModel *model in dataSource) {
            for(NvBeautyTypeModel *item in self.dataSource) {
                if ((item.fxName.length > 0 && [item.fxName isEqualToString:model.fxName]) || (item.degreeName.length > 0 && [item.degreeName isEqualToString:model.degreeName])) {
                    item.value = model.value;
                    item.extValue = model.extValue;
                    item.uuid = model.uuid;
                    item.canReplace = model.canReplace;
                    break;
                }
            }
        }
        
    }else {
        [self updateData:dataSource];
    }
}

- (void)updateData:(NSArray <NvBeautyTypeModel *>*)dataSource {
    [self.dataSource addObjectsFromArray:dataSource];
    self.originalDataSource = [[NSMutableArray alloc] initWithArray:dataSource copyItems:YES];
    
    [self.collectionView reloadData];
}

#pragma mark - 设置所有效果 Set all effects
//恢复原有效果 Restore original effect
- (void)reapplyAppliedEffects:(BOOL)needRefreshView refreshData:(BOOL)needRefreshData {
    if ([self.delegate respondsToSelector:@selector(nvEditShapeEffectView:selecteModel:refreshView:refreshData:)]) {
        for(NvBeautyTypeModel *model in self.dataSource) {
            if (needRefreshView && [model.fxName isEqualToString:self.currentModel.fxName]) {
                [self.delegate nvEditShapeEffectView:self selecteModel:model refreshView:YES refreshData:YES];
            }else{
                [self.delegate nvEditShapeEffectView:self selecteModel:model refreshView:NO refreshData:needRefreshData];
            }
        }
    }
}

//所有效果全部置为零 All effects are set to zero
- (void)setZeroToAllEffectStrength:(BOOL)needRefreshView refreshData:(BOOL)needRefreshData {
    if ([self.delegate respondsToSelector:@selector(nvEditShapeEffectView:selecteModel:refreshView:refreshData:)]) {
        for(NvBeautyTypeModel *model in self.originalDataSource) {
            NvBeautyTypeModel *newM = [NvBeautyTypeModel new];
            for(NvBeautyTypeModel *item in self.dataSource) {
                if ([model.name isEqualToString:item.name]) {
                    newM.value = model.value;
                    newM.extValue = model.extValue;
                    newM.fxName = model.fxName;
                    newM.uuid = item.uuid;
                    newM.degreeName = model.degreeName;
                    newM.canReplace = model.canReplace;
                    break;
                }
            }
            [self.delegate nvEditShapeEffectView:self selecteModel:newM refreshView:needRefreshView refreshData:needRefreshData];
        }
    }
}

- (void)refreshData{
    
}

#pragma mark - 界面 interface
- (void)addSubviews {
    CGFloat topTemp = 0;
    CGFloat heightTemp = 73 * SCREENSCALE;
    if (INDICATOR > 0){
        topTemp = 10 * SCREENSCALE;
        heightTemp = 104 * SCREENSCALE;
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(58*SCREENSCALE, 72*SCREENSCALE);
    layout.minimumLineSpacing = floorf((SCREENWIDTH - 5*58*SCREENSCALE - 30*SCREENSCALE)/4) ;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 15*SCREENSCALE, 0, 15*SCREENSCALE);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.collectionView];
    [self.collectionView registerClass:[NvBeautyTypeCViewCell class] forCellWithReuseIdentifier:@"NvEditBeautyEffectCell"];
    [self.collectionView registerClass:[NvBeautyIntervalCell class] forCellWithReuseIdentifier:@"NvEditBeautyEffectIntervalCell"];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(topTemp);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.offset(heightTemp);
    }];
    
    self.overlayView = [[UIView alloc] init];
    self.overlayView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.overlayView];
    [self.overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_top);
        make.left.equalTo(self.collectionView.mas_left);
        make.right.equalTo(self.collectionView.mas_right);
        make.bottom.equalTo(self.collectionView.mas_bottom);
    }];
    
    self.beautySwitch = [[NvSwitchView alloc] initWithFrame:CGRectMake(0, 0, 32 * SCREENSCALE, 19 * SCREENSCALE) withType:2 withState:YES];
    self.beautySwitch.tag = 1000;
    [self.beautySwitch addTarget:self action:@selector(beautyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.beautyLabel = [UILabel new];
    self.beautyLabel.text = NvLocalString(@"Close beautype", @"关闭美型");
    self.beautyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#777777"];
    self.beautyLabel.font = [UIFont systemFontOfSize:11];
    
    [self addSubview:self.beautySwitch];
    [self addSubview:self.beautyLabel];
    
    [self.beautySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom).offset(18 * SCREENSCALE);
        make.right.equalTo(self.mas_right).offset(-10 * SCREENSCALE);
        make.width.offset(32 * SCREENSCALE);
        make.height.offset(19 * SCREENSCALE);
    }];
    
    [self.beautyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.beautySwitch.mas_left).offset(-5 * SCREENSCALE);
        make.centerY.equalTo(self.beautySwitch.mas_centerY);
    }];
    
    self.resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.resetBtn.tag = 2000;
    [self.resetBtn setTitle:NvLocalString(@"Reset", @"重置") forState:UIControlStateNormal];
    [self.resetBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#777777"] forState:UIControlStateNormal];
    [self.resetBtn addTarget:self action:@selector(resetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.resetBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [self.resetBtn setImage:NvImageNamed(@"NvEditBeautyTypeReset") forState:UIControlStateNormal];
    self.resetBtn.imageEdgeInsets = UIEdgeInsetsMake(-4, -15, 0, 0);
    [self addSubview:self.resetBtn];
    [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(5 * SCREENSCALE);
        make.centerY.equalTo(self.beautyLabel.mas_centerY);
        make.width.offset(80 * SCREENSCALE);
        make.height.offset(20 * SCREENSCALE);
    }];
    self.overlayView.hidden = YES;
    [self changeSwitchView:self.beautySwitch];
}

- (void)changeSwitchView:(NvSwitchView *)sender {
    sender.selected = !sender.selected;
    UILabel *label = self.beautyLabel;
    if(sender.selected){
        /*
         开启
         open
         */
        sender.backgroundColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"];
        sender.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#ffffff"];
        sender.selected = YES;
        label.textColor = [UIColor nv_colorWithHexRGB:@"#777777"];
        label.text = NvLocalString(@"Close beautype", @"关闭美型");
        [UIView animateWithDuration:0.1 animations:^{
            sender.sliderView.frame = CGRectMake(sender.sliderView.frame.size.width, 2,sender.sliderView.frame.size.width, sender.sliderView.frame.size.height);
        }];
    }else{
        /*
         关闭
         close
         */
        sender.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4E5253"];
        sender.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#DBDCDC"];
        sender.selected = NO;
        label.textColor = [UIColor nv_colorWithHexRGB:@"#909293"];
        label.text = NvLocalString(@"Open beautype", @"开启美型");
        [UIView animateWithDuration:0.1 animations:^{
            sender.sliderView.frame = CGRectMake(2, 2, sender.sliderView.frame.size.width, sender.sliderView.frame.size.height);
        }];
    }
}

- (void)resetBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(nvEditShapeEffectView:selecteModel:refreshView:refreshData:)]) {
        if (self.dataSource.count > 0) {
            [self resetValues:self.dataSource referenceArr:self.originalDataSource];
            for(NvBeautyTypeModel *model in self.dataSource) {
                [self.delegate nvEditShapeEffectView:self selecteModel:model refreshView:NO refreshData:NO];
            }
        }

        if (self.currentModel) {
            [self.delegate nvEditShapeEffectView:self selecteModel:self.currentModel refreshView:YES refreshData:YES];
        }

    }
}

- (void)changeSwitchState:(BOOL)open {
    self.beautySwitch.selected = !open;
    [self beautyBtnClick:self.beautySwitch];
}

- (void)beautyBtnClick:(NvSwitchView *)sender {
    [self changeSwitchView:sender];
    BOOL hidden = sender.selected;
    self.overlayView.hidden = hidden;
    if (!hidden) {
        [self bringSubviewToFront:self.overlayView];
    }
    self.resetBtn.enabled = hidden;
    self.resetBtn.alpha = hidden ? 1.f : 0.2;
    for(NvBeautyTypeModel *model in self.dataSource) {
        model.isOperation = hidden;
    }
    [self.collectionView reloadData];
    if ([self.delegate respondsToSelector:@selector(nvEditShapeEffectView:switchShapeSum:)]) {
        [self.delegate nvEditShapeEffectView:self switchShapeSum:sender.selected];
    }
}

- (void)resetValues:(NSMutableArray *)targetArr referenceArr:(NSMutableArray <NvBeautyTypeModel *>*)referenceArr {
    for(NvBeautyTypeModel *model in referenceArr) {
        for(NvBeautyTypeModel *item in targetArr) {
            if ([model.name isEqualToString:item.name]) {
                item.value = model.value;
                item.extValue = model.extValue;
                item.uuid = model.uuid;
                break;
            }
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvBeautyTypeModel *model = self.dataSource[indexPath.item];
    if ([model.name isEqualToString: NvLocalString(@"interval", @"间隔")]) {
        NvBeautyIntervalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvEditBeautyEffectIntervalCell" forIndexPath:indexPath];
        cell.isEditModuler = YES;
        cell.isOperation = model.isOperation;
        return cell;
    }
    NvBeautyTypeCViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvEditBeautyEffectCell" forIndexPath:indexPath];
    cell.drawTemplate = YES;
    UIColor *color = model.selected ? [UIColor nv_colorWithHexRGB:@"#5BA5F9"] : [UIColor whiteColor];
    cell.tintColor = color;
    [cell renderCellWithModel:model];
    return cell;
}

-(CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath {
    NvBeautyTypeModel *model = self.dataSource[indexPath.item];
    if ([model.name isEqualToString: NvLocalString(@"interval", @"间隔")]) {
        return  CGSizeMake(40*SCREENSCALE, 72*SCREENSCALE);
    }
    return  CGSizeMake(58*SCREENSCALE, 72*SCREENSCALE);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NvBeautyTypeModel *model = self.dataSource[indexPath.item];
    if ([model.name isEqualToString: NvLocalString(@"interval", @"间隔")]) {
        return ;
    }
    if (!model.canReplace) {
        if ([self.delegate respondsToSelector:@selector(nvEditShapeEffectView:forbiddenReplace:)]) {
            [self.delegate nvEditShapeEffectView:self forbiddenReplace:model];
        }
        return;
    }
    for (NvBeautyTypeModel *model in self.dataSource) {
        model.selected = NO;
    }
    
    model.selected = YES;
    if (![self.currentModel.name isEqualToString:model.name] && [self.delegate respondsToSelector:@selector(nvEditShapeEffectView:selecteModel:refreshView:refreshData:)]) {
        [self.delegate nvEditShapeEffectView:self selecteModel:model refreshView:YES refreshData:YES];
    }
    self.currentModel = model;
    [collectionView reloadData];
}
@end
