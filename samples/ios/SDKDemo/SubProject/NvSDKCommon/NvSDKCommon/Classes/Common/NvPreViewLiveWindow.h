//
//  NvPreViewLiveWindow.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/9/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimeline.h"
#import <NvBaseCommon/NVDefineConfig.h>
//#import "NVHeader.h"


@protocol NvPreViewLiveWindowDelegate

- (void)backClick;

- (void)compileClick:(NvsTimeline *)timeline;

@end

@interface NvPreViewLiveWindow : UIView

@property(nonatomic, weak) id delegate;
@property(nonatomic, assign) NvEditMode model;
@property(nonatomic, strong) NSArray *pathArray;

- (void)againConnection;
@end
