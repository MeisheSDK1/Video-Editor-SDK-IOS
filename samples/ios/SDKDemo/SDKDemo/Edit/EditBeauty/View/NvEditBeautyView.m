//
//  NvEditBeautyView.m
//  SDKDemo
//
//  Created by Meishe on 2022/11/15.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvEditBeautyView.h"
#import <JXCategoryView/JXCategoryView.h>
#import <CQMenuTabView.h>
#import "NvViewPager.h"
#import "BLItemSlider.h"
#import "NvBeautySegmentView.h"
#import "NvEditBeautyEffectView.h"
#import "NvEditShapeEffectView.h"
#import "NvEditMicroShapeEffectView.h"

@interface NvEditBeautyView ()<JXCategoryViewDelegate,NvPageViewDelegate,BLItemSliderDelegate,NvEditBeautyEffectViewDelegate,NvEditShapeEffectViewDelegate,NvEditMicroShapeEffectViewDelegate>
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) NvEditBeautyEffectView *beautyBottomView;
@property (nonatomic, strong) NvEditShapeEffectView *shapeBottomView;
@property (nonatomic, strong) NvEditMicroShapeEffectView *microShapeBottomView;
@property (nonatomic, strong) NvViewPager *viewPager;

@property (nonatomic, strong) BLItemSlider *slider;
//滑杆对应的label
// label corresponding to the slide bar
@property (nonatomic, strong) UILabel *infoLabel;
//额外滑杆
// Extra slider
@property (nonatomic, strong) BLItemSlider *extSlider;
//额外滑杆对应的label
// label corresponding to the additional slide bar
@property (nonatomic, strong) UILabel *infoExtLabel;
//美白模式视图
// Whitening mode view
@property (nonatomic, strong) NvBeautySegmentView *whitenSegView;
//预览按钮
// Preview button
@property (nonatomic, strong) UIButton *previewBtn;
//当前选中的美颜model
// Currently selected beauty model
@property (nonatomic, strong) NvBeautyTypeModel *currentBeautyModel;
//当前选中的美型model
// The currently selected beauty model
@property (nonatomic, strong) NvBeautyTypeModel *currentShapeModel;
//当前选中的微整形model
// The currently selected microshaping model
@property (nonatomic, strong) NvBeautyTypeModel *currentMicroShapeModel;

@end

@implementation NvEditBeautyView

- (instancetype)initWithContainAI:(BOOL)containAI {
    if (self = [super init]) {
        self.containAI = containAI;
        self.beautySwitchOpen = YES;
        self.shapeSwitchOpen = YES;
        self.microShapeSwitchOpen = YES;
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    self.beautyBottomView = [[NvEditBeautyEffectView alloc] init];
    self.beautyBottomView.delegate = self;
    self.shapeBottomView = [[NvEditShapeEffectView alloc] init];
    self.shapeBottomView.delegate = self;
    self.microShapeBottomView = [[NvEditMicroShapeEffectView alloc] init];
    self.microShapeBottomView.delegate = self;
    
    NSArray *titles;
    NSArray *views ;
    if (self.containAI) {
        titles = @[NvLocalString(@"capture.beauty_2", @"美肤"),
                   NvLocalString(@"capture.beautype", @"美型"),
                   NvLocalString(@"microShaping", @"微整形")];
        
        views = @[self.beautyBottomView,
                  self.shapeBottomView,
                  self.microShapeBottomView];
    }else {
        titles = @[NvLocalString(@"capture.beauty_2", @"美肤"),
                   NvLocalString(@"capture.beautype", @"美型")];
        
        views = @[self.beautyBottomView,
                  self.shapeBottomView];
    }
    
    self.viewPager = [[NvViewPager alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 200) subViews:views subTitles:titles];
    self.viewPager.categoryView.originalIndex = 0;
    self.viewPager.categoryView.collectionView.backgroundColor = [UIColor nv_colorWithHexString:@"#242728"];
    self.viewPager.categoryView.titleNomalFont = [NvUtils fontWithSize:13];
    self.viewPager.categoryView.titleNormalColor = [UIColor nv_colorWithHexRGBA:@"#FFFFFF85"];
    self.viewPager.categoryView.titleSelectedFont = [NvUtils fontWithSize:13];
    self.viewPager.categoryView.titleSelectedColor = [UIColor nv_colorWithHexString:@"#63ABFF"];
    self.viewPager.categoryView.underlineHeight = 1.f*SCREENSCALE;
    self.viewPager.categoryView.shortUnderline = YES;
    [self.viewPager insertFixedItemAtLastIndex:@"" imageName:@"nv_style_finish"];
    self.viewPager.delegate = self;
    [self addSubview:self.viewPager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageViewDidSelectIndex:) name:@"NvPagerViewSelected" object:nil];
    
    [self.viewPager mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.mas_bottom);
        }
        if (INDICATOR > 0){
            make.height.mas_equalTo(220);
        }else{
            make.height.mas_equalTo(150*SCREENSCALE);
        }
    }];
    
    self.topView = [[UIView alloc] init];
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(@0);
        if (INDICATOR > 0){
            make.bottom.equalTo(self.viewPager.mas_top).offset(-10*SCREENSCALE);
        }else{
            make.bottom.equalTo(self.viewPager.mas_top).offset(0*SCREENSCALE);
        }
    }];
    
    [self addTopSubview];
}

