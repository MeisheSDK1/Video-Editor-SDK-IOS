//
//  NvInputCaptionVC.h
//  SDKDemo
//
//  Created by ms20180425 on 2020/8/5.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>

@class NvInputCaptionVC;
NS_ASSUME_NONNULL_BEGIN

@protocol NvInputCaptionVCDelegate <NSObject>

- (void)inputCaptionVC:(NvInputCaptionVC *)vc saveText:(NSString *)text;

@end

@interface NvInputCaptionVC : NvBaseViewController

@property (nonatomic, weak) id<NvInputCaptionVCDelegate>delegate;

@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
