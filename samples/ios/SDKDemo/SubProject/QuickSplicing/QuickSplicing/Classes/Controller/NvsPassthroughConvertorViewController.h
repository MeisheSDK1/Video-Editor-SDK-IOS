//
//  NvsPassthroughCompileViewController.h
//  QuickSplicing
//
//  Created by 美摄 on 2022/4/8.
//

#import <UIKit/UIKit.h>
@class NvsTimeline;

@protocol NvsPassthroughConvertorViewControllerDelegate <NSObject>

@optional
- (void)didConvertorProgress:(int64_t)taskId progress:(float)progress;

- (void)didConvertorFinish:(int64_t)taskId sourceFile:(NSString *)src outputFile:(NSString *)dst trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut errorCode:(int)error;
@end

@interface NvsPassthroughConvertorViewController : UIViewController
@property (nonatomic, assign) BOOL isHDRSetUp;

@property (nonatomic, weak) id <NvsPassthroughConvertorViewControllerDelegate> delegate;

- (int64_t)convertMediaFile:(NSString *)srcFilePath
              outputFile:(NSString *)outputFilePath
                  trimIn:(int64_t)trimIn
                 trimOut:(int64_t)trimOut
                 options:(NSMutableDictionary *)options;

- (void)cancelTask:(int64_t)taskId;
@end
