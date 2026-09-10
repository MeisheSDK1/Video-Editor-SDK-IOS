//
//  NvFlipCaptionListViewController.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import "NvFlipCaptionModel.h"
NS_ASSUME_NONNULL_BEGIN
@class NvFlipCaptionListViewController;

@protocol NvFlipCaptionListViewControllerDelegate <NSObject>

- (void)flipCaptionListViewController:(NvFlipCaptionListViewController *)flipCaptionListViewController editCaptionDataSource:(NSMutableArray *)dataSource;

@end



@interface NvFlipCaptionListViewController : NvBaseViewController

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSMutableArray <NvFlipCaptionModel *>*dataSource;

@end

NS_ASSUME_NONNULL_END
