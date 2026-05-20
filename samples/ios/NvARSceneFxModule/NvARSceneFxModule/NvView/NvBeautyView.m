//
//  NvBeautyView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvBeautyView.h"
#import "NvCaptureFilterModel.h"
#import "NvBeautySliderView.h"
#import "NvARSceneMacro.h"
#import "NvARSceneUtils.h"
#import "Masonry.h"
#import "UIColor+NvColor.h"
#import "NvARLocalString.h"

@interface NvBeautyView()<UICollectionViewDelegate,UICollectionViewDataSource,NvBeautySliderViewDelegate>

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIView *bottomView;


@property (nonatomic, strong) UIView *beautyBCView;

@property (nonatomic, strong) UILabel *beautyLabel;

@property (nonatomic, strong) NvBeautySliderView *beautySlider;

@property (nonatomic, strong) NvBeautySliderView *beautyShinySlider;

@property (nonatomic, strong) UILabel *filterLabel;

@property (nonatomic, strong) NvSwitchView *filterSwitch;

@property (nonatomic, strong) NvSwitchView *sharpenSwitch;

@property (nonatomic, strong) UILabel *sharpenLabel;

@property (nonatomic, strong) UICollectionView *beautyCollectionView;

@property (nonatomic, strong) UIButton *resetBtn;

@property (nonatomic, strong) NSMutableArray *currentArray_1;

@property (nonatomic, strong) NvBeautyTypeModel *currentModel_1;

@property (nonatomic, strong) UIView *beautyTypeBCView;

@property (nonatomic, strong) UILabel *beautyTypeLabel;

@property (nonatomic, strong) NvBeautySliderView *beautyTypeSlider;

@property (nonatomic, strong) UICollectionView *beautyTypeCollectionView;

@property (nonatomic, strong) UIButton *beautyTypeResetBtn;

@property (nonatomic, strong) NSMutableArray *currentArray;

@property (nonatomic, strong) NvBeautyTypeModel *currentModel;


@property (nonatomic, strong) UIView *beautyTypeMicroBCView;

@property (nonatomic, strong) UILabel *beautyTypeMicroLabel;

@property (nonatomic, strong) NvBeautySliderView *beautyTypeMicroSlider;

@property (nonatomic, strong) UICollectionView *beautyTypeMicroCollectionView;

@property (nonatomic, strong) UIButton *beautyMicroResetBtn;

@property (nonatomic, strong) NSMutableArray *beautyTypeMicroArray;

@property (nonatomic, strong) NvBeautyTypeModel *currentMicroModel;

@end

@implementation NvBeautyView

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self addSubviews];
    }
    return self;
}

#pragma mark - 添加子视图
///Add subview
- (void)addSubviews{
    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = UIColor.clearColor;
    
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = UIColor.whiteColor;
    
    self.beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beautyBtn setTitle:NvBundleLocalString(@"美颜", nil, [self class]) forState:UIControlStateNormal];
    self.beautyBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.beautyBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    self.beautyBtn.backgroundColor = UIColor.clearColor;
    
    self.beautyTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beautyTypeBtn setTitle:NvBundleLocalString(@"美型", nil, [self class]) forState:UIControlStateNormal];
    self.beautyTypeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.beautyTypeBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#707070"] forState:UIControlStateNormal];
    self.beautyTypeBtn.backgroundColor = UIColor.clearColor;
    
    self.beautyTypeMicroBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beautyTypeMicroBtn setTitle:NvBundleLocalString(@"微整形", nil, [self class]) forState:UIControlStateNormal];
    self.beautyTypeMicroBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.beautyTypeMicroBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#707070"] forState:UIControlStateNormal];
    self.beautyTypeMicroBtn.backgroundColor = UIColor.clearColor;
    
    UILabel *horizontalLine = [UILabel new];
    horizontalLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#C8C8C8"];
    
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.beautyBtn];
    [self.bottomView addSubview:self.beautyTypeBtn];
    [self.bottomView addSubview:self.beautyTypeMicroBtn];
    [self.bottomView addSubview:horizontalLine];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.width.equalTo(self.mas_width);
        make.height.offset(100 * SCREENSCALE);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(self.mas_width);
    }];
    
    [self.beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top);
        make.left.equalTo(self);
        make.width.offset(self.frame.size.width/3);
        make.height.offset(30 * SCREENSCALE);
    }];
    
    [self.beautyTypeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top);
        make.centerX.equalTo(self);
        make.width.offset(self.frame.size.width/3);
        make.height.offset(30 * SCREENSCALE);
    }];
    
    [self.beautyTypeMicroBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top);
        make.right.equalTo(self);
        make.width.offset(self.frame.size.width/3);
        make.height.offset(30 * SCREENSCALE);
    }];
    
    [horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBtn.mas_bottom);
        make.width.offset(self.frame.size.width);
        make.height.offset(1 *SCREENSCALE);
    }];
    
    [self addBeauty];
    [self addBeautyType];
    [self addBeautyTypeMicro];
}

