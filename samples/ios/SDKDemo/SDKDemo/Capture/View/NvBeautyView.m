//
//  NvBeautyView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvBeautyView.h"
#import "NVHeader.h"
#import "NvMakeupModel.h"
#import "NvBeautySliderView.h"
#import "NvSumBeautyTypeCViewCell.h"
#import "NvBeautySegmentView.h"
#import "NvBeautyIntervalCell.h"
#import "BLItemSlider.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvTipsView.h"

@interface NvBeautyView()<UICollectionViewDelegate,UICollectionViewDataSource,NvBeautySliderViewDelegate,BLItemSliderDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

/// 对比按钮
/// Contrast button
@property (nonatomic, strong) UIButton *styleBtn;
/// 重置按钮
/// reset button
@property (nonatomic, strong) UIButton *resetBtn;
/// 返回按钮
/// Back button
@property (nonatomic, strong) UIButton *backBtn;
/// 提示视图
/// Prompt view
@property (nonatomic, strong) NvTipsView *tipsView;


/// 美颜模版视图 BeautyTemplate view
@property (nonatomic, strong) UIView *beautyTemplateBCView;
/// 美颜模版model数组
/// BeautyTemplate model array
@property (nonatomic, strong) NSMutableArray *currentBeautyTemplateArr;
/// 美颜模版初始数据，用于重置
/// BeautyTemplate initial data for reset
@property (nonatomic, strong) NSMutableArray *originalBeautyTemplateArr;
/// 美颜模版滚动视图
/// BeautyTemplate scroll view
@property (nonatomic, strong) UICollectionView *beautyTemplateCollectionView;
/// 美颜模版当前选中model
/// model is currently selected for BeautyTemplate
@property (nonatomic, strong) NvBeautyTemplateModel *currentBeautyTemplateModel;

/// 美颜视图
/// Beauty view
@property (nonatomic, strong) UIView *beautyBCView;
/// 美颜滚动视图
/// Beauty scroll view
@property (nonatomic, strong) UICollectionView *beautyCollectionView;
/// 美颜
/// beauty
@property (nonatomic, strong) BLItemSlider *beautySlider;
/// 美颜、美型、微整形、调节、修容滑杆文本显示
/// Beauty, beauty, micro shaping, adjusting, trimming slider text display
@property (nonatomic, strong) UILabel *beautySliderLbl;
/// 去油光
/// degreasing
@property (nonatomic, strong) BLItemSlider *beautySlider2;
/// 去油光滑杆文本显示
/// degreasing Slider text display
@property (nonatomic, strong) UILabel *beautySlider2Lbl;
/// 美颜model数组
/// Beauty model array
@property (nonatomic, strong) NSMutableArray *currentBeautyArr;
/// 美颜model数组
/// Beauty model array
@property (nonatomic, strong) NSMutableArray *currentBeautyArray;
/// 美颜初始数据，用于重置
/// Beauty initial data for reset
@property (nonatomic, strong) NSMutableArray *originalBeautyArray;
/// 美颜当前选中model
/// model is currently selected
@property (nonatomic, strong) NvBeautyTypeModel *currentBeautyModel;

/// 美型视图
/// Beauty type view
@property (nonatomic, strong) UIView *beautyTypeBCView;
/// 美型滚动视图
/// Beauty type scroll view
@property (nonatomic, strong) UICollectionView *beautyTypeCollectionView;
/// 美型model数组
/// Beauty type model array
@property (nonatomic, strong) NSMutableArray *currentShapeArray;
/// 美型初始数据，用于重置
/// The initial data of the beauty type is used for reset
@property (nonatomic, strong) NSMutableArray *originalShapeArray;
/// 美型
/// Beauty type
@property (nonatomic, strong) BLItemSlider *beautyTypeSlider;
/// 美型当前选中model
/// model is currently selected for Beauty type
@property (nonatomic, strong) NvBeautyTypeModel *currentShapeModel;

/// 微整形视图
/// Microshaping view
@property (nonatomic, strong) UIView *microShapingTypeBCView;
/// 微整形滚动视图
/// Microshaping scroll view
@property (nonatomic, strong) UICollectionView *microShapingCollectionView;
/// 微整形model数组
/// Microshaping model array
@property (nonatomic, strong) NSMutableArray *microShapingArray;
/// 微整形原始model数组
/// Microshaping the original model array
@property (nonatomic, strong) NSMutableArray *originalMicroShapingArray;
/// 微整形
/// microshaping
@property (nonatomic, strong) BLItemSlider *microShapingTypeSlider;
/// 美型当前选中model
/// model is currently selected for Beauty type
@property (nonatomic, strong) NvBeautyTypeModel *currentMicroShapingModel;

/// 调节视图
/// Adjustment view
@property (nonatomic, strong) UIView *adjustTypeBCView;
/// 调节滚动视图
/// Adjust scroll view
@property (nonatomic, strong) UICollectionView *adjustCollectionView;
/// 调节model数组
/// Adjust model array
@property (nonatomic, strong) NSMutableArray *adjustArray;
/// 调节原始model数组
/// Adjust the original model array
@property (nonatomic, strong) NSMutableArray *originalAdjustArray;
/// 调节模块使用的滑杆
/// Adjust the slide rod used by the module
@property (nonatomic, strong) BLItemSlider *adjustSlider;
/// 调节当前选中model
/// model is currently selected for Adjust
@property (nonatomic, strong) NvBeautyTypeModel *currentAdjustModel;

/// 修容视图
/// Contouring view
@property (nonatomic, strong) UIView *contouringTypeBCView;
/// 修容滚动视图
/// Contouring Scroll view
@property (nonatomic, strong) UICollectionView *contouringCollectionView;
/// 修容model数组
/// Contouring model array
@property (nonatomic, strong) NSMutableArray *contouringArray;
/// 修容原始model数组
/// Contouring the original model array
@property (nonatomic, strong) NSMutableArray *originalContouringArray;
/// 修容模块使用的滑杆
/// Contouring the slide rod used by the module
@property (nonatomic, strong) BLItemSlider *contouringSlider;
/// 修容当前选中model
/// model is currently selected for Contouring
@property (nonatomic, strong) NvBeautyTypeModel *currentContouringModel;

@property (nonatomic, assign) CGSize currentColloctionSize;
@property (nonatomic, assign) CGFloat currentColloctionLineSpacing;
@property (nonatomic, assign) UIEdgeInsets currentColloctionEdge;

@end

@implementation NvBeautyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.currentBeautyArray = [NSMutableArray array];
        self.forbiddenBeautyType = NO;
        [self addSubviews];
    }
    return self;
}

