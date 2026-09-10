//
//  NvEditPictureViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/7/21.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvEditPictureViewController.h"
#import "NvEditClipLiveWindow.h"
#import "NvsVideoFx.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvsVideoTrack.h"
#import "NvsAudioClip.h"
#import "NvTimelineImageUtils.h"
#import "NvSwitchView.h"
#import "EditPictureDragView.h"

@interface NvEditPictureViewController ()<EditPictureDragViewDelegate>

///所有模块统一控件
///All modules unified control

///播放控件
///Playback control
@property (nonatomic, strong) NvEditClipLiveWindow *clipLivewindow;
///完成按钮
///Finish button
@property (nonatomic, strong) UIButton *finshBtn;
@property (nonatomic, strong) UIView *line;

///时长模块
///调节之后的时间
///Adjust the time after
@property (nonatomic, strong) UILabel *timeLabel;

///运动模块
///Motion module
///区域显示按钮
///Zone display button
@property (nonatomic, strong) UIButton *areaBtn;
///区域显示按钮选中蒙层
///Zone Display button with Mask selected
@property (nonatomic, strong) UIView *areaView;
///全图显示按钮
///Full picture display button
@property (nonatomic, strong) UIButton *fullBtn;
///全图显示按钮选中蒙层
///Full Display button with Mask selected
@property (nonatomic, strong) UIView *fullView;
///当前预览图片
///Current preview image
@property (nonatomic, strong) UIImageView *currentImageView;
///画面运动
///Picture motion
@property (nonatomic, strong) NvSwitchView *switchView;
///预览按钮点击之后弹出的视图
///Preview the view that pops up after the button is clicked
@property (nonatomic, strong) UIView *previewView;
///开始拖动框
///Start drag box
@property (nonatomic, strong) EditPictureDragView *startDragView;
///结束拖动框
///End drag box
@property (nonatomic, strong) EditPictureDragView *endDragView;
///区域拖动框
///Area drag box
@property (nonatomic, strong) EditPictureDragView *areaDragView;
///图片宽
///Picture width
@property (nonatomic, assign) CGFloat imageWidth;
///图片高
///Picture height
@property (nonatomic, assign) CGFloat imageHeight;
///当前图片
///Current picture
@property (nonatomic, strong) UIImage *currentImage;
///是否运动
///Exercise or not
@property (nonatomic, assign) BOOL movementState;

//-----------------sdk相关  SDK-related----------------//
///流媒体上下文
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
///数据结构
///Data structure
@property (nonatomic, strong) NvTimelineData *timelineData;
///根据当前片段创建timeline，并操作
///Create a timeline based on the current fragment and operate
@property (nonatomic, strong) NvsTimeline *currentTimeline;
///copy一份新的model，保存起来
///copy a new model and save it
@property (nonatomic, strong) NvEditDataModel *currentDataModel;
///当前片段
///Current fragment
@property (nonatomic, strong) NvsVideoClip * videoClip;
@end

@implementation NvEditPictureViewController{
    ///开始运动的位置
    ///The starting position of motion
    NvsRect startRectImage;
    ///结束运动的位置
    ///End motion position
    NvsRect endRectImage;
    ///区域位置
    ///Area position
    NvsRect areaRectImage;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NvTimelineUtils removeTimeline:self.currentTimeline];
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.streamingContext = [NvSDKUtils getSDKContext];
    self.currentTimeline = [NvTimelineUtils createTimeline:self.editMode];
    self.timelineData = [NvTimelineData sharedInstance];
    [NvTimelineUtils resetEditData:self.currentTimeline editDataArray:[NSArray arrayWithObject:self.model]];
    self.videoClip = [[self.currentTimeline getVideoTrackByIndex:0] getClipWithIndex:0];
    self.currentDataModel = [self.model copy];
    self.movementState = self.model.hasMotion;
    
    [self addSubViews];
    self.areaBtn.selected = self.model.isArea;
    self.fullBtn.selected = !self.model.isArea;
    self.areaView.hidden = !self.areaBtn.selected;
    self.fullView.hidden = !self.fullBtn.selected;
    [self configDragView];
    // Do any additional setup after loading the view.
}

