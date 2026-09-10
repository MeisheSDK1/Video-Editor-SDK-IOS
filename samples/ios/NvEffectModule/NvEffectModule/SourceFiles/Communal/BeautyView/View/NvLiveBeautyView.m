//
//  NvLiveBeautyView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvLiveBeautyView.h"
#import "NvLiveCaptureFilterModel.h"
#import "NvLiveBeautySliderView.h"
#import "NvLiveARSceneUtils.h"
#import "Masonry.h"
#import "UIColor+NvLiveColor.h"
#import "NvLiveBeautyTypeModel.h"
#import "NvLiveSwitchView.h"
#import "NvLiveBeautyTypeCollectionCell.h"
#import "NvLiveARSeceneCaptureFilterCell.h"
#import "NvLiveAppEnv.h"

@interface NvLiveBeautyView () <UICollectionViewDelegate, UICollectionViewDataSource, NvLiveBeautySliderViewDelegate>

@property(nonatomic, strong) UIView *topView;

@property(nonatomic, strong) UIView *bottomView;

@property(nonatomic, strong) UIView *beautyBCView;

@property(nonatomic, strong) UILabel *beautyLabel;

@property(nonatomic, strong) NvLiveBeautySliderView *beautySlider;

@property(nonatomic, strong) NvLiveBeautySliderView *beautyShinySlider;

@property(nonatomic, strong) UILabel *filterLabel;

@property(nonatomic, strong) NvLiveSwitchView *filterSwitch;

@property(nonatomic, strong) NvLiveSwitchView *sharpenSwitch;

@property(nonatomic, strong) UILabel *sharpenLabel;

@property(nonatomic, strong) UICollectionView *beautyCollectionView;

@property(nonatomic, strong) UIButton *resetBtn;

@property(nonatomic, strong) NSMutableArray *currentArray_1;

@property(nonatomic, strong) NSMutableArray *currentBeautyArray;

@property (nonatomic, strong) NSMutableArray *originalBeautyArray;

@property(nonatomic, strong) NvLiveBeautyTypeModel *currentModel_1;

@property(nonatomic, strong) UIView *beautyTypeBCView;

@property(nonatomic, strong) UILabel *beautyTypeLabel;

@property(nonatomic, strong) NvLiveBeautySliderView *beautyTypeSlider;

@property(nonatomic, strong) UICollectionView *beautyTypeCollectionView;

@property(nonatomic, strong) UIButton *beautyTypeResetBtn;

@property(nonatomic, strong) NSMutableArray *currentArray;

@property(nonatomic, strong) NvLiveBeautyTypeModel *currentModel;

@property(nonatomic, strong) UIView *beautyTypeMicroBCView;

@property(nonatomic, strong) UILabel *beautyTypeMicroLabel;

@property(nonatomic, strong) NvLiveBeautySliderView *beautyTypeMicroSlider;

@property(nonatomic, strong) UICollectionView *beautyTypeMicroCollectionView;

@property(nonatomic, strong) UIButton *beautyMicroResetBtn;

@property(nonatomic, strong) NSMutableArray *beautyTypeMicroArray;

@property(nonatomic, strong) NvLiveBeautyTypeModel *currentMicroModel;

@end

@implementation NvLiveBeautyView

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self addSubviews];
    }
    return self;
}

