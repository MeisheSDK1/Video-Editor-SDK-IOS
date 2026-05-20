//
//  EditPictureDragViewDragBarView.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/8/8.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditPictureDragBarViewDelegate <NSObject>

- (void)movePoint:(CGPoint) point;

@end

@interface EditPictureDragBarView : UIView{
    CGPoint startPoint;
    UIImageView * imageView;
}


@property (weak, nonatomic) id <EditPictureDragBarViewDelegate> delegate;
///拖拽框横纵比
///Drag frame ratio
@property (assign, nonatomic) CGFloat scale;

@end
