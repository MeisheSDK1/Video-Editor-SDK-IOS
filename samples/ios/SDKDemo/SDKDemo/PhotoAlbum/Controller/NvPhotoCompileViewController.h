//
//  NvPhotoCompileViewController.h
//  SDKDemo
//
//  Created by MS on 2019/10/8.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimeline.h"
NS_ASSUME_NONNULL_BEGIN

@protocol NvPhotoCompileViewControllerDelegate <NSObject>

@optional
- (void)compileFinished:(BOOL)needDelete;

- (void)compileTimeline:(NvsTimeline *)timeline progress:(CGFloat)progress;
- (void)compileTimelineFailed:(NvsTimeline *)timeline error:(NSError *)error;
- (void)compileTimelineStart:(NvsTimeline *)timeline;
@end
@interface NvPhotoCompileViewController : UIViewController
@property (nonatomic, weak) id <NvPhotoCompileViewControllerDelegate> delegate;

- (void)compileTimeline:(NvsTimeline *)timeline outputPath:(NSString *)ouputPath;

@end

NS_ASSUME_NONNULL_END
