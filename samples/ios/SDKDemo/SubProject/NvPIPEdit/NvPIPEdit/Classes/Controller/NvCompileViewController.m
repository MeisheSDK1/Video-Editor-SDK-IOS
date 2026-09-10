//
//  NvCompileViewController.m
//  SDKDemo
//
//  Created by meishe01 on 2018/6/5.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCompileViewController.h"
#import "NVHeader.h"
#import "NvSDKUtils.h"
#import "NvsTimelineAnimatedSticker.h"

@interface NvCompileViewController () <NvsStreamingContextDelegate>

@property (nonatomic, strong) UIView *compileView;
@property (nonatomic, strong) UIView *compileProgress;
@property (nonatomic, strong) CALayer *progressLayer;
@property (nonatomic, strong) UILabel *progressValue;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) NvsTimelineAnimatedSticker *sticker;
@property (nonatomic, strong) NvsTimeline *currentTimeline;
@property (nonatomic, weak) id contextDelegate;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@end

@implementation NvCompileViewController

- (void)dealloc {
    self.streamingContext.delegate = self.contextDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addSubviews];
    self.streamingContext = [NvSDKUtils getSDKContext];
    self.contextDelegate = self.streamingContext.delegate;
    self.streamingContext.delegate = self;
}

- (void)addSubviews {
    self.view.backgroundColor = [UIColor clearColor];
    self.compileView = [[UIView alloc] initWithFrame:self.view.frame];
    self.compileView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
    [self.view addSubview:self.compileView];
    self.compileProgress = [UIView new];
    self.compileProgress.hidden = YES;
    self.compileProgress.backgroundColor = [UIColor nv_colorWithHexARGB:@"#FFD8D8D8"];
    [self.compileView addSubview:self.compileProgress];
    [self.compileProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(274 * SCREENSCALE));
        make.width.equalTo(@(177 * SCREENSCALE));
        make.height.equalTo(@(30 * SCREENSCALE));
        make.centerX.equalTo(self.view);
    }];
    self.progressValue = [UILabel new];
    self.progressValue.hidden = YES;
    self.progressValue.text = @"0%";
    self.progressValue.font = [NvUtils fontWithSize:18];
    self.progressValue.textColor = [UIColor nv_colorWithHexARGB:@"#FF4A90E2"];
    [self.compileView addSubview:self.progressValue];
    [self.progressValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.compileProgress.mas_bottom).offset(15 * SCREENSCALE);
        make.centerX.equalTo(self.view);
    }];
    self.cancelBtn = [UIButton new];
    self.cancelBtn.hidden = YES;
    [self.cancelBtn setImage:[NvUtils imageWithName:@"NvCancelCompile"] forState:UIControlStateNormal];
    [self.compileView addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressValue.mas_bottom).offset(30 * SCREENSCALE);
        make.width.height.equalTo(@(35 * SCREENSCALE));
        make.centerX.equalTo(self.view);
    }];
    [self.view layoutIfNeeded];
    self.progressLayer = [CALayer layer];
    self.progressLayer.backgroundColor = [UIColor nv_colorWithHexARGB:@"#FF4A90E2"].CGColor;
    self.progressLayer.frame = CGRectMake(0, 0, 0, self.compileProgress.height);
    [self.compileProgress.layer addSublayer:self.progressLayer];
    
    [self.cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)compileTimeline:(NvsTimeline *)timeline outputPath:(NSString *)ouputPath {
    self.currentTimeline = timeline;
//    NSString *imagePath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingString:@"/NvHomeBgLogo@2x.png"];
//    self.sticker = [timeline addCustomAnimatedSticker:0 duration:timeline.duration animatedStickerPackageId:@"E14FEE65-71A0-4717-9D66-3397B6C11223" customImagePath:imagePath];
//    [self.sticker setScale:0.3f];//必须先缩放，再平移，否则位置会有错误
//
//    NSArray *stickerArray = [self.sticker getBoundingRectangleVertices];
//    NSValue *leftTopValue = stickerArray[0];
//    NSValue *rightBottomValue = stickerArray[2];
//
//    CGPoint topLeftCorner = [leftTopValue CGPointValue];
//    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
//
//    CGFloat stickerWidth = fabsf(rightBottomCorner.x)+ fabsf(topLeftCorner.x);
//    CGFloat stickerHeight = fabsf(rightBottomCorner.y)+ fabsf(topLeftCorner.y);
//
//    [self.sticker setTranslation:CGPointMake(- (timeline.videoRes.imageWidth/2.0 - stickerWidth/2.0 - 10), timeline.videoRes.imageHeight/2.0 - stickerHeight/2.0 - 10)];
    
    [NvSDKUtils getSDKContext].compileConfigurations = [[NSMutableDictionary alloc] init];
    int64_t bitrateSetting = [NvUtils compileBitrateSetting];
    if (bitrateSetting > 0)
        [[NvSDKUtils getSDKContext].compileConfigurations setValue:[NSNumber numberWithInteger:bitrateSetting] forKey:NVS_COMPILE_BITRATE];
    
//    [self.streamingContext.compileConfigurations setValue:@"hevc" forKey:NVS_COMPILE_VIDEO_ENCODEC_NAME];
    [[NvSDKUtils getSDKContext] setCustomCompileVideoHeight:timeline.videoRes.imageHeight];
    if (![[NvSDKUtils getSDKContext] compileTimeline:timeline startTime:0 endTime:timeline.duration outputFilePath:ouputPath videoResolutionGrade:NvsCompileVideoResolutionGradeCustom videoBitrateGrade:NvsCompileBitrateGradeHigh flags:NvsStreamingEngineCompileFlag_IgnoreTimelineVideoSize]) {
        NSLog(@"生成时间线失败！");
    }else{
        [NvToast showCompileWithMessage:NvLocalString(@"Generated", @"生成中")];
    }
    
    
}

