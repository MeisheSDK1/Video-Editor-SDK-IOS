//
//  NvEditBGBlurView.h
//  SDKDemo
//
//  Created by MS on 2020/10/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvEditBGBlurModel.h"
NS_ASSUME_NONNULL_BEGIN
@class NvEditBGBlurView;
@protocol NvEditBGBlurViewDelegate <NSObject>

//点击应用按钮方法 Click the Apply button method
- (void)nvEditBGBlurView:(NvEditBGBlurView *)blurView applyButtonClicked:(UIButton *)button;

//选中颜色 Selected color
- (void)nvEditBGBlurView:(NvEditBGBlurView *)blurView selectModel:(NvEditBGBlurModel *)model;

//应用所有片段方法 Apply all fragment methods
- (void)nvEditBGBlurViewApplyAll:(NvEditBGBlurView *)blurView;

@end
@interface NvEditBGBlurView : UIView
@property (nonatomic, assign) id<NvEditBGBlurViewDelegate>delegate;

- (void)configData:(NSArray *)array;
@end

NS_ASSUME_NONNULL_END
