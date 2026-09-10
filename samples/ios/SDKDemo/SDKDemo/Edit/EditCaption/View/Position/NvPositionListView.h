//
//  NvPositionListView.h
//  SDKDemo
//
//  Created by Meicam on 2018/6/6.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVHeader.h"
@class NvPositionListView;

typedef NS_ENUM(NSUInteger, NvCaptionTextAlignment) {
    None,
    NvCaptionTextAlignmentLeft,
    NvCaptionTextAlignmentRight,
    NvCaptionTextAlignmentUp,
    NvCaptionTextAlignmentDown,
    NvCaptionTextAlignmentVertical,
    NvCaptionTextAlignmentHorizontal
};

@protocol NvPositionListViewDelegate
@optional
- (void)okClick;
- (void)applyPositionToAllCaption:(BOOL)applyToAllCaption;
- (void)applyPositionWithType:(NvCaptionTextAlignment)type;
@end

@interface NvPositionListView : UIView

@property (nonatomic, weak)id delegate;
@property (nonatomic, assign) BOOL containFinishButton;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIButton *upButton;
@property (nonatomic, strong) UIButton *downButton;
@property (nonatomic, strong) UIButton *verticalButton;
@property (nonatomic, strong) UIButton *horizontalButton;

@property (nonatomic, strong) UILabel *styleApplyLabel;
@property (nonatomic, strong) NvButton *applyButton;
@property (nonatomic, assign) NvCaptionTextAlignment type;

///重置应用全部按钮
///Reset apply All buttons
- (void)resetApplyButton;

@end
