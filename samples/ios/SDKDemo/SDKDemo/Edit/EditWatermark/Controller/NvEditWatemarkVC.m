//
//  NvEditWatemarkVC.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/9/3.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvEditWatemarkVC.h"
#import "NvAlbumViewController.h"
#import <NvSDKCommon/NvBaseNavigationController.h>
#import "NvEditWatemarkImageView.h"
#import "NvWatemarkCVCell.h"
#import "NvsTimelineVideoFx.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvBaseCommon/UIView+Dimension.h>

@interface NvEditWatemarkVC ()<NvLiveWindowPanelViewDelegate, NvsStreamingContextDelegate,NvAlbumViewControllerDelegate,NvEditWatemarkImageViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

///水印图片
///Watermarking picture
@property (nonatomic, strong) NvEditWatemarkImageView *imageView;
///当前图片
///Current picture
@property (nonatomic, strong) UIImage *currentImage;
///当前图片大小
///Current picture size
@property (nonatomic, assign) CGSize imageSize;
///最小图片大小
///Minimum picture size
@property (nonatomic, assign) CGSize imageMinSize;
///是否保存到timeline
///Whether to save to timeline
@property (nonatomic, assign) BOOL isSave;
///水印对应比例
///Watermark corresponding ratio
@property (nonatomic, assign) CGFloat proportion;
///是否可以编辑拖动框
///Whether you can edit the drag box
@property (nonatomic, assign) BOOL editState;
///png图片选择
///png image selection
@property (nonatomic, strong) UIButton *pngBtn;
///caf图片选择
///caf picture selection
@property (nonatomic, strong) UIButton *cafBtn;
///效果按钮
///Effect button
@property (nonatomic, strong) UIButton *effectBtn;
@property (nonatomic, strong) UIView *pngLine;
@property (nonatomic, strong) UIView *cafLine;
@property (nonatomic, strong) UIView *effectLine;
@property (nonatomic, strong) UICollectionView *watemarkCView;
///内置特效对应slider的背景view
///Built-in effects correspond to the slider's background view
@property (nonatomic, strong) UIView *sliderBGView;
///马赛克程度slider
///Mosaic degree slider
@property (nonatomic, strong) UISlider *strengthMOSSlider;
@property (nonatomic, strong) UILabel *strengthLabel;
///马赛克数量slider
///Mosaic number slider
@property (nonatomic, strong) UISlider *amountMOSSlider;
@property (nonatomic, strong) UILabel *amountMOSLabel;
///模糊程度slider
///Blur degree slider
@property (nonatomic, strong) UISlider *strengthBlurSlider;
@property (nonatomic, strong) NSMutableArray *pngArray;
@property (nonatomic, strong) NSMutableArray *cafArray;
@property (nonatomic, strong) NSMutableArray *effectArray;
@property (nonatomic, strong) NSMutableArray *currentArray;
@property (nonatomic, strong) NvWatemarkItem *currentItem;

//-----------------sdk相关  SDK-related----------------//
///数据结构
///Data structure
@property (nonatomic, strong) NvTimelineData *timelineData;
///创建一个新的model
///Create a new model
@property (nonatomic, strong) NvWatermarkInfoModel *dataModel;
@property (nonatomic, strong) NvsTimelineVideoFx *videoFx;

@property (nonatomic, strong) UIView *line;
///动态水印添加的开始时间
///The start time of dynamic watermark addition
@property (nonatomic, assign) int64_t inPoint;
///动态水印添加的结束时间
///End time of dynamic watermark addition
@property (nonatomic, assign) int64_t outPoint;
@end

@implementation NvEditWatemarkVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [NvTimelineUtils sharedInstance].isVideoFx = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
     [NvTimelineUtils sharedInstance].isVideoFx = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pngArray = [NSMutableArray array];
    self.cafArray = [NSMutableArray array];
    self.effectArray = [NSMutableArray array];
    self.currentArray = [NSMutableArray array];
    [self initTimeline];
    [self.liveWindowPanel hiddenVolumeButton];
    self.liveWindowPanel.delegate = self;
    [self configDataSoure];
    [self rebuildWatermarkInTimeline];
    [self addSubviews];
    [self remakeSubviews];
    
    [self seekTimeline:0];
}

#pragma mark - 数据配置
/*
 数据配置
 Data configuration
 */
