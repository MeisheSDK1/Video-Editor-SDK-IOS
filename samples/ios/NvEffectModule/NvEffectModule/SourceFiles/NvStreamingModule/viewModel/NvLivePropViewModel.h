//
//  NvLivePropViewModel.h
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/15.
//

#import <Foundation/Foundation.h>
 
@class NvLiveARSceneFilterView;
@class NvLiveCaptureModularVMProp;
NS_ASSUME_NONNULL_BEGIN

@interface NvLivePropViewModel : NSObject

@property (nonatomic, strong) NvLiveCaptureModularVMProp *captureModularVM;

- (NvLiveARSceneFilterView *)createFilterView;

@end

NS_ASSUME_NONNULL_END
