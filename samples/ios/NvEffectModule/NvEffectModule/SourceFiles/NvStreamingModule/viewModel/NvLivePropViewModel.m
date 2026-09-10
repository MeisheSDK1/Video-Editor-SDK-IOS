//
//  NvLivePropViewModel.m
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/15.
//

#import "NvLivePropViewModel.h"
#import "NvLiveAppEnv.h"
#import "NvLiveCaptureFilterModel.h"
#import "YYModel.h"
#import "NvLiveARSceneFilterView.h"
#import "NvLiveCaptureModularVMProp.h"
#import "NvLiveStreamingModule.h"

@interface NvLivePropViewModel () <NvLiveARSceneFilterViewDelegate>
@property(nonatomic, strong) NSMutableArray *modelArray;

@end

@implementation NvLivePropViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.captureModularVM = [[NvLiveCaptureModularVMProp alloc]init];
        [self setupData];
    }
    return self;
}

- (void)setupData {
    NSString *filterPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"prop.bundle"];
    NSString *jsonPath = [filterPath stringByAppendingPathComponent:@"prop.json"];
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
            NSString *packageId = [NvLiveStreamingModule getAssetPackageIdFromAssetPackageFilePath:model.packagePath];
            if (packageId.length > 0) {
                NSString *licPath = [[filterPath stringByAppendingPathComponent:packageId] stringByAppendingString:@".lic"];
                model.licPath = licPath;
            }
        }
    }
    self.modelArray = [NSMutableArray arrayWithArray:array];
}

- (NvLiveARSceneFilterView *)createFilterView {
    CGRect viewFrame = CGRectMake(0, 0, NvScreen(kWidth), 285 * NvScreen(kScale) + NvScreen(kSafeAreaBottomHeight));
    NvLiveARSceneFilterView *filterView = [[NvLiveARSceneFilterView alloc] initWithFrame:viewFrame];
    filterView.delegate = self;
    [filterView configFilterArray:self.modelArray needSlider:NO];
    return filterView;
}

//MARK: -- NvLiveARSceneFilterViewDelegate
- (void)nvARSceneFilterView:(NvLiveARSceneFilterView *)filterView withFilter:(NvLiveCaptureFilterModel *)model withState:(BOOL)state {
    if (state) {
        [self.captureModularVM applicationProp:model];
    }
}
@end
