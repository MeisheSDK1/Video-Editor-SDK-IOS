//
//  NvEditColorCorrectViewController.m
//  SDKDemo
//
//  Created by ms on 2020/11/26.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditColorCorrectViewController.h"
#import "NvColorCorrectMenuCell.h"
#import "NvEditClipLiveWindow.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvEditCorrectColorItem.h"
#import "NvStreamingSdkCore.h"
#import "NvHotPixelAdjustView.h"
#import "BLItemSlider.h"

@interface NvEditColorCorrectViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, BLItemSliderDelegate>
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UICollectionView *bottomView;
///滑动视图数组
///Sliding view array
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) BLItemSlider *slider;
///播放控件
///Playback control
@property (nonatomic, strong) NvEditClipLiveWindow *clipLivewindow;
///这个时间线上只有一个片段
///There's only one fragment of this timeline
@property (nonatomic, strong) NvsTimeline *clipTimeline;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
///视频操作的片段对象
///A fragment object for a video operation
@property (nonatomic, strong) NvsVideoClip *videoClip;
///亮度，对比度，饱和度，高光，阴影，褪色
///Brightness, contrast, saturation, highlight, shadow, fade
@property (nonatomic, strong) NvsVideoFx *colorVideoFx;
///锐度
///sharpness
@property (nonatomic, strong) NvsVideoFx *sharpenVideoFx;
///暗角
///Dark Angle
@property (nonatomic, strong) NvsVideoFx *vignetteVideoFx;
///色温 色调
///Color temperature hue
@property (nonatomic, strong) NvsVideoFx *tintVideoFx;
///噪点
///Noise point
@property (nonatomic, strong) NvsVideoFx *denoiseVideoFx;
///重置
///reset
@property (nonatomic, strong) UIButton *resertBtn;
@property (nonatomic, strong) NvEditCorrectColorItem *currentItem;
@property (nonatomic, strong) NvHotPixelAdjustView *hotPixelView;

@property (nonatomic, strong) NvEditDataModel *currentModel;

@property (nonatomic, assign) BOOL isFirstCreated;
@end

@implementation NvEditColorCorrectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.streamingContext = [NvSDKUtils getSDKContext];
    self.clipTimeline = [NvTimelineUtils createTimeline:self.editMode];
    
    self.currentModel = [self.model copy];
    
    [NvTimelineUtils resetEditData:self.clipTimeline editDataArray:[NSArray arrayWithObject:_model]];
    [NvTimelineUtils resetVideoFx:self.clipTimeline videoFxDataArray:[self getClipTimelineFilter:_model]];
    self.videoClip = [[self.clipTimeline getVideoTrackByIndex:0] getClipWithIndex:0];
    [NvTimelineUtils removeClipCropAndTransformFx:self.videoClip];
    
    self.colorVideoFx = [self getVideoFx:self.videoClip name:@"BasicImageAdjust"];
    self.sharpenVideoFx = [self getVideoFx:self.videoClip name:@"Sharpen"];
    self.denoiseVideoFx = [self getVideoFx:self.videoClip name:@"Noise"];
    self.vignetteVideoFx = [self getVideoFx:self.videoClip name:@"Vignette"];
    self.tintVideoFx = [self getVideoFx:self.videoClip name:@"Tint"];
    [_sharpenVideoFx setFloatVal:@"Amount" val:0];
    
    if (self.isFirstCreated){
        [self.denoiseVideoFx setBooleanVal:@"Grayscale" val:self.model.grayscale];
        [self.denoiseVideoFx setFloatVal:@"Intensity" val:self.model.intensity];
        [self.denoiseVideoFx setFloatVal:@"Density" val:self.model.density];
    }
    [self configData];
    [self addSubViews];
    [self.clipLivewindow play];
    [self configHotPiex];
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

- (void)leftNavButtonClick:(UIButton *)button{
    self.model.brightness = self.currentModel.brightness;
    self.model.contrast = self.currentModel.contrast;
    self.model.saturation = self.currentModel.saturation;
    self.model.highlight = self.currentModel.highlight;
    self.model.shadow = self.currentModel.shadow;
    self.model.temperature = self.currentModel.temperature;
    self.model.tint = self.currentModel.tint;
    self.model.blackpoint = self.currentModel.blackpoint;
    self.model.Sharpen = self.currentModel.Sharpen;
    self.model.Vignette = self.currentModel.Vignette;
    self.model.grayscale = self.currentModel.grayscale;
    self.model.intensity = self.currentModel.intensity;
    self.model.density = self.currentModel.density;

    [self.navigationController popViewControllerAnimated:YES];
}

