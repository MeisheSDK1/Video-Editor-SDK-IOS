//
//  NvLiveFilterViewModel.m
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/15.
//

#import "NvLiveFilterViewModel.h"
#import "NvLiveAppEnv.h"
#import "NvLiveCaptureFilterModel.h"
#import "YYModel.h"
#import <NveEffectKit/NveEffectKit.h>
#import "NvLiveARSceneFilterView.h"
#import "NvLiveEffectModule.h"

@interface NvLiveFilterViewModel () <NvLiveARSceneFilterViewDelegate>
@property(nonatomic, strong) NSMutableArray *modelArray;

@end

@implementation NvLiveFilterViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupData];
    }
    return self;
}

- (void)setupData {
    NSString *filterPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"filter.bundle"];
    NSString *jsonPath = [filterPath stringByAppendingPathComponent:@"filter.json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSArray *array = [NSArray yy_modelArrayWithClass:NvLiveCaptureFilterModel.class json:data];
    for (NvLiveCaptureFilterModel *model in array) {
        model.coverName = [filterPath stringByAppendingPathComponent:model.coverName];
        if (model.packagePath && model.packagePath.length > 0) {
            model.packagePath = [filterPath stringByAppendingPathComponent:model.packagePath];
        }
        if (model.licPath && model.licPath.length > 0) {
            model.licPath = [filterPath stringByAppendingPathComponent:model.licPath];
        } else {
            NSString *packageId = [NvLiveEffectModule getAssetPackageIdFromAssetPackageFilePath:model.packagePath];
            if (packageId.length > 0) {
                NSString *licPath = [[filterPath stringByAppendingPathComponent:packageId] stringByAppendingString:@".lic"];
                model.licPath = licPath;
            }
        }
        model.displayName = [NvLiveAppEnv isZh]?model.displayNameZhCn:model.displayName;
    }
    self.modelArray = [NSMutableArray arrayWithArray:array];
}

- (NvLiveARSceneFilterView *)createFilterView {
    CGRect viewFrame = CGRectMake(0, 0, NvScreen(kWidth), 285 * NvScreen(kScale) + NvScreen(kSafeAreaBottomHeight));
    NvLiveARSceneFilterView *filterView = [[NvLiveARSceneFilterView alloc] initWithFrame:viewFrame];
    filterView.delegate = self;
    [filterView configFilterArray:self.modelArray needSlider:YES];
    return filterView;
}

//MARK: -- NvLiveARSceneFilterViewDelegate
- (void)nvARSceneFilterView:(NvLiveARSceneFilterView *)filterView withFilter:(NvLiveCaptureFilterModel *)model withState:(BOOL)state {
    if (!state) {
        NveFilterContainer *filterContainer = [NveEffectKit shareInstance].filterContainer;
        NveFilter *filter = filterContainer.filters.firstObject;
        filter.intensity = model.value;
    } else {
        if ((!model.packageId || model.packageId.length == 0) && model.packagePath.length > 0) {
            NSMutableString *mutString = [NSMutableString string];
            NvsAssetPackageManagerError error = [[NveEffectKit shareInstance] installAssetPackage:model.packagePath license:model.licPath type:NvsAssetPackageType_VideoFx assetPackageId:mutString];
            if (error == NvsAssetPackageManagerError_NoError) {
                model.packageId = mutString;
            } else {
                NSLog(@"installAssetPackage error: %d", error);
            }
        }
        NveFilterContainer *filterContainer = [NveEffectKit shareInstance].filterContainer;
        NveFilter *filter = filterContainer.filters.firstObject;
        if (![model.packageId isEqualToString:filter.effectId]) {
            [filterContainer removeAll];
            if (model.packageId) {
                NveFilter *filter = [NveFilter filterWithEffectId:model.packageId];
                filter.intensity = model.value;
                [filterContainer append:filter];
            } else {
                [filterContainer remove:filter];
            }
        }
    }
}
@end
