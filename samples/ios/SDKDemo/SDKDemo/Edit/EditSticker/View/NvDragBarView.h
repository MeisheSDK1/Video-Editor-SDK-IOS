//
//  NvDragBarView.h
//  SDKDemo
//
//  Created by dx on 2018/6/21.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
///拖拽框属性
///Drag and drop box properties
typedef enum {
    freeMode = 0,
    roundMode,
    squreMode
} DragMode;

@protocol NvDragBarViewDelegate <NSObject>

- (void)movePoint:(CGPoint) point;

@end

@interface NvDragBarView : UIView {
    CGPoint startPoint;
    UIImageView * imageView;
}

@property (weak, nonatomic) id <NvDragBarViewDelegate> delegate;
///拖拽框横纵比
///Drag frame ratio
@property (assign, nonatomic) CGFloat scale;
@property (assign, nonatomic) DragMode mode;

@end
