//
//  NvCompoundCaptionStyleView.h
//  SDKDemo
//
//  Created by MS on 2019/5/16.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimeline.h"
#import "NvCaptionStyleItem.h"
#import "NVHeader.h"

@protocol NvCompoundCaptionStyleViewDelegate <NSObject>
@optional
- (void)applyStyleToAllCaption:(BOOL)applyToAllCaption;
- (void)selectStyle:(NvCaptionStyleItem *)item isApplyToAllCaption:(BOOL)isApplyToAllCaption;
- (void)moreStyleClick;
- (void)styleOkButtonClick;
- (void)stylePlay;

@end

@interface NvCompoundCaptionStyleView : UIView

@property(nonatomic, strong) NvsTimeline *timeline;
@property(nonatomic, weak) id<NvCompoundCaptionStyleViewDelegate> delegate;
@property(nonatomic, strong) NvCaptionStyleItem *currentItem;

///设置默认数据
///Set default data
- (void)renderListWithItems:(NSMutableArray <NvCaptionStyleItem *>*)dataSource;
- (void)reloadData;

@end