- (void)addTopSubview {
    self.slider = [[BLItemSlider alloc] initWithFrame:CGRectMake(0, 0, 240 * SCREENSCALE, 30 * SCREENSCALE)];
    self.slider.delegate = self;
    [self.topView addSubview:self.slider];
    self.slider.maximumTrackTintColor = [UIColor whiteColor];
    self.slider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
    self.slider.thumbImageView.image = [UIImage imageNamed:@"Nv_beauty_thumb"];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10 * SCREENSCALE);
        make.centerX.equalTo(self.topView.mas_centerX).offset(20);
        make.width.offset(240 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    self.slider.hidden = YES;
    
    self.extSlider = [[BLItemSlider alloc] initWithFrame:CGRectMake(0, 0, 240 * SCREENSCALE, 30 * SCREENSCALE)];
    self.extSlider.delegate = self;
    [self.topView addSubview:self.extSlider];
    self.extSlider.maximumTrackTintColor = [UIColor whiteColor];
    self.extSlider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
    self.extSlider.thumbImageView.image = [UIImage imageNamed:@"Nv_beauty_thumb"];
    [self.extSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.slider.mas_top).offset(-10 * SCREENSCALE);
        make.width.mas_equalTo(self.slider.mas_width);
        make.centerX.equalTo(self.slider.mas_centerX);
        make.height.mas_equalTo(self.slider.mas_height);
    }];
    self.extSlider.hidden = YES;
    
    self.whitenSegView = [[NvBeautySegmentView alloc] initWithFrame:CGRectMake(0, 0, 66*SCREENSCALE, 42*SCREENSCALE) titles:@[@"A",@"B"] selectedBgColor:@"#63ABFFFF" normalBgColor:@"#FFFFFFFF" selectedTextColor:@"#FFFFFFFF" normalTextColor:@"#63ABFFFF" fontSize:12*SCREENSCALE];
    self.whitenSegView.backgroundColor = [UIColor clearColor];
    [self.topView addSubview:self.whitenSegView];
    [self.whitenSegView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.slider.mas_centerY);
        make.right.equalTo(self.topView.mas_right);
        make.width.offset(66 * SCREENSCALE);
        make.height.offset(42 * SCREENSCALE);
    }];
    __weak typeof(self)weakSelf = self;
    self.whitenSegView.selectBlock = ^(NSInteger selectedIndex) {
        [weakSelf selectWhitenMode:selectedIndex];
    };
    [self.whitenSegView setDefaultSelectedSegment:1];
    [self.whitenSegView setRectCornerRadius:2.f*SCREENSCALE];
    self.whitenSegView.hidden = YES;
    
    self.previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.previewBtn addTarget:self action:@selector(previewBtnTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.previewBtn addTarget:self action:@selector(previewBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.previewBtn setImage:NvImageNamed(@"compare") forState:UIControlStateNormal];
    [self.topView addSubview:self.previewBtn];
    [self.previewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView.mas_left).offset(15 * SCREENSCALE);
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10);
        make.width.offset(30 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    
    self.infoLabel = [[UILabel alloc]init];
    self.infoLabel.font = [UIFont systemFontOfSize:11.f];
    self.infoLabel.textColor = UIColor.whiteColor;
    self.infoLabel.textAlignment = NSTextAlignmentRight;
    [self.topView addSubview:self.infoLabel];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.slider.mas_centerY);
        make.height.mas_equalTo(15*SCREENSCALE);
        make.left.equalTo(self.previewBtn.mas_right).offset(2*SCREENSCALE);
        make.right.equalTo(self.slider.mas_left).offset(-12*SCREENSCALE);
    }];
    self.infoLabel.hidden = YES;
    self.infoLabel.text = NvLocalString(@"fxStrength", @"强度");
    
    self.infoExtLabel = [[UILabel alloc]init];
    self.infoExtLabel.font = [UIFont systemFontOfSize:11.f];
    self.infoExtLabel.textColor = UIColor.whiteColor;
    self.infoExtLabel.textAlignment = NSTextAlignmentRight;
    [self.topView addSubview:self.infoExtLabel];
    [self.infoExtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.extSlider.mas_centerY);
        make.height.mas_equalTo(15*SCREENSCALE);
        make.left.equalTo(self.infoLabel.mas_left);
        make.right.equalTo(self.infoLabel.mas_right);
    }];
    self.infoExtLabel.hidden = YES;
    self.infoExtLabel.text = NvLocalString(@"Radius2", @"半径");
}

