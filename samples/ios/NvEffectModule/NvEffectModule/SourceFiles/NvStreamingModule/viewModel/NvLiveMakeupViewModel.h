//
//  NvLiveMakeupViewModel.h
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/15.
//

#import <Foundation/Foundation.h>

@class NvLiveARSceneMakeupView;
@class NvLiveCaptureModularVMMakeup;
NS_ASSUME_NONNULL_BEGIN

@interface NvLiveMakeupViewModel : NSObject

@property (nonatomic, strong) NvLiveCaptureModularVMMakeup *captureModularVM;

- (NvLiveARSceneMakeupView *)createMakeupView;

@end

NS_ASSUME_NONNULL_END
