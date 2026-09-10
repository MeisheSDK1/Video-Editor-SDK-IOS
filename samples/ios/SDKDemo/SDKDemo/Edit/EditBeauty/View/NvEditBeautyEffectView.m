//
//  NvEditBeautyEffectView.m
//  SDKDemo
//
//  Created by Meishe on 2022/11/16.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvEditBeautyEffectView.h"
#import "NvBeautyIntervalCell.h"
#import "NvSwitchView.h"

@interface NvEditBeautyEffectView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *resetBtn;
@property (nonatomic, strong) NvSwitchView *beautySwitch;
@property (nonatomic, strong) UILabel *beautyLabel;
//"校色"开关
//" Color correction "switch
@property (nonatomic, strong) NvSwitchView *colorCorrectSwitch;
//"校色"label
//" Color proofer "label
@property (nonatomic, strong) UILabel *colorCorrectLabel;
//"校色"背景界面
//" Color Check "background interface
@property (nonatomic, strong) UIView *colorCorrectView;
@property (nonatomic, strong) UIView *sharpenView;
@property (nonatomic, strong) NvSwitchView *sharpenSwitch;
@property (nonatomic, strong) UILabel *sharpenLabel;
@property (nonatomic, strong) NSMutableArray *originalDataSource;
@property (nonatomic, strong) NSMutableArray *dataSource;
//“磨皮”代表model
// "Skinning" stands for model
@property (nonatomic, strong) NvBeautyTypeModel *beautySignModel;
@property (nonatomic, strong) NvBeautyTypeModel *currentModel;
//四个磨皮特效数组
// An array of four Millpitt effects
@property (nonatomic, strong) NSMutableArray *realBeautyStrengthArr;

@property (nonatomic, strong) UIView *overlayView;
@end

@implementation NvEditBeautyEffectView
- (instancetype)init {
    if (self = [super init]) {
        self.dataSource = [NSMutableArray array];
        self.originalDataSource = [NSMutableArray array];
        self.realBeautyStrengthArr = [NSMutableArray array];
        [self addSubviews];
    }
    return self;
}

#pragma mark - 数据 data
- (void)updateData:(NSArray <NvBeautyTypeModel *>*)dataSource showTemporaryData:(BOOL)temporary {
    if (temporary) {
        //临时数据 Temporary data
        for(NvBeautyTypeModel *model in dataSource) {
            BOOL contain = NO;
            for(NvBeautyTypeModel *item in self.dataSource) {
                if ([item.fxName isEqualToString:model.fxName]) {
                    item.value = model.value;
                    item.switchSelected = model.switchSelected;
                    item.canReplace = model.canReplace;
                    contain = YES;
                    break;
                }
            }
            if (!contain) {
                for(NvBeautyTypeModel *item in self.realBeautyStrengthArr) {
                    if ([item.fxName isEqualToString:model.fxName]) {
                        item.value = model.value;
                        item.selected = YES;
                        break;
                    }
                }
            }
        }
        
    }else {
        [self updateData:dataSource];
    }
}

- (void)updateData:(NSArray <NvBeautyTypeModel *>*)dataSource {
    self.originalDataSource = [[NSMutableArray alloc] initWithArray:dataSource copyItems:YES];
    if([NvBaseUtils enableAIBeauty]) {
        self.realBeautyStrengthArr = [NSMutableArray arrayWithArray:@[dataSource[1], dataSource[2],dataSource[3],dataSource[4],dataSource[5],dataSource[6]]];
    } else {
        self.realBeautyStrengthArr = [NSMutableArray arrayWithArray:@[dataSource[1], dataSource[2],dataSource[3],dataSource[4],dataSource[5]]];
    }
    
    self.beautySignModel = dataSource[0];
    [self.dataSource addObjectsFromArray:dataSource];
    [self keepsOnlyOneBeautyStrengthData];
    [self.collectionView reloadData];
}