#pragma mark - 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubviews{
    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = UIColor.clearColor;
    
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    
    self.beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beautyBtn setTitle:NvLocalString(@"capture.beauty_2", @"美肤") forState:UIControlStateNormal];
    self.beautyBtn.titleLabel.font = [UIFont systemFontOfSize:13*SCREENSCALE];
    self.beautyBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.beautyBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#777777"] forState:UIControlStateNormal];
    self.beautyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.beautyBtn.backgroundColor = UIColor.clearColor;
    
    self.beautyTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beautyTypeBtn setTitle:NvLocalString(@"capture.beautype", @"美型") forState:UIControlStateNormal];
    self.beautyTypeBtn.titleLabel.font = [UIFont systemFontOfSize:13*SCREENSCALE];
    self.beautyTypeBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.beautyTypeBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#777777"] forState:UIControlStateNormal];
    self.beautyTypeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.beautyTypeBtn.backgroundColor = UIColor.clearColor;
    
    self.microShapingTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.microShapingTypeBtn setTitle:NvLocalString(@"microShaping", @"微整形") forState:UIControlStateNormal];
    self.microShapingTypeBtn.titleLabel.font = [UIFont systemFontOfSize:13*SCREENSCALE];
    self.microShapingTypeBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.microShapingTypeBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#777777"] forState:UIControlStateNormal];
    self.microShapingTypeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.microShapingTypeBtn.backgroundColor = UIColor.clearColor;
    
    self.adjustBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.adjustBtn setTitle:NvLocalString(@"capture.adjust", @"调节") forState:UIControlStateNormal];
    self.adjustBtn.titleLabel.font = [UIFont systemFontOfSize:13*SCREENSCALE];
    self.adjustBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.adjustBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#777777"] forState:UIControlStateNormal];
    self.adjustBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.adjustBtn.backgroundColor = UIColor.clearColor;
    
    self.contouringBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contouringBtn setTitle:NvLocalString(@"capture.contouring", @"修容") forState:UIControlStateNormal];
    self.contouringBtn.titleLabel.font = [UIFont systemFontOfSize:13*SCREENSCALE];
    self.contouringBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contouringBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#777777"] forState:UIControlStateNormal];
    self.contouringBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.contouringBtn.backgroundColor = UIColor.clearColor;

    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.beautyBtn];
    [self.bottomView addSubview:self.beautyTypeBtn];
    [self.bottomView addSubview:self.microShapingTypeBtn];
    [self.bottomView addSubview:self.adjustBtn];
    [self.bottomView addSubview:self.contouringBtn];
    
    NSArray *tempArray = @[self.beautyBtn,
                           self.beautyTypeBtn,
                           self.microShapingTypeBtn,
                           self.adjustBtn,
                           self.contouringBtn];
    for (int i = 0; i < tempArray.count; i++) {
        UILabel *label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor nv_colorWithHexRGB:@"#3A3A3A"];
        label.tag = 1000;
        label.hidden = YES;
        UIButton *btn = tempArray[i];
        [btn addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(btn.mas_bottom).offset(-1.5*SCREENSCALE);
            make.centerX.equalTo(btn);
            make.width.offset(15*SCREENSCALE);
            make.height.offset(1.5*SCREENSCALE);
        }];
    }
    
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.width.equalTo(self.mas_width);
        make.height.offset(444 * SCREENSCALE);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(self.mas_width);
    }];
    
    CGFloat btnMaxWidth = (SCREENWIDTH - KScale6s(90))/4;
    [self.beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top);
        make.left.equalTo(self).offset(15*SCREENSCALE);
        make.height.offset(35 * SCREENSCALE);
        make.width.mas_lessThanOrEqualTo(btnMaxWidth);
    }];
    
    [self.beautyTypeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top);
        make.left.equalTo(self.beautyBtn.mas_right).offset(15*SCREENSCALE);
        make.height.offset(35 * SCREENSCALE);
        make.width.mas_lessThanOrEqualTo(btnMaxWidth);
    }];
    
    [self.microShapingTypeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top);
        make.left.equalTo(self.beautyTypeBtn.mas_right).offset(15*SCREENSCALE);
        make.height.offset(35 * SCREENSCALE);
        make.width.mas_lessThanOrEqualTo(btnMaxWidth);
    }];
    
    [self.adjustBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top);
        make.left.equalTo(self.microShapingTypeBtn.mas_right).offset(15*SCREENSCALE);
        make.height.offset(35 * SCREENSCALE);
        make.width.mas_lessThanOrEqualTo(btnMaxWidth);
    }];
    
    [self.contouringBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top);
        make.left.equalTo(self.adjustBtn.mas_right).offset(15*SCREENSCALE);
        make.height.offset(35 * SCREENSCALE);
        make.width.mas_lessThanOrEqualTo(btnMaxWidth);
    }];
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn setImage:NvImageNamed(@"capture_beauty_back") forState:UIControlStateNormal];
    [self.bottomView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBtn.mas_bottom).offset(12 * SCREENSCALE);
        make.left.equalTo(self.bottomView.mas_left).offset(10 * SCREENSCALE);
        make.width.offset(50 * SCREENSCALE);
        make.height.offset(50 * SCREENSCALE);
    }];
    
    [self addBeautyTemplateView];
    [self addBeauty];
    [self addBeautyType];
    [self addMicroShapingView];
    [self addAdjustTypeBCView];
    [self addContouringTypeBCView];
    
    [self.beautyBtn addTarget:self action:@selector(beautyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.beautyTypeBtn addTarget:self action:@selector(beautyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.microShapingTypeBtn addTarget:self action:@selector(beautyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.adjustBtn addTarget:self action:@selector(beautyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contouringBtn addTarget:self action:@selector(beautyClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.styleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.styleBtn addTarget:self action:@selector(styleBtnInClick:) forControlEvents:UIControlEventTouchDown];
    [self.styleBtn addTarget:self action:@selector(styleBtnInClick:) forControlEvents:UIControlEventTouchDragInside];
    [self.styleBtn addTarget:self action:@selector(styleBtnOutClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.styleBtn addTarget:self action:@selector(styleBtnOutClick:) forControlEvents:UIControlEventTouchDragOutside];
    [self.styleBtn setImage:NvImageNamed(@"compare") forState:UIControlStateNormal];
    [self.topView addSubview:self.styleBtn];
    [self.styleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topView).offset(-15 * SCREENSCALE);
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10);
        make.width.offset(30 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    
    self.resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.resetBtn setTitle:NvLocalString(@"Reset", @"重置") forState:UIControlStateNormal];
    [self.resetBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#777777"] forState:UIControlStateNormal];
    [self.resetBtn addTarget:self action:@selector(resetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.resetBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [self.resetBtn setImage:NvImageNamed(@"NvCaptureBeautyTypeReset") forState:UIControlStateNormal];
    self.resetBtn.imageEdgeInsets = UIEdgeInsetsMake(-2, -13, 0, 0);
    [self.bottomView addSubview:self.resetBtn];
    [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-10 * SCREENSCALE);
        make.top.equalTo(self.bottomView).offset(145*SCREENSCALE);
        make.width.offset(80 * SCREENSCALE);
        make.height.offset(20 * SCREENSCALE);
    }];
}

#pragma mark - 添加美颜模版视图
/// Add Beauty template view
- (void)addBeautyTemplateView{
    self.beautyTemplateBCView = [UIView new];
    self.beautyTemplateBCView.backgroundColor = UIColor.whiteColor;
    [self.bottomView addSubview:self.beautyTemplateBCView];
    [self.beautyTemplateBCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView);
        make.left.equalTo(self.bottomView);
        make.right.equalTo(self.bottomView);
        make.bottom.equalTo(self.bottomView);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:NvLocalString(@"capture.beauty.template", @"美颜模版") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13*SCREENSCALE];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btn.backgroundColor = UIColor.clearColor;
    [btn setTitleColor:[UIColor nv_colorWithHexRGB:@"#1C1C1C"] forState:UIControlStateNormal];
    [self.beautyTemplateBCView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyTemplateBCView.mas_top);
        make.left.equalTo(self.beautyTemplateBCView).offset(15*SCREENSCALE);
        make.height.offset(35 * SCREENSCALE);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 10*SCREENSCALE, 0, 0);
    self.currentColloctionEdge = layout.sectionInset;
    self.currentColloctionLineSpacing = 5*SCREENSCALE ;
    self.currentColloctionSize = CGSizeMake(50*SCREENSCALE, 95*SCREENSCALE);
    self.beautyTemplateCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,0,0) collectionViewLayout:layout];
    self.beautyTemplateCollectionView.delegate = self;
    self.beautyTemplateCollectionView.dataSource = self;
    self.beautyTemplateCollectionView.backgroundColor = [UIColor clearColor];
    self.beautyTemplateCollectionView.showsHorizontalScrollIndicator = NO;
    [self.beautyTemplateBCView addSubview:self.beautyTemplateCollectionView];
    [self.beautyTemplateCollectionView registerClass:[NvBeautyTypeCViewCell class] forCellWithReuseIdentifier:@"NvBeautyBeautyTemplateCViewCell"];
    [self.beautyTemplateCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btn.mas_bottom).offset(10*SCREENSCALE);
        make.left.equalTo(self.beautyTemplateBCView.mas_left);
        make.right.equalTo(self.beautyTemplateBCView.mas_right);
        make.height.offset(96 * SCREENSCALE);
    }];
}

- (UICollectionView *)getBeautyTemplateCollectionView{
    return self.beautyTemplateCollectionView;
}

#pragma mark - 添加美颜视图
/*
 添加美颜视图
 Add beauty view
 */
