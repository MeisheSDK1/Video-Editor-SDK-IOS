//
//  NvPrivateAlertView.h
//  SDKDemo
//
//  Created by chengww on 2020/7/24.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, Response) {
    kPrivate = 0,
    kService = 1,
    kAgree   = 2,
    kIgnore  = 3,
};

@interface NvPrivateAlertView : UIView

+ (void)nv_fadeIn:(UIView *)view eventHandle:(void(^)(Response response))handle;

@end

NS_ASSUME_NONNULL_END
