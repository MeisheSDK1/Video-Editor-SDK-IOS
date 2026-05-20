//
//  NvCompoundTimeSpanInfoModel.h
//  SDKDemo
//
//  Created by MS on 2019/5/23.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvTimelineDataModel.h"
#import "NvsCTimelineTimeSpan.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvCompoundTimeSpanInfoModel : NSObject
@property (nonatomic, strong) NvCompoundCaptionInfoModel *infoModel;
@property (nonatomic, strong) NvsCTimelineTimeSpan *timeSpan;
@property (nonatomic, strong) NvsTimelineCompoundCaption *currentCaption;

@end

NS_ASSUME_NONNULL_END
