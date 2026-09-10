//
//  NvPIPPreviewViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/17.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvPIPPreviewViewController.h"
#import "NvCompileViewController.h"
#import "NvLiveWindowPanelView.h"
#import "NvTipsView.h"
#import "NvUtils.h"

@interface NvPIPPreviewViewController ()<NvCompileViewControllerDelegate, NvLiveWindowPanelViewDelegate>

@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvLiveWindowPanelView *liveWindowPanel;
@property (nonatomic, strong) NSString *compileFilePath;

@end

@implementation NvPIPPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.streamingContext = [NvsStreamingContext sharedInstanceWithFlags:NvsStreamingContextFlag_Support4KEdit];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:NvLocalString(@"Compile", @"生成") style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnClicked)];
    [rightButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NvUtils fontWithSize:16], NSFontAttributeName, [UIColor nv_colorWithHexRGB:@"#4A90E2"], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    self.liveWindowPanel = [[NvLiveWindowPanelView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH)];
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

//生成按钮
- (void)rightBtnClicked {
    self.compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:self.timeline outputPath:self.compileFilePath];

}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
    if (needDelete) {
        [[NSFileManager defaultManager] removeItemAtPath:_compileFilePath error:nil];
    } else {
        UISaveVideoAtPathToSavedPhotosAlbum(_compileFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}

//保存相册的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//    NvTipsView *tip = [[NvTipsView alloc]initWithFrame:self.view.frame withTitle:NvLocalString(@"Save Succecs!", @"保存成功！") withColor:[UIColor nv_colorWithHexRGB:@"#4D4F51"] withCenter:NO];
//    [self.view addSubview:tip];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [tip removeFromSuperview];
//    });
    
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