- (void)configData:(NSMutableArray *)datas category:(NvEditBeautyCategory)category showTemporaryData:(BOOL)temporary {
    if (category == NvEditBeautyCategoryBeauty) {
        [self.beautyBottomView updateData:datas showTemporaryData:temporary];
    }else if (category == NvEditBeautyCategoryShape) {
        [self.shapeBottomView updateData:datas showTemporaryData:temporary];
    }else if (category == NvEditBeautyCategoryMicroShape) {
        [self.microShapeBottomView updateData:datas showTemporaryData:temporary];
    }
}

- (void)changeSwitchState:(NvEditBeautyCategory)category isOpen:(BOOL)open {
    if (category == NvEditBeautyCategoryBeauty) {
        [self.beautyBottomView changeSwitchState:open];
    }else if (category == NvEditBeautyCategoryShape) {
        [self.shapeBottomView changeSwitchState:open];
    }else if (category == NvEditBeautyCategoryMicroShape) {
        [self.microShapeBottomView changeSwitchState:open];
    }
}

- (void)applyEffects:(NSMutableArray *)datas category:(NvEditBeautyCategory)category {
    for(NvBeautyTypeModel *model in datas) {
        [self selectEffectModel:model category:category];
    }
}

//根据当前类型切换界面
//Switch the interface based on the current type
- (void)setViewCategory:(NvEditBeautyCategory)viewCategory {
    _viewCategory = viewCategory;
    [self selectCategoryTab:viewCategory];
}

//点击切换界面类型
//Click to switch the interface type
- (void)selectCategoryTab:(NvEditBeautyCategory)viewCategory {
    if (viewCategory == NvEditBeautyCategoryBeauty) {
        [self updateTopView:viewCategory model:self.currentBeautyModel];
    }else if (viewCategory == NvEditBeautyCategoryShape) {
        [self updateTopView:viewCategory model:self.currentShapeModel];
    }else if (viewCategory == NvEditBeautyCategoryMicroShape) {
        [self updateTopView:viewCategory model:self.currentMicroShapeModel];
    }
}

- (void)udpateLayoutSubviews:(NvEditBeautyCategory)viewCategory {
    
}

- (void)updateTopView:(NvEditBeautyCategory)viewCategory model:(NvBeautyTypeModel *)model {
    if (viewCategory == NvEditBeautyCategoryBeauty) {
        [self updateBeautyCategoryTopView:model];
    }else if (viewCategory == NvEditBeautyCategoryShape) {
        [self updateShapeCategoryTopView:model];
    }else if (viewCategory == NvEditBeautyCategoryMicroShape) {
        [self updateMicroShapeCategoryTopView:model];
    }
}

