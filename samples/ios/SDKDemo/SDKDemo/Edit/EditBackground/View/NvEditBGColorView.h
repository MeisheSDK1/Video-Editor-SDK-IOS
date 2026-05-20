//
//  NvEditBGColorView.h
//  SDKDemo
//
//  Created by MS on 2020/10/21.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvEditBGColorModel.h"
NS_ASSUME_NONNULL_BEGIN
@class NvEditBGColorView;
@protocol NvEditBGColorViewDelegate <NSObject>

//点击应用按钮方法 Click the Apply button method
- (void)nvEditBGColorView:(NvEditBGColorView *)colorView applyButtonClicked:(UIButton *)button;

//选中颜色 Selected color
- (void)nvEditBGColorView:(NvEditBGColorView *)colorView selectModel:(NvEditBGColorModel *)model;

//应用所有片段方法 Apply all fragment methods
- (void)nvEditBGColorViewApplyAll:(NvEditBGColorView *)colorView;
@end

@interface NvEditBGColorView : UIView
@property (nonatomic, assign) id <NvEditBGColorViewDelegate>delegate;

- (void)configData:(NSArray *)array;
@end

NS_ASSUME_NONNULL_END
