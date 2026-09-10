//
//  NvCompileViewController.h
//  SDKDemo
//
//  Created by meishe01 on 2018/6/5.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvsTimeline;

@protocol NvCompileViewControllerDelegate <NSObject>

@optional
- (void)compileFinished:(BOOL)needDelete;

@end

@interface NvCompileViewController : UIViewController

@property (nonatomic, assign) BOOL isHDRSetUp;

@property (nonatomic, weak) id <NvCompileViewControllerDelegate> delegate;

- (void)compileTimeline:(NvsTimeline *)timeline outputPath:(NSString *)ouputPath;

- (void)compileTimeline:(NvsTimeline *)timeline startTime:(int64_t)startTime endTime:(int64_t)endTime outputPath:(NSString *)ouputPath;

- (void)compilePassthroughTimeline:(NvsTimeline *)timeline outputPath:(NSString *)ouputPath;
@end