- (void)updateBeautyCategoryTopView:(NvBeautyTypeModel *)model {
    [self updateSliderLimitedValue:model];
    self.slider.value = model.value;
    [self hiddenViewsInTopview:YES];
    if (!self.beautySwitchOpen) {
        return;
    }
    if ([model.name isEqualToString:NvLocalString(@"Amount", @"锐度")] || [model.name isEqualToString:NvLocalString(@"Strength", @"磨皮")]) {
        self.slider.hidden = YES;
    }else if ([model.name isEqualToString:NvLocalString(@"Color correction", @"校色")]) {
        self.slider.hidden = !model.switchSelected;
    }else {
        if([model.name isEqualToString:NvLocalString(@"Whiten mode A", @"美白A")] || [model.name isEqualToString:NvLocalString(@"Whiten mode B", @"美白B")] ){
            self.whitenSegView.hidden = NO;
        }else if ([model.name isEqualToString:NvLocalString(@"Shiny", @"去油光")]){
            self.extSlider.hidden = NO;
            self.infoLabel.hidden = NO;
            self.infoExtLabel.hidden = NO;
            self.extSlider.value = model.extValue;
        }
        self.slider.hidden = model ? NO : YES;
    }
}

- (void)updateShapeCategoryTopView:(NvBeautyTypeModel *)model {
    [self hiddenViewsInTopview:YES];
    if (!self.shapeSwitchOpen) {
        return;
    }
    if (model) {
        self.slider.hidden = NO;
        [self updateSliderLimitedValue:model];
        self.slider.value = model.value;
    }
}

- (void)updateMicroShapeCategoryTopView:(NvBeautyTypeModel *)model {
    [self hiddenViewsInTopview:YES];
    if (!self.microShapeSwitchOpen) {
        return;
    }
    if (model) {
        self.slider.hidden = NO;
        [self updateSliderLimitedValue:model];
        self.slider.value = model.value;
    }
}

- (void)hiddenViewsInTopview:(BOOL)hidden {
    self.slider.hidden = hidden;
    self.extSlider.hidden = hidden;
    self.infoLabel.hidden = hidden;
    self.infoExtLabel.hidden = hidden;
    self.whitenSegView.hidden = hidden;
}

- (void)updateSliderLimitedValue:(NvBeautyTypeModel *)model {
    if (model.fxName.length > 0 && [model.fxName containsString:@"Package Id"]) {
        self.slider.minValue = -1;
        self.slider.maxValue = 1;
    }else{
        self.slider.minValue = 0;
        self.slider.maxValue = 1;
    }
}

#pragma mark - 点击预览按钮 Click the preview button
- (void)previewBtnTouchDown:(UIButton *)sender {
    [self.beautyBottomView setZeroToAllEffectStrength:NO refreshData:NO];
    [self.shapeBottomView setZeroToAllEffectStrength:NO refreshData:NO];
    [self.microShapeBottomView setZeroToAllEffectStrength:NO refreshData:NO];
}

- (void)previewBtnTouchUpInside:(UIButton *)sender {
    [self.beautyBottomView reapplyAppliedEffects:NO refreshData:NO];
    [self.shapeBottomView reapplyAppliedEffects:NO refreshData:NO];
    [self.microShapeBottomView reapplyAppliedEffects:NO refreshData:NO];
}

#pragma mark - 应用特效 Applied special effect
- (void)selectEffectModel:(NvBeautyTypeModel *)model category:(NvEditBeautyCategory)category {
    if ([self.delegate respondsToSelector:@selector(nvEditBeautyView:category:applyModel:)]) {
        [self.delegate nvEditBeautyView:self category:category applyModel:model];
    }
}

#pragma mark - 美颜 beauty
- (void)selectWhitenMode:(NSInteger)index {
    self.currentBeautyModel.switchSelected = index == 0 ? NO : YES;
    if (!self.currentBeautyModel.switchSelected) {
        self.currentBeautyModel.name = NvLocalString(@"Whiten mode A", @"美白A");
        self.currentBeautyModel.coverImage = @"NvCaptureBeautyWhitening";
    }else{
        self.currentBeautyModel.name = NvLocalString(@"Whiten mode B", @"美白B");
        self.currentBeautyModel.coverImage = @"NvCaptureBeautyWhitening";
    }
    [self.beautyBottomView refreshData];
    [self selectEffectModel:self.currentBeautyModel category:NvEditBeautyCategoryBeauty];
}


