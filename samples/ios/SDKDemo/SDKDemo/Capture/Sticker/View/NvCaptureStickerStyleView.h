//
//  NvCaptureStickerStyleView.h
//  SDKDemo
//
//  Created by ms on 2021/6/25.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvAssetCellModel.h"
#import "NvTimelineDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvCaptureStickerStyleView : UIView

@property(nonatomic, strong) NSArray *items;

@property(nonatomic, strong) NSArray *customItems;

/// 选中回调 Selected callback
@property (nonatomic, copy) void(^selectItemClick)(NvAssetCellModel *);

/// 更多回调 More pullbacks
@property (nonatomic, copy) void(^selectMoreItemClick)(void);

/// 添加自定义贴纸 Add custom stickers
@property (nonatomic, copy) void(^addCustomSticker)(void);

-(void)cancleSelectedWithSticker:(NvStickerInfoModel *_Nullable)model;
@end

NS_ASSUME_NONNULL_END
