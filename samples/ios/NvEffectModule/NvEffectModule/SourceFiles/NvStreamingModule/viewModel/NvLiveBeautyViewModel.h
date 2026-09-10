//
//  NvLiveBeautyViewModel.h
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/11.
//

#import <Foundation/Foundation.h>

#import "NvLiveBeautyView.h"

NS_ASSUME_NONNULL_BEGIN

@class NvLiveCaptureModularVM;

@interface NvLiveBeautyViewModel : NSObject <NvLiveBeautyViewDelegate>

@property (nonatomic, assign) BOOL activeRefresh;

@property(nonatomic, strong) NSMutableArray *beautyEffectArray;

@property(nonatomic, strong) NSMutableArray *beautyShapeArray;

@property(nonatomic, strong) NSMutableArray *beautyMicroArray;

@property (nonatomic, strong) NvLiveCaptureModularVM *captureModularVM;

- (void)configBeautyView:(NvLiveBeautyView *)beautyView;

@end

NS_ASSUME_NONNULL_END
