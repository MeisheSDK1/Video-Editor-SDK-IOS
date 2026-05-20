//
//  NvUrlVideoMaterialVC.h
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/2.
//  Copyright © 2024 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import "NvUrlVideoMaterialCVCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NvUrlVideoMaterialVCDelegate<NSObject>
@optional
- (void)selectMusicItem:(NvListMediaInfoModel *)item trimIn:(float)trimIn trimOut:(float)trimOut;

- (void)selectVideo:(NSMutableArray *)videoPathArray;

@end

@interface NvUrlVideoMaterialVC : NvBaseViewController

@property (nonatomic, weak) id<NvUrlVideoMaterialVCDelegate> delegate;

@property (nonatomic, assign) BOOL isMusicEdit;

@end

NS_ASSUME_NONNULL_END
