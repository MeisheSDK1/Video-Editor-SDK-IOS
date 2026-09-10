//
//  NvCaptionDialog.h
//  Caption
//
//  Created by 刘东旭 on 2017/8/18.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvCaptionDialog;

@protocol NvCaptionDialogDelegate <NSObject>

- (void)captionDialog:(NvCaptionDialog *)captionDialog clickButtonIndex:(NSInteger)index;

@end

@interface NvCaptionDialog : UIView

@property (weak, nonatomic)id delegate;

- (NSString *)getCaptionText;

- (void)setCaptionText:(NSString *)text;

@end
