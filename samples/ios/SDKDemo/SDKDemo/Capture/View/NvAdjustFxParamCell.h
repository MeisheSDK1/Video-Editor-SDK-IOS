//
//  NvAdjustFxParamCell.h
//  SDKDemo
//
//  Created by Meishe on 2022/8/17.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvAjustFxParamModel.h"
NS_ASSUME_NONNULL_BEGIN
@class NvAdjustFxParamCell;
@class BLItemSlider;
@class NvCustomColorControl;

@protocol NvAdjustFxParamCellDelegate <NSObject>

- (void)nvAdjustFxParamCell:(NvAdjustFxParamCell *)cell valueChanged:(NvAjustFxParamModel *)model;

- (void)nvAdjustFxParamCell:(NvAdjustFxParamCell *)cell endChange:(NvAjustFxParamModel *)model;
@end
@interface NvAdjustFxParamCell : UICollectionViewCell

@property (nonatomic, strong) NvAjustFxParamModel *model;
@property (nonatomic, strong) BLItemSlider *slider;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) NvCustomColorControl *colorSlider; //自定义颜色选择器 Custom color picker

@property (nonatomic, assign) id <NvAdjustFxParamCellDelegate>delegate;
- (void)renderCellWithModel:(NvAjustFxParamModel *)model;


- (void)itemSliderTouchEnd:(BLItemSlider *)slider;

-(void)itemSlider:(BLItemSlider*)slider valueChanged:(float)value;
@end

NS_ASSUME_NONNULL_END
