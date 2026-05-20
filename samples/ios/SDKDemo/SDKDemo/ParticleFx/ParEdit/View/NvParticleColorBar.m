//
//  NvParticleColorBar.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/12/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvParticleColorBar.h"
#import <NvSDKCommon/NvUtils.h>
#import <Masonry/Masonry.h>
#import <NvSDKCommon/NvSDKUtils.h>

#define NvColorBarAlpha 0.6
@implementation NvParticleColorBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    //    self.backgroundColor = [UIColor yellowColor];
    self.barsPosXArray = [[NSMutableArray alloc] init];
    self.barsWidthArray = [[NSMutableArray alloc] init];
    self.barsColorArray = [[NSMutableArray alloc] init];
    self.barsFxUUIDArray = [[NSMutableArray alloc] init];
    self.barsTimelineStartPositionArray = [[NSMutableArray alloc] init];
    self.barsTimelineEndPositionArray = [[NSMutableArray alloc] init];
    self.currentFxUUIDArray = [[NSMutableArray alloc] init];
    self.currentTimelineStartPositionArray = [[NSMutableArray alloc] init];
    self.currentTimelineEndPositionArray = [[NSMutableArray alloc] init];
    self.timelineStartPosition = 0;
    self.timelineCurrentPosition = 0;
    self.timelineDuration = 0;
    
    return self;
}


- (void)addBar:(float)posX width:(float)width color:(NSString *)color fxUuid:(NSString *)fxUuid {
    [self.barsPosXArray addObject:[NSNumber numberWithInt:posX]];
    [self.barsWidthArray addObject:[NSNumber numberWithInt:width]];
    [self.barsColorArray addObject:color];
    [self.barsFxUUIDArray addObject:fxUuid];
    [self.barsTimelineStartPositionArray addObject:[NSNumber numberWithLongLong:_timelineStartPosition]];
    [self.barsTimelineEndPositionArray addObject:[NSNumber numberWithLongLong:_timelineStartPosition]];
    
    UIView *bar = UIView.new;
    bar.backgroundColor = [UIColor nv_colorWithHexString:color alpha:NvColorBarAlpha];
    bar.frame = CGRectMake(posX, 0, width, self.frame.size.height);
    [self addSubview:bar];
}

- (void)deleteLastBar {
    if (![self isArrayValid])
        return;
    [self.barsPosXArray removeLastObject];
    [self.barsWidthArray removeLastObject];
    [self.barsColorArray removeLastObject];
    [self.barsFxUUIDArray removeLastObject];
    [self.barsTimelineStartPositionArray removeLastObject];
    [self.barsTimelineEndPositionArray removeLastObject];
    
    [self.subviews[self.subviews.count - 1] removeFromSuperview];
}

- (void)updateLastBar:(BOOL)isReverse {
    if (![self isArrayValid])
        return;
    float width = self.frame.size.width * llabs(self.timelineCurrentPosition - self.timelineStartPosition)/(float)(self.timelineDuration);
    
    NSNumber *number = [NSNumber numberWithFloat:width];
    [self.barsWidthArray removeLastObject];
    [self.barsWidthArray addObject:number];
    
    NSNumber *endPosition = [NSNumber numberWithLongLong:self.timelineCurrentPosition];
    [self.barsTimelineEndPositionArray removeLastObject];
    [self.barsTimelineEndPositionArray addObject:endPosition];
    
    UIView *lastBar = self.subviews[self.subviews.count - 1];
    if (self.timelineCurrentPosition == _timelineDuration)
        width = self.frame.size.width - lastBar.frame.origin.x;
    
    if (isReverse) {
        lastBar.frame = CGRectMake(lastBar.frame.origin.x + lastBar.frame.size.width - width, lastBar.frame.origin.y, width, lastBar.frame.size.height);
    } else {
        lastBar.frame = CGRectMake(lastBar.frame.origin.x, lastBar.frame.origin.y, width, lastBar.frame.size.height);
    }
}

- (BOOL)isArrayValid {
    return self.barsPosXArray.count == self.barsWidthArray.count &&
    self.barsPosXArray.count == self.barsColorArray.count &&
    self.barsPosXArray.count == self.barsFxUUIDArray.count &&
    self.barsPosXArray.count == self.barsTimelineStartPositionArray.count &&
    self.barsPosXArray.count == self.barsTimelineEndPositionArray.count &&
    self.barsPosXArray.count > 0;
}

- (void)clearCurrentArray {
    [self.currentFxUUIDArray removeAllObjects];
    [self.currentTimelineStartPositionArray removeAllObjects];
    [self.currentTimelineEndPositionArray removeAllObjects];
}

- (void)addToCurrentArray:(NSString *)fxUUID inPoint:(int64_t)inPoint outPoint:(int64_t)outPoint {
    [self.currentFxUUIDArray addObject:fxUUID];
    [self.currentTimelineStartPositionArray addObject:[NSNumber numberWithLongLong:inPoint]];
    [self.currentTimelineEndPositionArray addObject:[NSNumber numberWithLongLong:outPoint]];
}

- (void)updateSubviewsByCurrentArray:(BOOL)isReverse withColor:(NSMutableArray *)colorArray{
    NSLog(@"%lu", (unsigned long)self.currentFxUUIDArray.count);
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0; i < self.currentFxUUIDArray.count; i++) {
        UIView *bar = UIView.new;
        if (colorArray.count != 0 && colorArray != nil) {
            bar.backgroundColor = [UIColor nv_colorWithHexString:colorArray[i] alpha:NvColorBarAlpha];
        }else{
            bar.backgroundColor = [UIColor nv_colorWithHexString:[self getEffectColor:self.currentFxUUIDArray[i]] alpha:NvColorBarAlpha];
        }
        float posX = self.frame.size.width *[(NSNumber *)self.currentTimelineStartPositionArray[i] longLongValue]/(float)_timelineDuration;
        float width = self.frame.size.width *([(NSNumber *)self.currentTimelineEndPositionArray[i] longLongValue] - [(NSNumber *)self.currentTimelineStartPositionArray[i] longLongValue])/(float)_timelineDuration;
        if (isReverse)
            posX = self.frame.size.width - posX - width;
        bar.frame = CGRectMake(posX, 0, width, self.frame.size.height);
        [self addSubview:bar];
    }
}

- (NSString *)getEffectColor:(NSString *)fxUUID {
    
    NSString *packagePath = [[NSBundle mainBundle] pathForResource:@"shortVideoPackage" ofType:@"bundle"];
    NSString *jsonPath = [packagePath stringByAppendingPathComponent:@"fx.json"];
    NSString *jsontext = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
    NSData *data =[jsontext dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    for (int i = 0; i < array.count; i++) {
        NSDictionary *dic = array[i];
        if ([fxUUID isEqualToString:dic[@"fxid"]]) {
            return dic[@"color"];
        }
    }
    return @"FCB600";
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