#pragma mark - 添加美颜视图
///Add beauty view
- (void)addBeauty{
    self.beautySlider = [NvBeautySliderView new];
    self.beautySlider.hidden = YES;
    self.beautySlider.delegate = self;
    [self.topView addSubview:self.beautySlider];
    [self.beautySlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10 * SCREENSCALE);
        make.centerX.equalTo(self.topView.mas_centerX);
        make.width.offset(273 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    
    self.beautyShinySlider = [NvBeautySliderView new];
    self.beautyShinySlider.hidden = YES;
    self.beautyShinySlider.delegate = self;
    [self.topView addSubview:self.beautyShinySlider];
    [self.beautyShinySlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.beautySlider.mas_top).offset(-30 * SCREENSCALE);
        make.centerX.equalTo(self.topView.mas_centerX);
        make.width.offset(273 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    
    [self.beautySlider layoutIfNeeded];
    [self.beautyShinySlider layoutIfNeeded];
    [self.beautyShinySlider setupTextLabel:NvBundleLocalString(@"半径", nil, [self class])];
    
    self.beautyBCView = [UIView new];
    self.beautyBCView.backgroundColor = UIColor.clearColor;
    [self.bottomView addSubview:_beautyBCView];
    
    [_beautyBCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBtn.mas_bottom).offset(1 * SCREENSCALE);
        make.width.equalTo(self.bottomView.mas_width);
        make.bottom.equalTo(self.bottomView.mas_bottom);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(49*SCREENSCALE, 79*SCREENSCALE);
    layout.minimumLineSpacing = 20*SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 11*SCREENSCALE, 0, 0);
    self.beautyCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,0,0) collectionViewLayout:layout];
    self.beautyCollectionView.delegate = self;
    self.beautyCollectionView.dataSource = self;
    self.beautyCollectionView.backgroundColor = [UIColor clearColor];
    self.beautyCollectionView.showsHorizontalScrollIndicator = NO;
    [_beautyBCView addSubview:self.beautyCollectionView];
    [self.beautyCollectionView registerClass:[NvBeautyTypeCViewCell class] forCellWithReuseIdentifier:@"NvBeautyCViewCell"];
    [self.beautyCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBCView.mas_top).offset(10 * SCREENSCALE);
        make.left.equalTo(self.beautyBCView.mas_left);
        make.right.equalTo(self.beautyBCView.mas_right);
        make.height.offset(84 * SCREENSCALE);
    }];
    
    self.resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.resetBtn setTitle:NvBundleLocalString(@"重置", nil, [self class]) forState:UIControlStateNormal];
    [self.resetBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#707070"] forState:UIControlStateNormal];
    [self.resetBtn addTarget:self action:@selector(resetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.resetBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [self.resetBtn setImage:[NvARSceneUtils imageWithName:@"NvCaptureBeautyTypeReset"] forState:UIControlStateNormal];
    self.resetBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [_beautyBCView addSubview:self.resetBtn];
    [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.beautyBCView.mas_left).offset(5 * SCREENSCALE);
        make.top.equalTo(self.beautyCollectionView.mas_bottom).offset(18 * SCREENSCALE);
        make.width.offset(80 * SCREENSCALE);
        make.height.offset(20 * SCREENSCALE);
    }];
    
    self.beautySwitch = [[NvSwitchView alloc]initWithFrame:CGRectMake(0, 0, 32 * SCREENSCALE, 19 * SCREENSCALE) withType:2 withState:YES];
    self.beautySwitch.tag = 2000;
    
    self.beautyLabel = [UILabel new];
    self.beautyLabel.text = NvBundleLocalString(@"关闭美颜", nil, [self class]);
    self.beautyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#707070"];
    self.beautyLabel.font = [UIFont systemFontOfSize:12];
    
    [_beautyBCView addSubview:self.beautySwitch];
    [_beautyBCView addSubview:self.beautyLabel];
    
    [self.beautySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyCollectionView.mas_bottom).offset(18 * SCREENSCALE);
        make.right.equalTo(self.beautyBCView.mas_right).offset(-10 * SCREENSCALE);
        make.width.offset(32 * SCREENSCALE);
        make.height.offset(19 * SCREENSCALE);
    }];
    
    [self.beautyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.beautySwitch.mas_left).offset(-5 * SCREENSCALE);
        make.centerY.equalTo(self.beautySwitch.mas_centerY);
    }];
    
    self.filterSwitch = [[NvSwitchView alloc]initWithFrame:CGRectMake(0, 0, 32 * SCREENSCALE, 19 * SCREENSCALE) withType:2 withState:YES];
    [self.filterSwitch addTarget:self action:@selector(filterSharpenClick:) forControlEvents:UIControlEventTouchUpInside];
    [_beautyBCView addSubview:self.filterSwitch];
    
    self.filterLabel = [[UILabel alloc] init];
    self.filterLabel.text = NvBundleLocalString(@"校色", nil, [self class]);
    self.filterLabel.textColor = self.beautyLabel.textColor;
    self.filterLabel.font = [UIFont systemFontOfSize:11];
    [_beautyBCView addSubview:self.filterLabel];
    
    [self.filterSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.beautyLabel.mas_left).offset(-10*SCREENSCALE);
        make.width.mas_equalTo(32 * SCREENSCALE);
        make.height.mas_equalTo(19*SCREENSCALE);
        make.centerY.equalTo(self.beautyLabel.mas_centerY);
    }];
    
    [self.filterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.filterSwitch.mas_left).offset(-5*SCREENSCALE);
        make.centerY.equalTo(self.filterSwitch.mas_centerY);
    }];
    
    self.sharpenSwitch = [[NvSwitchView alloc]initWithFrame:CGRectMake(0, 0, 32 * SCREENSCALE, 19 * SCREENSCALE) withType:2 withState:YES];
    [self.sharpenSwitch addTarget:self action:@selector(filterSharpenClick:) forControlEvents:UIControlEventTouchUpInside];
    [_beautyBCView addSubview:self.sharpenSwitch];
    
    self.sharpenLabel = [[UILabel alloc] init];
    self.sharpenLabel.text = NvBundleLocalString(@"锐度", nil, [self class]);
    self.sharpenLabel.textColor = self.beautyLabel.textColor;
    self.sharpenLabel.font = [UIFont systemFontOfSize:11];
    [_beautyBCView addSubview:self.sharpenLabel];
    
    [self.sharpenSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.beautyLabel.mas_left).offset(-10*SCREENSCALE);
        make.width.mas_equalTo(32 * SCREENSCALE);
        make.height.mas_equalTo(19*SCREENSCALE);
        make.centerY.equalTo(self.beautyLabel.mas_centerY);
    }];
    
    [self.sharpenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.sharpenSwitch.mas_left).offset(-5*SCREENSCALE);
        make.centerY.equalTo(self.sharpenSwitch.mas_centerY);
    }];
}

