//
//  NvStickerModel.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/7/24.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "NvTimelineDataModel.h"
#import "NvsCTimelineTimeSpan.h"

@interface NvStickerModel : NSObject

@property (nonatomic, strong) NvStickerInfoModel *infoModel;
@property (nonatomic, strong) NvsTimelineAnimatedSticker *currentSticker;
@property (nonatomic, strong) NvsClipAnimatedSticker *currentClipSticker;
@property (nonatomic, strong) NvsCTimelineTimeSpan *timeSpan;


@end
