//
//  NvMyMusicViewController.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import "NvEditSelectMusicItem.h"
@class NvMyMusicViewController;

@protocol NvMyMusicViewControllerDelegate

- (void)nvMyMusicViewController:(NvMyMusicViewController *)nvMyMusicViewController playItem:(NvEditSelectMusicItem *)item;

@end

@interface NvMyMusicViewController : NvBaseViewController

@property (nonatomic, weak) id delegate;

- (void)reloadData;

@end
