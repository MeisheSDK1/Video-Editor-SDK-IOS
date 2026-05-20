//
//  NvFilePassThroughViewController.m
//  QuickSplicing
//
//  Created by 美摄 on 2022/4/8.
//

#import "NvFilePassThroughViewController.h"
#import "NvsPassthroughConvertorViewController.h"
#import "NvsPSTimelineEditor.h"
#import <Masonry/Masonry.h>
#import "NvStreamingSdkCore.h"
#import "NvUtils.h"
#import "NvSDKUtils.h"
@interface NvFilePassThroughViewController ()<NvsPSTimelineEditorDelegate,NvsPassthroughConvertorViewControllerDelegate>
///所有模块统一控件
///All modules unified control
///标题控件
///Title control
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) NvsPSTimelineEditor *timeLineEdit;
@property (nonatomic, weak)   NvsPSTimelineTimeSpan *timeSpan;
///分割的时间线
///The split timeline
@property (nonatomic, assign) int64_t splitTime;
///视频裁剪的trimIn
///Video clipping trimIn
@property (nonatomic, assign) int64_t trimIn;
///视频裁剪的trimOut
///Video clipping trimOut
@property (nonatomic, assign) int64_t trimOut;
@property (nonatomic, assign) int64_t assetDuration;
@property (nonatomic, strong) UIButton *compileButton;
@end

@implementation NvFilePassThroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.assetDuration = [self getAssetDuration:self.info.mediaFilePath];
    self.trimIn = self.info.trimIn;
    self.trimOut = self.info.trimOut;
    self.title = NvLocalStringFromTable([self class], @"File Passthrough", @"文件直通");
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.backButton.hidden = YES;
    [self.liveWindowPanel hiddenVolumeButton];
    [self initTimeline];
    [self initSubviews];
}

- (void)initSubviews {
    self.textLabel = [UILabel new];
    self.textLabel.textColor = UIColor.whiteColor;
    self.textLabel.alpha = 0.8;
    self.textLabel.font = [UIFont systemFontOfSize:10 * SCREENSCALE];
    self.textLabel.numberOfLines = 2;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.textLabel.text = [NSString stringWithFormat:NvLocalString(@"croppingTime", @"裁剪后总时长为%@"),[NvUtils convertTimecodePrecisional:self.info.trimOut - self.info.trimIn]];
    [self.view addSubview:_textLabel];
    [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.liveWindowPanel.mas_bottom).offset(10 * SCREENSCALE);
        make.centerX.equalTo(self.liveWindowPanel.mas_centerX);
        make.width.mas_lessThanOrEqualTo(KScale6s(345));
    }];
    
    self.timeLineEdit = [[NvsPSTimelineEditor alloc] initWithFrame:CGRectMake(13 * SCREENSCALE,426 * SCREENSCALE, 350 * SCREENSCALE,90 * SCREENSCALE)];
    self.timeLineEdit.caneditTimeSpan = YES;
    self.timeLineEdit.canOverlapTimeSpan = YES;
    self.timeLineEdit.timelinePosition = self.assetDuration;
    [self.view addSubview:self.timeLineEdit];

    [self.timeLineEdit initTimelineEditor:@[self.info] timelineDuration:self.assetDuration];
    self.timeLineEdit.delegate = self;
    self.timeLineEdit.type = 0;
    ///添加两边滑块
    ///Add sliders on both sides
    self.timeSpan = [self.timeLineEdit addTimeSpan:0 outPoint:self.assetDuration];
    self.timeSpan.inPoint = self.info.trimIn;
    self.timeSpan.outPoint = self.info.trimOut == 0 ? self.assetDuration : self.info.trimOut;
    
    [self.timeLineEdit updateTrimIn:self.info.trimIn trimOut:self.info.trimOut];
    
    [self.timeSpan setSelected:YES];
    self.timeSpan.editable = YES;
    
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton setBackgroundImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(finishButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishButton];
    [finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(20*SCREENSCALE));
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
        } else {
            make.bottom.equalTo(@(-15*SCREENSCALE));
        }
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(finishButton.mas_top).offset(-12*SCREENSCALE);
    }];
}

- (UIView *)rightNavigationBarItemView {
    
    self.compileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.compileButton setTitle:NvLocalString(@"Compile", @"生成") forState:UIControlStateNormal];
    [self.compileButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
    if (font) {
        self.compileButton.titleLabel.font = font;
    } else {
        UIFont *font = [UIFont systemFontOfSize:16];
        self.compileButton.titleLabel.font = font;
    }
    self.compileButton.frame = CGRectMake(0, 0, 30, 44);
    self.compileButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15*SCREENSCALE);
    [self.compileButton addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.compileButton.exclusiveTouch = YES;
    return self.compileButton;
}

- (void)initTimeline {
    self.timeline = [NvSDKUtils createTimeline:self.editMode];
    [[self.timeline getVideoTrackByIndex:0] appendClip:self.info.mediaFilePath];
}

- (int64_t)getAssetDuration:(NSString *)assetPath {
    NvsAVFileInfo *avInfo = [self.streamingContext getAVFileInfo:assetPath];
    return avInfo.duration;
}

- (void)finishButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(filePassThroughViewController:info:)]) {
        self.info.trimIn = self.trimIn;
        self.info.trimOut = self.trimOut;
        [self.delegate filePassThroughViewController:self info:self.info];
    }
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - 生成
/*
 生成
 composite
 */
- (void)rightBtnClicked{
    NSString *convertFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvsPassthroughConvertorViewController *convertorViewController = [NvsPassthroughConvertorViewController new];
    convertorViewController.delegate = self;
    convertorViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:convertorViewController animated:NO completion:nil];
    [convertorViewController convertMediaFile:self.info.mediaFilePath outputFile:convertFilePath trimIn:_trimIn trimOut:_trimOut options:nil];
}

#pragma mark - NvsPSTimelineEditorDelegate
- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint {
    if (isInPoint) {
        self.trimIn = timestamp;
        [self seekTimeline:self.trimIn];
    }else{
        self.trimOut = timestamp;
        [self seekTimeline:self.trimOut];
    }
    
    if (self.trimOut == 0.0) {
        self.trimOut = self.assetDuration;
    }
    self.textLabel.text = [NSString stringWithFormat:NvLocalString(@"croppingTime", @"裁剪后总时长为%@"),[NvUtils convertTimecodePrecisional:self.trimOut - self.trimIn]];
}

- (void)timelineEditor:(id)timelineEditor handlePan:(int64_t)timestamp {
    self.textLabel.text = [NSString stringWithFormat:@"%@/%@",[NvUtils convertTimecodePrecisional:timestamp],[NvUtils convertTimecodePrecisional:(self.assetDuration-timestamp)]];
    
    self.splitTime = timestamp;
    [self seekTimeline:timestamp];
}

#pragma mark - NvsPassthroughConvertorViewControllerDelegate
- (void)didConvertorFinish:(int64_t)taskId sourceFile:(NSString *)src outputFile:(NSString *)dst trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut errorCode:(int)error {
    if (error == 0) {
        UISaveVideoAtPathToSavedPhotosAlbum(dst, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"保存成功！ Save successfully!");
}
@end
