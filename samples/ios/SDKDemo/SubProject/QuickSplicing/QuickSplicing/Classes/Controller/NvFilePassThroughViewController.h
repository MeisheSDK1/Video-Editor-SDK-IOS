//
//  NvFilePassThroughViewController.h
//  QuickSplicing
//
//  Created by 美摄 on 2022/4/8.
//

#import "NvEditBaseViewController.h"
#import "NvsPSTimelineEditor.h"
@class NvFilePassThroughViewController;
NS_ASSUME_NONNULL_BEGIN
@protocol NvFilePassThroughViewControllerDelegate <NSObject>
- (void)filePassThroughViewController:(NvFilePassThroughViewController *)controller info:(NvsPSTimelineEditorInfo *)info;

@end

@interface NvFilePassThroughViewController : NvEditBaseViewController
@property (nonatomic, strong) NvsPSTimelineEditorInfo *info;
@property (nonatomic, assign) id <NvFilePassThroughViewControllerDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