#pragma mark - 点击pageView方法 Click the pageView method
- (void)pageViewDidSelectIndex:(NSNotification *)notify {
    NSNumber *num = notify.object;
    NSInteger index = [num integerValue];
    self.viewCategory = (NvEditBeautyCategory)index;
}

#pragma mark - NvPageViewDelegate
- (void)fixedItemClicked {
    if([self.delegate respondsToSelector:@selector(nvEditBeautyViewFinishedButtonClicked:)]) {
        [self.delegate nvEditBeautyViewFinishedButtonClicked:self];
    }
}

#pragma mark - BLItemSliderDelegate
-(void)itemSliderChangeStart:(BLItemSlider *)slider {
    if(self.viewCategory == NvEditBeautyCategoryBeauty) {
        slider.enable = self.currentBeautyModel.canReplace;
    }else if(self.viewCategory == NvEditBeautyCategoryShape){
        slider.enable = self.currentShapeModel.canReplace;
    }else if(self.viewCategory == NvEditBeautyCategoryMicroShape){
        slider.enable = self.currentMicroShapeModel;
    }
    if (!slider.enable) {
        if ([self.delegate respondsToSelector:@selector(nvEditBeautyView:forbiddenReplaceCategory:model:)]) {
            [self.delegate nvEditBeautyView:self forbiddenReplaceCategory:NvEditBeautyCategoryShape model:nil];
        }
    }
    
}

-(void)itemSlider:(BLItemSlider*)slider valueChanged:(float)value {
    if(self.viewCategory == NvEditBeautyCategoryBeauty) {
        if ([self.slider isEqual:slider]) {
            self.currentBeautyModel.value = value;
        }else if ([self.extSlider isEqual:slider]) {
            self.currentBeautyModel.extValue = value;
        }
        [self selectEffectModel:self.currentBeautyModel category:self.viewCategory];
    }else if(self.viewCategory == NvEditBeautyCategoryShape){
        if ([self.slider isEqual:slider]) {
            self.currentShapeModel.value = value;
        }
        [self selectEffectModel:self.currentShapeModel category:self.viewCategory];
    }else if(self.viewCategory == NvEditBeautyCategoryMicroShape){
        if ([self.slider isEqual:slider]) {
            self.currentMicroShapeModel.value = value;
        }
        [self selectEffectModel:self.currentMicroShapeModel category:self.viewCategory];
    }
}

-(void)itemSliderTouchEnd:(BLItemSlider*)slider {
    
}

#pragma mark - NvEditBeautyEffectViewDelegate
- (void)nvEditBeautyEffectView:(NvEditBeautyEffectView *)view switchBeautySum:(BOOL)open {
    self.beautySwitchOpen = open;
    if (open) {
        [self updateTopView:NvEditBeautyCategoryBeauty model:self.currentBeautyModel];
    } else {
        [self hiddenViewsInTopview:YES];
    }
    
    if (open) {
        [self.beautyBottomView reapplyAppliedEffects:NO refreshData:NO];
    } else {
        [self.beautyBottomView setZeroToAllEffectStrength:NO refreshData:NO];
    }
}

- (void)nvEditBeautyEffectView:(NvEditBeautyEffectView *)view switchSharpen:(BOOL)open {
    self.currentBeautyModel.switchSelected = open;
    [self selectEffectModel:self.currentBeautyModel category:NvEditBeautyCategoryBeauty];
}

- (void)nvEditBeautyEffectView:(NvEditBeautyEffectView *)view switchColorCorrect:(BOOL)open {
    self.currentBeautyModel.switchSelected = open;
    [self updateTopView:NvEditBeautyCategoryBeauty model:self.currentBeautyModel];
    [self selectEffectModel:self.currentBeautyModel category:NvEditBeautyCategoryBeauty];
}