#pragma mark 添加子视图
///Add subview
- (void)addSubViews{
    UIButton *finshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finshBtn setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [finshBtn addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finshBtn];
    [finshBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(@(-15*SCREENSCALE));
        }
        make.centerX.equalTo(self.view.mas_centerX);
    }];

    
    self.line = [UIView new];
    self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(finshBtn.mas_top).offset(-12*SCREENSCALE);
    }];
    
    if ([self.title isEqualToString:NvLocalString(@"Duration", @"时长")]) {
        [self addTimeModuleView];
    }else if ([self.title isEqualToString:NvLocalString(@"Motion", @"运动")]){
        if (self.model.isPhotoAlbum) {
            PHFetchResult<PHAsset *> *phresult = [PHAsset fetchAssetsWithLocalIdentifiers:[NSArray arrayWithObject:self.model.localIdentifier] options:nil];
            PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.synchronous = YES;
            PHAsset *asset = [phresult firstObject];
            [[PHImageManager defaultManager] requestImageForAsset:asset
                                                       targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)
                                                      contentMode:PHImageContentModeAspectFit
                                                          options:requestOptions
                                                    resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                        self.currentImage= result;
                                                        [self adapterWidthAndHeight];
                                                        [self addMovementModelView];
                                                        [self addDragView];
                                                    }];
        }else{
            self.currentImage = [UIImage imageWithContentsOfFile:self.model.localIdentifier];
            [self adapterWidthAndHeight];
            [self addMovementModelView];
            [self addDragView];
        }
    }
    if ([self.title isEqualToString:NvLocalString(@"Motion", @"运动")]) {
        [self addPreviewView];
    }
    
}

#pragma mark 时长模块控件
///时长模块控件
///Duration module control
- (void)addTimeModuleView{
    self.clipLivewindow = [[NvEditClipLiveWindow alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width)];
    [self.view addSubview:self.clipLivewindow];
    [self.clipLivewindow connectTimeline:self.currentTimeline];
    self.clipLivewindow.editMode = self.editMode;
    [self.clipLivewindow seekTimeline:0];
    [self.clipLivewindow setPlayRangeIn:0 rangeOut:self.currentTimeline.duration];
    [self.clipLivewindow play];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.text = NvLocalString(@"Adjustment time", @"拖动滑块调整时长");
    titleLabel.font = [NvUtils fontWithSize:12];
    titleLabel.numberOfLines = 2;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UISlider * timeLengSlider = [UISlider new];
    [timeLengSlider setMinimumValue:1];
    [timeLengSlider setMaximumValue:10];
    timeLengSlider.minimumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    timeLengSlider.maximumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    [timeLengSlider setThumbImage:NvImageNamed(@"Nvslider") forState:UIControlStateNormal];
    [timeLengSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [timeLengSlider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    [timeLengSlider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpOutside];
    timeLengSlider.value = (int)(self.currentTimeline.duration/NV_TIME_BASE);
    
    self.timeLabel = [[UILabel alloc]init];
    self.timeLabel.text = [NSString stringWithFormat:@"%llds",(self.currentTimeline.duration/NV_TIME_BASE)];
    self.timeLabel.textColor = UIColor.whiteColor;
    self.timeLabel.font = [NvUtils fontWithSize:12];
    
    [self.view addSubview:titleLabel];
    [self.view addSubview:timeLengSlider];
    [self.view addSubview:self.timeLabel];
    
    [timeLengSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.line.mas_top).offset(-75 * SCREENSCALE);
        make.left.equalTo(self.view.mas_left).offset(13 * SCREENSCALE);
        make.width.offset(321 * SCREENSCALE);
        make.height.offset(10 * SCREENSCALE);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(timeLengSlider.mas_top).offset(-34 * SCREENSCALE);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_lessThanOrEqualTo(KScale6s(345));
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(timeLengSlider.mas_centerY);
        make.right.equalTo(self.view.mas_right).offset(-13 * SCREENSCALE);
    }];
}

