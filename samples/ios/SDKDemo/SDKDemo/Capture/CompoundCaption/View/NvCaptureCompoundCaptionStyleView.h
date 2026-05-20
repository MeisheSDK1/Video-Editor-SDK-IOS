//
//  NvCompoundCaptionStyleView.h
//  SDKDemo
//
//  Created by ms on 2021/6/29.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionStyleItem.h"
#import "NvTimelineDataModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvCaptureCompoundCaptionStyleView : UIView
@property(nonatomic, strong) NSArray *items;

/// 选中回调 Selected callback
@property (nonatomic, copy) void(^selectItemClick)(NvCaptionStyleItem *);

/// 更多回调 More pullbacks
@property (nonatomic, copy) void(^selectMoreItemClick)(void);

-(void)cancleSelectedWithCaption:(NvCompoundCaptionInfoModel *_Nullable)model;
@end

NS_ASSUME_NONNULL_END
