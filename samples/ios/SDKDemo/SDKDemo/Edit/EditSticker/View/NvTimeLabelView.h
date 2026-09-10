//
//  NvTimeLabelView.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/7/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NvTimeLabelViewDelegate <NSObject>

- (void)onZoomOutClicked;
- (void)onZoomInClicked;

@end

@interface NvTimeLabelView : UIView {
    @public
    UILabel *timeLabel;
}

@property (nonatomic, weak) id<NvTimeLabelViewDelegate> delegate;
@property (nonatomic, assign) int64_t duration;
@property (nonatomic, assign) int64_t currentPos;

- (void)updateLabel;

@end