- (void)nvEditBeautyEffectView:(NvEditBeautyEffectView *)view selecteModel:(NvBeautyTypeModel *)model refreshView:(BOOL)needRefreshView refreshData:(BOOL)needRefreshData {
    if (needRefreshData) {
        self.currentBeautyModel = model;
    }
    if (needRefreshView) {
        [self updateTopView:NvEditBeautyCategoryBeauty model:model];
    }
    
    //应用特效 Applied special effect
    [self selectEffectModel:model category:NvEditBeautyCategoryBeauty];
}

- (void)nvEditBeautyEffectView:(NvEditBeautyEffectView *)view forbiddenReplace:(NvBeautyTypeModel *)model {
    if ([self.delegate respondsToSelector:@selector(nvEditBeautyView:forbiddenReplaceCategory:model:)]) {
        [self.delegate nvEditBeautyView:self forbiddenReplaceCategory:NvEditBeautyCategoryShape model:model];
    }
}

#pragma mark - NvEditShapeEffectViewDelegate
- (void)nvEditShapeEffectView:(NvEditShapeEffectView *)view selecteModel:(NvBeautyTypeModel *)model refreshView:(BOOL)needRefreshView refreshData:(BOOL)needRefreshData {
    if (needRefreshData) {
        self.currentShapeModel = model;
    }
    if (needRefreshView) {
        [self updateTopView:NvEditBeautyCategoryShape model:model];
    }
    
    //应用特效 Applied special effect
    [self selectEffectModel:model category:NvEditBeautyCategoryShape];
}

- (void)nvEditShapeEffectView:(NvEditShapeEffectView *)view switchShapeSum:(BOOL)open {
    self.shapeSwitchOpen = open;
    if (open) {
        [self updateTopView:NvEditBeautyCategoryShape model:self.currentShapeModel];
    } else {
        [self hiddenViewsInTopview:YES];
    }
    
    if (open) {
        [self.shapeBottomView reapplyAppliedEffects:YES refreshData:NO];
    } else {
        [self.shapeBottomView setZeroToAllEffectStrength:NO refreshData:NO];
    }
}

- (void)nvEditShapeEffectView:(NvEditShapeEffectView *)view forbiddenReplace:(NvBeautyTypeModel *)model {
    if ([self.delegate respondsToSelector:@selector(nvEditBeautyView:forbiddenReplaceCategory:model:)]) {
        [self.delegate nvEditBeautyView:self forbiddenReplaceCategory:NvEditBeautyCategoryShape model:model];
    }
}

#pragma mark - NvEditMicroShapeEffectViewDelegate
- (void)nvEditMicroShapeEffectView:(NvEditMicroShapeEffectView *)view selecteModel:(NvBeautyTypeModel *)model refreshView:(BOOL)needRefreshView refreshData:(BOOL)needRefreshData {
    if (needRefreshData) {
        self.currentMicroShapeModel = model;
    }
    if (needRefreshView) {
        [self updateTopView:NvEditBeautyCategoryMicroShape model:model];
    }
    
    //应用特效 Applied special effect
    [self selectEffectModel:model category:NvEditBeautyCategoryMicroShape];
}

- (void)nvEditMicroShapeEffectView:(NvEditMicroShapeEffectView *)view switchMicroShapeSum:(BOOL)open {
    self.microShapeSwitchOpen = open;
    if (open) {
        [self updateTopView:NvEditBeautyCategoryMicroShape model:self.currentMicroShapeModel];
    } else {
        [self hiddenViewsInTopview:YES];
    }
    
    if (open) {
        [self.microShapeBottomView reapplyAppliedEffects:NO refreshData:NO];
    } else {
        [self.microShapeBottomView setZeroToAllEffectStrength:NO refreshData:NO];
    }
}

- (void)nvEditMicroShapeEffectView:(NvEditMicroShapeEffectView *)view forbiddenReplace:(NvBeautyTypeModel *)model {
    if ([self.delegate respondsToSelector:@selector(nvEditBeautyView:forbiddenReplaceCategory:model:)]) {
        [self.delegate nvEditBeautyView:self forbiddenReplaceCategory:NvEditBeautyCategoryShape model:model];
    }
}
@end
