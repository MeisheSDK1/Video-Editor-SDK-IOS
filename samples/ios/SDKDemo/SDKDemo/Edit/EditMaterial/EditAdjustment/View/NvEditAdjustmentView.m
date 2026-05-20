//
//  NvEditAdjustmentView.m
//  SDKDemo
//
//  Created by MS on 2020/12/2.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditAdjustmentView.h"
#import "NvEditBottomCollectionViewCell.h"
#import "NvEditAdjustRatioCell.h"
#import "NvBeautySliderView.h"
#import "NVHeader.h"
@implementation NvEditAdjustmentModel

@end

@interface NvEditAdjustmentView ()<UICollectionViewDelegate,UICollectionViewDataSource,NvBeautySliderViewDelegate>
@property (nonatomic, strong) NvBeautySliderView *slider;
@property (nonatomic, strong) UICollectionView *ratioCollection;
@property (nonatomic, strong) UICollectionView *adjustCollection;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, copy) NSArray *adjustArray;
@property (nonatomic, strong) NSMutableArray *ratioArray;
@property (nonatomic, strong) NvEditAdjustmentModel *model;
@property (nonatomic, assign) CGFloat liveWindowWidth;
@property (nonatomic, assign) CGFloat liveWindowHeight;
@end

@implementation NvEditAdjustmentView

- (instancetype)initWithModel:(NvEditAdjustmentModel *)model {
    if (self = [super init]) {
        self.model = model;
        self.adjustArray = @[
        @{NvLocalString(@"Level", @"水平"):@"NvAdjustVertical"},
        @{NvLocalString(@"Vertical", @"垂直"):@"NvAdjustLevel"},
        @{NvLocalString(@"Rotation", @"旋转"):@"NvAdjustRotating"},
        @{NvLocalString(@"Reset", @"复位"):@"NvAdjustReset"}];
        [self configRatioData];
        [self addSubviews];
        self.backgroundColor = UIColorFromRGB(0x242728);
    }
    return self;
}

- (void)configRatioData {
    self.ratioArray = [NSMutableArray array];
    NSArray *nameArr = @[NvLocalString(@"Free", @"自由"),@"9:16",@"3:4",@"9:18",@"9:21",@"1:1",@"16:9",@"4:3",@"18:9",@"21:9"];
    NSArray *normalImgs = @[@"nv_adjust_ratio_Free",@"nv_adjust_ratio_9v16",@"nv_adjust_ratio_3v4",@"nv_adjust_ratio_9v18",@"nv_adjust_ratio_9v21",@"nv_adjust_ratio_1v1",@"nv_adjust_ratio_16v9",@"nv_adjust_ratio_4v3",@"nv_adjust_ratio_18v9",@"nv_adjust_ratio_21v9"];
    NSArray *selectImgs = @[@"nv_adjust_ratio_Free_select",@"nv_adjust_ratio_9v16_select",@"nv_adjust_ratio_3v4_select",@"nv_adjust_ratio_9v18_select",@"nv_adjust_ratio_9v21_select",@"nv_adjust_ratio_1v1_select",@"nv_adjust_ratio_16v9_select",@"nv_adjust_ratio_4v3_select",@"nv_adjust_ratio_18v9_select",@"nv_adjust_ratio_21v9_select"];
    for (int i=0; i<nameArr.count; i++) {
        NvEditAdjustRatioModel *item = [NvEditAdjustRatioModel new];
        if (i==0) {
            item.isSelected = YES;
        }else{
            item.isSelected = NO;
        }
        item.name = nameArr[i];
        item.normalImgName = normalImgs[i];
        item.selectedImgName = selectImgs[i];
        [self.ratioArray addObject:item];
    }
    
}



- (void)addSubviews {
    /*-------------------   底部按钮  Bottom button---------------------*/
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
    
    self.lineView = [UIView new];
    self.lineView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(finsh.mas_top).offset(-12*SCREENSCALE);
    }];
    
    /*------   adjustCollection  ------*/
    [self addAdjustCollectionView];
    /*------   ratioCollection  ------*/
    [self addRatioCollectionView];
    /*------   sliderView  ------*/
    [self addSliderView];
    /*------   liveWindow  ------*/
    [self addLiveWindow];
}