#pragma mark - 添加子视图
- (void)addSubviews {
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = UIColor.clearColor;

    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = UIColor.whiteColor;
    
    self.beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beautyBtn setTitle:NvLocalString(@"skin_beauty", @"美肤") forState:UIControlStateNormal];
    self.beautyBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.beautyBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    self.beautyBtn.backgroundColor = UIColor.clearColor;

    self.beautyTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beautyTypeBtn setTitle:NvLocalString(@"facetype", @"美型") forState:UIControlStateNormal];
    self.beautyTypeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.beautyTypeBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#707070"] forState:UIControlStateNormal];
    self.beautyTypeBtn.backgroundColor = UIColor.clearColor;

    self.beautyTypeMicroBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beautyTypeMicroBtn setTitle:NvLocalString(@"small_change", @"微整形") forState:UIControlStateNormal];
    self.beautyTypeMicroBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.beautyTypeMicroBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#707070"] forState:UIControlStateNormal];
    self.beautyTypeMicroBtn.backgroundColor = UIColor.clearColor;

    [self.beautyBtn addTarget:self action:@selector(beautyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.beautyTypeBtn addTarget:self action:@selector(beautyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.beautyTypeMicroBtn addTarget:self action:@selector(beautyClick:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.beautyBtn];
    [self.bottomView addSubview:self.beautyTypeBtn];
    [self.bottomView addSubview:self.beautyTypeMicroBtn];

    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.width.equalTo(self.mas_width);
        make.height.offset(100 * NvScreen(kScale));
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
        make.width.offset(self.frame.size.width / 3);
        make.height.offset(30 * NvScreen(kScale));
    }];

    [self.beautyTypeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top);
        make.centerX.equalTo(self);
        make.width.offset(self.frame.size.width / 3);
        make.height.offset(30 * NvScreen(kScale));
    }];

    [self.beautyTypeMicroBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top);
        make.right.equalTo(self);
        make.width.offset(self.frame.size.width / 3);
        make.height.offset(30 * NvScreen(kScale));
    }];

    [self layoutIfNeeded];
    [self addBeauty];
    [self addBeautyType];
    [self addBeautyTypeMicro];

    [self.beautySwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.beautyTypeSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.beautyTypeMicroSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 添加美颜视图
- (void)addBeauty {
    self.beautySlider = [[NvLiveBeautySliderView alloc] initWithFrame:CGRectMake((NvScreen(kWidth)-273 * NvScreen(kScale))/2.0, CGRectGetMaxY(self.topView.frame) - 50 * NvScreen(kScale), 273 * NvScreen(kScale), 30 * NvScreen(kScale))];
    self.beautySlider.delegate = self;
    self.beautySlider.hidden = YES;
    [self.topView addSubview:self.beautySlider];

    self.beautyShinySlider = [[NvLiveBeautySliderView alloc] initWithFrame:CGRectMake((NvScreen(kWidth)-273 * NvScreen(kScale))/2.0, CGRectGetMaxY(self.topView.frame) - 50 * NvScreen(kScale), 273 * NvScreen(kScale), 30 * NvScreen(kScale))];
    self.beautyShinySlider.delegate = self;
    self.beautyShinySlider.hidden = YES;
    [self.topView addSubview:self.beautyShinySlider];

    self.beautyBCView = [UIView new];
    self.beautyBCView.backgroundColor = UIColor.clearColor;
    [self.bottomView addSubview:_beautyBCView];

    [_beautyBCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBtn.mas_bottom).offset(1 * NvScreen(kScale));
        make.width.equalTo(self.bottomView.mas_width);
        make.bottom.equalTo(self.bottomView.mas_bottom);
    }];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(52 * NvScreen(kScale), 90 * NvScreen(kScale));
    layout.minimumLineSpacing = 20 * NvScreen(kScale);
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 11 * NvScreen(kScale), 0, 0);
    self.beautyCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
    self.beautyCollectionView.delegate = self;
    self.beautyCollectionView.dataSource = self;
    self.beautyCollectionView.backgroundColor = [UIColor clearColor];
    self.beautyCollectionView.showsHorizontalScrollIndicator = NO;
    [_beautyBCView addSubview:self.beautyCollectionView];
    [self.beautyCollectionView registerClass:[NvLiveBeautyTypeCollectionCell class] forCellWithReuseIdentifier:@"NveBeautyCViewCell"];
    [self.beautyCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBCView.mas_top).offset(10 * NvScreen(kScale));
        make.left.equalTo(self.beautyBCView.mas_left);
        make.right.equalTo(self.beautyBCView.mas_right);
        make.height.offset(90 * NvScreen(kScale));
    }];
    
    self.resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.resetBtn setTitle:NvLocalString(@"reset", @"重置") forState:UIControlStateNormal];
    [self.resetBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#707070"] forState:UIControlStateNormal];
    [self.resetBtn addTarget:self action:@selector(resetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.resetBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [self.resetBtn setImage:[NvLiveARSceneUtils imageNamed:@"NvCaptureBeautyTypeReset"] forState:UIControlStateNormal];
    self.resetBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [_beautyBCView addSubview:self.resetBtn];
    [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.beautyBCView.mas_left).offset(5 * NvScreen(kScale));
        make.top.equalTo(self.beautyCollectionView.mas_bottom).offset(18 * NvScreen(kScale));
        make.width.offset(80 * NvScreen(kScale));
        make.height.offset(20 * NvScreen(kScale));
    }];

    self.beautySwitch = [[NvLiveSwitchView alloc] initWithFrame:CGRectMake(0, 0, 32 * NvScreen(kScale), 19 * NvScreen(kScale)) withType:2 withState:YES];
    self.beautySwitch.tag = 2000;

    self.beautyLabel = [UILabel new];
    self.beautyLabel.text = NvLocalString(@"beauty_close", @"关闭");
    self.beautyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#707070"];
    self.beautyLabel.font = [UIFont systemFontOfSize:12];

    [_beautyBCView addSubview:self.beautySwitch];
    [_beautyBCView addSubview:self.beautyLabel];

    [self.beautySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyCollectionView.mas_bottom).offset(18 * NvScreen(kScale));
        make.right.equalTo(self.beautyBCView.mas_right).offset(-10 * NvScreen(kScale));
        make.width.offset(32 * NvScreen(kScale));
        make.height.offset(19 * NvScreen(kScale));
    }];

    [self.beautyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.beautySwitch.mas_left).offset(-5 * NvScreen(kScale));
        make.centerY.equalTo(self.beautySwitch.mas_centerY);
    }];

    self.filterSwitch = [[NvLiveSwitchView alloc] initWithFrame:CGRectMake(0, 0, 32 * NvScreen(kScale), 19 * NvScreen(kScale)) withType:2 withState:YES];
    [self.filterSwitch addTarget:self action:@selector(filterSharpenClick:) forControlEvents:UIControlEventTouchUpInside];
    [_beautyBCView addSubview:self.filterSwitch];

    self.filterLabel = [[UILabel alloc] init];
    self.filterLabel.text = @"校色";
    self.filterLabel.textColor = self.beautyLabel.textColor;
    self.filterLabel.font = [UIFont systemFontOfSize:11];
    [_beautyBCView addSubview:self.filterLabel];

    [self.filterSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.beautyLabel.mas_left).offset(-10 * NvScreen(kScale));
        make.width.mas_equalTo(32 * NvScreen(kScale));
        make.height.mas_equalTo(19 * NvScreen(kScale));
        make.centerY.equalTo(self.beautyLabel.mas_centerY);
    }];

    [self.filterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.filterSwitch.mas_left).offset(-5 * NvScreen(kScale));
        make.centerY.equalTo(self.filterSwitch.mas_centerY);
    }];

    self.sharpenSwitch = [[NvLiveSwitchView alloc] initWithFrame:CGRectMake(0, 0, 32 * NvScreen(kScale), 19 * NvScreen(kScale)) withType:2 withState:YES];
    [self.sharpenSwitch addTarget:self action:@selector(filterSharpenClick:) forControlEvents:UIControlEventTouchUpInside];
    [_beautyBCView addSubview:self.sharpenSwitch];

    self.sharpenLabel = [[UILabel alloc] init];
    self.sharpenLabel.text = @"锐度";
    self.sharpenLabel.textColor = self.beautyLabel.textColor;
    self.sharpenLabel.font = [UIFont systemFontOfSize:11];
    [_beautyBCView addSubview:self.sharpenLabel];

    [self.sharpenSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.beautyLabel.mas_left).offset(-10 * NvScreen(kScale));
        make.width.mas_equalTo(32 * NvScreen(kScale));
        make.height.mas_equalTo(19 * NvScreen(kScale));
        make.centerY.equalTo(self.beautyLabel.mas_centerY);
    }];

    [self.sharpenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.sharpenSwitch.mas_left).offset(-5 * NvScreen(kScale));
        make.centerY.equalTo(self.sharpenSwitch.mas_centerY);
    }];
}

