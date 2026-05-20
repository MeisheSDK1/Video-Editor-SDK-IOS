//
//  NvCompileViewController.m
//  SDKDemo
//
//  Created by meishe01 on 2018/6/5.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCompileViewController.h"
#import "NvSDKUtils.h"
#import "NvsTimeline.h"
#import "NvsTimelineAnimatedSticker.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvBaseCommon/UIColor+NvColor.h>
#import <NvBaseCommon/UIView+Dimension.h>
#import <NvBaseCommon/NvToast.h>
#import "NvUtils.h"
#import <NvSDKCommon/NvHDRManager.h>

static CGFloat const BgCircleWidth = 90;
#define OpenWebmTest 0
@interface NvCompileViewController () <NvsStreamingContextDelegate>

@property (nonatomic, strong) UIView *compileView;
@property (nonatomic, strong) UIView *compileProgress;

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *tranLayer;
@property (nonatomic, strong) UILabel *percentageLabel;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) NvsTimelineAnimatedSticker *sticker;
@property (nonatomic, strong) NvsTimeline *currentTimeline;
@property (nonatomic, weak) id contextDelegate;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, copy) NSString *ouputPath;
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

- (UIBezierPath *)_path
{
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.compileProgress.width / 2.0, self.compileProgress.width / 2.0) radius:BgCircleWidth / 2.0 startAngle:-M_PI_2 endAngle:1.5*M_PI clockwise:YES];
    return path;
}


- (void)addSubviews {
    self.view.backgroundColor = [UIColor clearColor];
    
    self.compileView = [[UIView alloc] initWithFrame:self.view.frame];
    self.compileView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
    [self.view addSubview:self.compileView];
    self.compileProgress = [UIView new];
    self.compileProgress.backgroundColor = [UIColor clearColor];
    [self.compileView addSubview:self.compileProgress];
    self.compileProgress.frame = CGRectMake(0, 0, BgCircleWidth, BgCircleWidth);
    self.compileProgress.centerX = self.compileView.centerX;
    self.compileProgress.centerY = self.compileView.centerY;
    
    [self.compileProgress.layer addSublayer:self.circleLayer];
    [self.compileProgress.layer addSublayer:self.tranLayer];
    [self.compileProgress addSubview:self.percentageLabel];
    [self.percentageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.compileProgress);
        make.width.mas_equalTo(80.0f);
        make.height.mas_equalTo(30.0f);
    }];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.compileView addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.compileProgress.mas_bottom).offset(30*SCREENSCALE);
        make.height.mas_equalTo(20*SCREENSCALE);
        make.left.right.equalTo(self.compileProgress);
    }];
    [self.cancelButton setTitle:NvLocalString(@"Cancel", @"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:11*SCREENSCALE];
    self.cancelButton.backgroundColor = [UIColor nv_colorWithHexRGB:@"#2C2C2C"];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)cancelButtonClicked:(UIButton *)sender {
    [[NvSDKUtils getSDKContext] stop];
}

-(UILabel *)percentageLabel{
    if (!_percentageLabel) {
        _percentageLabel = [UILabel new];
        _percentageLabel.font = [UIFont systemFontOfSize:12.0f];
        _percentageLabel.textAlignment = NSTextAlignmentCenter;
        _percentageLabel.textColor =  [UIColor whiteColor];
    }
    return _percentageLabel;
}

-(CAShapeLayer *)circleLayer{
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.bounds = self.compileProgress.bounds;
        _circleLayer.position = CGPointMake(self.compileProgress.width / 2.0, self.compileProgress.width / 2.0);
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.strokeColor = [UIColor nv_colorWithHexString:@"484848"].CGColor;
        _circleLayer.path = [self _path].CGPath;
        _circleLayer.lineWidth = 5;
        _circleLayer.lineCap = kCALineCapRound;
        _circleLayer.strokeStart = 0;
        _circleLayer.strokeEnd = 1;
    }
    return _circleLayer;
}

-(CAShapeLayer *)tranLayer{
    if (!_tranLayer) {
        _tranLayer = [CAShapeLayer layer];
        _tranLayer.bounds = self.compileProgress.bounds;
        _tranLayer.position = CGPointMake(self.compileProgress.width / 2.0, self.compileProgress.width / 2.0);
        _tranLayer.fillColor = [UIColor clearColor].CGColor;
        _tranLayer.strokeColor = [UIColor nv_colorWithHexString:@"#63abff"].CGColor;
        _tranLayer.path = [self _path].CGPath;
        _tranLayer.lineWidth = 5;
        _tranLayer.lineCap = kCALineCapRound;
        _tranLayer.strokeStart = 0;
        _tranLayer.strokeEnd = 0;
    }
    return _tranLayer;
}
CFAbsoluteTime begin = 0;
- (void)compileTimeline:(NvsTimeline *)timeline outputPath:(NSString *)ouputPath {
    [self compileTimeline:timeline startTime:0 endTime:timeline.duration outputPath:ouputPath];
}

