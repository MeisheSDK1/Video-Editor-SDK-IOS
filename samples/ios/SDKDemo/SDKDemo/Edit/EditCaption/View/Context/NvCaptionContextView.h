//
//  NvCaptionContextView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2020/7/25.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvCaptionRendererView.h"
#import "NvStyleListView.h"
@class NvCaptionContextItem;

@protocol NvCaptionContextViewDelegate
@optional
- (void)okClick;
- (void)applyCaptionContextToAllCaption:(BOOL)applyToAllCaption;
- (void)selectCaptionContext:(NvCaptionContextItem *_Nonnull)item;
- (void)moreCaptionContextClick;

@end

NS_ASSUME_NONNULL_BEGIN

@interface NvCaptionContextView : NvStyleListView

- (void)renderListWithItems:(NSMutableArray <NvCaptionContextItem *>*)dataSource;

@end

NS_ASSUME_NONNULL_END
