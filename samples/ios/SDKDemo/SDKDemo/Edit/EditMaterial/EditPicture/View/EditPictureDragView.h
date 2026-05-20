//
//  EditPictureDragView.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/8/8.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    startMode = 0,
    endMode,
    areaMode
} DragViewMode;

@protocol EditPictureDragViewDelegate <NSObject>

- (void)updateRect:(CGRect) rect withMode:(DragViewMode) mode;

@end

@interface EditPictureDragView : UIView
{
    CGPoint startPoint;
}

@property (weak, nonatomic) id <EditPictureDragViewDelegate> delegate;
@property (copy, nonatomic) NSString *text;
@property (assign, nonatomic) DragViewMode mode;
@property (assign, nonatomic) CGFloat scale;
@property (nonatomic, assign) CGSize imageSize;
///添加缩放按钮
///Add zoom button
- (void) addDragBar;
///刷新缩放按钮
///Refresh zoom button
- (void) updateDragBar;

@end
