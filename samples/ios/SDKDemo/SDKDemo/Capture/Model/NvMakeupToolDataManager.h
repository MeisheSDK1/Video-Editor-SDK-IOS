//
//  NvMakeupToolDataManager.h
//  SDKDemo
//
//  Created by Meishe on 2022/11/9.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvMakeupModel.h"   
#import "NvMakeupToolModel.h"
#import "NvMakeupCellModel.h"
#define NvMakeupBundlePath [[NSBundle mainBundle] pathForResource:@"makeup" ofType:@"bundle"]

typedef NS_ENUM(NSInteger,NvMakeupCategory) {
    NvMakeupCategoryCompose,              //整妆 Complete makeup
    NvMakeupCategoryVariableCompose,      //妆容 makeup
    NvMakeupCategoryCustom,               //单妆（single makeup effect,not compose）
};

typedef NS_ENUM(NSInteger,NvMakeupFunctionMode) {
    NvMakeupFunctionModeCapture,
    NvMakeupFunctionModeEdit,
};
NS_ASSUME_NONNULL_BEGIN

@interface NvMakeupToolDataManager : NSObject
@property (nonatomic, assign) BOOL hasNetwork;
@property (nonatomic, strong) NSMutableArray <NvMakeupLevelModel *>*kindArr;           //分类单妆 Assorted monomakeup
@property (nonatomic, strong) NSMutableArray *variableMakeupArr; //可变整妆  Variable makeup
@property (nonatomic, strong) NvMakeupLevelModel *varialbeMakeupModel;
@property (nonatomic, strong) NvMakeupToolModel *totalEffectContent;
@property (nonatomic, assign) NvMakeupFunctionMode functionMode;
@property (nonatomic, copy) NSArray *labelColorArr;
@property (nonatomic, assign) NSInteger selectedTagIndex;

- (void)getTagData:(void(^)(void))completeBlock;

- (void)getAllVariableMakeupData:(void(^)(void))completeBlock;

- (void)getDetailMakeupKindData:(NvMakeupLevelModel *)model completeBlock:(void(^)(void))completeBlock;

- (void)applyMakeupPackage:(NvMakeupToolModel *)effectModel completeBlock:(void(^)(void))completeBlock;

- (void)downloadAndProcessMakeupPackage:(NvMakeupToolModel *)contentModel variable:(BOOL)isVariable completeBlock:(void(^)(void))completeBlock;

- (void)getVariableMakeupNetworkData:(NSInteger)pageNum pageSize:(NSInteger)pageSize completeBlock:(void(^)(int responsePageSize))completeBlock failureBlock:(void(^)(void))failureBlock;

- (void)getDetailMakeupKindNetworkData:(NSInteger)type kind:(NSInteger)kind page:(NSInteger)page pageSize:(NSInteger)pageSize completeBlock:(void(^)(int responsePageSize))completeBlock failureBlock:(void(^)(void))failureBlock;
@end

NS_ASSUME_NONNULL_END
