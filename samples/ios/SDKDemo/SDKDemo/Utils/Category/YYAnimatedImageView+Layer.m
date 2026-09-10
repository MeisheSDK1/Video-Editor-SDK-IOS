//
//  YYAnimatedImageView+Layer.m
//  SDKDemo
//
//  Created by chengww on 2020/11/5.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "YYAnimatedImageView+Layer.h"
#import <objc/runtime.h>
@implementation YYAnimatedImageView (Layer)

+ (void)load {
    Method displayLayerMethod = class_getInstanceMethod(self, @selector(displayLayer:));
    Method displayLayerNewMethod = class_getInstanceMethod(self, @selector(displayLayerNew:));
    method_exchangeImplementations(displayLayerMethod, displayLayerNewMethod);
}
///ios14系统的bug，显示不出来图片需要这样处理
///IOS14 system bug, can not display the image need to deal with this
- (void)displayLayerNew:(CALayer *)layer {
    
    Ivar imgIvar = class_getInstanceVariable([self class], "_curFrame");
    UIImage *img = object_getIvar(self, imgIvar);
    if (img) {
        layer.contents = (__bridge id)img.CGImage;
    } else {
        if (@available(iOS 14.0, *)) {
            [super displayLayer:layer];
        }
    }
}
@end

