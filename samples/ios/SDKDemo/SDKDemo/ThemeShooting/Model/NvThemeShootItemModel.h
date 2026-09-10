//
//  NvThemeShootItemModel.h
//  SDKDemo
//
//  Created by ms20180425 on 2020/8/4.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvBaseModel.h"
#import "NvThemeShootModel.h"
#import "NvsStreamingContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvThemeShootItemModel : NvBaseModel

/// type=0  片头  type =1 片尾  type=2 片段
/// type=0 header type= 1 end type=2 fragments
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, strong) NvShotInfoModel *shotModel;

@property (nonatomic, strong) NvsTimelineCompoundCaption *compoundCaption;

@property (nonatomic, strong, nullable) NvsTimelineVideoFx *filterVideoFx;

@property (nonatomic, strong) UIImage *coverImage;

@end

NS_ASSUME_NONNULL_END
