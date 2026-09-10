//
//  NvModuleManager.m
//  SDKDemo
//
//  Created by rongwf on 2021/7/8.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvModuleManager.h"
#import <NvLocalString.h>



NSString *const kCurrentNavigationControllerKey = @"kCurrentNavigationControllerKey";

@implementation NvModule

+ (void)registerModule {
    [NvModuleManager addModuleClass:self];
}

+ (instancetype)module {
    return [[self alloc] init];
}

+ (int)moduleIndex {
    return 0;
}

- (NSString *)moduleTitle {
    return @"";
}

- (UIImage *)moduleCover {
    return nil;
}

- (NSString *)localString:(NSString *)translation_key comment:(NSString *)comment {
    return NvLocalString(translation_key, comment);
}

- (void)startModule:(NSDictionary *)param {
}

@end


static NSMutableArray const * NvModuleClassArray = nil;

@interface NvModuleManager ()

@property (nonatomic, strong) NSMutableArray<NvModule *> *modules;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NvModule *> *modulesMap;

@end

@implementation NvModuleManager

+ (instancetype)sharedInstance {
    static NvModuleManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NvModuleManager alloc] init];
    });
    return instance;
}

+ (void)addModuleClass:(Class)module {
    NSParameterAssert(module && [module isSubclassOfClass:[NvModule class]]);

    if (!NvModuleClassArray) {
        NvModuleClassArray = [NSMutableArray array];
    }

    if (![NvModuleClassArray containsObject:module]) {
        [NvModuleClassArray addObject:module];
    }
}

- (void)performPushTargetWithName:(NSString *)targetName params:(NSDictionary *)params {
    NvModule *module = self.modulesMap[targetName];
    module.navigationController = params[kCurrentNavigationControllerKey];
    [module startModule:params];
}

- (void)generateRegistedModules {
    [self.modules removeAllObjects];
    
    [NvModuleClassArray sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"moduleIndex" ascending:YES]]];

    for (Class cls in NvModuleClassArray) {
        NvModule *module = [cls module];
        NSAssert(module, @"module can't be nil of class %@", NSStringFromClass(cls));
        [self.modulesMap setValue:module forKey:NSStringFromClass([module class])];
        if (![self.modules containsObject:module]) {
            [self.modules addObject:module];
        }
    }
}

- (NSArray<NvModule *> *)allModules {
    return self.modules;
}

- (NvModule *)getModuleForKey:(NSString *)key {
    return self.modulesMap[key];
}

- (NSMutableArray<NvModule *> *)modules {
    if (!_modules) {
        _modules = [NSMutableArray array];
    }
    return _modules;
}

- (NSMutableDictionary *)modulesMap {
    if (!_modulesMap) {
        _modulesMap =[NSMutableDictionary dictionary];
    }
    return _modulesMap;
}

@end
