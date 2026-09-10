//
//  NvSelectedAnimationView.h
//  SDKDemo
//
//  Created by ms on 2020/8/25.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvAnimationSlider.h"
@class NvSelectedAnimationModel;

NS_ASSUME_NONNULL_BEGIN

@interface NvSelectedAnimationView : UIView
@property (nonatomic, strong) NSMutableArray<NvSelectedAnimationModel *> * animationDataSource;
@property (nonatomic, copy) void(^selectAnimation)(NvSelectedAnimationModel *);
@property (nonatomic, copy) void(^moreBtnClick)(void);
@property (nonatomic, copy) void(^okBtnClick)(void);
@property (nonatomic, strong) NvAnimationSlider *slider;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, copy)void(^valueChangeBLock)(NvSelectedAnimationView*, CGFloat);
@property (nonatomic, copy)void(^valueChangeEndBLock)(void);
@property(nonatomic, strong) UICollectionView *collectionView;
/**
 * @brief <#desc#>
 */
@property (nonatomic, assign) CGFloat topY;
@end

NS_ASSUME_NONNULL_END