- (void)reapplyAppliedEffects:(BOOL)needRefreshView refreshData:(BOOL)needRefreshData {
    if ([self.delegate respondsToSelector:@selector(nvEditBeautyEffectView:selecteModel:refreshView:refreshData:)]) {
        NSMutableArray *dataArr = [[NSMutableArray alloc] initWithArray:self.dataSource copyItems:YES];
        NSMutableArray *beautyStrengthArr = [[NSMutableArray alloc] initWithArray:self.realBeautyStrengthArr copyItems:YES];
        NSMutableArray *applyArr = [NSMutableArray array];
        [applyArr addObjectsFromArray:dataArr];
        [applyArr addObjectsFromArray:beautyStrengthArr];
        
        NvBeautyTypeModel *chooseBeautyStrengthM = [self chooseSuitableBeautyStrengthModel:applyArr];
        for(NvBeautyTypeModel *model in applyArr) {
            if ([model.fxName isEqualToString:@"Beauty Strength"] || [model.fxName isEqualToString:@"Advanced Beauty Type Zero"] || [model.fxName isEqualToString:@"Advanced Beauty Type One"] || [model.fxName isEqualToString:@"Advanced Beauty Type Two"] || [model.fxName isEqualToString:@"Advanced Beauty Type Three"]) {
                if (![model.fxName isEqualToString:chooseBeautyStrengthM.fxName]) {
                    continue;
                }
            }
            
            if (needRefreshView && [model.fxName isEqualToString:self.currentModel.fxName]) {
                [self.delegate nvEditBeautyEffectView:self selecteModel:model refreshView:YES refreshData:YES];
            }else{
                [self.delegate nvEditBeautyEffectView:self selecteModel:model refreshView:NO refreshData:needRefreshData];
            }
        }
        
    }
}

- (void)setZeroToAllEffectStrength:(BOOL)needRefreshView refreshData:(BOOL)needRefreshData {
    if ([self.delegate respondsToSelector:@selector(nvEditBeautyEffectView:selecteModel:refreshView:refreshData:)]) {
        for(NvBeautyTypeModel *model in self.originalDataSource) {
            [self.delegate nvEditBeautyEffectView:self selecteModel:model refreshView:needRefreshView refreshData:needRefreshData];
        }
    }
}

- (void)refreshData {
    [self.collectionView reloadData];
}

- (NvBeautyTypeModel *)chooseSuitableBeautyStrengthModel:(NSMutableArray *)beautyArr {
    NvBeautyTypeModel *targetModel;
    for(NvBeautyTypeModel *model in beautyArr) {
        if ([model.fxName isEqualToString:@"Beauty Strength"] || [model.fxName isEqualToString:@"Advanced Beauty Type Zero"] || [model.fxName isEqualToString:@"Advanced Beauty Type One"] || [model.fxName isEqualToString:@"Advanced Beauty Type Two"] || [model.fxName isEqualToString:@"Advanced Beauty Type Three"]) {
            if (model.selected) {
                targetModel = model;
                break;
            }else if (model.value != 0) {
                targetModel = model;
                break;
            }
        }
    }
    if (!targetModel) {
        for(NvBeautyTypeModel *model in beautyArr) {
            if ([model.fxName isEqualToString:@"Advanced Beauty Type Zero"]) {
                targetModel = model;
                break;
            }
        }
    }
    return targetModel;
}

//数据只包含一个“磨皮”代表数据
//The data contains only one "skinning" to represent the data
- (void)keepsOnlyOneBeautyStrengthData {
    NSMutableArray *arr = [self getRealBeautyStrengthArr];
    if (arr.count > 0) {
        self.realBeautyStrengthArr = arr;
    }
    
    [self.dataSource removeObjectsInArray:self.realBeautyStrengthArr];
    if (![self.dataSource containsObject:self.beautySignModel]) {
        [self.dataSource insertObject:self.beautySignModel atIndex:0];
    }
}

//数据包含全部磨皮
// Data includes all skinning
- (void)keepsAllBeautyStrengthData {
    NSMutableArray *arr = [self getRealBeautyStrengthArr];
    if (arr.count > 0 && (!self.realBeautyStrengthArr || self.realBeautyStrengthArr.count == 0)) {
        self.realBeautyStrengthArr = arr;
    }
    if ([self.dataSource containsObject:self.beautySignModel]) {
        [self.dataSource removeObject:self.beautySignModel];
    }
    if ([self.dataSource containsObject:self.realBeautyStrengthArr.lastObject]) {
        return;
    }
    for(int i=0; i<self.realBeautyStrengthArr.count; i++) {
        [self.dataSource insertObject:self.realBeautyStrengthArr[i] atIndex:i];
    }
}

