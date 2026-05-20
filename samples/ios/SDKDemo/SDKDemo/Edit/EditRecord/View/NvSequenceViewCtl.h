//
//  NvSequenceViewCtl.h
//  SDKDemo
//
//  Created by meishe01 on 2018/8/8.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsMultiThumbnailSequenceView.h"
#import "NvRecordModel.h"

@interface NvSpanItem : UIView

@property (nonatomic, assign) int64_t inPoint;
@property (nonatomic, assign) int64_t outPoint;

@end

@protocol NvSequenceViewCtlDelegate <NSObject>

@optional
- (void)sequenceViewCtl:(id)sequenceViewCtl scroll:(int64_t)timestamp;
- (void)sequenceViewCtl:(id)sequenceViewCtl scrollEnded:(int64_t)timestamp;

@end

@interface NvSequenceViewCtl : UIView

@property (nonatomic, weak) id <NvSequenceViewCtlDelegate> delegate;
@property (nonatomic, assign) int64_t timelinePosition;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)initSequenceViewCtl:(NSArray<NvsThumbnailSequenceDesc *> *)descArray duration:(int64_t)duration;
- (void)updateSpanItems:(NSArray<NvRecordModel *> *)dataArray;
- (void)removeSpanItem:(int64_t)timestamp;
- (void)scaleSequenceView:(double)scaleFactor;
- (void)setSequenceViewScrollEnabled:(BOOL)enabled;
- (void)startRecording:(int64_t)timestamp;
- (void)stopRecording;

- (CGFloat)getTimelineEditorWidth;
@end
