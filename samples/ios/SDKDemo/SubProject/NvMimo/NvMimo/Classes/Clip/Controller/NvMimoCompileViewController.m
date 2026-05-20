//
//  NvCompileViewController.m
//  SDKDemo
//
//  Created by meishe01 on 2018/6/5.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMimoCompileViewController.h"
#import "NVHeader.h"
#import "NvMimoTipsView.h"
#import "NvMimoSDKUtils.h"
#import "NvsTimelineAnimatedSticker.h"
#import <UIColor+NvColor.h>
#import "NvMimoToast.h"
#import "NvMimoUtils.h"
#import <NvBaseCommon/NVDefineConfig.h>

@interface NvMimoCompileViewController () <NvsStreamingContextDelegate>

@property (nonatomic, strong) UIView *compileView;
@property (nonatomic, strong) UIView *compileProgress;
@property (nonatomic, strong) CALayer *progressLayer;
@property (nonatomic, strong) UILabel *progressValue;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) NvsTimelineAnimatedSticker *sticker;
@property (nonatomic, strong) NvsTimeline *currentTimeline;
@property (nonatomic, weak) id contextDelegate;
@end

@implementation NvMimoCompileViewController

- (void)dealloc {
    [NvMimoSDKUtils getSDKContext].delegate = self.contextDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addSubviews];
    self.contextDelegate = [NvMimoSDKUtils getSDKContext].delegate;
    [NvMimoSDKUtils getSDKContext].delegate = self;
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
        make.top.equalTo(@(274 * SCREANSCALE));
        make.width.equalTo(@(177 * SCREANSCALE));
        make.height.equalTo(@(30 * SCREANSCALE));
        make.centerX.equalTo(self.view);
    }];
    self.progressValue = [UILabel new];
    self.progressValue.hidden = YES;
    self.progressValue.text = @"0%";
    self.progressValue.font = [NvMimoUtils fontWithSize:18];
    self.progressValue.textColor = [UIColor nv_colorWithHexARGB:@"#FF4A90E2"];
    [self.compileView addSubview:self.progressValue];
    [self.progressValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.compileProgress.mas_bottom).offset(15 * SCREANSCALE);
        make.centerX.equalTo(self.view);
    }];
    self.cancelBtn = [UIButton new];
    self.cancelBtn.hidden = YES;
    [self.cancelBtn setImage:[NvMimoUtils imageWithName:@"NvCancelCompile"] forState:UIControlStateNormal];
    [self.compileView addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressValue.mas_bottom).offset(30 * SCREANSCALE);
        make.width.height.equalTo(@(35 * SCREANSCALE));
        make.centerX.equalTo(self.view);
    }];
    [self.view layoutIfNeeded];
    self.progressLayer = [CALayer layer];
    self.progressLayer.backgroundColor = [UIColor nv_colorWithHexARGB:@"#FF4A90E2"].CGColor;
    self.progressLayer.frame = CGRectMake(0, 0, 0, self.compileProgress.frame.size.height);
    [self.compileProgress.layer addSublayer:self.progressLayer];
    
    [self.cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)compileTimeline:(NvsTimeline *)timeline outputPath:(NSString *)ouputPath {
    self.currentTimeline = timeline;
    [NvMimoSDKUtils getSDKContext].compileConfigurations = [[NSMutableDictionary alloc] init];
    int64_t bitrateSetting = [NvMimoUtils compileBitrateSetting];
    if (bitrateSetting > 0)
        [[NvMimoSDKUtils getSDKContext].compileConfigurations setValue:[NSNumber numberWithInteger:bitrateSetting] forKey:NVS_COMPILE_BITRATE];
    
    [[NvMimoSDKUtils getSDKContext] setCustomCompileVideoHeight:timeline.videoRes.imageHeight];
    if (![[NvMimoSDKUtils getSDKContext] compileTimeline:timeline startTime:0 endTime:timeline.duration outputFilePath:ouputPath videoResolutionGrade:NvsCompileVideoResolutionGradeCustom videoBitrateGrade:NvsCompileBitrateGradeHigh flags: NvsStreamingEngineCompileFlag_IgnoreTimelineVideoSize]) {
        DLog(@"生成时间线失败！");
    }else{
        [NvMimoToast showCompileWithMessage:NvLocalStringFromTable([self class], @"Generated", @"生成中")];
    }
}

- (void)cancelBtnClicked {
    [[NvMimoSDKUtils getSDKContext] stop];
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

}

- (void)didCompileCompleted:(NvsTimeline *)timeline isCanceled:(BOOL)isCanceled {
    [NvMimoToast dismiss];
    if (isCanceled){
        DLog(@"生成被取消,生成失败");
        UILabel *tipLabel = [[UILabel alloc]init];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.text = NvLocalStringFromTable([self class], @"compile fiald", @"生成失败");
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
        tipLabel.text = NvLocalStringFromTable([self class], @"Generated complete", @"已完成");
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
    [NvMimoToast dismiss];
    self.compileView.hidden = YES;
    NvMimoTipsView *tips = [[NvMimoTipsView alloc] initWithFrame:self.view.frame withPrompt:NvLocalStringFromTable([self class], @"compile fiald", @"生成失败") describeTitle:NvLocalStringFromTable([self class], @"storage", @"请检查手机存储空间") describeContent:nil buttonText:NvLocalStringFromTable([self class], @"Know", @"知道了") withCenter:NO];
    [self.view addSubview:tips];
    [tips.clickBtn addTarget:self action:@selector(clickBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)clickBtnClicked {
    [self finishCompiling:YES];
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