- (NSMutableArray *)getRealBeautyStrengthArr {
    NSMutableArray *realArr = [NSMutableArray array];
    for(NvBeautyTypeModel *model in self.dataSource) {
        if ([model.name isEqualToString:NvLocalString(@"Strength Mode 1", @"磨皮1")] ||
            [model.name isEqualToString:NvLocalString(@"Strength Mode 2", @"磨皮2")] ||
            [model.name isEqualToString:NvLocalString(@"Strength Mode 3", @"磨皮3")] ||
            [model.name isEqualToString:NvLocalString(@"Strength Mode 4", @"磨皮4")] ||
            [model.name isEqualToString:NvLocalString(@"AI Concealer", @"AI磨皮")] ||
            [model.coverImage isEqualToString:@"capture_skin_grinding_return"]) {
            [realArr addObject:model];
        }
    }
    return realArr;
}

- (void)resetValues:(NSMutableArray *)targetArr referenceArr:(NSMutableArray <NvBeautyTypeModel *>*)referenceArr {
    for(NvBeautyTypeModel *model in referenceArr) {
        for(NvBeautyTypeModel *item in targetArr) {
            if ([model.name isEqualToString:item.name] || ([model.name containsString:NvLocalString(@"Whiten mode" , @"美白")] && [item.name containsString:NvLocalString(@"Whiten mode" , @"美白")])) {
                item.value = model.value;
                item.extValue = model.extValue;
                item.canReplace = model.canReplace;
                break;
            }
        }
    }
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
    layout.itemSize = CGSizeMake(62*SCREENSCALE, 72*SCREENSCALE);
    layout.minimumLineSpacing = floorf((SCREENWIDTH - 5*62*SCREENSCALE - 30*SCREENSCALE)/4);
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
    self.beautyLabel.text = NvLocalString(@"Close beauty", @"关闭美肤");
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
    
    /*
     底部美颜滤镜(校色)开关界面
     Bottom beauty filter (color correction) switch interface
     */
    self.colorCorrectView = [[UIView alloc] init];
    [self addSubview:self.colorCorrectView];
    [self.colorCorrectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.beautyLabel.mas_centerY);
        make.width.mas_equalTo(90*SCREENSCALE);
        make.height.mas_equalTo(17*SCREENSCALE);
        make.right.equalTo(self.beautyLabel.mas_left);
    }];
    
    self.colorCorrectSwitch = [[NvSwitchView alloc]initWithFrame:CGRectMake(0, 0, 32 * SCREENSCALE, 19 * SCREENSCALE) withType:2 withState:YES];
    [self.colorCorrectSwitch addTarget:self action:@selector(colorCorrectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.colorCorrectSwitch.tag = 1001;
    [self.colorCorrectView addSubview:self.colorCorrectSwitch];
    self.colorCorrectLabel = [[UILabel alloc] init];
    self.colorCorrectLabel.text = NvLocalString(@"Color correction", @"校色");
    self.colorCorrectLabel.textColor = [UIColor nv_colorWithHexRGB:@"#777777"];
    self.colorCorrectLabel.font = [UIFont systemFontOfSize:11];
    [self.colorCorrectView addSubview:self.colorCorrectLabel];
    
    [self.colorCorrectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self.colorCorrectView);
        make.centerY.equalTo(self.beautyLabel.mas_centerY);
    }];
    [self.colorCorrectSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.colorCorrectLabel.mas_right).offset(5*SCREENSCALE);
        make.width.mas_equalTo(32 * SCREENSCALE);
        make.height.mas_equalTo(19*SCREENSCALE);
        make.centerY.equalTo(self.colorCorrectLabel.mas_centerY);
    }];
    self.colorCorrectView.hidden = YES;
    
    /*
     底部锐度界面（包含锐化开关以及显示label）
     Bottom sharpening interface (including sharpening switch and display label)
     */
    self.sharpenView = [[UIView alloc] init];
    [self addSubview:self.sharpenView];
    [self.sharpenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.colorCorrectView);
    }];
    
    self.sharpenSwitch = [[NvSwitchView alloc]initWithFrame:CGRectMake(0, 0, 32 * SCREENSCALE, 19 * SCREENSCALE) withType:2 withState:YES];
    [self.sharpenSwitch addTarget:self action:@selector(sharpenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.sharpenSwitch.tag = 1002;
    [self.sharpenView addSubview:self.sharpenSwitch];
    self.sharpenLabel = [[UILabel alloc] init];
    self.sharpenLabel.text = NvLocalString(@"Amount",@"锐度");
    self.sharpenLabel.textColor = [UIColor nv_colorWithHexRGB:@"#777777"];
    self.sharpenLabel.font = [UIFont systemFontOfSize:11];
    [self.sharpenView addSubview:self.sharpenLabel];
    [self.sharpenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.sharpenView);
        
    }];
    [self.sharpenSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sharpenLabel.mas_right).offset(5*SCREENSCALE);
        make.width.mas_equalTo(32 * SCREENSCALE);
        make.height.mas_equalTo(19*SCREENSCALE);
        make.centerY.equalTo(self.sharpenLabel.mas_centerY);
    }];
    self.sharpenView.hidden = YES;
    
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