- (void)addBeauty{
    
    self.beautySlider = [[BLItemSlider alloc] initWithFrame:CGRectMake(0, 0, 240 * SCREENSCALE, 30 * SCREENSCALE)];
    self.beautySlider.delegate = self;
    [self.topView addSubview:self.beautySlider];
    self.beautySlider.maximumTrackTintColor = [UIColor whiteColor];
    self.beautySlider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
    self.beautySlider.thumbImageView.image = [UIImage imageNamed:@"Nv_beauty_thumb"];
    [self.beautySlider modifyStylevalueLabel];
    [self.beautySlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10 * SCREENSCALE);
        make.centerX.equalTo(self.topView.mas_centerX).offset(20);
        make.width.offset(240 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    self.beautySlider.hidden = YES;
    
    self.beautySliderLbl = [[UILabel alloc]init];
    self.beautySliderLbl.font = [UIFont systemFontOfSize:11];
    self.beautySliderLbl.textColor = UIColor.whiteColor;
    self.beautySliderLbl.textAlignment = NSTextAlignmentCenter;
    self.beautySliderLbl.numberOfLines = 2;
    [self.topView addSubview:self.beautySliderLbl];
    [self.beautySliderLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.beautySlider);
        make.left.mas_equalTo(10*SCREENSCALE);
        make.right.equalTo(self.beautySlider.mas_left).offset(-10*SCREENSCALE);
    }];
    
    self.beautySlider2 = [[BLItemSlider alloc] initWithFrame:CGRectMake(0, 0, 240 * SCREENSCALE, 30 * SCREENSCALE)];
    self.beautySlider2.delegate = self;
    [self.topView addSubview:self.beautySlider2];
    self.beautySlider2.maximumTrackTintColor = [UIColor whiteColor];
    self.beautySlider2.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
    self.beautySlider2.thumbImageView.image = [UIImage imageNamed:@"Nv_beauty_thumb"];
    [self.beautySlider2 modifyStylevalueLabel];
    [self.beautySlider2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.beautySlider.mas_top).offset(-10 * SCREENSCALE);
        make.width.offset(240 * SCREENSCALE);
        make.centerX.equalTo(self.topView.mas_centerX).offset(20);
        make.height.offset(30 * SCREENSCALE);
    }];
    self.beautySlider2.hidden = YES;
    
    self.beautySlider2Lbl = [[UILabel alloc]init];
    self.beautySlider2Lbl.font = [UIFont systemFontOfSize:11];
    self.beautySlider2Lbl.textColor = UIColor.whiteColor;
    self.beautySlider2Lbl.textAlignment = NSTextAlignmentCenter;
    self.beautySlider2Lbl.text = NvLocalString(@"Radius2", @"半径");
    self.beautySlider2Lbl.numberOfLines = 2;
    [self.topView addSubview:self.beautySlider2Lbl];
    [self.beautySlider2Lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.beautySlider2);
        make.left.mas_equalTo(15*SCREENSCALE);
        make.right.equalTo(self.beautySlider2.mas_left).offset(-10*SCREENSCALE);
    }];
    
    self.beautyBCView = [UIView new];
    self.beautyBCView.backgroundColor = UIColor.clearColor;
    [self.bottomView addSubview:_beautyBCView];
    
    [_beautyBCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBtn.mas_bottom).offset(0 * SCREENSCALE);
        make.left.equalTo(self.backBtn.mas_right).offset(5*SCREENSCALE);
        make.right.equalTo(self.bottomView);
        make.bottom.equalTo(self.bottomView.mas_bottom);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 10*SCREENSCALE, 0, 0);
    self.currentColloctionEdge = layout.sectionInset;
    self.currentColloctionLineSpacing = 5*SCREENSCALE ;
    self.currentColloctionSize = CGSizeMake(50*SCREENSCALE, 95*SCREENSCALE);
    self.beautyCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,0,0) collectionViewLayout:layout];
    self.beautyCollectionView.delegate = self;
    self.beautyCollectionView.dataSource = self;
    self.beautyCollectionView.backgroundColor = [UIColor clearColor];
    self.beautyCollectionView.showsHorizontalScrollIndicator = NO;
    [_beautyBCView addSubview:self.beautyCollectionView];
    [self.beautyCollectionView registerClass:[NvBeautyTypeCViewCell class] forCellWithReuseIdentifier:@"NvBeautyCViewCell"];
    [self.beautyCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBCView.mas_top);
        make.left.equalTo(self.beautyBCView.mas_left);
        make.right.equalTo(self.beautyBCView.mas_right);
        make.height.offset(96 * SCREENSCALE);
    }];
}

#pragma mark - 添加美型视图
/*
 添加美型视图
 Add beauty view
 
 */
- (void)addBeautyType{
    self.beautyTypeBCView = [UIView new];
    self.beautyTypeBCView.backgroundColor = UIColor.clearColor;
    [self.bottomView addSubview:_beautyTypeBCView];
    
    [_beautyTypeBCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBtn.mas_bottom).offset(0 * SCREENSCALE);
        make.left.equalTo(self.backBtn.mas_right).offset(5*SCREENSCALE);
        make.right.equalTo(self.bottomView);
        make.bottom.equalTo(self.bottomView.mas_bottom);
    }];

    self.beautyTypeSlider = [[BLItemSlider alloc] initWithFrame:CGRectMake(0, 0, 240 * SCREENSCALE, 30 * SCREENSCALE)];
    self.beautyTypeSlider.delegate = self;
    [self.topView addSubview:self.beautyTypeSlider];
    self.beautyTypeSlider.maximumTrackTintColor = [UIColor whiteColor];
    self.beautyTypeSlider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
    self.beautyTypeSlider.thumbImageView.image = [UIImage imageNamed:@"Nv_beauty_thumb"];
    [self.beautyTypeSlider modifyStylevalueLabel];
    [self.beautyTypeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10 * SCREENSCALE);
        make.centerX.equalTo(self.topView.mas_centerX);
        make.width.offset(240 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    self.beautyTypeSlider.minValue = -1.0;
    self.beautyTypeSlider.maxValue = 1.0;

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 10*SCREENSCALE, 0, 0);
    self.currentColloctionEdge = layout.sectionInset;
    self.currentColloctionLineSpacing = 5*SCREENSCALE ;
    self.currentColloctionSize = CGSizeMake(50*SCREENSCALE, 95*SCREENSCALE);
    self.beautyTypeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,0,0) collectionViewLayout:layout];
    self.beautyTypeCollectionView.delegate = self;
    self.beautyTypeCollectionView.dataSource = self;
    self.beautyTypeCollectionView.backgroundColor = [UIColor clearColor];
    self.beautyTypeCollectionView.showsHorizontalScrollIndicator = NO;
    [_beautyTypeBCView addSubview:self.beautyTypeCollectionView];
    [self.beautyTypeCollectionView registerClass:[NvBeautyTypeCViewCell class] forCellWithReuseIdentifier:@"NvBeautyTypeCViewCell"];
    [self.beautyTypeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyTypeBCView.mas_top);
        make.left.equalTo(self.beautyTypeBCView.mas_left);
        make.right.equalTo(self.beautyTypeBCView.mas_right);
        make.height.offset(96*SCREENSCALE);
    }];
}

