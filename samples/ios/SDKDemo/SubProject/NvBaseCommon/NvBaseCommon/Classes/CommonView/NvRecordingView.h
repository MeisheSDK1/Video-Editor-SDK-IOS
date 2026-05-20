//
//  NvRecordingView.h
//  
//
//  Created by 刘东旭 on 2019/3/26.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvRecordingView;

typedef enum : NSUInteger {
    NvCaptureVideoModel,
    NvCapturePhotoModel,
} NvCaptureSwitchModel;

@protocol NvRecordingViewDelegate <NSObject>

- (BOOL)recordingViewAllowStartRecording:(NvRecordingView *_Nullable)recordingView;
- (void)startRecording;
- (void)stopRecording;
- (void)takePhoto;

@end

NS_ASSUME_NONNULL_BEGIN

@interface NvRecordingView : UIView

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign) NvCaptureSwitchModel captureModel;
- (void)startAnimation;
- (void)stopAnimation;
- (void)callbackAndStopAnimation;

@end

NS_ASSUME_NONNULL_END
