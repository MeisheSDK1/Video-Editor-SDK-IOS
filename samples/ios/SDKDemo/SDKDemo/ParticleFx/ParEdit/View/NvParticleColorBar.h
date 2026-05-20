//
//  NvParticleColorBar.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/12/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvParticleColorBar : UIControl
- (void)addBar:(float)posX width:(float)width color:(NSString *)color fxUuid:(NSString *)fxUuid;
- (void)updateLastBar:(BOOL)isReverse;
- (void)deleteLastBar;

- (void)clearCurrentArray;
- (void)addToCurrentArray:(NSString *)fxUUID inPoint:(int64_t)inPoint outPoint:(int64_t)outPoint;
- (void)updateSubviewsByCurrentArray:(BOOL)isReverse withColor:(NSMutableArray *)colorArray;

@property (assign, nonatomic) int64_t timelineStartPosition;
@property (assign, nonatomic) int64_t timelineCurrentPosition;
@property (assign, nonatomic) int64_t timelineDuration;
@property (strong, nonatomic) NSMutableArray* barsPosXArray;
@property (strong, nonatomic) NSMutableArray* barsWidthArray;
@property (strong, nonatomic) NSMutableArray* barsColorArray;
@property (strong, nonatomic) NSMutableArray* barsFxUUIDArray;
@property (strong, nonatomic) NSMutableArray* barsTimelineStartPositionArray;
@property (strong, nonatomic) NSMutableArray* barsTimelineEndPositionArray;

@property (strong, nonatomic) NSMutableArray* currentFxUUIDArray;
@property (strong, nonatomic) NSMutableArray* currentTimelineStartPositionArray;
@property (strong, nonatomic) NSMutableArray* currentTimelineEndPositionArray;
@end


