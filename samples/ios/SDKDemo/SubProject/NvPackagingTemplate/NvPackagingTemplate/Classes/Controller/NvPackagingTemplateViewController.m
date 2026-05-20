//
//  NvPackagingTemplateViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2021/6/25.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvPackagingTemplateViewController.h"
#import "NVDefineConfig.h"
#import "NvCompileViewController.h"
#import "UIColor+NvColor.h"
#import <Masonry/Masonry.h>
#import "NvStreamingSdkCore.h"
#import "NvUtils.h"
#import "NvSDKUtils.h"
#import <NvTemplate/NvTemplate-Swift.h>
#if __has_include(<NvTemplate/NvTemplate.h>)
@import NvTemplate;
#endif

@interface NvPackagingTemplateViewController ()<NvLiveWindowPanelViewDelegate,NvCompileViewControllerDelegate>

@property (nonatomic, strong) UIButton *titleBtn;

@property (nonatomic, strong) UIButton *creditsBtn;

@property (nonatomic, strong) NSString *compileFilePath;

@property (nonatomic, assign) BOOL isCredits;

@property (nonatomic, strong) UIButton *titleDeleteBtn;

@property (nonatomic, strong) UIButton *creditsDeleteBtn;
@property (nonatomic, assign) BOOL isHaveHead;
@property (nonatomic, assign) BOOL isHaveTrail;
@property (nonatomic, strong) UIButton *compileButton;
@end

@implementation NvPackagingTemplateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.liveWindowPanel.liveWindow.hdrDisplayMode = NvsLiveWindowHDRDisplayMode_SDR;
    
    self.title = NvLocalString(@"Packaging template", @"包装模板");
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(templateSelectionCallback:) name:@"toPackagingTemplateViewController" object:nil];
    
    self.liveWindowPanel.delegate = self;
    [self.liveWindowPanel hiddenVolumeButton];
    
    [self.liveWindowPanel hiddenVolumeButton];
    [self initTimeline];
    [self seekTimeline:0];
    [self addSubView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self connectLiveWindow];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self seekTimeline];
}

- (void)leftNavButtonClick:(UIButton *)button{
    [self.streamingContext stop];
    [self.streamingContext clearCachedResources:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
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
#pragma mark - 创建timeline
/*
 创建timeline
 Create timeline
 */
- (void)initTimeline{
    self.timeline = [NvSDKUtils createTimeline:self.editMode];
    __block BOOL isshowToast = NO;
    __weak typeof(self)weakSelf = self;
    [self.selectAssets enumerateObjectsUsingBlock:^(NvAlbumAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[weakSelf.timeline getVideoTrackByIndex:0] appendClip:obj.asset.localIdentifier];
    }];
}

#pragma mark - 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubView{
    self.titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.titleBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.titleBtn.titleLabel.font = FONT10;
    self.titleBtn.backgroundColor = [UIColor nv_colorWithHexRGB:@"#393939"];
    [self.titleBtn addTarget:self action:@selector(titleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.titleBtn setTitle:NvLocalString(@"Add title", @"添加片头") forState:UIControlStateNormal];
    self.titleBtn.titleLabel.numberOfLines = 2;
    self.titleBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
    [self.view addSubview:self.titleBtn];
    
    [self.titleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.liveWindowPanel.mas_bottom).offset(50*SCREENSCALE );
        make.left.equalTo(self.view).offset(16 * SCREENSCALE);
        make.height.offset(44 * SCREENSCALE);
        make.width.offset(52 * SCREENSCALE);
    }];
    
   
    self.titleDeleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.titleDeleteBtn.hidden = YES;
    [self.titleDeleteBtn addTarget:self action:@selector(titleDeleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.titleDeleteBtn setImage:NvImageNamedForBundle(@"NvDelete",NvCurrentBundle) forState:UIControlStateNormal];
    [self.view addSubview:self.titleDeleteBtn];
    
    [self.titleDeleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleBtn).offset(-8 *SCREENSCALE);
        make.right.equalTo(self.titleBtn).offset(8 *SCREENSCALE);
        make.width.height.offset(16 * SCREENSCALE);
    }];
    
    self.creditsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.creditsBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.creditsBtn.titleLabel.font = FONT10;
    self.creditsBtn.backgroundColor = [UIColor nv_colorWithHexRGB:@"#393939"];
    [self.creditsBtn addTarget:self action:@selector(creditsBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.creditsBtn setTitle:NvLocalString(@"Add credits", @"添加片尾") forState:UIControlStateNormal];
    self.creditsBtn.titleLabel.numberOfLines = 2;
    self.creditsBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.creditsBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.creditsBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
    [self.view addSubview:self.creditsBtn];
    
    [self.creditsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-16 * SCREENSCALE);
        make.width.height.equalTo(self.titleBtn);
        make.centerY.equalTo(self.titleBtn);
    }];
    
    self.creditsDeleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.creditsDeleteBtn.hidden = YES;
    [self.creditsDeleteBtn addTarget:self action:@selector(creditsDeleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.creditsDeleteBtn setImage:NvImageNamedForBundle(@"NvDelete",NvCurrentBundle) forState:UIControlStateNormal];
    [self.view addSubview:self.creditsDeleteBtn];
    
    [self.creditsDeleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.creditsBtn).offset(-8 *SCREENSCALE);
        make.right.equalTo(self.creditsBtn).offset(8 *SCREENSCALE);
        make.width.height.offset(16 * SCREENSCALE);
    }];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    
    for (int i = 0; i<track.clipCount; i++) {
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvsThumbnailSequenceDesc* desc = [[NvsThumbnailSequenceDesc alloc] init];
        desc.stillImageHint = clip.videoType == NvsVideoClipType_AV?NO:YES;
        desc.thumbnailAspectRatio = 1;
        desc.mediaFilePath = clip.filePath;
        desc.trimIn = clip.trimIn;
        desc.trimOut = clip.trimOut;
        desc.inPoint = clip.inPoint;
        desc.outPoint = clip.outPoint;
    
        [tempArray addObject:desc];
    }
    
    [self.view layoutIfNeeded];
    
    NvsMultiThumbnailSequenceView *thumbnailView = [[NvsMultiThumbnailSequenceView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.titleBtn.frame)+5*SCREENSCALE, CGRectGetMinY(self.titleBtn.frame), 230 * SCREENSCALE, 44*SCREENSCALE)];
    thumbnailView.bounces = NO;
    thumbnailView.thumbnailAspectRatio = 1;
    thumbnailView.thumbnailImageFillMode = NvsThumbnailFillModeAspectCrop;
    thumbnailView.pointsPerMicrosecond = 230 * SCREENSCALE/self.timeline.duration;
    thumbnailView.startPadding = 0;
    thumbnailView.endPadding = 0;
    thumbnailView.descArray = tempArray;
    [self.view addSubview:thumbnailView];
}