#pragma mark 运动模块控件
///Motion module control
- (void)addMovementModelView{
    UIView *imageBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 387 * SCREENSCALE)];
    imageBackView.backgroundColor = UIColor.clearColor;
    
    self.currentImageView = [[UIImageView alloc]init];
    self.currentImageView.userInteractionEnabled = YES;
    self.currentImageView.image = self.currentImage;
    self.currentImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.switchView = [[NvSwitchView alloc]initWithFrame:CGRectMake(0, 0, 62 * SCREENSCALE, 27 * SCREENSCALE) withType:1 withState:self.movementState];
    self.switchView.selected = self.movementState;
    [self.switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *huamianyundong = [[UILabel alloc]init];
    huamianyundong.alpha = 0.8;
    huamianyundong.text = NvLocalString(@"Picture movement", @"画面运动");
    huamianyundong.font = [NvUtils fontWithSize:12];
    huamianyundong.textColor = UIColor.whiteColor;
    huamianyundong.numberOfLines = 2;
    huamianyundong.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UIButton *previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    previewBtn.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    [previewBtn setTitle:NvLocalString(@"Preview", @"预览") forState:UIControlStateNormal];
    previewBtn.titleLabel.font = [NvUtils fontWithSize:12];
    previewBtn.titleLabel.alpha = 0.8;
    previewBtn.layer.masksToBounds = YES;
    previewBtn.layer.cornerRadius = 27 * SCREENSCALE / 2.0;
    [previewBtn addTarget:self action:@selector(previewBtn:) forControlEvents:UIControlEventTouchUpInside];

    self.areaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.areaBtn setImage:NvImageNamed(@"NvEditPictureArea") forState:UIControlStateNormal];
    [self.areaBtn addTarget:self action:@selector(areaBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.areaView = [[UIView alloc]init];
    self.areaView.layer.cornerRadius = 4 * SCREENSCALE;
    self.areaView.backgroundColor = [[UIColor nv_colorWithHexRGB:@"#52D3FF"] colorWithAlphaComponent:.7];
    
    UILabel *areaLabel = [[UILabel alloc]init];
    areaLabel.text = NvLocalString(@"Region", @"区域");
    areaLabel.textColor = UIColor.whiteColor;
    areaLabel.font = [NvUtils fontWithSize:12];
    areaLabel.alpha = 0.8;
    
    self.fullBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fullBtn setImage:NvImageNamed(@"NvEditPictureFull") forState:UIControlStateNormal];
    [self.fullBtn addTarget:self action:@selector(fullBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.fullView = [[UIView alloc]init];
    self.fullView.layer.cornerRadius = 4 * SCREENSCALE;
    self.fullView.backgroundColor = [[UIColor nv_colorWithHexRGB:@"#52D3FF"] colorWithAlphaComponent:.7];
    
    UILabel *fullLabel = [[UILabel alloc]init];
    fullLabel.text = NvLocalString(@"Full", @"全图");
    fullLabel.textColor = UIColor.whiteColor;
    fullLabel.font = [NvUtils fontWithSize:12];
    fullLabel.alpha = 0.8;
    
    [self.view addSubview:imageBackView];
    [imageBackView addSubview:self.currentImageView];
    [self.view addSubview:self.switchView];
    [self.view addSubview:huamianyundong];
    [self.view addSubview:previewBtn];
    [self.view addSubview:self.areaBtn];
    [self.view addSubview:self.fullBtn];
    [self.areaBtn addSubview:self.areaView];
    [self.fullBtn addSubview:self.fullView];
    [self.view addSubview:areaLabel];
    [self.view addSubview:fullLabel];
    
    
    NSLog(@"%f,%f",self.imageWidth,self.imageHeight);
    [self.currentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imageBackView.mas_centerY);
        make.centerX.equalTo(imageBackView.mas_centerX);
        make.width.offset(self.imageWidth);
        make.height.offset(self.imageHeight);
    }];
    
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageBackView.mas_bottom).offset(23 * SCREENSCALE);
        make.left.equalTo(self.view.mas_left).offset(13 * SCREENSCALE);
        make.width.offset(62 * SCREENSCALE);
        make.height.offset(27 * SCREENSCALE);
    }];
    
    [huamianyundong mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.switchView.mas_right).offset(12 * SCREENSCALE);
        make.centerY.equalTo(self.switchView.mas_centerY);
        make.right.lessThanOrEqualTo(previewBtn.mas_left).offset(-10 * SCREENSCALE);
    }];
    
    [previewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.switchView.mas_centerY);
        make.right.equalTo(self.view.mas_right).offset(-13 * SCREENSCALE);
        make.width.mas_lessThanOrEqualTo(KScale6s(80));
        make.height.offset(27 * SCREENSCALE);
    }];

    [self.areaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageBackView.mas_bottom).offset(70 * SCREENSCALE);
        make.left.equalTo(self.view.mas_left).offset(103 * SCREENSCALE);
    }];

    [self.areaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.areaBtn);
        make.width.equalTo(self.areaBtn.mas_width);
        make.height.equalTo(self.areaBtn.mas_height);
    }];
    
    [areaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.areaBtn.mas_centerX);
        make.top.equalTo(self.areaBtn.mas_bottom).offset(7 * SCREENSCALE);
    }];

    [self.fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageBackView.mas_bottom).offset(70 * SCREENSCALE);
        make.right.equalTo(self.view.mas_right).offset(-103 * SCREENSCALE);
    }];
    
    [self.fullView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.fullBtn);
        make.width.equalTo(self.fullBtn.mas_width);
        make.height.equalTo(self.fullBtn.mas_height);
    }];

    [fullLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.fullBtn.mas_centerX);
        make.top.equalTo(self.fullBtn.mas_bottom).offset(7 * SCREENSCALE);
    }];
    
    [self.switchView switchSelected:self.movementState];
}