- (void)configDataSoure{
    NvWatemarkItem *item = [[NvWatemarkItem alloc]init];
    item.coverString = @"NvEditWatemarButton";
    item.selected = NO;
    item.isCaf = NO;
    item.isCacheImage = NO;
    [self.pngArray addObject:item];
    
    NvWatemarkItem *item1 = [[NvWatemarkItem alloc]init];
    item1.coverString = @"NvEditWatemarkPng";
    item1.selected = NO;
    item1.isCaf = NO;
    item1.isCacheImage = NO;
    [self.pngArray addObject:item1];
    
    NvWatemarkItem *item2 = [[NvWatemarkItem alloc]init];
    item2.coverString = @"NvEditWatemarkCaf";
    item2.selected = NO;
    item2.isCaf = YES;
    item2.isCacheImage = NO;
    [self.cafArray addObject:item2];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *fileArray = [fm contentsOfDirectoryAtPath:WATEMARK_PATH error:nil];
    for (NSString *fileString in fileArray) {
        if ([fileString hasSuffix:@".png"]) {
            if ([fileString containsString:@"NvEditWatemarkPng"]) {
                [self.pngArray removeObject:item1];
            }
            NvWatemarkItem *fileModel = [[NvWatemarkItem alloc]init];
            fileModel.coverString = [fileString stringByReplacingOccurrencesOfString:@".png" withString:@""];
            fileModel.selected = NO;
            fileModel.isCaf = NO;
            fileModel.isCacheImage = YES;
            [self.pngArray addObject:fileModel];
        }
    }
    
    /*
     添加效果数据
     Add performance data
     */
    NvWatemarkItem *effct1 = [[NvWatemarkItem alloc]init];
    effct1.coverString = @"NvEditWatemark_Mosaic";
    effct1.selected = NO;
    effct1.isCaf = NO;
    effct1.isBuiltInEffect = YES;
    effct1.isCacheImage = NO;
    effct1.effectName = @"Mosaic";
    effct1.intensity = 0.5;
    effct1.unitSize = 0.05;
    [self.effectArray addObject:effct1];
    
    NvWatemarkItem *effct2 = [[NvWatemarkItem alloc]init];
    effct2.coverString = @"NvEditWatemark_Blur";
    effct2.selected = NO;
    effct2.isCaf = NO;
    effct2.isBuiltInEffect = YES;
    effct2.isCacheImage = NO;
    effct2.effectName = @"Fast Blur";
    effct2.intensity = 0.5;
    [self.effectArray addObject:effct2];
    
    if (self.timelineData.watermarkInfo.isCaf) {
        self.currentArray = self.cafArray;
    }else if (self.timelineData.watermarkInfo.isBuiltInEffect) {
        self.currentArray = self.effectArray;
        NSString *effectName = self.timelineData.watermarkInfo.builtInEffect.effectName;
        if ([effct1.effectName isEqualToString:effectName]) {
            self.isSave = YES;
            effct1.intensity = self.timelineData.watermarkInfo.builtInEffect.intensity;
            effct1.unitSize = self.timelineData.watermarkInfo.builtInEffect.unitSize;
        }else if ([effct2.effectName isEqualToString:effectName]){
            self.isSave = YES;
            effct2.intensity = self.timelineData.watermarkInfo.builtInEffect.intensity;
        }
    }
    else{
        self.currentArray = self.pngArray;
    }
    
    for (NvWatemarkItem *model in self.currentArray) {
        if ([model.coverString isEqualToString:self.timelineData.watermarkInfo.imageUrl]) {
            model.selected = YES;
            self.currentItem = model;
        }
    }
    
}

#pragma mark - 恢复数据中记录的水印效果
/*
 恢复数据中记录的水印效果
 Restore the watermark effect recorded in the data
 */
- (void)rebuildWatermarkInTimeline {
    if (self.timelineData.watermarkInfo.isCaf) {
        self.currentImage = NvImageNamed(self.currentItem.coverString);
        self.imageSize = CGSizeMake(self.timelineData.watermarkInfo.displayWidth, self.timelineData.watermarkInfo.displayHeight);
        NvsTimelineVideoFx *fx = [self.timeline getFirstTimelineVideoFx];
        while (fx) {
            if ([fx.bultinTimelineVideoFxName isEqualToString:@"Storyboard"]) {
                self.videoFx = fx;
            }
            fx = [self.timeline getNextTimelineVideoFx:fx];
        }
    }else if (self.currentItem.isBuiltInEffect) {
        self.currentImage = NvImageNamed(self.currentItem.coverString);
        self.imageSize = CGSizeMake(self.timelineData.watermarkInfo.displayWidth, self.timelineData.watermarkInfo.displayHeight);
        NvsTimelineVideoFx *fx = [self.timeline getFirstTimelineVideoFx];
        while (fx) {
            if ([fx.bultinTimelineVideoFxName isEqualToString:self.timelineData.watermarkInfo.builtInEffect.effectName]) {
                self.videoFx = fx;
            }
            fx = [self.timeline getNextTimelineVideoFx:fx];
        }
    }
}

#pragma mark - 重新创建timeline和数据结构
/*
 重新创建timeline和数据结构
 Recreate timeline and data structure
 */
- (void)initTimeline {
    self.timeline = [NvTimelineUtils createTimeline:self.editMode];
    [NvTimelineUtils recreateTimeline:self.timeline];
    self.proportion = self.timeline.videoRes.imageWidth/ self.liveWindowPanel.liveWindow.width;
    self.timelineData = [NvTimelineData sharedInstance];
    
    self.inPoint = 0;
    self.outPoint = self.timeline.duration;
    
    if (self.timelineData.watermarkInfo.imageUrl) {
        self.editState = YES;
        [self.timeline deleteWatermark];
        self.currentImage = [self getImage];
        if (self.timelineData.watermarkInfo.isCaf) {
            self.imageView = [[NvEditWatemarkImageView alloc]initWithFrame:CGRectMake(self.timelineData.watermarkInfo.marginX + self.liveWindowPanel.liveWindow.width/2.0 - self.timelineData.watermarkInfo.displayWidth/2.0,-self.timelineData.watermarkInfo.marginY + self.liveWindowPanel.liveWindow.height/2.0 - self.timelineData.watermarkInfo.displayHeight/2.0,self.timelineData.watermarkInfo.displayWidth,self.timelineData.watermarkInfo.displayHeight)];
        }else if (self.timelineData.watermarkInfo.isBuiltInEffect) {
            CGRect rect = CGRectMake(self.timelineData.watermarkInfo.marginX, self.timelineData.watermarkInfo.marginY, self.timelineData.watermarkInfo.displayWidth, self.timelineData.watermarkInfo.displayHeight);
            self.imageView = [[NvEditWatemarkImageView alloc]initWithFrame:rect];
        }
        else{
            self.imageView = [[NvEditWatemarkImageView alloc]initWithFrame:CGRectMake(self.liveWindowPanel.liveWindow.width - self.timelineData.watermarkInfo.marginX / self.proportion - self.timelineData.watermarkInfo.displayWidth / self.proportion,self.timelineData.watermarkInfo.marginY / self.proportion,self.timelineData.watermarkInfo.displayWidth / self.proportion,self.timelineData.watermarkInfo.displayHeight / self.proportion)];
        }
        self.imageView.delegate = self;
        if (!self.timelineData.watermarkInfo.isBuiltInEffect) {
            self.imageView.image = self.currentImage;
        }
        
        [self.liveWindowPanel.liveWindow addSubview:self.imageView];
    }
}

