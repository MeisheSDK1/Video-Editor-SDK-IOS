//
//  NvEditBeautyEffectView.h
//  SDKDemo
//
//  Created by Meishe on 2022/11/16.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvBeautyTypeCViewCell.h"
@class NvEditBeautyEffectView;
NS_ASSUME_NONNULL_BEGIN
@protocol NvEditBeautyEffectViewDelegate <NSObject>
@optional

- (void)nvEditBeautyEffectView:(NvEditBeautyEffectView *)view switchSharpen:(BOOL)open;

- (void)nvEditBeautyEffectView:(NvEditBeautyEffectView *)view switchColorCorrect:(BOOL)open;

- (void)nvEditBeautyEffectView:(NvEditBeautyEffectView *)view switchBeautySum:(BOOL)open;


/// 选中应用某个美颜model Select Apply a beauty model
/// - Parameters:
///   - view: self
///   - model: 选中的model Selected model
///   - needRefreshView: 是否需要通知代理对象刷新界面（这里指的是滑杆所在的分界面是否需要刷新） Whether the proxy object needs to be notified to refresh the interface (in this case, whether the interface on which the slider is located needs to be refreshed)
///   - needRefreshData: 是否需要通知代理对象刷新其所持有的当前应用的model  Whether the proxy object needs to be notified to refresh the currently applied model it holds
- (void)nvEditBeautyEffectView:(NvEditBeautyEffectView *)view selecteModel:(NvBeautyTypeModel *)model refreshView:(BOOL)needRefreshView refreshData:(BOOL)needRefreshData;

/// 不允许点击 Not allowed to click
/// - Parameters:
///   - view: self
///   - model: 不允许点击的项 Items that are not allowed to be clicked
- (void)nvEditBeautyEffectView:(NvEditBeautyEffectView *)view forbiddenReplace:(NvBeautyTypeModel *)model;
@end

@interface NvEditBeautyEffectView : UIView
@property (nonatomic, assign) id <NvEditBeautyEffectViewDelegate>delegate;

/// 刷新界面数据源 Refresh interface data source
/// - Parameters:
///   - dataSource: 数据源
///   - temporary: 是否是临时数据 Whether it is temporary data
- (void)updateData:(NSArray <NvBeautyTypeModel *>*)dataSource showTemporaryData:(BOOL)temporary;

- (void)changeSwitchState:(BOOL)open;

- (void)reapplyAppliedEffects:(BOOL)needRefreshView refreshData:(BOOL)needRefreshData;

- (void)setZeroToAllEffectStrength:(BOOL)needRefreshView refreshData:(BOOL)needRefreshData;

- (void)refreshData;
@end

NS_ASSUME_NONNULL_END
