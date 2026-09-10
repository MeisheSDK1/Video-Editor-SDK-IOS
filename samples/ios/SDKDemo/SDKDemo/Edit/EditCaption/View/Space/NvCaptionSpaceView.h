//
//  NvCaptionSpaceView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2019/11/1.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvTimelineDataModel.h"
@class NvCaptionSpaceView;

NS_ASSUME_NONNULL_BEGIN

@protocol NvCaptionSpaceViewDelegate <NSObject>
- (void)okClick;
- (void)applyCaptionSpaceToAllCaption:(BOOL)applyToAllCaption;
- (void)captionSpaceView:(NvCaptionSpaceView *)captionSpaceView didSelectCaptionLetterSpaceType:(float)letterSpace Type:(NvCaptionLetterSpaceType)type;
- (void)captionSpaceView:(NvCaptionSpaceView *)captionSpaceView didSelectCaptionLineLetterSpace:(float)letterSpace;

@end

@interface NvCaptionSpaceView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL containFinishButton;
@property (nonatomic, strong) UIButton *smaller;
@property (nonatomic, strong) UIButton *standard;
@property (nonatomic, strong) UIButton *larger;
@property (nonatomic, strong) UIButton *huge;

@property (nonatomic, strong) UIButton *lineSmaller;
@property (nonatomic, strong) UIButton *lineStandard;
@property (nonatomic, strong) UIButton *lineLarger;
@property (nonatomic, strong) UIButton *lineHuge;

@property (nonatomic, strong) UILabel *styleApplyLabel;
@property (nonatomic, strong) UIButton *applyButton;

- (void)selectCaptionLetterSpace:(float)letterSpace;
- (void)selectCaptionLetterSpaceType:(NvCaptionLetterSpaceType)letterSpaceType;
- (void)selectCaptionLineLetterSpace:(float)letterSpace;
@end

NS_ASSUME_NONNULL_END