- (void)compileTimeline:(NvsTimeline *)timeline startTime:(int64_t)startTime endTime:(int64_t)endTime outputPath:(NSString *)ouputPath {
    begin = CFAbsoluteTimeGetCurrent();
    self.currentTimeline = timeline;
    self.ouputPath = ouputPath;
    [NvSDKUtils getSDKContext].compileConfigurations = [[NSMutableDictionary alloc] init];
    int64_t bitrateSetting = [NvUtils compileBitrateSetting];
    
    if (bitrateSetting > 0)
        [[NvSDKUtils getSDKContext].compileConfigurations setValue:[NSNumber numberWithInteger:bitrateSetting] forKey:NVS_COMPILE_BITRATE];
    
    if ([NvHDRManager isSupportExporter] && [NvSDKUtils hevcModelSetting].length > 0 && self.isHDRSetUp) {
        [[NvsStreamingContext sharedInstance].compileConfigurations setValue:[NvSDKUtils hevcModelSetting] forKey:NVS_COMPILE_VIDEO_ENCODEC_NAME];
        [[NvsStreamingContext sharedInstance].compileConfigurations setValue:[NvSDKUtils exportModelSetting] forKey:NVS_COMPILE_HDR_VIDEO_COLOR_TRANSFER];
    }
    
    if (OpenWebmTest) {
        [[NvsStreamingContext sharedInstance].compileConfigurations setObject:@"vp8" forKey:NVS_COMPILE_VIDEO_ENCODEC_NAME];
        [[NvsStreamingContext sharedInstance].compileConfigurations setObject:@"vorbis" forKey:NVS_COMPILE_AUDIO_ENCODEC_NAME];
        ouputPath = [ouputPath stringByDeletingPathExtension];
        ouputPath = [ouputPath stringByAppendingPathExtension:@"webm"];
    }
    
    NvsSize compileSize = [NvUtils calculateCompileSizeWithTimelineVideoSize:CGSizeMake(timeline.videoRes.imageWidth, timeline.videoRes.imageHeight) compileResolution:[NvUtils compileResolutionSetting]];
    [[NvSDKUtils getSDKContext] setCustomCompileVideoHeight:compileSize.height];
    if (![[NvSDKUtils getSDKContext] compileTimeline:timeline startTime:startTime endTime:endTime outputFilePath:ouputPath videoResolutionGrade:NvsCompileVideoResolutionGradeCustom videoBitrateGrade:NvsCompileBitrateGradeHigh flags:NvsStreamingEngineCompileFlag_IgnoreTimelineVideoSize | NvsStreamingEngineCompileFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineCompileFlag_BuddyHostVideoFrame|NvsStreamingEngineCompileFlag_TruncateAudioStream]) {
        NSLog(@"生成时间线失败！Failed to generate timeline!");
    }
}

- (void)compilePassthroughTimeline:(NvsTimeline *)timeline outputPath:(NSString *)ouputPath {
    self.currentTimeline = timeline;
    self.ouputPath = ouputPath;

    if (![[NvSDKUtils getSDKContext] compilePassthroughTimeline:timeline outputFilePath:ouputPath compileConfigurations:nil flags:0]) {
        [NvToast dismiss];
        [self removeSubviews];
        self.compileView.hidden = YES;
        __weak typeof(self)weakSelf = self;
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NvLocalStringFromTable([self class], @"compile fiald", @"生成失败") message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *skipAction = [UIAlertAction actionWithTitle:NvLocalStringFromTable([self class], @"Know", @"知道了") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf finishCompiling:YES];
        }];
        [alertVC addAction:skipAction];
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)finishCompiling:(BOOL)needDelete {
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"%f",end - begin);
    if ([self.delegate respondsToSelector:@selector(compileFinished:)]) {
        if (self.sticker) {
            [self.currentTimeline removeAnimatedSticker:_sticker];
            _sticker = nil;
        }
        [self.delegate compileFinished:needDelete];
    }
}

- (void)didCompileProgress:(NvsTimeline *)timeline progress:(int)progress {
    
    self.tranLayer.strokeEnd = progress / 100.0;
    self.percentageLabel.text = [NSString stringWithFormat:@"%d%%", progress];
}

- (void)didCompileCompleted:(NvsTimeline *)timeline isHardwareEncoding:(BOOL)isHardwareEncoding errorType:(int)errorType errorString:(NSString*)errorString flags:(int)flags{
    [NvToast dismiss];
    if (errorType == NvsStreamingEngineCompileErrorType_No_Error) {
        [self removeSubviews];
         
        UILabel *tipLabel = [[UILabel alloc]init];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.text = NvLocalStringFromTable([self class], @"Generated complete", @"已完成");
        tipLabel.textColor = UIColor.whiteColor;
        tipLabel.numberOfLines = 0;
        tipLabel.alpha = 0.8;
        [self.compileView addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.compileView.mas_centerX);
            make.centerY.equalTo(self.compileView.mas_centerY);
        }];
        [self finishCompiling:NO];

    }else{
        
        self.compileView.hidden = YES;
        __weak typeof(self)weakSelf = self;
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NvLocalStringFromTable([self class], @"compile fiald", @"生成失败") message:NvLocalStringFromTable([self class], @"storage", @"请检查手机存储空间") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *skipAction = [UIAlertAction actionWithTitle:NvLocalStringFromTable([self class], @"Know", @"知道了") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf finishCompiling:YES];
        }];
        [alertVC addAction:skipAction];
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)removeSubviews {
    [self.compileProgress removeFromSuperview];
    self.compileProgress = nil;
    
    [self.cancelButton removeFromSuperview];
    self.cancelButton = nil;
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