- (void)cancelBtnClicked {
    [self.streamingContext stop];
}

- (void)finishCompiling:(BOOL)needDelete {
    if ([self.delegate respondsToSelector:@selector(compileFinished:)]) {
        if (self.sticker) {
            [self.currentTimeline removeAnimatedSticker:_sticker];
            _sticker = nil;
        }
        [self.delegate compileFinished:needDelete];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    });
}

- (void)didCompileProgress:(NvsTimeline *)timeline progress:(int)progress {
//    self.progressLayer.frame = CGRectMake(0, 0, (float)progress / 100 * self.compileProgress.width, self.compileProgress.height);
//    self.progressValue.text = [NSString stringWithFormat:@"%d%%", progress];
}

- (void)didCompileCompleted:(NvsTimeline *)timeline isCanceled:(BOOL)isCanceled {
    [NvToast dismiss];
    if (isCanceled){
        NSLog(@"生成被取消,生成失败");
        UILabel *tipLabel = [[UILabel alloc]init];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.text = NvLocalString(@"compile fiald", @"生成失败");
        tipLabel.textColor = UIColor.whiteColor;
        tipLabel.numberOfLines = 0;
        tipLabel.alpha = 0.8;
        [self.compileView addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.compileView.mas_centerX);
            make.centerY.equalTo(self.compileView.mas_centerY);
        }];
    }else{
        UILabel *tipLabel = [[UILabel alloc]init];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.text = NvLocalString(@"Generated complete", @"已完成");
        tipLabel.textColor = UIColor.whiteColor;
        tipLabel.numberOfLines = 0;
        tipLabel.alpha = 0.8;
        [self.compileView addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.compileView.mas_centerX);
            make.centerY.equalTo(self.compileView.mas_centerY);
        }];
    }
    [self finishCompiling:isCanceled];
}

- (void)didCompileFailed:(NvsTimeline *)timeline {
    [NvToast dismiss];
    self.compileView.hidden = YES;
    __weak typeof(self)weakSelf = self;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NvLocalString(@"compile fiald", @"生成失败") message:NvLocalString(@"storage", @"请检查手机存储空间") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *skipAction = [UIAlertAction actionWithTitle:NvLocalString(@"Know", @"知道了") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf finishCompiling:YES];
    }];
    [alertVC addAction:skipAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
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