#pragma mark - 添加美型视图
///Add a beauty view
- (void)addBeautyType{
    self.beautyTypeSlider = [NvBeautySliderView new];
    self.beautyTypeSlider.hidden = YES;
    self.beautyTypeSlider.maxValue = 1;
    self.beautyTypeSlider.minValue = -1;
    self.beautyTypeSlider.delegate = self;
    [self.topView addSubview:self.beautyTypeSlider];
    [self.beautyTypeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10 * SCREENSCALE);
        make.centerX.equalTo(self.topView.mas_centerX);
        make.width.offset(273 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    
    [self.beautyTypeSlider layoutIfNeeded];
    
    self.beautyTypeBCView = [UIView new];
    self.beautyTypeBCView.backgroundColor = UIColor.clearColor;
    [self.bottomView addSubview:_beautyTypeBCView];
    
    [_beautyTypeBCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBtn.mas_bottom).offset(1 * SCREENSCALE);
        make.width.equalTo(self.bottomView.mas_width);
        make.bottom.equalTo(self.bottomView.mas_bottom);
    }];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(49*SCREENSCALE, 79*SCREENSCALE);
    layout.minimumLineSpacing = 20*SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 11*SCREENSCALE, 0, 0);
    self.beautyTypeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,0,0) collectionViewLayout:layout];
    self.beautyTypeCollectionView.delegate = self;
    self.beautyTypeCollectionView.dataSource = self;
    self.beautyTypeCollectionView.backgroundColor = [UIColor clearColor];
    self.beautyTypeCollectionView.showsHorizontalScrollIndicator = NO;
    [_beautyTypeBCView addSubview:self.beautyTypeCollectionView];
    [self.beautyTypeCollectionView registerClass:[NvBeautyTypeCViewCell class] forCellWithReuseIdentifier:@"NvBeautyTypeCViewCell"];
    [self.beautyTypeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyTypeBCView.mas_top).offset(10 * SCREENSCALE);
        make.left.equalTo(self.beautyTypeBCView.mas_left);
        make.right.equalTo(self.beautyTypeBCView.mas_right).offset(-10 * SCREENSCALE);
        make.height.offset(84 * SCREENSCALE);
    }];
    
    self.beautyTypeResetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beautyTypeResetBtn setTitle:NvBundleLocalString(@"重置", nil, [self class]) forState:UIControlStateNormal];
    [self.beautyTypeResetBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#707070"] forState:UIControlStateNormal];
    [self.beautyTypeResetBtn addTarget:self action:@selector(resetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.beautyTypeResetBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [self.beautyTypeResetBtn setImage:[NvARSceneUtils imageWithName:@"NvCaptureBeautyTypeReset"] forState:UIControlStateNormal];
    self.beautyTypeResetBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [_beautyTypeBCView addSubview:self.beautyTypeResetBtn];
    [self.beautyTypeResetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.beautyTypeBCView.mas_left).offset(5 * SCREENSCALE);
        make.top.equalTo(self.beautyTypeCollectionView.mas_bottom).offset(18 * SCREENSCALE);
        make.width.offset(80 * SCREENSCALE);
        make.height.offset(20 * SCREENSCALE);
    }];

    self.beautyTypeSwitch = [[NvSwitchView alloc]initWithFrame:CGRectMake(0, 0, 32 * SCREENSCALE, 19 * SCREENSCALE) withType:2 withState:YES];
    self.beautyTypeSwitch.tag = 2001;
    [_beautyTypeBCView addSubview:_beautyTypeSwitch];
    
    self.beautyTypeLabel = [UILabel new];
    self.beautyTypeLabel.text = NvBundleLocalString(@"关闭美型", nil, [self class]);
    self.beautyTypeLabel.textColor = [UIColor nv_colorWithHexRGB:@"#707070"];
    self.beautyTypeLabel.font = [UIFont systemFontOfSize:11];
    [_beautyTypeBCView addSubview:_beautyTypeLabel];
    
    [self.beautyTypeSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.beautyTypeBCView.mas_right).offset(-10 * SCREENSCALE);
        make.centerY.equalTo(self.beautyTypeLabel.mas_centerY);
        make.width.offset(32 * SCREENSCALE);
        make.height.offset(19 * SCREENSCALE);
    }];
    
    [self.beautyTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.beautyTypeResetBtn.mas_centerY);
        make.right.equalTo(self.beautyTypeSwitch.mas_left).offset(-5 * SCREENSCALE);
    }];
}