/**
 获取某个片段的特效
 Get the special effects of a clip

 @param clip 片段
 clip
 @param name 特效名称
 Effect name
 */
- (NvsVideoFx *)getVideoFx:(NvsVideoClip *)clip name:(NSString *)name {
    NvsVideoFx *fx = nil;
    for (int i = 0; i < clip.fxCount; i++) {
        NvsVideoFx *videoFx = [clip getFxWithIndex:i];
        if ([videoFx.bultinVideoFxName isEqualToString:name]) {
            fx = videoFx;
            break;
        }
    }
    if (!fx){
        fx = [clip appendBuiltinFx:name];
        if ([name isEqualToString:@"Noise"]) {
            self.isFirstCreated = true;
        }
        
    }
    return fx;
}
- (NSMutableArray *)getClipTimelineFilter:(NvEditDataModel *)clipInfo {
    NSUInteger index = [[NvTimelineData sharedInstance].editDataArray indexOfObject:clipInfo];
    NSMutableArray *filters = [[NvTimelineData sharedInstance] videoFxDataArray];
    NSMutableArray *clipFilters = NSMutableArray.new;
    if (filters.count > index) {
        NvTimeFilterInfoModel *filterModel = filters[index];
        NvTimeFilterInfoModel *clipFilter = [filterModel copy];
        clipFilter.inPoint = 0;
        clipFilter.outPoint = _clipTimeline.duration;
        [clipFilters addObject:clipFilter];
    } else {
        
    }
    return clipFilters;
}

/**
 噪点视图回调
 Noisy view callback
 */
-(void)configHotPiex{
    __weak typeof(self)weakSelf = self;
    self.hotPixelView.colorSelectBlock = ^(int select) {
        if (select == 0) {
            [weakSelf.denoiseVideoFx setBooleanVal:@"Grayscale" val:YES];
            weakSelf.model.grayscale = YES;
        }else if (select == 1){
            [weakSelf.denoiseVideoFx setBooleanVal:@"Grayscale" val:NO];
            weakSelf.model.grayscale = NO;
        }
        [weakSelf seekTimeline];
    };
    self.hotPixelView.degreeeSlideValueChangeBlock = ^(CGFloat value) {
        [weakSelf.denoiseVideoFx setFloatVal:@"Intensity" val:value];
        weakSelf.model.intensity = value;
        [weakSelf seekTimeline];
    };
    self.hotPixelView.densitySlideValueChangeBlock = ^(CGFloat value) {
         [weakSelf.denoiseVideoFx setFloatVal:@"Density" val:value];
         weakSelf.model.density = value;
        [weakSelf seekTimeline];
    };
}
/**
 配置数据
 Configure data
 */