- (void)addLiveWindow {
    CGRect frame = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH);
    if (SCREENHEIGHT <= 667.0) {
        frame = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH*2/3);
    }
    self.liveWindowPanel = [[NvCropperScrollView alloc] initWithFrame:frame];
    [self addSubview:self.liveWindowPanel];
}

- (void)addSliderView {
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.textColor = [UIColor whiteColor];
    infoLabel.font = [UIFont systemFontOfSize:12*SCREENSCALE];
    infoLabel.text = NvLocalString(@"Angle", @"角度");
    [self addSubview:infoLabel];
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15*SCREENSCALE);
        make.bottom.equalTo(self.ratioCollection.mas_top).offset(-10.5f*SCREENSCALE);
        make.height.mas_equalTo(17*SCREENSCALE);
        make.width.mas_lessThanOrEqualTo(50*SCREENSCALE);
    }];
    
    UILabel *leftLabel = [[UILabel alloc] init];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.textColor = [UIColor whiteColor];
    leftLabel.font = [UIFont systemFontOfSize:10*SCREENSCALE];
    leftLabel.text = @"-45";
    [self addSubview:leftLabel];
    [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(72*SCREENSCALE);
        make.centerY.equalTo(infoLabel.mas_centerY);
        make.height.mas_equalTo(17*SCREENSCALE);
        make.width.mas_equalTo(30*SCREENSCALE);
    }];
    
    UILabel *rightLabel = [[UILabel alloc] init];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.backgroundColor = [UIColor clearColor];
    rightLabel.textColor = [UIColor whiteColor];
    rightLabel.font = [UIFont systemFontOfSize:10*SCREENSCALE];
    rightLabel.text = @"45";
    [self addSubview:rightLabel];
    [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-34.5*SCREENSCALE);
        make.centerY.equalTo(infoLabel.mas_centerY);
        make.height.mas_equalTo(17*SCREENSCALE);
        make.width.mas_equalTo(30*SCREENSCALE);
    }];
    
    self.slider = [[NvBeautySliderView alloc] init];
    self.slider.minValue = -45.0/100;
    self.slider.maxValue = 45.0/100;
    self.slider.value = -1*self.model.angle/100;
    self.slider.delegate = self;
    self.slider.hiddenIndicatorView = YES;
    [self.slider.slider setThumbImage:NvImageNamed(@"nv_adjust_angle_slider") forState:UIControlStateNormal];
    [self addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftLabel.mas_right).offset(8*SCREENSCALE);
        make.right.equalTo(rightLabel.mas_left).offset(-10.5*SCREENSCALE);
        make.centerY.equalTo(infoLabel.mas_centerY).offset(4*SCREENSCALE);
        make.height.mas_equalTo(10*SCREENSCALE);
    }];
}

- (void)setSliderValue:(CGFloat)value {
    self.slider.value = -1*value/100;
}

- (NvVideoEditAspectRatioMode)getAspectRatioMode {
    NSInteger index = 0;
    for (NvEditAdjustRatioModel *model in _ratioArray) {
        if (model.isSelected) {
            index = [_ratioArray indexOfObject:model];
            break;
        }
    }
    
    return (NvVideoEditAspectRatioMode)index;
}

- (void)addRatioCollectionView {
    [self addSubview:self.ratioCollection];
    [self.ratioCollection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.adjustCollection.mas_top).offset(-8*SCREENSCALE);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(50*SCREENSCALE);
    }];
}

- (void)addAdjustCollectionView {
    [self addSubview:self.adjustCollection];
    [self.adjustCollection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.lineView.mas_top).offset(-10*SCREENSCALE);
        make.height.mas_equalTo(84*SCREENSCALE);
        make.left.right.equalTo(self);
    }];
}

- (void)finshClick:(UIButton *)sender {
    NvCropperModel *model = [self.liveWindowPanel currentRransformDataWithEditViewLiveWindow:self.timelineLivewindow timelineVideoRes:self.timelineVideoRes];
    
    
    if ([self.delegate respondsToSelector:@selector(nvEditAdjustmentViewFinished:cropperModel:)]) {
        [self.delegate nvEditAdjustmentViewFinished:self cropperModel:model];
    }
}

