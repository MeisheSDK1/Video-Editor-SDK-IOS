//
//  NvLiveFilterViewModel.h
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/15.
//

#import <Foundation/Foundation.h>

@class NvLiveARSceneFilterView;
@class NvLiveCaptureModularVMFilter;
NS_ASSUME_NONNULL_BEGIN

@interface NvLiveFilterViewModel : NSObject

@property (nonatomic, strong) NvLiveCaptureModularVMFilter *captureModularVM;

- (NvLiveARSceneFilterView *)createFilterView;

@end

NS_ASSUME_NONNULL_END
