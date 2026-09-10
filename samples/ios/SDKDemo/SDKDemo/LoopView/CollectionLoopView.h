//
//  CollectionLoopView.h
//  ScrollViewLoop
//
//  Created by 刘东旭 on 2019/9/25.
//  Copyright © 2019 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvLoopViewModel.h"
@class CollectionLoopView;

NS_ASSUME_NONNULL_BEGIN

@protocol CollectionLoopViewDelegate <NSObject>

- (void)collectionLoopView:(CollectionLoopView *)collectionLoopView didSelectIndex:(unsigned int)index;

@end

@interface CollectionLoopView : UIView

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSArray <NvLoopViewModel *>*contents;

- (void)stopTimer;
- (void)startTimer;

@end

NS_ASSUME_NONNULL_END