#pragma mark - 添加美型视图
- (void)addBeautyType {
    self.beautyTypeSlider = [[NvLiveBeautySliderView alloc] initWithFrame:CGRectMake((NvScreen(kWidth)-273 * NvScreen(kScale))/2.0, CGRectGetMaxY(self.topView.frame) - 50 * NvScreen(kScale), 273 * NvScreen(kScale), 30 * NvScreen(kScale))];
    self.beautyTypeSlider.delegate = self;
    self.beautyTypeSlider.hidden = YES;
    [self.topView addSubview:self.beautyTypeSlider];

    self.beautyTypeBCView = [UIView new];
    self.beautyTypeBCView.backgroundColor = UIColor.clearColor;
    [self.bottomView addSubview:_beautyTypeBCView];

    [_beautyTypeBCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBtn.mas_bottom).offset(1 * NvScreen(kScale));
        make.width.equalTo(self.bottomView.mas_width);
        make.bottom.equalTo(self.bottomView.mas_bottom);
    }];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(49 * NvScreen(kScale), 90 * NvScreen(kScale));
    layout.minimumLineSpacing = 20 * NvScreen(kScale);
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 11 * NvScreen(kScale), 0, 0);
    self.beautyTypeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
    self.beautyTypeCollectionView.delegate = self;
    self.beautyTypeCollectionView.dataSource = self;
    self.beautyTypeCollectionView.backgroundColor = [UIColor clearColor];
    self.beautyTypeCollectionView.showsHorizontalScrollIndicator = NO;
    [_beautyTypeBCView addSubview:self.beautyTypeCollectionView];
    [self.beautyTypeCollectionView registerClass:[NvLiveBeautyTypeCollectionCell class] forCellWithReuseIdentifier:@"NvLiveBeautyTypeCollectionCell"];
    [self.beautyTypeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyTypeBCView.mas_top).offset(10 * NvScreen(kScale));
        make.left.equalTo(self.beautyTypeBCView.mas_left);
        make.right.equalTo(self.beautyTypeBCView.mas_right).offset(-10 * NvScreen(kScale));
        make.height.offset(90 * NvScreen(kScale));
    }];

    self.beautyTypeResetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beautyTypeResetBtn setTitle:NvLocalString(@"reset", @"重置") forState:UIControlStateNormal];
    [self.beautyTypeResetBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#707070"] forState:UIControlStateNormal];
    [self.beautyTypeResetBtn addTarget:self action:@selector(resetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.beautyTypeResetBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [self.beautyTypeResetBtn setImage:[NvLiveARSceneUtils imageNamed:@"NvCaptureBeautyTypeReset"] forState:UIControlStateNormal];
    self.beautyTypeResetBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [_beautyTypeBCView addSubview:self.beautyTypeResetBtn];
    [self.beautyTypeResetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.beautyTypeBCView.mas_left).offset(5 * NvScreen(kScale));
        make.top.equalTo(self.beautyTypeCollectionView.mas_bottom).offset(18 * NvScreen(kScale));
        make.width.offset(80 * NvScreen(kScale));
        make.height.offset(20 * NvScreen(kScale));
    }];

    self.beautyTypeSwitch = [[NvLiveSwitchView alloc] initWithFrame:CGRectMake(0, 0, 32 * NvScreen(kScale), 19 * NvScreen(kScale)) withType:2 withState:YES];
    self.beautyTypeSwitch.tag = 2001;
    [_beautyTypeBCView addSubview:_beautyTypeSwitch];

    self.beautyTypeLabel = [UILabel new];
    self.beautyTypeLabel.text = NvLocalString(@"beauty_shape_close", @"关闭");
    self.beautyTypeLabel.textColor = [UIColor nv_colorWithHexRGB:@"#707070"];
    self.beautyTypeLabel.font = [UIFont systemFontOfSize:11];
    [_beautyTypeBCView addSubview:_beautyTypeLabel];

    [self.beautyTypeSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.beautyTypeBCView.mas_right).offset(-10 * NvScreen(kScale));
        make.centerY.equalTo(self.beautyTypeLabel.mas_centerY);
        make.width.offset(32 * NvScreen(kScale));
        make.height.offset(19 * NvScreen(kScale));
    }];

    [self.beautyTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.beautyTypeResetBtn.mas_centerY);
        make.right.equalTo(self.beautyTypeSwitch.mas_left).offset(-5 * NvScreen(kScale));
    }];
}