-(void)configData{
    self.dataArray = [NSMutableArray array];
    NSArray *names = @[NvLocalString(@"Brightness", @"亮度"),
                      NvLocalString(@"Contrast", @"对比度"),
                      NvLocalString(@"Saturation", @"饱和度"),
                      NvLocalString(@"Highlights", @"高光"),
                      NvLocalString(@"shadow", @"阴影"),
                      NvLocalString(@"colortemperature", @"色温"),
                      NvLocalString(@"colortone", @"色调"),
                      NvLocalString(@"fade", @"褪色"),
                      NvLocalString(@"Degree", @"暗角"),
                      NvLocalString(@"Amount", @"锐度"),
                      NvLocalString(@"HotPixel", @"噪点"),
                       
    ];
    
    NSArray *builtenNames = @[@"Brightness",
                      @"Contrast",
                      @"Saturation",
                      @"Highlight",
                           @"Shadow",
                           @"Temperature",
                           @"Tint",
                           @"Blackpoint",
                           @"Degree",
                           @"Amount",
                           @"Intensity",
                       
    ];
    NSArray *unselects = @[@"edit_color_brightness_unselected",
                      @"edit_contrast_ratio_unselected",
                      @"edit_color_saturation_unselected",
                      @"edit_color_highlights_unselected",
                           @"edit_color_shadow_unselected",
                           @"edit_color_temperature_unselected",
                           @"edit_color_tone_unselected",
                           @"edit_color_fade_unselected",
                           @"edit_color_dark_unselected",
                           @"edit_color_sharpness_unselected",
                           @"edit_color_noise_unselected",
                       
    ];
    NSArray *selects = @[@"edit_color_brightness_selected",
                         @"edit_contrast_ratio_selected",
                         @"edit_color_saturation_selected",
                         @"edit_color_highlights_selected",
                         @"edit_color_shadow_selected",
                         @"edit_color_temperature_selected",
                         @"edit_color_tone_selected",
                         @"edit_color_fade_selected",
                         @"edit_color_dark_selected",
                         @"edit_color_sharpness_selected",
                         @"edit_color_noise_selected",
                         
                         
    ];
    NSArray *maxValues = @[@1.0,
                         @1.0,
                           @1.0,
                           @1.0,
                           @1.0,
                           @1.0,
                           @1.0,
                           @1.0,
                           @1.0,
                           @5.0,
                           @1.0,
   
                   
    ];
    NSArray *minValues = @[@-1.0,
                         @-1.0,
                           @-1.0,
                           @-1.0,
                           @-1.0,
                           @-1.0,
                           @-1.0,
                           @-1.0,
                           @0,
                           @0,
                           @0,
                          
    ];
    
    NSArray *defaultValues = @[@0,
                         @0,
                           @0,
                           @0,
                           @0,
                           @0,
                           @0,
                           @0,
                           @0,
                           @0,
                           @0,
                          
    ];
    
    
    for (int i = 0; i < names.count; i++) {
        NvEditCorrectColorItem *item = [NvEditCorrectColorItem new];
        item.name = names[i];
        item.isSelected = NO;
        item.slecteImage = selects[i];
        item.builtenName = builtenNames[i];
        item.unslecteImage = unselects[i];
        item.maxValue = [maxValues[i] floatValue];
        item.minValue = [minValues[i] floatValue];
        item.value = [defaultValues[i] floatValue];
        if ([item.builtenName isEqualToString:@"Brightness"]) {
            item.isSelected = YES;
        }
        [self.dataArray addObject:item];
    }
    
}
/**
 Slider回调
 Slider callback
 */
-(void)itemSlider:(BLItemSlider*)slider valueChanged:(float)value {
    self.currentItem.value = slider.value;
    [self setUpFx];
}


#pragma mark - 结束编辑点击事件
///End Edit click event
- (void)finshClick:(UIButton *)btn{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addSubViews{
    
    self.clipLivewindow = [[NvEditClipLiveWindow alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width)];
    [self.view addSubview:self.clipLivewindow];
    [self.clipLivewindow connectTimeline:self.clipTimeline];
    self.clipLivewindow.editMode = self.editMode;
    [self.clipLivewindow setPlayRangeIn:0 rangeOut:self.model.trimOut/self.model.speed];
    [self.clipLivewindow seekTimeline:0];
    self.clipLivewindow.delegate = self;
    
    self.currentItem = self.dataArray.firstObject;
    
    CGRect sliderFrame = CGRectMake(77*SCREENSCALE, 390*SCREENSCALE, SCREENWIDTH - 107*SCREENSCALE, 8.0f*SCREENSCALE);
    self.slider = [[BLItemSlider alloc] initWithFrame:sliderFrame];
    self.slider.delegate = self;
    self.slider.maximumTrackTintColor = [UIColor whiteColor];
    self.slider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
    self.slider.thumbTintColor = [UIColor whiteColor];
    self.slider.thumbSeletedTintColor = [UIColor whiteColor];
    [self.view addSubview:self.slider];
    self.slider.maxValue = self.currentItem.maxValue;
    self.slider.minValue = self.currentItem.minValue;
    self.slider.value = _model.brightness;
    self.slider.hidden = NO;
    
    self.hotPixelView = [[NvHotPixelAdjustView alloc] init];
    
    [self.view addSubview:self.hotPixelView];
    self.hotPixelView.hidden = YES;
    
    UIButton *finsh = [UIButton buttonWithType:UIButtonTypeCustom];
    [finsh setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [finsh addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finsh];
    [finsh mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(20*SCREENSCALE));
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(@(-15*SCREENSCALE));
        }
    }];
    
    self.line = [UIView new];
    self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(finsh.mas_top).offset(-12*SCREENSCALE);
    }];
    
    UICollectionViewFlowLayout *layout1 = [[UICollectionViewFlowLayout alloc]init];
    layout1.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout1.itemSize = CGSizeMake(65 *SCREENSCALE, 60.0 *SCREENSCALE);
    layout1.minimumLineSpacing = 5*SCREENSCALE;
    layout1.minimumInteritemSpacing = 0;
    _bottomView = [[UICollectionView alloc] initWithFrame:CGRectMake(0 * SCREENSCALE, 430 *SCREENSCALE, SCREENWIDTH, 80*SCREENSCALE) collectionViewLayout:layout1];
    _bottomView.delegate = self;
    _bottomView.dataSource = self;
    _bottomView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_bottomView];
    [_bottomView registerClass:[NvColorCorrectMenuCell class] forCellWithReuseIdentifier:@"NvColorCorrectMenuCellID"];
    _bottomView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetBtn setTitle:NvLocalString(@"Reset", @"重置") forState:UIControlStateNormal];
    [resetBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(resetBtnClick) forControlEvents:UIControlEventTouchUpInside];
    resetBtn.titleLabel.font = [NvUtils fontWithSize:10*SCREENSCALE];
    [resetBtn setTitleColor:[UIColor nv_colorWithHexString:@"#DFDFDF"] forState:UIControlStateNormal];
    self.resertBtn = resetBtn;
    [self.view addSubview:resetBtn];

    
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@(80*SCREENSCALE));
        make.bottom.equalTo(self.line.mas_top).offset(-12*SCREENSCALE);
    }];
    
    [_resertBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(15*SCREENSCALE);
        make.width.mas_lessThanOrEqualTo(@(50*SCREENSCALE));
        make.height.equalTo(@(20*SCREENSCALE));
       make.bottom.mas_equalTo(_bottomView.mas_top).offset(-20.0*SCREENSCALE);
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(75.0*SCREENSCALE);
        make.right.mas_equalTo(-30.0*SCREENSCALE);
        make.height.mas_equalTo(8.0f*SCREENSCALE);
        make.centerY.mas_equalTo(_resertBtn.mas_centerY);
    }];
    
    [self.hotPixelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(75.0*SCREENSCALE);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(100.0f*SCREENSCALE);
        make.bottom.mas_equalTo(_bottomView.mas_top).offset(-10.0*SCREENSCALE);
    }];
}
/**
 重置特效
 Reset fx
 */