#pragma mark - 添加微整形视图
/// Add beauty view
- (void)addMicroShapingView{

    self.microShapingTypeSlider = [[BLItemSlider alloc] initWithFrame:CGRectMake(0, 0, 240 * SCREENSCALE, 30 * SCREENSCALE)];
    self.microShapingTypeSlider.delegate = self;
    self.microShapingTypeSlider.hidden = YES;
    [self.topView addSubview:self.microShapingTypeSlider];
    self.microShapingTypeSlider.maximumTrackTintColor = [UIColor whiteColor];
    self.microShapingTypeSlider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
    self.microShapingTypeSlider.thumbImageView.image = [UIImage imageNamed:@"Nv_beauty_thumb"];
    [self.microShapingTypeSlider modifyStylevalueLabel];
    [self.microShapingTypeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10 * SCREENSCALE);
        make.centerX.equalTo(self.topView.mas_centerX);
        make.width.offset(240 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];

    
    self.microShapingTypeBCView = [UIView new];
    self.microShapingTypeBCView.backgroundColor = UIColor.clearColor;
    [self.bottomView addSubview:_microShapingTypeBCView];
    
    [_microShapingTypeBCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBtn.mas_bottom).offset(0 * SCREENSCALE);
        make.left.equalTo(self.backBtn.mas_right).offset(5*SCREENSCALE);
        make.right.equalTo(self.bottomView);
        make.bottom.equalTo(self.bottomView.mas_bottom);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 10*SCREENSCALE, 0, 0);
    self.currentColloctionEdge = layout.sectionInset;
    self.currentColloctionLineSpacing = 5*SCREENSCALE ;
    self.currentColloctionSize = CGSizeMake(50*SCREENSCALE, 95*SCREENSCALE);
    self.microShapingCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,0,0) collectionViewLayout:layout];
    self.microShapingCollectionView.delegate = self;
    self.microShapingCollectionView.dataSource = self;
    self.microShapingCollectionView.backgroundColor = [UIColor clearColor];
    self.microShapingCollectionView.showsHorizontalScrollIndicator = NO;
    [_microShapingTypeBCView addSubview:self.microShapingCollectionView];
    [self.microShapingCollectionView registerClass:[NvBeautyTypeCViewCell class] forCellWithReuseIdentifier:@"NvMicroShapingViewCell"];
    [self.microShapingCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.microShapingTypeBCView.mas_top);
        make.left.equalTo(self.microShapingTypeBCView.mas_left);
        make.right.equalTo(self.microShapingTypeBCView.mas_right);
        make.height.offset(96 * SCREENSCALE);
    }];
}

#pragma mark - 添加调节视图
///Add adjustment view
- (void)addAdjustTypeBCView{
    self.adjustSlider = [[BLItemSlider alloc] initWithFrame:CGRectMake(0, 0, 240 * SCREENSCALE, 30 * SCREENSCALE)];
    self.adjustSlider.delegate = self;
    [self.topView addSubview:self.adjustSlider];
    self.adjustSlider.maximumTrackTintColor = [UIColor whiteColor];
    self.adjustSlider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
    self.adjustSlider.thumbImageView.image = [UIImage imageNamed:@"Nv_beauty_thumb"];
    [self.adjustSlider modifyStylevalueLabel];
    [self.adjustSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10 * SCREENSCALE);
        make.centerX.equalTo(self.topView.mas_centerX);
        make.width.offset(240 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    self.adjustSlider.minValue = 0;
    self.adjustSlider.maxValue = 1.0;
    
    self.adjustTypeBCView = [UIView new];
    self.adjustTypeBCView.backgroundColor = UIColor.clearColor;
    [self.bottomView addSubview:self.adjustTypeBCView];
    
    [self.adjustTypeBCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBtn.mas_bottom).offset(0 * SCREENSCALE);
        make.left.equalTo(self.backBtn.mas_right).offset(5*SCREENSCALE);
        make.right.equalTo(self.bottomView);
        make.bottom.equalTo(self.bottomView.mas_bottom);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 10*SCREENSCALE, 0, 0);
    self.currentColloctionEdge = layout.sectionInset;
    self.currentColloctionLineSpacing = 5*SCREENSCALE ;
    self.currentColloctionSize = CGSizeMake(50*SCREENSCALE, 95*SCREENSCALE);
    self.adjustCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,0,0) collectionViewLayout:layout];
    self.adjustCollectionView.delegate = self;
    self.adjustCollectionView.dataSource = self;
    self.adjustCollectionView.backgroundColor = [UIColor clearColor];
    self.adjustCollectionView.showsHorizontalScrollIndicator = NO;
    [self.adjustTypeBCView addSubview:self.adjustCollectionView];
    [self.adjustCollectionView registerClass:[NvBeautyTypeCViewCell class] forCellWithReuseIdentifier:@"NvBeautyAdjustCViewCell"];
    [self.adjustCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.adjustTypeBCView.mas_top);
        make.left.equalTo(self.adjustTypeBCView.mas_left);
        make.right.equalTo(self.adjustTypeBCView.mas_right);
        make.height.offset(96 * SCREENSCALE);
    }];
}

#pragma mark - 添加修容视图
///Add contouring view
- (void)addContouringTypeBCView{
    self.contouringSlider = [[BLItemSlider alloc] initWithFrame:CGRectMake(0, 0, 240 * SCREENSCALE, 30 * SCREENSCALE)];
    self.contouringSlider.delegate = self;
    [self.topView addSubview:self.contouringSlider];
    self.contouringSlider.maximumTrackTintColor = [UIColor whiteColor];
    self.contouringSlider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
    self.contouringSlider.thumbImageView.image = [UIImage imageNamed:@"Nv_beauty_thumb"];
    [self.contouringSlider modifyStylevalueLabel];
    [self.contouringSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10 * SCREENSCALE);
        make.centerX.equalTo(self.topView.mas_centerX);
        make.width.offset(240 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    self.contouringSlider.minValue = 0;
    self.contouringSlider.maxValue = 1.0;
    
    self.contouringTypeBCView = [UIView new];
    self.contouringTypeBCView.backgroundColor = UIColor.clearColor;
    [self.bottomView addSubview:self.contouringTypeBCView];
    
    [self.contouringTypeBCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beautyBtn.mas_bottom).offset(0 * SCREENSCALE);
        make.left.equalTo(self.backBtn.mas_right).offset(5*SCREENSCALE);
        make.right.equalTo(self.bottomView);
        make.bottom.equalTo(self.bottomView.mas_bottom);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 10*SCREENSCALE, 0, 10*SCREENSCALE);
    self.currentColloctionEdge = layout.sectionInset;
    self.currentColloctionLineSpacing = 5*SCREENSCALE ;
    self.currentColloctionSize = CGSizeMake(50*SCREENSCALE, 95*SCREENSCALE);
    self.contouringCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,0,0) collectionViewLayout:layout];
    self.contouringCollectionView.delegate = self;
    self.contouringCollectionView.dataSource = self;
    self.contouringCollectionView.backgroundColor = [UIColor clearColor];
    self.contouringCollectionView.showsHorizontalScrollIndicator = NO;
    [self.contouringTypeBCView addSubview:self.contouringCollectionView];
    [self.contouringCollectionView registerClass:[NvBeautyTypeCViewCell class] forCellWithReuseIdentifier:@"NvBeautyShadowCViewCell"];
    [self.contouringCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contouringTypeBCView.mas_top);
        make.left.equalTo(self.contouringTypeBCView.mas_left);
        make.right.equalTo(self.contouringTypeBCView.mas_right);
        make.height.offset(96 * SCREENSCALE);
    }];
}

#pragma mark - layoutSubviews
- (void)layoutSubviews{
    [super layoutSubviews];
}

#pragma mark - 对比按钮点击事件
///Contrast button click event
- (void)styleBtnInClick:(UIButton *)sender{
    [self touchDown];
}

- (void)styleBtnOutClick:(UIButton *)sender{
    [self touchUp];
}

#pragma mark 美颜视图，美颜按钮点击事件
/*
 美颜视图，美颜按钮点击事件
 Beauty view, beauty button click event
 */
- (void)beautyClick:(UIButton *)sender {
    if ([self.beautyBtn isEqual:sender]) {
        self.viewCategory = NvBeautyCategory;
    }else if ([self.beautyTypeBtn isEqual:sender]){
        self.viewCategory = NvBeautyTypeCategory;
    }else if ([self.microShapingTypeBtn isEqual:sender]){
        self.viewCategory = NvMicroShapingCategory;
    }else if ([self.adjustBtn isEqual:sender]){
        self.viewCategory = NvBeautyAdjustCategory;
    }else if ([self.contouringBtn isEqual:sender]){
        self.viewCategory = NvBeautyShadowCategory;
    }
}

#pragma mark backBtnClick——返回按钮点击
/// Back button click
- (void)backBtnClick:(UIButton *)sender{
    self.viewCategory = NvBeautyBeautyTemplate;
}

#pragma mark resetBtnClick——重置按钮点击
/*
 重置按钮点击
 Reset button click
 */
