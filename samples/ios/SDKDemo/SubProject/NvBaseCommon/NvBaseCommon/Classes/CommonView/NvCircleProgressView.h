//
//  NvCircleProgressView.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/12/20.
//  Copyright © 2018 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NvViewType) {
    kViewBoomrange,
    kViewSuperzoom
};

NS_ASSUME_NONNULL_BEGIN

@interface NvCircleProgressView : UIView

- (instancetype)initWithFrame:(CGRect)frame type:(NvViewType)type;
// progress range: 0-100
@property (nonatomic, assign) int progress;
@end

NS_ASSUME_NONNULL_END
