//
//  NvThemeAssetManager.m
//  NvMimoDemo
//
//  Created by MS on 2019/8/19.
//  Copyright © 2019 MS. All rights reserved.
//

#import "NvThemeAssetManager.h"
#import "YYModel.h"
#import "NVMimoDefineConfig.h"

@interface NvThemeAssetManager ()
@property(nonatomic, copy) NSString *directoryName;
@end

@implementation NvThemeAssetManager

- (instancetype )initWithDirectoryName:(NSString *)directoryName {
    if (self = [super init]) {
        self.directoryName = directoryName;
        self.dirPathArr = [NSMutableArray array];
    }
    return self;
}

- (NSMutableArray *)loadLocalFile {
    if (self.directoryName.length <= 0) {
        return nil;
    }
    [self.dirPathArr removeAllObjects];
    NSMutableArray *themeArr = [NSMutableArray array];
    
    NSString *memoPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Asset/MIMOThemeAsset"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:memoPath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:memoPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fontPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Asset/MIMOFontAsset"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fontPath isDirectory:nil]) {
           [[NSFileManager defaultManager] createDirectoryAtPath:fontPath withIntermediateDirectories:YES attributes:nil error:nil];
       }
    if (![[NSFileManager defaultManager] fileExistsAtPath:memoPath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:memoPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSMutableArray *memoArr = [self readFilesFromBasePath:memoPath];
    if (memoArr.count>0) {
        [themeArr addObjectsFromArray:memoArr];
    }

    NSString *localPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:self.directoryName];
    NSMutableArray *localArr = [self readFilesFromBasePath:localPath];
    [themeArr addObjectsFromArray:localArr];
    return themeArr;
}

- (NSMutableArray *)readFilesFromBasePath:(NSString *)basePath {

    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:basePath error:nil];
//    DLog(@"读取文件%@",dirArray);
    if (dirArray.count <=0) {
        return nil;
    }
    NSDirectoryEnumerator *myDirectoryEnumerator = [myFileManager enumeratorAtPath:basePath];
    
    BOOL isDir = NO;
    BOOL isExist = NO;
    NSMutableArray *categoryArr = [NSMutableArray array];

    for (NSString *path in myDirectoryEnumerator.allObjects) {
        if ([path.pathExtension isEqualToString:@"json"]) {
//            DLog(@"文件一%@", path);  // 所有路径
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", basePath, path];
            isExist = [myFileManager fileExistsAtPath:filePath isDirectory:&isDir];
            [self.dirPathArr addObject:[filePath stringByDeletingLastPathComponent]];
            if (!isDir) {
                NvThemeModel *model = [self processLocalFile:[basePath stringByAppendingPathComponent:path]];
                model.localPath = [self.dirPathArr lastObject];
                [categoryArr addObject:model];
                
            }
        }
        
    }
    return categoryArr;
}

- (NvThemeModel *)processLocalFile:(NSString *)path {
    NSDictionary *info = [self readLocalFileWithName:path];
    NvThemeModel *model = [NvThemeModel yy_modelWithJSON:info];
    return model;
}

- (NSDictionary *)readLocalFileWithName:(NSString *)path {
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

@end
