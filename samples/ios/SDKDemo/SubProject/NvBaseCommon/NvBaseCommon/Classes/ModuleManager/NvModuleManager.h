//
//  NvModuleManager.h
//  SDKDemo
//
//  Created by rongwf on 2021/7/8.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kCurrentNavigationControllerKey;

@interface NvModule : NSObject

@property (nonatomic, strong) UINavigationController *navigationController;

+ (instancetype)module;

/**
 注册模块
 Register module
 */
+ (void)registerModule;

+ (int)moduleIndex;
- (NSString *)moduleTitle;
- (UIImage *)moduleCover;
- (NSString *)localString:(NSString *)translation_key comment:(NSString *)comment;
- (void)startModule:(NSDictionary *)param;

@end

@interface NvModuleManager : NSObject

+ (instancetype)sharedInstance;

/**
 获取所有模块
 @return 所有模块
 Get all modules
 @return all modules
 */
- (NSArray<NvModule *> *)allModules;
- (NvModule *)getModuleForKey:(NSString *)key;

/**
 添加模型
 @param module 实体类
 Adding models
 @param module entity class
 */
+ (void)addModuleClass:(Class)module;

/**
 模块注册，并且排序模块
 Modules register, and sort modules
 */
- (void)generateRegistedModules;

- (void)performPushTargetWithName:(NSString *)targetName params:(NSDictionary *)params ;

@end

NS_ASSUME_NONNULL_END