- (void)resetBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(nvEditBeautyEffectView:selecteModel:refreshView:refreshData:)]) {
        if (self.dataSource.count > 0) {
            [self resetValues:self.dataSource referenceArr:self.originalDataSource];
            for(NvBeautyTypeModel *model in self.dataSource) {
                [self.delegate nvEditBeautyEffectView:self selecteModel:model refreshView:NO refreshData:NO];
            }
        }
        
        if (self.realBeautyStrengthArr.count > 0) {
            [self resetValues:self.realBeautyStrengthArr referenceArr:self.originalDataSource];
            for(NvBeautyTypeModel *model in self.realBeautyStrengthArr) {
                [self.delegate nvEditBeautyEffectView:self selecteModel:model refreshView:NO refreshData:NO];
            }
        }
        if(self.sharpenSwitch.selected) {
            [self changeSwitchView:self.sharpenSwitch];
        }
        
        if (self.currentModel) {
            [self.delegate nvEditBeautyEffectView:self selecteModel:self.currentModel refreshView:YES refreshData:YES];
        }
        
    }
}

- (void)changeSwitchState:(BOOL)open {
    self.beautySwitch.selected = !open;
    [self beautyBtnClick:self.beautySwitch];
}

- (void)beautyBtnClick:(NvSwitchView *)sender {
    if (sender.selected) {
        if (self.colorCorrectSwitch.selected) {
            [self colorCorrectBtnClicked:self.colorCorrectSwitch];
        }
        if (self.sharpenSwitch.selected) {
            [self sharpenBtnClick:self.sharpenSwitch];
        }
    }
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
    if ([self.delegate respondsToSelector:@selector(nvEditBeautyEffectView:switchBeautySum:)]) {
        [self.delegate nvEditBeautyEffectView:self switchBeautySum:sender.selected];
    }
}

- (void)colorCorrectBtnClicked:(NvSwitchView *)sender {
    if(self.beautySwitch.selected == NO) {
        return;
    }
    [self changeSwitchView:sender];
    if ([self.delegate respondsToSelector:@selector(nvEditBeautyEffectView:switchColorCorrect:)]) {
        [self.delegate nvEditBeautyEffectView:self switchColorCorrect:sender.selected];
    }
}

- (void)sharpenBtnClick:(NvSwitchView *)sender {
    if(self.beautySwitch.selected == NO) {
        return;
    }
    [self changeSwitchView:sender];
    if ([self.delegate respondsToSelector:@selector(nvEditBeautyEffectView:switchSharpen:)]) {
        [self.delegate nvEditBeautyEffectView:self switchSharpen:sender.selected];
    }
}