- (void)resetBtnClick:(UIButton *)sender{
    self.tipsView = [[NvTipsView alloc]initWithTitle:NvLocalString(@"Are you sure to restore all beauty parameters to default?",@"确定将所有美颜参数恢复到默认吗？") buttonText:NvLocalString(@"Cancel",@"取消") buttonText:NvLocalString(@"Sure", @"确定")];
    [self.superview addSubview:self.tipsView];
    
    [self.tipsView.clickBtn addTarget:self action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.tipsView.clickBtn1 addTarget:self action:@selector(clickSure) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickCancel{
    [self.tipsView removeFromSuperview];
}

- (void)clickSure{
    [self.tipsView removeFromSuperview];
    [self.captureVM resetBeautyTemplateData];
    
    [self configBeautyArray:self.captureVM.beautyFxArray];
    [self configBeautyByteArray:self.captureVM.shapeFxArray];
    [self configMicroShapingArray:self.captureVM.microShapingFxArray];
    [self configAdjustArray:self.captureVM.adjustArray];
    [self configContouringArray:self.captureVM.contouringArray];
    
    if (self.viewCategory != NvBeautyBeautyTemplate) {
        self.viewCategory = NvBeautyCategory;
    }
}

#pragma mark - 配置美颜信息 Configure beauty information
- (void)configBeautyArray:(NSMutableArray *)array{
    self.currentBeautyModel = nil;
    self.currentBeautyArr = [NSMutableArray array];
    self.originalBeautyArray = [[NSMutableArray alloc] initWithArray:array copyItems:YES];
    [self.currentBeautyArr addObjectsFromArray:array];
    [self.beautyCollectionView reloadData];
    
    [self expansionData];
}

#pragma mark - 配置美型信息 Configure beauty information
- (void)configBeautyByteArray:(NSMutableArray *)array{
    self.currentShapeModel = nil;
    
    self.currentShapeArray = [NSMutableArray array];
    self.originalShapeArray = [[NSMutableArray alloc] initWithArray:array copyItems:YES];
    [self.currentShapeArray addObjectsFromArray:array];
    [self.beautyTypeCollectionView reloadData];
}

#pragma mark - 配置微整形信息 Configure the micro-shaping information
- (void)configMicroShapingArray:(NSMutableArray *)array{
    self.currentMicroShapingModel = nil;
    
    self.microShapingArray = [NSMutableArray array];
    self.originalMicroShapingArray = [[NSMutableArray alloc] initWithArray:array copyItems:YES];
    [self.microShapingArray addObjectsFromArray:array];
    [self installCurrentMicroShapingModel];
    [self.microShapingCollectionView reloadData];
}

#pragma mark - 配置调节信息
///Configuration adjust information
- (void)configAdjustArray:(NSMutableArray *)array{
    self.currentAdjustModel = nil;
    self.adjustArray = [NSMutableArray array];
    self.originalAdjustArray = [[NSMutableArray alloc] initWithArray:array copyItems:YES];
    [self.adjustArray addObjectsFromArray:array];
    [self.adjustCollectionView reloadData];
}

#pragma mark - 配置修容信息
///Configuration contouring information
- (void)configContouringArray:(NSMutableArray *)array{
    self.currentContouringModel = nil;
    self.contouringArray = [NSMutableArray array];
    self.originalContouringArray= [[NSMutableArray alloc] initWithArray:array copyItems:YES];
    [self.contouringArray addObjectsFromArray:array];
    [self.contouringCollectionView reloadData];
    if(array.count > 0){
        self.contouringBtn.hidden = NO;
    }else{
        self.contouringBtn.hidden = YES;
    }
}

#pragma mark - 配置美颜模版信息
/// Configuration BeautyTemplate information
- (void)configBeautyTemplateArray:(NSMutableArray *)array{
    self.currentBeautyTemplateArr = [NSMutableArray array];
    self.originalBeautyTemplateArr= [[NSMutableArray alloc] initWithArray:array copyItems:YES];
    [self.currentBeautyTemplateArr addObjectsFromArray:array];
    [self.beautyTemplateCollectionView reloadData];
    
    for (NvBeautyTemplateModel *model in self.currentBeautyTemplateArr) {
        if (model.selected){
            self.currentBeautyTemplateModel = model;
        }
    }
    
    [self.beautyTemplateCollectionView setContentOffset:CGPointZero];
}

- (void)expansionData{
    [self.currentBeautyArray removeAllObjects];
    
    for (NvBeautyTypeModel *model in self.currentBeautyArr) {
        if (model.expansion) {
            for (NvBeautyTypeModel *model1 in model.subprojectArray) {
                [self.currentBeautyArray addObject:model1];
            }
        }else{
            [self.currentBeautyArray addObject:model];
        }
    }
}

- (void)layoutBeautyviewBasedOnCurrentSelectedModel:(NvBeautyTypeModel *)model {
    self.beautySlider.hidden = YES;
    self.beautySlider2.hidden = YES;
    self.beautySliderLbl.hidden = YES;
    self.beautySlider2Lbl.hidden = YES;
    
    if (model == nil){
        return;
    }
    
    [self.beautySlider adsorb:YES adsorbValue:model.defaultValue];
    [self.beautySlider2 adsorb:YES adsorbValue:model.defaultExtValue];
    
    self.beautySlider.value = model.value;
    self.beautySlider2.value = model.extValue;
    
    if ([model.fxName isEqualToString:@"Shiny"] ) {
        self.beautySlider2.hidden = NO;
        self.beautySlider2Lbl.hidden = NO;
        
        [self.beautySlider2 cancelAnimation];
    }
    
    self.beautySliderLbl.text = NvLocalString(model.nameEn, model.name);
    self.beautySlider.hidden = NO;
    [self.topView bringSubviewToFront:self.beautySlider];
    self.beautySliderLbl.hidden = NO;
}

#pragma mark - BLItemSliderDelegate
-(void)itemSliderChangeStart:(BLItemSlider *)slider {
    NSString *fxName;
    NSInteger type = 0;
    NvBeautyTypeModel *model;
    if ([self.beautySlider isEqual:slider] || [self.beautySlider2 isEqual:slider]){
        if (self.beautySlider.isHidden && self.beautySlider2.isHidden) {
            return;
        }
        type = NvBeautyCategory;
        fxName = self.currentBeautyModel.fxName;
        model = self.currentBeautyModel;
        if ([fxName isEqualToString:@"Shiny"]){
            if ([slider isEqual:self.beautySlider]) {
                [self.beautySlider2 cancelAnimation];
            }else{
                [self.beautySlider cancelAnimation];
            }
        }
    }else if ([self.beautyTypeSlider isEqual:slider] && !self.beautyTypeSlider.isHidden) {
        type = NvBeautyTypeCategory;
        fxName = self.currentShapeModel.fxName;
        model = self.currentShapeModel;
    }else if ([self.microShapingTypeSlider isEqual:slider] && !self.microShapingTypeSlider.isHidden){
        type = NvMicroShapingCategory;
        fxName = self.currentMicroShapingModel.fxName;
        model = self.currentMicroShapingModel;
    }else if ([self.adjustSlider isEqual:slider] && !self.adjustSlider.hidden){
        type = NvBeautyAdjustCategory;
        fxName = self.currentAdjustModel.fxName;
        model = self.currentAdjustModel;
    }else if ([self.contouringSlider isEqual:slider] && !self.contouringSlider.hidden){
        type = NvBeautyShadowCategory;
        fxName = self.currentContouringModel.fxName;
        model = self.currentContouringModel;
    }

    BOOL canReplace = [self canReplace:type fxName:fxName makeupEffect:_currentMakeupVariableModel];
    if (!canReplace) {
        slider.enable = NO;
        [self.captureVM applyBeautyWithForbiddenReplaceEffect:model];
    }else{
        slider.enable = YES;
    }
}

-(void)itemSlider:(BLItemSlider*)slider valueChanged:(float)value{
    if ([self.beautyTypeSlider isEqual:slider] && !self.beautyTypeSlider.isHidden) {
        self.currentShapeModel.value = slider.value;
        [self.captureVM applyBeautyModel:self.currentShapeModel withChange:YES];
    }else if ([self.beautySlider isEqual:slider] && !self.beautySlider.isHidden){
        self.currentBeautyModel.value = slider.value;
        [self.captureVM applyBeautyModel:self.currentBeautyModel withChange:YES];
    }else if ([self.beautySlider2 isEqual:slider] && !self.beautySlider2.isHidden){
        self.currentBeautyModel.extValue = slider.value;
        [self.captureVM applyBeautyModel:self.currentBeautyModel withChange:YES];
    }else if ([self.microShapingTypeSlider isEqual:slider] && !self.microShapingTypeSlider.isHidden){
        self.currentMicroShapingModel.value = slider.value;
        [self.captureVM applyBeautyModel:self.currentMicroShapingModel withChange:YES];
    }else if ([self.adjustSlider isEqual:slider] && !self.adjustSlider.hidden){
        self.currentAdjustModel.value = slider.value;
        [self.captureVM applyBeautyModel:self.currentAdjustModel withChange:YES];
    }else if ([self.contouringSlider isEqual:slider] && !self.contouringSlider.hidden){
        self.currentContouringModel.value = slider.value;
        [self.captureVM applyBeautyModel:self.currentContouringModel withChange:YES];
    }
}

-(void)itemSliderTouchEnd:(BLItemSlider*)slider{
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.beautyCollectionView isEqual:collectionView]) {
        return self.currentBeautyArray.count;
    }else if ([self.microShapingCollectionView isEqual:collectionView]) {
        return self.microShapingArray.count;
    }else if ([self.adjustCollectionView isEqual:collectionView]) {
        return self.adjustArray.count;
    }else if ([self.contouringCollectionView isEqual:collectionView]) {
        return self.contouringArray.count;
    }else if ([self.beautyTemplateCollectionView isEqual:collectionView]) {
        return self.currentBeautyTemplateArr.count;
    }
    return self.currentShapeArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.beautyCollectionView isEqual:collectionView]) {
        NvBeautyTypeModel *model = self.currentBeautyArray[indexPath.item];
        NvBeautyTypeCViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvBeautyCViewCell" forIndexPath:indexPath];
        [cell renderCellWithNewModel:model];
        return cell;
    }else if ([self.beautyTypeCollectionView isEqual:collectionView]) {
        NvBeautyTypeModel *model = self.currentShapeArray[indexPath.item];
        NvBeautyTypeCViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvBeautyTypeCViewCell" forIndexPath:indexPath];
        [cell renderCellWithNewModel:model];
        return cell;
    }else if ([self.microShapingCollectionView isEqual:collectionView]) {
        NvBeautyTypeCViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvMicroShapingViewCell" forIndexPath:indexPath];
        [cell renderCellWithNewModel:self.microShapingArray[indexPath.item]];
        return cell;
    }else if ([self.adjustCollectionView isEqual:collectionView]) {
        NvBeautyTypeCViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvBeautyAdjustCViewCell" forIndexPath:indexPath];
        [cell renderCellWithNewModel:self.adjustArray[indexPath.item]];
        return cell;
    }else if ([self.contouringCollectionView isEqual:collectionView]) {
        NvBeautyTypeCViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvBeautyShadowCViewCell" forIndexPath:indexPath];
        [cell renderCellWithNewModel:self.contouringArray[indexPath.item]];
        return cell;
    }else if ([self.beautyTemplateCollectionView isEqual:collectionView]) {
        NvBeautyTypeCViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvBeautyBeautyTemplateCViewCell" forIndexPath:indexPath];
        [cell renderCellWithStyleModel:self.currentBeautyTemplateArr[indexPath.item]];
        return cell;
    }
    NvBeautyTypeCViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvBeautyTypeCViewCell" forIndexPath:indexPath];
    [cell renderCellWithNewModel:self.currentShapeArray[indexPath.item]];
    return cell;
}