-(void)resetBtnClick{
    for (int i = 0; i < self.dataArray.count - 1; i++) {
        NvEditCorrectColorItem *item = self.dataArray[i];
        if ([item.name isEqualToString:NvLocalString(@"Brightness", @"亮度")]) {
            item.value = 0;
            [_colorVideoFx setFloatVal:item.builtenName val:0];
            self.model.brightness = 0;
        }else if([item.name isEqualToString: NvLocalString(@"Contrast", @"对比度")]){
            item.value = 0;
            [_colorVideoFx setFloatVal:item.builtenName val:0];
            self.model.contrast = 0;
        }else if([item.name isEqualToString:NvLocalString(@"Saturation", @"饱和度")]){
            item.value = 0;
            [_colorVideoFx setFloatVal:item.builtenName val:0];
            self.model.saturation = 0;
        }else if([item.name isEqualToString:NvLocalString(@"Highlights", @"高光")]){
            item.value = 0;
            [_colorVideoFx setFloatVal:item.builtenName val:0];
            self.model.highlight = 0;
        }else if([item.name isEqualToString:NvLocalString(@"shadow", @"阴影")]){
            item.value = 0;
            [_colorVideoFx setFloatVal:item.builtenName val:0];
            self.model.shadow = 0;
        }else if([item.name isEqualToString:NvLocalString(@"colortemperature", @"色温")]){
            item.value = 0;
            [_tintVideoFx setFloatVal:item.builtenName val:0];
            self.model.temperature = 0;
        }else if([item.name isEqualToString:NvLocalString(@"colortone", @"色调")]){
            item.value = 0;
            [_tintVideoFx setFloatVal:item.builtenName val:0];
            self.model.tint = 0;
        }else if([item.name isEqualToString:NvLocalString(@"fade", @"褪色")]){
            item.value = 0;
            [_colorVideoFx setFloatVal:item.builtenName val:0];
            self.model.blackpoint = 0;
        }else if([item.name isEqualToString:NvLocalString(@"Amount", @"锐度")]){
            item.value = 1;
            [_sharpenVideoFx setFloatVal:item.builtenName val:0];
            self.model.Sharpen = 0;
        }else if([item.name isEqualToString:NvLocalString(@"Degree", @"暗角")]){
            item.value = 0;
            [_vignetteVideoFx setFloatVal:item.builtenName val:0];
            self.model.Vignette = 0;
        }else if([item.name isEqualToString:NvLocalString(@"HotPixel", @"噪点")]){
           
        }
    }
    self.slider.maxValue = self.currentItem.maxValue;
    self.slider.minValue = self.currentItem.minValue;
    self.slider.value = 0;
    [self.denoiseVideoFx setFloatVal:@"Intensity" val:0.0];
    self.model.intensity = 0;
    [self.denoiseVideoFx setFloatVal:@"Density" val:0.0];
    [self.denoiseVideoFx setBooleanVal:@"Grayscale" val:YES];
    self.model.density = 0;
    [self.hotPixelView reset];
    [self seekTimeline];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NvColorCorrectMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvColorCorrectMenuCellID" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.item];
    return cell;

}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.currentItem = self.dataArray[indexPath.row];
    for (NvEditCorrectColorItem *item in self.dataArray) {
        item.isSelected = NO;
    }
    self.currentItem.isSelected = YES;
    self.slider.maxValue = self.currentItem.maxValue;
    self.slider.minValue = self.currentItem.minValue;
    [collectionView reloadData];
    [self setSliderValue];
    [self seekTimeline];
    if ([self.currentItem.name isEqualToString:NvLocalString(@"HotPixel", @"噪点")]) {
        self.hotPixelView.hidden = NO;
        self.slider.hidden = YES;
        [self.hotPixelView setWithColorType:self.model.grayscale Intensity:self.model.intensity Density:self.model.density];
    }else{
        self.hotPixelView.hidden = YES;
        self.slider.hidden = NO;
    }
}

