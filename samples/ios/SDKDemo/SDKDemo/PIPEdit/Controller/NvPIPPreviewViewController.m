//
//  NvPIPPreviewViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/17.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvPIPPreviewViewController.h"
#import <NvSDKCommon/NvCompileViewController.h>
#import <NvSDKCommon/NvLiveWindowPanelView.h>
#import "NvTipsView.h"
#import <NvSDKCommon/NvUtils.h>

@interface NvPIPPreviewViewController ()<NvCompileViewControllerDelegate, NvLiveWindowPanelViewDelegate>

@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvLiveWindowPanelView *liveWindowPanel;
@property (nonatomic, strong) NSString *compileFilePath;
@property (nonatomic, strong) UIButton *compileButton;
@end

@implementation NvPIPPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.streamingContext = [NvsStreamingContext sharedInstanceWithFlags:NvsStreamingContextFlag_Support4KEdit | NvsStreamingContextFlag_InterruptStopForInternalStop | NvsStreamingContextFlag_NeedGifMotion];

    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.liveWindowPanel = [[NvLiveWindowPanelView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH)];
    self.liveWindowPanel.liveWindow.hdrDisplayMode = NvsLiveWindowHDRDisplayMode_SDR;
    self.liveWindowPanel.editMode = self.editMode;
    [self.liveWindowPanel connectTimeline:self.timeline];
    self.liveWindowPanel.delegate = self;
    [self.liveWindowPanel hiddenVolumeButton];
    [self.view addSubview:self.liveWindowPanel];
    [self.liveWindowPanel playAtTime:0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.streamingContext stop];
}

- (UIView *)rightNavigationBarItemView {
    self.compileButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Compile", @"生成") textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] fontSize:16 image:nil];
    self.compileButton.frame = CGRectMake(0, 0, 30, 44);
    self.compileButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15*SCREENSCALE);
    [self.compileButton addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.compileButton.exclusiveTouch = YES;
    return self.compileButton;
}

- (void)rightBtnClicked {
    [self.streamingContext stop];
    self.compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:self.timeline outputPath:self.compileFilePath];
}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
    NVWeakSelf
    if (needDelete) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:weakSelf.compileFilePath error:nil];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            UISaveVideoAtPathToSavedPhotosAlbum(weakSelf.compileFilePath, weakSelf, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        });
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
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
