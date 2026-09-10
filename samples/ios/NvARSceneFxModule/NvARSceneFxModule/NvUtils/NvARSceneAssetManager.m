//
//  NvARSceneAssetManager.m
//  NvTest
//
//  Created by ms20180425 on 2022/8/22.
//

#import "NvARSceneAssetManager.h"

@interface NvARSceneAssetManager()

@property (nonatomic, strong) NvsEffectSdkContext *effectSdkContext;

@end

@implementation NvARSceneAssetManager

static NvARSceneAssetManager *sharedInstance = nil;
static dispatch_once_t pred;

+ (NvARSceneAssetManager *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    
    dispatch_once(&pred, ^{
        sharedInstance = [[NvARSceneAssetManager alloc] init];
    });
    
    return sharedInstance;
}

+ (void)dellocInstance{
    pred = 0;
    sharedInstance.effectSdkContext = nil;
    sharedInstance = nil;
}

- (NSMutableString *)installAssetPackage:(NSString *)path licPath:(NSString *)licPath assetType:(NvsAssetPackageType)assetType {
    if (!path) {
        return nil;
    }
    
    if (!self.effectSdkContext) {
        self.effectSdkContext = [NvsEffectSdkContext sharedInstance:NvsEffectSdkContextFlag_NoFlag];
    }
    
    NSMutableString *sceneId = [[NSMutableString alloc] init];
    NvsAssetPackageManagerError error = [self.effectSdkContext.assetPackageManager installAssetPackage:path license:licPath type:assetType sync:YES assetPackageId:sceneId];
    if (error != NvsAssetPackageManagerError_AlreadyInstalled && error != NvsAssetPackageManagerError_NoError) {
        NSLog(@"安装素材失败 Material installation failure=====%@,%@,%@,%d",self.effectSdkContext,path,licPath,assetType);
    }
    return sceneId;
}

@end