#pragma mark - 添加微整形视图
///Add a microshaping view
- (void)addBeautyTypeMicro{
    self.beautyTypeMicroSlider = [NvBeautySliderView new];
    self.beautyTypeMicroSlider.hidden = YES;
    self.beautyTypeMicroSlider.delegate = self;
    [self.topView addSubview:self.beautyTypeMicroSlider];
    [self.beautyTypeMicroSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10 * SCREENSCALE);
        make.centerX.equalTo(self.topView.mas_centerX);
        make.width.offset(273 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    [self.beautyTypeMicroSlider layoutIfNeeded];
    self.beautyTypeMicroBCView = [UIView new];
    self.beautyTypeMicroBCView.backgroundColor = UIColor.clearColor;
    [self.bottomView addSubview:self.beautyTypeMicroBCView];
    
    [self.beautyTypeMicroBCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBtn.mas_bottom).offset(1 * SCREENSCALE);
        make.width.equalTo(self.bottomView.mas_width);
        make.bottom.equalTo(self.bottomView.mas_bottom);
    }];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(49*SCREENSCALE, 79*SCREENSCALE);
    layout.minimumLineSpacing = 20*SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 11*SCREENSCALE, 0, 0);
    self.beautyTypeMicroCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,0,0) collectionViewLayout:layout];
    self.beautyTypeMicroCollectionView.delegate = self;
    self.beautyTypeMicroCollectionView.dataSource = self;
    self.beautyTypeMicroCollectionView.backgroundColor = [UIColor clearColor];
    self.beautyTypeMicroCollectionView.showsHorizontalScrollIndicator = NO;
    [self.beautyTypeMicroBCView addSubview:self.beautyTypeMicroCollectionView];
    [self.beautyTypeMicroCollectionView registerClass:[NvBeautyTypeCViewCell class] forCellWithReuseIdentifier:@"NvBeautyTypeCViewCell"];
    [self.beautyTypeMicroCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyTypeBCView.mas_top).offset(10 * SCREENSCALE);
        make.left.equalTo(self.beautyTypeBCView.mas_left);
        make.right.equalTo(self.beautyTypeBCView.mas_right).offset(-10 * SCREENSCALE);
        make.height.offset(84 * SCREENSCALE);
    }];
    
    self.beautyMicroResetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beautyMicroResetBtn.tag = 4002;
    [self.beautyMicroResetBtn setTitle:NvBundleLocalString(@"重置", nil, [self class]) forState:UIControlStateNormal];
    [self.beautyMicroResetBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#707070"] forState:UIControlStateNormal];
    [self.beautyMicroResetBtn addTarget:self action:@selector(resetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.beautyMicroResetBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [self.beautyMicroResetBtn setImage:[NvARSceneUtils imageWithName:@"NvCaptureBeautyTypeReset"] forState:UIControlStateNormal];
    self.beautyMicroResetBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [_beautyTypeMicroBCView addSubview:self.beautyMicroResetBtn];
    [self.beautyMicroResetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.beautyTypeMicroBCView.mas_left).offset(5 * SCREENSCALE);
        make.top.equalTo(self.beautyTypeMicroCollectionView.mas_bottom).offset(18 * SCREENSCALE);
        make.width.offset(80 * SCREENSCALE);
        make.height.offset(20 * SCREENSCALE);
    }];
    
    self.beautyTypeMicroSwitch = [[NvSwitchView alloc]initWithFrame:CGRectMake(0, 0, 32 * SCREENSCALE, 19 * SCREENSCALE) withType:2 withState:YES];
    self.beautyTypeMicroSwitch.tag = 2002;
    [_beautyTypeMicroBCView addSubview:self.beautyTypeMicroSwitch];
    
    self.beautyTypeMicroLabel = [UILabel new];
    self.beautyTypeMicroLabel.text = NvBundleLocalString(@"关闭微整形", nil, [self class]);
    self.beautyTypeMicroLabel.textColor = [UIColor nv_colorWithHexRGB:@"#707070"];
    self.beautyTypeMicroLabel.font = [UIFont systemFontOfSize:11];
    [_beautyTypeMicroBCView addSubview:self.beautyTypeMicroLabel];
    
    [self.beautyTypeMicroSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.beautyTypeMicroBCView.mas_right).offset(-10 * SCREENSCALE);
        make.centerY.equalTo(self.beautyMicroResetBtn.mas_centerY);
        make.width.offset(32 * SCREENSCALE);
        make.height.offset(19 * SCREENSCALE);
    }];
    
    [self.beautyTypeMicroLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.beautyTypeMicroSwitch.mas_centerY);
        make.right.equalTo(self.beautyTypeMicroSwitch.mas_left).offset(-5 * SCREENSCALE);
    }];
}

