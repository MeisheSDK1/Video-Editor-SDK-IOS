//
//  NvCaptionInfoModel.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/15.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvTimelineDataModel.h"
#import "NvsCTimelineTimeSpan.h"

@interface NvInfoModel : NSObject

@property (nonatomic, strong) NvCaptionInfoModel *infoModel;
@property (nonatomic, strong) NvsTimelineCaption *currentCaption;
@property (nonatomic, strong) NvsClipCaption *currentClipCaption;
@property (nonatomic, strong) NvsCTimelineTimeSpan *timeSpan;
@end