#pragma mark 预览视图
///Preview view
- (void)addPreviewView{
    self.previewView = [[UIView alloc]initWithFrame:self.view.frame];
    self.previewView.hidden = YES;
    self.previewView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 387 * SCREENSCALE)];
    backView.backgroundColor = self.view.backgroundColor;
    
    self.clipLivewindow = [[NvEditClipLiveWindow alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 387 * SCREENSCALE)];
    [self.view addSubview:self.clipLivewindow];
    [self.clipLivewindow connectTimeline:self.currentTimeline];
    self.clipLivewindow.editMode = self.editMode;
    [self.clipLivewindow seekTimeline:0];
    [self.clipLivewindow setPlayRangeIn:0 rangeOut:self.currentTimeline.duration];
    
    UIButton *finshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    finshBtn.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    [finshBtn addTarget:self action:@selector(finshBtn:) forControlEvents:UIControlEventTouchUpInside];
    [finshBtn setTitle:NvLocalString(@"End", @"结束") forState:UIControlStateNormal];
    finshBtn.titleLabel.font = [NvUtils fontWithSize:12];
    finshBtn.titleLabel.alpha = 0.8;
    finshBtn.layer.masksToBounds = YES;
    finshBtn.layer.cornerRadius = 27 * SCREENSCALE / 2.0;
    CGSize titleSize = [finshBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:finshBtn.titleLabel.font.fontName size:finshBtn.titleLabel.font.pointSize]}];
    titleSize.width += 30 * SCREENSCALE;
    
    [self.view addSubview:self.previewView];
    [self.previewView addSubview:backView];
    [self.previewView addSubview:self.clipLivewindow];
    [self.previewView addSubview:finshBtn];
    
    [finshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.clipLivewindow.mas_bottom).offset(128 * SCREENSCALE);
        make.centerX.equalTo(self.previewView.mas_centerX);
        
        make.width.offset(titleSize.width);
        make.height.offset(27 * SCREENSCALE);
    }];
    
}

#pragma mark 添加拖动框
///Add drag box
- (void)addDragView{
    ///初始化拖拽框
    ///Initializes the drag box
    if (_startDragView == nil){
        _startDragView = [EditPictureDragView new];
    }
    if (_endDragView == nil){
        _endDragView = [EditPictureDragView new];
    }
    if (_areaDragView == nil){
        _areaDragView = [EditPictureDragView new];
    }
    
    [self.currentImageView addSubview:_startDragView];
    [self.currentImageView addSubview:_endDragView];
    [self.currentImageView addSubview:_areaDragView];
    
    _startDragView.delegate = self;
    _startDragView.mode = startMode;
    _startDragView.imageSize = CGSizeMake(self.imageWidth, self.imageHeight);
    
    _endDragView.delegate = self;
    _endDragView.mode = endMode;
    _endDragView.imageSize = CGSizeMake(self.imageWidth, self.imageHeight);
    
    _areaDragView.delegate = self;
    _areaDragView.mode = areaMode;
    _areaDragView.imageSize = CGSizeMake(self.imageWidth, self.imageHeight);
    
    CGRect startRect = [self NormalizedToView:self.videoClip.startROI];
    CGRect endRect = [self NormalizedToView:self.videoClip.endROI];
    CGRect areaRect = [self NormalizedToView:self.videoClip.startROI];
    [self.startDragView setFrame:startRect];
    [self.endDragView setFrame:endRect];
    [self.areaDragView setFrame:areaRect];
    [self.startDragView setText:NvLocalString(@"Start screen", @"开始画面")];
    [self.endDragView setText:NvLocalString(@"End screen", @"结束画面")];
    
    ///为拖拽框设置横纵比
    ///Sets the aspect ratio for the drag box
    CGFloat scale = startRect.size.width / startRect.size.height;
    _startDragView.scale = scale;
    _endDragView.scale = scale;
    _areaDragView.scale = scale;
    
    [self.startDragView addDragBar];
    [self.endDragView addDragBar];
    [self.areaDragView addDragBar];
}