#pragma mark - 添加微整形视图
- (void)addBeautyTypeMicro {
    self.beautyTypeMicroSlider = [[NvLiveBeautySliderView alloc] initWithFrame:CGRectMake((NvScreen(kWidth)-273 * NvScreen(kScale))/2.0, CGRectGetMaxY(self.topView.frame) - 50 * NvScreen(kScale), 273 * NvScreen(kScale), 30 * NvScreen(kScale))];
    self.beautyTypeMicroSlider.delegate = self;
    self.beautyTypeMicroSlider.hidden = YES;
    [self.topView addSubview:self.beautyTypeMicroSlider];
  
    [self.beautyTypeMicroSlider layoutIfNeeded];
    self.beautyTypeMicroBCView = [UIView new];
    self.beautyTypeMicroBCView.backgroundColor = UIColor.clearColor;
    [self.bottomView addSubview:self.beautyTypeMicroBCView];

    [self.beautyTypeMicroBCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBtn.mas_bottom).offset(1 * NvScreen(kScale));
        make.width.equalTo(self.bottomView.mas_width);
        make.bottom.equalTo(self.bottomView.mas_bottom);
    }];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(49 * NvScreen(kScale), 90 * NvScreen(kScale));
    layout.minimumLineSpacing = 20 * NvScreen(kScale);
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 11 * NvScreen(kScale), 0, 0);
    self.beautyTypeMicroCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
    self.beautyTypeMicroCollectionView.delegate = self;
    self.beautyTypeMicroCollectionView.dataSource = self;
    self.beautyTypeMicroCollectionView.backgroundColor = [UIColor clearColor];
    self.beautyTypeMicroCollectionView.showsHorizontalScrollIndicator = NO;
    [self.beautyTypeMicroBCView addSubview:self.beautyTypeMicroCollectionView];
    [self.beautyTypeMicroCollectionView registerClass:[NvLiveBeautyTypeCollectionCell class] forCellWithReuseIdentifier:@"NvLiveBeautyTypeCollectionCell"];
    [self.beautyTypeMicroCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyTypeBCView.mas_top).offset(10 * NvScreen(kScale));
        make.left.equalTo(self.beautyTypeBCView.mas_left);
        make.right.equalTo(self.beautyTypeBCView.mas_right).offset(-10 * NvScreen(kScale));
        make.height.offset(90 * NvScreen(kScale));
    }];

    self.beautyMicroResetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beautyMicroResetBtn.tag = 4002;
    [self.beautyMicroResetBtn setTitle:NvLocalString(@"reset", @"重置") forState:UIControlStateNormal];
    [self.beautyMicroResetBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#707070"] forState:UIControlStateNormal];
    [self.beautyMicroResetBtn addTarget:self action:@selector(resetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.beautyMicroResetBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [self.beautyMicroResetBtn setImage:[NvLiveARSceneUtils imageNamed:@"NvCaptureBeautyTypeReset"] forState:UIControlStateNormal];
    self.beautyMicroResetBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [_beautyTypeMicroBCView addSubview:self.beautyMicroResetBtn];
    [self.beautyMicroResetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.beautyTypeMicroBCView.mas_left).offset(5 * NvScreen(kScale));
        make.top.equalTo(self.beautyTypeMicroCollectionView.mas_bottom).offset(18 * NvScreen(kScale));
        make.width.offset(80 * NvScreen(kScale));
        make.height.offset(20 * NvScreen(kScale));
    }];

    self.beautyTypeMicroSwitch = [[NvLiveSwitchView alloc] initWithFrame:CGRectMake(0, 0, 32 * NvScreen(kScale), 19 * NvScreen(kScale)) withType:2 withState:YES];
    self.beautyTypeMicroSwitch.tag = 2002;
    [_beautyTypeMicroBCView addSubview:self.beautyTypeMicroSwitch];

    self.beautyTypeMicroLabel = [UILabel new];
    self.beautyTypeMicroLabel.text = NvLocalString(@"small_shape_close", @"关闭");
    self.beautyTypeMicroLabel.textColor = [UIColor nv_colorWithHexRGB:@"#707070"];
    self.beautyTypeMicroLabel.font = [UIFont systemFontOfSize:11];
    [_beautyTypeMicroBCView addSubview:self.beautyTypeMicroLabel];

    [self.beautyTypeMicroSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.beautyTypeMicroBCView.mas_right).offset(-10 * NvScreen(kScale));
        make.centerY.equalTo(self.beautyMicroResetBtn.mas_centerY);
        make.width.offset(32 * NvScreen(kScale));
        make.height.offset(19 * NvScreen(kScale));
    }];

    [self.beautyTypeMicroLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.beautyTypeMicroSwitch.mas_centerY);
        make.right.equalTo(self.beautyTypeMicroSwitch.mas_left).offset(-5 * NvScreen(kScale));
    }];
}

