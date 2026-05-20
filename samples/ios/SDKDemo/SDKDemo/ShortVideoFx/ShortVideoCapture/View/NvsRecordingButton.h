//
//  NvsRecordingButton.h
//  progress
//
//  Created by Meicam on 2018/3/18.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NvsRecordingButtonDelegate <NSObject>

/// 开始触摸
/// touch begin
- (void)touchBegin;

/// 触摸结束
/// touch ended
- (void)touchEnd;

@end

@interface NvsRecordingButton : UIView

@property (weak, nonatomic) id delegate;

- (void)stopAnimation;

@end