#pragma mark - 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubviews{
    /*
     底部选中按钮
     Select button at the bottom
     */
    UIButton *finshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finshBtn setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [finshBtn addTarget:self action:@selector(finshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finshBtn];
    
    [finshBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(20*SCREENSCALE));
        if (@available(iOS 11.0, *)) { make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
        } else {
            make.bottom.equalTo(@(-15*SCREENSCALE));
        }
    }];
    
    self.line = [UIView new];
    self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(finshBtn.mas_top).offset(-12*SCREENSCALE);
    }];
    
    /*
     中间collectionView
     Middle collectionView
     */
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(64 * SCREENSCALE, 64*SCREENSCALE);
    layout.minimumLineSpacing = 23 * SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 13 * SCREENSCALE, 0, 0);
    self.watemarkCView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _watemarkCView.backgroundColor = UIColor.clearColor;
    _watemarkCView.delegate = self;
    _watemarkCView.dataSource = self;
    _watemarkCView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_watemarkCView];
    [_watemarkCView registerClass:[NvWatemarkCVCell class] forCellWithReuseIdentifier:@"NvWatemarkCVCell"];
    [_watemarkCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.line.mas_top).offset(-10 * SCREENSCALE);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.offset(64 * SCREENSCALE);
    }];
    
    /*
     添加最上部内置特效对应的slider控件
     Add the slider control corresponding to the built-in special effects at the top
     */
    self.sliderBGView = [[UIView alloc] init];
    self.sliderBGView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.sliderBGView];
    [self.sliderBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.watemarkCView.mas_top).mas_offset(-10);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.offset(30 * SCREENSCALE);
    }];
    
    self.strengthLabel = [[UILabel alloc] init];
    [self.sliderBGView addSubview:self.strengthLabel];
    [self.strengthLabel setFont:[UIFont systemFontOfSize:10.f]];
    [self.strengthLabel setTextColor:[UIColor whiteColor]];
    [self.strengthLabel setText:NvLocalString(@"EditStrength" , @"程度")];
    self.strengthLabel.textAlignment = NSTextAlignmentCenter;
    [self.strengthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.sliderBGView.mas_centerY);
        make.left.equalTo(self.sliderBGView.mas_left);
        make.width.mas_equalTo(45);
        make.height.offset(20 * SCREENSCALE);
    }];
    
    /*
     马赛克效果两个slider
     Two sliders with mosaic effect
     */
    self.strengthMOSSlider = [[UISlider alloc] init];
    self.strengthMOSSlider.maximumValue = 1;
    self.strengthMOSSlider.minimumValue = 0;
    [self.strengthMOSSlider setThumbImage:NvImageNamed(@"Nvslider") forState:UIControlStateNormal];
    [self.strengthMOSSlider setMinimumTrackTintColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"]];
    [self.strengthMOSSlider setMaximumTrackTintColor:[UIColor nv_colorWithHexRGB:@"#CFCFCF"]];
    [self.strengthMOSSlider addTarget:self action:@selector(strengthSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.sliderBGView addSubview:self.strengthMOSSlider];
    [self.strengthMOSSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.strengthLabel.mas_right).offset(10);
        make.width.mas_equalTo(110*SCREENSCALE);
        make.height.mas_equalTo(15*SCREENSCALE);
        make.centerY.equalTo(self.sliderBGView.mas_centerY);
    }];

    self.amountMOSLabel = [[UILabel alloc] init];
    [self.sliderBGView addSubview:self.amountMOSLabel];
    [self.amountMOSLabel setFont:[UIFont systemFontOfSize:10.f]];
    [self.amountMOSLabel setTextColor:[UIColor whiteColor]];
    [self.amountMOSLabel setText:NvLocalString(@"AmountMOS" , @"数量")];
    self.amountMOSLabel.textAlignment = NSTextAlignmentCenter;
    [self.amountMOSLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.sliderBGView.mas_centerY);
        make.left.equalTo(self.strengthMOSSlider.mas_right).offset(12);
        make.width.mas_equalTo(45);
        make.height.offset(20 * SCREENSCALE);
    }];

    self.amountMOSSlider = [[UISlider alloc] init];
    self.amountMOSSlider.maximumValue = 100;
    self.amountMOSSlider.minimumValue = 0;
    [self.amountMOSSlider setThumbImage:NvImageNamed(@"Nvslider") forState:UIControlStateNormal];
    [self.amountMOSSlider setMinimumTrackTintColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"]];
    [self.amountMOSSlider setMaximumTrackTintColor:[UIColor nv_colorWithHexRGB:@"#CFCFCF"]];
    [self.amountMOSSlider addTarget:self action:@selector(amountMOSSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.sliderBGView addSubview:self.amountMOSSlider];
    [self.amountMOSSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.amountMOSLabel.mas_right).offset(10);
        make.width.mas_equalTo(110*SCREENSCALE);
        make.height.mas_equalTo(15*SCREENSCALE);
        make.centerY.equalTo(self.sliderBGView.mas_centerY);
    }];
    
    /*
     模糊效果的slider
     Blur effect slider
     */
    self.strengthBlurSlider = [[UISlider alloc] init];
    self.strengthBlurSlider.maximumValue = 1;
    self.strengthBlurSlider.minimumValue = 0;
    [self.strengthBlurSlider setThumbImage:NvImageNamed(@"Nvslider") forState:UIControlStateNormal];
    [self.strengthBlurSlider setMinimumTrackTintColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"]];
    [self.strengthBlurSlider setMaximumTrackTintColor:[UIColor nv_colorWithHexRGB:@"#CFCFCF"]];
    [self.strengthBlurSlider addTarget:self action:@selector(strengthSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.sliderBGView addSubview:self.strengthBlurSlider];
    [self.strengthBlurSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.strengthLabel.mas_right).offset(15);
        make.width.mas_equalTo(250*SCREENSCALE);
        make.height.mas_equalTo(15*SCREENSCALE);
        make.centerY.equalTo(self.sliderBGView.mas_centerY);
    }];
    NvWatemarkItem *effct1 = self.effectArray[0];
    NvWatemarkItem *effect2 = self.effectArray[1];
    self.strengthMOSSlider.value = effct1.intensity;
    self.amountMOSSlider.value = effct1.unitSize * 1000;
    self.strengthBlurSlider.value = effect2.intensity;
    [self unselectEffectItem];
    
    /*
     上部切换类型按钮
     Upper switch type button
     */
    self.pngBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pngBtn setTitle:NvLocalString(@"Static", @"静态") forState:UIControlStateNormal];
    [self.pngBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#909293"] forState:UIControlStateNormal];
    [self.pngBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateSelected];
    [self.pngBtn addTarget:self action:@selector(pngBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.pngBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [self.view addSubview:self.pngBtn];
    [self.pngBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sliderBGView.mas_top).offset(-10 * SCREENSCALE);
        make.left.equalTo(self.view).offset(KScale6s(15));
        make.width.mas_lessThanOrEqualTo(80 * SCREENSCALE);
        make.height.offset(40 * SCREENSCALE);
    }];
    
    self.cafBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cafBtn setTitle:NvLocalString(@"Dynamic", @"动态") forState:UIControlStateNormal];
    self.cafBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [self.cafBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#909293"] forState:UIControlStateNormal];
    [self.cafBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateSelected];
    [self.cafBtn addTarget:self action:@selector(cafBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cafBtn];
    [self.cafBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sliderBGView.mas_top).offset(-10 * SCREENSCALE);
        make.left.equalTo(self.pngBtn.mas_right).offset(KScale6s(15));
        make.width.mas_lessThanOrEqualTo(80 * SCREENSCALE);
        make.height.offset(40 * SCREENSCALE);
    }];
    
    self.effectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.effectBtn setTitle:NvLocalString(@"Watermark Effect", @"效果") forState:UIControlStateNormal];
    self.effectBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [self.effectBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#909293"] forState:UIControlStateNormal];
    [self.effectBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateSelected];
    [self.effectBtn addTarget:self action:@selector(effectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.effectBtn];
    [self.effectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sliderBGView.mas_top).offset(-10 * SCREENSCALE);
        make.left.equalTo(self.cafBtn.mas_right).offset(KScale6s(15));
        make.width.mas_lessThanOrEqualTo(80 * SCREENSCALE);
        make.height.offset(40 * SCREENSCALE);
    }];
    
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pngBtn.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.offset(1);
    }];
    
    self.pngLine = [[UIView alloc]init];
    self.pngLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    [lineView addSubview:self.pngLine];
    [self.pngLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pngBtn.mas_bottom);
        make.width.equalTo(self.pngBtn.mas_width);
        make.height.offset(1);
        make.centerX.equalTo(self.pngBtn.mas_centerX);
    }];
    
    self.cafLine = [[UIView alloc]init];
    self.cafLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    [lineView addSubview:self.cafLine];
    [self.cafLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cafBtn.mas_bottom);
        make.width.equalTo(self.cafBtn.mas_width);
        make.height.offset(1);
        make.centerX.equalTo(self.cafBtn.mas_centerX);
    }];
    
    self.effectLine = [[UIView alloc]init];
    self.effectLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    [lineView addSubview:self.effectLine];
    [self.effectLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.effectBtn.mas_bottom);
        make.width.equalTo(self.effectBtn.mas_width);
        make.height.offset(1);
        make.centerX.equalTo(self.effectBtn.mas_centerX);
    }];
}

