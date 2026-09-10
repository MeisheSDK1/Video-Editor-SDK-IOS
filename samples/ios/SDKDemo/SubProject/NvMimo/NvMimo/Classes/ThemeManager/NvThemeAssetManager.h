//
//  NvThemeAssetManager.h
//  NvMimoDemo
//
//  Created by MS on 2019/8/19.
//  Copyright © 2019 MS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvThemeModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvThemeAssetManager : NSObject
- (instancetype )initWithDirectoryName:(NSString *)directoryName ;
- (NSMutableArray *)loadLocalFile ;
// Resource bundle path
@property(nonatomic,strong) NSMutableArray *dirPathArr; //资源包所在路径
@end

NS_ASSUME_NONNULL_END