- (void)changeSwitchView:(NvSwitchView *)sender {
    sender.selected = !sender.selected;
    UILabel *label;
    if (sender.tag == 1000) {
        //美肤按钮 Beauty button
        label = self.beautyLabel;
    }
    else if (sender.tag == 1001) {
        //校色 Color correction
        label = self.colorCorrectLabel;
    }
    else if (sender.tag == 1002) {
        //锐度 sharpness
        label = self.sharpenLabel;
    }
    if(sender.selected){
        /*
         开启
         open
         */
        sender.backgroundColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"];
        sender.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#ffffff"];
        sender.selected = YES;
        label.textColor = [UIColor nv_colorWithHexRGB:@"#777777"];
        if (sender.tag == 1000) {
            label.text = NvLocalString(@"Close beauty", @"关闭美肤");
        }
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
        if (sender.tag == 1000) {
            label.text = NvLocalString(@"Open beauty", @"开启美肤");
        }
        [UIView animateWithDuration:0.1 animations:^{
            sender.sliderView.frame = CGRectMake(2, 2, sender.sliderView.frame.size.width, sender.sliderView.frame.size.height);
        }];
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
    return  CGSizeMake(62*SCREENSCALE, 72*SCREENSCALE);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NvBeautyTypeModel *model = self.dataSource[indexPath.item];
    if ([model.name isEqualToString: NvLocalString(@"interval", @"间隔")]) {
        return ;
    }
    if (!model.canReplace) {
        if ([self.delegate respondsToSelector:@selector(nvEditBeautyEffectView:forbiddenReplace:)]) {
            [self.delegate nvEditBeautyEffectView:self forbiddenReplace:model];
        }
        return;
    }
    for (NvBeautyTypeModel *model in self.dataSource) {
        if (!([model.name isEqualToString:NvLocalString(@"Strength Mode 1", @"磨皮1")] || [model.name isEqualToString:NvLocalString(@"Strength Mode 2", @"磨皮2")] || [model.name isEqualToString:NvLocalString(@"Strength Mode 3", @"磨皮3")] || [model.name isEqualToString:NvLocalString(@"Strength Mode 4", @"磨皮4")]|| [model.name isEqualToString:NvLocalString(@"AI Concealer", @"AI磨皮")])) {
            model.selected = NO;
        }
        
    }

    if ([model.name isEqualToString:NvLocalString(@"Color correction", @"校色")]) {
        self.colorCorrectView.hidden = NO;
        if (self.colorCorrectSwitch.selected != model.switchSelected) {
            [self changeSwitchView:self.colorCorrectSwitch];
        }
    }else{
        self.colorCorrectView.hidden = YES;
    }

    if([model.name isEqualToString:NvLocalString(@"Amount", @"锐度")]){
        self.sharpenView.hidden = NO;
        if (self.sharpenSwitch.selected != model.switchSelected) {
            [self changeSwitchView:self.sharpenSwitch];
        }
    }else{
        self.sharpenView.hidden = YES;
    }
    
    if ([model.name containsString:NvLocalString(@"Strength", @"磨皮")]) {
        if ([model.coverImage isEqualToString:@"capture_skin_grinding_sum"]) {
            [self keepsAllBeautyStrengthData];

        }else if ([model.coverImage isEqualToString:@"capture_skin_grinding_return"]) {
            [self keepsOnlyOneBeautyStrengthData];
        }
        
        
        for (NvBeautyTypeModel *item in self.dataSource) {
            if ([item.name isEqualToString:NvLocalString(@"Strength Mode 1", @"磨皮1")] || [item.name isEqualToString:NvLocalString(@"Strength Mode 2", @"磨皮2")] || [item.name isEqualToString:NvLocalString(@"Strength Mode 3", @"磨皮3")]||[item.name isEqualToString:NvLocalString(@"Strength Mode 4", @"磨皮4")]|| [item.name isEqualToString:NvLocalString(@"AI Concealer", @"AI磨皮")]) {
                if ([model.coverImage isEqualToString:@"capture_skin_grinding_sum"]) {
                    //点击总磨皮，需要显示之前选中的磨皮x
                    //Click on Total dermabrasion to display the dermabrasion x selected earlier
                    if (item.selected) {
                        model = item;
                    }else {
                        //应用其中一个"磨皮"，其余"磨皮"强度置为0
                        //Apply one of the "peels" and set the strength of the remaining "peels" to 0
                        item.value = 0;
                    }
                }else {
                    //除了点击相同的项，其余“磨皮”强度置为0
                    //Except for clicking the same item, the rest of the "skin" intensity is set to 0
                    if (!([item.name isEqualToString:model.name] && ![model.coverImage isEqualToString:@"capture_skin_grinding_return"])) {
                        item.value = 0;
                        item.selected = 0;
                    }
                }
                
            }
        }
        
        model.selected = YES;
        if ([model.coverImage isEqualToString:@"capture_skin_grinding_return"]) {
            model.selected = NO;
        }
        if (![self.currentModel.name isEqualToString:model.name] && ![model.coverImage isEqualToString:@"capture_skin_grinding_sum"] && ![model.coverImage isEqualToString:@"capture_skin_grinding_return"]) {
            if ([self.delegate respondsToSelector:@selector(nvEditBeautyEffectView:selecteModel:refreshView:refreshData:)]) {
                [self.delegate nvEditBeautyEffectView:self selecteModel:model refreshView:YES refreshData:YES];
            }
        }
        
    }else {
        model.selected = YES;
        [self keepsOnlyOneBeautyStrengthData];
        self.beautySignModel.selected = NO;
        if (![self.currentModel.name isEqualToString:model.name] && [self.delegate respondsToSelector:@selector(nvEditBeautyEffectView:selecteModel:refreshView:refreshData:)]) {
            [self.delegate nvEditBeautyEffectView:self selecteModel:model refreshView:YES refreshData:YES];
        }
    }
    
    self.currentModel = model;
    [collectionView reloadData];
}
@end