- (void)connectLiveWindow {
    if (!self.timeline) {
        return;
    }
    
    [self.liveWindowPanel connectTimeline:self.timeline];
    [self seekTimeline:self.liveWindowPanel.currentTime];
}

#pragma mark - 生成
/*
 生成
 composite
 */
- (void)rightBtnClicked{
    self.compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:self.timeline outputPath:self.compileFilePath];
}


#pragma mark - 添加片头
/*
 添加片头
 Add title
 */
- (void)titleBtnClick{
    
    if (self.isHaveHead) {
        return;
    }
    
    /// 添加剪同款
    /// Add cut the same style
    #if __has_include(<NvTemplate/NvTemplate.h>)
    NvTemplatePageViewController *vc = [[NvTemplatePageViewController alloc] init];
    vc.isPackagingTemplate = true;
    [self.navigationController pushViewController:vc animated:YES];
    self.isCredits = NO;
    #else
    return;
    #endif
}

#pragma mark - 添加片尾
/*
 添加片尾
 Add credits
 */
- (void)creditsBtnClick{
    
    if (self.isHaveTrail) {
        return;
    }
    /// 添加剪同款
    /// Add cut the same style
    #if __has_include(<NvTemplate/NvTemplate.h>)
    NvTemplatePageViewController *vc = [[NvTemplatePageViewController alloc] init];
    vc.isPackagingTemplate = true;
    [self.navigationController pushViewController:vc animated:YES];
    self.isCredits = YES;
    #else
    
    #endif
}

#pragma mark - 选择完片头和片尾的回调通知
///Select the callback notification after the opening and ending credits
- (void)templateSelectionCallback:(NSNotification *)notification{
    if (self.isCredits) {
        [self.creditsBtn setTitle:@"" forState:UIControlStateNormal];
        self.creditsDeleteBtn.hidden = NO;
        
        
        NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
        NvsTimeline *timeline = notification.userInfo[@"timeline"];
        if (timeline) {
            [self.creditsBtn setBackgroundImage:notification.userInfo[@"cover"] forState:UIControlStateNormal];
            [videoTrack appendTimelineClip:timeline];
            self.isHaveTrail = YES;
            [self connectLiveWindow];
        }
        
        
    }else{
        ///片头
        ///Opening title
        [self.titleBtn setTitle:@"" forState:UIControlStateNormal];
        self.titleDeleteBtn.hidden = NO;

        NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
        NvsTimeline *timeline = notification.userInfo[@"timeline"];
        if (timeline) {
            [self.titleBtn setBackgroundImage:notification.userInfo[@"cover"] forState:UIControlStateNormal];
            [videoTrack insertTimelineClip:timeline clipIndex:0];
            self.isHaveHead = YES;
            [self connectLiveWindow];
        }
        
    }
    self.streamingContext.delegate = self;

}

#pragma mark - 片头删除事件
///Title deletion event
- (void)titleDeleteBtnClick{
    self.titleDeleteBtn.hidden = YES;
    [self.titleBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.titleBtn setTitle:NvLocalString(@"Add title", @"添加片头") forState:UIControlStateNormal];
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    [videoTrack removeClip:0 keepSpace:NO];
    self.isHaveHead = NO;
    [self connectLiveWindow];
}

#pragma mark - 片尾删除事件
///End delete event
- (void)creditsDeleteBtnClick{
    self.creditsDeleteBtn.hidden = YES;
    [self.creditsBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.creditsBtn setTitle:NvLocalString(@"Add credits", @"添加片尾") forState:UIControlStateNormal];
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    [videoTrack removeClip:videoTrack.clipCount - 1 keepSpace:NO];
    self.isHaveTrail = NO;
    [self connectLiveWindow];
}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
    [self connectLiveWindow];
    if (needDelete) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:self.compileFilePath error:nil];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            UISaveVideoAtPathToSavedPhotosAlbum(self.compileFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        });
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
}

@end
