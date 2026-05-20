//
//  NvBottomView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@class NvBottomView;

@protocol NvBottomViewDelegate <NSObject>

/// 确定按钮点击回调
/// OK button click callback
/// @param bottomView 当前对象 Current object
- (void)bottomViewOkClick:(NvBottomView *)bottomView;

@end



@interface NvBottomView : UIView

/// 代理 delegate
@property (nonatomic, weak) id delegate;

@end

NS_ASSUME_NONNULL_END