-(CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    if ([collectionView isEqual:self.beautyTemplateCollectionView]){
        NvBeautyTemplateModel *model = self.currentBeautyTemplateArr[indexPath.item];
        if (model.typeTemplate == 0){
            return  CGSizeMake(60*SCREENSCALE,  self.currentColloctionSize.height);
        }
    }
    return self.currentColloctionSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return self.currentColloctionLineSpacing;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.beautyCollectionView isEqual:collectionView]) {
        /*
         美颜
         Beauty
         */
        NvBeautyTypeModel *model = self.currentBeautyArray[indexPath.item];
        BOOL canReplace = [self canReplace:NvBeautyCategory fxName:model.fxName makeupEffect:_currentMakeupVariableModel];
        if (!canReplace) {
            [self.captureVM applyBeautyWithForbiddenReplaceEffect:model];
            return;
        }
        
        self.currentBeautyModel = nil;
        
        if (model.expansion) {
            /// 实际应用数据
            /// Actual application data
            for (NvBeautyTypeModel *tempModel in self.currentBeautyArr) {
                tempModel.expansion = NO;
            }
        }else{
            if (model.subprojectArray.count > 0){
                for (NvBeautyTypeModel *tempModel in self.currentBeautyArr) {
                    tempModel.expansion = NO;
                }
                
                /// 视图数据
                /// View data
                for (NvBeautyTypeModel *tempModel in self.currentBeautyArray) {
                    if (!tempModel.parentNode) {
                        tempModel.selected = NO;
                    }
                }
                
                model.expansion = YES;
                
                for (NvBeautyTypeModel *tempModel in model.subprojectArray) {
                    if (tempModel.selected) {
                        self.currentBeautyModel = tempModel;
                    }
                }
            }else{
                if (model.parentNode){
                    /// 视图数据
                    /// View data
                    for (NvBeautyTypeModel *tempModel in self.currentBeautyArray) {
                        if (tempModel.parentNode){
                            tempModel.selected = NO;
                        }
                    }
                }else{
                    for (NvBeautyTypeModel *tempModel in self.currentBeautyArr) {
                        tempModel.expansion = NO;
                    }
                    for (NvBeautyTypeModel *tempModel in self.currentBeautyArray) {
                        if (!tempModel.parentNode){
                            tempModel.selected = NO;
                        }
                    }
                }
                
                model.selected = YES;
                self.currentBeautyModel = model;
            }
        }
        
        [self expansionData];
        
        [self layoutBeautyviewBasedOnCurrentSelectedModel:self.currentBeautyModel];
        [self.captureVM applyBeautyModel:self.currentBeautyModel withChange:NO];
    }else if ([self.beautyTypeCollectionView isEqual:collectionView]){
        /*
         美型
         Beauty type
         */
        NvBeautyTypeModel *model = self.currentShapeArray[indexPath.item];
        BOOL canReplace = [self canReplace:NvBeautyTypeCategory fxName:model.fxName makeupEffect:_currentMakeupVariableModel];
        if (!canReplace) {
            [self.captureVM applyBeautyWithForbiddenReplaceEffect:model];
            return;
        }
        
        self.currentShapeModel = model;
        
        if (!self.currentShapeModel.uuid) {
            [self installCurrentShapeModel];
        }
       
        for (NvBeautyTypeModel *model in self.currentShapeArray) {
            model.selected = NO;
        }
        
        self.currentShapeModel.selected = YES;
        self.beautyTypeSlider.hidden = NO;
        [self.topView bringSubviewToFront:self.beautyTypeSlider];
        self.beautyTypeSlider.value = self.currentShapeModel.value;
        self.beautySliderLbl.text = NvLocalString(self.currentShapeModel.nameEn, self.currentShapeModel.name);
        self.beautySliderLbl.hidden = NO;
        
        [self.captureVM applyBeautyModel:self.currentShapeModel withChange:NO];
        
        [self.beautyTypeSlider adsorb:YES adsorbValue:self.currentShapeModel.defaultValue];
    }else if ([self.microShapingCollectionView isEqual:collectionView]){
        /*
         微整形
         microshaping
         */
        NvBeautyTypeModel *currentModel = self.microShapingArray[indexPath.item];
        if(currentModel.isOperation == NO && ([currentModel.packageUrl.pathExtension containsString:@"warp"] || [currentModel.packageUrl.pathExtension containsString:@"facemesh"])){
            [self.captureVM forbiddenApplyBeautyTypeEffectWithProps:currentModel];
            return;
        }
        for (NvBeautyTypeModel *model in self.microShapingArray) {
            model.selected = NO;
        }

        BOOL canReplace = [self canReplace:NvMicroShapingCategory fxName:currentModel.fxName makeupEffect:_currentMakeupVariableModel];
        if (!canReplace) {
            [self.captureVM applyBeautyWithForbiddenReplaceEffect:currentModel];
            return;
        }
        currentModel.selected = YES;
        self.currentMicroShapingModel = currentModel;
        [self updateMicroShapingTypeSliderLimitedValue:currentModel];
        if (!self.currentMicroShapingModel.uuid) {
            [self installCurrentMicroShapingModel];
        }
        self.microShapingTypeSlider.hidden = NO;
        [self.topView bringSubviewToFront:self.microShapingTypeSlider];
        self.microShapingTypeSlider.value = self.currentMicroShapingModel.value;
        self.beautySliderLbl.text = NvLocalString(self.currentMicroShapingModel.nameEn, self.currentMicroShapingModel.name);
        self.beautySliderLbl.hidden = NO;
        [self.microShapingTypeSlider adsorb:YES adsorbValue:self.currentMicroShapingModel.defaultValue];
        [self.captureVM applyBeautyModel:self.currentMicroShapingModel withChange:NO];
    }else if ([self.adjustCollectionView isEqual:collectionView]) {
        /*
         调节
         adjust
         */
        for (NvBeautyTypeModel *model in self.adjustArray) {
            model.selected = NO;
        }
        
        self.currentAdjustModel = self.adjustArray[indexPath.item];
        self.currentAdjustModel.selected = YES;
        self.adjustSlider.hidden = NO;
        [self.topView bringSubviewToFront:self.adjustSlider];
        self.adjustSlider.value = self.currentAdjustModel.value;
        self.beautySliderLbl.text = NvLocalString(self.currentAdjustModel.nameEn, self.currentAdjustModel.name);
        self.beautySliderLbl.hidden = NO;
        [self.captureVM applyBeautyModel:self.currentAdjustModel withChange:NO];
    }else if ([self.contouringCollectionView isEqual:collectionView]) {
        /*
         修容
         contouring
         */
        for (NvBeautyTypeModel *model in self.contouringArray) {
            model.selected = NO;
        }

        self.currentContouringModel = self.contouringArray[indexPath.item];
        self.currentContouringModel.selected = YES;
        self.contouringSlider.hidden = NO;
        [self.topView bringSubviewToFront:self.contouringSlider];
        self.contouringSlider.value = self.currentContouringModel.value;
        self.beautySliderLbl.text = NvLocalString(self.currentContouringModel.nameEn, self.currentContouringModel.name);
        self.beautySliderLbl.hidden = NO;
        [self.captureVM applyBeautyModel:self.currentContouringModel withChange:NO];
    }else if ([self.beautyTemplateCollectionView isEqual:collectionView]) {
        /*
         美颜模版
         Beauty template
         */
        for (NvBeautyTemplateModel *model in self.currentBeautyTemplateArr) {
            model.selected = NO;
        }

        NvBeautyTemplateModel *model = self.currentBeautyTemplateArr[indexPath.item];
        if (self.currentBeautyTemplateModel){
            if ([model isEqual:self.currentBeautyTemplateModel]) {
                self.viewCategory = NvBeautyCategory;
                UILabel *label = [self.beautyBtn viewWithTag:1000];
                label.hidden = NO;
            }
        }
        
        if (model.typeTemplate == 0){
            self.currentBeautyTemplateModel = nil;
        }else{
            self.currentBeautyTemplateModel = self.currentBeautyTemplateArr[indexPath.item];
            self.currentBeautyTemplateModel.selected = YES;
        }
        
        if (model.state == NODownload){
            model.state = Downloading;
        }
        
        self.captureVM.currentTemplatemodel = self.currentBeautyTemplateModel;
        [self.captureVM applyBeautyTemplateData];
    }
    
    [collectionView reloadData];
}