#pragma mark - 锐化、校色开关交互
- (void)filterSharpenClick:(NvLiveSwitchView *)sender {
    if (sender.selected) {
        //关闭
        sender.backgroundColor = [UIColor nv_colorWithHexRGB:@"#A2A2A2"];
        sender.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
        sender.selected = NO;
        [UIView animateWithDuration:0.1
                         animations:^{
                             sender.sliderView.frame = CGRectMake(2, 2, sender.sliderView.frame.size.width, sender.sliderView.frame.size.height);
                         }];
    } else {
        //开启
        sender.backgroundColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"];
        sender.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
        sender.selected = YES;
        [UIView animateWithDuration:0.1
                         animations:^{
                             sender.sliderView.frame = CGRectMake(sender.sliderView.frame.size.width, 2, sender.sliderView.frame.size.width, sender.sliderView.frame.size.height);
                         }];
    }

    self.currentModel_1.open = sender.selected;
    self.beautySlider.value = self.currentModel_1.value;

    if ([self.currentModel_1.name isEqualToString:@"校色"]) {
        self.beautySlider.hidden = !sender.selected;
    } else {
        self.beautySlider.hidden = YES;
    }

    [self.delegate NvLiveBeautyView:self withModel:self.currentModel_1 withState:YES];
}

#pragma mark - 重置按钮点击
- (void)resetBtnClick:(UIButton *)sender {
    if ([self.resetBtn isEqual:sender]) {
        [self configBeautyArray:self.originalBeautyArray];

        self.currentModel_1 = nil;
        [self setupSliderStyle];
        [self layoutBeautyviewBasedOnCurrentSelectedModel:self.currentModel_1];
        
        [self.delegate NvLiveBeautyView:self withModel:self.currentModel_1 withState:NO];
        [self.delegate NvLiveBeautyView:self withModelArray:self.originalBeautyArray];
    } else if ([self.beautyTypeResetBtn isEqual:sender]) {
        for (int i = 0; i < self.currentArray.count; i++) {
            NvLiveBeautyTypeModel *model = self.currentArray[i];
            model.value = model.defaultValue;
            model.uuid = model.defaultShapePackage;
        }
        [self.delegate NvLiveBeautyView:self withModelArray:self.currentArray];
        [self.beautyTypeCollectionView reloadData];

        self.beautyTypeSlider.value = self.currentModel.value;
        [self.beautyTypeSlider adsorb:YES adsorbValue:self.currentModel.defaultValue];
    } else if ([self.beautyMicroResetBtn isEqual:sender]) {
        for (int i = 0; i < self.beautyTypeMicroArray.count; i++) {
            NvLiveBeautyTypeModel *model = self.beautyTypeMicroArray[i];
            model.value = model.defaultValue;
            model.uuid = model.defaultShapePackage;
        }
        [self.delegate NvLiveBeautyView:self withModelArray:self.beautyTypeMicroArray];
        [self.beautyTypeMicroCollectionView reloadData];

        self.beautyTypeMicroSlider.value = self.currentMicroModel.value;
        [self.beautyTypeMicroSlider adsorb:YES adsorbValue:self.currentMicroModel.defaultValue];
    }
}

- (void)switchAction:(NvLiveSwitchView *)sender {
    [self switchSelectState:sender selected:sender.selected];
    NSInteger type = sender.tag - 2000;
    if (type != 0) {
        
        if (sender == self.beautyTypeSwitch) {
            [self switchSelectState:self.beautyTypeMicroSwitch selected:self.beautyTypeMicroSwitch.selected];
            [self editBool:self.beautyTypeMicroSwitch.selected withType:self.beautyTypeMicroSwitch.tag - 2000];
        } else if (sender == self.beautyTypeMicroSwitch) {
            [self switchSelectState:self.beautyTypeSwitch selected:self.beautyTypeSwitch.selected];
            [self editBool:self.beautyTypeSwitch.selected withType:self.beautyTypeSwitch.tag - 2000];
        }
    }
    [self editBool:sender.selected withType:sender.tag - 2000];
}

- (void)switchSelectState:(NvLiveSwitchView *)sender selected:(BOOL)selected {
    if (selected) {
        //关闭
        sender.backgroundColor = [UIColor nv_colorWithHexRGB:@"#A2A2A2"];
        sender.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
        sender.selected = NO;
        [UIView animateWithDuration:0.1
                         animations:^{
                             sender.sliderView.frame = CGRectMake(2, 2, sender.sliderView.frame.size.width, sender.sliderView.frame.size.height);
                         }];
    } else {
        sender.backgroundColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"];
        sender.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
        sender.selected = YES;
        [UIView animateWithDuration:0.1
                         animations:^{
            sender.sliderView.frame = CGRectMake(sender.sliderView.frame.size.width,
                                                 2,
                                                 sender.sliderView.frame.size.width,
                                                 sender.sliderView.frame.size.height);
        }];
    }
}

#pragma mark - 配置美颜信息
- (void)configBeautyArray:(NSMutableArray *)array {
    self.currentArray_1 = [NSMutableArray array];
    self.currentBeautyArray = [NSMutableArray array];
    [self.currentArray_1 addObjectsFromArray:array];
    self.originalBeautyArray = [[NSMutableArray alloc] initWithArray:array copyItems:YES];
    
    [self expansionData];
    
    [self.beautyCollectionView reloadData];
}

#pragma mark - 获取美颜数据
- (NSMutableArray *)getBeautyArrayData {
    return self.currentArray_1;
}

