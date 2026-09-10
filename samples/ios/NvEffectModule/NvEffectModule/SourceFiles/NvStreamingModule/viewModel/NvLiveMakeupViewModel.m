//
//  NvLiveMakeupViewModel.m
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/15.
//

#import "NvLiveMakeupViewModel.h"
#import "YYModel.h"
#import "NvLiveAppEnv.h"
#import "NvLiveMakeupItemModel.h"
#import "NvLiveARSceneMakeupView.h"
#import "NvLiveCaptureModularVMMakeup.h"

@interface NvLiveMakeupViewModel () <NvLiveARSceneMakeupViewDelegate>

@property(nonatomic, strong) NSMutableArray<NvLiveMakeupItemModel *> *beautyMakeupArray;

@end

@implementation NvLiveMakeupViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.captureModularVM = [[NvLiveCaptureModularVMMakeup alloc] init];
        [self setupBeautyMakeupArrayData];
    }
    return self;
}

- (NvLiveARSceneMakeupView *)createMakeupView {
    CGRect viewFrame = CGRectMake(0, 0, NvScreen(kWidth), 200 * NvScreen(kScale) + NvScreen(kSafeAreaBottomHeight));
    NvLiveARSceneMakeupView *makeupView = [[NvLiveARSceneMakeupView alloc] initWithFrame:viewFrame];
    makeupView.delegate = self;
    [makeupView configData:self.beautyMakeupArray];
    return makeupView;
}

#pragma mark - 初始化美妆数据
//Initialize the beauty data
- (void)setupBeautyMakeupArrayData {
    self.beautyMakeupArray = [NSMutableArray array];
    NSString *beautyMakeupData = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"beautyMakeupData.bundle"];
    NSString *jsonPath = [beautyMakeupData stringByAppendingPathComponent:@"beautyMakeup.json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    if (!data) {
        NSLog(@"beautyMakeup.json path error");
    }
    NSArray *array = [NSArray yy_modelArrayWithClass:NvLiveMakeupItemModel.class json:data];
    [self.beautyMakeupArray addObjectsFromArray:array];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *packagePath;
    NSString *tempPackagePath;

    for (NvLiveMakeupItemModel *model in self.beautyMakeupArray) {
        jsonPath = [beautyMakeupData stringByAppendingPathComponent:model.infoPath];
        data = [NSData dataWithContentsOfFile:jsonPath];
        array = [NSArray yy_modelArrayWithClass:NvLiveMakeupItemModel.class json:data];
        model.contents = [NSMutableArray array];
        [model.contents addObjectsFromArray:array];

        for (NvLiveMakeupItemModel *contentModel in model.contents) {
            contentModel.effectType = model.effectType;
            if (contentModel.packagePath.length == 0) {
                continue;
            }
            packagePath = [beautyMakeupData stringByAppendingPathComponent:contentModel.packagePath];
            if (model.effectType == -1) {
                contentModel.packagePath = packagePath;
            }
            NSArray *tempArray = [fileManager contentsOfDirectoryAtPath:packagePath error:nil];
            for (NSString *tempPath in tempArray) {
                tempPackagePath = [packagePath stringByAppendingPathComponent:tempPath];
                if (model.effectType != -1) {
                    if ([tempPath.pathExtension isEqualToString:@"videofx"]) {
                        contentModel.packagePath = tempPackagePath;
                    } else if ([tempPath.pathExtension isEqualToString:@"makeup"]) {
                        contentModel.packagePath = tempPackagePath;
                        NSArray *array = [tempPath componentsSeparatedByString:@"."];
                        contentModel.uuid = array.firstObject;
                    } else if ([tempPath.pathExtension isEqualToString:@"facemesh"]) {
                        contentModel.packagePath = tempPackagePath;
                    } else if ([tempPath.pathExtension isEqualToString:@"warp"]) {
                        contentModel.packagePath = tempPackagePath;
                    } else if ([tempPath.pathExtension isEqualToString:@"lic"]) {
                        contentModel.licPath = tempPackagePath;
                    }
                }
                if (([tempPath.pathExtension isEqualToString:@"png"] || [tempPath.pathExtension isEqualToString:@"jpg"]) && (contentModel.coverImage.length <= 0 || !contentModel.coverImage)) {
                    contentModel.coverImage = tempPackagePath;
                }
            }

            if (model.effectType == -1) {
                contentModel.coverImage = [beautyMakeupData stringByAppendingPathComponent:contentModel.coverImage];
            }
        }
    }
}

//MARK: -- NvLiveARSceneMakeupViewDelegate

/**
 应用组合妆容
 Apply the variable makeup effects

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvMakeupView:(NvLiveARSceneMakeupView *)makeupView applyVariableMakeupEffect:(NvLiveMakeupItemModel *)effectModel {
    [self.captureModularVM applicationMakeup:effectModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeBeauty" object:nil];
}

/**
 应用单妆
 Apply the single makeup effects

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvMakeupView:(NvLiveARSceneMakeupView *)makeupView applySingleKindMakeupEffect:(NvLiveMakeupItemModel *)effectModel {
    [self.captureModularVM applicationSingleMakeup:effectModel];
}

- (void)nvMakeupView:(NvLiveARSceneMakeupView *)makeupView refetchModel:(NvLiveMakeupItemModel *)effectModel {
    if (effectModel.effectType == -1) {
        return;
    }
    NSString *packageId = [self.captureModularVM getCurrentSingleMakeupPackageId:effectModel];
    effectModel.selected = [packageId isEqualToString:effectModel.uuid];
}

- (double)nvMakeupView:(NvLiveARSceneMakeupView *)makeupView intensity:(NvLiveMakeupItemModel *)effectModel {
    if (effectModel.effectType == -1) {
        return 0;
    } else {
        return effectModel.value;
    }
    
    return 0;
}

- (void)nvMakeupView:(NvLiveARSceneMakeupView *)makeupView update:(NvLiveMakeupItemModel *)effectModel intensity:(double)intensity {
    if (effectModel.effectType == -1) {
        
    } else {
        effectModel.value = intensity;
        [self.captureModularVM changeSingleMakeup:effectModel];
    }
}

@end