- (BOOL)canReplace:(NvBeautyViewCategory)type fxName:(NSString *)fxName makeupEffect:(NvMakeupToolModel *)model {
    BOOL canReplace = YES;
    if (!model) {
        return canReplace;
    }
    NvMakeupToolEffectContentModel *effectContentModel = model.effectContent;
    if (type == NvBeautyCategory) {
        //美颜 beauty
        for (NvMakeupToolEffectModel *effectModel in effectContentModel.beauty) {
            if ([effectModel.type isEqualToString:fxName]) {
                //目前只有“校色” 满足该条件 At present, only "school color" meets this condition
                canReplace = effectModel.canReplace;
                break;
            } else if([fxName isEqualToString:@"Beauty Strength"] ||
                      [fxName containsString:@"Advanced Beauty Type"]) {
                //磨皮,包含普通磨皮和高级磨皮 Dermabrasion, including ordinary dermabrasion and advanced dermabrasion
                BOOL containFx = NO;
                for(NvMakeupToolElementFloatModel *param in effectModel.params) {
                    if ([param.key containsString:@"Advanced Beauty Intensity"] || [param.key containsString:@"Beauty Strength"]) {
                        canReplace = effectModel.canReplace;
                        containFx = YES;
                        break;
                    }
                }
                if (containFx) {
                    break;
                }
            } else {
                BOOL containFx = NO;
                if (fxName.length > 0) {
                    for(NvMakeupToolElementFloatModel *param in effectModel.params) {
                        if ([param.key containsString:fxName]) {
                            canReplace = effectModel.canReplace;
                            containFx = YES;
                            break;
                        }
                    }
                }
                if (containFx) {
                    break;
                }
            }
            
        }
    }else if(type == NvBeautyTypeCategory) {
        //美型 Beauty type
        BOOL containFx = NO;
        for (NvMakeupToolEffectModel *effectModel in effectContentModel.shape) {
            if (fxName.length > 0) {
                for(NvMakeupToolElementFloatModel *param in effectModel.params) {
                    if ([param.key containsString:fxName]) {
                        canReplace = effectModel.canReplace;
                        containFx = YES;
                        break;
                    }
                }
            }
            if (containFx) {
                break;
            }
        }
    }else if(type == NvBeautyAdjustCategory) {
        BOOL containFx = NO;
        if (fxName.length > 0) {
            for (NvMakeupToolEffectModel *effectModel in effectContentModel.adjust) {
                if ([effectModel.type containsString:fxName]) {
                    canReplace = effectModel.canReplace;
                    containFx = YES;
                    break;
                }
                if (containFx) {
                    break;
                }
            }
        }
    }else if(type == NvBeautyShadowCategory) {
        BOOL containFx = NO;
        if (fxName.length > 0) {
            for (NvMakeupToolEffectModel *effectModel in effectContentModel.makeup) {
                for(NvMakeupToolElementFloatModel *param in effectModel.params) {
                    if ([param.key containsString:fxName]) {
                        canReplace = effectModel.canReplace;
                        containFx = YES;
                        break;
                    }
                }
                if (containFx) {
                    break;
                }
            }
        }
    }else {
        //微整形 microshaping
        BOOL containFx = NO;
        if (fxName.length > 0) {
            for (NvMakeupToolEffectModel *effectModel in effectContentModel.microShape) {
                for(NvMakeupToolElementFloatModel *param in effectModel.params) {
                    if ([param.key containsString:fxName]) {
                        canReplace = effectModel.canReplace;
                        containFx = YES;
                        break;
                    }
                }
                if (containFx) {
                    break;
                }
            }
        }
    }
    return canReplace;
}


- (void)touchDown{
    [self.captureVM discardCurrentEffect:YES];
}

- (void)touchUp{
    [self.captureVM discardCurrentEffect:NO];
}

- (void)forbiddenBeautyTypeInMicroShapingView:(BOOL)forbidden {
    for (NvBeautyTypeModel *model in self.microShapingArray) {
        if (model.packageUrl && ([model.packageUrl.pathExtension containsString:@"warp"] || [model.packageUrl.pathExtension containsString:@"facemesh"])) {
            model.isOperation = !forbidden;
        }
    }
    [self.microShapingCollectionView reloadData];
}

- (void)installCurrentShapeModel {
    NSMutableString *uuid;
    NSString * packageUrl = self.currentShapeModel.packageUrl;
    NSString * licensePath = [NSString convertFilePathToNewPath:packageUrl WithExtension:@"lic"];
    if ([packageUrl.pathExtension containsString:@"warp"]) {
        
        uuid = [NvSDKUtils installAssetPackage:packageUrl license:licensePath assetType:NvsAssetPackageType_Warp];
    }else if ([packageUrl.pathExtension containsString:@"facemesh"]) {
        
       uuid = [NvSDKUtils installAssetPackage:packageUrl license:licensePath assetType:NvsAssetPackageType_FaceMesh];
    }
    self.currentShapeModel.uuid = uuid;
}