#pragma mark - 根据数据更新页面状态
/*
 根据数据更新页面状态
 Update page status based on data
 */
- (void)remakeSubviews {
    
    if (self.timelineData.watermarkInfo.isCaf) {
        
        self.cafBtn.selected = YES;
        self.cafLine.hidden = NO;
        self.pngLine.hidden = YES;
        self.effectLine.hidden = YES;
        [self unselectEffectItem];
    }else if (self.timelineData.watermarkInfo.isBuiltInEffect) {
        
        self.effectBtn.selected = YES;
        self.effectLine.hidden = NO;
        self.cafLine.hidden = YES;
        self.pngLine.hidden = YES;
        NvBuiltInWatermarkEffectModel *effectModel = self.timelineData.watermarkInfo.builtInEffect;
        NSString *effectName = effectModel.effectName;
        if ([effectName isEqualToString:@"Mosaic"]) {
            
            [self selectEffectItem:0];
            self.strengthMOSSlider.value = effectModel.intensity;
            self.amountMOSSlider.value = effectModel.unitSize * 1000;
        }else if ([effectName isEqualToString:@"Fast Blur"]){
            
            [self selectEffectItem:1];
            self.strengthBlurSlider.value = effectModel.intensity;
        }
    }else{
        
        [self unselectEffectItem];
        self.pngBtn.selected = YES;
        self.pngLine.hidden = NO;
        self.cafLine.hidden = YES;
        self.effectLine.hidden = YES;
    }
}

#pragma mark - 根据参数更新效果标签界面状态
/*
 根据参数更新效果标签界面状态
 Update the status of the effect label interface according to the parameters
 
 @param index 下标 index
 */