#pragma mark - 锐化、校色开关交互
///Sharpening, color switch interaction
- (void)filterSharpenClick:(NvSwitchView *)sender{
    if(sender.selected){
        ///关闭
        ///close
        sender.backgroundColor = [UIColor nv_colorWithHexRGB:@"#A2A2A2"];
        sender.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
        sender.selected = NO;
        [UIView animateWithDuration:0.1 animations:^{
            sender.sliderView.frame = CGRectMake(2, 2, sender.sliderView.frame.size.width, sender.sliderView.frame.size.height);
        }];
    }else{
        ///开启
        ///open
        sender.backgroundColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"];
        sender.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
        sender.selected = YES;
        [UIView animateWithDuration:0.1 animations:^{
            sender.sliderView.frame = CGRectMake(sender.sliderView.frame.size.width, 2,sender.sliderView.frame.size.width, sender.sliderView.frame.size.height);
        }];
    }
    
    self.currentModel_1.open = sender.selected;
    self.beautySlider.value = self.currentModel_1.value;
    
    if ([self.currentModel_1.name isEqualToString:@"校色"] || [self.currentModel_1.name isEqualToString:@"color correction"]) {
        self.beautySlider.hidden = !sender.selected;
    }else{
        self.beautySlider.hidden = YES;
    }
    
    [self.delegate nvBeautyView:self withModel:self.currentModel_1 withState:YES];
}

