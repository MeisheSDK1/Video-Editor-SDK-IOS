//
//  NvStickerAnimationView.h
//  SDKDemo
//
//  Created by ms on 2021/4/20.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVHeader.h"
#import "NvStickerAnimationModel.h"

///功能类型
///Functional type
typedef enum{
    NvInStickerAnimationType = 0,       ///<入场动画
    NvOutStickerAnimationType,          ///<出场动画
    NvComStickerAnimationType,         ///< 组合动画
}NvStickerAnimationType;


@protocol NvAnimationViewDelegate
@optional
- (void)okClick;
- (void)selectAnimation:(NvStickerAnimationModel *)item withAnimationType:(NvStickerAnimationType)type;
- (void)applyAnimationAllSticker:(BOOL)applyToAllSticker withAnimationType:(NvStickerAnimationType)type;
- (void)moreAnimationClickWithAnimationType:(NvStickerAnimationType)type;
- (void)changeAnimationType:(NvStickerAnimationType)type data:(NvStickerAnimationModel *)item;

@end

@interface NvStickerAnimationView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NvStickerAnimationModel *currentItem;
@property (nonatomic, strong) NvButton *applyButton;

- (NvStickerAnimationType)getCurrenntType;
/// 设置动画数组
/// Set animation array
/// @param dataSource 开场动画数组
/// Opening animation array
/// @param type 动画类型
/// Animation type
- (void)renderListWithOpenItems:(NSMutableArray <NvStickerAnimationModel *>*)dataSource withType:(NvStickerAnimationType)type;
/// 刷新数据
/// Refresh data
- (void)reloadData;
@end