- (void)installCurrentMicroShapingModel {
    NSMutableString *uuid;
    NSString * packageUrl = self.currentMicroShapingModel.packageUrl;
    NSString * licensePath = [NSString convertFilePathToNewPath:packageUrl WithExtension:@"lic"];
    if ([packageUrl.pathExtension containsString:@"warp"]) {
        
       uuid = [NvSDKUtils installAssetPackage:packageUrl license:licensePath assetType:NvsAssetPackageType_Warp];
    }else if ([packageUrl.pathExtension containsString:@"facemesh"]) {
        
       uuid = [NvSDKUtils installAssetPackage:packageUrl license:licensePath assetType:NvsAssetPackageType_FaceMesh];
    }
    self.currentMicroShapingModel.uuid = uuid;
}

#pragma mark - setter & getter
/// 切换美颜美型界面回调方法
/// Change the callback method of Meiyan Meimei interface
- (void)setViewCategory:(NvBeautyViewCategory)viewCategory {
    _viewCategory = viewCategory;
    
    NSArray *array = @[self.beautyBtn,
                       self.beautyTypeBtn,
                       self.microShapingTypeBtn,
                       self.adjustBtn,
                       self.contouringBtn
    ];
    for (UIButton *btn in array) {
        UILabel *label = [btn viewWithTag:1000];
        label.hidden = YES;
        [btn setTitleColor:[UIColor nv_colorWithHexRGB:@"#888888"] forState:UIControlStateNormal];
    }
    
    NSArray *array1 = @[self.beautyBCView,
              self.beautySlider,
              self.beautySlider2,
              self.beautySliderLbl,
              self.beautySlider2Lbl,
              self.beautyTypeBCView,
              self.beautyTypeSlider,
              self.microShapingTypeBCView,
              self.microShapingTypeSlider,
              self.adjustTypeBCView,
              self.adjustSlider,
              self.contouringTypeBCView,
              self.contouringSlider,
              self.beautyTemplateBCView
    ];
    for (UIView *view in array1) {
        view.hidden = YES;
    }
    
    self.resetBtn.hidden = NO;
    
    if (viewCategory == NvBeautyCategory) {
        self.beautyBCView.hidden = NO;
        [self.beautyBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#1C1C1C"] forState:UIControlStateNormal];
        UILabel *label = [self.beautyBtn viewWithTag:1000];
        label.hidden = NO;
        
        [self layoutBeautyviewBasedOnCurrentSelectedModel:self.currentBeautyModel];
    }else if (viewCategory == NvBeautyTypeCategory) {
        self.beautyTypeBCView.hidden = NO;
        [self.beautyTypeBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#1C1C1C"] forState:UIControlStateNormal];
        UILabel *label = [self.beautyTypeBtn viewWithTag:1000];
        label.hidden = NO;
        
        if (self.currentShapeModel) {
            self.beautyTypeSlider.hidden = NO;
            [self.topView bringSubviewToFront:self.beautyTypeSlider];
            self.beautySliderLbl.hidden = NO;
            self.beautySliderLbl.text = NvLocalString(self.currentShapeModel.nameEn,self.currentShapeModel.name);
        }
    }else if (viewCategory == NvMicroShapingCategory) {
        self.microShapingTypeBCView.hidden = NO;
        [self.microShapingTypeBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#1C1C1C"] forState:UIControlStateNormal];
        UILabel *label = [self.microShapingTypeBtn viewWithTag:1000];
        label.hidden = NO;
        
        if (self.currentMicroShapingModel) {
            self.microShapingTypeSlider.hidden = NO;
            [self.topView bringSubviewToFront:self.microShapingTypeSlider];
            self.beautySliderLbl.hidden = NO;
            self.beautySliderLbl.text = NvLocalString(self.currentMicroShapingModel.nameEn,self.currentMicroShapingModel.name);
        }
    }else if (viewCategory == NvBeautyAdjustCategory) {
        self.adjustTypeBCView.hidden = NO;
        [self.adjustBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#1C1C1C"] forState:UIControlStateNormal];
        UILabel *label = [self.adjustBtn viewWithTag:1000];
        label.hidden = NO;
        
        if (self.currentAdjustModel){
            self.adjustSlider.hidden = NO;
            [self.topView bringSubviewToFront:self.adjustSlider];
            self.adjustSlider.value = self.currentAdjustModel.value;
            self.beautySliderLbl.text = NvLocalString(self.currentAdjustModel.nameEn,self.currentAdjustModel.name);
            self.beautySliderLbl.hidden = NO;
        }
    }else if (viewCategory == NvBeautyShadowCategory) {
        self.contouringTypeBCView.hidden = NO;
        [self.contouringBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#1C1C1C"] forState:UIControlStateNormal];
        UILabel *label = [self.contouringBtn viewWithTag:1000];
        label.hidden = NO;
        
        if (self.currentContouringModel){
            self.contouringSlider.hidden = NO;
            [self.topView bringSubviewToFront:self.contouringSlider];
            self.contouringSlider.value = self.currentContouringModel.value;
            self.beautySliderLbl.text = NvLocalString(self.currentContouringModel.nameEn, self.currentContouringModel.name);
            self.beautySliderLbl.hidden = NO;
        }
    }else if (viewCategory == NvBeautyBeautyTemplate){
        self.beautyTemplateBCView.hidden = NO;
        
        self.currentBeautyModel = nil;
        self.currentShapeModel = nil;
        self.currentMicroShapingModel = nil;
        self.currentAdjustModel = nil;
        
        self.resetBtn.hidden = YES;
        
        [self showCustomTemplatesChange];
    }
    
    [self.beautySliderLbl sizeToFit];
}

- (int)getBeautyTemplateCount {
    return self.currentBeautyTemplateArr.count;
}

#pragma mark - showCustomTemplatesChange
///如果自定义模版中的任意一项数据有修改（这里的修改指的是数值上的修改）则界面需要显示一个点，代表模版数据有修改
///If any data in the custom template is modified (the modification here refers to the numerical modification), the interface needs to display a dot, indicating that the template data has been modified
- (void)showCustomTemplatesChange{
    if (self.currentBeautyTemplateModel.typeTemplate == 2){
        self.currentBeautyTemplateModel.displayChangedStatus = NO;
        for (NSDictionary *dict in self.currentBeautyTemplateModel.beautyTemplateData) {
            NSArray *array = dict.allValues.firstObject;
            for (NvBeautyTypeModel *model in array) {
                if(model.value != 0){
                    self.currentBeautyTemplateModel.displayChangedStatus = YES;
                }
            }
        }
    }
    [self.beautyTemplateCollectionView reloadData];
}

- (void)resetAll {
    
}

- (void)resetBeautyTypeAfterProps {
    
    
}

- (void)updateMicroShapingTypeSliderLimitedValue:(NvBeautyTypeModel *)model {
    if (model.fxName.length > 0 && [model.fxName containsString:@"Package Id"]) {
        self.microShapingTypeSlider.minValue = -1;
        self.microShapingTypeSlider.maxValue = 1;
    }else{
        self.microShapingTypeSlider.minValue = 0;
        self.microShapingTypeSlider.maxValue = 1;
    }
}

- (void)setCurrentVariableMakeup:(NvMakeupEffectModel *)currentVariableMakeup {
    _currentVariableMakeup = currentVariableMakeup;
    if(!currentVariableMakeup){
        return;
    }
}

- (void)setCurrentMakeupVariableModel:(NvMakeupToolModel *)currentMakeupVariableModel {
    _currentMakeupVariableModel = currentMakeupVariableModel;
    if (!currentMakeupVariableModel) {
        return;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect visibleRect = self.beautySlider2.hidden ? CGRectMake(0, 400 * SCREENSCALE, self.frame.size.width, self.frame.size.height) : CGRectMake(0, 360 * SCREENSCALE, self.frame.size.width, self.frame.size.height);
    if (CGRectContainsPoint(visibleRect, point)) {
        return [super hitTest:point withEvent:event];
    }
    return nil;
}

@end
