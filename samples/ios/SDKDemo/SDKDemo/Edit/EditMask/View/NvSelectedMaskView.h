//
//  NvSelectedMaskView.h
//  SDKDemo
//
//  Created by ms on 2021/3/4.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvSelectedMaskView : UIView
@property (nonatomic, copy) void(^okBtnClick)(void);

@property (nonatomic, copy) void(^addMaskBtnClick)(void);
@end

NS_ASSUME_NONNULL_END
