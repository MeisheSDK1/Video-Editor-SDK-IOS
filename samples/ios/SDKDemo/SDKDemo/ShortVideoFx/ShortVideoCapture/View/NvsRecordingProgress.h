//
//  NvsRecordingProgress.h
//  progress
//
//  Created by Meicam on 2018/3/17.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TotalTime 15000000
#define MinRecordTime 4000000

typedef NS_ENUM(NSUInteger, ProgressStatus) {
    UnKnow,
    Start,
    Progressing,
    End,
    Prepare,
};

@interface NvsRecordingProgress : UIView

@property (weak, nonatomic)id delegate;
@property (assign, nonatomic) ProgressStatus status;
///获取录制有几段
///There are several segments of the capture recording
@property (assign, nonatomic, readonly) NSUInteger getCount;
///获取当前值（0-15000000）
///Get the current value (0-15000000)
@property (assign, nonatomic, readonly) int64_t value;
///开始录制
///Start recording
- (void)beginProgress;
///录制中传递当前的时间占总时间的百分比
///The percentage of the recording time that is transmitted to the total time
- (void)currentValue:(int64_t)value;
///结束录制
///End recording
- (void)endProgress;
///准备删除
///Ready to delete
- (void)prepareDelete;
///删除
///delete
- (void)deleteProgress;
///获取上一段结束value毫秒
///Gets the end value of the previous segment in milliseconds
- (int64_t)getValue;
///是否只有一段并且达到了15秒
///Is there only one segment and it reaches 15 seconds
- (BOOL)singleRecordingOverFifteen;

- (int64_t)getMinRecordTime;

@end