#pragma mark - 配置美型信息
- (void)configBeautyByteArray:(NSMutableArray *)array {
    self.currentArray = [NSMutableArray array];
    [self.currentArray addObjectsFromArray:array];
    [self.beautyTypeCollectionView reloadData];

    for (NvLiveBeautyTypeModel *model in self.currentArray) {
        if (model.selected) {
            self.currentModel = model;
        }
    }
}

#pragma mark - 配置微整形数据
- (void)configBeautyTypeMicroArray:(NSMutableArray *)array {
    self.beautyTypeMicroArray = [NSMutableArray array];
    [self.beautyTypeMicroArray addObjectsFromArray:array];
    [self.beautyTypeMicroCollectionView reloadData];

    for (NvLiveBeautyTypeModel *model in self.beautyTypeMicroArray) {
        if (model.selected) {
            self.currentMicroModel = model;
        }
    }
}

#pragma mark - 刷新整体ui
- (void)refreshUI {
    self.hiddenInteger = self.hiddenInteger;
}

#pragma mark - 切换美颜、美型、微整形界面回调方法
- (void)setHiddenInteger:(NSInteger)hiddenInteger {
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
        //美颜
        if (self.delegate && [self.delegate respondsToSelector:@selector(NvLiveBeautyView:valueWithModel:)]) {
            if (self.currentModel_1){
                self.currentModel_1.value = [self.delegate NvLiveBeautyView:self valueWithModel:self.currentModel_1];
            }
        }
        if (self.currentModel_1){
            self.beautySlider.value = self.currentModel_1.value;
            self.beautySlider.hidden = !self.beautySwitch.isSelected;
        }else{
            self.beautySlider.hidden = YES;
        }

        self.beautyBCView.hidden = NO;

        [self.beautyCollectionView reloadData];

        [self.beautyBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];

        [self setupSliderStyle];
    } else if (hiddenInteger == 1) {
        //美型
        if (self.delegate && [self.delegate respondsToSelector:@selector(NvLiveBeautyView:valueWithModel:)]) {
            self.currentModel.value = [self.delegate NvLiveBeautyView:self valueWithModel:self.currentModel];
        }
        
        if (self.currentModel) {
            self.beautyTypeSlider.value = self.currentModel.value;
            self.beautyTypeSlider.hidden = !self.beautyTypeSwitch.isSelected;
        } else {
            self.beautyTypeSlider.hidden = YES;
        }

        self.beautyTypeBCView.hidden = NO;

        [self.beautyTypeCollectionView reloadData];

        [self.beautyTypeBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    } else if (hiddenInteger == 2) {
        //微整形
        if (self.delegate && [self.delegate respondsToSelector:@selector(NvLiveBeautyView:valueWithModel:)]) {
            self.currentMicroModel.value = [self.delegate NvLiveBeautyView:self valueWithModel:self.currentMicroModel];
        }

        if (self.currentMicroModel) {
            self.beautyTypeMicroSlider.value = self.currentMicroModel.value;
            self.beautyTypeMicroSlider.hidden = !self.beautyTypeMicroSwitch.isSelected;
        } else {
            self.beautyTypeMicroSlider.hidden = YES;
        }
        
        self.beautyTypeMicroBCView.hidden = NO;

        [self.beautyTypeMicroCollectionView reloadData];

        [self.beautyTypeMicroBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    }
}

#pragma mark - 点击美颜、美型、微整形开关回调函数
- (void)editBool:(BOOL)edit withType:(NSInteger)type {
    if (type == 0) {
        //美颜
        //        for (NvLiveBeautyTypeModel *model in self.currentArray_1) {
        //            model.isOperation = edit;
        //            model.value = edit ? model.defaultValue : 0;
        //            model.radiusValue = edit ? model.defaultRadiusValue : 0;
        //        }
        self.beautyCollectionView.userInteractionEnabled = edit;
        self.beautyCollectionView.scrollEnabled = edit;
        [self.beautyCollectionView reloadData];
        if (self.currentModel_1) {
            self.beautySlider.hidden = !edit;
        } else {
            self.beautySlider.hidden = YES;
        }
        self.beautySlider.value = self.currentModel_1.value;
        self.beautyLabel.text = edit ? NvLocalString(@"beauty_close", @"关闭") : NvLocalString(@"beauty_open", @"开启");

        self.resetBtn.enabled = edit;

        [self setupSliderStyle];

        [self.delegate NvLiveBeautyView:self withModelArray:self.currentArray_1 withOpen:edit];
    } else if (type == 1) {
        //美型
        //        for (NvLiveBeautyTypeModel *model in self.currentArray) {
        //            model.isOperation = edit;
        //            model.value = edit ? model.defaultValue : 0;
        //        }

        self.beautyTypeCollectionView.scrollEnabled = edit;
        self.beautyTypeCollectionView.userInteractionEnabled = edit;
        [self.beautyTypeCollectionView reloadData];

        if (self.currentModel && self.hiddenInteger == 1) {
            self.beautyTypeSlider.hidden = !edit;
        } else {
            self.beautyTypeSlider.hidden = YES;
        }
        
        self.beautyTypeSlider.value = self.currentModel.value;
        self.beautyTypeLabel.text = edit ? NvLocalString(@"beauty_shape_close", @"关闭") : NvLocalString(@"beauty_shape_open", @"开启");

        self.beautyTypeResetBtn.enabled = edit;

        [self.delegate NvLiveBeautyView:self withModelArray:self.currentArray withOpen:edit];
    } else {
        //        for (NvLiveBeautyTypeModel *model in self.beautyTypeMicroArray) {
        //            model.isOperation = edit;
        //            model.value = edit ? model.defaultValue : 0;
        //        }

        self.beautyTypeMicroCollectionView.scrollEnabled = edit;
        self.beautyTypeMicroCollectionView.userInteractionEnabled = edit;
        [self.beautyTypeMicroCollectionView reloadData];

        if (self.currentMicroModel && self.hiddenInteger == 2) {
            self.beautyTypeMicroSlider.hidden = !edit;
        } else {
            self.beautyTypeMicroSlider.hidden = YES;
        }
        
        self.beautyTypeMicroSlider.value = self.currentMicroModel.value;
        self.beautyTypeMicroLabel.text = edit ? NvLocalString(@"small_shape_close", @"关闭") : NvLocalString(@"small_shape_open", @"开启");

        self.beautyMicroResetBtn.enabled = edit;

        [self.delegate NvLiveBeautyView:self withModelArray:self.beautyTypeMicroArray withOpen:edit];
    }
}

#pragma mark - NvLiveBeautySliderViewDelegate
- (void)itemSlider:(NvLiveBeautySliderView *)slider valueChanged:(float)value{
    if ([self.beautyTypeSlider isEqual:slider] && !self.beautyTypeSlider.hidden) {
        //美型的调节
        self.currentModel.value = slider.value;
        [self.delegate NvLiveBeautyView:self withModel:self.currentModel withState:YES];
    } else if ([self.beautySlider isEqual:slider] && !self.beautySlider.hidden) {
        //美颜的调节
        self.currentModel_1.value = slider.value;
        [self.delegate NvLiveBeautyView:self withModel:self.currentModel_1 withState:YES];
    } else if ([self.beautyShinySlider isEqual:slider] && !self.beautyShinySlider.hidden) {
        self.currentModel_1.value = slider.value;
        [self.delegate NvLiveBeautyView:self withModel:self.currentModel_1 withState:YES];
    } else if ([self.beautyTypeMicroSlider isEqual:slider] && !self.beautyTypeMicroSlider.hidden) {
        //微整形的调节
        self.currentMicroModel.value = slider.value;
        [self.delegate NvLiveBeautyView:self withModel:self.currentMicroModel withState:YES];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.beautyCollectionView isEqual:collectionView]) {
        return self.currentBeautyArray.count;
    } else if ([self.beautyTypeCollectionView isEqual:collectionView]) {
        return self.currentArray.count;
    }
    return self.beautyTypeMicroArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.beautyCollectionView isEqual:collectionView]) {
        NvLiveBeautyTypeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NveBeautyCViewCell" forIndexPath:indexPath];
        [cell renderCellWithModel:self.currentBeautyArray[indexPath.item]];
        return cell;
    } else if ([self.beautyTypeCollectionView isEqual:collectionView]) {
        NvLiveBeautyTypeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvLiveBeautyTypeCollectionCell" forIndexPath:indexPath];
        [cell renderCellWithModel:self.currentArray[indexPath.item]];
        return cell;
    }

    NvLiveBeautyTypeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvLiveBeautyTypeCollectionCell" forIndexPath:indexPath];
    [cell renderCellWithModel:self.beautyTypeMicroArray[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.beautyCollectionView isEqual:collectionView]) {
        /*
         美颜
         Beauty
         */
        NvLiveBeautyTypeModel *model = self.currentBeautyArray[indexPath.item];
        
        self.currentModel_1 = nil;
        
        if (model.expansion) {
            /// 实际应用数据
            /// Actual application data
            for (NvLiveBeautyTypeModel *tempModel in self.currentArray_1) {
                tempModel.expansion = NO;
            }
        }else{
            if (model.subprojectArray.count > 0){
                for (NvLiveBeautyTypeModel *tempModel in self.currentArray_1) {
                    tempModel.expansion = NO;
                }
                
                /// 视图数据
                /// View data
                for (NvLiveBeautyTypeModel *tempModel in self.currentBeautyArray) {
                    if (!tempModel.parentNode) {
                        tempModel.selected = NO;
                    }
                }
                
                model.expansion = YES;
                
                for (NvLiveBeautyTypeModel *tempModel in model.subprojectArray) {
                    if (tempModel.selected) {
                        self.currentModel_1 = tempModel;
                    }
                }
            }else{
                if (model.parentNode){
                    /// 视图数据
                    /// View data
                    for (NvLiveBeautyTypeModel *tempModel in self.currentBeautyArray) {
                        if (tempModel.parentNode){
                            tempModel.selected = NO;
                        }
                    }
                }else{
                    for (NvLiveBeautyTypeModel *tempModel in self.currentArray_1) {
                        tempModel.expansion = NO;
                    }
                    for (NvLiveBeautyTypeModel *tempModel in self.currentBeautyArray) {
                        if (!tempModel.parentNode){
                            tempModel.selected = NO;
                        }
                    }
                }
                
                model.selected = YES;
                self.currentModel_1 = model;
            }
        }
        
        [self expansionData];
        [self setupSliderStyle];
        [self layoutBeautyviewBasedOnCurrentSelectedModel:self.currentModel_1];
    } else if ([self.beautyTypeCollectionView isEqual:collectionView]) {
        //美型
        for (NvLiveBeautyTypeModel *model in self.currentArray) {
            model.selected = NO;
        }
        self.currentModel = self.currentArray[indexPath.item];
        self.currentModel.selected = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(NvLiveBeautyView:valueWithModel:)]) {
            self.currentModel.value = [self.delegate NvLiveBeautyView:self valueWithModel:self.currentModel];
        }
        
        [self.beautyTypeSlider adsorb:YES adsorbValue:self.currentModel.defaultValue];
        self.beautyTypeSlider.value = self.currentModel.value;
        self.beautyTypeSlider.hidden = NO;
        [self.delegate NvLiveBeautyView:self withModel:self.currentModel withState:NO];
    } else {
        //微整形
        for (NvLiveBeautyTypeModel *model in self.beautyTypeMicroArray) {
            model.selected = NO;
        }

        self.currentMicroModel = self.beautyTypeMicroArray[indexPath.item];
        self.currentMicroModel.selected = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(NvLiveBeautyView:valueWithModel:)]) {
            self.currentMicroModel.value = [self.delegate NvLiveBeautyView:self valueWithModel:self.currentMicroModel];
        }
        [self setupSliderMinAndMax];
        [self.beautyTypeMicroSlider adsorb:YES adsorbValue:self.currentMicroModel.defaultValue];
        self.beautyTypeMicroSlider.value = self.currentMicroModel.value;
        self.beautyTypeMicroSlider.hidden = NO;
        [self.delegate NvLiveBeautyView:self withModel:self.currentMicroModel withState:NO];
    }

    [collectionView reloadData];
}

