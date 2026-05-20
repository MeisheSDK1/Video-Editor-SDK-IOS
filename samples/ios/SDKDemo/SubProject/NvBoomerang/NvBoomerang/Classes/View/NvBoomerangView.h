//
//  NvBoomerangView.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/12/19.
//  Copyright © 2018 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NvStreamingSdkCore/NvsLiveWindow.h>

NS_ASSUME_NONNULL_BEGIN
@protocol NvBoomerangViewDelegate <NSObject>

- (void)backBtnClick;
- (void)deviceBtnClick;
- (void)flashBtnClick;
- (void)shootingBtnClick;
- (void)exportBtnClick;

@end

@interface NvBoomerangView : UIView

@property (nonatomic, weak) id<NvBoomerangViewDelegate> delegate;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;

- (void)enableFlash:(BOOL)enable;
- (void)enableRecordBtn:(BOOL)enable;
- (void)toggleFlash:(BOOL)flash;
- (void)setProgress:(int)progress;
@end

NS_ASSUME_NONNULL_END
