//
//  NvEditCompoundCaptionViewController.h
//  SDKDemo
//
//  Created by MS on 2019/5/14.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <NvSDKCommon/NvEditBaseViewController.h>
#import "NvCompoundCaptionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvEditCompoundCaptionViewController : NvEditBaseViewController
@property(nonatomic, strong) NvCompoundCaptionModel *compoundCaptionModel;
@end

NS_ASSUME_NONNULL_END
