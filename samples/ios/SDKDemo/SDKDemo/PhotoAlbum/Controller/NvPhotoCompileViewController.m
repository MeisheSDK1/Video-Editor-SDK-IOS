//
//  NvPhotoCompileViewController.m
//  SDKDemo
//
//  Created by MS on 2019/10/8.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvPhotoCompileViewController.h"
#import "NVHeader.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvsTimelineAnimatedSticker.h"
#import "NvPhotoAlbumProgressView.h"

@interface NvPhotoCompileViewController ()<NvsStreamingContextDelegate>
@property (nonatomic, strong) UIView *compileView;
@property (nonatomic, strong) UIView *compileProgress;
@property (nonatomic, strong) UILabel *progressValue;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) NvPhotoAlbumProgressView *progressView;
@property (nonatomic, strong) NvsTimelineAnimatedSticker *sticker;
@property (nonatomic, strong) NvsTimeline *currentTimeline;
@property (nonatomic, weak) id contextDelegate;
@end

@implementation NvPhotoCompileViewController

- (void)dealloc {
    [NvsStreamingContext sharedInstance].delegate = self.contextDelegate;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addSubviews];
    self.contextDelegate = [NvsStreamingContext sharedInstance].delegate;
    [NvsStreamingContext sharedInstance].delegate = self;
}

- (void)addSubviews {
    self.view.backgroundColor = [UIColor clearColor];
    self.compileView = [[UIView alloc] initWithFrame:self.view.frame];
    self.compileView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
    [self.view addSubview:self.compileView];
    self.compileProgress = [UIView new];

    self.compileProgress.backgroundColor = [UIColor whiteColor];
    [self.compileView addSubview:self.compileProgress];
    self.compileProgress.layer.cornerRadius = 15*SCREENSCALE;
    [self.compileProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(274 * SCREENSCALE));
        make.width.equalTo(@(200 * SCREENSCALE));
        make.height.equalTo(@(150 * SCREENSCALE));
        make.centerX.mas_equalTo(self.compileView.mas_centerX);
    }];
    
    self.progressView = [[NvPhotoAlbumProgressView alloc] init];
    [self.compileProgress addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.compileProgress.mas_centerX);
        make.top.equalTo(self.compileProgress.mas_top).offset(21*SCREENSCALE);
        make.width.mas_equalTo(45*SCREENSCALE);
        make.height.mas_equalTo(45*SCREENSCALE);
    }];

    
    ///提示信息label
    ///Prompt label
    self.progressValue = [UILabel new];
    self.progressValue.text = NvLocalString(@"Generated", nil);
    self.progressValue.font = [NvUtils mediumFontWithSize:18];
    
    self.progressValue.textColor = [UIColor nv_colorWithHexARGB:@"#FF333333"];
    [self.compileProgress addSubview:self.progressValue];
    [self.progressValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView.mas_bottom).offset(8 * SCREENSCALE);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(22*SCREENSCALE);
    }];
    
    self.cancelBtn = [UIButton new];
    [self.cancelBtn setTitle:NvLocalString(@"Cancel", @"取消") forState:UIControlStateNormal];
    self.cancelBtn.backgroundColor = [UIColor nv_colorWithHexRGB:@"#E4E4E4"];
    [self.cancelBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#666666"] forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = [NvUtils mediumFontWithSize:15];
    self.cancelBtn.layer.cornerRadius = 25/2*SCREENSCALE;
    [self.compileProgress addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressValue.mas_bottom).offset(18 * SCREENSCALE);
        make.width.equalTo(@(63 * SCREENSCALE));
        make.height.equalTo(@(25 * SCREENSCALE));
        make.centerX.equalTo(self.view);
    }];
    [self.cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)compileTimeline:(NvsTimeline *)timeline outputPath:(NSString *)ouputPath {
    self.currentTimeline = timeline;
    
    [NvsStreamingContext sharedInstance].compileConfigurations = [[NSMutableDictionary alloc] init];
    int64_t bitrateSetting = [NvUtils compileBitrateSetting];
    if (bitrateSetting > 0){
        [[NvsStreamingContext sharedInstance].compileConfigurations setValue:[NSNumber numberWithInteger:bitrateSetting] forKey:NVS_COMPILE_BITRATE];
    }
    
    [[NvsStreamingContext sharedInstance] setCustomCompileVideoHeight:timeline.videoRes.imageHeight];
    if (![[NvsStreamingContext sharedInstance] compileTimeline:timeline startTime:0 endTime:timeline.duration outputFilePath:ouputPath videoResolutionGrade:NvsCompileVideoResolutionGradeCustom videoBitrateGrade:NvsCompileBitrateGradeHigh flags: NvsStreamingEngineCompileFlag_IgnoreTimelineVideoSize]) {
        
    }
}

- (void)cancelBtnClicked {
    [[NvsStreamingContext sharedInstance] stop];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    });
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
    self.progressView.progressValue = progress;
}

- (void)didCompileCompleted:(NvsTimeline *)timeline isCanceled:(BOOL)isCanceled {
    [NvToast dismiss];
    if (isCanceled){
        
    }
    [self finishCompiling:isCanceled];
}

- (void)didCompileFailed:(NvsTimeline *)timeline {
    [NvToast dismiss];
    self.compileView.hidden = YES;
    
    NVWeakSelf
    [UIAlertController presentAlertFromVC:self
                                    title:NvLocalString(@"compile fiald", @"生成失败")
                                  message:NvLocalString(@"storage", @"请检查手机存储空间")
                        buttonTitleColors:nil
                        cancelButtonTitle:nil
                         otherButtonTitle:NvLocalString(@"Know", @"知道了")
                       cancelButtonAction:nil
                        otherButtonAction:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf finishCompiling:YES];
    }];

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