/**
 Slider回调
 Slider callback
 */
-(void)setSliderValue{
    if ([self.currentItem.name isEqualToString:NvLocalString(@"Brightness", @"亮度")]) {
        self.slider.value = self.model.brightness;
        [_colorVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString: NvLocalString(@"Contrast", @"对比度")]){
        self.slider.value = self.model.contrast;
        [_colorVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"Saturation", @"饱和度")]){
        self.slider.value = self.model.saturation;
        [_colorVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"Highlights", @"高光")]){
        self.slider.value = self.model.highlight;
        [_colorVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"shadow", @"阴影")]){
        self.slider.value = self.model.shadow;
        [_colorVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"colortemperature", @"色温")]){
        self.slider.value = self.model.temperature;
        [_tintVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"colortone", @"色调")]){
        self.slider.value = self.model.tint;
        [_tintVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"fade", @"褪色")]){
        self.slider.value = self.model.blackpoint;
        [_colorVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"Amount", @"锐度")]){
        self.slider.value = self.model.Sharpen;
        [_sharpenVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"Degree", @"暗角")]){
        self.slider.value = self.model.Vignette;
        [_vignetteVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"HotPixel", @"噪点")]){
        [self.denoiseVideoFx setBooleanVal:@"Grayscale" val:self.model.grayscale];
        [self.denoiseVideoFx setFloatVal:@"Intensity" val:self.model.intensity];
        [self.denoiseVideoFx setFloatVal:@"Density" val:self.model.density];
        
    }
}
/**
 设置特效值
 Set special effect value
 */
-(void)setUpFx{
    
    if ([self.currentItem.name isEqualToString:NvLocalString(@"Brightness", @"亮度")]) {
        self.model.brightness = self.slider.value;
        [_colorVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString: NvLocalString(@"Contrast", @"对比度")]){
        self.model.contrast = self.slider.value;
        [_colorVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"Saturation", @"饱和度")]){
        self.model.saturation = self.slider.value;
        [_colorVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"Highlights", @"高光")]){
        self.model.highlight = self.slider.value;
        [_colorVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"shadow", @"阴影")]){
        self.model.shadow = self.slider.value;
        [_colorVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"colortemperature", @"色温")]){
        self.model.temperature = self.slider.value;
        [_tintVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"colortone", @"色调")]){
        self.model.tint = self.slider.value;
        [_tintVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"fade", @"褪色")]){
        self.model.blackpoint = self.slider.value;
        [_colorVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"Amount", @"锐度")]){
        self.model.Sharpen = self.slider.value;
        [_sharpenVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"Degree", @"暗角")]){
        self.model.Vignette = self.slider.value;
        [_vignetteVideoFx setFloatVal:self.currentItem.builtenName val:self.slider.value];
    }else if([self.currentItem.name isEqualToString:NvLocalString(@"HotPixel", @"噪点")]){
    }
    
    [self seekTimeline];
}


-(void)seekTimeline{
    [self.streamingContext seekTimeline:self.clipTimeline timestamp:[self.streamingContext getTimelineCurrentPosition:self.clipTimeline] videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}
@end
