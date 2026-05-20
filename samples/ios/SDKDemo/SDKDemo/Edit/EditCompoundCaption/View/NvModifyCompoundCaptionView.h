//
//  NvModifyCompoundCaptionView.h
//  SDKDemo
//  复合字幕修改界面 Composite subtitle modification interface
//  Created by MS on 2019/5/20.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimelineCompoundCaption.h"
#import "NvColorCollectionViewCell.h"
#import "NvCompoundCaptionModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol NvModifyCompoundCaptionViewDelegate <NSObject>

- (void)cancelButtonClicked:(UIButton *)button ;
- (void)confirmButtonClicked:(UIButton *)button model:(NvCompoundCaptionModel *)model ;

@end

@interface NvModifyCompoundCaptionView : UIView

@property(nonatomic, strong) NvsTimelineCompoundCaption *caption;
@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, strong)NSMutableArray *fontDataArr;
@property(nonatomic, strong) UITextView *textView;
@property(nonatomic, strong) NvCaptionColorItem *currentItem;
///最后应用的数据（包含字体、颜色、文本、字体显示名），与选中字体界面公用此model
///The data that is finally applied (including font, color, text, and font display name) shares this model with the selected font interface
@property(nonatomic, strong) NvCompoundCaptionModel *model;
@property(nonatomic, weak) id<NvModifyCompoundCaptionViewDelegate>delegate;

- (instancetype )initWithFrame:(CGRect)frame compoundCaption:(NvsTimelineCompoundCaption *)caption selectedIndex:(NSInteger)index ;

@end

NS_ASSUME_NONNULL_END
