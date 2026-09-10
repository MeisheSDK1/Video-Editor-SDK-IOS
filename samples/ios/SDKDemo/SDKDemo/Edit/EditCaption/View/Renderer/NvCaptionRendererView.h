//
//  NvCaptionRendererView.h
//  SDKDemo
//
//  Created by ms on 2020/7/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvStyleListView.h"
#import "NvCaptionRendererItem.h"
#import "NVHeader.h"

@protocol NvCaptionRendererViewDelegate
@optional
- (void)okClick;
- (void)applyCaptionRendererToAllCaption:(BOOL)applyToAllCaption;
- (void)selectCaptionRenderer:(NvCaptionRendererItem *)item;
- (void)moreCaptionRendererClick;

@end

@interface NvCaptionRendererView : NvStyleListView

///设置默认数据
///Set default data
- (void)renderListWithItems:(NSMutableArray <NvCaptionRendererItem *>*)dataSource;

@end

