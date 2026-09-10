//
//  NvFlipCaptionColorViewController.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@class NvFlipCaptionColorViewController;
@class NvCaptionColorItem;

@protocol NvFlipCaptionColorViewControllerDelegate <NSObject>

- (void)flipCaptionColorViewController:(NvFlipCaptionColorViewController *)flipCaptionColorViewController didSelectItem:(NvCaptionColorItem *)item;

- (void)flipCaptionColorViewController:(NvFlipCaptionColorViewController *)flipCaptionColorViewController okClickItem:(NvCaptionColorItem *)item;

@end



@interface NvFlipCaptionColorViewController : UIViewController

@property (nonatomic, weak) id delegate;

@end

NS_ASSUME_NONNULL_END
