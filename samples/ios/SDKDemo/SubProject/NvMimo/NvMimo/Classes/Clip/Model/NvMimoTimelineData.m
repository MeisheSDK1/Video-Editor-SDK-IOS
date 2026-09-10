//
//  NvMimoTimelineData.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/6/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMimoTimelineData.h"

@implementation NvMimoTimelineData

static NvMimoTimelineData *sharedInstance = nil;

+ (NvMimoTimelineData *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[NvMimoTimelineData alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    
    self.editDataArray = [[NSMutableArray alloc] init];
    self.themeInfo = nil;
    self.watermarkInfo = nil;
    self.captionDataArray = [[NSMutableArray alloc] init];
    self.stickerDataArray = [[NSMutableArray alloc] init];
    self.particleDataArray = [[NSMutableArray alloc] init];
    self.videoFxDataArray = [[NSMutableArray alloc] init];
    self.transitionDataArray = [[NSMutableArray alloc] init];
    self.dubbingModel = [[NvMimoDubbingModel alloc] init];
    self.musicDataArray = [[NSMutableArray alloc] init];
    self.dataOrder =  [[NSMutableArray alloc] init];
    [self.dataOrder addObject:@"Music"];
    [self.dataOrder addObject:@"Dubbing"];
    [self.dataOrder addObject:@"Theme"];
    [self.dataOrder addObject:@"Filter"];
    [self.dataOrder addObject:@"Sticker"];
    [self.dataOrder addObject:@"Caption"];
    [self.dataOrder addObject:@"Particle"];
    [self.dataOrder addObject:@"Transition"];
    [self.dataOrder addObject:@"Watermark"];

    return self;
}

- (void)clear {
    [self.editDataArray removeAllObjects];
    self.themeInfo = nil;
    self.watermarkInfo = nil;
    [self.captionDataArray removeAllObjects];
    [self.stickerDataArray removeAllObjects];
    [self.particleDataArray removeAllObjects];
    [self.videoFxDataArray removeAllObjects];
    [self.transitionDataArray removeAllObjects];
    self.dubbingModel = [NvMimoDubbingModel new];
    [self.musicDataArray removeAllObjects];
}


@end
