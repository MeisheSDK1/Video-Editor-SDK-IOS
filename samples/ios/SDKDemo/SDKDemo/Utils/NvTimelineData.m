//
//  NvTimelineData.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/6/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvTimelineData.h"
#import "YYModel.h"

@implementation NvTimelineData

static NvTimelineData *sharedInstance = nil;

+ (NvTimelineData *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[NvTimelineData alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    self.dataOrder =  [[NSMutableArray alloc] init];
    [self.dataOrder addObject:@"Music"];
    [self.dataOrder addObject:@"Dubbing"];
    [self.dataOrder addObject:@"Theme"];
    [self.dataOrder addObject:@"Filter"];
    [self.dataOrder addObject:@"Sticker"];
    [self.dataOrder addObject:@"Caption"];
    [self.dataOrder addObject:@"CompoundCaption"];
    [self.dataOrder addObject:@"Particle"];
    [self.dataOrder addObject:@"Transition"];
    [self.dataOrder addObject:@"Watermark"];
    [self.dataOrder addObject:@"Animation"];
    [self.dataOrder addObject:@"Mask"];
    [self.dataOrder addObject:@"Makeup"];
    [self.dataOrder addObject:@"Beauty"];
    self.timelineFilterArray = [[NSMutableArray alloc] init];
    self.captionDataArray = [[NSMutableArray alloc] init];
    self.compoundCaptionDataArray = [[NSMutableArray alloc] init];
    self.stickerDataArray = [[NSMutableArray alloc] init];
    self.particleDataArray = [[NSMutableArray alloc] init];
    self.videoFxDataArray = [[NSMutableArray alloc] init];
    self.transitionDataArray = [[NSMutableArray alloc] init];
    self.dubbingModel = [[NvDubbingModel alloc] init];
    self.musicDataArray = [[NSMutableArray alloc] init];
    self.editDataArray = [[NSMutableArray alloc] init];
    self.beautyArr = [[NSMutableArray alloc] init];
    self.shapeArr = [[NSMutableArray alloc] init];
    self.microShapeArr = [[NSMutableArray alloc] init];
    self.themeInfo = nil;
    self.timelineFilter = nil;
    self.watermarkInfo = nil;
    self.timelineMakeupModel = nil;
    self.editMode = 0;
    self.type = 0;
    self.isDou = NO;
    self.trimIn = 0;
    self.trimOut = 0;
    self.musicPath = nil;
    return self;
}

- (void)clear {
    [self.editDataArray removeAllObjects];
    self.themeInfo = nil;
    self.watermarkInfo = nil;
    self.timelineFilter = nil;
    self.timelineMakeupModel = nil;
    self.editMode = 0;
    self.type = 0;
    self.isDou = NO;
    self.trimIn = 0;
    self.trimOut = 0;
    self.musicPath = nil;
    [self.timelineFilterArray removeAllObjects];
    [self.captionDataArray removeAllObjects];
    [self.compoundCaptionDataArray removeAllObjects];
    [self.stickerDataArray removeAllObjects];
    [self.particleDataArray removeAllObjects];
    [self.videoFxDataArray removeAllObjects];
    [self.transitionDataArray removeAllObjects];
    self.dubbingModel = [NvDubbingModel new];
    [self.musicDataArray removeAllObjects];
    [self.beautyArr removeAllObjects];
    [self.shapeArr removeAllObjects];
    [self.microShapeArr removeAllObjects];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"editDataArray" : [NvEditDataModel class],
        @"captionDataArray" : [NvCaptionInfoModel class],
        @"compoundCaptionDataArray" : [NvCompoundCaptionInfoModel class],
        @"animationDataArray" : [NvAnimationInfoModel class],
        @"stickerDataArray" : [NvStickerInfoModel class],
        @"particleDataArray" : [NvParticleInfoModel class],
        @"videoFxDataArray" : [NvTimeFilterInfoModel class],
        @"transitionDataArray" : [NvTransitionInfoModel class],
        @"musicDataArray" : [NvMusicInfoModel class],
        @"dataOrder" : [NSString class],
        @"timelineFilterArray" : [NvTimeFilterInfoModel class],
        @"beautyArr" : [NvBeautyTypeModel class],
        @"shapeArr" : [NvBeautyTypeModel class],
        @"microShapeArr" : [NvBeautyTypeModel class],
    };
}


@end