- (void)selectEffectItem:(NSInteger)index {
    self.sliderBGView.hidden = NO;
    self.strengthLabel.hidden = NO;
    if (index == 0) {
        self.strengthMOSSlider.hidden = NO;
        self.amountMOSLabel.hidden = NO;
        self.amountMOSSlider.hidden = NO;
        self.strengthBlurSlider.hidden = YES;
    }else{
        self.strengthMOSSlider.hidden = YES;
        self.amountMOSLabel.hidden = YES;
        self.amountMOSSlider.hidden = YES;
        self.strengthBlurSlider.hidden = NO;
    }
}

#pragma mark - 恢复效果标签界面默认状态
/*
 恢复效果标签界面默认状态
 Restore the default state of the effect tab interface
 */
- (void)unselectEffectItem {
    self.strengthLabel.hidden = YES;
    self.strengthMOSSlider.hidden = YES;
    self.amountMOSLabel.hidden = YES;
    self.amountMOSSlider.hidden = YES;
    self.strengthBlurSlider.hidden = YES;
    self.sliderBGView.hidden = YES;
}

#pragma mark - 内置效果slider方法
/*
 内置效果slider方法
 Built-in effect slider method
 
 @param slider 当前滑杆 Current slider
 */
- (void)strengthSliderValueChanged:(UISlider *)slider {
    if (self.videoFx) {
        [self.videoFx setFilterIntensity:slider.value];
        self.currentItem.intensity = slider.value;
        [self seekTimeline];
    }
}

#pragma mark - 马赛克数量slider方法
/*
 马赛克数量slider方法
 Mosaic quantity slider method
 
 @param slider 当前滑杆 Current slider
 */
