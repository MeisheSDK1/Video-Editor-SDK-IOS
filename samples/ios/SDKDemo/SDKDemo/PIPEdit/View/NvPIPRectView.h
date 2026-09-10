//
//  NvPIPRectView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/18.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvPIPRectView;

@protocol NvPIPRectViewDelegate <NSObject>
@optional
- (void)rectView:(NvPIPRectView*)rectView currentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)previousPoint;
- (void)rectView:(NvPIPRectView *)rectView touchBeganPoint:(CGPoint)point;
- (void)rectView:(NvPIPRectView *)rectView touchUpInside:(CGPoint)point;

@end

@interface NvPIPRectView : UIView

@property (weak, nonatomic) id delegate;

@end