#pragma mark - 重置按钮点击
///Reset button click
- (void)resetBtnClick:(UIButton *)sender{
    if ([self.resetBtn isEqual:sender]) {
        for (int i = 0; i<self.currentArray_1.count; i++) {
            NvBeautyTypeModel *model = self.currentArray_1[i];
            model.value = model.defaultValue;
            model.radiusValue = model.defaultRadiusValue;
        }
        [self.delegate nvBeautyView:self withModelArray:self.currentArray_1];
        [self.beautyCollectionView reloadData];
        
        self.beautySlider.value = self.currentModel_1.value;
        
        [self setupSliderStyle];
    }else if ([self.beautyTypeResetBtn isEqual:sender]){
        for (int i = 0; i<self.currentArray.count; i++) {
            NvBeautyTypeModel *model = self.currentArray[i];
            model.value = model.defaultValue;
            model.uuid = model.defaultShapePackage;
        }
        [self.delegate nvBeautyView:self withModelArray:self.currentArray];
        [self.beautyTypeCollectionView reloadData];
        
        self.beautyTypeSlider.value = self.currentModel.value;
    }else if ([self.beautyMicroResetBtn isEqual:sender]){
        for (int i = 0; i<self.beautyTypeMicroArray.count; i++) {
            NvBeautyTypeModel *model = self.beautyTypeMicroArray[i];
            model.value = model.defaultValue;
            model.uuid = model.defaultShapePackage;
        }
        [self.delegate nvBeautyView:self withModelArray:self.beautyTypeMicroArray];
        [self.beautyTypeMicroCollectionView reloadData];
        
        self.beautyTypeMicroSlider.value = self.currentMicroModel.value;
    }
}

#pragma mark - 配置美颜信息
///Configure the beauty data
- (void)configBeautyArray:(NSMutableArray *)array{
    self.currentArray_1 = [NSMutableArray array];
    [self.currentArray_1 addObjectsFromArray:array];
    [self.beautyCollectionView reloadData];
    
    for (NvBeautyTypeModel *model in self.currentArray_1) {
        if (model.selected) {
            self.currentModel_1 = model;
        }
    }
}

#pragma mark - 获取美颜数据
///Get beauty data
- (NSMutableArray *)getBeautyArrayData{
    return self.currentArray_1;
}

#pragma mark - 配置美型信息
///Configure the beautyShape data
- (void)configBeautyByteArray:(NSMutableArray *)array{
    self.currentArray = [NSMutableArray array];
    [self.currentArray addObjectsFromArray:array];
    [self.beautyTypeCollectionView reloadData];
    
    for (NvBeautyTypeModel *model in self.currentArray) {
        if (model.selected) {
            self.currentModel = model;
        }
    }
}

#pragma mark - 配置微整形数据
///Configure the micro-shaping data
- (void)configBeautyTypeMicroArray:(NSMutableArray *)array{
    self.beautyTypeMicroArray = [NSMutableArray array];
    [self.beautyTypeMicroArray addObjectsFromArray:array];
    [self.beautyTypeMicroCollectionView reloadData];
    
    for (NvBeautyTypeModel *model in self.beautyTypeMicroArray) {
        if (model.selected) {
            self.currentMicroModel = model;
        }
    }
}

#pragma mark - 刷新整体ui
///Refresh the overall ui
- (void)refreshUI{
    self.hiddenInteger = self.hiddenInteger;
}