- (void)amountMOSSliderValueChanged:(UISlider *)slider {
    if (self.videoFx) {
        float unitSize = slider.value / 1000;
        if (unitSize>1) {
            return;
        }
        self.currentItem.unitSize = unitSize;
        [self.videoFx setFloatVal:@"Unit Size" val:unitSize];
        [self seekTimeline];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NvWatemarkCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvWatemarkCVCell" forIndexPath:indexPath];
    [cell renderCellWithItem:_currentArray[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvWatemarkItem *model in self.currentArray) {
        model.selected = NO;
    }
    [self seekTimeline];
    NvWatemarkItem *item = self.currentArray[indexPath.item];
    if ([self.currentArray isEqualToArray:self.pngArray]) {
        if (indexPath.item == 0) {
            item.selected = NO;
            [self addBtnClick];
            
        }else{
            item.selected = YES;
            if(![item isEqual:self.currentItem]){
                self.currentItem = item;
                if (item.isCacheImage) {
                    self.currentImage = [UIImage imageWithContentsOfFile:[WATEMARK_PATH stringByAppendingPathComponent:[item.coverString stringByAppendingString:@".png"]]];
                }else{
                    self.currentImage = NvImageNamed(item.coverString);
                }
                [self adapterWidthAndHeight];
                [self addWatermark];
                self.isSave = YES;
            }
        }
        if (self.videoFx) {
            [self.timeline removeTimelineVideoFx:self.videoFx];
            self.videoFx = nil;
        }
    }else if ([self.currentArray isEqualToArray:self.effectArray]){
        /*
         水印内置效果
         Built-in watermark effect
         */
        item.selected = YES;
        if (![item isEqual:self.currentItem]){
            [self adapterBuiltInEffectWidthAndHeight];
            [self addWatermark];
            self.imageView.image = nil;
            [self.timeline deleteWatermark];
            if (self.videoFx) {
                [self.timeline removeTimelineVideoFx:self.videoFx];
                self.videoFx = nil;
            }
            self.currentItem = item;
            self.currentImage = NvImageNamed(self.currentItem.coverString);
            [self selectEffectItem:indexPath.item];
            
            self.videoFx = [self.timeline addBuiltinTimelineVideoFx:self.inPoint duration:self.outPoint videoFxName:self.currentItem.effectName];
            [self.videoFx setRegional:YES];
            CGSize sceneSize = self.liveWindowPanel.liveWindow.bounds.size;
            NSArray *pointsArr = [NvTimelineUtils getRegionWithRect:self.imageView.frame sceneWidth:sceneSize.width sceneHeight:sceneSize.height];
            [self.videoFx setRegion:pointsArr];
            [self seekTimeline];
            
            if (indexPath.item == 0) {
                if (self.currentItem.unitSize<=1) {
                    [self.videoFx setFloatVal:@"Unit Size" val:self.currentItem.unitSize];
                }
                
            }
            [self.videoFx setFilterIntensity:self.currentItem.intensity];
            self.isSave = YES;
        }
    }else{
        item.selected = YES;
        if (![item isEqual:self.currentItem]) {
            if (self.videoFx) {
                [self.timeline removeTimelineVideoFx:self.videoFx];
                self.videoFx = nil;
            }
            self.currentItem = item;
            if (!self.videoFx) {
                self.videoFx = [self.timeline addBuiltinTimelineVideoFx:self.inPoint duration:self.outPoint videoFxName:@"Storyboard"];
            }
             self.currentImage = NvImageNamed(item.coverString);
            [self adapterWidthAndHeight];
            [self addWatermark];
            self.isSave = YES;
            NSString *descString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><storyboard sceneWidth=\"Swidth\" sceneHeight=\"SHeight\"><track source=\"cafFile\" width=\"Nwidth\" height=\"Nheight\" clipStart=\"0\" clipDuration=\"2000\" repeat=\"true\"><effect name=\"transform\"><param name=\"opacity\" value=\"1\"/><param name=\"transX\" value=\"0\"/><param name=\"transY\" value=\"0\"/></effect></track></storyboard>"];
            
            descString = [descString stringByReplacingOccurrencesOfString:@"Swidth" withString:[NSString stringWithFormat:@"%d",(int)self.liveWindowPanel.liveWindow.width]];
            descString = [descString stringByReplacingOccurrencesOfString:@"SHeight" withString:[NSString stringWithFormat:@"%d",(int)self.liveWindowPanel.liveWindow.height]];
            descString = [descString stringByReplacingOccurrencesOfString:@"Nwidth" withString:[NSString stringWithFormat:@"%d",(int)self.imageView.width]];
            descString = [descString stringByReplacingOccurrencesOfString:@"Nheight" withString:[NSString stringWithFormat:@"%d",(int)self.imageView.height]];
            descString = [descString stringByReplacingOccurrencesOfString:@"cafFile" withString:[NSString stringWithFormat:@"%@.caf",item.coverString]];
            NSString *packagePath = [[NSBundle bundleForClass:[self class]] bundlePath];
            [self.videoFx setStringVal:@"Resource Dir" val:packagePath];
            [self.videoFx setStringVal:@"Description String" val:descString];
            [self.videoFx setBooleanVal:@"Is Animated Sticker" val:true];
            self.dataModel.marginX = self.liveWindowPanel.liveWindow.width/2.0 - self.imageView.width + self.imageView.width/2.0 - 10;
            self.dataModel.marginY = self.liveWindowPanel.liveWindow.height/2.0 - self.imageView.height + self.imageView.height/2.0 - 10;
            [self.videoFx setFloatVal:@"Sticker TransX" val:self.dataModel.marginX];
            [self.videoFx setFloatVal:@"Sticker TransY" val:self.dataModel.marginY];
        }
    }
    [collectionView reloadData];
}

#pragma mark - 静态按钮点击事件
/*
 静态按钮点击事件
 Static button click event
 
 @param sender 当前按钮 Current button
 */
- (void)pngBtnClick:(UIButton *)sender{
    if (!sender.selected) {
        self.currentArray = self.pngArray;
        for (NvWatemarkItem *model in self.currentArray) {
            if (_currentImage) {
                if ([self.currentItem isEqual:model]) {
                    model.selected = YES;
                }else{
                    model.selected = NO;
                }
            }else{
                model.selected = NO;
            }
        }
        sender.selected = YES;
        self.sliderBGView.hidden = YES;
        self.pngLine.hidden = NO;
        self.cafLine.hidden = YES;
        self.effectLine.hidden = YES;
        self.effectBtn.selected = NO;
        self.cafBtn.selected = NO;
        [self.watemarkCView reloadData];
    }
}

#pragma mark - 动态按钮点击事件
/*
 动态按钮点击事件
 Dynamic button click event
 
 @param sender 当前按钮 Current button
 */
- (void)cafBtnClick:(UIButton *)sender{
    if (!sender.selected) {
        self.currentArray = self.cafArray;
        for (NvWatemarkItem *model in self.currentArray) {
            if (_currentImage) {
                if ([self.currentItem isEqual:model]) {
                    model.selected = YES;
                }else{
                    model.selected = NO;
                }
            }else{
                model.selected = NO;
            }
        }
        sender.selected = YES;
        self.sliderBGView.hidden = YES;
        self.cafLine.hidden = NO;
        self.pngLine.hidden = YES;
        self.pngBtn.selected = NO;
        self.effectLine.hidden = YES;
        self.effectBtn.selected = NO;
        [self.watemarkCView reloadData];
    }
}

#pragma mark - 效果按钮点击事件
/*
 效果按钮点击事件
 Effect button click event
 
 @param sender 当前按钮 Current button
 */
- (void)effectBtnClick:(UIButton *)sender{
    if (!sender.selected) {
        self.currentArray = self.effectArray;
        for (NvWatemarkItem *model in self.currentArray) {
            if (_currentImage) {
                if ([self.currentItem isEqual:model]) {
                    model.selected = YES;
                }else{
                    model.selected = NO;
                }
            }else{
                model.selected = NO;
            }
        }
        sender.selected = YES;
        self.sliderBGView.hidden = NO;
        self.effectLine.hidden = NO;
        self.cafLine.hidden = YES;
        self.pngLine.hidden = YES;
        self.pngBtn.selected = NO;
        self.cafBtn.selected = NO;
        [self.watemarkCView reloadData];
    }
}

#pragma mark - 添加按钮点击事件
/*
 添加按钮点击事件
 Add button click event
 */
- (void)addBtnClick{
    [self seekTimeline];
    NvAlbumViewController *album = [NvAlbumViewController new];
    album.delegate = self;
    album.isOnlyImage = YES;
    album.mutableSelect = NO;
    [album customSelectAssetButtonText:NvLocalString(@"Next", @"下一步")];
    NvBaseNavigationController *nav = [[NvBaseNavigationController alloc] initWithRootViewController:album];
    [self presentViewController:nav animated:YES completion:NULL];
}

#pragma mark - NvAlbumViewControllerDelegate
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray<NvAlbumAsset *> *)assets{
    [albumViewController dismissViewControllerAnimated:YES completion:NULL];
    NvAlbumAsset *asset = [assets firstObject];
    __block BOOL isshowToast = false;
    __weak typeof(self)weakSelf = self;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset.asset
                                               targetSize:CGSizeMake(self.liveWindowPanel.liveWindow.width,self.liveWindowPanel.liveWindow.height)
                                              contentMode:PHImageContentModeAspectFit
                                                  options:requestOptions
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                BOOL isIcloud =  [[info valueForKeyPath:@"PHImageResultIsInCloudKey"] boolValue];
                                                if (isIcloud) {
                                                    isshowToast = YES;
                                                } else {
                                                    weakSelf.currentImage = result;
                                                    [weakSelf adapterWidthAndHeight];
                                                    [weakSelf addWatermark];
                                                    weakSelf.isSave = YES;
                                                    NvWatemarkItem *item = [NvWatemarkItem new];
                                                    weakSelf.currentItem = item;
                                                    item.isCaf = NO;
                                                    item.isCacheImage = YES;
                                                    item.selected = YES;
                                                    item.coverString = [NvUtils currentDateAndTime];
                                                    item.coverString = [weakSelf saveImage:result];
                                                    [weakSelf.pngArray insertObject:item atIndex:weakSelf.pngArray.count - 1];
                                                }
                                                dispatch_semaphore_signal(semaphore);
                                            }
     ];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isshowToast) {
            
            [UIAlertController presentAlertFromVC:weakSelf
                                            title:NvLocalString(@"Tips" , @"提示")
                                          message:NvLocalString(@"album.iClould", @"所选资源在iCloud中")
                                buttonTitleColors:nil
                                cancelButtonTitle:nil
                                 otherButtonTitle:NvLocalString(@"Sure", @"确定")
                               cancelButtonAction:nil
                                otherButtonAction:nil];

        }
    });
    
    [self.watemarkCView reloadData];
}