- (void)selectAspectRatio:(NvVideoEditAspectRatioMode)ratioMode {
    for (NvEditAdjustRatioModel *model in _ratioArray) {
        model.isSelected = NO;
    }
    NvEditAdjustRatioModel *model = self.ratioArray[ratioMode];
    model.isSelected = YES;
    [_ratioCollection reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual: _ratioCollection]) {
        return self.ratioArray.count;
    }
    return self.adjustArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual: _ratioCollection]) {
        NvEditAdjustRatioCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ratioCell" forIndexPath:indexPath];
        NvEditAdjustRatioModel *item = self.ratioArray[indexPath.item];
        cell.model = item;
        return cell;
    }
    NvEditBottomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.dict = self.adjustArray[indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView isEqual:_ratioCollection]) {
        for (NvEditAdjustRatioModel *model in _ratioArray) {
            model.isSelected = NO;
        }
        NvEditAdjustRatioModel *model = self.ratioArray[indexPath.item];
        model.isSelected = YES;
        [collectionView reloadData];
        ///注：需保证item内容与NvEditAdjustMode 枚举一一对应
        ///Note: Ensure that item contents correspond to the NvEditAdjustMode enumeration
        [self.liveWindowPanel resetRatioWithAspectRatio:(NvVideoEditAspectRatioMode)indexPath.item];
    }else{
        if ([self.delegate respondsToSelector:@selector(nvEditAdjustmentView:selectIndex:)]) {
            [self.delegate nvEditAdjustmentView:self selectIndex:indexPath.item];
        }
    }
}

#pragma mark - NvBeautySliderViewDelegate
-(void)sliderValueChanged:(UISlider *)paramSender {
    [self.liveWindowPanel resetRotateAngleWithAngle:paramSender.value*100/180.0*M_PI];
}
-(void)sliderValueEnd:(UISlider *)paramSender{
    
}

#pragma mark - setter & getter
- (void)setModel:(NvEditAdjustmentModel *)model {
    _model = model;
    
    _liveWindowWidth = SCREENWIDTH;
    _liveWindowHeight = SCREENWIDTH;
    if (model.assetRatio<=1.0) {
        _liveWindowWidth = _liveWindowHeight * model.assetRatio;
    }else{
        _liveWindowHeight = _liveWindowWidth / model.assetRatio;
    }
}

#pragma mark - lazyload
- (UICollectionView *)adjustCollection {
    if (!_adjustCollection) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(58*SCREENSCALE, 82*SCREENSCALE);
        layout.minimumLineSpacing = 10*SCREENSCALE;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, (SCREENWIDTH - 262 * SCREENSCALE) * 0.5, 0, 0);
        _adjustCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0 * SCREENSCALE, 462, SCREENWIDTH, 84*SCREENSCALE) collectionViewLayout:layout];
        _adjustCollection.backgroundColor = UIColor.clearColor;
        _adjustCollection.delegate = self;
        _adjustCollection.dataSource = self;
        _adjustCollection.showsHorizontalScrollIndicator = NO;
        [_adjustCollection registerClass:[NvEditBottomCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _adjustCollection;
}

- (UICollectionView *)ratioCollection {
    if (!_ratioCollection) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(26*SCREENSCALE, 45*SCREENSCALE);
        layout.minimumLineSpacing = 24.5*SCREENSCALE;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 17.5*SCREENSCALE, 0, 17.5*SCREENSCALE);
        _ratioCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0 * SCREENSCALE, 462, SCREENWIDTH, 50*SCREENSCALE) collectionViewLayout:layout];
        _ratioCollection.backgroundColor = UIColor.clearColor;
        _ratioCollection.delegate = self;
        _ratioCollection.dataSource = self;
        _ratioCollection.showsHorizontalScrollIndicator = NO;
        [_ratioCollection registerClass:[NvEditAdjustRatioCell class] forCellWithReuseIdentifier:@"ratioCell"];
    }
    return _ratioCollection;
}

- (void)connectTimeline:(NvsTimeline *)timeline{
    
    
}

- (void)playTimelineAtTime:(int64_t)timeStamp{
    
    
}
@end