#pragma mark 归一化坐标转换为控件坐标
///Normalized coordinates are converted to view coordinates
- (CGRect) NormalizedToView:(NvsRect) rect {
    CGRect newRect;
    NSUInteger width = self.imageWidth;
    NSUInteger height = self.imageHeight;
    newRect.origin.x = (rect.left + 1)/2 * width;
    newRect.origin.y = (1 - rect.top)/2 * height;
    newRect.size.width = (rect.right - rect.left)/2 * width;
    newRect.size.height =  (rect.top - rect.bottom)/2 * height;
    return newRect;
}

#pragma mark 控件坐标转换为归一化坐标
///View coordinates are converted to normalized coordinates
- (NvsRect) ViewToNormalized:(CGRect) rect {
    NvsRect newRect;
    NSUInteger width = self.currentImageView.frame.size.width;
    NSUInteger height = self.currentImageView.frame.size.height;
    newRect.left = rect.origin.x / width * 2 - 1;
    newRect.right = newRect.left + rect.size.width / width * 2;
    newRect.top = 1 - rect.origin.y / height * 2;
    newRect.bottom = newRect.top - rect.size.height / height *2;
    if (newRect.left < -1)
        newRect.left = -1;
    if (newRect.right > 1)
        newRect.right = 1;
    if (newRect.bottom < -1)
        newRect.bottom = -1;
    if (newRect.top > 1)
        newRect.top = 1;
    return newRect;
}

#pragma mark 为图片展示控件计算合理宽度和高度
///Calculate the appropriate width and height for the picture display control
- (void)adapterWidthAndHeight{
    CGFloat width,height;
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = 387 * SCREENSCALE;
    CGFloat imageWidth = self.currentImage.size.width;
    CGFloat imageHeight = self.currentImage.size.height;
    NSUInteger widthScale = ceilf(imageWidth / viewWidth);
    NSUInteger heightScale = ceilf(imageHeight / viewHeight);
    if (widthScale == 1 && heightScale == 1) {
        width = imageWidth;
        height = imageHeight;
    } else {
        if (widthScale >= heightScale) {
            width = viewWidth;
            height = viewWidth / (imageWidth/imageHeight);
        } else {
            width = viewHeight * (imageWidth/imageHeight);
            height = viewHeight;
        }
    }
    self.imageWidth = width;
    self.imageHeight = height;
}


#pragma mark EditPictureDragViewDelegate
- (void)updateRect:(CGRect)rect withMode:(DragViewMode)mode{
    if (mode == startMode) {
        self.startDragView.frame = rect;
    }else if (mode == endMode){
        self.endDragView.frame = rect;
    }else{
        self.areaDragView.frame = rect;
    }
}

#pragma mark 调整时长滑动事件
///Adjust the duration of sliding events
- (void)sliderValueChanged:(UISlider *)slider{
    self.timeLabel.text = [NSString stringWithFormat:@"%ds",(int)slider.value];
    int64_t time = [self.timeLabel.text intValue] * NV_TIME_BASE;
    [self.videoClip changeTrimOutPoint:time affectSibling:true];
    
}

- (void)sliderValueEnd:(UISlider *)slider{
    [self.clipLivewindow seekTimeline:0];
    [self.clipLivewindow setPlayRangeIn:0 rangeOut:self.currentTimeline.duration];
    [self.clipLivewindow play];
}

#pragma mark 预览按钮点击事件
///Preview button click event
- (void)previewBtn:(UIButton *)sender{
    [self updateTimelineModel];
    [self.clipLivewindow seekTimeline:0];
    [self.clipLivewindow play];
    self.previewView.hidden = NO;
}

