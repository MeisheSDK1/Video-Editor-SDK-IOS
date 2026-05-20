//
//  NvRangeSequenceView.h
//  SDKDemo
//
//  Created by Mac-Mini on 2025/5/7.
//  Copyright © 2025 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NvRangeSequenceView;
@protocol NvRangeSequenceViewDelegate <NSObject>

- (void)onRangeSequenceView:(NvRangeSequenceView *)rangeSequenceView didLeftChange:(int64_t)leftValue isTouchUp:(BOOL)isTouchUp;
- (void)onRangeSequenceView:(NvRangeSequenceView *)rangeSequenceView didRightChange:(int64_t)rightValue isTouchUp:(BOOL)isTouchUp;
- (void)onRangeSequenceView:(NvRangeSequenceView *)rangeSequenceView didSeekPosition:(int64_t)position isTouchUp:(BOOL)isTouchUp;

@end

@class NvsVideoTrack;
@class NvsMultiThumbnailSequenceView;
@interface NvRangeSequenceView : UIView

@property (nonatomic, weak) id<NvRangeSequenceViewDelegate> delegate;
@property (nonatomic, strong) NvsVideoTrack *videoTrack;
@property (nonatomic, strong) NvsMultiThumbnailSequenceView *sequenceView;
@property (nonatomic, assign) int64_t minValue;

- (int64_t)getLeftValue;
- (int64_t)getRightValue;

- (void)didPlaybackTimelinePosition:(int64_t)position;

@end

NS_ASSUME_NONNULL_END
