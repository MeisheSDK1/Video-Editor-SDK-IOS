//
//  NvPIPWindowView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/21.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvPIPWindowView;

@protocol NvPIPWindowViewDelegate <NSObject>
@optional
- (void)rectView:(NvPIPWindowView *)rectView touchBeganPoint:(CGPoint)point;
- (void)rectView:(NvPIPWindowView*)rectView currentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)previousPoint;

@end

@interface NvPIPWindowView : UIView

@property (weak, nonatomic) id delegate;

@end

