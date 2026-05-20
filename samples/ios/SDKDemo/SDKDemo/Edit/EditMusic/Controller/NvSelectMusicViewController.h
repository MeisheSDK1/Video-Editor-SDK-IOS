//
//  NvSelectMusicViewController.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import "NvEditSelectMusicItem.h"
@class NvSelectMusicViewController;

@protocol NvSelectMusicViewControllerDelegate<NSObject>
@optional
- (void)selectMusicViewController:(NvSelectMusicViewController *)selectMusicViewController withItem:(NvEditSelectMusicItem *)item trimIn:(float)trimIn trimOut:(float)trimOut;

- (void)selectNoneMusic;

- (BOOL)updateNotMusicState;

@end

@interface NvSelectMusicViewController : NvBaseViewController

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign) BOOL hiddenTrimButton;

@property (nonatomic, assign) BOOL musiclyric;

- (void)showCutHandleImage;

@end
