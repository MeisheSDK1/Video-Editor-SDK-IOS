//
//  LDXScrollLabel.h
//  ScrollLabel
//
//  Created by 刘东旭 on 2017/12/19.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LDXScrollType) {
    LDXAutoScroll,   //自动滚动 Automatic scrolling
    LDXManualScroll, //手动滚动 Manual scrolling
};

typedef NS_ENUM(NSInteger, LDXScrollDirection) {
    LDXFromLeft,  //从左边滚动 Scrolling from the left
    LDXFromRight, //从右边滚动 Scroll from the right
};

@interface NvScrollLabel : UILabel

@property(assign, nonatomic) LDXScrollType scrollType;

@property(assign, nonatomic) LDXScrollDirection scrollDirection;

//手动滚动需要调用一下两个方法来启动停止label滚动
//Manual scrolling requires calling two methods to start and stop label scrolling
- (void)stopAnimate;
- (void)startAnimate;

@end
