//
//  NvShortVideoCaptureView.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/8/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsRecordingProgress.h"
#import "NvGraphicBtn.h"
@class NvShortVideoCaptureView;

@protocol NvShortVideoCaptureViewDelegate <NSObject>
@optional
- (void)countDownBtnClick;
- (void)selectMusicClick;
- (void)faceBtnClicked;
- (void)propsBtnClicked;
- (void)cutMusicClicked;
- (void)cameraButtonClicked;
- (BOOL)supportAutoFocus;
- (BOOL)supportAutoExposure;
- (void)focusOnPoint:(CGPoint)point;
- (void)exposureOnPoint:(CGPoint)point;
- (void)backButtonClicked;
- (void)albumClick;
- (void)deleteBtnClicked;
- (void)nextBtnClicked;
- (void)filterBtnClicked;
- (void)flashBtnClicked;
- (void)startRecord;
- (void)overFifteenSecond;
- (void)endRecord;
- (void)shortVideoCaptureView:(NvShortVideoCaptureView *)shortVideoCaptureView selectSpeed:(float)speed;

@end

@interface NvShortVideoCaptureView : UIView {
    @public
    NvGraphicBtn *flashBtn;
    ///录制进度条
    ///Recording progress bar
    NvsRecordingProgress *recordingProgress;
    NvGraphicBtn *faceBtn;
    UIButton *deleteBtn;
    UIButton *nextBtn;
}

@property (weak, nonatomic) id<NvShortVideoCaptureViewDelegate> delegate;

@property (nonatomic, strong) NvGraphicBtn *album;          //相册
@property (nonatomic, strong) UIButton *selectMusic;         //选择音乐
@property (nonatomic, strong) NvGraphicBtn *countDownBtn;   //倒计时

- (void)updateCaptureClipDuration:(int64_t)duration;

- (void)hiddenAllButtonExceptRecordingButton;
- (void)showAllButton;

- (void)showFocusToPoint:(CGPoint)point;
- (void)hiddenFocusImage;

///录制超过15秒后
///After recording for more than 15 seconds
- (void)recordingEnd;

- (void)enableRecordingButton;

- (void)countDownStartRecording;

@end
