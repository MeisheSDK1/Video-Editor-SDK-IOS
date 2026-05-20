//
//  NvModifyCompoundCaptionViewController.h
//  SDKDemo
//
//  Created by MS on 2019/5/20.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <NvSDKCommon/NvEditBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvModifyCompoundCaptionViewController : NvEditBaseViewController
@property(nonatomic, strong)NvsTimelineCompoundCaption *caption;
@property(nonatomic, assign)NSInteger selectedIndex;
@property(nonatomic, strong)NSMutableArray *fontDataArr;
@end

NS_ASSUME_NONNULL_END