#pragma mark 根据数据修改timeline，达到预览效果
///Modify the timeline based on the data to achieve the preview effect
- (void)updateTimelineModel{
    if (!self.fullBtn.selected && self.areaBtn.selected) {
        self.videoClip.imageMotionMode = NvsStreamingEngineImageClipMotionMode_ROI;
        ///区域显示
        ///Area display
        if (self.movementState) {
            startRectImage = [self ViewToNormalized:self.startDragView.frame];
            endRectImage = [self ViewToNormalized:self.endDragView.frame];
            [self.videoClip setImageMotionROI:&startRectImage endROI:&endRectImage];
            self.videoClip.imageMotionAnimationEnabled = YES;
        }else{
            self.videoClip.imageMotionAnimationEnabled = NO;
            areaRectImage = [self ViewToNormalized:self.areaDragView.frame];
            [self.videoClip setImageMotionROI:&areaRectImage endROI:&areaRectImage];
        }
    }else if (self.fullBtn.selected && !self.areaBtn.selected){
        self.videoClip.imageMotionMode = NvsStreamingEngineImageClipMotionMode_LetterBoxZoomIn;
        ///全图显示
        ///Full picture display
        if (self.movementState) {
            self.videoClip.imageMotionAnimationEnabled = YES;
        }else{
            self.videoClip.imageMotionAnimationEnabled = NO;
        }
    }
}

#pragma mark 预览结束按钮点击事件
///Preview the end button click event
- (void)finshBtn:(UIButton *)sender{
    self.previewView.hidden = YES;
    [self.clipLivewindow seekTimeline:0];
}

#pragma mark 区域显示按钮点击事件
///Area displays button click events
- (void)areaBtn:(UIButton *)sender{
    self.areaView.hidden = NO;
    self.fullView.hidden = YES;
    self.fullBtn.selected = NO;
    if (sender.selected) {
        sender.selected = NO;
    }else{
        sender.selected = YES;
    }
    [self configDragView];
}

#pragma mark 全图显示按钮点击事件
///全图显示按钮点击事件
///Full picture shows button click event
- (void)fullBtn:(UIButton *)sender{
    self.areaView.hidden = YES;
    self.fullView.hidden = NO;
    self.areaBtn.selected = NO;
    if (sender.selected) {
        sender.selected = NO;
    }else{
        sender.selected = YES;
    }
    [self configDragView];
}

#pragma mark 画面运动按钮点击事件
///Picture motion button click event
- (void)switchAction:(NvSwitchView *)sender{
    if (sender.selected) {
        sender.selected = NO;
        ///关闭运动
        ///Closing motion
        self.movementState = NO;
        [sender switchSelected:NO];
        [self configDragView];
        
    }else {
        sender.selected = YES;
        ///开启运动
        ///Open motion
        self.movementState = YES;
        [sender switchSelected:YES];
        [self configDragView];
    }
}

#pragma mark 根据选中效果显示不同的拖动框
///Different drag boxes are displayed according to the selected effect
- (void)configDragView{
    if (!self.fullBtn.selected && self.areaBtn.selected) {
        ///区域显示
        ///Area display
        self.currentImageView.layer.borderWidth = 0;
        if (self.movementState) {
            self.areaDragView.hidden = YES;
            self.startDragView.hidden = NO;
            self.endDragView.hidden = NO;
        }else{
            self.areaDragView.hidden = NO;
            self.startDragView.hidden = YES;
            self.endDragView.hidden = YES;
        }
    }else if (self.fullBtn.selected && !self.areaBtn.selected){
        ///全图显示
        ///Full picture display
        self.areaDragView.hidden = YES;
        self.startDragView.hidden = YES;
        self.endDragView.hidden = YES;
        self.currentImageView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#D0021B"].CGColor;
        self.currentImageView.layer.borderWidth = 3;
    }
}

#pragma mark 完成按钮点击
///Finish button click
- (void)finshClick:(UIButton *)sender{
    if ([self.title isEqualToString:NvLocalString(@"Duration", @"时长")]) {
        self.model.trimOut = self.currentTimeline.duration;
        NvTimeFilterInfoModel *filterInfo = [[[NvTimelineData sharedInstance] videoFxDataArray] firstObject];
        filterInfo.outPoint = filterInfo.outPoint + self.model.trimOut;
    }else{
        [self updateTimelineModel];
        self.model.isDefault = YES;
        self.model.hasMotion = self.movementState;
        self.model.isArea = self.areaBtn.selected;
        self.model.motionMode = self.videoClip.imageMotionMode;
        if (self.model.isArea) {
            if (self.movementState) {
                self.model.startRect = startRectImage;
                self.model.endRect = endRectImage;
            }else{
                self.model.startRect = areaRectImage;
                self.model.endRect = areaRectImage;
            }
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
