//
//  NvEditBGBottomView.h
//  SDKDemo
//
//  Created by MS on 2020/10/21.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NvEditBGBottomView;
typedef NS_ENUM(NSInteger,NvEditCanvasCategory)
{
    NvEditCanvasCategoryColor,
    NvEditCanvasCategoryStyle,
    NvEditCanvasCategoryBlur,
};

@protocol NvEditBGBottomViewDelegate <NSObject>
//点击应用按钮 Click the Apply button
- (void)nvEditBGBottomView:(NvEditBGBottomView *)editBGView applyButtonClicked:(UIButton *)button;

//点击item按钮 Click the item button
- (void)nvEditBGBottomView:(NvEditBGBottomView *)editBGView canvasCategory:(NvEditCanvasCategory)canvasCategory;
@end

@interface NvEditBGBottomView : UIView
@property (nonatomic, assign) id <NvEditBGBottomViewDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
