//
//  NvEditBGStyleView.h
//  SDKDemo
//
//  Created by MS on 2020/10/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvEditBGStyleModel.h"
NS_ASSUME_NONNULL_BEGIN
@class NvEditBGStyleView;
@protocol NvEditBGStyleViewDelegate <NSObject>

//点击应用按钮方法 Click the Apply button method
- (void)nvEditBGStyleView:(NvEditBGStyleView *)styleView applyButtonClicked:(UIButton *)button;

//选中颜色 Selected color
- (void)nvEditBGStyleView:(NvEditBGStyleView *)styleView selectModel:(NvEditBGStyleModel *)model;

//应用所有片段方法 Apply all fragment methods
- (void)nvEditBGStyleViewApplyAll:(NvEditBGStyleView *)styleView;

@end
@interface NvEditBGStyleView : UIView

@property (nonatomic, assign) id<NvEditBGStyleViewDelegate> delegate;

- (void)configData:(NSArray *)array;
@end

NS_ASSUME_NONNULL_END