- (void)expansionData{
    [self.currentBeautyArray removeAllObjects];
    
    for (NvLiveBeautyTypeModel *model in self.currentArray_1) {
        if (model.expansion) {
            for (NvLiveBeautyTypeModel *model1 in model.subprojectArray) {
                [self.currentBeautyArray addObject:model1];
            }
        }else{
            [self.currentBeautyArray addObject:model];
        }
    }
}

- (void)layoutBeautyviewBasedOnCurrentSelectedModel:(NvLiveBeautyTypeModel *)model {
    self.beautyShinySlider.hidden = YES;
    self.beautySlider.hidden = YES;
    self.filterSwitch.hidden = YES;
    self.filterLabel.hidden = YES;
    self.sharpenSwitch.hidden = YES;
    self.sharpenLabel.hidden = YES;
    
    if (model == nil){
        return;
    }
    
    [self.beautySlider adsorb:YES adsorbValue:model.defaultValue];
    [self.beautyShinySlider adsorb:YES adsorbValue:model.defaultValue];
    
    self.beautySlider.value = model.value;
    self.beautyShinySlider.value = model.value;
    
    if ([model.fxName isEqualToString:@"Shiny"] ) {
        self.beautyShinySlider.hidden = NO;
    } else if (self.beautySwitch.isSelected) {
        self.beautySlider.hidden = NO;
    }
    
    [self.delegate NvLiveBeautyView:self withModel:self.currentModel_1 withState:NO];
}