#pragma mark - 切换美颜、美型、微整形界面回调方法
///Switch the interface callback method of beauty, beauty and micro shaping
- (void)setHiddenInteger:(NSInteger)hiddenInteger{
    _hiddenInteger = hiddenInteger;
    self.beautyTypeMicroBCView.hidden = YES;
    self.beautyTypeMicroSlider.hidden = YES;
    
    self.beautyTypeSlider.hidden = YES;
    self.beautyTypeBCView.hidden = YES;
    
    self.beautyBCView.hidden = YES;
    self.beautySlider.hidden = YES;
    self.beautyShinySlider.hidden = YES;
    
    [self.beautyBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#707070"] forState:UIControlStateNormal];
    [self.beautyTypeBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#707070"] forState:UIControlStateNormal];
    [self.beautyTypeMicroBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#707070"] forState:UIControlStateNormal];
   
    if (hiddenInteger == 0) {
        ///美颜
        ///beauty
        self.beautySlider.value = self.currentModel_1.value;
        self.beautySlider.hidden = !self.beautySwitch.isSelected;
        
        self.beautyBCView.hidden = NO;
        
        [self.beautyCollectionView reloadData];
        
        [self.beautyBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
        
        [self setupSliderStyle];
    }else if(hiddenInteger == 1){
        ///美型
        ///beautyShape
        self.beautyTypeSlider.value = self.currentModel.value;
        self.beautyTypeSlider.hidden = !self.beautyTypeSwitch.isSelected;
        
        self.beautyTypeBCView.hidden = NO;
        
        [self.beautyTypeCollectionView reloadData];
        
        [self.beautyTypeBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    }else if (hiddenInteger == 2){
        ///微整形
        ///microshaping
        self.beautyTypeMicroSlider.value = self.currentMicroModel.value;
        self.beautyTypeMicroSlider.hidden = !self.beautyTypeMicroSwitch.isSelected;
        
        self.beautyTypeMicroBCView.hidden = NO;
        
        [self.beautyTypeMicroCollectionView reloadData];
        
        [self.beautyTypeMicroBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    }
}

#pragma mark - 点击美颜、美型、微整形开关回调函数
///Click beauty, beauty, micro shaping switch callback function
- (void)editBool:(BOOL)edit withType:(NSInteger)type{
    if (type == 0) {
        ///美颜
        ///beauty
        for (NvBeautyTypeModel *model in self.currentArray_1) {
            model.isOperation = edit;
            model.value = edit?model.defaultValue:0;
            model.radiusValue = edit?model.defaultRadiusValue:0;
        }
        self.beautyCollectionView.userInteractionEnabled = edit;
        self.beautyCollectionView.scrollEnabled = edit;
        [self.beautyCollectionView reloadData];
        
        self.beautySlider.hidden = !edit;
        self.beautySlider.value = self.currentModel_1.value;
        
        self.beautyLabel.text = edit?NvBundleLocalString(@"关闭美颜", nil, [self class]):NvBundleLocalString(@"开启美颜", nil, [self class]);
        
        self.resetBtn.enabled = edit;
        
        [self setupSliderStyle];
        
        [self.delegate nvBeautyView:self withModelArray:self.currentArray_1 withOpen:edit];
    }else if(type == 1){
        ///美型
        ///beautyShape
        for (NvBeautyTypeModel *model in self.currentArray) {
            model.isOperation = edit;
            model.value = edit?model.defaultValue:0;
        }
        
        self.beautyTypeCollectionView.scrollEnabled = edit;
        self.beautyTypeCollectionView.userInteractionEnabled = edit;
        [self.beautyTypeCollectionView reloadData];
        
        self.beautyTypeSlider.hidden = !edit;
        self.beautyTypeSlider.value = self.currentModel.value;
        self.beautyTypeLabel.text = edit?NvBundleLocalString(@"关闭美型", nil, [self class]):NvBundleLocalString(@"开启美型", nil, [self class]);
        
        self.beautyTypeResetBtn.enabled = edit;
        
        [self.delegate nvBeautyView:self withModelArray:self.currentArray withOpen:edit];
    }else{
        for (NvBeautyTypeModel *model in self.beautyTypeMicroArray) {
            model.isOperation = edit;
            model.value = edit?model.defaultValue:0;
        }
        
        self.beautyTypeMicroCollectionView.scrollEnabled = edit;
        self.beautyTypeMicroCollectionView.userInteractionEnabled = edit;
        [self.beautyTypeMicroCollectionView reloadData];
        
        self.beautyTypeMicroSlider.hidden = !edit;
        self.beautyTypeMicroSlider.value = self.currentMicroModel.value;
        self.beautyTypeMicroLabel.text = edit?NvBundleLocalString(@"关闭微整形", nil, [self class]):NvBundleLocalString(@"开启微整形", nil, [self class]);
        
        self.beautyMicroResetBtn.enabled = edit;
        
        [self.delegate nvBeautyView:self withModelArray:self.beautyTypeMicroArray withOpen:edit];
    }
}

#pragma mark - 滑杆拖动的回调
///Slider drag callback
-(void)sliderValueChanged:(UISlider *)paramSender{
    if ([self.beautyTypeSlider.slider isEqual:paramSender]) {
        ///美型的调节
        ///The regulation of beautyShape form
        self.currentModel.value = paramSender.value;
        [self.delegate nvBeautyView:self withModel:self.currentModel withState:NO];
    }else if ([self.beautySlider.slider isEqual:paramSender]){
        ///美颜的调节
        ///The regulation of beauty form
        self.currentModel_1.value = paramSender.value;
        [self.delegate nvBeautyView:self withModel:self.currentModel_1 withState:NO];
    }else if ([self.beautyShinySlider.slider isEqual:paramSender]){
        ///去油光的半径调节
        ///The regulation of matte form
        self.currentModel_1.radiusValue = paramSender.value;
        [self.delegate nvBeautyView:self withModel:self.currentModel_1 withState:NO];
    }else if ([self.beautyTypeMicroSlider.slider isEqual:paramSender]){
        ///微整形的调节
        ///The regulation of microshaping form
        self.currentMicroModel.value = paramSender.value;
        [self.delegate nvBeautyView:self withModel:self.currentMicroModel withState:NO];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.beautyCollectionView isEqual:collectionView]) {
        return self.currentArray_1.count;
    }else if ([self.beautyTypeCollectionView isEqual:collectionView]){
        return self.currentArray.count;
    }
    return self.beautyTypeMicroArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.beautyCollectionView isEqual:collectionView]) {
        NvBeautyTypeCViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvBeautyCViewCell" forIndexPath:indexPath];
        [cell renderCellWithModel:self.currentArray_1[indexPath.item]];
        return cell;
    }else if ([self.beautyTypeCollectionView isEqual:collectionView]){
        NvBeautyTypeCViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvBeautyTypeCViewCell" forIndexPath:indexPath];
        [cell renderCellWithModel:self.currentArray[indexPath.item]];
        return cell;
    }
    
    NvBeautyTypeCViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvBeautyTypeCViewCell" forIndexPath:indexPath];
    [cell renderCellWithModel:self.beautyTypeMicroArray[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.beautyCollectionView isEqual:collectionView]) {
        ///美颜
        ///beauty
        for (NvBeautyTypeModel *model in self.currentArray_1) {
            model.selected = NO;
        }
        
        self.currentModel_1 = self.currentArray_1[indexPath.item];
        self.currentModel_1.selected = YES;
        self.beautySlider.value = self.currentModel_1.value;
        self.beautySlider.hidden = NO;
        
        [self setupSliderStyle];
        
        [self.delegate nvBeautyView:self withModel:self.currentModel_1 withState:YES];
    }else if([self.beautyTypeCollectionView isEqual:collectionView]){
        ///美型
        ///beautyShape
        for (NvBeautyTypeModel *model in self.currentArray) {
            model.selected = NO;
        }
        self.currentModel = self.currentArray[indexPath.item];
        self.currentModel.selected = YES;
        
        self.beautyTypeSlider.value = self.currentModel.value;
    }else{
        ///微整形
        ///microshaping
        for (NvBeautyTypeModel *model in self.beautyTypeMicroArray) {
            model.selected = NO;
        }
        
        self.currentMicroModel = self.beautyTypeMicroArray[indexPath.item];
        self.currentMicroModel.selected = YES;
        
        [self setupSliderMinAndMax];
        self.beautyTypeMicroSlider.value = self.currentMicroModel.value;
    }
    
    [collectionView reloadData];
}

#pragma mark - 根据名称设置不同的最大值和最小值
///Set different maximum and minimum values based on the name
- (void)setupSliderMinAndMax{
    self.beautyTypeMicroSlider.minValue = self.currentMicroModel.minValue;
    self.beautyTypeMicroSlider.maxValue = self.currentMicroModel.maxValue;
}

#pragma mark - 处理去油光、校色、锐度的ui
///Handles ui for degreasing, color tuning, and sharpness
- (void)setupSliderStyle{
    self.beautyShinySlider.hidden = YES;
    self.filterSwitch.hidden = YES;
    self.filterLabel.hidden = YES;
    self.sharpenSwitch.hidden = YES;
    self.sharpenLabel.hidden = YES;
    [self.beautySlider setupTextLabel:@""];
    
    if ([self.currentModel_1.name isEqualToString:@"去油光"] || [self.currentModel_1.name isEqualToString:@"matte"]) {
        self.beautyShinySlider.value = self.currentModel_1.radiusValue;
        self.beautyShinySlider.hidden = !self.beautySwitch.isSelected;
        [self.beautySlider setupTextLabel:NvBundleLocalString(@"强度", nil, [self class])];
    }else if([self.currentModel_1.name isEqualToString:@"校色"] || [self.currentModel_1.name isEqualToString:@"color correction"]){
        self.filterSwitch.hidden = NO;
        self.filterLabel.hidden = NO;
        if (self.beautySwitch.isSelected) {
            self.filterSwitch.enabled = YES;
            self.beautySlider.hidden = !self.filterSwitch.isSelected;
        }else{
            self.filterSwitch.enabled = NO;
            self.beautySlider.hidden = YES;
        }
    }else if ([self.currentModel_1.name isEqualToString:@"锐度"] || [self.currentModel_1.name isEqualToString:@"sharpness"]){
        self.sharpenSwitch.hidden = NO;
        self.sharpenLabel.hidden = NO;
        self.beautySlider.hidden = YES;
        if (self.beautySwitch.isSelected) {
            self.sharpenSwitch.enabled = YES;
        }else{
            self.sharpenSwitch.enabled = NO;
        }
    }
    
    if (!self.beautySwitch.isSelected) {
        self.sharpenSwitch.selected = YES;
        [self filterSharpenClick:self.sharpenSwitch];
        self.filterSwitch.selected = YES;
        [self filterSharpenClick:self.filterSwitch];
    }
}

@end
