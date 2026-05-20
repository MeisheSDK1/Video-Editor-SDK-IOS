//
//  NvCurveSpeedListView.h
//  SDKDemo
//
//  Created by MS on 2020/11/26.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCurveSpeedModel.h"
@class NvCurveSpeedListView;

NS_ASSUME_NONNULL_BEGIN
@protocol NvCurveSpeedListViewDelegate <NSObject>

- (void)nvCurveSpeedListView:(NvCurveSpeedListView *)listView didSelectItem:(NvCurveSpeedModel *)item;

- (void)nvCurveSpeedListView:(NvCurveSpeedListView *)listView didBeginEditing:(NvCurveSpeedModel *)item;

- (void)nvFinishCurveSpeedListView:(NvCurveSpeedListView *)listView;

@end

@interface NvCurveSpeedListView : UIView
@property (nonatomic, weak) id<NvCurveSpeedListViewDelegate> delegate;

@property (nonatomic, strong) NSString *selectedCurveId;
@end

NS_ASSUME_NONNULL_END
