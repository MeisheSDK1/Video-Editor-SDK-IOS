//
//  NvLiveBeautyViewModel.h
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/11.
//

#import <Foundation/Foundation.h>

#import <NveEffectKit/NveEffectKit.h>

//@class NvLiveBeautyView;
//@protocol NvLiveBeautyViewDelegate;

#import "NvLiveBeautyView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvLiveBeautyViewModel : NSObject <NvLiveBeautyViewDelegate>

@property (nonatomic, assign) BOOL activeRefresh;

@property(nonatomic, strong) NSMutableArray *beautyEffectArray;

@property(nonatomic, strong) NSMutableArray *beautyShapeArray;

@property(nonatomic, strong) NSMutableArray *beautyMicroArray;

- (void)configBeautyView:(NvLiveBeautyView *)beautyView;

- (NveBeauty *)defaultBeauty;

- (NveShape *)defaultShap;

- (NveMicroShape *)defaultMicroShap;

@end

NS_ASSUME_NONNULL_END
