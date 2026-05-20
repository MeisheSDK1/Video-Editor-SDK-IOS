//
//  NvFlipCaptionColor.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionColorItem.h"
NS_ASSUME_NONNULL_BEGIN
@class NvFlipCaptionColor;

@protocol NvFlipCaptionColorDelegate <NSObject>

- (void)flipCaptionColor:(NvFlipCaptionColor *)colorView didSelectItem:(NvCaptionColorItem *)item;
- (void)flipCaptionColor:(NvFlipCaptionColor *)colorView okClickItem:(NvCaptionColorItem *)item;

@end



@interface NvFlipCaptionColor : UIView

@property (nonatomic, weak)id delegate;

@property (nonatomic, assign) float colorViewToParentSpacing;

@end

NS_ASSUME_NONNULL_END
