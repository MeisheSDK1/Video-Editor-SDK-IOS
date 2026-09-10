//
//  NvDubNoiseSuppressionView.h
//  SDKDemo
//
//  Created by Meishe on 2022/9/9.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvDubNoiseSuppressionView;
NS_ASSUME_NONNULL_BEGIN
@protocol NvDubNoiseSuppressionViewDelegate <NSObject>
- (void)noiseSuppressionView:(NvDubNoiseSuppressionView *)view selectIndex:(NSInteger)index;

- (void)noiseSuppressionViewdidAddOkClick;
@end

@interface NvDubNoiseSuppressionView : UIView
@property (nonatomic, assign) id <NvDubNoiseSuppressionViewDelegate>delegate;
@property (nonatomic, assign) NSInteger selectedIndex;
@end

NS_ASSUME_NONNULL_END
