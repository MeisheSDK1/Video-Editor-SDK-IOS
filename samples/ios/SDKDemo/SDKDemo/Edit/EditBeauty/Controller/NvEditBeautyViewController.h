//
//  NvEditBeautyViewController.h
//  SDKDemo
//
//  Created by Meishe on 2022/11/15.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvEditBeautyViewController : NvBaseViewController
@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, strong) NvsTimeline *timeline;
@end

NS_ASSUME_NONNULL_END
