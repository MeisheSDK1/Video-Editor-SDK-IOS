//
//  NvStyleListView.h
//  SDKDemo
//
//  Created by Meicam on 2018/6/5.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionStyleItem.h"
#import "NVHeader.h"
NS_ASSUME_NONNULL_BEGIN
@protocol NvStyleListViewProtocol
@optional
- (void)okClick;
- (void)moreClick;
- (void)applyAllClick:(BOOL)applyToAll;
- (void)selectCaptionItem:(id _Nonnull)item;

@end

@protocol NvStyleListViewDelegate
@optional
- (void)okClick;
- (void)applyStyleToAllCaption:(BOOL)applyToAllCaption;
- (void)selectStyle:(NvCaptionStyleItem * _Nonnull)item;
- (void)moreStyleClick;

@end

@interface NvStyleListView : UIView<NvStyleListViewProtocol>

@property (weak, nonatomic) id _Nullable delegate;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UILabel *styleApplyLabel;
@property (nonatomic, strong) NvButton *applyButton;
@property (nonatomic, strong) id _Nullable currentItem;
@property (nonatomic, assign) BOOL containFinishButton;

- (Class)registerCell;

///设置默认数据
///Set default data
- (void)renderListWithItems:(NSMutableArray <NvCaptionStyleItem *>*)dataSource;

@end
NS_ASSUME_NONNULL_END
