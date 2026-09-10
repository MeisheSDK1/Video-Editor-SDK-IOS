//
//  NvDownloadBtn.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvDownloadBtn : UIButton

/// 进度 progress
@property (nonatomic, assign) CGFloat progress;

/// 按钮状态文字 Button state text
@property (nonatomic, strong) NSString *stateTitle;

/// 进度视图的大小 The size of the progress view
@property (nonatomic, assign) CGSize progressSize;

/// 进度背景视图的颜色 The color of the progress background view
@property (nonatomic, strong) NSString *progressColorStr;
@end
