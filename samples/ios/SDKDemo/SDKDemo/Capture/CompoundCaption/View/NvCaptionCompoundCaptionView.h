//
//  NvCaptionCompoundCaptionView.h
//  SDKDemo
//
//  Created by ms on 2021/6/29.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsCaptureCompoundCaption.h"
#import "NvCompoundCaptionModel.h"
#import "NvCaptionColorItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvCaptionCompoundCaptionView : UIView

@property(nonatomic, strong)NSMutableArray *fontDataArr;
@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, strong) NvsCaptureCompoundCaption *caption;
@property(nonatomic, strong) NvCompoundCaptionModel *model;
@property(nonatomic, strong) NvCaptionColorItem *currentItem;

@property (nonatomic, copy) void(^selectItemClick)(NvCompoundCaptionModel *, NSInteger, BOOL);
@property (nonatomic, copy) void(^keyboardClick)(CGFloat);
@end

NS_ASSUME_NONNULL_END
