//
//  NvPIPOperationView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/12.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NvPIPOperationViewDelegate <NSObject>

- (void)replace;

- (void)zoomIn;

- (void)zoomOut;

- (void)rotate;

- (void)cutVideo;

@end

@interface NvPIPOperationView : UIView

@property (weak, nonatomic) id delegate;

@property (assign, nonatomic) BOOL hiddenCrop;

@end