- (void)nvAlbumViewControllerCancelClick:(NvAlbumViewController *)albumViewController {
    [albumViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - 添加水印图片
/*
 添加水印图片
 Add a watermark image
 */
- (void)addWatermark{
    if (self.imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    self.imageView = [[NvEditWatemarkImageView alloc]initWithFrame:CGRectMake(self.liveWindowPanel.liveWindow.width - self.imageSize.width - 10, 10, self.imageSize.width, self.imageSize.height)];
    self.dataModel.marginX = 10;
    self.dataModel.marginY = 10;
    self.imageView.delegate = self;
    if (!self.currentItem.isCaf && !self.currentItem.isBuiltInEffect) {
        self.imageView.image = self.currentImage;
    }
    self.editState = YES;
    [self.liveWindowPanel.liveWindow addSubview:self.imageView];
}

#pragma mark - NvLiveWindowPanelViewDelegate
- (void)playback{
    self.editState = NO;
    [self.imageView hiddenView:!self.editState];
}

- (void)didPlaybackStopped:(NvsTimeline *)timeline{
    self.editState = YES;
    self.imageView.hidden = NO;
    [self.imageView hiddenView:!self.editState];
}

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position{
    self.editState = NO;
    [self.imageView hiddenView:!self.editState];
    if (self.videoFx) {
        self.imageView.hidden = YES;
    }else{
        self.imageView.hidden = NO;
    }
}

#pragma mark - NvEditWatemarkImageViewDelegate
- (void)nvEditWatemarkImageViewWithDeleteClick{
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    self.currentItem = nil;
    self.dataModel.imageUrl = nil;
    self.timelineData.watermarkInfo = nil;
    self.isSave = NO;
    if (self.videoFx) {
        [self.timeline removeTimelineVideoFx:self.videoFx];
        [self seekTimeline];
        self.videoFx = nil;
    }
    for (NvWatemarkItem *model in self.pngArray) {
        model.selected = NO;
    }
    for (NvWatemarkItem *model in self.cafArray) {
        model.selected = NO;
    }
    for (NvWatemarkItem *model in self.effectArray) {
        model.selected = NO;
    }
    [self.watemarkCView reloadData];
}

- (void)nvEditWatemarkImageView:(NvEditWatemarkImageView *)watemarkView updateRect:(CGRect)rect withState:(BOOL)isEnd{
    if (self.editState) {
        self.isSave = YES;
        self.dataModel.marginX = self.liveWindowPanel.liveWindow.width - rect.size.width - rect.origin.x;
        self.dataModel.marginY = rect.origin.y;
        if (self.currentItem.isBuiltInEffect) {
            if (self.videoFx) {
                CGSize sceneSize = self.liveWindowPanel.liveWindow.bounds.size;
                NSArray *pointsArr = [NvTimelineUtils getRegionWithRect:rect sceneWidth:sceneSize.width sceneHeight:sceneSize.height];
                [self.videoFx setRegion:pointsArr];
                [self seekTimeline];
            }
        }else{
            if (self.videoFx) {
                self.dataModel.marginX = rect.origin.x - self.liveWindowPanel.liveWindow.width/2.0 + rect.size.width/2.0;
                self.dataModel.marginY = -(rect.origin.y - self.liveWindowPanel.liveWindow.height/2.0 + rect.size.height/2.0);
                [self.videoFx setFloatVal:@"Sticker TransX" val:self.dataModel.marginX];
                [self.videoFx setFloatVal:@"Sticker TransY" val:self.dataModel.marginY];
                [self.videoFx setFloatVal:@"Sticker Scale"  val:rect.size.height/self.imageSize.height];
                [self seekTimeline];
            }
            
        }
        if (isEnd) {
            [self.liveWindowPanel playbackBtnClicked];
        }
    }
}

#pragma mark - 为图片展示控件计算合理宽度和高度
/*
 为图片展示控件计算合理宽度和高度
 Calculate reasonable width and height for the picture display control
 */
- (void)adapterWidthAndHeight{
    CGFloat width,height;
    CGFloat viewWidth = self.liveWindowPanel.liveWindow.width;
    CGFloat viewHeight = self.liveWindowPanel.liveWindow.height;
    CGFloat imageWidth = self.currentImage.size.width;
    CGFloat imageHeight = self.currentImage.size.height;
    NSUInteger widthScale = ceilf(imageWidth / viewWidth);
    NSUInteger heightScale = ceilf(imageHeight / viewHeight);
    if (widthScale == 1 && heightScale == 1) {
        width = imageWidth;
        height = imageHeight;
    } else {
        if (widthScale > heightScale) {
            width = viewWidth;
            height = viewWidth / (imageWidth/imageHeight);
        } else {
            width = viewHeight * (imageWidth/imageHeight);
            height = viewHeight;
        }
    }
    self.imageSize = CGSizeMake(width < 20?width * 4:width/3, height < 20 ? height * 4:height/3);
}

#pragma mark - 调整内置效果控件宽高
/*
 调整内置效果控件宽高
 Adjust the width and height of the built-in effect controls
 */
- (void)adapterBuiltInEffectWidthAndHeight {
    CGFloat viewWidth = self.liveWindowPanel.liveWindow.width;
    CGFloat viewHeight = self.liveWindowPanel.liveWindow.height;
    self.imageSize = CGSizeMake(viewWidth/2, viewHeight/2);
}

#pragma mark - 完成按钮点击事件
/*
 完成按钮点击事件
 Finish button click event
 */
- (void)finshBtnClick{
    if (self.isSave) {
        [self configWatermarkInfo];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 操作完成，重新配置数据
/*
 操作完成，重新配置数据
 The operation is complete, reconfigure the data
 */
- (void)configWatermarkInfo{
    if (self.currentItem.isCaf) {
        self.dataModel.isCaf = YES;
        self.dataModel.imageUrl = [self saveCaf:self.currentItem.coverString];
        self.dataModel.displayWidth = self.imageView.width;
        self.dataModel.displayHeight = self.imageView.height;
        self.dataModel.marginX = self.dataModel.marginX;
        self.dataModel.marginY = self.dataModel.marginY;
        self.dataModel.sceneWidth = self.liveWindowPanel.liveWindow.width;
        self.dataModel.sceneHeight = self.liveWindowPanel.liveWindow.height;
        self.dataModel.inPoint = self.inPoint;
        self.dataModel.outPoint = self.outPoint;
    }else if (self.currentItem.isBuiltInEffect) {
        self.dataModel.isBuiltInEffect = YES;
        self.dataModel.builtInEffect = [NvBuiltInWatermarkEffectModel new];
        self.dataModel.builtInEffect.effectName = self.currentItem.effectName;
        self.dataModel.builtInEffect.intensity = self.currentItem.intensity;
        self.dataModel.builtInEffect.unitSize = self.currentItem.unitSize;
        self.dataModel.isCaf = NO;
        self.dataModel.imageUrl = [self saveCaf:self.currentItem.coverString];
        self.dataModel.displayWidth = self.imageView.width;
        self.dataModel.displayHeight = self.imageView.height;
        self.dataModel.sceneWidth = self.liveWindowPanel.liveWindow.width;
        self.dataModel.sceneHeight = self.liveWindowPanel.liveWindow.height;
        self.dataModel.inPoint = self.inPoint;
        self.dataModel.outPoint = self.outPoint;
        self.dataModel.marginX = self.imageView.frame.origin.x;
        self.dataModel.marginY = self.imageView.frame.origin.y;
    }else{
        if (self.currentItem.isCacheImage) {
            self.dataModel.imageUrl = self.currentItem.coverString;
        }else{
            self.dataModel.imageUrl = [self saveImage:self.currentImage];
        }
        self.dataModel.displayWidth = self.imageView.width * self.proportion;
        self.dataModel.displayHeight = self.imageView.height * self.proportion;
        self.dataModel.marginX = self.dataModel.marginX * self.proportion;
        self.dataModel.marginY = self.dataModel.marginY * self.proportion;
    }
    self.timelineData.watermarkInfo = self.dataModel;
}

#pragma mark - 返回按钮
- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

#pragma mark - 保存caf到本地，并返回保存路径
/*
 保存caf到本地，并返回保存路径
 Save the cafe to the local, and return to the save path
 
 @param cafString 文件名 file name
 
 return 返回NSString值。保存的路径 Saved path
 */
- (NSString *)saveCaf:(NSString *)cafString {
    NSString *path = [WATEMARK_PATH stringByAppendingPathComponent:[cafString stringByAppendingString:@".caf"]];
    NSString *bundle = [[[NSBundle bundleForClass:self.class] bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",cafString]];
    NSData *data = [NSData dataWithContentsOfFile:bundle];
    if ([data writeToFile:path atomically:YES]) {
        NSLog(@"success");
    }else{
        NSLog(@"failure");
    }
    return cafString;
}

#pragma mark - 保存图片到本地，并返回保存路径
/*
 保存图片到本地，并返回保存路径
 Save the picture locally and return to the save path
 
 @param image 文件名 file name
 
 return 返回NSString值。保存的路径 Saved path
 */
- (NSString *)saveImage:(UIImage *)image {
    NSString *name = [NvUtils currentDateAndTime];
    if (!self.currentItem.isCacheImage) {
        name = self.currentItem.coverString;
    }
    NSString *path = [WATEMARK_PATH stringByAppendingPathComponent:[name stringByAppendingString:@".png"]];
    NSLog(@"name ==%@   path==%@,image == %@",name,path,image);
    NSData *data = UIImagePNGRepresentation(image);
    if ([data writeToFile:path atomically:YES]) {
        NSLog(@"success");
    }else{
        NSLog(@"failure");
    }
    return name;
}

#pragma mark - 把路径下的文件转成image对象
/*
 把路径下的文件转成image对象
 Convert the file under the path into an image object
 */
- (UIImage *)getImage {
    NSString *path = [WATEMARK_PATH stringByAppendingPathComponent:[self.timelineData.watermarkInfo.imageUrl stringByAppendingString:@".png"]];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    return img;
}

- (NvWatermarkInfoModel *)dataModel{
    if (!_dataModel)
    {
        _dataModel = [NvWatermarkInfoModel new];
    }
    return _dataModel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
