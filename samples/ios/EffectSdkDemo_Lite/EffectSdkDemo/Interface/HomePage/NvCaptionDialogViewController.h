//
//  NvCaptionDialogViewController.h
//  SDKDemo
//
//  Created by 刘东旭 on 2019/3/28.
//  Copyright © 2019年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionDialog.h"
@class NvCaptionDialogViewController;

@protocol NvCaptionDialogViewControllerDelegate <NSObject>

- (void)captionDialog:(NvCaptionDialogViewController *_Nonnull)captionDialog clickButtonIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface NvCaptionDialogViewController : UIViewController
    
@property (weak, nonatomic)id delegate;

@property (nonatomic, assign) BOOL isChangedText;

@property (nonatomic, assign) NSInteger captionIndex;
    
- (NSString *)getCaptionText;
    
- (void)setCaptionText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