- (void)beautyClick:(UIButton *)sender {
    if (self.hiddenInteger==0 && [sender isEqual:self.beautyBtn]==false && self.currentModel_1.parentNode) {
        // 美肤中选择了具有父节点的特效（如磨皮1，磨皮2等）,这是直接选中美型或微整形tab 时需要整理currentModel_1值
        // 避免后续对这个对象进行操作时误将该特效已应用真实数据改变
        self.currentModel_1 = nil;
    }
    if ([sender isEqual:self.beautyBtn]) {
        self.hiddenInteger = 0;
        if (self.currentModel_1==nil) {
            // 当美肤中选择了具有父节点的特效（如磨皮1，磨皮2等），从其他tab 返回到美肤界面并且停留在已经展开的子节点界面时
            // 应该恢复currentModel_1 数值，及相关界面（如slider 等）
            for (NvLiveBeautyTypeModel *tempModel in self.currentBeautyArray) {
                if (tempModel.parentNode && tempModel.selected){
                    self.currentModel_1 = tempModel;
                    break;
                }
            }
            if (self.currentModel_1) {
                [self setupSliderStyle];
                [self layoutBeautyviewBasedOnCurrentSelectedModel:self.currentModel_1];
            }
        }
    } else if ([sender isEqual:self.beautyTypeBtn]) {
        self.hiddenInteger = 1;
    } else {
        self.hiddenInteger = 2;
    }
}

#pragma mark - 根据名称设置不同的最大值和最小值
- (void)setupSliderMinAndMax {
    self.beautyTypeMicroSlider.minValue = self.currentMicroModel.minValue;
    self.beautyTypeMicroSlider.maxValue = self.currentMicroModel.maxValue;
}

#pragma mark - 处理去油光、校色、锐度的ui
- (void)setupSliderStyle {
    self.beautyShinySlider.hidden = YES;
    self.filterSwitch.hidden = YES;
    self.filterLabel.hidden = YES;
    self.sharpenSwitch.hidden = YES;
    self.sharpenLabel.hidden = YES;

    if (!self.beautySwitch.isSelected) {
        self.sharpenSwitch.selected = YES;
        [self filterSharpenClick:self.sharpenSwitch];
        self.filterSwitch.selected = YES;
        [self filterSharpenClick:self.filterSwitch];
    }
}

@end
